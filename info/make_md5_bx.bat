@echo off
REM http://www.jb51.net/article/17927.htm

rem base
FilesMd5 ..\encryptComponent\base %temp%\filemd5List_base.json 
copy %temp%\filemd5List_base.json ..\encryptComponent\base\res\filemd5List.json
del %temp%\filemd5List_base.json

rem client
FilesMd5 ..\encryptComponent\client %temp%\filemd5List_client.json
copy %temp%\filemd5List_client.json ..\encryptComponent\client\res\filemd5List.json
del %temp%\filemd5List_client.json

set /a game_count=0
rem game list
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10 delims==," %%a in (game_list_bx.txt) do (
	echo game name %%b
	@REM del %%d\filemd5List%%d.json
	FilesMd5 ..\%%d %temp%\filemd5List%%h.json
	copy %temp%\filemd5List%%h.json ..\%%d\res\filemd5List.json
del %temp%\filemd5List%%h.json
	
	set /a game_count+=1
	if  errorlevel 1 goto OnError
)
if  errorlevel 0 goto Finish
:OnError
echo make md5 error
pause

:Finish
echo make md5 finish