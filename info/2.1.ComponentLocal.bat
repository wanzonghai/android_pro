@echo off
set currentDir=%~dp0
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح���ɱ����ȸ��ļ�
echo ح1.ɾ�������ļ����ȸ��ļ�
echo ح2.�������ȸ��ļ�
echo ح3.����MD5�б�
echo ح4.���ܽű�����Դ
echo ح5.������Ӧzip�ļ�
echo ح6.�ƶ������ع����ļ���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ

echo 1.ɾ�������ļ����ȸ��ļ�
RD /S /Q D:\Hotfix\ComponentLocal\client\
RD /S /Q D:\Hotfix\ComponentLocal\game\
DEL /Q D:\Hotfix\ComponentLocal\client.zip

echo 2.�������ȸ��ļ�
cd %currentDir%
if exist "..\encryptComponent" (
    RD /S /Q ..\encryptComponent
)
mkdir ..\encryptComponent
md ..\encryptComponent\game
md ..\encryptComponent\client
md ..\encryptComponent\base
xcopy /y /e ..\clientComponent\client ..\encryptComponent\client\
xcopy /y /e ..\clientComponent\base ..\encryptComponent\base\
xcopy /y /e ..\clientComponent\game ..\encryptComponent\game\

echo 3.����MD5�б�
call make_md5_bx.bat

echo 4.���ܽű�����Դ
call new_encrypt_bx.bat

echo 5.������Ӧzip�ļ�
PUSHD ..\encryptComponent
call WinRAR a -k -r -m1 client.zip client

cd game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (
   call WinRAR a -k -r -m1  %%i.zip %%i
)

echo 6.�ƶ��������ļ���
cd ..\..
xcopy /y /e client D:\Hotfix\ComponentLocal\client\
xcopy /y /e game D:\Hotfix\ComponentLocal\game\
copy client.zip D:\Hotfix\ComponentLocal\client.zip

echo 7.���Դ������APK�ˣ�����
pause


