--[[
	author: chenwei
	date:2022-05-27
	desc:新聊天帮助类
]]

local ChatHelper = Class("ChatHelper")

local isFirst = true --是否首次打开。

-- 实例
local instance = nil
-- 获取实例
function ChatHelper:GetInst()
    if instance == nil then
        instance = ClassList["ChatHelper"].instance()
    end
    return instance
end

function ChatHelper:Init()
	self.MAX_SAME_MESSAGE_COUNT = 4
	self.curChatFriend = 0

	self.m_aMessages = {}

	self.m_SpamPunishTimer = TimerFactory:newLazyTimer();

    self.bSightMode = false    --是否显示星标模式
end

function ChatHelper:SetSightMode(isShow)
	self.bSightMode = isShow
end

function ChatHelper:GetSightMode()
	return self.bSightMode
end

function ChatHelper:SetCurChatFriendUin(uin)
	self.curChatFriend = uin
end

function ChatHelper:GetCurChatFriendUin()
	return self.curChatFriend
end

--将字符串中使用的表情转换为富文本使用的表情格式
function TransferStrToEmoji(str, emojiSize)
    print("TransferStrToEmoji:", str)
    if not str or str == "" or type(str) ~= "string" then
        return ""
    end

    local function FindEmojiExpress(str2)
        return string.find(str2, "#A")
    end

    local function GetEmojiExpressFormat(str2)
        local pos = FindEmojiExpress(str2)
        local emoStr = string.sub(str2, pos, pos + 4);
        return emoStr
    end

    local function ReplaceEmojiExpress(emoStr)
        local emojN = g_ChatConfig.transEmoji[emoStr] or ""
        local imgUrl = string.format("<img src='ui://Chat/%s'>", emojN)
        if emojiSize then
            imgUrl = string.format("<img src='ui://Chat/%s' width='%s' height='%s'>", emojN, emojiSize.width, emojiSize.height)
        end
        return imgUrl
    end

    local posEmojiA, posEmojiB = FindEmojiExpress(str)
    if posEmojiA and posEmojiB then
        local preStr = string.sub(str, 1, posEmojiA - 1) or ""
        local emoStr = string.sub(str, posEmojiA, posEmojiA + 4)
        local otherStr = string.sub(str, posEmojiB+4, -1)
        --print("TransferStrToEmoji preStr：", preStr)
        --print("TransferStrToEmoji emoStr：", emoStr)
        --print("TransferStrToEmoji otherStr：", otherStr)

        if g_ChatConfig.transEmoji[emoStr] then
            if otherStr ~= nil and otherStr ~= "" then
                --print("TransferStrToEmoji otherStr has str", ReplaceEmojiExpress(emoStr))
                local newStr = preStr .. ReplaceEmojiExpress(emoStr) .. TransferStrToEmoji(otherStr, emojiSize)
                return newStr
            else
                --print("TransferStrToEmoji otherStr is nil or empty")
                return preStr .. ReplaceEmojiExpress(emoStr)
            end
        else
            local newStr = preStr .. string.gsub(emoStr, "#A", "") .. TransferStrToEmoji(otherStr, emojiSize)
            return newStr
        end
    else
        return str
    end
    
    return str
end


function ChatHelper:OpenChatView()
    if isFirst and ClientMgr:isPC() then --首次打开手动设置下输入模式
        UIFrameMgr:setCurEditBox(getglobal("ChatInputBox"));
        UIFrameMgr:setCurEditBox(nil);
        isFirst = false
    end
    GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/Chat","miniui/miniworld/c_playercenter"})
    GetInst("MiniUIManager"):OpenUI("chat_view","miniui/miniworld/Chat","chat_viewAutoGen", {fullScreen = {Type = 'Normal'},disableOperateUI = true})
end

function ChatHelper:OpenChatHoverBallView()
    --悬浮球功能暂不开放
    if true then
        return;
    end
    GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ChatHoverBall"})
    GetInst("MiniUIManager"):OpenUI("ChatHoverBall","miniui/miniworld/ChatHoverBall","ChatHoverBallAutoGen", {fullScreen = {Type = 'Normal'}})
end

function ChatHelper:isSpeakingTooFast()
    return AccountManager:getSvrTime() - self.m_iLastSendChatTime <= 0 
end

-- 发送好友聊天消息
function ChatHelper:SendFriendMsg(targetUin, szPlayerMsg)
    ReqSendChatMessage(AccountManager:getUin(), targetUin, szPlayerMsg)
end

-- 打开语音识别
function ChatHelper:OpenSpeechRecognize()
    if not ClientMgr:isAndroid() then
        return
    end

    local nowday = math.floor(getServerNow()/86400)
    local count = tonumber(0);
    local day_count = getkv("Speech_Limit_Day")
    if day_count then
        local arr = string.split(day_count, "_")
        if arr then 
            if tonumber(arr[1]) == nowday then
                count = tonumber(arr[2]);
            end
        end 
    end
    
    if count >= 500 then 
        ShowGameTips(GetS(100264))
        return
    end

    count = count+1
    setkv("Speech_Limit_Day",nowday..count)

    threadpool:work(function()
        JavaMethodInvokerFactory:obtain()
            :setClassName("org/appplay/lib/GameBaseActivity")
            :setMethodName("OpenSpeechRecognize")
            :setSignature("()V")
            :call()
    end)
end

-- 结束语音识别
function ChatHelper:StopSpeechRecognize(sceneId)
    if not ClientMgr:isAndroid() then
        return
    end

    threadpool:work(function()
        JavaMethodInvokerFactory:obtain()
            :setClassName("org/appplay/lib/GameBaseActivity")
            :setMethodName("StopSpeechRecognize")
            :setSignature("(Ljava/lang/String;)V")
			:addString(tostring(sceneId))
            :call()
    end)
end

-- 取消语音识别
function ChatHelper:CancelSpeechRecognize()
    if not ClientMgr:isAndroid() then
        return
    end

    threadpool:work(function()
        JavaMethodInvokerFactory:obtain()
            :setClassName("org/appplay/lib/GameBaseActivity")
            :setMethodName("CancelSpeechRecognize")
            :setSignature("()V")
            :call()
    end)
end

-- 语音识别回调
function ReturnRecognizeVoiceData(data)
    if not data then
        ShowGameTips("recognize speech failed data is empty")
        return
    end

    local params = string.split(data, "_")
    if not params then
        return
    end

    if (not params[1]) or (not params[2]) then
        return
    end

    local code = tonumber(params[1])
    local content = tostring(params[2])
    if code == 0 then
        SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_COMPLETED, SandboxContext():SetData_String("content", content))
    elseif code == 1 then --语音转换失败
        SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_FAIL, SandboxContext():SetData_String("code", code..""))
        ShowGameTipsWithoutFilter(GetS(8000034))
    elseif code == 2 then --拒绝麦克风权限
        SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_FAIL, SandboxContext():SetData_String("code", code..""))
        ShowGameTipsWithoutFilter(GetS(8000032))
    elseif code == 3 then --语音读取开始
        SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_START, SandboxContext():SetData_String("code", code..""))
    elseif code == 4 then --切后台
        SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_FAIL, SandboxContext():SetData_String("code", code..""))
    else
        print("ReturnRecognizeVoiceData recongize failed, error", code)
    end
end

-- 麦克风音量
function ReturnMicDbData(data)
    if not data then
        return
    end
    SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_SPEECH_RECOGNIZE_MICDB, SandboxContext():SetData_String("db", data))
end
