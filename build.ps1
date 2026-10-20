#requires -version 5
param(
    [string]$JavaHome,
    [string]$AndroidSdkRoot,
    [string]$OutputDirectory = 'dist'
)
$ErrorActionPreference = 'Stop'

# 本地隔离构建脚本：只使用本目录与 ../.toolchains，不写系统 PATH、不安装全局组件。
$Root = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } elseif ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
Set-Location $Root

if (-not $JavaHome) {
    $JavaHome = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { Join-Path $Root '..\.toolchains\jdk\jdk-17.0.20.1+1' }
}
$env:JAVA_HOME = $JavaHome
$env:PATH = (Join-Path $JavaHome "bin") + ";" + $env:PATH
$Sdk      = if ($AndroidSdkRoot) { $AndroidSdkRoot } elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } elseif ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $Root '..\.toolchains\android-sdk' }
$Bt       = Join-Path $Sdk 'build-tools\34.0.0'
$Aj       = Join-Path $Sdk 'platforms\android-34\android.jar'

foreach ($p in @($JavaHome, $Sdk, $Bt, $Aj)) {
    if (-not (Test-Path $p)) { throw "缺少构建依赖：$p" }
}

$aapt2     = Join-Path $Bt 'aapt2.exe'
$aapt      = Join-Path $Bt 'aapt.exe'
$d8        = Join-Path $Bt 'd8.bat'
$zipalign  = Join-Path $Bt 'zipalign.exe'
$apksigner = Join-Path $Bt 'apksigner.bat'
$javac     = Join-Path $JavaHome 'bin\javac.exe'
$keytool   = Join-Path $JavaHome 'bin\keytool.exe'
foreach ($p in @($aapt2, $aapt, $d8, $zipalign, $apksigner, $javac, $keytool)) {
    if (-not (Test-Path $p)) { throw "缺少工具：$p" }
}

$Build = Join-Path $Root 'build'
if (Test-Path $Build) {
    $resolvedBuild = Get-Item -LiteralPath $Build -Force
    if ($resolvedBuild.FullName -ne [IO.Path]::GetFullPath($Build) -or ($resolvedBuild.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw '拒绝清理非项目 build 目录或链接目录'
    }
    Remove-Item -LiteralPath $resolvedBuild.FullName -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $Build 'gen'), (Join-Path $Build 'classes'), (Join-Path $Build 'dex') -Force | Out-Null

Write-Host '[1/6] aapt2 compile/link'
& $aapt2 compile --dir res -o (Join-Path $Build 'res.zip')
if ($LASTEXITCODE -ne 0) { throw 'aapt2 compile 失败' }
& $aapt2 link -o (Join-Path $Build 'unsigned.apk') -I $Aj --manifest AndroidManifest.xml `
    -R (Join-Path $Build 'res.zip') --java (Join-Path $Build 'gen') `
    --min-sdk-version 21 --target-sdk-version 28 --version-code 1 --version-name 1.0 --auto-add-overlay
if ($LASTEXITCODE -ne 0) { throw 'aapt2 link 失败' }

Write-Host '[2/6] javac'
$sources = @(Get-ChildItem -Path src, (Join-Path $Build 'gen') -Recurse -Filter *.java | ForEach-Object { $_.FullName })
& $javac -encoding UTF-8 -source 8 -target 8 -bootclasspath $Aj -d (Join-Path $Build 'classes') @sources
if ($LASTEXITCODE -ne 0) { throw 'javac 失败' }

Write-Host '[3/6] d8'
$classes = @(Get-ChildItem -Path (Join-Path $Build 'classes') -Recurse -Filter *.class | ForEach-Object { $_.FullName })
& $d8 --release --min-api 21 --lib $Aj --output (Join-Path $Build 'dex') @classes
if ($LASTEXITCODE -ne 0) { throw 'd8 失败' }

Write-Host '[4/6] 打包 classes.dex + zipalign'
Copy-Item (Join-Path $Build 'dex\classes.dex') (Join-Path $Build 'classes.dex') -Force
Push-Location $Build
try {
    & $aapt add unsigned.apk classes.dex
    if ($LASTEXITCODE -ne 0) { throw 'aapt add 失败' }
} finally { Pop-Location }
& $zipalign -f 4 (Join-Path $Build 'unsigned.apk') (Join-Path $Build 'aligned.apk')
if ($LASTEXITCODE -ne 0) { throw 'zipalign 失败' }

Write-Host '[5/6] 测试签名（本地自建 keystore，不上传）'
$keystore = Join-Path $Root 'keystore\test-debug.keystore'
if (-not (Test-Path $keystore)) {
    New-Item -ItemType Directory -Path (Split-Path $keystore) -Force | Out-Null
    & $keytool -genkeypair -keystore $keystore -storepass androidtest -keypass androidtest `
        -alias testdebugkey -dname 'CN=Local Test Signing, O=developer-navigator, C=CN' `
        -keyalg RSA -keysize 2048 -validity 10000
    if ($LASTEXITCODE -ne 0) { throw 'keytool 失败' }
}
$Output = if ([IO.Path]::IsPathRooted($OutputDirectory)) { $OutputDirectory } else { Join-Path $Root $OutputDirectory }
New-Item -ItemType Directory -Path $Output -Force | Out-Null
& $apksigner sign --ks $keystore --ks-pass pass:androidtest --key-pass pass:androidtest `
    --out (Join-Path $Output 'tv-settings-navigator.apk') (Join-Path $Build 'aligned.apk')
if ($LASTEXITCODE -ne 0) { throw 'apksigner 失败' }

Write-Host '[6/6] 验证'
& $apksigner verify --verbose --print-certs (Join-Path $Output 'tv-settings-navigator.apk')
if ($LASTEXITCODE -ne 0) { throw 'apksigner verify 失败' }
Get-FileHash (Join-Path $Output 'tv-settings-navigator.apk') -Algorithm SHA256 | Format-List
Write-Host '构建完成。'
