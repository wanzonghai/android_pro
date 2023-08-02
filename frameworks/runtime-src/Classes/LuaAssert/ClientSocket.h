#ifndef _CLIENT_SOCKET_H_
#define _CLIENT_SOCKET_H_

#include "cocos2d.h"
#include "CMD_Data.h"
//#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
//#include "MobileClientKernel.h"
//#else
//#include "../net/MobileClientKernel.h"
//#endif
#include "hxlibnetv3.h"

#include "LuaAssert.h"
#ifdef __cplusplus
extern "C" {
#endif

NS_CC_BEGIN;

class DLL_LOCAL CClientSocket :public cocos2d::Node
{
	//ISocketServer* pISocketServer;
	//IServerPool*   pIServerPool;
	IHxNetClientV3* m_pNetClient;
public:
	DLL_LOCAL CClientSocket(int nHandler);
	DLL_LOCAL virtual ~CClientSocket();

	DLL_LOCAL virtual bool ConnectServer();
	DLL_LOCAL virtual bool ConnectGameServer(uint16_t wKind, uint16_t wSort);
	

	DLL_LOCAL virtual bool SendSocketData(unsigned short wMain, unsigned short wSub, const void* pData = nullptr, unsigned short wDataSize = 0);
	DLL_LOCAL virtual void StopServer();
	DLL_LOCAL virtual bool IsServer();

	DLL_LOCAL virtual bool CloseGame(uint16_t wKind, uint16_t wSort);
	//DLL_LOCAL virtual void SetHeartBeatKeep(bool bKeep);
	//DLL_LOCAL virtual void SetDelayTime(long time);
	//DLL_LOCAL virtual void SetWaitTime(long time);

public:
	DLL_LOCAL int sendData(CCmd_Data* pData);
	//DLL_LOCAL bool AddServer(int nType, uint32_t, unsigned nPort = 0);
	//DLL_LOCAL void ClsServer(int nType);
};

NS_CC_END

USING_NS_CC;

static int toLua_Client_Socket_create(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S)-1;
    
	if(argc == 1)
	{

		int handler = toluafix_ref_function(tolua_S,2,0);
		CCLOG("toLua_Client_Socket_create:[%d",(int)handler);
		if(handler != 0)
		{

			CClientSocket* tolua_ret;
			CCLOG("toLua_Client_Socket_create2:[%d", (int)handler);
			try {
				tolua_ret = new CClientSocket(handler);
			}
			catch (...) {
				CCLOG("toLua_Client_Socket_create err. handler=[%d]", handler);
				return 0;
			}
			int nID = (tolua_ret) ? tolua_ret->_ID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->_luaID : NULL;

			tolua_ret->autorelease();
			tolua_ret->retain();
			

			CCLOG("lua 网络回调:[%d][%d]",nID,*pLuaID);
			toluafix_pushusertype_ccobject(tolua_S,nID,pLuaID,(void*)tolua_ret, "cc.CClientSocket");

			return 1;
		}
	}
	/*if (argc == 2)
	{
		int handler = toluafix_ref_function(tolua_S, 2, 0);
		CCLOG("toLua_Client_Socket_create:[%d", (int)handler);
		bool bMode = lua_toboolean(tolua_S, 3);
		if (handler != 0)
		{
			CClientSocket* tolua_ret = new CClientSocket(handler, bMode);
			tolua_ret->autorelease();
			tolua_ret->retain();

			int nID = (tolua_ret) ? tolua_ret->_ID : -1;
			int *pLuaID = (tolua_ret) ? &tolua_ret->_luaID : NULL;

			CCLOG("lua 网络回调:[%d][%d]", nID, *pLuaID);
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret, "cc.CClientSocket");

			return 1;
		}
	}*/

	return 0;
}

static int toLua_Client_Socket_sendData(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S,1,0);
		CC_BREAK_IF(cobj == NULL);
		CC_BREAK_IF(cobj->IsServer()==false);
		
		int argc = lua_gettop(tolua_S)-1;
		CC_BREAK_IF(argc != 1);
		
		CCmd_Data* pData= (CCmd_Data*)tolua_tousertype(tolua_S,2,0);
		CC_BREAK_IF(pData == NULL);
		
		result = cobj->sendData(pData);
	}while(false);
			
	lua_pushboolean(tolua_S, result);

	return result;
}


/*

static int toLua_Client_Socket_connect(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S,1,0);
		CC_BREAK_IF(cobj == NULL);
		CC_BREAK_IF(!cobj->IsServer());
		const char* szUrl = lua_tostring(tolua_S,2);
		WORD wPort = lua_tointeger(tolua_S,3);
		int argc = lua_gettop(tolua_S);
		if (argc == 4)
		{
			BYTE pValidate[128] = {};
			const char* szData = lua_tostring(tolua_S,4);
			WORD wSrcLen = strlen(szData); 
			char* szSrc = new char[wSrcLen+1];
			memset(szSrc,0,wSrcLen+1);
			memcpy(szSrc,szData,wSrcLen);
			ToServerString(szSrc,strlen(szData),(char*)pValidate,128);
			CCLOG("toLua_Client_Socket_connect:[%s][%d][%s]",szUrl,wPort,szData);
			lua_pushboolean(tolua_S, cobj->Connect(szUrl,wPort,pValidate)?1:0);
		}
		else
		{
			CCLOG("toLua_Client_Socket_connect:[%s][%d][null]",szUrl,wPort);
			lua_pushboolean(tolua_S, cobj->Connect(szUrl,wPort)?1:0);
		}


		result = 1;
	}while(false);
	
	return result;
}*/
//use new methond to connect
static int toLua_Client_Socket_connectNew(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(cobj == NULL);
		//CC_BREAK_IF(!cobj->IsServer());
		//ntype=1,hall  ,ntype=2,game
		//ESCKTYPE nType = (ESCKTYPE)lua_tointeger(tolua_S, 2);
		//WORD wPort = lua_tointeger(tolua_S, 3);

	    //CCLOG("toLua_Client_Socket_connectNew:[%d]", nType);
	    lua_pushboolean(tolua_S, cobj->ConnectServer() ? 1 : 0);

		result = 1;
	} while (false);

	return result;
}



static int toLua_Client_Socket_connectGame(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(cobj == NULL);
		int argc = lua_gettop(tolua_S);
		if (argc < 3) {
			lua_pushboolean(tolua_S, 0);
			break;
		}

		WORD wKind = lua_tointeger(tolua_S, 2);
		WORD wSort = lua_tointeger(tolua_S, 3);
		lua_pushboolean(tolua_S, cobj->ConnectGameServer(wKind, wSort) ? 1 : 0);
		result = 1;
	} while (false);

	return result;
}
static int toLua_Client_Socket_closeGame(lua_State* tolua_S) {
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(cobj == NULL);
		int argc = lua_gettop(tolua_S);
		if (argc < 3) {
			lua_pushboolean(tolua_S, 0);
			break;
		}

		WORD wKind = lua_tointeger(tolua_S, 2);
		WORD wSort = lua_tointeger(tolua_S, 3);
		lua_pushboolean(tolua_S, cobj->CloseGame(wKind, wSort) ? 1 : 0);
		result = 1;
	} while (false);

	return result;
}


static int toLua_Client_Socket_AddServer(lua_State* tolua_S)
{
	//int result = 0;
	//do
	//{
	//	CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
	//	CC_BREAK_IF(cobj == NULL);
	//	int nType = lua_tointeger(tolua_S, 2);
	//	//const char* szUrl = lua_tostring(tolua_S, 3);
	//	unsigned int uAddr = (unsigned int)lua_tointeger(tolua_S, 2);
	//	unsigned short nPort = (unsigned short)lua_tointeger(tolua_S, 4);
	//
	//
	//	lua_pushboolean(tolua_S, cobj->AddServer(nType, uAddr, nPort) ? 1 : 0);
	//} while (false);
	//
	//return result;
	CCLOG("AddServer NO USE!!");
	return 0;
}

static int toLua_Client_Socket_ClsServer(lua_State* tolua_S)
{
	//int result = 0;
	//do
	//{
	//	CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
	//	CC_BREAK_IF(cobj == NULL);
	//	int nType = lua_tointeger(tolua_S, 2);
	//
	//	cobj->ClsServer(nType);
	//} while (false);
	//
	//return result;
	CCLOG("ClsServer NO USE!!");
	return 0;
}


static int toLua_Client_Socket_relaseSocket(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(cobj == NULL);
		cobj->StopServer();
		cobj->release();
	}while(false);
	
	return result;
}

static int toLua_Client_Socket_close(lua_State* tolua_S)
{
	int result = 1;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(cobj == NULL);
		cobj->StopServer();
		result = true;
	} while (false);

	lua_pushboolean(tolua_S, result);

	return result;
}

static int toLua_Client_Socket_setheartbeatkeep(lua_State* tolua_S)
{
	//int result = 0;
	//do
	//{
	//	CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S,1,0);
	//	CC_BREAK_IF(cobj == NULL);
	//	bool bkeep = lua_toboolean(tolua_S,2);
	//	cobj->SetHeartBeatKeep(bkeep);
	//}while(false);
	//
	//return result;
	CCLOG("setheartbeatkeep NO USE!!");
	return 0;
}

static int toLua_Client_Socket_setdelaytime(lua_State* tolua_S)
{
	//int result = 0;
	//do
	//{
	//	CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S,1,0);
	//	CC_BREAK_IF(cobj == NULL);
	//	long lDelayTime = lua_tointeger(tolua_S,2);
	//	cobj->SetDelayTime(lDelayTime);
	//}while(false);
	//
	//return result;
	CCLOG("setdelaytime NO USE!!");
	return 0;
}

static int toLua_Client_Socket_setwaittime(lua_State* tolua_S)
{
	//int result = 0;
	//do
	//{
	//	CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S,1,0);
	//	CC_BREAK_IF(cobj == NULL);
	//	long lDelayTime = lua_tointeger(tolua_S,2);
	//	cobj->SetWaitTime(lDelayTime);
	//}while(false);
	//
	//return result;
	CCLOG("setwaittime NO USE!!");
	return 0;

}

static int toLua_Client_Socket_isReady(lua_State* tolua_S)
{
	int result = 0;
	do
	{
		CClientSocket* cobj = (CClientSocket*)tolua_tousertype(tolua_S, 1, 0);
		CC_BREAK_IF(!cobj->IsServer());
		result = 1;
	} while (false);
	lua_pushboolean(tolua_S, result);
	return result;

}


static int register_all_client_socket()
{
	auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* tolua_S = engine->getLuaStack()->getLuaState();

	tolua_usertype(tolua_S,"cc.CClientSocket");
	tolua_cclass(tolua_S,"CClientSocket","cc.CClientSocket","cc.Node",nullptr);
	tolua_beginmodule(tolua_S,"CClientSocket");
	tolua_function(tolua_S,"createSocket",toLua_Client_Socket_create);
	tolua_function(tolua_S,"sendData",toLua_Client_Socket_sendData);
	tolua_function(tolua_S,"relaseSocket",toLua_Client_Socket_relaseSocket);
	tolua_function(tolua_S,"closeSocket",toLua_Client_Socket_close);
	//tolua_function(tolua_S,"connectSocket",toLua_Client_Socket_connect);
	tolua_function(tolua_S,"connectSocketNew", toLua_Client_Socket_connectNew);
	tolua_function(tolua_S, "connectGame", toLua_Client_Socket_connectGame);
	tolua_function(tolua_S, "closeGame", toLua_Client_Socket_closeGame);

	tolua_function(tolua_S,"AddServer", toLua_Client_Socket_AddServer);
	tolua_function(tolua_S,"ClsServer", toLua_Client_Socket_ClsServer);
	tolua_function(tolua_S,"setheartbeatkeep",toLua_Client_Socket_setheartbeatkeep);
	tolua_function(tolua_S,"setdelaytime",toLua_Client_Socket_setdelaytime);
	tolua_function(tolua_S,"setwaittime",toLua_Client_Socket_setwaittime);
	tolua_function(tolua_S, "isReady", toLua_Client_Socket_isReady);
	tolua_endmodule(tolua_S);

	std::string typeName = typeid(cocos2d::CClientSocket).name();
    g_luaType[typeName] = "cc.CClientSocket";
    g_typeCast["CClientSocket"] = "cc.CClientSocket";
	return 1;
}

#ifdef __cplusplus
}
#endif

#endif
