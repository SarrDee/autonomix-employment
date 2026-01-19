;; ============================================================
;; Contract: autonomix-employment.clar
;; Purpose : On-chain employment agreements for AI agents
;; Network : Stacks
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------

(define-constant ERR-NOT-EMPLOYER      (err u300))
(define-constant ERR-NOT-AGENT         (err u301))
(define-constant ERR-NOT-ACTIVE        (err u302))
(define-constant ERR-ALREADY-ACTIVE    (err u303))
(define-constant ERR-NOT-FOUND         (err u304))
(define-constant ERR-NO-FUNDS          (err u305))

;; -------------------------
;; STATE
;; -------------------------

(define-data-var next-job-id uint u0)

;; -------------------------
;; STORAGE
;; -------------------------

(define-map jobs
  { id: uint }
  {
    employer: principal,
    agent: principal,
    rate: uint,          ;; payment per release (in microSTX)
    active: bool,
    created-at: uint
  }
)

(define-map balances
  { id: uint }
  { amount: uint }
)

;; -------------------------
;; CREATE EMPLOYMENT
;; -------------------------

(define-public (create-job (agent principal) (rate uint))
  (begin
    (let ((id (+ (var-get next-job-id) u1)))
      (map-set jobs
        { id: id }
        {
          employer: tx-sender,
          agent: agent,
          rate: rate,
          active: true,
          created-at: burn-block-height
        }
      )

      (map-set balances { id: id } { amount: u0 })
      (var-set next-job-id id)
      (ok id)
    )
  )
)

;; -------------------------
;; FUND JOB (ESCROW)
;; -------------------------

(define-public (fund-job (id uint) (amount uint))
  (let ((job (map-get? jobs { id: id })))
    (match job data
      (begin
        (asserts! (is-eq tx-sender (get employer data)) ERR-NOT-EMPLOYER)

        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        (let ((bal (default-to { amount: u0 } (map-get? balances { id: id }))))
          (map-set balances
            { id: id }
            { amount: (+ (get amount bal) amount) }
          )
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; RELEASE PAYMENT
;; -------------------------

(define-public (release-payment (id uint))
  (let (
        (job (map-get? jobs { id: id }))
        (bal (map-get? balances { id: id }))
       )
    (match job job-data
      (match bal bal-data
        (begin
          (asserts! (get active job-data) ERR-NOT-ACTIVE)
          (asserts! (is-eq tx-sender (get employer job-data)) ERR-NOT-EMPLOYER)
          (asserts! (>= (get amount bal-data) (get rate job-data)) ERR-NO-FUNDS)

          (map-set balances
            { id: id }
            { amount: (- (get amount bal-data) (get rate job-data)) }
          )

          (as-contract
            (stx-transfer?
              (get rate job-data)
              tx-sender
              (get agent job-data)
            )
          )
        )
        ERR-NOT-FOUND
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; TERMINATE JOB
;; -------------------------

(define-public (terminate-job (id uint))
  (let ((job (map-get? jobs { id: id })))
    (match job data
      (begin
        (asserts! (is-eq tx-sender (get employer data)) ERR-NOT-EMPLOYER)

        (map-set jobs
          { id: id }
          (merge data { active: false })
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; READ-ONLY
;; -------------------------

(define-read-only (get-job (id uint))
  (map-get? jobs { id: id })
)

(define-read-only (job-balance (id uint))
  (map-get? balances { id: id })
)

(define-read-only (job-count)
  (var-get next-job-id)
)
