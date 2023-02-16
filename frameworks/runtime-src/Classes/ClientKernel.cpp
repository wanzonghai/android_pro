#include "ClientKernel.h"
#include "CCLuaEngine.h"
#include "CMD_Data.h"


CClientKernel::CClientKernel()
{
	m_pNetKernel = NULL;
	CreateNetKernel(&m_pNetKernel);
}

CClientKernel::~CClientKernel()
{
	//CC_SAFE_DELETE(m_pCipher);
	DeleteNetKernel(&m_pNetKernel);
}

bool CClientKernel::OnInit()
{
	//m_pCipher = new CCipher();
	m_pNetKernel->SetLogOut(this);

	return true;
}
void CClientKernel::LogOut(const char *message)
{
	CCLOG("[Kernel LogOut]: %s",message);
}
//֪ͨ
bool CClientKernel::OnMessageHandler(int nHandler,WORD wMain,WORD wSub)
{
	bool result = false;
	do
	{
		if(nHandler != 0)
		{
			lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
			toluafix_get_function_by_refid(tolua_S, nHandler);
			if (lua_isfunction(tolua_S, -1))
			{
				lua_pushinteger(tolua_S, wMain);
				lua_pushinteger(tolua_S, wSub);
				int result = LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(nHandler, 2)!=0;
			}else{
				CCLOG("OnUnZipEvent-luacallback-handler-false:%d",nHandler);
			}
		}
	}while(false);
	return result == 0;
}

bool CClientKernel::OnSocketConnectEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize ,bool bZip)
{
	bool result = false;
	do{	
		CCmd_Data* pData = CCmd_Data::createWithBuffer(pBuffer, wSize, bZip);
		pData->SetCommand(wMain, wSub);

		result = OnCallLuaSocketCallBack(nHandler,pData);
	}while(false);
	return result;
}

bool CClientKernel::OnSocketDataEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip)
{
	bool result = false;
	do
	{
		CCmd_Data* pData = CCmd_Data::createWithBuffer(pBuffer, wSize, bZip);
		pData->SetCommand(wMain,wSub);
		result = OnCallLuaSocketCallBack(nHandler,pData);
	}while(false);
	return result;
}

bool CClientKernel::OnSocketErrorEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip)
{
	bool result = false;
	do
	{
		CCmd_Data* pData = CCmd_Data::createWithBuffer(pBuffer, wSize, bZip);
		pData->SetCommand(wMain, wSub);
		result = OnCallLuaSocketCallBack(nHandler,pData);

	}while(false);
	return result;
}

bool CClientKernel::OnSocketCloseEvent(int nHandler,WORD wMain,WORD wSub,BYTE* pBuffer,WORD wSize, bool bZip)
{
	bool result = false;
	do
	{
		CCmd_Data* pData = CCmd_Data::createWithBuffer(pBuffer, wSize, bZip);
		pData->SetCommand(wMain, wSub);
		result = OnCallLuaSocketCallBack(nHandler,pData);
	}while(false);
	return result;
}
bool CClientKernel::OnSocketReconnEvent(int nHandler, WORD wMain, WORD wSub, BYTE* pBuffer, WORD wSize, bool bZip)
{
	bool result = false;
	do
	{
		CCmd_Data* pData = CCmd_Data::createWithBuffer(pBuffer, wSize, bZip);
		pData->SetCommand(wMain, wSub);
		//pData->PushByteDataNHJ(pBuffer, 4);
		pData->ResetCurrentIndexgr();
		result = OnCallLuaSocketCallBack(nHandler, pData);
	} while (false);
	return result;
}
bool CClientKernel::OnCallLuaSocketCallBack(int nHandler,Ref* pData)
{

	bool result = false;
	do
	{
		CCmd_Data* pCmdData = (CCmd_Data*)pData;

		if(nHandler != 0 && pCmdData != NULL)
		{
			lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
			toluafix_get_function_by_refid(tolua_S, nHandler);
			if (lua_isfunction(tolua_S, -1))
			{
				//����
				int nID = (pData) ? pCmdData->_ID : -1;
				int *pLuaID = (pData) ? &pCmdData->_luaID : NULL;
				toluafix_pushusertype_ccobject(tolua_S,nID,pLuaID,(void*)pData, "cc.CCmd_Data");

				LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(nHandler, 1);
			}else{
				CCLOG("OnCallLuaSocketCallBack-false:%d",nHandler);
			}
		}
	}while(false);
	return result == 0;
}


void CClientKernel::GlobalUpdate(float dt)
{
	Global_LoopProcessSyncData(this, 100);
	//GetMCKernel()->OnMainLoop(this, 100);
}


void CClientKernel::OnMessageRespon(int nLuaFunID, TNetPacket* message)
{
	
	if(message)
	{
		switch (message->Type)
		{
		case MSG_SOCKET_CONNECT:
			 OnSocketConnectEvent(nLuaFunID,message->MCmd,message->SCmd,message->Data,message->Length, message->ZipData);
			 break;
		case MSG_SOCKET_DATA:
			 OnSocketDataEvent(nLuaFunID,message->MCmd,message->SCmd,message->Data,message->Length, message->ZipData);
			  break;
		case MSG_SOCKET_ERROR:
			 OnSocketErrorEvent(nLuaFunID,message->MCmd,message->SCmd,message->Data,message->Length, message->ZipData);
			  break;
		case MSG_SOCKET_CLOSED:
			 OnSocketCloseEvent(nLuaFunID,message->MCmd,message->SCmd,message->Data,message->Length, message->ZipData);
			  break;
		case MSG_SOCKET_RECONNT:
			OnSocketReconnEvent(nLuaFunID, message->MCmd, message->SCmd, message->Data, message->Length, message->ZipData);
			break;
		case MSG_HTTP_DOWN:
			 OnMessageHandler(nLuaFunID,message->MCmd,message->SCmd);
			  break;
		case MSG_UN_ZIP:
			 OnMessageHandler(nLuaFunID,message->MCmd,message->SCmd);
			 break;
		default:
			CCLOG("[_DEBUG]	unkown_message:[type:%d][main:%d][sub:%d][size:%d]",message->Type,message->MCmd,message->SCmd,message->Length);
			break;
		}
	}

}