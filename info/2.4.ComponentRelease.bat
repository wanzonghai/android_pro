@echo off
set currentDir=%~dp0
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨生成正式服热更文件
echo 丨1.删除正式服 准备热更文件
echo 丨1.拷贝需热更文件
echo 丨2.生成MD5列表
echo 丨3.加密脚本和资源
echo 丨4.创建对应zip文件
echo 丨5.移动到正式服 待上传文件夹
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一

echo 1.删除正式服 准备热更文件
RD /S /Q D:\Hotfix\BrazilRelease\client\
RD /S /Q D:\Hotfix\BrazilRelease\game\
DEL /Q D:\Hotfix\BrazilRelease\client.zip

echo 2.拷贝需热更文件
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

echo 3.生成MD5列表
call make_md5_bx.bat

echo 4.加密脚本和资源
call new_encrypt_bx.bat

echo 5.创建对应zip文件
PUSHD ..\encryptBrazil
call WinRAR a -k -r -m1 client.zip client

cd game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (
   call WinRAR a -k -r -m1  %%i.zip %%i
)

echo 6.移动到预发布文件夹
cd ..\..
xcopy /y /e client D:\Hotfix\BrazilRelease\client\
xcopy /y /e game D:\Hotfix\BrazilRelease\game\
copy client.zip D:\Hotfix\BrazilRelease\client.zip

echo 7.可以打包了！！！！
pause
