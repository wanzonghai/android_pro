@echo off
set currentDir=%~dp0
set sourceDir=%~dp0..\..\clientComponent\
set encryptDir=%~dp0..\..\encryptComponent\
set remoteDir=Y:\Component\
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo حһ��ʽ������ȸ�����(2023-04-27)
echo ح��ȷ��%currentDir%��,����GameList.txt(������Ϸ��Ҫ��������)
echo ح��ѡ����Ҫִ�еĲ�����
echo ح1.�ȸ�
echo ح2.���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
set /p FuncSelect=��ѡ��,���س�ȷ��:
if %FuncSelect%==1 (
	cls & goto SelectMakeHotfix
) 
if %FuncSelect%==2 (
	cls & goto GenerateAPK
)

:SelectMakeHotfix
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح��ѡ����Ҫִ�еĲ�����
echo ح1.���Է�(��Ҫ����)%currentDir%1Local\
echo ح2.���Է�(�Զ��ϴ�)%currentDir%2Debug\
echo ح3.ƽ�з�(��Ҫ�ϴ�)%currentDir%3Alpha\
echo ح4.��ʽ��(��Ҫ�ϴ�)%currentDir%4Release\
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
set /p HotfixSelect=��ѡ��,���س�ȷ��:

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
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح����%encryptDir%��base�ļ���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
if exist "%encryptDir%" (
    RD /S /Q %encryptDir%
)
mkdir %encryptDir%
md %encryptDir%base
xcopy /y /e %sourceDir%base %encryptDir%base\
echo ���ɡ�base����filemd5List.json
FilesMd5 %encryptDir%base %temp%\filemd5List_base.json 
copy %temp%\filemd5List_base.json %encryptDir%base\res\filemd5List.json
del %temp%\filemd5List_base.json

md %encryptDir%client
xcopy /y /e %sourceDir%client %encryptDir%client\
echo ���ɡ�client����filemd5List.json
FilesMd5 %encryptDir%client %temp%\filemd5List_client.json 
copy %temp%\filemd5List_client.json %encryptDir%client\res\filemd5List.json
del %temp%\filemd5List_client.json

echo 5.���ܽű�����Դ
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
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح����%midDir%�ȸ��ļ�
echo ح1.ɾ��%midDir%�ļ����ȸ��ļ�
echo ح2.�������ȸ��ļ�
echo ح3.�Ƴ�base���������µ���Դ�ļ�
echo ح4.����MD5�б�
echo ح5.���ܽű�����Դ
echo ح6.������Ӧzip�ļ�
echo ح7.�ƶ���%midDir%�ļ���
echo ح8.ɾ��%encryptDir%��������Դ
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo 1.ɾ��%midDir%�ļ����ȸ��ļ�
if not exist "%currentDir%%midDir%" (
	mkdir %currentDir%%midDir%
)
RD /S /Q %currentDir%%midDir%\base\
RD /S /Q %currentDir%%midDir%\client\
RD /S /Q %currentDir%%midDir%\game\
DEL /Q %currentDir%%midDir%\base.zip
DEL /Q %currentDir%%midDir%\client.zip
cls
echo 2.�������ȸ��ļ�
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
echo 3.�Ƴ�base���������µ���Դ�ļ�
DEL /Q %encryptDir%base\ChannelConfig.json
DEL /Q %encryptDir%base\threeSdkSwitch.json
DEL /Q %encryptDir%base\src\config.lua
DEL /Q %encryptDir%base\src\app\models\ylAll.lua
cls
echo 4.����MD5�б�
call 2.MakeMD5.bat
cls
echo 5.���ܽű�����Դ
python 3.Encrypt.py %encryptDir%
cls
echo 6.������Ӧzip�ļ�
echo 6.1������base.zip���ļ�
cd %encryptDir%
call WinRAR a -k -r -m1 base.zip base
echo 6.2������client.zip���ļ�
call WinRAR a -k -r -m1 client.zip client
cd %encryptDir%game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (	
	echo 6.3������%%i.zip���ļ�
	call WinRAR a -k -r -m1  %%i.zip %%i
)
cls
cd %encryptDir%
echo 7.�ƶ���%midDir%�ļ���
xcopy /y /e base %currentDir%%midDir%\base\
xcopy /y /e client %currentDir%%midDir%\client\
xcopy /y /e game %currentDir%%midDir%\game\
copy base.zip %currentDir%%midDir%\base.zip
copy client.zip %currentDir%%midDir%\client.zip
cls
echo 8.ɾ��%encryptDir%��������Դ
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