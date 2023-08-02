#ifndef __HXLIB_NETV3_H__
#define __HXLIB_NETV3_H__

#pragma once

#include <stdint.h>


#ifndef hxinterface
#define hxinterface struct
#endif//hxinterface

#if !defined(_LUA_DEFINE_H_) && !defined(MSG_SOCKET_CONNECT)
#define 	MSG_SOCKET_CONNECT						1									//网络链接
#define 	MSG_SOCKET_DATA							2									//网络数据
#define		MSG_SOCKET_CLOSED						3									//网络关闭
#define 	MSG_SOCKET_ERROR						4									//网络错误
#endif//!defined(_LUA_DEFINE_H_) && !defined(MSG_SOCKET_CONNECT)


#ifndef DLL_PUBLIC
    #if defined(WIN32) || defined(WIN64)
        #define DLL_PUBLIC // Note: actually gcc seems to also supports this syntax.
        #define DLL_LOCAL
    #else
        #define DLL_PUBLIC __attribute__ ((visibility ("default")))
        #define DLL_LOCAL  __attribute__ ((visibility ("hidden")))
    #endif//
#endif//DLL_PUBLIC

#pragma pack(push,1)
typedef struct _NetPacket {
    uint16_t Type;
    bool ZipData;//层底
    union{
        struct{
            uint16_t						MCmd;							//主命令码
            uint16_t						SCmd;							//子命令码
        };
        uint32_t VCmd;
    };
    uint16_t Length;
    uint8_t* Data;
}TNetPacket;
#pragma pack(pop)


hxinterface IMessageRespon {
	virtual void OnMessageRespon(int nLuaFunID, TNetPacket* packet) = 0;
};

hxinterface ILog {
	virtual void LogOut(const char *message) = 0;
};

enum {
	EVENT_SUB_SOCKET_CONNECT_HALL = 1, //大厅连接成功
	EVENT_SUB_SOCKET_CONNECT_GAME = 2, //大厅游戏连接成功

	EVENT_SUB_SOCKET_CLOSED_HALL = 3, //大厅已经关闭
	EVENT_SUB_SOCKET_CLOSED_GAME = 4, //游戏已经关闭
	EVENT_SUB_SOCKET_CLOSED_ALL = 5,  //全部l连接关闭

	EVENT_SUB_SOCKET_ERROR = 6,         //Socket错误
	EVENT_SUB_SOCKET_RECONNT = 7,/*    --正在重连 */
};


hxinterface IHxNetClientV3 {
    
    virtual bool Connect() = 0;

    virtual bool SendSocketData(uint16_t wMCmd, uint16_t wSCmd) = 0;
	virtual bool SendSocketData(uint16_t wMCmd, uint16_t wSCmd, const void* pData, uint16_t wDataSize) = 0;
	
    virtual void CloseConnect() = 0 ;
	virtual bool IsStarted() = 0;

};

hxinterface IHxNetKernel
{
    virtual void SetNetConfig(
		uint32_t dwServTestInterval, //测试间隔时间 
		uint32_t dwServTestTimeout,  //服务器测试超时
		uint32_t dwUdpRecvTimeout, //udp 接收超时
		uint32_t dwUdpSendTimeout, //udp 发送超时
		uint32_t dwTcpRecvTimeout, //tcp 接收超时
		uint32_t dwTcpSendTimeout, //tcp 发送超时
		uint32_t dwRttFixValue//rtt 修复值
	) = 0;
    virtual bool InitKernel(const char* szMachineID, const char* szIpAddress) = 0;
	virtual void DoneKernel() = 0;


	virtual bool CheckVersion(unsigned long dwVersion) = 0 ;
	virtual const char* GetVersion() = 0;

	virtual void SetLogOut(ILog *log) = 0;
    //add gate server format //<ip><:网关端口>[|测试类型 0:UDP测试 1:PING测试 2:负载均衡][|测试端口]
	virtual bool AddGateServer(uint32_t uGateID, const char* szEncodeUrl) = 0;
    //if uGateID=0 then clear all servers;
	virtual void ClsGateServer(uint32_t uGateID) = 0;

    virtual bool CreateClient(IHxNetClientV3** ppNetClient, int nLuaFunID) = 0;

    virtual bool DeleteClient(IHxNetClientV3** ppNetClient) = 0;
	//////////////////////////////////////////////////////////////////////////
	virtual int  GetOptimalAddressCount() = 0;
};
#ifdef __cplusplus
extern "C" {
#endif//__cplusplus
    void SetNetKernelVersion(uint32_t uVersion);
    bool CreateNetKernel(IHxNetKernel** pNetKernel);
    void DeleteNetKernel(IHxNetKernel** pNetKernel);
    IHxNetKernel* GetNetKernel();
#ifdef __cplusplus
}
#endif//__cplusplus



#ifdef __cplusplus
extern "C" {
#endif//__cplusplus
    //把数据放入到 Lua同步数据队列 Global_LoopProcessNetwork 回调到call中
    bool Global_PushSyncData( uint16_t wType, 
        int32_t nLuaFunID, uint16_t wMCmd, uint16_t wSCmd, 
        const void* pData = NULL, uint16_t wDataSize = 0) ;

    //处理 Lua同步数据队列 中的数据
    void Global_LoopProcessSyncData(IMessageRespon* pMessage, int maxCount);


	int hxcipher_ipencode(uint32_t inip, uint8_t* outdt);
	int hxcipher_ipdecode(uint8_t* ipdt, uint32_t* outip);
#ifdef __cplusplus
}
#endif//__cplusplus


#endif//__HXLIB_NETV3_H__