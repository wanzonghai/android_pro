@echo off
set currentDir=%~dp0
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨生成本地热更文件
echo 丨1.删除本地文件夹热更文件
echo 丨2.拷贝需热更文件
echo 丨3.生成MD5列表
echo 丨4.加密脚本和资源
echo 丨5.创建对应zip文件
echo 丨6.移动到本地共享文件夹
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一

echo 1.删除本地文件夹热更文件
RD /S /Q D:\Hotfix\ComponentLocal\client\
RD /S /Q D:\Hotfix\ComponentLocal\game\
DEL /Q D:\Hotfix\ComponentLocal\client.zip

echo 2.拷贝需热更文件
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

echo 3.生成MD5列表
call make_md5_bx.bat

echo 4.加密脚本和资源
call new_encrypt_bx.bat

echo 5.创建对应zip文件
PUSHD ..\encryptComponent
call WinRAR a -k -r -m1 client.zip client

cd game\yule
for /f "delims=" %%i in ('dir /b /ad "%cd%"') do (
   call WinRAR a -k -r -m1  %%i.zip %%i
)

echo 6.移动到本地文件夹
cd ..\..
xcopy /y /e client D:\Hotfix\ComponentLocal\client\
xcopy /y /e game D:\Hotfix\ComponentLocal\game\
copy client.zip D:\Hotfix\ComponentLocal\client.zip

echo 7.可以打包本地APK了！！！
pause


