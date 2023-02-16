#ifndef _LUA_CLIENT_KERNEL_H_
#define _LUA_CLIENT_KERNEL_H_

#include "Define.h"
#include "cocos2d.h"
//#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
//#include "MobileClientKernel.h"
//#include "Macordef.h"
//#else
//#include "net/MobileClientKernel.h"
//#include "net/Macordef.h"
//#endif
#include "hxlibnetv3.h"



USING_NS_CC;
class DLL_LOCAL CClientKernel: public cocos2d::Node,public IMessageRespon,public ILog
{
public:
	IHxNetKernel* m_pNetKernel;
public:
	//ππ‘Ï∫Ø ˝
	DLL_LOCAL CClientKernel();
public:
	//Œˆππ∫Ø ˝
	DLL_LOCAL virtual ~CClientKernel();
public:
	//≥ı ºªØ
	DLL_LOCAL bool OnInit();

public:
	DLL_LOCAL bool OnMessageHandler(int nHandler,WORD wMain, WORD wSub);

public:
	// Luaªÿµ˜
	DLL_LOCAL bool OnCallLuaSocketCallBack(int nHandler,Ref* data);

public:
	//¡¨Ω” ¬º˛
	DLL_LOCAL bool OnSocketConnectEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip);
	// ˝æ› ¬º˛
	DLL_LOCAL bool OnSocketDataEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip);
	//¥ÌŒÛ ¬º˛
	DLL_LOCAL bool OnSocketErrorEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip);
	//πÿ±’ ¬º˛
	DLL_LOCAL bool OnSocketCloseEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip);
	//重连
	DLL_LOCAL bool OnSocketReconnEvent(int nHandler, WORD wMain, WORD wSub, BYTE* pBuffer, WORD wSize, bool bZip);
public:
	//»´æ÷∏¸–¬
	DLL_LOCAL void GlobalUpdate(float dt);

public:
	DLL_LOCAL virtual void OnMessageRespon(int nLuaFunID, TNetPacket* message);

	DLL_LOCAL virtual void LogOut(const char *message);

};



#endif