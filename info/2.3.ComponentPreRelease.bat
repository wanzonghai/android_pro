@echo off
set currentDir=%~dp0
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح����ƽ�з��ȸ��ļ�
echo ح1.ɾ��ƽ�з����ϴ��ļ���
echo ح1.�������ȸ��ļ�
echo ح2.����MD5�б�
echo ح3.���ܽű�����Դ
echo ح4.������Ӧzip�ļ�
echo ح5.�ƶ���ƽ�з����ϴ��ļ���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ

echo 1.ɾ��ƽ�з� ׼���ȸ��ļ�
RD /S /Q D:\Hotfix\ComponentPreRelease\client\
RD /S /Q D:\Hotfix\ComponentPreRelease\game\
DEL /Q D:\Hotfix\ComponentPreRelease\client.zip

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

echo 6.�ƶ���ƽ�з�Ԥ�����ļ���
cd ..\..
xcopy /y /e client D:\Hotfix\ComponentPreRelease\client\
xcopy /y /e game D:\Hotfix\ComponentPreRelease\game\
copy client.zip D:\Hotfix\ComponentPreRelease\client.zip

echo 7.ƽ�з����Դ���ˣ�������
