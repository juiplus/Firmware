@echo off
:start
cls
rem -----------------------------------------------------------------------
rem Flashes worldclock fw to 0x00 and spiffs filesystem data to 0x300000
rem  usage default in []: 
rem   1. wähle comport# oder [auto]
rem      Mit 'm' wird die FW Version für die Mini Uhr auf den default Comport geflasht!
rem   2. wähle FW Version    [181], o=ohne FW
rem   3. wähle Spiffs Version[181], o=ohne Spiffs 
rem   das Flashen per esptool dauert ca 20s
rem  https://www.flamingo-tech.nl/2021/03/21/installing-and-using-esptools/
rem  which esptool.exe
rem   C:\Users\Jui\AppData\Local\Programs\Python\Python313\Scripts\esptool.exe
rem -----------------------------------------------------------------------

echo ++++++++++++++++++++++++++++++++++
echo +++ ESP8266 Flash WClock       +++
echo +++ (c) 2024 Jui v1.0          +++
echo ++++++++++++++++++++++++++++++++++
echo.
set comport#=auto
set version=181
set baud=256000
set mini=
 
echo Vorhandene serielle Ports:
reg query HKLM\HARDWARE\DEVICEMAP\SERIALCOMM

set /p comport#=Welche COM port#? ([%comport#%],5,9,11.. m=mini, x=Abbruch)
if /i '%comport#%'=='x' goto end
if /i '%comport#%'=='auto' (
    set comport=
    goto check
  )
if /i '%comport#%'=='m' (
    set comport=
    set comport#=auto
    set mini=_mini
    goto check
  )

set "comport=--port com%comport#%"
:check
echo Checke comport:
esptool %comport% flash_id 
if /i '%errorlevel%'=='2' goto end
echo.
dir /D *%mini%.bin
echo.
:selectFW
set fwfile=%version%
set /p fwfile=Welche Firmware%mini% Version? ([%version%],190,.. o=ohne FW, x=Abbruch)
if /i '%fwfile%'=='x' goto end
if /i '%fwfile%'=='o' (
 set fw=
 set fwfile=%version%
)else (
  set fw=0x000000 WC_v%fwfile%%mini%.bin
  IF NOT EXIST WC_v%fwfile%%mini%.bin goto selectFW
)

set spiffsfile=%fwfile%
set /p spiffsfile=Welche Spiffs   Version? ([%fwfile%],190,.. o=ohne Spiffs, x=Abbruch)
if /i '%spiffsfile%'=='x' goto end
if /i '%spiffsfile%'=='o' (
 set spiffs=
)else (
  set spiffs=0x300000 WC_v%spiffsfile%_spiffs.bin
  IF NOT EXIST WC_v%spiffsfile%_spiffs.bin goto selectFW
)
echo +++++++++++++++++++++++++++++++++++
echo Flashe Firmware auf COM_%comport#%:
echo %fw%
echo %spiffs% 
echo +++++++++++++++++++++++++++++++++++
pause
echo.
esptool --chip esp8266 %comport% --baud %baud% write_flash %fw% %spiffs%

echo +++++++++++++++++++++++++++++++++++
echo +++ Flash V%fwfile% fertisch    +++
echo +++++++++++++++++++++++++++++++++++
:end
Pause

