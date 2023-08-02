@echo off
set currentDir=%~dp0
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一
echo 丨生成内网（192.168.1.230）热更文件
echo 丨1.删除内网测试热更文件
echo 丨2.拷贝需热更文件
echo 丨3.生成MD5列表
echo 丨4.加密脚本和资源
echo 丨5.创建对应zip文件
echo 丨6.移动到内网共享文件夹
echo  一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一一

echo 1.删除内网测试热更文件
RD /S /Q  Z:\Component\client\
RD /S /Q  Z:\Component\game\
DEL /Q  Z:\Component\client.zip

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

echo 6.移动到内网共享文件夹
cd ..\..
xcopy /y /e client Z:\Component\client\
xcopy /y /e game Z:\Component\game\
copy client.zip Z:\Component\client.zip

echo 7.可以出APK了！


