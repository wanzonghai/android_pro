#ifndef DOWN_ASSETS_H
#define DOWN_ASSETS_H

#include <string>
#include "cocos2d.h"
//#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
//#include "macordef.h"
//#else
//#include "../net/macordef.h"
//#endif
#include "hxlibnetv3.h"

using namespace cocos2d;
using namespace std;

// CURL下载类
class DLL_LOCAL CDownAssetManager :public cocos2d::Node
{
protected:
	std::string	m_szDownUrl;			//下载地址
	std::string	m_szSavePath;			//保存目录

	int m_nHandler;						//回调通知
	int m_nPrecent;						//下载进度
public:
	std::string m_szFileName;			//文件名
	long m_localFileLenth;              //本地已经下载的文件大小
	long m_downFileLenth;               //服务器上文件大小

	void* m_curlHandle;
protected:
	//构造函数
	DLL_LOCAL CDownAssetManager(const char* szUrl,const char* szFileName,const char* szSavePath,int nHandler);
	
public:
	//析构函数
	DLL_LOCAL virtual ~CDownAssetManager();

public:
	//创建函数
	DLL_LOCAL static void DownFile(const char* szUrl,const char* szFileName,const char* szSavePath,int nHandler);

public:
	//更新进度
	DLL_LOCAL void upDatePro(int precent);

protected:
	//通知UI
	DLL_LOCAL void Notify(int wMain,int wSub);
	//下载函数
	DLL_LOCAL void DownRun();

};
#endif