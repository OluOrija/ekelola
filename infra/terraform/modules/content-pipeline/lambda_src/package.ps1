# PowerShell script to package Lambda functions for Terraform deployment
$ErrorActionPreference = 'Stop'

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $baseDir

# Remove old zip files
Remove-Item -Force -ErrorAction SilentlyContinue validate_mdx.zip, trigger_deploy.zip

# Create validate_mdx.zip
Compress-Archive -Path .\validate_mdx\index.py -DestinationPath .\validate_mdx.zip

# Create trigger_deploy.zip
Compress-Archive -Path .\trigger_deploy\index.py -DestinationPath .\trigger_deploy.zip

Write-Host "Lambda zips created at:"
Get-ChildItem *.zip | Format-Table Name, Length
