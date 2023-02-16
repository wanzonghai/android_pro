--[[
* sdk callback 
*
*
]]
function GoogleLogonCallback(param)
    print("google logon: "..param)
	if type(param) == "string" then
		local ok, datatable = pcall(function()
			return cjson.decode(param)
		end)
        if ok and type(datatable) == "table" then
            local code = datatable["code"]   
            if code and tonumber(code) == 0 then   --成功
                -- ylAll.LogonType = ylAll.googleLogon
                local data = {}
                data.LoginType = 3 --Google登录
                data.uniqueId = datatable["id"]
                data.name = datatable["name"]
                data.token = datatable["token"]
                data.gender = math.random(2)-1
                data.headUrl = datatable["gpHeadImg"]
                data.email = datatable["personEmail"]
                G_event:NotifyEvent(G_eventDef.UI_THIRD_AUTH_CALLBACK,{data = data})
            end        
        end
    end
end

function FacebookCallback(param)
    print("facebook返回 "..param)
	if type(param) == "string" then
		local ok, datatable = pcall(function()
			return cjson.decode(param)
		end)
        if ok and type(datatable) == "table" then
            local code =  datatable["code"]   --0 成功，-1 取消
            if code and tonumber(code) == 0 then   --成功
                
                local data = {}
                -- ylAll.LogonType = ylAll.facebookLogon
                data.LoginType = 2 --FB登录
                data.uniqueId = datatable["id"]
                data.name = datatable["name"]
                data.token = datatable["token"]
                data.gender = 0
                data.headUrl = datatable["fbHeadImg"]
                data.email = datatable["email"]
                if datatable["gender"] == "male" then
                    data.gender = 1
                end
                G_event:NotifyEvent(G_eventDef.UI_THIRD_AUTH_CALLBACK,{data = data})
            end        
        end
    end
end


function mobShareCallback(param)
	if type(param) == "string" then
        if param == "uninstall" then
            G_event:NotifyEvent(G_eventDef.EVENT_PHONE_SHARE_CALLBACK)
        else
            local ok, datatable = pcall(function()
                return cjson.decode(param)
            end)
            if ok and type(datatable) == "table" then
                local data = {}
                data.platformType =  datatable["requestCode"]   --平台类型 WhatsApp= 54018,Telegram = 54019,FB Messenger = 54020 ,Instagram = 54021 , Twitter = 54022
                data.resultCode = datatable["resultCode"]
                G_event:NotifyEvent(G_eventDef.EVENT_PHONE_SHARE_CALLBACK,data)
            end
        end
    end
end



