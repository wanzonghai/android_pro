@echo off
set currentDir=%~dp0
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح����������192.168.1.230���ȸ��ļ�
echo ح1.ɾ�����������ȸ��ļ�
echo ح2.�������ȸ��ļ�
echo ح3.����MD5�б�
echo ح4.���ܽű�����Դ
echo ح5.������Ӧzip�ļ�
echo ح6.�ƶ������������ļ���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ

echo 1.ɾ�����������ȸ��ļ�
RD /S /Q  Z:\Component\client\
RD /S /Q  Z:\Component\game\
DEL /Q  Z:\Component\client.zip

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

echo 6.�ƶ������������ļ���
cd ..\..
xcopy /y /e client Z:\Component\client\
xcopy /y /e game Z:\Component\game\
copy client.zip Z:\Component\client.zip

echo 7.���Գ�APK�ˣ�


