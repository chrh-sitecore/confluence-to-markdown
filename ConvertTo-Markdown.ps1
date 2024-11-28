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

# Define the function
function Copy-FileToFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetFolder
    )

    # Check if the target folder exists; if not, create it
    if (-not (Test-Path -Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force
        Write-Host "Created folder: $TargetFolder"
    }

    # Get the file name and define the destination path
    $fileName = Split-Path -Leaf $FilePath
    $destination = Join-Path -Path $TargetFolder -ChildPath $fileName

    # Check if the file exists
    if (Test-Path -Path $FilePath) {
        # Move the file to the target folder
        Copy-Item -Path $FilePath -Destination $destination -Force
        Write-Host "Moved file to: $destination"
    } else {
        Write-Host "File not found: $FilePath"
    }
}

# Define the function for copying folders
function Copy-FolderToFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceFolder,

        [Parameter(Mandatory = $true)]
        [string]$TargetFolder
    )

    # Check if the source folder exists
    if (Test-Path -Path $SourceFolder) {
        # Copy the folder and its contents, overwriting if necessary
        Copy-Item -Path $SourceFolder -Destination $TargetFolder -Recurse -Force
        Write-Host "Copied folder from '$SourceFolder' to '$TargetFolder'"
    } else {
        Write-Host "Source folder not found: $SourceFolder"
    }
}


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
	# Copy files from export folder to accelerate structure
	Copy-FileToFolder -FilePath "$OutputPath/export/path-path-relation-and-path-hierarchy.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/configuration/schema-management"
	
	#taxonomy-vs-option-list
	Copy-FileToFolder -FilePath "$OutputPath/export/taxonomy-vs-option-list.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/configuration/schema-management"
	
	#	using-direct-or-indirect-security-condition-with-many-to-many-relation
	Copy-FileToFolder -FilePath "$OutputPath/export/using-direct-or-indirect-security-condition-with-many-to-many-relation.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/configuration/schema-management"
	
	# content-hub-insights - pre-development
	Copy-FileToFolder -FilePath "$OutputPath/export/content-hub-insights.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/pre-development"
	
	# User Group Setups - CH Configuration Functional Security (Users and User Groups) 
	Copy-FileToFolder -FilePath "$OutputPath/export/user-group-setups.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/configuration/functional-security"

	Copy-FileToFolder -FilePath "$OutputPath/export/sso-and-auto-assignment.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/configuration/functional-security"


	
	Copy-FileToFolder -FilePath "$OutputPath/export/migration-guide.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/final-steps"

	Copy-FileToFolder -FilePath "$OutputPath/export/ch-scripts-guidance-and-scenarios.md" -TargetFolder "$OutputPath/data/markdown/pages/learn/accelerate/content-hub/implementation/custom-logic"

	# Copy asset folders
	Copy-FolderToFolder -SourceFolder "$OutputPath/export/attachments" -TargetFolder "$OutputPath/public/images/learn/accelerate/content-hub/attachments"
	Copy-FolderToFolder -SourceFolder "$OutputPath/export/images" -TargetFolder "$OutputPath/public/images/learn/accelerate/content-hub/img"

	# Copy to DeveloperPortalFolder Host if specified
	if ($DeveloperPortalFolder) {
		if (Test-Path -Path $DeveloperPortalFolder) {
		Copy-FolderToFolder -SourceFolder "$OutputPath/public" -TargetFolder "$DeveloperPortalFolder"
		Copy-FolderToFolder -SourceFolder "$OutputPath/data" -TargetFolder "$DeveloperPortalFolder"
		}
		else{
			Write-Host "DeveloperPortalFolder not found: $DeveloperPortalFolder"
		}
	}
	Write-Host "All files and folders processed."
    Pop-Location
}

