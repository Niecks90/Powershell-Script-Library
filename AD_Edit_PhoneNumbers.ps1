Import-Module ActiveDirectory

$fields = @("telephoneNumber", "mobile", "homePhone", "otherTelephone")
$export = @()

function Format-PhoneNumber($number) {
    $clean = $number -replace '[^\\d+]', ''
    switch -Regex ($clean) {
        '^\\+33(\\d)(\\d{2})(\\d{2})(\\d{2})(\\d{2})$'   { return \"+33 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4]) $($matches[5])\" }
        '^\\+32(\\d{3})(\\d{2})(\\d{2})(\\d{2})$'        { return \"+32 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])\" }
        '^\\+34(\\d{3})(\\d{2})(\\d{2})(\\d{2})$'        { return \"+34 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])\" }
        '^\\+351(\\d{3})(\\d{3})(\\d{3})$'               { return \"+351 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+44(\\d{4})(\\d{6})$'                        { return \"+44 $($matches[1]) $($matches[2])\" }
        '^\\+353(\\d{2})(\\d{3})(\\d{4})$'               { return \"+353 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+39(\\d{3})(\\d{3})(\\d{4})$'                { return \"+39 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+49(\\d{3})(\\d{4})(\\d{4})$'                { return \"+49 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+31(\\d)(\\d{4})(\\d{4})$'                   { return \"+31 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+420(\\d{3})(\\d{3})(\\d{3})$'               { return \"+420 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+48(\\d{3})(\\d{3})(\\d{3})$'                { return \"+48 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+40(\\d{3})(\\d{3})(\\d{3})$'                { return \"+40 $($matches[1]) $($matches[2]) $($matches[3])\" }
        '^\\+45(\\d{2})(\\d{2})(\\d{2})(\\d{2})$'        { return \"+45 $($matches[1]) $($matches[2]) $($matches[3]) $($matches[4])\" }
        default                                         { return $number }
    }
}

$users = Get-ADUser -Filter * -Properties $fields

foreach ($user in $users) {
    foreach ($field in $fields) {
        $value = $user.$field
        if ($value -and $value -match '^\\+\\d{2,3}') {
            $formatted = Format-PhoneNumber $value
            if ($formatted -ne $value) {
                $export += [PSCustomObject]@{
                    user        = $user.SamAccountName
                    field       = $field
                    'old number' = $value
                    'new number' = $formatted
                }
            }
        }
    }
}

$export | Export-Csv -Path "modifications_preview.csv" -NoTypeInformation -Encoding UTF8
Write-Host "✅ Export terminé : $($export.Count) modification(s) détectée(s)."
