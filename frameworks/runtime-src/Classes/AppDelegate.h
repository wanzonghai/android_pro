#ifndef __APP_DELEGATE_H__
#define __APP_DELEGATE_H__

#include "cocos2d.h"

//#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
//#include "macordef.h"
//#else
//#include "../net/macordef.h"
//#endif
#include "hxlibnetv3.h"

 typedef int Lua_CallBack;
 USING_NS_CC;

/**
@brief    The cocos2d Application.

The reason for implement as private inheritance is to hide some interface call by Director.
*/
class DLL_LOCAL AppDelegate : private cocos2d::Application, public cocos2d::Node
{
static	AppDelegate*	m_instance;

	Node*				m_pClientKernel;
    // Lua_CallBack*       m_SocketEventListener;

    Lua_CallBack        m_BackgroundCallBack;


public:
	Node*			    m_ImageToByte;
    std::unordered_map<std::string, cocos2d::Texture2D*> m_cachedBmpTex;
public:
	DLL_LOCAL AppDelegate();
	DLL_LOCAL virtual ~AppDelegate();

	DLL_LOCAL virtual void initGLContextAttrs();

    /**
    @brief    Implement Director and Scene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
	DLL_LOCAL virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    */
	DLL_LOCAL virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    */
	DLL_LOCAL virtual void applicationWillEnterForeground();
	
	DLL_LOCAL void GlobalUpdate(float dt);

	DLL_LOCAL static AppDelegate* getAppInstance(){return m_instance;}

	Node* getClientKernel(){return m_pClientKernel;}

    // void setSocketEventListener(Node* node){m_SocketEventListener = node;}
    // Node* getSocketEventListener(){return m_SocketEventListener;}

	DLL_LOCAL void setBackgroundListener(Lua_CallBack callback){m_BackgroundCallBack = callback;}
	DLL_LOCAL Lua_CallBack getBackgroundListener(){return m_BackgroundCallBack;}


};

#endif  // __APP_DELEGATE_H__

