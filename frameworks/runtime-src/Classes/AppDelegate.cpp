#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "lua_extensions.h"
#include "FileAsset.h"
//#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
//#include "MobileClientKernel.h"
//#else
//#include "net/MobileClientKernel.h"
//#endif

#include "LuaAssert/CurlAsset.h"
#include "LuaAssert/LogAsset.h"
#include "LuaAssert/CircleBy.h"
#include "LuaAssert/QrNode.h"
#include "LuaAssert/AESEncryptManager.h"

#include "LuaAssert/LuaDrawNode3D.h"


#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif

//#include "hxnetpacket.h"
//#include "hxnetcipher.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 

#include <Nb30.h>
#pragma comment(lib,"netapi32.lib") 

#include "SimpleAudioEngine.h"

#elif  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	#include "platform/android/jni/JniHelper.h"
    #include "SimpleAudioEngine.h"
    using namespace CocosDenshion;
#endif
#include "audio/include/AudioEngine.h"
using namespace experimental;

#include "ClientKernel.h"
#include "ImageToByte.h"
#include "LuaAssert.h"
#include "ClientSocket.h"
#include "Integer64.h"
#include "CMD_Data.h"
#include "ry_MD5.h"
#include "UnZipAsset.h"
#include "CDownAssetManager.h"

#include "utlis/rippleObject.h"

#define pi 3.141592

USING_NS_CC;
using namespace std;



#define SCHEDULE CCDirector::sharedDirector()->getScheduler()

AppDelegate* AppDelegate::m_instance = NULL;

AppDelegate::AppDelegate()
{
	//VM(AppDelegate);
	m_instance = this;
	m_pClientKernel = new CClientKernel();
	m_ImageToByte = new CImageToByteManger();
	m_BackgroundCallBack =  0;
	//VMEND();
}

AppDelegate::~AppDelegate()
{
#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	SimpleAudioEngine::end();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::end();

#endif
	CC_SAFE_DELETE(m_pClientKernel);
	CC_SAFE_DELETE(m_ImageToByte);

 #if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
//     // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
     RuntimeEngine::getInstance()->end();
 #endif

}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

static int toLua_AppDelegate_MD5(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 1)
	{
		const char* szData = lua_tostring(tolua_S,1);
		if(EMPTY_CHAR(szData) == false)
		{
			string md5pass = md5(szData);
			lua_pushstring(tolua_S,md5pass.c_str());
			return 1;
		}
	}//
	return 0;
}

static int toLua_AppDelegate_LoadImageByte(lua_State* tolua_S)
{//
	bool result = false;
	int argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		const char* szData = lua_tostring(tolua_S, 1);
		if (EMPTY_CHAR(szData) == false)
		{
			CImageToByteManger* help = (CImageToByteManger*)AppDelegate::getAppInstance()->m_ImageToByte;
			if (help)
				result = help->onLoadData(szData);
		}
	}
	lua_pushboolean(tolua_S, result ? 1 : 0);
	return 1;
}

static int toLua_AppDelegate_CleanImageByte(lua_State* tolua_S)
{
	CImageToByteManger* help = (CImageToByteManger*)AppDelegate::getAppInstance()->m_ImageToByte;
	if (help)
		help->onCleanData();
	return 0;
}

static int toLua_AppDelegate_checkData(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 2)
	{
		CImageToByteManger* help = (CImageToByteManger*)AppDelegate::getAppInstance()->m_ImageToByte;
		if (help)
		{		
			int x = lua_tointeger(tolua_S,1);
			int y = lua_tointeger(tolua_S,2);
			unsigned int data = help->getData(x,y);
			int r= data & 0xff;
			int g = (data >> 8) & 0xff;
			int b = (data >> 16) & 0xff;
			int a = (data >> 24) & 0xff;        
			lua_pushinteger(tolua_S,r);
			lua_pushinteger(tolua_S,g);
			lua_pushinteger(tolua_S,b);
			lua_pushinteger(tolua_S,a);
		}
		return 4;
	}//
	return 0;
}

static int toLua_AppDelegate_SaveByEncrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 3)
	{
		const char* filename = lua_tostring(tolua_S,1);
		const char* szKey = lua_tostring(tolua_S,2);
		const char* szData = lua_tostring(tolua_S,3);
		
		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length()-1]=='/')
		{
			sp = "";
		}else
		{//
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath+sp+filename);
		CCLOG("save_path:%s",filePath.c_str());
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		ValueVector dataArray;
		int len = strlen(szData);
		if (len > 0)
		{
			
			char *pData = new char[len+4];
			memset(pData,0,len+4);
			memcpy(pData+4,szData,len);
			//CCipher::encryptBuffer(pData,len+4);
			for(int i = 0;i<len+4;i++)
			{
				int tmp = pData[i];
				dataArray.push_back(Value(tmp));
			}
			CC_SAFE_DELETE(pData);
		}
		valueMap[szKey] = Value(dataArray);
		FileUtils::getInstance()->writeToFile(valueMap, filePath);
	}
	return 0;
}

static int toLua_AppDelegate_ReadByDecrypt(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 2)
	{
		const char* filename = lua_tostring(tolua_S,1);
		const char* szKey = lua_tostring(tolua_S,2);
		std::string filePath = FileUtils::getInstance()->getWritablePath();
		std::string sp = "";
		if (filePath[filePath.length()-1]=='/')
		{
			sp = "";
		}else
		{
			sp = '/';
		}
		filePath = FileUtils::getInstance()->fullPathForFilename(filePath+sp+filename);
		ValueMap valueMap = FileUtils::getInstance()->getValueMapFromFile(filePath);
		if (valueMap[szKey].isNull())
		{
			lua_pushstring(tolua_S,"");
		}
		else
		{
			ValueVector& dataArray = valueMap[szKey].asValueVector();
			int len = dataArray.size();
			if(len == 0)
			{
				lua_pushstring(tolua_S,"");
			}
			else
			{
				BYTE *pData = new BYTE[len+1];
				memset(pData,0,len+1);
				for (int i = 0;i<len ;i++)
				{
					pData[i] = dataArray.at(i).asByte();
				}
				//CCipher::decryptBuffer(pData,len);
				lua_pushstring(tolua_S,(char*)(pData+4));
				CC_SAFE_DELETE(pData);
			}
		}
		return 1;
	}
	return 0;
}

static int toLua_AppDelegate_downFileAsync(lua_State* tolua_S)
{

	int argc = lua_gettop(tolua_S);
	if ( argc == 4 )
	{

		const char* szUrl = lua_tostring(tolua_S,1);
		const char* szSaveName = lua_tostring(tolua_S,2);
		const char* szSavePath = lua_tostring(tolua_S,3);
		int handler = toluafix_ref_function(tolua_S,4,0);
		if (handler != 0)
		{
			CDownAssetManager::DownFile(szUrl,szSaveName,szSavePath,handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}
		else
		{
			CCLOG("toLua_AppDelegate_setHttpDownCallback hadler or listener is null");
		}
	}
	else
	{
		CCLOG("toLua_AppDelegate_setHttpDownCallback arg error now is %d",argc);
	}

	return 0;
}

static int toLua_AppDelegate_unZipAsync(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 3)
	{
		const char* file = lua_tostring(tolua_S,1);
		const char* path = lua_tostring(tolua_S,2);
		int handler = toluafix_ref_function(tolua_S,3,0);
		if (handler != 0)
		{
			CUnZipAssetManger::UnZipFile(file,path,handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}else{
			if (handler == NULL)
				CCLOG("toLua_AppDelegate_unZipAsync error handler is null");
		}
	}else{
		CCLOG("toLua_AppDelegate_unZipAsync error argc is %d",argc);
	}
	return 0;
}

static int toLua_AppDelegate_setbackgroundcallback(lua_State* tolua_S)
{
	int argc = lua_gettop(tolua_S);
	if(argc == 1)
	{
		int handler = toluafix_ref_function(tolua_S,1,0);

		if (handler != 0)
		{
			AppDelegate::getAppInstance()->setBackgroundListener(handler);
			lua_pushboolean(tolua_S, 1);
			return 1;
		}

	}
	return 0;
}
static int toLua_AppDelegate_removebackgroundcallback(lua_State* tolua_S)
{
	AppDelegate::getAppInstance()->setBackgroundListener(0);
	return 0;
}

static int toLua_AppDelegate_onUpDateBaseApp(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{	
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	WCHAR wszClassName[256] ={};
	MultiByteToWideChar(CP_ACP,0,path,strlen(path)+1,wszClassName,sizeof(wszClassName)/sizeof(wszClassName[0]));
	ShellExecute(NULL, L"open", L"explorer.exe",wszClassName, NULL, SW_SHOW);
#endif
    	lua_pushboolean(tolua_S, 1);
		return 1;
	}
	return 0;
}

static int toLua_AppDelegate_createDirectory(lua_State* tolua_S)
{

	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{
		bool result = createDirectory(path);
		lua_pushboolean(tolua_S, result?1:0);
		return 1;
	}

	return 0;
}

static int toLua_AppDelegate_removeDirectory(lua_State* tolua_S)
{
	const char* path = lua_tostring(tolua_S,1);
	if(path != NULL)
	{
		bool result = removeDirectory(path);
		lua_pushboolean(tolua_S, result?1:0);
		return 1;
	}

	return 0;
}

static unsigned char* getBMPFileData(const std::string &path, bool &haveData)
{
    haveData = false;
    //鏂囦欢鍒ゆ柇
    if (!FileUtils::getInstance()->isFileExist(path))
    {
        log("%s not exist!", path.c_str());
        return nullptr;
    }
    Data tmp = FileUtils::getInstance()->getDataFromFile(path);
    unsigned char* pBmpData = tmp.getBytes();
    //鏂囦欢闀垮害鍒ゆ柇
    if (tmp.getSize() < 2)
    {
    	log("%s not exist!", path.c_str());
    	return nullptr;
    }
    //bmp鏍煎紡鍒ゆ柇
    static const unsigned char BMP[] = {0X42, 0X4d};
    if (memcmp(BMP, pBmpData, sizeof(BMP)) != 0)
    {
        log("%s is not .bmp type file!", path.c_str());
        return nullptr;
    }
    
    unsigned char *bytecs = new unsigned char[96 * 96 * 4 + 1];
    int idx1 = 0;
    int idx2 = 0;
    for (int i = 0; i < 96 ; ++i)
    {
        for (int j = 0; j < 96; ++j)
        {
            idx1 = ((95 - i) * 96 + j)*4;
            idx2 = (i * 96 + j)*4;
            bytecs[idx1] = pBmpData[54 + idx2 + 2];          //R
            bytecs[idx1 + 1] = pBmpData[54 + idx2 + 1];      //G
            bytecs[idx1 + 2] = pBmpData[54 + idx2];          //B
            bytecs[idx1 + 3] = 0xff;                         //A
        }
    }
    haveData = true;
    return bytecs;
}

static int toLua_AppDelegate_createSpriteByBMPFile(lua_State* tolua_S)
{
    const char* path = lua_tostring(tolua_S, 1);

    cocos2d::Texture2D* tex = nullptr;
    bool bInit = false;
    //鍒ゆ柇鏄惁瀛樺湪绾圭悊缂撳瓨
    auto it = AppDelegate::getAppInstance()->m_cachedBmpTex.find(path);
    if (it != AppDelegate::getAppInstance()->m_cachedBmpTex.end())
    {
    	tex = it->second;
    	bInit = true;
    }
    else
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(path, bHave);
	    if (nullptr == data || false == bHave )
	    {
	        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", nullptr);
	        CC_SAFE_DELETE_ARRAY(data);
	        return 1;
	    }
	    
	    tex = new Texture2D();
	    bInit = tex->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    if (bInit)
	    {
	    	//缂撳瓨绾圭悊
	        AppDelegate::getAppInstance()->m_cachedBmpTex.insert(std::make_pair(path,tex));
	    }
	    CC_SAFE_DELETE_ARRAY(data);
    }
    if (nullptr != tex && true == bInit)
    {
    	//鍒涘缓
        cocos2d::Sprite* ret = cocos2d::Sprite::createWithTexture(tex);
        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", (cocos2d::Sprite*)ret);
    }
    else
    {
    	log("init texture error");
        object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite", nullptr);
        CC_SAFE_DELETE(tex);
    }
    return 1;
}

static int toLua_AppDelegate_createSpriteFrameByBMPFile(lua_State* tolua_S)
{
    const char* path = lua_tostring(tolua_S, 1);

    cocos2d::Texture2D* tex = nullptr;
    bool bInit = false;
    //鍒ゆ柇鏄惁瀛樺湪绾圭悊缂撳瓨
    auto it = AppDelegate::getAppInstance()->m_cachedBmpTex.find(path);
    if (it != AppDelegate::getAppInstance()->m_cachedBmpTex.end())
    {
    	tex = it->second;
    	bInit = true;
    }
    else
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(path, bHave);
	    if (nullptr == data || false == bHave )
	    {
	        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", nullptr);
	        CC_SAFE_DELETE_ARRAY(data);
	        return 1;
	    }
	    
	    tex = new Texture2D();
	    bInit = tex->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    if (bInit)
	    {
	    	//缂撳瓨绾圭悊
	        AppDelegate::getAppInstance()->m_cachedBmpTex.insert(std::make_pair(path,tex));
	    }
	    CC_SAFE_DELETE_ARRAY(data);
    }
    if (nullptr != tex && true == bInit)
    {
    	//鍒涘缓
        cocos2d::SpriteFrame* ret = cocos2d::SpriteFrame::createWithTexture(tex, Rect(0,0,96,96));
        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", (cocos2d::SpriteFrame*)ret);
    }
    else
    {
    	log("init texture error");
        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame", nullptr);
        CC_SAFE_DELETE(tex);
    }
    return 1;

}

static int toLua_AppDelegate_reSizeGivenFile(lua_State* tolua_S)
{
    auto argc = lua_gettop(tolua_S);
    if (argc == 4)
    {
        std::string path = lua_tostring(tolua_S, 1);
        std::string newpath = lua_tostring(tolua_S, 2);
        std::string notifyfun = lua_tostring(tolua_S, 3);
        if (FileUtils::getInstance()->isFileExist(path))
        {
            auto sp = Sprite::create(path);
            if (nullptr != sp)
            {            	
                int nSize = lua_tonumber(tolua_S, 4);
                auto size = sp->getContentSize();
                auto scale = nSize / size.width;
                sp->setScale(scale);
                sp->setAnchorPoint(Vec2(0.0f, 0.0f));

                auto render = RenderTexture::create(nSize, nSize);
                render->retain();
                render->beginWithClear(0, 0, 0, 0);
                sp->visit();
                render->end();
                Director::getInstance()->getRenderer()->render();
                render->saveToFile("tmp.png", true, [=](RenderTexture* render, const std::string& fullpath)
                                   {
                                   		if (newpath != "")
                                   		{
                                   			Director::getInstance()->getTextureCache()->removeTextureForKey(path);
	                                       	FileUtils::getInstance()->renameFile(fullpath, newpath);
	                                       
	                                       	lua_getglobal(tolua_S, notifyfun.c_str());
	                                       	if (!lua_isfunction(tolua_S, -1))
	                                       	{
	                                           	CCLOG("value at stack [%d] is not function", -1);
	                                           	lua_pop(tolua_S, 1);
	                                       	}
	                                       	else
	                                       	{
	                                           	lua_pushstring(tolua_S, fullpath.c_str());
	                                           	lua_pushstring(tolua_S, newpath.c_str());
	                                           	int iRet = lua_pcall(tolua_S, 2, 0, 0);
	                                           	if (iRet)
	                                           	{ 
	                                               log("call lua fun error:%s", lua_tostring(tolua_S, -1));
	                                               lua_pop(tolua_S, 1);
	                                           	}
	                                       	}
                                   		}
                                       	render->release();
                                   });
            }
        }
        
    }
    return 0;
}

static int toLua_AppDelegate_nativeMessageBox(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (2 == argc)
	{
		std::string msg = lua_tostring(tolua_S, 1);
        std::string title = lua_tostring(tolua_S, 2);

        MessageBox(msg.c_str(), title.c_str());
	}
	return 1;
}

static int toLua_AppDelegate_nativeIsDebug(lua_State* tolua_S)
{
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
	lua_pushboolean(tolua_S, 1);
#else
	lua_pushboolean(tolua_S, 0);
#endif
	return 1;
}

static int toLua_AppDelegate_containEmoji(lua_State* tolua_S)
{
    bool bContain = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        std::string msg = lua_tostring(tolua_S, 1);
        std::u16string ut16;
        if (StringUtils::UTF8ToUTF16(msg, ut16))
        {
            if (false == ut16.empty())
            {
                size_t len = ut16.length();
                for (size_t i = 0; i < len; ++i)
                {
                    char16_t hs = ut16[i];
                    if (0xd800 <= hs && hs <= 0xdbff)
                    {
                        if (ut16.length() > (i + 1))
                        {
                            char16_t ls = ut16[i + 1];
                            int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                            if (0x1d000 <= uc && uc <= 0x1f77f)
                            {
                                bContain = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if (0x2100 <= hs && hs <= 0x27ff)
                        {
                            bContain = true;
                        }
                        else if (0x2B05 <= hs && hs <= 0x2b07)
                        {
                            bContain = true;
                        }
                        else if (0x2934 <= hs && hs <= 0x2935)
                        {
                            bContain = true;
                        }
                        else if (0x3297 <= hs && hs <= 0x3299)
                        {
                            bContain = true;
                        }
                        else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
                        {
                            bContain = true;
                        }
                    }
                }
            }
        }
    }
    lua_pushboolean(tolua_S, bContain);
    return 1;
}

static int toLua_AppDelegate_convertToGraySprite(lua_State* tolua_S)
{
    bool bSuccess = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        Sprite *sp = (Sprite*)tolua_tousertype(tolua_S, 1, nullptr);
        if (nullptr != sp)
        {
            const GLchar* pszFragSource =
            "#ifdef GL_ES \n \
            precision mediump float; \n \
            #endif \n \
            uniform sampler2D u_texture; \n \
            varying vec2 v_texCoord; \n \
            varying vec4 v_fragmentColor; \n \
            void main(void) \n \
            { \n \
            // Convert to greyscale using NTSC weightings \n \
            vec4 col = texture2D(u_texture, v_texCoord); \n \
            float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); \n \
            gl_FragColor = vec4(grey, grey, grey, col.a); \n \
            }";
            GLProgram* pProgram = new GLProgram();
            pProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, pszFragSource);
            sp->setGLProgram(pProgram);
            pProgram->release();
            
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
            
            sp->getGLProgram()->link();
            sp->getGLProgram()->updateUniforms();
            bSuccess = true;
        }
    }
    lua_pushboolean(tolua_S, bSuccess);
    return 1;
}

static int toLua_AppDelegate_convertToNormalSprite(lua_State* tolua_S)
{
    bool bSuccess = false;
    auto argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        Sprite *sp = (Sprite*)tolua_tousertype(tolua_S, 1, nullptr);
        if (nullptr != sp)
        {
            const GLchar* pszFragSource =
            "#ifdef GL_ES \n \
            precision mediump float; \n \
            #endif \n \
            uniform sampler2D u_texture; \n \
            varying vec2 v_texCoord; \n \
            varying vec4 v_fragmentColor; \n \
            void main(void) \n \
            { \n \
            // Convert to greyscale using NTSC weightings \n \
            vec4 col = texture2D(u_texture, v_texCoord); \n \
            gl_FragColor = vec4(col.r, col.g, col.b, col.a); \n \
            }";
            GLProgram* pProgram = new GLProgram();
            pProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, pszFragSource);
            sp->setGLProgram(pProgram);
            pProgram->release();
            
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_POSITION, GLProgram::VERTEX_ATTRIB_POSITION);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_COLOR, GLProgram::VERTEX_ATTRIB_COLOR);
            sp->getGLProgram()->bindAttribLocation(GLProgram::ATTRIBUTE_NAME_TEX_COORD, GLProgram::VERTEX_ATTRIB_TEX_COORD);
            
            sp->getGLProgram()->link();
            sp->getGLProgram()->updateUniforms();
            bSuccess = true;
        }
    }
    lua_pushboolean(tolua_S, bSuccess);
    return 1;
}


static int toLua_AppDelegate_CCipHerInit(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool rv = false;
	if (argc == 2)
	{

		const char* machined = lua_tostring(tolua_S, 1);
		const char* localip = lua_tostring(tolua_S, 2);


		if (EMPTY_CHAR(machined) == false)
		{
			IHxNetKernel* kernel = GetNetKernel();
			if (kernel)
			{
				kernel->InitKernel(machined, localip);
			}
			/*CClientKernel* pKernel = (CClientKernel*)AppDelegate::getAppInstance()->getClientKernel();
			if (pKernel && pKernel->GetCipHer())
			{
				pKernel->GetCipHer()->initCipher(machined);
			}*/
		}
	}
	return 0;
}
static int toLua_AppDelegate_CCipHerDone(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 1)
	{

		IHxNetKernel* kernel = GetNetKernel();
		if (kernel)
		{
			kernel->DoneKernel();
		}

	}
	return 0;
}

static int toLua_AppDelegate_CCSetNetworkDelayTime(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 7)
	{
		int testInterval = lua_tointeger(tolua_S, 1);
		int pingAllTimeout = lua_tointeger(tolua_S, 2);
		int pingRecvTimeout = lua_tointeger(tolua_S, 3);
		int pingSendTimeout = lua_tointeger(tolua_S, 4);
		int recvTimeout = lua_tointeger(tolua_S, 5);
		int sendTimeout = lua_tointeger(tolua_S, 6);
		int fixRttVal = lua_tointeger(tolua_S, 7);
		IHxNetKernel* kernel = GetNetKernel();
		if (kernel)
		{
			kernel->SetNetConfig(testInterval, pingAllTimeout, pingRecvTimeout, pingSendTimeout, recvTimeout, sendTimeout, fixRttVal);
		}
	}
	return 0;
}
static int toLua_AppDelegate_CCSetSessionID(lua_State* tolua_S)
{
/*
#ifdef WIN32
	auto argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		unsigned int sessionID = lua_tointeger(tolua_S, 1);
		IMCKernel *kernel = GetMCKernel();
		if (kernel)
		{
			kernel->InitNetSessionID(sessionID);
		}
	}
#endif*/
	return 0;
}

static int toLua_AppDelegate_CCCalcuBezier(lua_State* tolua_S)
{
    auto argc = lua_gettop(tolua_S);
	if (argc == 9)
	{
		double x1 = lua_tonumber(tolua_S, 1);
		double y1 = lua_tonumber(tolua_S, 2);
		double x2 = lua_tonumber(tolua_S, 3);
		double y2 = lua_tonumber(tolua_S, 4);
		double x3 = lua_tonumber(tolua_S, 5);
		double y3 = lua_tonumber(tolua_S, 6);
		double x4 = lua_tonumber(tolua_S, 7);
		double y4 = lua_tonumber(tolua_S, 8);
		double t = lua_tonumber(tolua_S, 9);

		Vec2 p;
		double u = 1 - t;
		double tt = t * t;
		double uu = u * u;
		double uuu = uu * u;
		double ttt = tt * t;

		p.x = uuu * x1;
		p.y = uuu * y1;

		p.x += 3 * uu * t * x2;
		p.y += 3 * uu * t * y2;

		p.x += 3 * u * tt * x3;
		p.y += 3 * u * tt * y3;

		p.x += ttt * x4;
		p.y += ttt * y4;

		lua_pushnumber(tolua_S, p.x);
		lua_pushnumber(tolua_S, p.y);

		return 2;
	}
	return 2;
}


static int toLua_AppDelegate_CCDeg(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 2)
	{
		double x = lua_tonumber(tolua_S, 1);
		double y = lua_tonumber(tolua_S, 2);
		double angle = atan2(x, y);
		double deg = angle * 180 / pi;
		lua_pushnumber(tolua_S, deg);
	}
	return 1;
}

static int toLua_AppDelegate_CCNormalize(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 4)
	{
		double fish_x = lua_tonumber(tolua_S, 1);
		double fish_y = lua_tonumber(tolua_S, 2);
		double bullet_x = lua_tonumber(tolua_S, 3);
		double bullet_y = lua_tonumber(tolua_S, 4);

		double x = fish_x - bullet_x;
		double y = fish_y - bullet_y;

		double len = sqrt(x*x+y*y);
		if (len <= 0.00001f)
		{
			lua_pushnumber(tolua_S, 1);
			lua_pushnumber(tolua_S, 0);
		}
		else
		{
			lua_pushnumber(tolua_S, x/len);
			lua_pushnumber(tolua_S, y/len);
		}
	}
	return 2;
}

static int toLua_AppDelegate_CCCalcuBullet(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 6)
	{
		double bullet_x = lua_tonumber(tolua_S, 1);
		double bullet_y = lua_tonumber(tolua_S, 2);
		double movedir_x = lua_tonumber(tolua_S, 3);
		double movedir_y = lua_tonumber(tolua_S, 4);
		double speed = lua_tonumber(tolua_S, 5);
		double dt = lua_tonumber(tolua_S, 6);

		double x = bullet_x + movedir_x*speed*dt;
		double y = bullet_y + movedir_y*speed*dt;

		double angle = atan2(movedir_x, movedir_y);
		double deg = angle * 180 / pi;

		lua_pushnumber(tolua_S, deg);
		lua_pushnumber(tolua_S, x );
		lua_pushnumber(tolua_S, y );
		lua_pushnumber(tolua_S, abs(movedir_x));
		lua_pushnumber(tolua_S, abs(movedir_y));

	}
	return 5;
}

static int toLua_AppDelegate_CCCreateRippleLayer(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		const char* strFile = lua_tostring(tolua_S, 1);
		RippleObject* _layer = new RippleObject();
		_layer->autorelease();
		_layer->init(strFile);
		object_to_luaval<cocos2d::Layer>(tolua_S, "cc.Layer", (cocos2d::Layer*)_layer);
	}
	if (argc == 2)
	{
		const char* strFile = lua_tostring(tolua_S, 1);
		float girdSide = (float)lua_tonumber(tolua_S, 2);
		RippleObject* _layer = new RippleObject();
		_layer->autorelease();
		_layer->init(strFile, girdSide);
		object_to_luaval<cocos2d::Layer>(tolua_S, "cc.Layer", (cocos2d::Layer*)_layer);
	}
	return 1;
}

static int toLua_AppDelegate_CCOpenWinUrl(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
		const char* _url = lua_tostring(tolua_S, 1);
		WCHAR wszClassName[256] = {};
		MultiByteToWideChar(CP_ACP, 0, _url, strlen(_url) + 1, wszClassName, sizeof(wszClassName) / sizeof(wszClassName[0]));
		ShellExecute(NULL, L"open",
			wszClassName, NULL, NULL, SW_SHOWNORMAL);
#endif
	}
	return 1;
}


static int toLua_AppDelegate_CCInitServer(lua_State* tolua_S)
{
	//auto argc = lua_gettop(tolua_S);
	//if (argc == 3)
	//{
	//	int nType = lua_tointeger(tolua_S, 1);
	//	//const char* szUrl = lua_tostring(tolua_S, 2);
	//	unsigned int uAddr = (unsigned int)lua_tonumber(tolua_S, 2);
	//	unsigned short nPort = (unsigned short)lua_tointeger(tolua_S, 3);
	//	IHxNetKernel* kernel = GetNetKernel();
	//	if (kernel)
	//	{
	//		kernel->AddServer(nType, uAddr, nPort);
	//	}
	//}
	CCLOG("CCInitServer NOT USED!!");
	return 1;
}


static int toLua_AppDelegate_CCCleanTesterServer(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);

	uint32_t uGateID = argc==2?lua_tonumber(tolua_S, 1):0;
	IHxNetKernel* kernel = GetNetKernel();
	bool rv = false;
	if (kernel)
	{
		kernel->ClsGateServer(uGateID);
		CCLOG("CCCleanTesterServer NOT USED!!");
	}
	return 1;
}
static int toLua_AppDelegate_CCInitTesterServer(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);

	uint32_t uGateID = lua_tonumber(tolua_S, 1);
	const char* szUrl = lua_tostring(tolua_S, 2);
	IHxNetKernel* kernel = GetNetKernel();
	bool rv = false;
	if (kernel)
	{
		if (szUrl == NULL) {
			CCLOG("CCInitTesterServer szUrl == NULL!!");
			return 0;
		}
		rv = kernel->AddGateServer(uGateID, szUrl);
	}
	lua_pushboolean(tolua_S, rv?1:0);
	return rv?1:0;
}
static int toLua_AppDelegate_GetOptimalAddressCount(lua_State* tolua_S)
{
	IHxNetKernel* kernel = GetNetKernel();
	if (kernel)
	{
		int rv = kernel->GetOptimalAddressCount();
		lua_pushnumber(tolua_S, rv);
		return 1;
	}
	lua_pushnumber(tolua_S, -1);
	return 0;
}


static int toLua_AppDelegate_CCInitStartServerTester(lua_State* tolua_S)
{
	//auto argc = lua_gettop(tolua_S);
	//if (argc == 0)
	//{
	//	IMCKernel *kernel = GetMCKernel();
	//	if (kernel)
	//	{
	//		kernel->StartServerTester();
	//	}
	//}
	CCLOG("CCInitStartServerTester NOT USED!!");
	return 1;
}

static int toLua_AppDelegate_CCInitStopServerTester(lua_State* tolua_S)
{
	//auto argc = lua_gettop(tolua_S);
	//if (argc == 0)
	//{
	//	IMCKernel *kernel = GetMCKernel();
	//	if (kernel)
	//	{
	//		kernel->StopServerTester();
	//	}
	//}
	CCLOG("CCInitStopServerTester NOT USED!!");
	return 1;
}


static int toLua_AppDelegate_CCHxcipherIpEncode(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 1)
	{
		uint32_t ipDw = lua_tonumber(tolua_S, 1);
		uint8_t ipBuffer[14] = { 0 };
		int result = hxcipher_ipencode(ipDw, ipBuffer);
		for (int i = 0; i < 14; i++)
		{
			//macTemp[i] = ipBuffer[i];
			lua_pushnumber(tolua_S, ipBuffer[i]);
		}
	}
	return 14;
}
static Vec3 getInterpolatedPt(float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10, float a11)
{
	float v11 = a2 * ((1.0 - a11 * 2.0 + (float)(a11 * a11)) * 0.5);
	float v12 = a3 * ((1.0 - a11 * 2.0 + (float)(a11 * a11)) * 0.5);
	float v13 = a4 * ((1.0 - a11 * 2.0 + (float)(a11 * a11)) * 0.5);
	float v14 = a5 * ((a11 * 2.0 + 1.0 - (float)(a11 * a11) * 2.0) * 0.5);
	float v15 = a6 * ((a11 * 2.0 + 1.0 - (float)(a11 * a11) * 2.0) * 0.5);
	float v16 = a7 * ((a11 * 2.0 + 1.0 - (float)(a11 * a11) * 2.0) * 0.5);
	float v17 = a8 * ((float)(a11 * a11) * 0.5);
	float v18 = a9 * ((float)(a11 * a11) * 0.5);
	float v19 = a10 * ((float)(a11 * a11) * 0.5);
	float v30 = (float)(v11 + v14) + v17;
	float v29 = (float)(v12 + v15) + v18;
	float v28 = (float)(v13 + v16) + v19;
	return (cocos2d::Vec3(v30, v29, v28));
}

static int toLua_AppDelegate_setLightWave(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool ok = true;
	if (argc == 7)
	{
		cocos2d::Mesh* cobj = nullptr;
		if (!tolua_isusertype(tolua_S, 1, "cc.Mesh", 0, 0))
		{
			tolua_error(tolua_S, "setLightWave agr1 error", nullptr);
			return 0;
		}
		cobj = (cocos2d::Mesh*)tolua_tousertype(tolua_S, 1, 0);
#if COCOS2D_DEBUG >= 1
		if (!cobj)
		{
			tolua_error(tolua_S, "invalid 'cobj' in function 'toLua_AppDelegate_setLightWave'", nullptr);
			return 0;
		}
#endif
		std::string v29;
		ok &= luaval_to_std_string(tolua_S, 2, &v29, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr2 error", nullptr);
			return 0;
		}
		std::string v30;
		ok &= luaval_to_std_string(tolua_S, 3, &v30, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr3 error", nullptr);
			return 0;
		}
		Vec4 v37;
		ok &= luaval_to_vec4(tolua_S, 4, &v37, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr4 error", nullptr);
			return 0;
		}
		double v21;
		ok &= luaval_to_number(tolua_S, 5, &v21, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr5 error", nullptr);
			return 0;
		}
		double v22;
		ok &= luaval_to_number(tolua_S, 6, &v22, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr6 error", nullptr);
			return 0;
		}
		double v23;
		ok &= luaval_to_number(tolua_S, 7, &v23, "setLightWave");
		if (!ok)
		{
			tolua_error(tolua_S, "setLightWave agr7 error", nullptr);
			return 0;
		}
		const GLchar *vertexShader = "attribute vec3 a_position; attribute vec4 a_blendWeight; att"
			"ribute vec4 a_blendIndex; attribute vec2 a_texCoord; const i"
			"nt SKINNING_JOINT_COUNT = 60; uniform vec4 u_matrixPalette[S"
			"KINNING_JOINT_COUNT * 3]; \n"
			" #ifdef GL_ES \n"
			" varying mediump vec2 v_texCoord; \n"
			" #else \n"
			" varying vec2 v_texCoord; \n"
			" #endif \n"
			" vec4 getPosition() { float blendWeight = a_blendWeight[0]; "
			"int matrixIndex = int(a_blendIndex[0]) * 3; vec4 matrixPalet"
			"te1 = u_matrixPalette[matrixIndex] * blendWeight; vec4 matri"
			"xPalette2 = u_matrixPalette[matrixIndex + 1] * blendWeight; "
			"vec4 matrixPalette3 = u_matrixPalette[matrixIndex + 2] * ble"
			"ndWeight; blendWeight = a_blendWeight[1]; if (blendWeight > "
			"0.0) { matrixIndex = int(a_blendIndex[1]) * 3; matrixPalette"
			"1 += u_matrixPalette[matrixIndex] * blendWeight; matrixPalet"
			"te2 += u_matrixPalette[matrixIndex + 1] * blendWeight; matri"
			"xPalette3 += u_matrixPalette[matrixIndex + 2] * blendWeight;"
			" } blendWeight = a_blendWeight[2]; if (blendWeight > 0.0) { "
			"matrixIndex = int(a_blendIndex[2]) * 3; matrixPalette1 += u_"
			"matrixPalette[matrixIndex] * blendWeight; matrixPalette2 += "
			"u_matrixPalette[matrixIndex + 1] * blendWeight; matrixPalett"
			"e3 += u_matrixPalette[matrixIndex + 2] * blendWeight; } blen"
			"dWeight = a_blendWeight[3]; if (blendWeight > 0.0) { matrixI"
			"ndex = int(a_blendIndex[3]) * 3; matrixPalette1 += u_matrixP"
			"alette[matrixIndex] * blendWeight; matrixPalette2 += u_matri"
			"xPalette[matrixIndex + 1] * blendWeight; matrixPalette3 += u"
			"_matrixPalette[matrixIndex + 2] * blendWeight; } vec4 _skinn"
			"edPosition; vec4 postion = vec4(a_position, 1.0); _skinnedPo"
			"sition.x = dot(postion, matrixPalette1); _skinnedPosition.y "
			"= dot(postion, matrixPalette2); _skinnedPosition.z = dot(pos"
			"tion, matrixPalette3); _skinnedPosition.w = postion.w; retur"
			"n _skinnedPosition; } void main() { gl_Position = CC_MVPMatr"
			"ix * getPosition(); v_texCoord = a_texCoord; v_texCoord.y = "
			"1.0 - v_texCoord.y; }";
		const GLchar *fragmentShader = "\n"
			" #ifdef GL_ES \n"
			" precision mediump float; \n"
			" #endif \n"
			" uniform sampler2D u_texture; uniform sampler2D u_texture_mask; uniform sampler2D "
			"u_texture_light; uniform vec4 v_LightColor; uniform vec4 u_color; uniform float UV"
			"RunTime; varying vec2 v_texCoord; void main(void) { vec4 maskcolor = texture2D(u_t"
			"exture_mask, v_texCoord) * v_LightColor; vec4 lightcolor = texture2D(u_texture_lig"
			"ht, v_texCoord - UVRunTime / 30.0) * maskcolor; lightcolor.w = 0.0; gl_FragColor ="
			" texture2D(u_texture, v_texCoord)*u_color + lightcolor; }";
		auto v5 = GLProgram::createWithByteArrays(vertexShader, fragmentShader);
		ssize_t v8 = cobj->getMeshVertexAttribCount();
		ssize_t v7 = 0;
		const cocos2d::MeshVertexAttrib *v18;
		for (int i=0;i<v8;i++)
		{
			v18 = &(cobj->getMeshVertexAttribute(i));
			auto v25 = *v18;
			auto v26 = *(v18 + 4);
			auto v27 = *(v18 + 8);
			auto v28 = *(v18 + 12);

			int v29 = cobj->getVertexSizeInBytes();
			//GLProgramState::setVertexAttribPointer;
		}
	}
	return 1;
}

static int toLua_AppDelegate_pathMathGetLength(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool ok = true;
	if (argc == 4)
	{
		cocos2d::Vec3 v71;
		ok &= luaval_to_vec3(tolua_S, 1, &v71, "pathMathGetLength");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetLength agr1 error", nullptr);
			return 0;
		}
		cocos2d::Vec3 v70;
		ok &= luaval_to_vec3(tolua_S, 2, &v70, "pathMathGetLength");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetLength agr2 error", nullptr);
			return 0;
		}
		cocos2d::Vec3 v69;
		ok &= luaval_to_vec3(tolua_S, 3, &v69, "pathMathGetLength");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetLength agr3 error", nullptr);
			return 0;
		}
		int v68 = lua_tointeger(tolua_S,4);
		float  v67 = 1.0/ v68;
		float v66 = 0.0;
		float v65 = 0.0;
		Vec3 v62 = v71;
		Vec3 v59;
	    for (int i=0;i<v68;i++)
	    {
			v65 = v65 + v67;
			if (i>=1)
			{
				v62 = v59;
			}
			v59 = getInterpolatedPt(v71.x, v71.y, v71.z, v70.x, v70.y, v70.z, v69.x, v69.y, v69.z, v65);
			float len = v62.distance(v59);
			v66 += len;
	    }
		lua_pushnumber(tolua_S, v66);
	}
	return 1;
}
static int toLua_AppDelegate_pathMathGetInterpolatedPt(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool ok = true;
	if (argc == 4)
	{
		cocos2d::Vec3 v71;
		ok &= luaval_to_vec3(tolua_S, 1, &v71, "pathMathGetInterpolatedPt");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetInterpolatedPt agr1 error", nullptr);
			return 0;
		}
		cocos2d::Vec3 v70;
		ok &= luaval_to_vec3(tolua_S, 2, &v70, "pathMathGetInterpolatedPt");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetInterpolatedPt agr2 error", nullptr);
			return 0;
		}
		cocos2d::Vec3 v69;
		ok &= luaval_to_vec3(tolua_S, 3, &v69, "pathMathGetInterpolatedPt");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetInterpolatedPt agr3 error", nullptr);
			return 0;
		}
		float v68 = lua_tonumber(tolua_S, 4);
		Vec3 v66 = getInterpolatedPt(v71.x, v71.y, v71.z, v70.x, v70.y, v70.z, v69.x, v69.y, v69.z, v68);
		vec3_to_luaval(tolua_S, v66);
	}
	return 1;
}

static int toLua_AppDelegate_pathMathCircleMovePos(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool ok = true;
	float v24 = 0.0;
	float v23 = 0.0;
	float v22 = 0.0;
	float v21 = 1.0;

	cocos2d::Vec3 v28;
	luaval_to_vec3(tolua_S, 1, &v28, "pathMathCircleMovePos");
	v24 = lua_tonumber(tolua_S, 2);
	cocos2d::Vec3 v25;
	luaval_to_vec3(tolua_S, 3, &v25, "pathMathCircleMovePos");
	double v3 = lua_tonumber(tolua_S, 4);
	v23 = v3;

	if (argc > 4)
	{
		v22 = lua_tonumber(tolua_S, 5);
		v3 = lua_tonumber(tolua_S, 6);
		v21 = v3;
	}
	float v1 = cos(v23);
	float v2 = sin(v23);
	float v20 = v1*v24;
	float v19 = v2*v24;
	float v18 = v1*v21;
	float v17 = v2*v21;

	float v14 = v28.x*v22 + v25.x;
	float v15 = (v25.y + v19) + v17 + (v28.y * v22);
	float v16 = (v25.z - v20) - v18 + (v28.z * v22);

	vec3_to_luaval(tolua_S, Vec3(v14,v15,v16));
	return 1;
}

static int toLua_AppDelegate_pathMathGetDirection(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	bool ok = true;
	if (argc == 2)
	{
		cocos2d::Vec3 v57;
		ok &= luaval_to_vec3(tolua_S, 1, &v57, "pathMathGetDirection");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetDirection agr1 error", nullptr);
			return 0;
		}
		cocos2d::Vec3 v56;
		ok &= luaval_to_vec3(tolua_S, 2, &v56, "pathMathGetDirection");
		if (!ok)
		{
			tolua_error(tolua_S, "pathMathGetDirection agr2 error", nullptr);
			return 0;
		}
		Vec3 u(0.0, 1.0, 0.0);
		Vec3 v53 = v56 - v57;
		v53.normalize();
		
		Vec3 v50;
		Vec3::cross(u, v53, &v50);
		v50.normalize();

		Vec3 v47;
		Vec3::cross(v53, v50, &v47);
		v47.normalize();

		Mat4 v38;
		v38.m[0] = v53.x;
		v38.m[1] = v53.y;
		v38.m[2] = v53.z;

		v38.m[4] = v47.x;
		v38.m[5] = v47.y;
		v38.m[6] = v47.z;

		v38.m[8] = v50.x;
		v38.m[9] = v50.y;
		v38.m[10] = v50.z;

		Quaternion  quat;
		Quaternion::createFromRotationMatrix(v38, &quat);
		quat.normalize();

		quaternion_to_luaval(tolua_S, quat);

	}
	return 1;
}









#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
typedef struct _ASTAT_
{
	ADAPTER_STATUS adapt;
	NAME_BUFFER NameBuff[30];
} ASTAT, *PASTAT;

static int toLua_AppDelegate_CCGetWinMac(lua_State* tolua_S)
{
	ASTAT Adapter;
	NCB Ncb;
	UCHAR uRetCode;
	LANA_ENUM lenum;
	int i = 0;
	memset(&Ncb, 0, sizeof(Ncb));
	Ncb.ncb_command = NCBENUM;
	Ncb.ncb_buffer = (UCHAR *)&lenum;
	Ncb.ncb_length = sizeof(lenum);
	uRetCode = Netbios(&Ncb);
	printf("The NCBENUM return adapter number is: %d \n ", lenum.length);
	for (i = 0; i < lenum.length; i++)
	{
		memset(&Ncb, 0, sizeof(Ncb));
		Ncb.ncb_command = NCBRESET;
		Ncb.ncb_lana_num = lenum.lana[i];
		uRetCode = Netbios(&Ncb);
		memset(&Ncb, 0, sizeof(Ncb));
		Ncb.ncb_command = NCBASTAT;
		Ncb.ncb_lana_num = lenum.lana[i];
		strcpy((char *)Ncb.ncb_callname, "* ");
		Ncb.ncb_buffer = (unsigned char *)&Adapter;
		Ncb.ncb_length = sizeof(Adapter);
		uRetCode = Netbios(&Ncb);
		if (uRetCode == 0)
		{
			char macTemp[32] = {'\0'};
			sprintf(macTemp, "%02X%02X%02X%02X%02X%02X ",
				Adapter.adapt.adapter_address[0],
				Adapter.adapt.adapter_address[1],
				Adapter.adapt.adapter_address[2],
				Adapter.adapt.adapter_address[3],
				Adapter.adapt.adapter_address[4],
				Adapter.adapt.adapter_address[5]
			);
			lua_pushstring(tolua_S, macTemp);
			return 1;
		}
	}
	return 0;
}
#endif

static int toLua_AppDelegate_CHxGetCheckCode(lua_State* tolua_S)
{
	CCLOG("toLua_AppDelegate_CHxGetCheckCode NOT USED!!");
	//auto argc = lua_gettop(tolua_S);
// 	if (argc==1)
// 	{
// 		int64_t lTime = lua_tointeger(tolua_S, 1);
// 		bool bNew = 0;
// 		if (AppDelegate::getAppInstance()->GetChxMakeCode())
// 		{
// 			DWORD oldCode = AppDelegate::getAppInstance()->GetChxMakeCode()->GetCheckCode(lTime,&bNew);
// 			lua_pushnumber(tolua_S, oldCode);
// 			lua_pushboolean(tolua_S, bNew);
// 		}
// 	}
// 	if (argc==0)
// 	{
// 		if (AppDelegate::getAppInstance()->GetChxMakeCode())
// 		{
// 			DWORD oldCode = AppDelegate::getAppInstance()->GetChxMakeCode()->GetCheckCode();
// 			lua_pushnumber(tolua_S, oldCode);
// 		}
// 	}
	return 2;
}

#ifdef WIN32
static int win_gettimeofday(struct timeval * val, struct timezone *)
{
	if (val)
	{
		SYSTEMTIME wtm;
		GetLocalTime(&wtm);

		struct tm tTm;
		tTm.tm_year	 = wtm.wYear - 1900;
		tTm.tm_mon	  = wtm.wMonth - 1;
		tTm.tm_mday	 = wtm.wDay;
		tTm.tm_hour	 = wtm.wHour;
		tTm.tm_min	  = wtm.wMinute;
		tTm.tm_sec	  = wtm.wSecond;
		tTm.tm_isdst	= -1;

		val->tv_sec	 = (long)mktime(&tTm);	   // time_t is 64-bit on win32
		val->tv_usec	= wtm.wMilliseconds * 1000;
	}
   return 0;
}
#endif

static long long getCurrentTime()  
{   
    struct timeval tv;   
#ifdef WIN32
    win_gettimeofday(&tv,NULL);
#else
    gettimeofday(&tv,NULL);
#endif 
	long long ms = tv.tv_sec;
    return ms * 1000 + tv.tv_usec / 1000;
} 
static int toLua_AppDelegate_currentTime(lua_State* tolua_S)
{
	long long curtime = getCurrentTime();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	//CCLOG("currentTime:%I64d",curtime);
#else
	//CCLOG("currentTime:%lld",curtime);
#endif
	lua_pushnumber(tolua_S, curtime);
	return 1;
}



extern uint8_t PROTOC_PUBVER;
extern bool PROTOC_ISZIP;
extern "C" {
    void SetNetKernelVersion(uint32_t uVersion);
}


static int toLua_AppDelegate_SetKernelVersion(lua_State* tolua_S)
{
	auto argc = lua_gettop(tolua_S);
	if (argc == 1) {
		uint32_t uVersion = lua_tonumber(tolua_S, 1);
		PROTOC_PUBVER = uVersion & 0xFF;
		if(0x80 == (PROTOC_PUBVER & 0x80)) {
			PROTOC_ISZIP = true;
		}
	}
	return 1;
}
// If you want to use packages manager to install more packages,
// don't modify or remove this function
static int register_all_packages()
{
	lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	luaopen_lua_extensions_MY(tolua_S);

	register_all_cmd_data();
	register_all_Integer64();
	register_all_client_socket();
	register_all_curlasset();
	register_all_logasset();
	register_all_Circleasset();
    register_all_QrNode();
    register_all_AESEncrypt();
	register_all_DrawNode3D(tolua_S);

	lua_register(tolua_S,"checkData",toLua_AppDelegate_checkData);
	lua_register(tolua_S,"md5",toLua_AppDelegate_MD5);
	lua_register(tolua_S,"readByDecrypt",toLua_AppDelegate_ReadByDecrypt);
	lua_register(tolua_S,"saveByEncrypt",toLua_AppDelegate_SaveByEncrypt);
	lua_register(tolua_S,"loadImageByte",toLua_AppDelegate_LoadImageByte);
	lua_register(tolua_S, "cleanImageByte", toLua_AppDelegate_CleanImageByte);
	lua_register(tolua_S,"downFileAsync",toLua_AppDelegate_downFileAsync);
	lua_register(tolua_S,"unZipAsync",toLua_AppDelegate_unZipAsync);
	lua_register(tolua_S,"setbackgroundcallback",toLua_AppDelegate_setbackgroundcallback);
	lua_register(tolua_S,"removebackgroundcallback",toLua_AppDelegate_removebackgroundcallback);
	lua_register(tolua_S,"onUpDateBaseApp",toLua_AppDelegate_onUpDateBaseApp);
	lua_register(tolua_S,"createDirectory",toLua_AppDelegate_createDirectory);
	lua_register(tolua_S,"removeDirectory",toLua_AppDelegate_removeDirectory);
	lua_register(tolua_S,"currentTime",toLua_AppDelegate_currentTime);

	lua_register(tolua_S,"createSpriteWithBMPFile",toLua_AppDelegate_createSpriteByBMPFile);
    lua_register(tolua_S,"createSpriteFrameWithBMPFile",toLua_AppDelegate_createSpriteFrameByBMPFile);
    lua_register(tolua_S,"reSizeGivenFile",toLua_AppDelegate_reSizeGivenFile);
    lua_register(tolua_S,"nativeMessageBox",toLua_AppDelegate_nativeMessageBox);
    lua_register(tolua_S,"isDebug",toLua_AppDelegate_nativeIsDebug);
    lua_register(tolua_S,"containEmoji",toLua_AppDelegate_containEmoji);
    lua_register(tolua_S,"convertToGraySprite", toLua_AppDelegate_convertToGraySprite);
    lua_register(tolua_S,"convertToNormalSprite", toLua_AppDelegate_convertToNormalSprite);

	lua_register(tolua_S, "CCipHerInit", toLua_AppDelegate_CCipHerInit);
	lua_register(tolua_S, "CCipHerDone", toLua_AppDelegate_CCipHerDone);

	lua_register(tolua_S, "CCSetNetworkDelayTime", toLua_AppDelegate_CCSetNetworkDelayTime);
	lua_register(tolua_S, "CCSetSessionID", toLua_AppDelegate_CCSetSessionID);
	lua_register(tolua_S, "CCCalcuBezier", toLua_AppDelegate_CCCalcuBezier);

	lua_register(tolua_S, "CCDeg", toLua_AppDelegate_CCDeg);
	lua_register(tolua_S, "CCNormalize", toLua_AppDelegate_CCNormalize);
	lua_register(tolua_S, "CCCalcuBullet", toLua_AppDelegate_CCCalcuBullet);

	lua_register(tolua_S, "CCCreateRippleLayer", toLua_AppDelegate_CCCreateRippleLayer);

	lua_register(tolua_S, "CCOpenWinUrl", toLua_AppDelegate_CCOpenWinUrl);
	lua_register(tolua_S, "CCInitServer", toLua_AppDelegate_CCInitServer);
	lua_register(tolua_S, "CCInitTesterServer", toLua_AppDelegate_CCInitTesterServer);
	lua_register(tolua_S, "CCCleanTesterServer", toLua_AppDelegate_CCCleanTesterServer);
	
	lua_register(tolua_S, "CCInitStartServerTester", toLua_AppDelegate_CCInitStartServerTester);
	lua_register(tolua_S, "CCInitStopServerTester", toLua_AppDelegate_CCInitStopServerTester);
	lua_register(tolua_S, "CCHxcipherIpEncode", toLua_AppDelegate_CCHxcipherIpEncode);
	//检测是否有 激活的服务器地址  >0 是有 ==0 没有  -1 未初始化
	lua_register(tolua_S, "CCGetReadyServerCount", toLua_AppDelegate_GetOptimalAddressCount);
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	lua_register(tolua_S, "CCGetWinMac", toLua_AppDelegate_CCGetWinMac);
#endif
	//use new functin
	lua_register(tolua_S, "setLightWave", toLua_AppDelegate_setLightWave);
	lua_register(tolua_S, "pathMathGetLength", toLua_AppDelegate_pathMathGetLength);
	lua_register(tolua_S, "pathMathGetInterpolatedPt", toLua_AppDelegate_pathMathGetInterpolatedPt);
	lua_register(tolua_S, "pathMathCircleMovePos", toLua_AppDelegate_pathMathCircleMovePos);
	lua_register(tolua_S, "pathMathGetDirection", toLua_AppDelegate_pathMathGetDirection);

	//设置核心版本
	lua_register(tolua_S, "setKernelVersion", toLua_AppDelegate_SetKernelVersion);
    return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
	//VM(applicationDidFinishLaunching);
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    AudioEngine::lazyInit();
#endif
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    auto isDebug = false;
#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
	isDebug = true;
	Director::getInstance()->setDisplayStats(true);
#endif

    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    register_all_packages();

    Device::setKeepScreenOn(true);
	
	if(((CClientKernel*)m_pClientKernel)->OnInit()==false)
	{
		CCLOG("[_DEBUG]	ClientKernel_onInit_FALSE!");
		return false;
	}

	
    LuaStack* stack = engine->getLuaStack();
	stack->setXXTEAKeyAndSign("kaile_game12345a", strlen("kaile_game12345a"), "kaile_game12345a", strlen("kaile_game12345a"));


    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());
	/*
 #if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
     // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
     auto runtimeEngine = RuntimeEngine::getInstance();
     runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
     runtimeEngine->start();
#else*/
/*
test
*/	
	//
    CCUserDefault::getInstance()->setIntegerForKey("CurApkVersion", 1);
	CCFileUtils::getInstance()->addSearchPath("base/src/");
    if (engine->executeScriptFile("base/src/main.lua"))
    {

        return false;
    }
	/*
#endif*/

	//IMCKernel *kernel = GetMCKernel();
	//if (kernel)
	//{
	//	kernel->SetLogOut((ILog*)((CClientKernel*)m_pClientKernel));
	//	CCLOG("KERNEL SUCCEED:%s", kernel->GetVersion());
	//}
	//else{
	//	CCLOG("Load MCKernel Faild************************************************");
	//	return false;
	//}


	SCHEDULE->scheduleSelector(schedule_selector(AppDelegate::GlobalUpdate), this, 0, kRepeatForever, 0,false);

	//VMEND();
    return true;
}


// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

#endif
#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	SimpleAudioEngine::getInstance()->pauseAllEffects();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    //AudioEngine::pauseAll();
#endif    

	if (m_BackgroundCallBack != 0)
	{
		lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
		toluafix_get_function_by_refid(tolua_S, m_BackgroundCallBack);
		if (lua_isfunction(tolua_S, -1))
		{
			lua_pushboolean(tolua_S, 0);
			LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_BackgroundCallBack, 1)!=0;
		}else{
			CCLOG("applicationDidEnterBackground-luacallback-handler-false:%d",m_BackgroundCallBack);
		}
	}
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
#if  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
	SimpleAudioEngine::getInstance()->resumeAllEffects();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    //AudioEngine::resumeAll();
#endif

    //
    for (auto it = m_cachedBmpTex.cbegin(); it != m_cachedBmpTex.cend();)
    {
    	Texture2D *tex = it->second;
    	CCLOG("ref count %d", tex->getReferenceCount());
    	if (tex->getReferenceCount() == 1)
    	{
    		CCLOG("removing unused bmp texture :%s", it->first.c_str());
    		tex->release();
    		m_cachedBmpTex.erase(it++);
    	}
    	else
    	{
    		++it;
    	}
    }
    //閲嶆柊鍔犺浇鏁版嵁
    for (auto it = m_cachedBmpTex.cbegin(); it != m_cachedBmpTex.cend(); ++it)
    {
    	bool bHave = false;
	    unsigned char *data = getBMPFileData(it->first.c_str(), bHave);
	    if (nullptr != data && true == bHave )
	    {
	    	it->second->initWithData(data, 96 * 96 * 4, Texture2D::PixelFormat::RGBA8888, 96, 96, cocos2d::Size(96, 96));
	    }    	
    }

	if (m_BackgroundCallBack != 0)
	{
		lua_State* tolua_S=LuaEngine::getInstance()->getLuaStack()->getLuaState();
		toluafix_get_function_by_refid(tolua_S, m_BackgroundCallBack);
		if (lua_isfunction(tolua_S, -1))
		{
			lua_pushboolean(tolua_S, 1);
			LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(m_BackgroundCallBack, 1)!=0;
		}else{
			CCLOG("applicationDidEnterBackground-luacallback-handler-false:%d",m_BackgroundCallBack);
		}
	}
	/*LuaStack * LL = LuaEngine::getInstance()->getLuaStack();
	lua_State* tolua_s = LL->getLuaState();
	lua_getglobal(tolua_s, "GetMyMachined");    // 鑾峰彇鍑芥暟锛屽帇鍏ユ爤涓?
	int iRet = lua_pcall(tolua_s, 0, 1, 0);// 璋冪敤鍑芥暟锛岃皟鐢ㄥ畬鎴愪互鍚?
	if (iRet)
	{

		const char *pErrorMsg = lua_tostring(tolua_s, -1);
		CCLOG("閿欒-------%s", pErrorMsg);
	}
	string str = lua_tostring(tolua_s, -1);     //鑾峰彇绗竴涓繑鍥炲€?
	int aa = 10;*/
}

void AppDelegate::GlobalUpdate(float dt)
{
	CClientKernel* pKernel = (CClientKernel*)AppDelegate::getAppInstance()->getClientKernel();
	if(pKernel)
		pKernel->GlobalUpdate(dt);
	else
		CCLOG("GlobalUpdate m_pClientKernel is null");
}
