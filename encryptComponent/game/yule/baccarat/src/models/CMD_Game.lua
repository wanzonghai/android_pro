local cmd = {}

--[[
******
* �ṹ������
* {k = "key", t = "type", s = len, l = {}}
* k ��ʾ�ֶ���,��ӦC++�ṹ�������
* t ��ʾ�ֶ�����,��ӦC++�ṹ���������
* s ���string��������,��������
* l �����������,�������鳤��,��table��ʽ,һά�����ʾΪ{N},N��ʾ���鳤��,��ά�����ʾΪ{N,N},N��ʾ���鳤��
* d ���table����,�����ֶ�Ϊһ��table����
* ptr �������,��ʱs����Ϊʵ�ʳ���

** egg
* ȡ���ݵ�ʱ��,���һά����,�������ֶ�����Ϊ {k = "a", t = "byte", l = {3}}
* ���ʾΪ ����aΪһ��byte������,����Ϊ3
* ȡ��һ��ֵ�ķ�ʽΪ a[1][1],�ڶ���ֵa[1][2],��������

* ȡ���ݵ�ʱ��,��Զ�ά����,�������ֶ�����Ϊ {k = "a", t = "byte", l = {3,3}}
* ���ʾΪ ����aΪһ��byte�Ͷ�ά����,���ȶ�Ϊ3
* ��ȡ��һ������ĵ�һ�����ݵķ�ʽΪ a[1][1], ȡ�ڶ�������ĵ�һ�����ݵķ�ʽΪ a[2][1]
******
]]

--��Ϸ�汾
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--��Ϸ��ʶ
cmd.KIND_ID						= 122
	
--��Ϸ����
cmd.GAME_PLAYER					= 100

--����������
cmd.SERVER_LEN					= 32

--��Ϸ��¼����
cmd.RECORD_LEN					= 5

--��ͼλ��
cmd.MY_VIEWID					= 2

--�������� (lua��tableĬ���±�Ϊ1������ʹ�õĹ�����Ӧ����1)
cmd.AREA_XIAN					= 0									--�м�����
cmd.AREA_PING					= 1									--ƽ������
cmd.AREA_ZHUANG					= 2									--ׯ������
cmd.AREA_XIAN_TIAN				= 3									--������
cmd.AREA_ZHUANG_TIAN			= 4									--ׯ����
cmd.AREA_TONG_DUI				= 5									--ͬ��ƽ
cmd.AREA_XIAN_DUI				= 6									--�ж���
cmd.AREA_ZHUANG_DUI				= 7									--ׯ����
cmd.AREA_MAX					= 8									--�������

--������multiple
cmd.MULTIPLE_XIAN				= 2									--�мұ���
cmd.MULTIPLE_PING				= 9									--ƽ�ұ���
cmd.MULTIPLE_ZHUANG				= 2									--ׯ�ұ���
cmd.MULTIPLE_XIAN_TIAN			= 3									--����������
cmd.MULTIPLE_ZHUANG_TIAN		= 3									--ׯ��������
cmd.MULTIPLE_TONG_DIAN			= 33								--ͬ��ƽ����
cmd.MULTIPLE_XIAN_PING			= 12								--�ж��ӱ���
cmd.MULTIPLE_ZHUANG_PING		= 12								--ׯ���ӱ���

--ռ������
cmd.SEAT_LEFT1_INDEX            = 0                                 --��һ
cmd.SEAT_LEFT2_INDEX            = 1                                 --���
cmd.SEAT_LEFT3_INDEX            = 2                                 --����
cmd.SEAT_LEFT4_INDEX            = 3                                 --����
cmd.SEAT_RIGHT1_INDEX           = 4                                 --��һ
cmd.SEAT_RIGHT2_INDEX           = 5                                 --�Ҷ�
cmd.SEAT_RIGHT3_INDEX           = 6                                 --����
cmd.SEAT_RIGHT4_INDEX           = 7                                 --����
cmd.MAX_OCCUPY_SEAT_COUNT       = 8                                 --���ռλ����
cmd.SEAT_INVALID_INDEX          = 9                                 --��Ч����

--����״̬
cmd.GAME_SCENE_FREE				= 0
--��Ϸ��ʼ
cmd.GAME_START 					= 1
--��Ϸ����
cmd.GAME_PLAY					= 100
--��ע״̬
cmd.GAME_JETTON					= 100
--��Ϸ����
cmd.GAME_END					= 101

--��Ϸ����ʱ
cmd.kGAMEFREE_COUNTDOWN			= 1
cmd.kGAMEPLAY_COUNTDOWN			= 2
cmd.kGAMEOVER_COUNTDOWN			= 3

---------------------------------------------------------------------------------------
--����������ṹ

--��Ϸ����
cmd.SUB_S_GAME_FREE				= 99
--��Ϸ��ʼ
cmd.SUB_S_GAME_START			= 100
--�û���ע
cmd.SUB_S_PLACE_JETTON			= 101
--��Ϸ����
cmd.SUB_S_GAME_END				= 102
--����ׯ��
cmd.SUB_S_APPLY_BANKER			= 103
--�л�ׯ��
cmd.SUB_S_CHANGE_BANKER			= 104
--���»���
cmd.SUB_S_CHANGE_USER_SCORE		= 105
--��Ϸ��¼
cmd.SUB_S_SEND_RECORD			= 106
--��עʧ��
cmd.SUB_S_PLACE_JETTON_FAIL		= 107
--ȡ������
cmd.SUB_S_CANCEL_BANKER			= 108
--����Ա����
cmd.SUB_S_AMDIN_COMMAND			= 109
--���¿��
cmd.SUB_S_UPDATE_STORAGE		= 110
--������ע(�������Ϣ)
cmd.SUB_S_SEND_USER_BET_INFO    = 111
--������ע(�������Ϣ)
cmd.SUB_S_USER_SCORE_NOTIFY     = 112
--������ׯ
cmd.SUB_S_SUPERROB_BANKER       = 113
--������ׯ����뿪
cmd.SUB_S_CURSUPERROB_LEAVE     = 114
--ռλ
cmd.SUB_S_OCCUPYSEAT            = 115
--ռλʧ��
cmd.SUB_S_OCCUPYSEAT_FAIL       = 116
--����ռλ
cmd.SUB_S_UPDATE_OCCUPYSEAT     = 117
---------------------------------------------------------------------------------------

------
--������ׯ����

--������ׯ
cmd.SUPERBANKER_VIPTYPE = 0;
cmd.SUPERBANKER_CONSUMETYPE = 1;

--��Ա
cmd.VIP1_INDEX = 1;
cmd.VIP2_INDEX = 2;
cmd.VIP3_INDEX = 3;
cmd.VIP4_INDEX = 4;
cmd.VIP5_INDEX = 5;
cmd.VIP_INVALID = 6;

--���ýṹ
cmd.SUPERBANKERCONFIG = 
{
    --��ׯ����
    {k = "superbankerType", t = "int"},
    --vip����
    {k = "enVipIndex", t = "int"},
    --��ׯ����
    {k = "lSuperBankerConsume", t = "score"}
 
    
}

--��ǰׯ������
cmd.ORDINARY_BANKER = 0;    --��ͨ���
cmd.SUPERROB_BANKER = 1;    --������ׯ���
cmd.INVALID_SYSBANKER = 2;  --��Ч����(ϵͳׯ��)
------

------
--ռλ����
cmd.OCCUPYSEAT_VIPTYPE = 0          --��Առλ
cmd.OCCUPYSEAT_CONSUMETYPE = 1      --������Ϸ��ռλ
cmd.OCCUPYSEAT_FREETYPE = 2         --���ռλ

--ռλ���ýṹ
cmd.OCCUPYSEATCONFIG = 
{
    --ռλ����
    {k = "occupyseatType", t = "int"},
    --vip����
    {k = "enVipIndex", t = "int"},
    --ռλ����
    {k = "lOccupySeatConsume", t = "score"},
    --���ռλ��Ϸ������
    {k = "lOccupySeatFree", t = "score"},
    --ǿ��վ������
    {k = "lForceStandUpCondition", t = "score"}
}
------

--��¼��Ϣ
cmd.tagServerGameRecord = 
{	
	cbKinWinner = 0,
	bPlayerTwoPair = false,
	bBankerTwoPair = false,
	cbPlayerCount = 0,
	cbBankerCount = 0
}

--������ׯ
cmd.CMD_S_SuperRobBanker = 
{
    {k = "bSucceed", t = "bool"},
    {k = "wApplySuperRobUser", t = "word"},     --�������
    {k = "wCurSuperRobBankerUser", t = "word"}  --��ǰ���
}

--������ׯ����뿪
cmd.CMD_S_CurSuperRobLeave = 
{
    {k = "wCurSuperRobBankerUser", t = "word"}
}

--����������
cmd.tagCustomAndroid = 
{
    --��ׯ
    --�Ƿ���ׯ
    {k = "nEnableRobotBanker", t = "bool"},
    --��ׯ����
    {k = "lRobotBankerCountMin", t = "score"},
    --��ׯ����
    {k = "lRobotBankerCountMax", t = "score"},
    --�б�����
    {k = "lRobotListMinCount", t = "score"},
    --�б�����
    {k = "lRobotListMaxCount", t = "score"},
    --����������
    {k = "lRobotApplyBanker", t = "score"},
    --��������
    {k = "lRobotWaitBanker", t = "score"},
    
    --��ע
    --��ע�������
    {k = "lRobotMinBetTime", t = "score"},
    --��ע�������
    {k = "lRobotMaxBetTime", t = "score"},
    --��ע������
    {k = "lRobotMinJetton", t = "score"},
    --��ע������
    {k = "lRobotMaxJetton", t = "score"},
    --��ע��������
    {k = "lRobotBetMinCount", t = "score"},
    --��ע��������
    {k = "lRobotBetMaxCount", t = "score"},
    --��������
    {k = "lRobotAreaLimit", t = "score"},
    
    --��ȡ��
    --��Ϸ������
    {k = "lRobotScoreMin", t = "score"},
    --��Ϸ������
    {k = "lRobotScoreMax", t = "score"},
    --ȡ����Сֵ(��ׯ)
    {k = "lRobotBankGetMin", t = "score"},
    --ȡ�����ֵ(��ׯ)
    {k = "lRobotBankGetMax", t = "score"},
    --ȡ����Сֵ(��ׯ)
    {k = "lRobotBankGetBankerMin", t = "score"},
    --ȡ�����ֵ(��ׯ)
    {k = "lRobotBankGetBankerMax", t = "score"},
    --���ٷֱ�
    {k = "lRobotBankStoMul", t = "score"},
    
    --������
    {k = "nAreaChance", t = "int", l = {cmd.AREA_MAX}},
}

--��עʧ��
cmd.CMD_S_PlaceBetFail =
{
	--��ע���
	{k = "wPlaceUser", t = "word"},
	--��ע����
	{k = "cbBetArea", t = "byte"},
	--��ע����
	{k = "lPlaceScore", t = "score"},
    --������
    {k="cbCode",t="byte"} 
    --[[1 ��ע������ȷ,
    2 ��ǰ������ע״̬
    3 ׯ�Ҳ�����ע
    4  ûׯ������ע
    5 �����Լ�Я������
    6 �����û���������
    7 ������ǰ����ע���ע
    ]]
}

--����ׯ��
cmd.CMD_S_ApplyBanker = 
{
	--����ׯ��
	{k = "wApplyUser", t = "word"}
}

--ȡ������
cmd.CMD_S_CancelBanker =
{
	--ȡ�����
	{k = "wCancelUser", t = "word"}
}

--�л�ׯ��
cmd.CMD_S_ChangeBanker = 
{
	--��ׯ���
	{k = "wBankerUser", t = "word"},
	--ׯ�ҷ���
	{k = "lBankerScore", t = "score"},
    --ׯ������
    {k = "typeCurrentBanker", t = "int"}
}

--��Ϸ״̬ free
cmd.CMD_S_StatusFree = 
{
	--ʣ��ʱ��
	{k = "cbTimeLeave", t = "byte"},
	--���������Ϸ��
	{k = "lPlayFreeScore", t = "score"},
	--��ǰׯ��
	{k = "wBankerUser", t = "word"},
	--ׯ�ҷ���
	{k = "lBankerScore", t = "score"},
	--ׯ��Ӯ��
	{k = "lBankerWinScore", t = "score"},
	--ׯ�Ҿ���
	{k = "wBankerTime", t = "word"},						
    
    --�Ƿ�����ϵͳ��ׯ
    {k = "bEnableSysBanker", t = "bool"},
    --������Ϣ									
    {k = "lApplyBankerCondition", t = "score"},				--��������
    {k = "lAreaLimitScore", t = "score"},					--��������
    
    --������Ϣ SERVER_LEN										
    {k = "szGameRoomName", t = "string", s = cmd.SERVER_LEN},					--��������
    {k = "bGenerEducate", t = "bool"},	                             --�Ƿ���ϰ��					
    --{k = "CustomAndroid", t = "table", d = cmd.tagCustomAndroid},  --����������

    --��ׯ����
    {k = "superbankerConfig", t = "table", d = cmd.SUPERBANKERCONFIG}, 
    {k = "wCurSuperRobBankerUser", t = "word"},
    --ׯ������
    {k = "typeCurrentBanker", t = "int"},

    --ռλ����
    {k = "occupyseatConfig", t = "table", d = cmd.OCCUPYSEATCONFIG},
    --ռλ����id MAX_OCCUPY_SEAT_COUNT
    {k = "wOccupySeatChairID", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},

     {k = "lUserLastJettonScore", t = "score", l = {cmd.AREA_MAX+1}},
}

--��Ϸ״̬ play/jetton
cmd.CMD_S_StatusPlay = 
{
	--ȫ����Ϣ					
    {k = "cbTimeLeave", t = "byte"},					--ʣ��ʱ��					
    {k = "cbGameStatus", t = "byte"},					--��Ϸ״̬
    
    --��ע�� AREA_MAX						
    {k = "lAllBet", t = "score", l = {cmd.AREA_MAX}},	--����ע		
    {k = "lPlayBet", t = "score", l = {cmd.AREA_MAX}},	--�����ע
    
    --��һ���				
    {k = "lPlayBetScore", t = "score"},					--��������ע	
    {k = "lPlayFreeSocre", t = "score"},				--�������¹��
    
    --�����Ӯ AREA_MAX						
    {k = "lPlayScore", t = "score", l = {cmd.AREA_MAX}},--�����Ӯ
    {k = "lPlayAllScore", t = "score"},       
    {k = "lRevenue", t = "score"},						--˰��
    --��ҳɼ�
    
    --ׯ����Ϣ					
    {k = "wBankerUser", t = "word"},					--��ǰׯ��	
    {k = "lBankerCurScore", t = "score"},					--ׯ�ҷ���		
    {k = "lBankerScore", t = "score"},				--ׯ��Ӯ��		
    {k = "wBankerTime", t = "word"},					--ׯ�Ҿ���
    
    --�Ƿ�ϵͳ��ׯ					
    {k = "bEnableSysBanker", t = "bool"},				--ϵͳ��ׯ
    
    --������Ϣ			
    {k = "lApplyBankerCondition", t = "score"},			--��������		
    {k = "lAreaLimitScore", t = "score"},				--��������
    
    --�˿���Ϣ 2				
    {k = "cbCardCount", t = "byte", l = {2}},			--�˿���Ŀ
    {k = "cbTableCardArray", t = "byte", l = {3,3}},	--�����˿� 2,3
    
    --������Ϣ SERVER_LEN				
    {k = "szGameRoomName", t = "string", s = cmd.SERVER_LEN},	--��������
    {k = "bGenerEducate", t = "bool"},	                         --�Ƿ���ϰ��
    --{k = "CustomAndroid", t = "table", d = cmd.tagCustomAndroid}, --����������

    {k = "superbankerConfig", t = "table", d = cmd.SUPERBANKERCONFIG},  --��ׯ����
    {k = "wCurSuperRobBankerUser", t = "word"},
    --ׯ������
    {k = "typeCurrentBanker", t = "int"},

    --ռλ����
    {k = "occupyseatConfig", t = "table", d = cmd.OCCUPYSEATCONFIG},
    --ռλ����id MAX_OCCUPY_SEAT_COUNT
    {k = "wOccupySeatChairID", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},

    --ռλ��ҳɼ�
    {k = "lOccupySeatUserWinScore", t = "score", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},

      {k = "lUserLastJettonScore", t = "score", l = {cmd.AREA_MAX+1}},
}

--��Ϸ����
cmd.CMD_S_GameFree = 
{
    {k = "cbTimeLeave", t = "byte"}
}

--��Ϸ��ʼ
cmd.CMD_S_GameStart = 
{
    --ʣ��ʱ��
    {k = "cbTimeLeave", t = "byte"},
    
    --ׯ��λ��
    {k = "wBankerUser", t = "word"},
    --ׯ����Ϸ��
    {k = "lBankerScore", t = "score"},
    
    --��������ע
    {k = "lPlayBetScore", t = "score"},
    --���������Ϸ��
    {k = "lPlayFreeSocre", t = "score"},
    
    --�������� (��ע������)
    {k = "nChipRobotCount", t = "int"},
    --�б�����
    {k = "nListUserCount", t = "int"},
    --�������б�����
    {k = "nAndriodCount", t = "int"},

    {k = "lUserLastJettonScore", t = "score", l = {cmd.AREA_MAX+1}},
};

--�û���ע
cmd.CMD_S_PlaceBet = 
{
    --�û�λ��
    {k = "wChairID", t = "word"},
    --��������
    {k = "cbBetArea", t = "byte"},
    --��ע��Ŀ
    {k = "lBetScore", t = "score"},
    --������ʶ
    {k = "cbAndroidUser", t = "byte"},
    --������ʶ
    {k = "cbAndroidUserT", t = "byte"},
};

--��Ϸ����
cmd.CMD_S_GameEnd = 
{
    --�¾���Ϣ
    --ʣ��ʱ��
    {k = "cbTimeLeave", t = "byte"},
    
    --�˿���Ϣ 2
    {k = "cbCardCount", t = "byte", l = {2}},			--�˿���Ŀ
    {k = "cbTableCardArray", t = "byte", l = {3,3}},	--�����˿� 2,3
    
    --ׯ����Ϣ
    --ׯ�ҳɼ�
    {k = "lBankerScore", t = "score"},
    --ׯ�ҳɼ�
    {k = "lBankerTotallScore", t = "score"},
    --��ׯ����
    {k = "nBankerTime", t = "int"},
    
    --��ҳɼ�
    --��ҳɼ� AREA_MAX
    {k = "lPlayScore", t = "score", l = {cmd.AREA_MAX}},

     {k = "lPlaySAreaScore", t = "score", l = {cmd.AREA_MAX}},
    --��ҳɼ�
    {k = "lPlayAllScore", t = "score"},
    
    --ȫ����Ϣ
    --��Ϸ˰��
    {k = "lRevenue", t = "score"},
}

--ռλ
cmd.CMD_S_OccupySeat = 
{
    --����ռλ���id
    {k = "wOccupySeatChairID", t = "word"},
    --ռλ����
    {k = "cbOccupySeatIndex", t = "byte"},
    --ռλ����id
    {k = "tabWOccupySeatChairID", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},
}

--ռλʧ��
cmd.CMD_S_OccupySeat_Fail = 
{
    --������ռλ���ID
    {k = "wAlreadyOccupySeatChairID", t = "word"},
    --��ռλ����
    {k = "cbAlreadyOccupySeatIndex", t = "byte"},
    --ռλ����id
    {k = "tabWOccupySeatChairID", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},
}

--����ռλ
cmd.CMD_S_UpdateOccupySeat = 
{
    --ռλ����id
    {k = "tabWOccupySeatChairID", t = "word", l = {cmd.MAX_OCCUPY_SEAT_COUNT}},
    --�����˳�ռλ���
    {k = "wQuitOccupySeatChairID", t = "word"},
}

---------------------------------------------------------------------------------------
--�ͻ�������ṹ

--�û���ע
cmd.SUB_C_PLACE_JETTON				= 1
--����ׯ��
cmd.SUB_C_APPLY_BANKER				= 2
--ȡ������
cmd.SUB_C_CANCEL_BANKER				= 3
--����Ա����
cmd.SUB_C_AMDIN_COMMAND				= 4
--���¿��
cmd.SUB_C_UPDATE_STORAGE			= 5
--������ׯ
cmd.SUB_C_SUPERROB_BANKER           = 6
--ռλ
cmd.SUB_C_OCCUPYSEAT                = 7                                   
--�˳�ռλ
cmd.SUB_C_QUIT_OCCUPYSEAT           = 8                                   
---------------------------------------------------------------------------------------

--�û���ע
cmd.CMD_C_PlaceBet = 
{
	--��������
	{k = "cbBetArea", t = "byte"},
	--��ע��Ŀ
	{k = "lBetScore", t = "score"}
}

--ռλ
cmd.CMD_C_OccupySeat = 
{
    --ռλ���
    {k = "wOccupySeatChairID", t = "word"},
    --ռλ����
    {k = "cbOccupySeatIndex", t = "byte"},
}

cmd.RES_PATH 					= 	"baccaratnew/res/"
print("********************************************************load cmd");
return cmd