@echo off
setlocal EnableExtensions

rem Zephyr IEEE 802.15.4 Sniffer installer and Wireshark extcap
rem Version 1.0

rem When Wireshark calls this BAT with arguments,
rem forward them to the official Zephyr Python extcap.
if not "%~1"=="" goto RUN

echo =========================================
echo Zephyr IEEE 802.15.4 Sniffer Installer
echo =========================================
echo.

set "PYTHON=py"
set "PYVER=-3.13"
set "EXTCAP=%APPDATA%\Wireshark\extcap"
set "SCRIPT=%EXTCAP%\ieee802154_sniffer.py"
set "LAUNCHER=%EXTCAP%\zephyr-sniffer.bat"

rem Check Python 3.13
py -3.13 --version
if errorlevel 1 (
    echo.
    echo ERROR: Python 3.13 is required.
    echo Install it using:
    echo winget install --id Python.Python.3.13 --exact
    exit /b 1
)

rem Install pyserial
echo.
echo [1/4] Checking pyserial...

py -3.13 -c "import serial" >nul 2>&1
if errorlevel 1 (
    py -3.13 -m pip install --user pyserial
    if errorlevel 1 (
        echo ERROR: Could not install pyserial.
        exit /b 1
    )
)

rem Create personal Wireshark extcap directory
echo.
echo [2/4] Preparing Wireshark extcap...

if not exist "%EXTCAP%" mkdir "%EXTCAP%"
if errorlevel 1 exit /b 1

rem Download official Zephyr sniffer Python script
echo.
echo [3/4] Downloading official Zephyr plugin...

powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/main/samples/net/ieee802154/sniffer/scripts/ieee802154_sniffer.py' -OutFile '%SCRIPT%'"
if errorlevel 1 (
    echo ERROR: Download failed.
    exit /b 1
)

py -3.13 -m py_compile "%SCRIPT%"
if errorlevel 1 (
    echo ERROR: Python plugin validation failed.
    exit /b 1
)

rem Install this BAT as the Wireshark extcap launcher
echo.
echo [4/4] Registering Wireshark extcap...

if /I not "%~f0"=="%LAUNCHER%" (
    if exist "%LAUNCHER%" (
        echo ERROR: Existing launcher detected:
        echo %LAUNCHER%
        echo No existing launcher was overwritten.
        exit /b 1
    )
    copy "%~f0" "%LAUNCHER%" >nul
    if errorlevel 1 exit /b 1
)

echo.
echo =========================================
echo Installation complete
echo =========================================
echo.

call "%LAUNCHER%" --extcap-interfaces
if errorlevel 1 (
    echo ERROR: Extcap verification failed.
    exit /b 1
)

echo.
echo Close other programs using the COM port.
echo Restart Wireshark to detect the sniffer.
echo.
exit /b 0

:RUN
py -3.13 "%~dp0ieee802154_sniffer.py" %*
exit /b %errorlevel%
