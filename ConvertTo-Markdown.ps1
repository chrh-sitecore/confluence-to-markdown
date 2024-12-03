[CmdletBinding()]
param (
    # Path to HTML exported from Confluence.
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $InputPath,

    # Path to directory where Markdown is exported.
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputPath,

    # Markdown conversion method. Turndown is the default and best alternative and always available,
    # while pandoc requires a separate install included in PATH.
    [Parameter()]
    [ValidateSet('turndown', 'pandoc')]
    [string]
    $Converter = 'turndown',
	
	[Parameter()]
	[string]
	$DeveloperPortalFolder
)

if (-not (Test-Path $InputPath -PathType Container)) {
    Write-Host 'Error: InputPath must be an existing directory!' -ForegroundColor Red
    exit 1
}

$npm = Get-Command -Name npm -ErrorAction Ignore
if (-not $npm) {
    Write-Host 'Error: Could not locate the npm command. Is Node.js installed?' -ForegroundColor Red
    Write-Host 'To install run: winget install -e --id OpenJS.NodeJS.LTS'
    exit 1
}

Push-Location $PSScriptRoot
try {
    if (-not (Test-Path "node_modules")) {
        Write-Host 'Installing dependencies...' -ForegroundColor Yellow
        & $npm install --no-fund --no-audit --silent
    }
     Write-Host "$npm run start -- --input $InputPath --output $OutputPath --converter $Converter"
    & cmd /c "npm run start -- --input `"$InputPath`" --output `"$OutputPath`" --converter $Converter"
}

finally {
	# Copy attachment folders
    robocopy "$OutputPath/export/attachments" "$OutputPath/public/images/learn/accelerate/content-hub/attachments/" /E /XO /R:0 /W:0
	
	# Copy image folders
    robocopy "$OutputPath/export/images" "$OutputPath/public/images/learn/accelerate/content-hub/img/" /E /XO /R:0 /W:0

    # Copy markdown	
    robocopy "$OutputPath/export/markdown" "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/" /E /XO /R:0 /W:0

	# Copy to DeveloperPortalFolder Host if specified
	if ($DeveloperPortalFolder) {
		if (Test-Path -Path $DeveloperPortalFolder) {
            robocopy "$OutputPath/public" "$DeveloperPortalFolder/public" /E /XO /R:0 /W:0
            robocopy "$OutputPath/data" "$DeveloperPortalFolder/data" /E /XO /R:0 /W:0
        }
	    else {
		    Write-Host "DeveloperPortalFolder not found: $DeveloperPortalFolder"
	    }
    }
	
	Write-Host "All files and folders processed."
    Pop-Location
}

