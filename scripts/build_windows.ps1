#requires -Version 5.1
[CmdletBinding()]
param([string]$Godot='godot', [string]$Python='python')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$build = Join-Path $PSScriptRoot 'build.py'
& $Python $build --godot $Godot
if ($LASTEXITCODE -ne 0) { throw "Build falhou (exit $LASTEXITCODE). Consulte evidencias." }
