// EncryptManager.h : interface of the EncryptManager class
//
/////////////////////////////////////////////////////////////////////////////
#ifndef __ENCRYPTMANAGER_H__
#define __ENCRYPTMANAGER_H__
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#define CPP_DLL __declspec(dllexport)
#else
#define CPP_DLL 
#endif

#ifdef CC_TARGET_IOS_MAC
#define CPP_DLL
#endif

class CPP_DLL CEncryptManager
{
public:
	static CEncryptManager* getInstance();
	unsigned char* DecryptFileFormat(const unsigned char *pData, unsigned int dataLen, unsigned int &outdataLen);
	void Clear(unsigned char *pData);
};



#endif // __EncryptManager
