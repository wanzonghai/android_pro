@echo off
set currentDir=%~dp0
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ
echo ح������ʽ���ȸ��ļ�
echo ح1.ɾ����ʽ�� ׼���ȸ��ļ�
echo ح1.�������ȸ��ļ�
echo ح2.����MD5�б�
echo ح3.���ܽű�����Դ
echo ح4.������Ӧzip�ļ�
echo ح5.�ƶ�����ʽ�� ���ϴ��ļ���
echo  һһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһһ

echo 1.ɾ����ʽ�� ׼���ȸ��ļ�
RD /S /Q D:\Hotfix\BrazilRelease\client\
RD /S /Q D:\Hotfix\BrazilRelease\game\
DEL /Q D:\Hotfix\BrazilRelease\client.zip

echo 2.�������ȸ��ļ�
cd %currentDir%
if exist "..\encryptBrazil" (
    RD /S /Q ..\encryptBrazil
)
mkdir ..\encryptBrazil
md ..\encryptBrazil\game
md ..\encryptBrazil\client
md ..\encryptBrazil\base
xcopy /y /e ..\clientBrazil\client ..\encryptBrazil\client\
xcopy /y /e ..\clientBrazil\base ..\encryptBrazil\base\
xcopy /y /e ..\clientBrazil\game ..\encryptBrazil\game\

echo 3.����MD5�б�
call make_md5_bx.bat

echo 4.���ܽű�����Դ
call new_encrypt_bx.bat

echo 5.������Ӧzip�ļ�
PUSHD ..\encryptBrazil
call WinRAR a -k -r -m1 client.zip client

cd game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (
   call WinRAR a -k -r -m1  %%i.zip %%i
)

echo 6.�ƶ���Ԥ�����ļ���
cd ..\..
xcopy /y /e client D:\Hotfix\BrazilRelease\client\
xcopy /y /e game D:\Hotfix\BrazilRelease\game\
copy client.zip D:\Hotfix\BrazilRelease\client.zip

echo 7.���Դ���ˣ�������
pause
