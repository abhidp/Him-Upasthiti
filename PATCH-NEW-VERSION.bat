@echo off
REM ====================================================================
REM  Him Upasthiti - one-button offline patcher (double-click this file)
REM  Prompts for the version, patches the matching XAPK from Downloads,
REM  builds + signs, and offers to install to a connected phone.
REM
REM  This launcher lives INSIDE the git repo (base_extracted) so it is
REM  version-controlled. autopatch.ps1 auto-locates apktool.jar/signer.jar.
REM ====================================================================
REM  The script keeps this window open itself (it pauses on every exit path),
REM  so no 'pause' is needed here - that would just double-prompt.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\autopatch.ps1"
