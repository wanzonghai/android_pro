#include "ClientSocket.h"

#pragma pack(push,1)
struct tagKernelData
{
	union {
		struct {
			WORD							KindID;							//Ãû³ÆË÷Òý
			WORD							SortID;							//ÅÅÐòË÷Òý
		};
		uint32_t VData;
	};
};

#pragma pack(pop)
CClientSocket::CClientSocket(int nHandler)
{
	/*if (bMode){
		pISocketServer = GetMCKernel()->CreateSocket(nHandler);
	}
	else{
		pIServerPool = GetMCKernel()->CreateServPool(nHandler, &pISocketServer);
	}*/
	//pISocketServer = GetMCKernel()->CreateSocket(nHandler);
	try {
		if (NULL == GetNetKernel()) {
			CCLOG("[_DEBUG]	CClientSocket::CClientSocket GetNetKernel() == NULL.handle:%d ", nHandler);
			return;
		}
		m_pNetClient = NULL;
		GetNetKernel()->CreateClient(&m_pNetClient, nHandler);
	}
	catch (...) {
		CCLOG("[_DEBUG]	CClientSocket::CClientSocket error. handle:%d ", nHandler);
	}

}
CClientSocket::~CClientSocket()
{
	CCLOG("[_DEBUG]	CClientSocket::~CClientSocket");
	GetNetKernel()->DeleteClient(&m_pNetClient);

}

int CClientSocket::sendData(CCmd_Data* pData)
{
	return SendSocketData(pData->GetMainCmd(), pData->GetSubCmd(), pData->GetBuffer(), pData->GetBufferLenghtqw()) ? 1 : 0;
}

// bool CClientSocket::AddServer(int nType, uint32_t szUrl, unsigned nPort)
// {
// 	return GetNetKernel()->AddGateServer()
// }
// 
// void CClientSocket::ClsServer(int nType)
// {
// 	GetNetKernel()->ClsServer(nType);
// }

bool CClientSocket::ConnectServer()
{
	if (m_pNetClient)
		return m_pNetClient->Connect();
	return false;
}



bool CClientSocket::ConnectGameServer(uint16_t wKind, uint16_t wSort)
{
	if (NULL == m_pNetClient)
		return false;

	tagKernelData cmd;
	cmd.KindID = wKind;
	cmd.SortID = wSort;
	return m_pNetClient->SendSocketData(0, 5, &cmd, sizeof(cmd));
}
/*
bool CClientSocket::QuerySocketServer(ISocketServer** ppServ)
{
	if (pIServerPool)
		return pIServerPool->QuerySocketServer(ppServ);
	return false;
}

bool CClientSocket::Connect(const char* szUrl, unsigned short wPort, unsigned char* pValidate / *= nullptr* /)
{
	/ *if (pISocketServer)
		return pISocketServer->ConnectServer(szUrl, wPort, pValidate);* /
	return false;
}
*/

bool CClientSocket::SendSocketData(unsigned short wMain, unsigned short wSub, const void* pData/* = nullptr*/, unsigned short wDataSize/* = 0*/)
{
	if (m_pNetClient)
		return m_pNetClient->SendSocketData(wMain, wSub, pData, wDataSize);
	return false;
}
void CClientSocket::StopServer()
{
	if (m_pNetClient)
		m_pNetClient->CloseConnect();
}

bool  CClientSocket::CloseGame(uint16_t wKind, uint16_t wSort) {
	if (NULL == m_pNetClient)
		return false;

	tagKernelData cmd;
	cmd.KindID = wKind;
	cmd.SortID = wSort;
	return m_pNetClient->SendSocketData(0, 6, &cmd, sizeof(cmd));
}
bool CClientSocket::IsServer()
{
	if (m_pNetClient)
		return m_pNetClient->IsStarted();
	return false;
}

/*
void CClientSocket::SetHeartBeatKeep(bool bKeep)
{
	if (pISocketServer)
		pISocketServer->SetHeartBeatKeep(bKeep);
}
void CClientSocket::SetDelayTime(long time)
{
	if (pISocketServer)
		pISocketServer->SetDelayTime(time);
}

void CClientSocket::SetWaitTime(long time)
{
	if (pISocketServer)
		pISocketServer->SetWaitTime(time);
}*/