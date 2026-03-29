[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet('hosted', 'docker', 'mixed')]
  [string]$ExecutionProfile,

  [Parameter()]
  [string]$CompareViPin = 'v0.6.6'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$capabilitiesSchemaPath = Join-Path $repoRoot 'docs/schemas/labview-template-comparevi-capabilities-v1.schema.json'
$dockerLanePolicySchemaPath = Join-Path $repoRoot 'docs/schemas/labview-template-docker-lane-policy-v1.schema.json'
$dockerReceiptSchemaPath = Join-Path $repoRoot 'docs/schemas/labview-template-docker-profile-plan-v1.schema.json'
$runnerTemp = if ([string]::IsNullOrWhiteSpace($env:RUNNER_TEMP)) { [System.IO.Path]::GetTempPath() } else { $env:RUNNER_TEMP }
$outputRoot = Join-Path $runnerTemp 'cookiecutter-render'
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$repoSlug = "template-smoke-{0}-sample" -f $ExecutionProfile
$generatedRoot = Join-Path $outputRoot $repoSlug
if (Test-Path -LiteralPath $generatedRoot) {
  Remove-Item -Recurse -Force $generatedRoot
}

Push-Location $repoRoot
try {
  $cookiecutterArgs = @(
    $repoRoot
    '--no-input'
    '--output-dir'
    $outputRoot
    'project_name=Template Smoke Sample'
    ('repo_slug={0}' -f $repoSlug)
    'github_owner=LabVIEW-Community-CI-CD'
    'default_branch=develop'
    ('execution_profile={0}' -f $ExecutionProfile)
    ('comparevi_tools_consumer_pin={0}' -f $CompareViPin)
    'enable_vi_history_capability=yes'
    'license_holder=LabVIEW Community CI/CD'
    'copyright_year=2026'
  )
  & cookiecutter @cookiecutterArgs

  if (-not (Test-Path -LiteralPath $generatedRoot -PathType Container)) {
    throw "Rendered project was not created at $generatedRoot"
  }

  $dockerGovernanceContractPath = Join-Path $repoRoot 'docs/policy/docker-execution-profile-governance-surface.json'
  $dockerGovernanceContract = Get-Content -LiteralPath $dockerGovernanceContractPath -Raw | ConvertFrom-Json -AsHashtable
  $profileContract = $dockerGovernanceContract.profiles[$ExecutionProfile]
  if ($null -eq $profileContract) {
    throw "Execution-profile governance contract is missing profile entry: $ExecutionProfile"
  }

  $required = @($dockerGovernanceContract.commonRequiredOutputs) + @($profileContract.requiredOutputs)
  $dockerForbiddenPaths = @($dockerGovernanceContract.producerOwnedRuntimePaths)
  $dockerForbiddenWorkflowSnippets = @($dockerGovernanceContract.producerOwnedRuntimeWorkflowSnippets)
  $dockerWorkflowRequiredSnippets = @($dockerGovernanceContract.dockerWorkflowRequiredSnippets)
  foreach ($relativePath in $required) {
    $candidate = Join-Path $generatedRoot $relativePath
    if (-not (Test-Path -LiteralPath $candidate)) {
      throw "Missing rendered file: $relativePath"
    }
  }

  $generatedReadmePath = Join-Path $generatedRoot 'README.md'
  $generatedReadme = Get-Content -LiteralPath $generatedReadmePath -Raw
  $profileSnippet = ('- execution profile: `{0}`' -f $ExecutionProfile)
  $pinSnippet = ('CompareVI.Tools pin: `{0}`' -f $CompareViPin)
  if (-not $generatedReadme.Contains($profileSnippet)) {
    throw "Generated README is missing execution profile snippet: $profileSnippet"
  }
  if (-not $generatedReadme.Contains($pinSnippet)) {
    throw "Generated README is missing the selected CompareVI.Tools pin: $CompareViPin"
  }

  $generatedPlatformDocPath = Join-Path $generatedRoot 'docs/COMPAREVI_PLATFORM_INTEGRATION.md'
  $generatedPlatformDoc = Get-Content -LiteralPath $generatedPlatformDocPath -Raw
  $generatedProvingDocPath = Join-Path $generatedRoot 'docs/CONSUMER_PROVING_RAIL.md'
  $generatedProvingDoc = Get-Content -LiteralPath $generatedProvingDocPath -Raw
  $generatedViHistoryDocPath = Join-Path $generatedRoot 'docs/VI_HISTORY_CAPABILITY.md'
  $generatedViHistoryDoc = Get-Content -LiteralPath $generatedViHistoryDocPath -Raw
  $imageContractSnippet = 'authoritative image-contract source: `consumerContract.dockerImageContract`'
  $capabilitySchemaSourcePath = 'LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-comparevi-capabilities-v1.schema.json'
  $dockerDocPath = Join-Path $generatedRoot 'docs/DOCKER_PROFILE.md'
  $dockerPolicyPath = Join-Path $generatedRoot '.github/comparevi/docker-lane-policy.json'
  $dockerReceiptScriptPath = Join-Path $generatedRoot '.github/comparevi/Emit-DockerProfileReceipt.ps1'
  $dockerReceiptPath = Join-Path $generatedRoot 'tests/results/docker-profile/docker-profile-plan.json'
  $dockerWorkflowPath = Join-Path $generatedRoot '.github/workflows/docker-profile.yml'

  if (-not $generatedReadme.Contains($capabilitySchemaSourcePath)) {
    throw 'Generated README is missing the canonical capability-manifest schema source.'
  }
  if (-not $generatedPlatformDoc.Contains($capabilitySchemaSourcePath)) {
    throw 'Generated platform integration doc is missing the canonical capability-manifest schema source.'
  }
  if (-not $generatedViHistoryDoc.Contains($capabilitySchemaSourcePath)) {
    throw 'Generated vi-history capability doc is missing the canonical capability-manifest schema source.'
  }

  switch ($ExecutionProfile) {
    'hosted' {
      foreach ($relativePath in @($profileContract.forbiddenOutputs)) {
        $candidate = Join-Path $generatedRoot $relativePath
        if (Test-Path -LiteralPath $candidate) {
          throw "Hosted render should not emit Docker scaffold file: $relativePath"
        }
      }
      foreach ($snippet in @($profileContract.requiredPlatformDocSnippets)) {
        if (-not $generatedPlatformDoc.Contains($snippet)) {
          throw "Hosted render is missing required platform doc snippet: $snippet"
        }
      }
      foreach ($snippet in @($profileContract.forbiddenPlatformDocSnippets)) {
        if ($generatedPlatformDoc.Contains($snippet)) {
          throw "Hosted render should not emit forbidden platform doc snippet: $snippet"
        }
      }
      foreach ($snippet in @($profileContract.requiredProvingDocSnippets)) {
        if (-not $generatedProvingDoc.Contains($snippet)) {
          throw "Hosted render is missing required proving doc snippet: $snippet"
        }
      }
      if (Test-Path -LiteralPath $dockerReceiptPath) {
        throw 'Hosted render should not emit a Docker receipt.'
      }
    }
    'docker' {
      foreach ($relativePath in @($profileContract.requiredOutputs)) {
        $candidate = Join-Path $generatedRoot $relativePath
        if (-not (Test-Path -LiteralPath $candidate)) {
          throw "Docker render should emit Docker scaffold file: $relativePath"
        }
      }
      foreach ($snippet in @($profileContract.requiredPlatformDocSnippets)) {
        if (-not $generatedPlatformDoc.Contains($snippet)) {
          throw "Docker render is missing required platform doc snippet: $snippet"
        }
      }
      foreach ($snippet in @($profileContract.requiredProvingDocSnippets)) {
        if (-not $generatedProvingDoc.Contains($snippet)) {
          throw "Docker render is missing required proving doc snippet: $snippet"
        }
      }
    }
    'mixed' {
      foreach ($relativePath in @($profileContract.requiredOutputs)) {
        $candidate = Join-Path $generatedRoot $relativePath
        if (-not (Test-Path -LiteralPath $candidate)) {
          throw "Mixed render should emit Docker scaffold file: $relativePath"
        }
      }
      foreach ($snippet in @($profileContract.requiredPlatformDocSnippets)) {
        if (-not $generatedPlatformDoc.Contains($snippet)) {
          throw "Mixed render is missing required platform doc snippet: $snippet"
        }
      }
      foreach ($snippet in @($profileContract.requiredProvingDocSnippets)) {
        if (-not $generatedProvingDoc.Contains($snippet)) {
          throw "Mixed render is missing required proving doc snippet: $snippet"
        }
      }
    }
  }

  $workflowPath = Join-Path $generatedRoot '.github/workflows/validate.yml'
  $workflowContent = Get-Content -LiteralPath $workflowPath -Raw
  $requiredSnippets = @(
    'feature/*',
    'hotfix/*',
    'release/*',
    '### Consumer proving plan',
    'Hosted Linux consumer lane',
    'Hosted Windows consumer lane',
    'vi_history_enabled',
    'release_asset_name',
    'comparevi_ref',
    'consumerContract.capabilities.viHistory',
    'CompareVI.Tools-$pin.zip',
    'Read and verify producer-native vi-history capability',
    ('uses: LabVIEW-Community-CI-CD/compare-vi-cli-action@{0}' -f $CompareViPin),
    'Hosted Linux compare smoke',
    'Hosted Windows compare smoke',
    'shortCircuitedIdentical',
    'diff'
  )
  foreach ($snippet in $requiredSnippets) {
    if ($workflowContent -notlike "*$snippet*") {
      throw "Generated workflow is missing required snippet: $snippet"
    }
  }

  $capabilityPath = Join-Path $generatedRoot '.github/comparevi/capabilities.json'
  $capabilityJson = Get-Content -LiteralPath $capabilityPath -Raw
  if (-not (Test-Json -Json $capabilityJson -SchemaFile $capabilitiesSchemaPath)) {
    throw 'Rendered capability manifest should validate against the checked-in capability-manifest schema.'
  }
  $capability = $capabilityJson | ConvertFrom-Json -AsHashtable
  if (-not $capability.capabilities.viHistory.enabled) {
    throw 'Rendered capability manifest should enable vi-history for template smoke.'
  }
  if ($capability.capabilities.viHistory.authoritativeConsumerPin -ne $CompareViPin) {
    throw 'Rendered capability manifest did not preserve the CompareVI.Tools consumer pin.'
  }
  if ($capability.capabilities.viHistory.releaseAssetName -ne "CompareVI.Tools-$CompareViPin.zip") {
    throw 'Rendered capability manifest did not preserve the CompareVI.Tools release asset name.'
  }
  if ($capability.capabilities.viHistory.releaseMetadataPath -ne 'comparevi-tools-release.json') {
    throw 'Rendered capability manifest did not preserve the CompareVI.Tools release metadata path.'
  }

  $dockerCapability = if ($capability.capabilities.ContainsKey('dockerProfile')) {
    $capability.capabilities.dockerProfile
  }
  else {
    $null
  }
  switch ($ExecutionProfile) {
    'hosted' {
      if ($null -ne $dockerCapability) {
        throw 'Hosted render should not emit a dockerProfile capability entry.'
      }
    }
    'docker' {
      if ($null -eq $dockerCapability) {
        throw 'Docker render should emit a dockerProfile capability entry.'
      }
      if ($dockerCapability.authoritativeConsumerPin -ne $CompareViPin) {
        throw 'Docker render should keep the CompareVI.Tools pin on the dockerProfile capability.'
      }
      if ($dockerCapability.releaseAssetName -ne "CompareVI.Tools-$CompareViPin.zip") {
        throw 'Docker render should record the released CompareVI.Tools asset name on the dockerProfile capability.'
      }
      if ($dockerCapability.releaseMetadataPath -ne 'comparevi-tools-release.json') {
        throw 'Docker render should record the CompareVI.Tools release metadata path on the dockerProfile capability.'
      }
      if ($dockerCapability.bundleImportPath -ne 'tools/CompareVI.Tools/CompareVI.Tools.psd1') {
        throw 'Docker render should record the bundle import path on the dockerProfile capability.'
      }
      if ($dockerCapability.requestedExecutionProfile -ne 'docker') {
        throw 'Docker render should record docker as the requested execution profile.'
      }
      if ($dockerCapability.hostedSurfaceRetained) {
        throw 'Docker render should not report hostedSurfaceRetained.'
      }
      if (-not $generatedPlatformDoc.Contains($imageContractSnippet)) {
        throw 'Docker render should document the authoritative image contract source.'
      }

      $dockerDoc = Get-Content -LiteralPath $dockerDocPath -Raw
      if (-not $dockerDoc.Contains($capabilitySchemaSourcePath)) {
        throw 'Docker render should document the canonical capability-manifest schema source.'
      }
      foreach ($snippet in @(
        'workflow scaffold: `.github/workflows/docker-profile.yml`',
        'receipt helper: `.github/comparevi/Emit-DockerProfileReceipt.ps1`',
        'releaseAssetName',
        'releaseMetadataPath',
        'bundleImportPath',
        'canonical lane-policy schema source: `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-docker-lane-policy-v1.schema.json`',
        'receipt path: `tests/results/docker-profile/docker-profile-plan.json`',
        'receipt schema: `labview-template/docker-profile-plan@v1`',
        'uploaded artifact name: `docker-profile-plan`'
      )) {
        if (-not $dockerDoc.Contains($snippet)) {
          throw "Docker render should document Docker manifest or receipt contract detail: $snippet"
        }
      }

      $dockerPolicyJson = Get-Content -LiteralPath $dockerPolicyPath -Raw
      if (-not (Test-Json -Json $dockerPolicyJson -SchemaFile $dockerLanePolicySchemaPath)) {
        throw 'Docker lane policy should validate against the checked-in Docker lane-policy schema.'
      }
      $dockerPolicy = $dockerPolicyJson | ConvertFrom-Json -AsHashtable
      if ($dockerPolicy.requestedExecutionProfile -ne 'docker') {
        throw 'Docker lane policy should record docker as the requested execution profile.'
      }
      if ($dockerPolicy.hostedSurfaceRetained) {
        throw 'Docker lane policy should not report hostedSurfaceRetained.'
      }
      if ($dockerPolicy.authoritativeImageContractSource -ne 'consumerContract.dockerImageContract') {
        throw 'Docker lane policy should record the authoritative image contract source.'
      }

      $dockerWorkflow = Get-Content -LiteralPath $dockerWorkflowPath -Raw
      foreach ($snippet in $dockerWorkflowRequiredSnippets) {
        if (-not $dockerWorkflow.Contains($snippet)) {
          throw "Docker workflow scaffold is missing required snippet: $snippet"
        }
      }
      foreach ($snippet in @(
        '.github/comparevi/Emit-DockerProfileReceipt.ps1',
        '"receipt_path=$receiptPath" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append',
        'name: docker-profile-plan'
      )) {
        if (-not $dockerWorkflow.Contains($snippet)) {
          throw "Docker workflow scaffold is missing receipt contract snippet: $snippet"
        }
      }

      $emittedReceiptPath = & pwsh -NoLogo -NoProfile -File $dockerReceiptScriptPath -RepositoryRoot $generatedRoot
      if (-not (Test-Path -LiteralPath $emittedReceiptPath -PathType Leaf)) {
        throw 'Docker render should emit a Docker receipt when the receipt helper runs.'
      }
      $dockerReceiptJson = Get-Content -LiteralPath $emittedReceiptPath -Raw
      if (-not (Test-Json -Json $dockerReceiptJson -SchemaFile $dockerReceiptSchemaPath)) {
        throw 'Docker receipt should validate against the checked-in Docker receipt schema.'
      }
      $dockerReceipt = $dockerReceiptJson | ConvertFrom-Json -AsHashtable
      if ($dockerReceipt.schema -ne 'labview-template/docker-profile-plan@v1') {
        throw 'Docker receipt should record the documented schema.'
      }
      if ($dockerReceipt.requestedExecutionProfile -ne 'docker') {
        throw 'Docker receipt should record docker as the requested execution profile.'
      }
      if ($dockerReceipt.authoritativeConsumerPin -ne $dockerPolicy.authoritativeConsumerPin) {
        throw 'Docker receipt should preserve the authoritative consumer pin from the lane policy.'
      }
      if ($dockerReceipt.authoritativeImageContractSource -ne $dockerPolicy.authoritativeImageContractSource) {
        throw 'Docker receipt should preserve the authoritative image contract source from the lane policy.'
      }
      if ([bool]$dockerReceipt.hostedSurfaceRetained -ne [bool]$dockerPolicy.hostedSurfaceRetained) {
        throw 'Docker receipt should preserve hostedSurfaceRetained from the lane policy.'
      }
      if ($dockerReceipt.lanePolicyPath -ne '.github/comparevi/docker-lane-policy.json') {
        throw 'Docker receipt should record the Docker lane policy path.'
      }
      if ($dockerReceipt.capabilityManifestPath -ne '.github/comparevi/capabilities.json') {
        throw 'Docker receipt should record the capability manifest path.'
      }
      if ($dockerReceipt.integrationDocPath -ne 'docs/DOCKER_PROFILE.md') {
        throw 'Docker receipt should record the Docker integration doc path.'
      }
      if ($dockerReceipt.runtimeOwnership -ne 'producer-owned') {
        throw 'Docker receipt should record producer-owned runtime ownership.'
      }

      foreach ($relativePath in $dockerForbiddenPaths) {
        $candidate = Join-Path $generatedRoot $relativePath
        if (Test-Path -LiteralPath $candidate) {
          throw "Docker render should stay bounded to consumer governance surfaces and must not emit: $relativePath"
        }
      }
      foreach ($snippet in $dockerForbiddenWorkflowSnippets) {
        if ($dockerWorkflow.Contains($snippet)) {
          throw "Docker workflow scaffold should not vendor producer runtime behavior: $snippet"
        }
      }
    }
    'mixed' {
      if ($null -eq $dockerCapability) {
        throw 'Mixed render should emit a dockerProfile capability entry.'
      }
      if ($dockerCapability.authoritativeConsumerPin -ne $CompareViPin) {
        throw 'Mixed render should keep the CompareVI.Tools pin on the dockerProfile capability.'
      }
      if ($dockerCapability.releaseAssetName -ne "CompareVI.Tools-$CompareViPin.zip") {
        throw 'Mixed render should record the released CompareVI.Tools asset name on the dockerProfile capability.'
      }
      if ($dockerCapability.releaseMetadataPath -ne 'comparevi-tools-release.json') {
        throw 'Mixed render should record the CompareVI.Tools release metadata path on the dockerProfile capability.'
      }
      if ($dockerCapability.bundleImportPath -ne 'tools/CompareVI.Tools/CompareVI.Tools.psd1') {
        throw 'Mixed render should record the bundle import path on the dockerProfile capability.'
      }
      if ($dockerCapability.requestedExecutionProfile -ne 'mixed') {
        throw 'Mixed render should record mixed as the requested execution profile.'
      }
      if (-not $dockerCapability.hostedSurfaceRetained) {
        throw 'Mixed render should report hostedSurfaceRetained.'
      }
      if (-not $generatedPlatformDoc.Contains($imageContractSnippet)) {
        throw 'Mixed render should document the authoritative image contract source.'
      }

      $dockerDoc = Get-Content -LiteralPath $dockerDocPath -Raw
      if (-not $dockerDoc.Contains($capabilitySchemaSourcePath)) {
        throw 'Mixed render should document the canonical capability-manifest schema source.'
      }
      foreach ($snippet in @(
        'hosted surface retained: `true`',
        'receipt helper: `.github/comparevi/Emit-DockerProfileReceipt.ps1`',
        'releaseAssetName',
        'releaseMetadataPath',
        'bundleImportPath',
        'canonical lane-policy schema source: `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-docker-lane-policy-v1.schema.json`',
        'receipt path: `tests/results/docker-profile/docker-profile-plan.json`',
        'receipt schema: `labview-template/docker-profile-plan@v1`',
        'uploaded artifact name: `docker-profile-plan`'
      )) {
        if (-not $dockerDoc.Contains($snippet)) {
          throw "Mixed render should document Docker manifest or receipt contract detail: $snippet"
        }
      }

      $dockerPolicyJson = Get-Content -LiteralPath $dockerPolicyPath -Raw
      if (-not (Test-Json -Json $dockerPolicyJson -SchemaFile $dockerLanePolicySchemaPath)) {
        throw 'Mixed lane policy should validate against the checked-in Docker lane-policy schema.'
      }
      $dockerPolicy = $dockerPolicyJson | ConvertFrom-Json -AsHashtable
      if ($dockerPolicy.requestedExecutionProfile -ne 'mixed') {
        throw 'Mixed lane policy should record mixed as the requested execution profile.'
      }
      if (-not $dockerPolicy.hostedSurfaceRetained) {
        throw 'Mixed lane policy should report hostedSurfaceRetained.'
      }
      if ($dockerPolicy.authoritativeImageContractSource -ne 'consumerContract.dockerImageContract') {
        throw 'Mixed lane policy should record the authoritative image contract source.'
      }

      $dockerWorkflow = Get-Content -LiteralPath $dockerWorkflowPath -Raw
      foreach ($snippet in $dockerWorkflowRequiredSnippets) {
        if (-not $dockerWorkflow.Contains($snippet)) {
          throw "Mixed Docker workflow scaffold is missing required snippet: $snippet"
        }
      }
      foreach ($snippet in @(
        '.github/comparevi/Emit-DockerProfileReceipt.ps1',
        '"receipt_path=$receiptPath" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append',
        'name: docker-profile-plan'
      )) {
        if (-not $dockerWorkflow.Contains($snippet)) {
          throw "Mixed Docker workflow scaffold is missing receipt contract snippet: $snippet"
        }
      }

      $emittedReceiptPath = & pwsh -NoLogo -NoProfile -File $dockerReceiptScriptPath -RepositoryRoot $generatedRoot
      if (-not (Test-Path -LiteralPath $emittedReceiptPath -PathType Leaf)) {
        throw 'Mixed render should emit a Docker receipt when the receipt helper runs.'
      }
      $dockerReceiptJson = Get-Content -LiteralPath $emittedReceiptPath -Raw
      if (-not (Test-Json -Json $dockerReceiptJson -SchemaFile $dockerReceiptSchemaPath)) {
        throw 'Mixed receipt should validate against the checked-in Docker receipt schema.'
      }
      $dockerReceipt = $dockerReceiptJson | ConvertFrom-Json -AsHashtable
      if ($dockerReceipt.schema -ne 'labview-template/docker-profile-plan@v1') {
        throw 'Mixed receipt should record the documented schema.'
      }
      if ($dockerReceipt.requestedExecutionProfile -ne 'mixed') {
        throw 'Mixed receipt should record mixed as the requested execution profile.'
      }
      if ($dockerReceipt.authoritativeConsumerPin -ne $dockerPolicy.authoritativeConsumerPin) {
        throw 'Mixed receipt should preserve the authoritative consumer pin from the lane policy.'
      }
      if ($dockerReceipt.authoritativeImageContractSource -ne $dockerPolicy.authoritativeImageContractSource) {
        throw 'Mixed receipt should preserve the authoritative image contract source from the lane policy.'
      }
      if ([bool]$dockerReceipt.hostedSurfaceRetained -ne [bool]$dockerPolicy.hostedSurfaceRetained) {
        throw 'Mixed receipt should preserve hostedSurfaceRetained from the lane policy.'
      }
      if ($dockerReceipt.lanePolicyPath -ne '.github/comparevi/docker-lane-policy.json') {
        throw 'Mixed receipt should record the Docker lane policy path.'
      }
      if ($dockerReceipt.capabilityManifestPath -ne '.github/comparevi/capabilities.json') {
        throw 'Mixed receipt should record the capability manifest path.'
      }
      if ($dockerReceipt.integrationDocPath -ne 'docs/DOCKER_PROFILE.md') {
        throw 'Mixed receipt should record the Docker integration doc path.'
      }
      if ($dockerReceipt.runtimeOwnership -ne 'producer-owned') {
        throw 'Mixed receipt should record producer-owned runtime ownership.'
      }

      foreach ($relativePath in $dockerForbiddenPaths) {
        $candidate = Join-Path $generatedRoot $relativePath
        if (Test-Path -LiteralPath $candidate) {
          throw "Mixed render should stay bounded to consumer governance surfaces and must not emit: $relativePath"
        }
      }
      foreach ($snippet in $dockerForbiddenWorkflowSnippets) {
        if ($dockerWorkflow.Contains($snippet)) {
          throw "Mixed Docker workflow scaffold should not vendor producer runtime behavior: $snippet"
        }
      }
    }
  }

  $lineagePath = Join-Path $generatedRoot '.github/comparevi/lineage.json'
  $lineage = Get-Content -LiteralPath $lineagePath -Raw | ConvertFrom-Json -AsHashtable
  if ($lineage.branchRoles.producerLineage -ne 'upstream/develop') {
    throw 'Rendered lineage manifest is missing the upstream/develop producer-lineage role.'
  }
  if ($lineage.branchRoles.consumerProving -ne 'downstream/develop') {
    throw 'Rendered lineage manifest is missing the downstream/develop consumer-proving role.'
  }

  $historyWorkflowPath = Join-Path $generatedRoot '.github/workflows/vi-history.yml'
  $historyWorkflowContent = Get-Content -LiteralPath $historyWorkflowPath -Raw
  $historySnippets = @(
    ('default: {0}' -f $CompareViPin),
    'CompareVI.Tools-$pin.zip',
    '.github/comparevi/capabilities.json'
  )
  foreach ($snippet in $historySnippets) {
    if ($historyWorkflowContent -notlike "*$snippet*") {
      throw "Generated vi-history workflow is missing required snippet: $snippet"
    }
  }

  if ($env:GITHUB_OUTPUT) {
    "generated_root=$generatedRoot" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
  }
  else {
    Write-Output $generatedRoot
  }
}
finally {
  Pop-Location
}
