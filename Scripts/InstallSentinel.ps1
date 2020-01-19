param (
    [Parameter(Mandatory=$true)]$OnboardingFile
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

$artifactName = "OnboardingFile"

#Build the full path for the onboarding file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$onboardingFilePath = Join-Path $artifactPath $OnboardingFile

$workspaces = Get-Content -Raw -Path $onboardingFilePath | ConvertFrom-Json

Write-Host "Deployments are: $workspaces"

foreach ($item in $workspaces.deployments){
    Write-Host "Processing workspace $wrkspce ..."
    $solutions = Get-AzOperationalInsightsIntelligencePack -resourcegroupname $item.resourcegroup -WorkspaceName $item.workspace

    if (($solutions | Where-Object Name -eq 'SecurityInsights').Enabled) {
        Write-Error "SecurityInsights solution is already enabled for workspace $($item.workspace)"
        exit
    }
    else {
        Set-AzSentinel -WorkspaceName $item.workspace -Confirm:$false
    }
}

