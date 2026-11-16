<#
.SYNOPSIS
    Moves <Tool>.env files saved in "Claude outputs" into their stack folders as <Category>\<Tool>\.env.

.DESCRIPTION
    Claude delivers each stack's .env file as "<Tool>.env" (its remote tools are not allowed to write .env files
    into the repo directly). Run this script after saving them in "Claude outputs": each file is moved to the one
    stack folder with the same name (a folder containing docker-compose.yml, one level below a category folder).
    An existing .env there is replaced. Files with no matching stack folder are left where they are.

.EXAMPLE
    .\Move-EnvFiles.ps1            # move them
    .\Move-EnvFiles.ps1 -WhatIf    # only show what would be moved
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$repo = Split-Path -Parent $PSScriptRoot

$stackFolders = Get-ChildItem -Path $repo -Directory |
    Where-Object { $_.FullName -ne $PSScriptRoot -and -not $_.Name.StartsWith('.') } |
    Get-ChildItem -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'docker-compose.yml') }

$moved = 0
foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.env' -File) {
    $found = @($stackFolders | Where-Object { $_.Name -eq $file.BaseName })
    if ($found.Count -ne 1) {
        Write-Warning "$($file.Name): expected one stack folder named '$($file.BaseName)', found $($found.Count). Skipped."
        continue
    }
    $destination = Join-Path $found[0].FullName '.env'
    $relative = $destination.Substring($repo.Length + 1)
    if ($PSCmdlet.ShouldProcess($relative, "Move $($file.Name)")) {
        Move-Item -LiteralPath $file.FullName -Destination $destination -Force
        Write-Host "$($file.Name) -> $relative"
        $moved++
    }
}
Write-Host "$moved file(s) moved."
