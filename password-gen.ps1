param (
    [Parameter(Mandatory=$true)]
    [string]$VmNames
)

$vmNamesArray = $VmNames -split ","
$passwords = @{}

foreach ($vm in $vmNamesArray) {
    $passwordLength = 4
    $lowercaseChars = "ae"
    $uppercaseChars = "VZ"
    $numberChars = "89"
    $specialChars = "!@"

    # Collecting one character from each required category
    $passwordChars = @(
        $lowercaseChars[(Get-Random -Maximum $lowercaseChars.Length)],
        $uppercaseChars[(Get-Random -Maximum $uppercaseChars.Length)],
        $specialChars[(Get-Random -Maximum $specialChars.Length)]
    )

    # Fill the rest of the password with random characters
    while ($passwordChars.Count -lt $passwordLength) {
        $passwordChars += Get-Random -InputObject ($lowercaseChars + $uppercaseChars + $numberChars + $specialChars)
    }

    # Shuffle and join the characters to form the final password
    $password = -join ($passwordChars | Get-Random -Count $passwordChars.Count)

    $passwords[$vm] = $password
}

$passwords | ConvertTo-Json
