[CmdletBinding()]
param(
  [Parameter()]
  [string]$RepositoryRoot = (Get-Location).Path
)

$resolvedRepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$capabilityPath = Join-Path $resolvedRepositoryRoot '.github/comparevi/capabilities.json'
$policyPath = Join-Path $resolvedRepositoryRoot '.github/comparevi/docker-lane-policy.json'
$integrationDocPath = Join-Path $resolvedRepositoryRoot 'docs/DOCKER_PROFILE.md'

foreach ($requiredPath in @($capabilityPath, $policyPath, $integrationDocPath)) {
  if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
    throw "Missing Docker receipt contract input: $requiredPath"
  }
}

$capability = Get-Content -LiteralPath $capabilityPath -Raw | ConvertFrom-Json -AsHashtable
$policy = Get-Content -LiteralPath $policyPath -Raw | ConvertFrom-Json -AsHashtable
$dockerProfile = $capability.capabilities.dockerProfile

if ($null -eq $dockerProfile) {
  throw 'Missing capabilities.dockerProfile in .github/comparevi/capabilities.json.'
}
if (-not [bool]$dockerProfile.enabled) {
  throw 'Docker capability manifest entry is present but not enabled.'
}
if ($policy.authoritativeImageContractSource -ne 'consumerContract.dockerImageContract') {
  throw 'Docker lane policy must record consumerContract.dockerImageContract as the authoritative image contract source.'
}
if ($dockerProfile.authoritativeImageContractSource -ne $policy.authoritativeImageContractSource) {
  throw 'Docker capability manifest and Docker lane policy disagree on the authoritative image contract source.'
}
if ($dockerProfile.requestedExecutionProfile -ne $policy.requestedExecutionProfile) {
  throw 'Docker capability manifest and Docker lane policy disagree on the requested execution profile.'
}
if ($dockerProfile.authoritativeConsumerPin -ne $policy.authoritativeConsumerPin) {
  throw 'Docker capability manifest and Docker lane policy disagree on the authoritative consumer pin.'
}

$receiptRoot = Join-Path $resolvedRepositoryRoot 'tests/results/docker-profile'
New-Item -ItemType Directory -Path $receiptRoot -Force | Out-Null
$receiptPath = Join-Path $receiptRoot 'docker-profile-plan.json'
[ordered]@{
  schema = 'labview-template/docker-profile-plan@v1'
  requestedExecutionProfile = $policy.requestedExecutionProfile
  authoritativeConsumerPin = $policy.authoritativeConsumerPin
  authoritativeImageContractSource = $policy.authoritativeImageContractSource
  hostedSurfaceRetained = [bool]$policy.hostedSurfaceRetained
  lanePolicyPath = '.github/comparevi/docker-lane-policy.json'
  capabilityManifestPath = '.github/comparevi/capabilities.json'
  integrationDocPath = 'docs/DOCKER_PROFILE.md'
  runtimeOwnership = 'producer-owned'
} | ConvertTo-Json -Depth 10 | Out-File -LiteralPath $receiptPath -Encoding utf8

$receiptPath
