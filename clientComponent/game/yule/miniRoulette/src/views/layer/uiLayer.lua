--[[
    UI canvas
]]

local uiLayer = class("uiLayer")

local colorConfig = {
    2,1,2,1,2,1,1,2,1,2,1,2
}


function uiLayer:onExit()
    TweenLite.killTweensOf(self.m_sliderTime, time, { value = 50,time = 0, onUpdate = onUpdate,onComplete = onComplete,ease = Linear.easeNone }) 
end

function uiLayer:ctor(pNode)
    self.m_rootNode = pNode    
    self.m_maxPercent = 100
    self:initRecord()
    self.mm_Slider_time:setScale9Enabled(true)
    self.mm_Slider_time:setTouchEnabled(false)
    self.mm_Slider_time:setMaxPercent(self.m_maxPercent)
    self.mm_Slider_time:setPercent(self.m_maxPercent)

    self.mm_Button_showRecord:onClicked(function() 
        -- self.m_rootNode.m_scene:getGameRecordReq()
    end)


    self.mm_Panel_menu:hide()
    self.mm_btn_menu:onClicked(function() 
        self.mm_Panel_menu:setVisible(not self.mm_Panel_menu:isVisible())
    end)

    self.mm_btn_help:onClicked(function() 
        self.m_rootNode:createHelp()
    end)


    self.mm_Image_music_1:setVisible(not GlobalUserItem.bSoundAble)
    self.mm_Image_music_2:setVisible(GlobalUserItem.bSoundAble)
    if GlobalUserItem.bSoundAble then
        self.m_rootNode.m_soundsVolume = 1
    else
        self.m_rootNode.m_soundsVolume = 0
    end
    self.mm_btn_music:onClicked(function() 
        self.mm_Image_music_1:setVisible(GlobalUserItem.bSoundAble)
        self.mm_Image_music_2:setVisible(not GlobalUserItem.bSoundAble)
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
        if GlobalUserItem.bSoundAble then
            self.m_rootNode.m_soundsVolume = 1
        else
            self.m_rootNode.m_soundsVolume = 0
        end
        -- GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
    end)

    self.mm_btn_exit:onClicked(function()
        self.m_rootNode:onExit()
    end)

end
--time
function uiLayer:sliderUpdate(cbTimeLeave,cbAllTime)
    local time = cbTimeLeave
    local percent = cbTimeLeave * self.m_maxPercent
    if cbAllTime ~= nil then
        self.mm_Slider_time:setMaxPercent(cbAllTime * self.m_maxPercent)
    else
        self.mm_Slider_time:setMaxPercent(percent)
    end
    self.m_sliderTime = {value = percent,time = time}
    self.mm_Slider_time:setPercent(self.m_sliderTime.value)
    self.mm_Text_time:setString(self.m_sliderTime.time)
    local onUpdate = function() 
        if self.mm_Slider_time == nil then 
            return
        end 
        self.mm_Slider_time:setPercent(self.m_sliderTime.value)
        local n,_ = math.modf(self.m_sliderTime.time)
        self.mm_Text_time:setString(n+1)
    end
    local onComplete = function( ) 
        if self.mm_Slider_time == nil then 
            return
        end 
        self.mm_Slider_time:setPercent(0) 
        self.mm_Text_time:setString(0)
    end
    
	TweenLite.to(self.m_sliderTime, time, { value = 50,time = 0, onUpdate = onUpdate,onComplete = onComplete,ease = Linear.easeNone }) 
end

function uiLayer:initRecord()
    for i=1,22 do
        self["mm_Text_record"..i]:setString(0)
        local img = self["mm_Image_"..i]
        img:setVisible(false)
        local size = img:getContentSize()
        img:setPositionX(54*(i-1)+size.width/2)
    end
end

function uiLayer:setRecordData(recordData)
    self.m_recordData = recordData
    self:upRecordList()
end

function uiLayer:addRecordData(record)
    if type(record) ~= "number" then
        return
    end
    if tonumber(record) > 0 then
        if self.m_recordData.openNumCount < 65 then
            self.m_recordData.openNum[self.m_recordData.openNumCount+1]  = record
        else
            table.insert( self.m_recordData.openNum, record )
        end
            self.m_recordData.openNumCount = self.m_recordData.openNumCount + 1
    end
    self:upRecordList()
end

function uiLayer:upRecordList()

    local index = 0
    if self.m_recordData.openNumCount > 22 then
        index = self.m_recordData.openNumCount - 22
    end
    local newIconIndex = 1
    for i=1,22 do
        local openNum = self.m_recordData.openNum[index + i]
        if openNum and openNum > 0 then
            self["mm_Text_record"..i]:setString(openNum)
            local img = self["mm_Image_"..i]
            local index = colorConfig[openNum]
            local path = "GUI/ui/roulette_yd"..index..".png"
            img:loadTexture(path)
            img:setVisible(true)
            newIconIndex = i
        end
    end
    self.mm_Image_icon:setPositionX(40 + 54*(newIconIndex-1))
end

return uiLayer