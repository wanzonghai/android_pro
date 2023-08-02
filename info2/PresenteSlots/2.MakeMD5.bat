@echo off
echo 生成《base》的filemd5List.json
FilesMd5 %encryptDir%base %temp%\filemd5List_base.json 
copy %temp%\filemd5List_base.json %encryptDir%base\res\filemd5List.json
del %temp%\filemd5List_base.json
echo 生成《client》的filemd5List.json
FilesMd5 %encryptDir%client %temp%\filemd5List_client.json
copy %temp%\filemd5List_client.json %encryptDir%client\res\filemd5List.json
del %temp%\filemd5List_client.json
set /a game_count=0
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10 delims==," %%a in (GameList.txt) do (	
	echo 生成《%%b》的filemd5List.json
	FilesMd5 %encryptDir%game\yule\%%d %temp%\filemd5List%%d.json
	copy %temp%\filemd5List%%d.json %encryptDir%game\yule\%%d\res\filemd5List.json
	del %temp%\filemd5List%%d.json	
	set /a game_count+=1
	if  errorlevel 1 goto OnError
)
if  errorlevel 0 goto Finish
:OnError
echo 生成game的filemd5List.json 失败
pause

:Finish
echo 生成game的filemd5List.json 成功