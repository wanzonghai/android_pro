#ifndef _UN_ZIP_ASSET_H_
#define _UN_ZIP_ASSET_H_

#include <string>
#include "cocos2d.h"

using namespace cocos2d;
using namespace std;


class CUnZipAssetManger :public cocos2d::Node
{

protected:
	std::string	m_szUnZipPath;			//解压目录
	std::string m_szFilePath;			//解压文件
	int			m_nHandler;
protected:
	CUnZipAssetManger(const char* szFilePath,const char* szUnZipPath,int nHandler);

public:
	virtual ~CUnZipAssetManger();

public:
	static void UnZipFile(const char* szFilePath,const char* szUnZipPath,int nHandler);

protected:
	void UnZipRun();
};

#endif