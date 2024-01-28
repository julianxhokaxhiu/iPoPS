Set-StrictMode -Version Latest

$env:_APP_VERSION = $env:_BUILD_VERSION.Substring(0,$env:_BUILD_VERSION.LastIndexOf('.'))
if ($env:_BUILD_BRANCH -eq "refs/heads/master" -Or $env:_BUILD_BRANCH -eq "refs/tags/canary")
{
  $env:_IS_BUILD_CANARY = "true"
  $env:_IS_GITHUB_RELEASE = "true"
}
elseif ($env:_BUILD_BRANCH -like "refs/tags/*")
{
  $env:_CHANGELOG_VERSION = $env:_BUILD_VERSION.Substring(0,$env:_BUILD_VERSION.LastIndexOf('.')).Replace('.','')
  $env:_BUILD_VERSION = $env:_BUILD_VERSION.Substring(0,$env:_BUILD_VERSION.LastIndexOf('.')) + ".0"
  $env:_IS_GITHUB_RELEASE = "true"
}
$env:_RELEASE_VERSION = "v${env:_BUILD_VERSION}"

Write-Output "--------------------------------------------------"
Write-Output "BUILD CONFIGURATION: $env:_RELEASE_CONFIGURATION"
Write-Output "RELEASE VERSION: $env:_RELEASE_VERSION"
Write-Output "--------------------------------------------------"

Write-Output "_BUILD_VERSION=${env:_BUILD_VERSION}" >> ${env:GITHUB_ENV}
Write-Output "_RELEASE_VERSION=${env:_RELEASE_VERSION}" >> ${env:GITHUB_ENV}
Write-Output "_IS_BUILD_CANARY=${env:_IS_BUILD_CANARY}" >> ${env:GITHUB_ENV}
Write-Output "_IS_GITHUB_RELEASE=${env:_IS_GITHUB_RELEASE}" >> ${env:GITHUB_ENV}

# Start build
agvtool new-marketing-version $env:_APP_VERSION
xcodebuild -project "${env:_RELEASE_NAME}.xcodeproj" -scheme "${env:_RELEASE_NAME}" -configuration "${env:_RELEASE_CONFIGURATION}" -derivedDataPath ".dist"

# Install dependencies
npm install --global create-dmg

# Create DMG
$ErrorActionPreference = 'SilentlyContinue'
Copy-Item LICENSE .dist/Build/Products/$env:_RELEASE_CONFIGURATION/license.txt
create-dmg .dist/Build/Products/$env:_RELEASE_CONFIGURATION/${env:_RELEASE_NAME}.app .dist/
Move-Item ".dist/${env:_RELEASE_NAME} ${env:_APP_VERSION}.dmg" .dist/${env:_RELEASE_NAME}.dmg
exit 0
