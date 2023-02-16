#include "CMD_Data.h"
#include "LuaAssert.h"
#include "../../hxlibnetv3/include/hxnet_coding++.h"

#ifndef _hxcmp_min
#define _hxcmp_min(x, y) ((x)<(y)?(x):(y))
#endif//_hxcmp_min

bool PROTOC_ISZIP = false;
//构造函数
CCmd_Data::CCmd_Data(WORD nLenght, bool bZip)
	:m_wMain(0),m_wSub(0),m_wCurIndex(0), m_bZip(bZip), m_nFeldIndex(0)
{
	if(nLenght>0) {
		m_bAutoLen = false;
		m_wMaxLenght = nLenght;
		m_pBuffer = (BYTE*)malloc(nLenght);
		memset(m_pBuffer,0,nLenght);
	}
	else {
		m_bAutoLen = true; 
		m_wMaxLenght = AUTO_LEN;
		m_pBuffer = (BYTE*)malloc(AUTO_LEN);
		memset(m_pBuffer,0,AUTO_LEN);
	}
}
CCmd_Data::CCmd_Data(uint8_t* pBuf, WORD nLenght, bool bZip) 
	:m_wMain(0), m_wSub(0), m_wCurIndex(0), m_bZip( bZip || PROTOC_ISZIP ), m_nFeldIndex(0)
{
	m_bAutoLen = false;
	m_wMaxLenght = nLenght;
	m_pBuffer = pBuf;
}
//析构函数
CCmd_Data::~CCmd_Data()
{
	CC_SAFE_FREE(m_pBuffer);
}

//创建对象
CCmd_Data* CCmd_Data::create(int nLenght, bool bZip)
{
	CCmd_Data* data = new CCmd_Data(nLenght, bZip);
	data->autorelease();
	return data;
}
CCmd_Data* CCmd_Data::createWithBuffer(uint8_t* pBuf, int nLenght, bool bZip) {
	CCmd_Data* data = new CCmd_Data(pBuf, nLenght, bZip);
	data->autorelease();
	return data;
}

VOID CCmd_Data::SetCommand(WORD wMain, WORD wSub) {
	m_wMain = wMain;
	m_wSub = wSub;

}





//===================================================================================================================================
#define _RDBUF(T, CHK)																												\
	int32_t fld = 0;																												\
	int32_t pos = 0;																												\
	int32_t cnt = 1;																												\
	if(m_pBuffer == NULL) {pos = -1;}																								\
	else if (m_bZip) {																												\
		if (nMaxCount >= 0)																											\
			pos = CodingHelper<T, 1>::Decode(&fld, pVal, &cnt, m_pBuffer + m_wCurIndex, m_wMaxLenght - m_wCurIndex);				\
		else																														\
			pos = CodingHelper<T, -1>::Decode(&fld, *pVal, &cnt, m_pBuffer + m_wCurIndex, m_wMaxLenght - m_wCurIndex);				\
		if(pos > 0) m_wCurIndex+=pos;																								\
	}																																\
	else {																															\
		if (nMaxCount > 0 ) {																										\
			int32_t i = 0;																											\
			cnt = _hxcmp_min(nMaxCount,(m_wMaxLenght-m_wCurIndex)/sizeof(T));														\
			T* pSrc = (T*)(m_pBuffer + m_wCurIndex);																				\
			if( pVal) memcpy(pVal, pSrc, cnt*sizeof(T));																			\
			pos = cnt * sizeof(T);																									\
			m_wCurIndex += pos;																										\
		}																															\
		else if(nMaxCount==0) {																										\
			int32_t i = 0;																											\
			cnt = 0;																												\
			if(m_wCurIndex+sizeof(uint16_t) <= m_wMaxLenght) {																		\
				cnt = *(uint16_t*)(m_pBuffer + m_wCurIndex);																		\
				pos += sizeof(uint16_t);																							\
			}																														\
			cnt = _hxcmp_min(cnt,(m_wMaxLenght-m_wCurIndex-pos)/sizeof(T));															\
			T* pSrc = (T*)(m_pBuffer+m_wCurIndex+pos);																				\
			while (i < cnt ) {																										\
				if (CHK)																											\
					break;																											\
				if( pVal) memcpy(pVal+i,pSrc+i,sizeof(T));																			\
				i++;																												\
			}																														\
			pos += cnt * sizeof(T);																									\
			m_wCurIndex += pos;																										\
		}																															\
		else {																														\
			cnt = 1;																												\
			pos = -1;																												\
			if( m_wCurIndex + sizeof(T) <= m_wMaxLenght ) {																			\
				T* pSrc = (T*)(m_pBuffer + m_wCurIndex);																			\
				pos = sizeof(T);																									\
				if(pVal) memcpy(pVal,pSrc,sizeof(T));																				\
				m_wCurIndex += pos;																									\
			}																														\
		}																															\
		fld = m_nFeldIndex++;																										\
	}


int32_t	CCmd_Data::ReadSInt08(char* pVal, int32_t nMaxCount) {
	_RDBUF(char, pSrc[i]== 0);
	return pos;
}
int32_t	CCmd_Data::ReadUInt08(uint8_t* pVal, int32_t nMaxCount) {
	_RDBUF(uint8_t,0);
	return pos;
}
int32_t	CCmd_Data::ReadSInt16(int16_t* pVal, int32_t nMaxCount) {
	_RDBUF(int16_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadUInt16(uint16_t* pVal, int32_t nMaxCount) {
	_RDBUF(uint16_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadSInt32(int32_t* pVal, int32_t nMaxCount) {
	_RDBUF(int32_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadUInt32(uint32_t* pVal, int32_t nMaxCount) {
	_RDBUF(uint32_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadSInt64(int64_t* pVal, int32_t nMaxCount) {
	_RDBUF(int64_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadUInt64(uint64_t* pVal, int32_t nMaxCount) {
	_RDBUF(uint64_t, 0);
	return pos;
}
int32_t	CCmd_Data::ReadFlat32(float* pVal, int32_t nMaxCount) {
	_RDBUF(float, 0);
	return pos;
}
int32_t	CCmd_Data::ReadFlat64(double* pVal, int32_t nMaxCount) {
	_RDBUF(DOUBLE, 0);
	return pos;
}

int32_t	CCmd_Data::ReadString(char* pUtf8Val, int32_t nMaxCount) {
	if(m_bZip) {
		return ReadUTF8(pUtf8Val, nMaxCount);
	}
	else {
		char16_t* pVal = NULL;
		int32_t oLen = 0;
		int32_t nAlloc = nMaxCount;
		if (nAlloc == 0) {
			nAlloc = 4096;
		}
		pVal = new char16_t[nAlloc];
		memset(pVal, 0, nAlloc);
		if (nMaxCount <= 0) {
			int32_t i = 0;
			int32_t cnt = _hxcmp_min(nAlloc, (m_wMaxLenght - m_wCurIndex) / sizeof(char16_t));
			char16_t* pSrc = (char16_t*)(m_pBuffer + m_wCurIndex);
			while (i < cnt) {
				if (pVal) *(pVal + i) = *(pSrc + i);// memcpy(pVal + i, pSrc + i, sizeof(char16_t));
				if (*(pSrc + i) == 0) {
					i++;
					break;
				}
				i++;
			}
			pVal[cnt - 1] = 0;
			oLen = i * sizeof(char16_t);
			m_wCurIndex += oLen;
		}
		else {
			int32_t i = 0;
			int32_t cnt = _hxcmp_min(nMaxCount, (m_wMaxLenght - m_wCurIndex) / sizeof(char16_t));
			char16_t* pSrc = (char16_t*)(m_pBuffer + m_wCurIndex);
			while (i < cnt) {
				if (pVal) *(pVal + i) = *(pSrc + i);// memcpy(pVal + i, pSrc + i, sizeof(char16_t));
				if (*(pSrc + i) == 0) {
					i++;
					break;
				}
				i++;
			}
			pVal[cnt - 1] = 0;
			oLen = cnt * sizeof(char16_t);
			m_wCurIndex += oLen;
		}
		ToClientString((char*)pVal, oLen, pUtf8Val, nAlloc);
		SAFE_DELETE_ARRAY(pVal);
		return oLen;
	}
}
int32_t	CCmd_Data::ReadUTF8(char* pVal, int32_t nMaxCount) {
	int32_t oLen = 0;
	int32_t nAlloc = nMaxCount;
	if (nAlloc <= 0) {
		nAlloc = 4096;
	}
	if (nMaxCount <= 0) {
		int32_t i = 0;
		int32_t cnt = _hxcmp_min(nAlloc, (m_wMaxLenght - m_wCurIndex) / sizeof(char));
		char* pSrc = (char*)(m_pBuffer + m_wCurIndex);
		while (i < cnt) {
			if (pVal) *(pVal + i) = *(pSrc + i);// memcpy(pVal + i, pSrc + i, sizeof(char));
			if (*(pSrc + i) == 0) {
				i++;
				break;
			}
			i++;
		}
		pVal[cnt - 1] = 0;
		oLen = i * sizeof(char);
		m_wCurIndex += oLen;
	}
	else {
		int32_t i = 0;
		int32_t cnt = _hxcmp_min(nMaxCount, (m_wMaxLenght - m_wCurIndex) / sizeof(char));
		char* pSrc = (char*)(m_pBuffer + m_wCurIndex);
		while (i < cnt) {
			if (pVal) *(pVal + i) = *(pSrc + i);// memcpy(pVal + i, pSrc + i, sizeof(char));
			if (*(pSrc + i) == 0) {
				i++;
				break;
			}
			i++;
		}
		pVal[cnt - 1] = 0;
		oLen = cnt * sizeof(char);
		m_wCurIndex += oLen;
	}
	return oLen;
}



#define _WTBUF(T,CHK)																												\
	int32_t fld = m_nFeldIndex++;																									\
	int32_t pos = 0;																												\
	int32_t cnt = 1;																												\
	if(m_pBuffer == NULL) {pos = -1;}																								\
	else if (m_bZip) {																												\
		if (nMaxCount >= 0)																											\
			pos = CodingHelper<T, 1>::Encode(fld, pVal, nMaxCount, m_pBuffer + m_wCurIndex, m_wMaxLenght - m_wCurIndex);			\
		else																														\
			pos = CodingHelper<T, -1>::Encode(fld, *pVal, -1, m_pBuffer + m_wCurIndex, m_wMaxLenght - m_wCurIndex);					\
		if(pos > 0) m_wCurIndex += pos;																								\
	}																																\
	else {																															\
		if (nMaxCount > 0) {																										\
			int i = 0;																												\
			cnt = _hxcmp_min(nMaxCount,(m_wMaxLenght-m_wCurIndex)/sizeof(T));														\
			T* pDes = (T*)(m_pBuffer + m_wCurIndex);																				\
			if( pVal) memcpy(pDes, pVal, cnt*sizeof(T));																			\
			pos = cnt * sizeof(T);																							\
			m_wCurIndex += pos;																										\
		}																															\
		else if(nMaxCount == 0) {																									\
			int i = 0;																												\
			uint16_t* ln = (uint16_t*)(m_pBuffer+m_wCurIndex);																		\
			cnt = 0;																												\
			if(m_wCurIndex+sizeof(uint16_t)<= m_wMaxLenght) {																		\
				pos += sizeof(uint16_t);																							\
				cnt = (m_wMaxLenght-m_wCurIndex-pos)/sizeof(T);																		\
			}																														\
			else { ln = NULL; }																										\
			T* pDes = (T*)(m_pBuffer+m_wCurIndex+pos);																				\
			while(i < cnt) {																										\
				if (CHK)																											\
					break;																											\
				if(pVal) memcpy(pDes+i,pVal+i,sizeof(T));																			\
				i++;																												\
			}																														\
			if( ln ) *ln = (uint16_t)i;																								\
			pos = i * sizeof(T);																									\
			m_wCurIndex += pos;																										\
		}																															\
		else {																														\
			T* pDes = (T*)(m_pBuffer+m_wCurIndex);																					\
			if(m_wCurIndex+sizeof(T) <= m_wMaxLenght) {																				\
				pos = sizeof(T);																									\
				if (pVal) memcpy(pDes,pVal,sizeof(T));																				\
			}																														\
			m_wCurIndex += pos;																										\
		}																															\
	}


int32_t	CCmd_Data::WriteSInt08(const char* pVal, int32_t nMaxCount){
	_WTBUF(char, (pVal==NULL || pVal[i] == 0));
	return pos;
}

int32_t	CCmd_Data::WriteUInt08(const uint8_t* pVal, int32_t nMaxCount) {
	_WTBUF(uint8_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteSInt16(const int16_t* pVal, int32_t nMaxCount) {
	_WTBUF(int16_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteUInt16(const uint16_t* pVal, int32_t nMaxCount) {
	_WTBUF(uint16_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteSInt32(const int32_t* pVal, int32_t nMaxCount) {
	_WTBUF(int32_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteUInt32(const uint32_t* pVal, int32_t nMaxCount) {
	_WTBUF(uint32_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteSInt64(const int64_t* pVal, int32_t nMaxCount) {
	_WTBUF(int64_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteUInt64(const uint64_t* pVal, int32_t nMaxCount) {
	_WTBUF(uint64_t, 0);
	return pos;
}

int32_t	CCmd_Data::WriteFlat32(const float* pVal, int32_t nMaxCount) {
	_WTBUF(float, 0);
	return pos;
}
int32_t	CCmd_Data::WriteFlat64(const double* pVal, int32_t nMaxCount) {
	_WTBUF(double, 0);
	return pos;
}
int32_t	CCmd_Data::WriteString(const char* pUtf8, int32_t nMaxCount) {
	if(m_bZip) {
		return WriteUTF8(pUtf8, nMaxCount);
	}
	else {
		int32_t nAlloc = nMaxCount;
		int32_t oLen = 0;
		if (nAlloc == 0) {
			nAlloc = 1024;
		}
		else {
			nAlloc += 1;
		}
		char16_t* pVal = new char16_t[nAlloc+4];
		memset(pVal, 0, nAlloc * sizeof(char16_t));
		*pVal = 0;
		if (pUtf8 != NULL) {
			ToServerString((char*)pUtf8, strlen(pUtf8)+1, (char*)pVal, nAlloc * sizeof(char16_t));
			pVal[nAlloc-1] = 0;
		}
		if (nMaxCount <= 0) {
			int32_t i = 0;
			int32_t cnt = _hxcmp_min(nAlloc, (m_wMaxLenght - m_wCurIndex) / sizeof(char16_t));
			char16_t* pDes = (char16_t*)(m_pBuffer + m_wCurIndex);
			while (i < cnt) {
				if (pVal) *(pDes + i) = *(pVal + i);// memcpy(pVal + i, pSrc + i, sizeof(char));
				if (*(pVal + i) == 0) {
					i++;
					break;
				}
				i++;
			}
			if (i > 0) {
				pDes[i - 1] = 0;
			}
			oLen = i * sizeof(char16_t);
			m_wCurIndex += oLen;
		}
		else {
			int32_t i = 0;
			int32_t cnt = _hxcmp_min(nMaxCount, (m_wMaxLenght - m_wCurIndex) / sizeof(char16_t));
			char16_t* pDes = (char16_t*)(m_pBuffer + m_wCurIndex);
			while (i < cnt) {
				if (pVal) *(pDes + i) = *(pVal + i);// memcpy(pVal + i, pSrc + i, sizeof(char));
				if (pVal  &&  *(pVal + i) == 0) {
					break;
				}
				i++;
			}
			if (cnt > 0) {
				pDes[cnt - 1] = 0;
			}
			oLen = cnt * sizeof(char16_t);
			m_wCurIndex += oLen;
		}
		SAFE_DELETE_ARRAY(pVal);
		return oLen;
	}
}
int32_t	CCmd_Data::WriteUTF8(const char* pVal, int32_t nMaxCount) {
	int32_t oLen = 0;
	if (nMaxCount <= 0) {
		int32_t i = 0;
		int32_t cnt = (m_wMaxLenght - m_wCurIndex) / sizeof(char);
		char* pDes = (char*)(m_pBuffer + m_wCurIndex);
		while (i < cnt) {
			if (pVal)  memcpy(pDes + i, pVal + i, sizeof(char));
			i++;
			if (*(pVal + i) == 0) {
				i++;
				break;
			}
		}
		if (i > 0) {
			pDes[i - 1] = 0;
		}
		oLen = i * sizeof(char);
		m_wCurIndex += oLen;
	}
	else {
		int32_t i = 0;
		int32_t cnt = _hxcmp_min(nMaxCount, (m_wMaxLenght - m_wCurIndex) / sizeof(char));
		char* pDes = (char*)(m_pBuffer + m_wCurIndex);
		while (i < cnt) {
			if (pVal) *(pDes + i) = *(pVal + i);// memcpy(pVal + i, pSrc + i, sizeof(char));
			i++;
			if (pVal && *(pVal + i) == 0) {
				break;
			}
		}
		if (cnt > 0) {
			pDes[cnt - 1] = 0;
		}
		oLen = cnt * sizeof(char);
		m_wCurIndex += oLen;
	}
	return oLen;
}



/*


//设置命令
VOID CCmd_Data::SetCmdInfoMa(WORD wMain,WORD wSub)
{
	m_wMain = wMain;
	m_wSub = wSub;
}
//填充数据
WORD CCmd_Data::PushByteDataNHJ(BYTE* cbData,WORD wLenght)
{
	do
	{
		//非法过滤
		if(wLenght == 0&&cbData == NULL)
		{
			CCLOG("[_DEBUG]	pushByteData-error-null-input");
			break;
		}
		if(m_wCurIndex+wLenght > m_wMaxLenght)
		{
			if(!m_bAutoLen)
			{
				CCLOG("[_DEBUG]	pushByteData-error:[cur:%d][max:%d][add:%d]",m_wCurIndex,m_wMaxLenght,wLenght);
				break;
			}else{
				WORD wNewLen = (m_wMaxLenght + wLenght)*2;
				BYTE* pNewData =  new BYTE[wNewLen];
				memset(pNewData,0,wNewLen);
				memcpy(pNewData,m_pBuffer,m_wMaxLenght);
				m_wMaxLenght = wNewLen;
				CC_SAFE_DELETE(m_pBuffer);
				m_pBuffer = pNewData;
			}
		}
		//填充数据
		if(cbData != NULL)
			memcpy(m_pBuffer + m_wCurIndex,cbData,wLenght);
		//游标更新
		m_wCurIndex += wLenght;
	}while(false);
	return m_wCurIndex;
}
*/
