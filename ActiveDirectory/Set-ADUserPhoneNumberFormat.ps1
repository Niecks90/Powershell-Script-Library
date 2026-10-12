<#
.SYNOPSIS
    Formats phone numbers for AD users and exports a preview of changes.

.DESCRIPTION
    This script searches for users with phone numbers in standard AD fields
    (telephoneNumber, mobile, homePhone, otherTelephone). It attempts to format
    numbers starting with an international dialing code (+XX) according to standard
    spacing rules. It outputs a CSV preview of the proposed changes.

.PARAMETER Fields
    The AD fields to check. Defaults to 'telephoneNumber', 'mobile', 'homePhone', 'otherTelephone'.

.PARAMETER ExportPath
    The path to export the CSV preview. Defaults to '.\modifications_preview.csv'.

.EXAMPLE
    Set-ADUserPhoneNumberFormat -ExportPath "C:\temp\phonenumbers.csv"

.OUTPUTS
    None

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string[]]$Fields = @("telephoneNumber", "mobile", "homePhone", "otherTelephone"),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ExportPath = ".\modifications_preview.csv"
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

$export = [System.Collections.Generic.List[PSCustomObject]]::new()

function Format-PhoneNumber {
    param([string]$number)
    $clean = $number -replace '[^\d+]', ''
    switch -Regex ($clean) {
        '^\+33(\d)(\d{2})(\d{2})(\d{2})(\d{2})$' { return "+33 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4]) $($matches[5])" }
        '^\+32(\d{3})(\d{2})(\d{2})(\d{2})$'     { return "+32 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])" }
        '^\+34(\d{3})(\d{2})(\d{2})(\d{2})$'     { return "+34 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])" }
        '^\+351(\d{3})(\d{3})(\d{3})$'           { return "+351 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+44(\d{4})(\d{6})$'                   { return "+44 $($matches[1]) $($matches[2])" }
        '^\+353(\d{2})(\d{3})(\d{4})$'           { return "+353 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+39(\d{3})(\d{3})(\d{4})$'            { return "+39 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+49(\d{3})(\d{4})(\d{4})$'            { return "+49 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+31(\d)(\d{4})(\d{4})$'               { return "+31 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+420(\d{3})(\d{3})(\d{3})$'           { return "+420 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+48(\d{3})(\d{3})(\d{3})$'            { return "+48 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+40(\d{3})(\d{3})(\d{3})$'            { return "+40 $($matches[1]) $($matches[2]) $($matches[3])" }
        '^\+45(\d{2})(\d{2})(\d{2})(\d{2})$'     { return "+45 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])" }
        default                                  { return $number }
    }
}

try {
    # Build filter string for performance
    $filterParts = foreach ($field in $Fields) { "$field -like '*'" }
    $filter = $filterParts -join " -or "

    $users = Get-ADUser -Filter $filter -Properties $Fields -ErrorAction Stop

    foreach ($user in $users) {
        foreach ($field in $Fields) {
            $value = $user.$field
            if ($value -and $value -match '^\+\d{2,3}') {
                $formatted = Format-PhoneNumber $value
                if ($formatted -ne $value) {
                    $export.Add([PSCustomObject]@{
                        user         = $user.SamAccountName
                        field        = $field
                        'old number' = $value
                        'new number' = $formatted
                    })
                }
            }
        }
    }

    if ($export.Count -gt 0) {
        $export | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
        Write-Host "✅ Export complete: $($export.Count) edit(s) detected. Saved to $ExportPath"
    } else {
        Write-Host "No edits detected."
    }
} catch {
    Write-Error "An error occurred: $_"
}
