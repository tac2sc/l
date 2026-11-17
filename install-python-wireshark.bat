@echo off
setlocal EnableExtensions

echo =========================================
echo Python 3.13 and Wireshark Installer
echo =========================================
echo.

where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: winget not found.
    echo Install or update App Installer from Microsoft.
    exit /b 1
)

echo [1/2] Installing Python 3.13...
winget install --id Python.Python.3.13 --exact --scope user --accept-package-agreements --accept-source-agreements

if errorlevel 1 (
    echo ERROR: Python installation failed.
    exit /b 1
)

echo.
echo [2/2] Installing Wireshark...
winget install --id WiresharkFoundation.Wireshark --exact --accept-package-agreements --accept-source-agreements

if errorlevel 1 (
    echo ERROR: Wireshark installation failed.
    exit /b 1
)

echo.
echo =========================================
echo Installation completed
echo =========================================
echo.
echo Close and reopen PowerShell before
echo running zephyr-sniffer.bat.
echo.

exit /b 0
