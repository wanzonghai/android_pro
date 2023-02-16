#ifndef _CMD_DATA_H_
#define _CMD_DATA_H_
#include "Define.h"
#include "cocos2d.h"
#include "tolua_fix.h"
#include "CCLuaEngine.h"
#include "LuaAssert.h"
#include "LuaBasicConversions.h"
#include "Integer64.h"



#ifndef _WIN32
typedef int16_t uchar_t;
#else
typedef wchar_t uchar_t;
#endif//_WIN32

NS_CC_BEGIN
#ifdef __cplusplus
extern "C" {
#endif

#define AUTO_LEN		512

	

//网络数据处理
class CCmd_Data :public cocos2d::Ref
{
protected:
	BYTE*		m_pBuffer;			//数据缓存
public:
	const		bool m_bZip;				//压缩
protected:
	WORD		m_wMain;			//主命令
	WORD		m_wSub;				//子命令
	
	WORD		m_wMaxLenght;		//数据长度
	WORD		m_wCurIndex;		//操作游标
	bool        m_bAutoLen;
	int32_t		m_nFeldIndex;
protected:
	//构造函数
	CCmd_Data(WORD nLenght, bool bZip);
	CCmd_Data(uint8_t* pBuf, WORD nLenght, bool bZip);
public:
	//析构函数
	virtual ~CCmd_Data();
	const BYTE* GetBuffer() { return m_pBuffer; }

	const BYTE* GetBufferLave() { return m_pBuffer + m_wCurIndex; }
public:
	//创建对象
	static CCmd_Data * create(int nLenght,bool bZip = false);
	static CCmd_Data* createWithBuffer(uint8_t* pBuf, int nLenght, bool bZip = false);
public:
	//设置命令
	VOID	SetCommand(WORD wMain, WORD wSub);


	int32_t	ReadSInt08(char* pVall, int32_t nMaxCount = -1);
	int32_t	ReadUInt08(uint8_t* pVall, int32_t nMaxCount = -1);

	int32_t	ReadSInt16(int16_t* pVall, int32_t nMaxCount = -1);
	int32_t	ReadUInt16(uint16_t* pVall, int32_t nMaxCount = -1);

	int32_t	ReadSInt32(int32_t* pVal, int32_t nMaxCount = -1);
	int32_t	ReadUInt32(uint32_t* pVal, int32_t nMaxCount = -1);

	int32_t	ReadSInt64(int64_t* pVal, int32_t nMaxCount = -1);
	int32_t	ReadUInt64(uint64_t* pVal, int32_t nMaxCount = -1);

	int32_t	ReadFlat32(float* pVal, int32_t nMaxCount = -1);
	int32_t	ReadFlat64(double* pVal, int32_t nMaxCount = -1);
	int32_t	ReadString(char* pVal, int32_t nMaxCount = -1);
	int32_t	ReadUTF8(char* pVal, int32_t nMaxCount = -1);


	int32_t	WriteSInt08(const char* pVal, int32_t nMaxCount = -1);
	int32_t	WriteUInt08(const uint8_t* pVal, int32_t nMaxCount = -1);

	int32_t	WriteSInt16(const int16_t* pVal, int32_t nMaxCount = -1);
	int32_t	WriteUInt16(const uint16_t* pVal, int32_t nMaxCount = -1);

	int32_t	WriteSInt32(const int32_t* pVal, int32_t nMaxCount = -1);
	int32_t	WriteUInt32(const uint32_t* pVal, int32_t nMaxCount = -1);

	int32_t	WriteSInt64(const int64_t* pVal, int32_t nMaxCount = -1);
	int32_t	WriteUInt64(const uint64_t* pVal, int32_t nMaxCount = -1);

	int32_t	WriteFlat32(const float* pVal, int32_t nMaxCount = -1);
	int32_t	WriteFlat64(const double* pVal, int32_t nMaxCount = -1);
	int32_t	WriteString(const char* pVal, int32_t nMaxCount = -1);
	int32_t	WriteUTF8(const char* pVal, int32_t nMaxCount = -1);

	/*//填充数据
	WORD	PushByteDataNHJ(BYTE* cbData,WORD wLenght);

	
	
	//设置游标
	VOID	SetCurrentIndex(WORD wIndex){if(wIndex<=m_wMaxLenght)m_wCurIndex = wIndex;}
	*/
	//当前位置
	WORD	GetCurrentIndex() { return m_wCurIndex; }
	//数据长度
	WORD	GetBufferLenghtqw() { return m_bAutoLen ? m_wCurIndex : m_wMaxLenght; }
	//获取主命令
	WORD	GetMainCmd() { return m_wMain; }
	//获取子命令
	WORD	GetSubCmd() { return m_wSub; }
	//重置游标
	VOID	ResetCurrentIndexgr(){m_wCurIndex = 0 ;}
};
NS_CC_END

USING_NS_CC;

//创建对象
static int toLua_Cmd_Data_createOne(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	CCmd_Data* tolua_ret = nullptr;
	if(argc == 2)
	{
		int nLenght = lua_tointeger(tolua_S,2);
		tolua_ret = (CCmd_Data*)CCmd_Data::create(nLenght);
	} 
	else if (argc == 3)
	{
		int nLenght = lua_tointeger(tolua_S, 2);
		bool bZip = lua_tointeger(tolua_S, 3)?true:false;
		tolua_ret = (CCmd_Data*)CCmd_Data::create(nLenght, bZip);
	}
	else{
		tolua_ret = (CCmd_Data*)CCmd_Data::create(0);
		CCLOG("WARN this is cmd_data is auto! init auto is %d",AUTO_LEN);
	}
	int nID = (tolua_ret) ? tolua_ret->_ID : -1;
	int *pLuaID = (tolua_ret) ? &tolua_ret->_luaID : NULL;

	toluafix_pushusertype_ccobject(tolua_S,nID,pLuaID,(void*)tolua_ret, "cc.CCmd_Data");
	return 1;
}
//设置命令
static int toLua_Cmd_Data_setCmdInfoTwo(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 3)
		{
			WORD wMain = (WORD)lua_tointeger(tolua_S,2);
			WORD wSub = (WORD)lua_tointeger(tolua_S,3);
			cobj->SetCommand(wMain,wSub);
			//CCLOG("toLua_Cmd_Data_setCmdInfoTwo main:%d sub:%d curLen:%d",wMain,wSub,cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充bool
static int toLua_Cmd_Data_pushBOOLBG(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			BYTE cbValue = ((lua_toboolean(tolua_S,2)== 0)?FALSE:TRUE);
			cobj->WriteUInt08(&cbValue ,-1);
			//CCLOG("toLua_Cmd_Data_pushBOOLBG curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充BYTE
static int toLua_Cmd_Data_pushBYTE(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			BYTE cbValue = (BYTE)lua_tointeger(tolua_S,2);
			cobj->WriteUInt08(&cbValue, -1);
			//CCLOG("toLua_Cmd_Data_pushBYTE curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}

//填充SHORT
static int toLua_Cmd_Data_pushSHORT(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S, 1, nullptr);
	if (cobj)
	{
		int argc = lua_gettop(tolua_S);
		if (argc == 2)
		{
			SHORT wValue = (SHORT)lua_tointeger(tolua_S, 2);
			cobj->WriteSInt16(&wValue, -1);
		}
	}
	return 0;
}
//填充WORD
static int toLua_Cmd_Data_pushWORD(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			WORD wValue =  (WORD)lua_tointeger(tolua_S,2);
			cobj->WriteUInt16(&wValue, -1);
			//CCLOG("toLua_Cmd_Data_pushWORD curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}



//填充int
static int toLua_Cmd_Data_pushINT(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			int dwValue =  lua_tointeger(tolua_S,2);
			cobj->WriteSInt32(&dwValue, -1);
			//CCLOG("toLua_Cmd_Data_pushINT curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充DWORD
static int toLua_Cmd_Data_pushDWORD(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			uint32_t dwValue = (uint32_t)lua_tonumber(tolua_S,2);
			cobj->WriteUInt32(&dwValue, -1);
			//CCLOG("toLua_Cmd_Data_pushDWORD curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充Float
static int toLua_Cmd_Data_pushFLOATRG(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			
			float fValue =  (float)lua_tonumber(tolua_S,2);
			cobj->WriteFlat32(&fValue, -1);
			//CCLOG("toLua_Cmd_Data_pushFLOATRG curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充DOUBLE
static int toLua_Cmd_Data_pushDOUBLE(lua_State* tolua_S)
{

	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			DOUBLE dValue =  (DOUBLE)lua_tonumber(tolua_S,2);
			cobj->WriteFlat64(&dValue, -1);
			//CCLOG("toLua_Cmd_Data_pushDOUBLE curLen:%d",cobj->GetCurrentIndex());
			return 1;
		}
	}
	return 0;
}
//填充I64
static int toLua_Cmd_Data_pushSCORE(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 2)
		{
			Integer64* data64 = (Integer64*)tolua_tousertype(tolua_S,2,nullptr);
			if(data64)
			{
				int64_t data = data64->m_val;
				cobj->WriteSInt64(&data, -1);
			}
			else
			{
				int64_t data =  (int64_t)lua_tonumber(tolua_S,2);
				cobj->WriteSInt64(&data, -1);
			}
			//CCLOG("toLua_Cmd_Data_pushSCORE curLen:%d",cobj->GetCurrentIndex());
		}
	}
	return 0;
}
//填充文本
static int toLua_Cmd_Data_pushSTRING(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if (argc == 2)
		{
			const char* szData = lua_tostring(tolua_S, 2);
			if (szData) {
				int32_t len = strlen(szData);
				cobj->WriteString(szData, len + 1);
			}
			else {
				cobj->WriteString(szData, 0);
			}
		} 
		else if(argc == 3)
		{
			const char* szData = lua_tostring(tolua_S,2);
			WORD wDstLen = lua_tointeger(tolua_S,3);
			cobj->WriteString(szData, wDstLen);
		}
	}
	return 0;
}
static int toLua_Cmd_Data_pushUTF8(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S, 1, nullptr);
	if (cobj)
	{
		int argc = lua_gettop(tolua_S);
		if (argc == 2)
		{
			const char* szData = lua_tostring(tolua_S, 2);
			if (szData) {
				int32_t len = strlen(szData);
				cobj->WriteUTF8(szData, len+1);
			}
			else {
				cobj->WriteUTF8(szData, 0);
			}
		}
		if (argc == 3)
		{
			const char* szData = lua_tostring(tolua_S, 2);
			WORD wDstLen = lua_tointeger(tolua_S, 3);
			cobj->WriteUTF8(szData, wDstLen);
		}
	}
	return 0;
}
//读取bool
static int toLua_Cmd_Data_readBOOL(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readBOOL");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		BYTE val;
		cobj->ReadUInt08(&val);
		lua_pushboolean(tolua_S, val ? 1 : 0);
		return 1;
		//WORD wCurIndex = cobj->GetCurrentIndex();
		//if( wCurIndex < cobj->GetBufferLenghtqw())
		//{
		//	lua_pushboolean(tolua_S, cobj->m_pBuffer[wCurIndex]==0?0:1);
		//	cobj->SetCurrentIndex(wCurIndex+1);
		//	return 1;
		//}
	}
	return 0;
}
//读取byte
static int toLua_Cmd_Data_readBYTE(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readBYTE");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		BYTE val = 0;
		if (cobj->ReadUInt08(&val) > 0) {
			lua_pushinteger(tolua_S, val & 0x000000FF);
			return 1;
		}
		//WORD wCurIndex = cobj->GetCurrentIndex();
		//if( wCurIndex < cobj->GetBufferLenghtqw())
		//{
		//	lua_pushinteger(tolua_S, (0x000000FF&cobj->m_pBuffer[wCurIndex]));
		//	cobj->SetCurrentIndex(wCurIndex+1);
		//	return 1;
		//}

	}
	return 0;
}
//读取word
static int toLua_Cmd_Data_readWORD(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readWORD");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		uint16_t val;
		if (cobj->ReadUInt16(&val) > 0) {
			lua_pushinteger(tolua_S, val);
			return 1;
		}
		//WORD wCurIndex = cobj->GetCurrentIndex();
		//if( wCurIndex+2 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE tmp[2] = {0};
		//    memcpy(tmp, (void*)(cobj->m_pBuffer+wCurIndex), 2);
		//	lua_pushinteger(tolua_S, *(WORD*)(tmp));
		//	cobj->SetCurrentIndex(wCurIndex+2);
		//	return 1;
		//}
	}
	return 0;
}

//读取short
static int toLua_Cmd_Data_readSHORT(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int16_t val = 0;
		if (cobj->ReadSInt16(&val) > 0) {
			lua_pushinteger(tolua_S, val);
			return 1;
		}
		//SHORT wCurIndex = cobj->GetCurrentIndex();
		//if( wCurIndex+2 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE tmp[2] = {0};
        //    memcpy(tmp, (void*)(cobj->m_pBuffer+wCurIndex), 2);
		//	lua_pushinteger(tolua_S, *(SHORT*)(tmp));
		//	cobj->SetCurrentIndex(wCurIndex+2);
		//	return 1;
		//}
	}
	return 0;
}

//读取int
static int toLua_Cmd_Data_readINT(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readINT");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int32_t val;
		if (cobj->ReadSInt32(&val) > 0) {
			lua_pushnumber(tolua_S, val);
			return 1;
		}

		//WORD wIndex = cobj->GetCurrentIndex();
		//if(wIndex + 4 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE tmp[4] = {0};
		//    memcpy(tmp, (void*)(cobj->m_pBuffer+wIndex), 4);
		//	lua_pushinteger(tolua_S, *(int*)(tmp));
		//	cobj->SetCurrentIndex(wIndex+4);
		//	return 1;
		//}
	}
	return 0;
}
//读取DWORD
static int toLua_Cmd_Data_readDWORD12W(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readDWORD12W");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		uint32_t val = 0;
		if (cobj->ReadUInt32(&val) > 0) {
			lua_pushnumber(tolua_S, val);
			return 1;
		}

		//WORD wIndex = cobj->GetCurrentIndex();
		//if(wIndex + 4 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE tmp[4] = {0};
        //    memcpy(tmp, (void*)(cobj->m_pBuffer+wIndex), 4);
        //    lua_pushnumber(tolua_S,*(DWORD*)(tmp));
		//	cobj->SetCurrentIndex(wIndex+4);
		//	return 1;
		//}
	}
	return 0;
}
//读取float
static int toLua_Cmd_Data_readFLOAT(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readFLOAT");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		float val = 0.0f;
		if (cobj->ReadFlat32(&val) > 0) {
			lua_pushnumber(tolua_S, val);
			return 1;
		}

		//WORD wIndex = cobj->GetCurrentIndex();
		//if(wIndex + 4 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE tmp[4] = {0};
		//    memcpy(tmp, (void*)(cobj->m_pBuffer+wIndex), 4);
		//	lua_pushnumber(tolua_S, *(float*)(tmp));
		//	cobj->SetCurrentIndex(wIndex+4);
		//	return 1;
		//}
	}
	return 0;
}
//读取double
static int toLua_Cmd_Data_readDOUBLEHT(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readDOUBLEHT");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		double val = 0.0;
		if (cobj->ReadFlat64(&val) > 0) {
			lua_pushnumber(tolua_S, val);
			return 1;
		}

		//WORD wIndex = cobj->GetCurrentIndex();
		//
		//if(wIndex + 8 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE cbBuffer[8] = {0};
		//	memcpy(cbBuffer,cobj->m_pBuffer+wIndex,8);
		//	double dData = *((double*)cbBuffer);
		//	lua_pushnumber(tolua_S, dData);
		//	cobj->SetCurrentIndex(wIndex+8);
		//	return 1;
		//}

	}
	return 0;
}
//读取score
static int toLua_Cmd_Data_readSCORE(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readSCORE");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	Integer64* data64	= (Integer64*)tolua_tousertype(tolua_S,2,nullptr);
	do
	{
		if(cobj == NULL)
		{
			CCLOG("toLua_Cmd_Data_readSCORE error cobj is null");
			break;
		}
		if(data64 == NULL)
		{
			CCLOG("toLua_Cmd_Data_readSCORE error data64 is null");
			break;
		}
		if (cobj->ReadSInt64(&data64->m_val) > 0) {
			return 1;
		}
		//WORD wIndex = cobj->GetCurrentIndex();
		//
		//if(wIndex + 8 <= cobj->GetBufferLenghtqw())
		//{
		//	BYTE cbData[8] = {0};
		//	memcpy(cbData,cobj->m_pBuffer+wIndex,8);
		//	data64->m_val = *((int64_t*)cbData);
		//	cobj->SetCurrentIndex(wIndex+8);
		//	return 1;
		//}
		CCLOG("toLua_Cmd_Data_readSCORE error wIndex is longer");
	}while(false);

	return 0;
}
//读取string
static int toLua_Cmd_Data_readSTRING(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readSTRING");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		int argc = lua_gettop(tolua_S);
		if(argc == 1)
		{
			char* pszDstData = new char[4096];
			memset(pszDstData,0, 4096);
			int rv = cobj->ReadString(pszDstData, 0);
			lua_pushstring(tolua_S, pszDstData);
			CC_SAFE_DELETE(pszDstData);
			if (rv > 0) return 1;
		}
		if(argc == 2)
		{
			
			//WORD wIndex =  cobj->GetCurrentIndex();
			int32_t wMaxLen = (int32_t)lua_tointeger(tolua_S, 2);
			char* pszDstData = NULL;
			if (wMaxLen <= 0) {
				wMaxLen = 0;
				pszDstData = new char[4096];
				memset(pszDstData, 0, 4096);
			}
			else {
				pszDstData = new char[wMaxLen];
				memset(pszDstData, 0, wMaxLen);
			}
			int rv = cobj->ReadString(pszDstData, wMaxLen);
			lua_pushstring(tolua_S, pszDstData);
			CC_SAFE_DELETE(pszDstData);
			if (rv > 0) return 1;
			//if(wMaxLen>0 && wIndex + wMaxLen*2 <= cobj->GetBufferLenghtqw())
			//{
			//	char*	pszDstData = new char[1024];
			//	TCHAR*	pszSrcData = new TCHAR[wMaxLen+1];
			//	
			//	memset(pszDstData,0,1024);
			//	memset(pszSrcData,0,wMaxLen*2+2);
			//
			//	memcpy(pszSrcData,cobj->m_pBuffer+wIndex,wMaxLen*2);
			//
			//	ToClientString((char*)pszSrcData,wMaxLen*2,pszDstData,1024);
			//	lua_pushstring(tolua_S,pszDstData);
			//	CC_SAFE_DELETE(pszDstData);
			//	CC_SAFE_DELETE(pszSrcData);
			//	cobj->SetCurrentIndex(wIndex+wMaxLen*2);
			//	return 1;
			//}else{
			//	CCLOG("readstring error readlen:%d curLen:%d maxlen:%d",wMaxLen,wIndex,cobj->GetBufferLenghtqw());
			//}
		}

	}
	return 0;
}


static int toLua_Cmd_Data_readUTF8(lua_State* tolua_S)
{
	//CCLOG("toLua_Cmd_Data_readSTRING");
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S, 1, nullptr);
	if (cobj)
	{
		int argc = lua_gettop(tolua_S);
		if (argc == 1)
		{
			char* pszDstData = new char[4096];
			memset(pszDstData,0, 4096);
			int rv = cobj->ReadUTF8(pszDstData, 0);
			lua_pushstring(tolua_S, pszDstData);
			CC_SAFE_DELETE(pszDstData);
			if (rv > 0) return 1;

			//WORD wIndex =  cobj->GetCurrentIndex();
			//
			//if(wIndex<cobj->GetBufferLenghtqw())
			//{
			//	WORD wMaxLen = cobj->GetBufferLenghtqw() - wIndex;
			//	char*	pszDstData = new char[1024];
			//	TCHAR*	pszSrcData = new TCHAR[wMaxLen+1];
			//	
			//	memset(pszDstData,0,1024);
			//	memset(pszSrcData,0,wMaxLen*2+2);
			//
			//	memcpy(pszSrcData,cobj->m_pBuffer+wIndex,wMaxLen*2);
			//
			//	ToClientString((char*)pszSrcData,wMaxLen*2,pszDstData,1024);
			//	lua_pushstring(tolua_S,pszDstData);
			//	CC_SAFE_DELETE(pszDstData);
			//	CC_SAFE_DELETE(pszSrcData);
			//	cobj->SetCurrentIndex(wIndex+wMaxLen*2);
			//	return 1;
			//}else{
			//	CCLOG("readstring error curLen:%d maxlen:%d",wIndex,cobj->GetBufferLenghtqw());
			//}
		}
		if (argc == 2)
		{
			//WORD wIndex =  cobj->GetCurrentIndex();
			int32_t wMaxLen = (int32_t)lua_tointeger(tolua_S, 2);
			char* pszDstData = NULL;
			if (wMaxLen <= 0) {
				wMaxLen = 0;
				pszDstData = new char[4096];
				memset(pszDstData, 0, 4096);
			}
			else {
				pszDstData = new char[wMaxLen];
				memset(pszDstData, 0, wMaxLen);
			}
			int rv = cobj->ReadUTF8(pszDstData, wMaxLen);
			lua_pushstring(tolua_S, pszDstData);
			CC_SAFE_DELETE(pszDstData);
			if (rv > 0) return 1;
			//if(wMaxLen>0 && wIndex + wMaxLen*2 <= cobj->GetBufferLenghtqw())
			//{
			//	char*	pszDstData = new char[1024];
			//	TCHAR*	pszSrcData = new TCHAR[wMaxLen+1];
			//	
			//	memset(pszDstData,0,1024);
			//	memset(pszSrcData,0,wMaxLen*2+2);
			//
			//	memcpy(pszSrcData,cobj->m_pBuffer+wIndex,wMaxLen*2);
			//
			//	ToClientString((char*)pszSrcData,wMaxLen*2,pszDstData,1024);
			//	lua_pushstring(tolua_S,pszDstData);
			//	CC_SAFE_DELETE(pszDstData);
			//	CC_SAFE_DELETE(pszSrcData);
			//	cobj->SetCurrentIndex(wIndex+wMaxLen*2);
			//	return 1;
			//}else{
			//	CCLOG("readstring error readlen:%d curLen:%d maxlen:%d",wMaxLen,wIndex,cobj->GetBufferLenghtqw());
			//}
		}

	}
	return 0;
}
//获取主命令
static int toLua_Cmd_Data_getMainHH(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		lua_pushinteger(tolua_S,cobj->GetMainCmd());
		return 1;
	}
	return 0;
}
//获取子命令
static int toLua_Cmd_Data_getSubMN(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		lua_pushinteger(tolua_S,cobj->GetSubCmd());
		return 1;
	}
	return 0;
}
//获取长度
static int toLua_Cmd_Data_lenTO(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		lua_pushinteger(tolua_S,cobj->GetBufferLenghtqw());
		return 1;
	}
	return 0;
}
//获取长度
static int toLua_Cmd_Data_curlenQW(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		lua_pushinteger(tolua_S,cobj->GetCurrentIndex());
		return 1;
	}
	return 0;	
}
/*
//设置游标
static int toLua_Cmd_Data_setCurrentIndex(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S, 1, nullptr);
	if (cobj)
	{
		int argc = lua_gettop(tolua_S);
		if (argc == 2)
		{
			WORD dwValue = (WORD)lua_tonumber(tolua_S, 2);
			cobj->SetCurrentIndex(dwValue);
		}
	}
	return 0;
}*/
//重置游标
static int toLua_Cmd_Data_resetRead(lua_State* tolua_S)
{
	CCmd_Data* cobj = (CCmd_Data*)tolua_tousertype(tolua_S,1,nullptr);
	if (cobj) 
	{
		cobj->ResetCurrentIndexgr();
		return 1;
	}
	return 0;
}
//Lua注册
static int register_all_cmd_data()
{
	auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* tolua_S = engine->getLuaStack()->getLuaState();

	tolua_usertype(tolua_S,"cc.CCmd_Data");
	tolua_cclass(tolua_S,"CCmd_Data","cc.CCmd_Data","cc.Node",nullptr);
	tolua_beginmodule(tolua_S,"CCmd_Data");

	tolua_function(tolua_S,"create",toLua_Cmd_Data_createOne);
	tolua_function(tolua_S,"setcmdinfo",toLua_Cmd_Data_setCmdInfoTwo);
	tolua_function(tolua_S,"getmain",toLua_Cmd_Data_getMainHH);
	tolua_function(tolua_S,"getsub",toLua_Cmd_Data_getSubMN);
	tolua_function(tolua_S,"getlen",toLua_Cmd_Data_lenTO);
	tolua_function(tolua_S,"getcurlen",toLua_Cmd_Data_curlenQW);
	tolua_function(tolua_S,"pushbool",toLua_Cmd_Data_pushBOOLBG);
	tolua_function(tolua_S,"pushbyte",toLua_Cmd_Data_pushBYTE);
	tolua_function(tolua_S,"pushword",toLua_Cmd_Data_pushWORD);
	tolua_function(tolua_S,"pushshort",toLua_Cmd_Data_pushSHORT);
	tolua_function(tolua_S,"pushint",toLua_Cmd_Data_pushINT);
	tolua_function(tolua_S,"pushdword",toLua_Cmd_Data_pushDWORD);
	tolua_function(tolua_S,"pushfloat",toLua_Cmd_Data_pushFLOATRG);
	tolua_function(tolua_S,"pushdouble",toLua_Cmd_Data_pushDOUBLE);
	tolua_function(tolua_S,"pushscore",toLua_Cmd_Data_pushSCORE);
	tolua_function(tolua_S,"pushstring",toLua_Cmd_Data_pushSTRING);
	tolua_function(tolua_S, "pushutf8", toLua_Cmd_Data_pushUTF8);
	//tolua_function(tolua_S,"setcurrentindex", toLua_Cmd_Data_setCurrentIndex);
	tolua_function(tolua_S,"resetread",toLua_Cmd_Data_resetRead);
	tolua_function(tolua_S,"readbool",toLua_Cmd_Data_readBOOL);
	tolua_function(tolua_S,"readbyte",toLua_Cmd_Data_readBYTE);
	tolua_function(tolua_S,"readword",toLua_Cmd_Data_readWORD);
	tolua_function(tolua_S,"readshort",toLua_Cmd_Data_readSHORT);
	tolua_function(tolua_S,"readint",toLua_Cmd_Data_readINT);
	tolua_function(tolua_S,"readdword",toLua_Cmd_Data_readDWORD12W);
	tolua_function(tolua_S,"readfloat",toLua_Cmd_Data_readFLOAT);
	tolua_function(tolua_S,"readdouble",toLua_Cmd_Data_readDOUBLEHT);
	tolua_function(tolua_S,"readscore",toLua_Cmd_Data_readSCORE);
	tolua_function(tolua_S,"readstring",toLua_Cmd_Data_readSTRING);
	tolua_function(tolua_S,"readutf8", toLua_Cmd_Data_readUTF8);
	tolua_endmodule(tolua_S);
	//mnahjdfe春树暮云d
	std::string typeName = typeid(cocos2d::CCmd_Data).name();
    g_luaType[typeName] = "cc.CCmd_Data";
    g_typeCast["CCmd_Data"] = "cc.CCmd_Data";
	return 1;
}

#ifdef __cplusplus
}
#endif

#endif