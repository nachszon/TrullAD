<#
.SYNOPSIS
    Precise "true last logon" for Active Directory accounts by aggregating the
    non‑replicated LastLogon attribute from every domain controller (DC).

.DESCRIPTION
    In multi‑DC environments, the LastLogon attribute is updated only on the DC that
    authenticated the sign‑in and is not replicated. To determine the actual most recent
    logon, this script queries ALL DCs for the specified account, converts raw FILETIME
    to DateTime, and returns the latest value ("True Last Logon"). It also prints the
    per‑DC table for transparency and auditability.

    Use this when you need an authoritative answer "when did this account last sign in?".
    For broad inactivity reporting (e.g., 90+ days), LastLogonTimestamp/LastLogonDate is fine
    but it is intentionally delayed by ~9–14 days; it is not suitable for near‑real‑time checks.

.PARAMETER User
    Single SAM account name to query (e.g., 'pussinboots').

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrullAD.ps1 -User pussinboots
    Shows a per‑DC LastLogon table and prints:
    "True last logon for pussinboots: <timestamp>"

.OUTPUTS
    Console tables (per‑DC detail) and a single summary line with the "true" last logon.

.REQUIREMENTS
    • PowerShell 5.1+ or PowerShell 7+
    • ActiveDirectory module (RSAT on a workstation or run on a DC)
    • Read access to user objects in AD

.NOTES
    Author      : Krzysztof Nachszon Lipa‑Izdebski
    Script Name : TrullAD (True Last Logon)
    Version     : 1.0.0
    Released    : 2026‑03‑20
    Licence     : MIT (recommend placing a LICENSE file in the repository)

    Changelog
    1.0.0  (2026‑03‑20)  Initial minimal release: single account, per‑DC table, true last logon.

#>

#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$User
)

# Retrieve all domain controllers in the current domain.
# LastLogon is per‑DC and NOT replicated; we must query them all.
$DCs = (Get-ADDomainController -Filter *).HostName

# Collect LastLogon from each DC and convert FILETIME → DateTime.
# A null value indicates this DC has never authenticated the account.
$rows = foreach ($dc in $DCs) {
    try {
        $u = Get-ADUser -Server $dc -Identity $User -Properties LastLogon
        [pscustomobject]@{
            DC        = $dc
            LastLogon = if ($u.LastLogon -and $u.LastLogon -ne 0) { [datetime]::FromFileTime($u.LastLogon) } else { $null }
        }
    }
    catch {
        # If a DC is unreachable or the lookup fails, record a null and continue.
        [pscustomobject]@{ DC = $dc; LastLogon = $null }
    }
}

# Sort per‑DC results so the freshest timestamps appear first.
$sorted = $rows | Sort-Object LastLogon -Descending

# Display the per‑DC table for transparency (what each DC reports).
$sorted | Format-Table -AutoSize

# Compute the authoritative "True Last Logon" (maximum non‑null value).
$TrueLastLogon = ($sorted | Where-Object LastLogon | Select-Object -First 1).LastLogon

# Print a concise, copy‑friendly summary line.
"True last logon for ${User}: $TrueLastLogon"
