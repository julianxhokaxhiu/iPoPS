$env:_APP_VERSION = $env:_BUILD_VERSION.Substring(0,$env:_BUILD_VERSION.LastIndexOf('.'))
if ($env:_BUILD_BRANCH -eq "refs/heads/master" -Or $env:_BUILD_BRANCH -eq "refs/tags/canary") {
  $env:_IS_BUILD_CANARY = "true"
}
elseif ($env:_BUILD_BRANCH -like "refs/tags/*") {
  $env:_BUILD_VERSION = $env:_BUILD_VERSION.Substring(0,$env:_BUILD_VERSION.LastIndexOf('.')) + ".0"
}
$env:_RELEASE_VERSION = "v${env:_BUILD_VERSION}"

Write-Output "--------------------------------------------------"
Write-Output "APP VERSION: $env:_APP_VERSION"
Write-Output "BUILD CONFIGURATION: $env:_RELEASE_CONFIGURATION"
Write-Output "RELEASE VERSION: $env:_RELEASE_VERSION"
Write-Output "--------------------------------------------------"

Write-Host "##vso[task.setvariable variable=_BUILD_VERSION;]${env:_BUILD_VERSION}"
Write-Host "##vso[task.setvariable variable=_RELEASE_VERSION;]${env:_RELEASE_VERSION}"
Write-Host "##vso[task.setvariable variable=_IS_BUILD_CANARY;]${env:_IS_BUILD_CANARY}"

agvtool new-marketing-version $env:_APP_VERSION
xcodebuild -project "${env:_RELEASE_NAME}.xcodeproj" -scheme "${env:_RELEASE_NAME}" -configuration "${env:_RELEASE_CONFIGURATION}" -derivedDataPath ".dist"

npm install --global create-dmg
Copy-Item LICENSE .dist/Build/Products/$env:_RELEASE_CONFIGURATION/license.txt

$ErrorActionPreference = 'SilentlyContinue'
create-dmg .dist/Build/Products/$env:_RELEASE_CONFIGURATION/${env:_RELEASE_NAME}.app .dist/
Move-Item ".dist/${env:_RELEASE_NAME} ${env:_APP_VERSION}.dmg" .dist/${env:_RELEASE_NAME}.dmg
exit 0
