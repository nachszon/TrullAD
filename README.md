# TrullAD — True Last Logon for Active Directory

**TrullAD** provides a precise, defensible “true last logon” timestamp for Active Directory accounts by aggregating the non‑replicated `lastLogon` attribute from **every** domain controller (DC). It also surfaces the replicated `LastLogonDate` (the friendly view of `lastLogonTimestamp`) to highlight expected replication lag.

> **Why this matters**
>
> - `lastLogon` is **accurate** but **not replicated** — the true value is the *maximum across all DCs*.
> - `lastLogonTimestamp` / `LastLogonDate` is **replicated**, but intentionally **delayed** by ~9–14 days by design.
>
> TrullAD automates the per‑DC lookup and provides a trustworthy, audit‑ready result.

---

## Features

- Queries **all** DCs to gather per‑DC `lastLogon` values.
- Converts raw FILETIME into human‑readable `DateTime`.
- Calculates the definitive **True Last Logon** (most recent non‑null value).
- Optionally exports **Summary** and **Per‑DC detail** to CSV.
- Displays replicated `LastLogonDate` for comparison and replication‑lag awareness.
- Supports both **single account** and **bulk mode** (list of accounts).

---

## Requirements

- **PowerShell 5.1+** or **PowerShell 7+**
- **ActiveDirectory** module (RSAT or running directly on a DC)
- Read permissions for user objects in AD

---

## Installation

Clone the repository:

```powershell
git clone https://github.com/nachszon/TruLAD.git
cd TrullAD
```

## Usage

Below are the recommended and tested way to run TruLaL.  
All examples use the safe, fictional sample user pussinboots.  
You may run the script via its relative or absolute path.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrullAD.ps1 -User pusspussinboots
```
