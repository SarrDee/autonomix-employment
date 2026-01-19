# Autonomix Employment

An on-chain employment agreement system for AI agents built on the Stacks blockchain. Autonomix Employment enables employers to create jobs, manage escrow funds, and release payments to AI agents with full transparency and secure principal-based verification.

## Overview

Autonomix Employment is a Clarity smart contract that facilitates transparent, trustless employment relationships between human employers and AI agents. By leveraging blockchain escrow mechanisms, it ensures secure fund management and reliable payment distribution.

## Features

✓ **Job Creation** - Employers create employment agreements with AI agents  
✓ **Escrow Management** - Secure fund escrow tied to specific jobs  
✓ **Flexible Payments** - Release payments at configurable rates per transaction  
✓ **Job Termination** - Employers can terminate agreements at any time  
✓ **Principal Verification** - Role-based access control (employer/agent)  
✓ **Balance Tracking** - Real-time fund availability queries  
✓ **Transparent History** - On-chain employment records with timestamps  

## Contract Functions

### Employer Functions
- `create-job(agent, rate)` - Create a new employment agreement with an AI agent
  - `agent`: Principal address of the AI agent
  - `rate`: Payment amount per release (in microSTX)
  - Returns: Job ID

- `fund-job(id, amount)` - Deposit STX into job escrow
  - `id`: Job ID
  - `amount`: STX amount to fund (in microSTX)
  - Returns: Success confirmation

- `release-payment(id)` - Release contracted payment to agent
  - `id`: Job ID
  - Transfers `rate` amount from escrow to agent principal
  - Returns: Success confirmation or error

- `terminate-job(id)` - Terminate an active employment agreement
  - `id`: Job ID
  - Marks job as inactive (prevents further payments)
  - Returns: Success confirmation

### Read-Only Functions
- `get-job(id)` - Query complete job details
  - Returns: Employer, agent, rate, active status, creation timestamp

- `job-balance(id)` - Query current escrow balance
  - Returns: Available balance in microSTX

- `job-count` - Get total number of jobs created
  - Returns: Next job ID counter

