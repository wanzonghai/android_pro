@echo off
set currentDir=%~dp0
set sourceDir=%~dp0..\..\clientComponent\
set encryptDir=%~dp0..\..\encryptComponent\
set remoteDir=Y:\Component\
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨一键式打包及热更工具(2023-04-27)
echo 丨请确保%currentDir%下,包含GameList.txt(新增游戏需要新增配置)
echo 丨请选择需要执行的操作：
echo 丨1.热更
echo 丨2.打包
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
set /p FuncSelect=请选择,并回车确定:
if %FuncSelect%==1 (
	cls & goto SelectMakeHotfix
) 
if %FuncSelect%==2 (
	cls & goto GenerateAPK
)

:SelectMakeHotfix
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨请选择需要执行的操作：
echo 丨1.测试服(需要挂载)%currentDir%1Local\
echo 丨2.测试服(自动上传)%currentDir%2Debug\
echo 丨3.平行服(需要上传)%currentDir%3Alpha\
echo 丨4.正式服(需要上传)%currentDir%4Release\
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
set /p HotfixSelect=请选择,并回车确定:

if %HotfixSelect%==1 (
	cls & goto MakeHotfixLocal
)
if %HotfixSelect%==2 (
	cls & goto MakeHotfixDebug
)
if %HotfixSelect%==3 (
	cls & goto MakeHotfixAlpha
)
if %HotfixSelect%==4 (
	cls & goto MakeHotfixRelease
)

:GenerateAPK
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨生成%encryptDir%下base文件夹
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
if exist "%encryptDir%" (
    RD /S /Q %encryptDir%
)
mkdir %encryptDir%
md %encryptDir%base
xcopy /y /e %sourceDir%base %encryptDir%base\
echo 生成《base》的filemd5List.json
FilesMd5 %encryptDir%base %temp%\filemd5List_base.json 
copy %temp%\filemd5List_base.json %encryptDir%base\res\filemd5List.json
del %temp%\filemd5List_base.json

md %encryptDir%client
xcopy /y /e %sourceDir%client %encryptDir%client\
echo 生成《client》的filemd5List.json
FilesMd5 %encryptDir%client %temp%\filemd5List_client.json 
copy %temp%\filemd5List_client.json %encryptDir%client\res\filemd5List.json
del %temp%\filemd5List_client.json

echo 5.加密脚本和资源
python 3.Encrypt.py %encryptDir%
goto End

:MakeHotfixLocal
set midDir=1Local
goto MakeHotfix

:MakeHotfixDebug
set midDir=2Debug
goto MakeHotfix

:MakeHotfixAlpha
set midDir=3Alpha
goto MakeHotfix

:MakeHotfixRelease
set midDir=4Release
goto MakeHotfix

:MakeHotfix
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨生成%midDir%热更文件
echo 丨1.删除%midDir%文件夹热更文件
echo 丨2.拷贝需热更文件
echo 丨3.移除base下跳过更新的资源文件
echo 丨4.生成MD5列表
echo 丨5.加密脚本和资源
echo 丨6.创建对应zip文件
echo 丨7.移动到%midDir%文件夹
echo 丨8.删除%encryptDir%下冗余资源
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 1.删除%midDir%文件夹热更文件
if not exist "%currentDir%%midDir%" (
	mkdir %currentDir%%midDir%
)
RD /S /Q %currentDir%%midDir%\base\
RD /S /Q %currentDir%%midDir%\client\
RD /S /Q %currentDir%%midDir%\game\
DEL /Q %currentDir%%midDir%\base.zip
DEL /Q %currentDir%%midDir%\client.zip
cls
echo 2.拷贝需热更文件
if exist "%encryptDir%" (
    RD /S /Q %encryptDir%
)
mkdir %encryptDir%
md %encryptDir%base
md %encryptDir%client
md %encryptDir%game
xcopy /y /e %sourceDir%base %encryptDir%base\
xcopy /y /e %sourceDir%client %encryptDir%client\
xcopy /y /e %sourceDir%game %encryptDir%game\
cls
echo 3.移除base下跳过更新的资源文件
DEL /Q %encryptDir%base\ChannelConfig.json
DEL /Q %encryptDir%base\threeSdkSwitch.json
DEL /Q %encryptDir%base\src\config.lua
DEL /Q %encryptDir%base\src\app\models\ylAll.lua
cls
echo 4.生成MD5列表
call 2.MakeMD5.bat
cls
echo 5.加密脚本和资源
python 3.Encrypt.py %encryptDir%
cls
echo 6.创建对应zip文件
echo 6.1创建《base.zip》文件
cd %encryptDir%
call WinRAR a -k -r -m1 base.zip base
echo 6.2创建《client.zip》文件
call WinRAR a -k -r -m1 client.zip client
cd %encryptDir%game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (	
	echo 6.3创建《%%i.zip》文件
	call WinRAR a -k -r -m1  %%i.zip %%i
)
cls
cd %encryptDir%
echo 7.移动到%midDir%文件夹
xcopy /y /e base %currentDir%%midDir%\base\
xcopy /y /e client %currentDir%%midDir%\client\
xcopy /y /e game %currentDir%%midDir%\game\
copy base.zip %currentDir%%midDir%\base.zip
copy client.zip %currentDir%%midDir%\client.zip
cls
echo 8.删除%encryptDir%下冗余资源
RD /S /Q %encryptDir%client\
RD /S /Q %encryptDir%game\
DEL /Q %encryptDir%base.zip
DEL /Q %encryptDir%client.zip

if %HotfixSelect%==2 (
	cls & goto MoveToDebug
)
if %HotfixSelect%==3 (
	cls & goto UploadToAlpha
)
if %HotfixSelect%==4 (
	cls & goto UploadToRelease
)
goto End

:MoveToDebug
cd %currentDir%%midDir%
RD /S /Q  %remoteDir%base\
RD /S /Q  %remoteDir%client\
RD /S /Q  %remoteDir%game\
DEL /Q  %remoteDir%base.zip
DEL /Q  %remoteDir%client.zip
xcopy /y /e base %remoteDir%base\
xcopy /y /e client %remoteDir%client\
xcopy /y /e game %remoteDir%game\
copy base.zip %remoteDir%base.zip
copy client.zip %remoteDir%client.zip
RD /S /Q %currentDir%%midDir%\base\
RD /S /Q %currentDir%%midDir%\client\
RD /S /Q %currentDir%%midDir%\game\
DEL /Q %currentDir%%midDir%\base.zip
DEL /Q %currentDir%%midDir%\client.zip
goto End

:UploadToAlpha
echo Upload to alpha
goto End

:UploadToRelease
echo Upload to release
goto End

:End
cd %currentDir%
pause