@echo off
setlocal enabledelayedexpansion
echo * 请把此脚本放在与BitComet.exe同目录下运行 *
echo * 如非必要，不建议以管理员身份运行 *
echo * 如有需要请自行备份文件 *
echo.
echo 解锁BitComet简体中文版功能限制
echo 如种子市场、完整的IP显示、截图、电驴下载（插件另行安装）等
echo.
echo 此脚本将进行以下操作
echo 1.修改BitComet*.exe的二进制代码（同时支持32位/64位）
echo 2.替换语言，语言选项为繁体中文，实际显示为简体中文
echo 修改的文件：Bitcomet*.exe; BitComet.xml; /lang/bitcomet-zh_TW.mo
echo.
echo * 修改程序可能需要耗时数分钟 *
echo * 此脚本无需安装第三方软件 *
echo * 此脚本不会因重复运行而导致额外的问题 *
pause & cls
if EXIST C:\Windows\System32\Get-Content (
  del C:\Windows\System32\Get-Content
  if EXIST C:\Windows\System32\Get-Content (
    echo 请以管理员身份重新运行此脚本
	pause & exit
  )
)
set l32=EB2883FE017518
set l64=EB2E83FF01751E
set b32=66B8041090900FB7F885F6750866B804109090
set b64=66B8041090900FB7D885FF750866B804109090
set cmd='dir /B /OGN bitcomet*.exe'
:START
echo 将对以下文件进行操作
cd /D "%~dp0"
dir /B /OGN bitcomet*.exe || (cls && ^
echo 未找到Bitcomet*.exe，若脚本所在目录错误，请关闭本窗口 && ^
echo 否则将以管理员身份修改文件夹权限 && pause)
if %ERRORLEVEL% ==1 (icacls "%~dp0\" /grant administrators:F /T && goto START)
echo 程序正在解码，请稍候 ...
for /F %%a in (%cmd%) do (certutil -encodehex -f %%a %%a.hex 12)
if %ERRORLEVEL% ==0 echo 解码成功 √
for /F %%a in (%cmd%) do (
  set flag=0
  findstr /IC:%l32% %%a.hex >nul && set flag=1
  if !flag!==1 (findstr /IC:%b32% %%a.hex >nul && set flag=2)
  if !flag!==1 (
    echo 正在修改32位代码，请稍候 ...
    powershell.exe "(Get-Content %%a.hex) -replace '.{38}%l32%','%b32%%l32%' | Set-Content %%a.hex"
    echo 32位程序正在编码，请稍候 ...
    certutil -decodehex -f %%a.hex %%a
  ) else if !flag!==2 echo 32位程序已解锁，无需修改
  findstr /IC:%l64% %%a.hex >nul && set flag=3
  if !flag!==3 (findstr /IC:%b64% %%a.hex >nul && set flag=4)
  if !flag!==3 (
    echo 正在修改64位代码，请稍候 ...
    powershell.exe "(Get-Content %%a.hex) -replace '.{38}%l64%','%b64%%l64%' | Set-Content %%a.hex"
    echo 64位程序正在编码，请稍候 ...
    certutil -decodehex -f %%a.hex %%a
  ) else if !flag!==4 echo 64位程序已解锁，无需修改
)
if %ERRORLEVEL% ==0 echo 程序修改完成 √
del *.hex
copy /Y .\lang\bitcomet-zh_CN.mo .\lang\bitcomet-zh_TW.mo && echo 修改语言文件成功 √
set axml="%APPDATA%\BitComet\BitComet.xml"
if EXIST BitComet.xml (
  powershell.exe "(Get-Content BitComet.xml) -replace '<Settings>','<Settings><Language>Chinese (Traditional, Taiwan)</Language>' | Set-Content BitComet.xml"
) else if EXIST %axml% (
  powershell.exe "(Get-Content %axml%) -replace '<Settings>','<Settings><Language>Chinese (Traditional, Taiwan)</Language>' | Set-Content %axml%"
) else (
  echo ^<BitComet^> >>BitComet.xml
  echo   ^<Settings^> >>BitComet.xml
  echo    ^<Language^>Chinese ^(Traditional, Taiwan^)^<^/Language^> >>BitComet.xml
  echo   ^</Settings^> >>BitComet.xml
  echo ^</BitComet^> >>BitComet.xml
)
if %ERRORLEVEL% ==0 echo 修改语言配置成功 √
echo.
echo * 所有操作已完成，请确认提示信息 *
echo * 若提示“拒绝访问”，请以管理员身份运行此脚本 *
pause