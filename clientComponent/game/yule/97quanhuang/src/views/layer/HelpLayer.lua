--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)


-- 关闭
HelpLayer.BT_HOME_Esc = 1
-- 上一页
HelpLayer.BT_HOME_Up = 2
-- 下一页
HelpLayer.BT_HOME_Next = 3

HelpLayer.RES_PATH 				= device.writablePath.. "game/yule/97quanhuang/res/"

function HelpLayer:ctor(scene )
    --注册触摸事件
    g_ExternalFun.registerTouchEvent(self, true)

    self.scene = scene
   
--    local rootLayer, csbNode = g_ExternalFun.loadRootCSB(HelpLayer.RES_PATH .. "Help.csb", self);
   local csbNode = g_ExternalFun.loadCSB(HelpLayer.RES_PATH .. "Help.csb", self,false);

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender)
		end
	end
    local Panel = ccui.Layout:create()
    Panel:addTo(self,-1)
    Panel:setPosition(cc.p(0,0))
    Panel:setSize(cc.size(ylAll.WIDTH,ylAll.HEIGHT))
    Panel:setTouchEnabled(true)

    local img = csbNode:getChildByName("MengBan_2")
    img:setAnchorPoint(0.5,0.5)
    img:setPosition(667,375)
    img:setContentSize(1624,750)
    local btn_all          = csbNode:getChildByName("ChuangKou_Ban_3") 
    self.first_page_one    = csbNode:getChildByName("BiaoTi_Scene_1")
    --翻译修改
    local text_2 = self.first_page_one:getChildByName("Text_2")
    text_2:setString("Três ou mais BONUS disponíveis para\nentrar no mini-jogo! (Clique no\nmetrônomo no mini-jogo para\ncontrolar o ataque dos oito deusas\na grande cobra, o metrônomo conta com\ntrês efeitos de ativação e as recompensas\nserão diferentes para cada efeito!)")
    text_2:setScale(0.75)
    local text_3 = self.first_page_one:getChildByName("Text_3")
    text_3:setString('Os mini-jogos de desafio\npodem ser jogados por um')
    text_3:setScale(0.9)
    text_3:setPositionY(text_3:getPositionY() - 15)
    local text_2_0 = self.first_page_one:getChildByName("Text_2_0")
    text_2_0:setString("É possível substituir outros símbolos,\nexcepto os símbolos Bonus e Scatter.\n(Quando o símbolo curinga aparecer e\nfor ganho, irá expandir-se e os 3\nsímbolos na sua coluna irão se tornar\ncuringa para ligar!)")
    text_2_0:setScale(0.75)
    local text_3_0 = self.first_page_one:getChildByName("Text_3_0")
    text_3_0:setString('bônus de 35% do premiozão para 5 wild')
    text_3_0:setScale(0.9)

    local text_2_0_0 = self.first_page_one:getChildByName("Text_2_0_0")
    text_2_0_0:setString("Gira livremente quando\n3 ou mais Scatters\naparecerem na tela")
    text_2_0_0:setScale(0.95)
    local text_3_0_0 = self.first_page_one:getChildByName("Text_3_0_0")
    text_3_0_0:setString("3 grátis 5 vezes\n4 grátis 10 vezes\n5 grátis 20 vezes\n5 Símbolos Scatter aparecerão\npara um adicional de\n25% do premiozão")

    self.first_page_two    = csbNode:getChildByName("BiaoTi_Scene_2")
    self.first_page_two:setVisible(false)
    self.first_page_three  = csbNode:getChildByName("YanXian_34") 
    self.first_page_three:setVisible(false)
    self.first_page_three:getChildByName("Text_19"):setString("Os avatares devem estar na linha de pagamento e ligados por\ntrês ou mais da extremidade esquerda ou direita para ganhar")

    local Btn_Up   = btn_all:getChildByName("Button_1")
    Btn_Up:setTag(HelpLayer.BT_HOME_Up)
    Btn_Up:addTouchEventListener(btnEvent)

    local Btn_Esc  = btn_all:getChildByName("Button_3")
    Btn_Esc:setTag(HelpLayer.BT_HOME_Esc)
    Btn_Esc:addTouchEventListener(btnEvent)

    local Btn_Next = btn_all:getChildByName("Button_2")
    Btn_Next:setTag(HelpLayer.BT_HOME_Next)
    Btn_Next:addTouchEventListener(btnEvent)

    self.Index = 1
	self:setVisible(true)
end

function HelpLayer:onButtonClickedEvent( touch, event )
    if touch == HelpLayer.BT_HOME_Esc  then
        self:setVisible(false)
    elseif touch == HelpLayer.BT_HOME_Up  then
        if self.Index == 1 then
            self.first_page_one:setVisible(false)
            self.first_page_three:setVisible(true)
            self.Index = 3
        elseif self.Index == 3 then
            self.first_page_three:setVisible(false)
            self.first_page_two:setVisible(true)
            self.Index = 2
        elseif self.Index == 2 then
            self.first_page_two:setVisible(false)
            self.first_page_one:setVisible(true)
            self.Index = 1
        end
    elseif touch == HelpLayer.BT_HOME_Next  then
        if self.Index == 3 then
            self.first_page_three:setVisible(false)
            self.first_page_one:setVisible(true)
            self.Index = 1
        elseif self.Index == 2 then
            self.first_page_two:setVisible(false)
            self.first_page_three:setVisible(true)
            self.Index = 3
        elseif self.Index == 1 then
            self.first_page_one:setVisible(false)
            self.first_page_two:setVisible(true)
            self.Index = 2
        end
    end
	
end

return HelpLayer