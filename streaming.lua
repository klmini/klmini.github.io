
_G.Streaming = {
    appId = "8af456cedc954cb5bb75dbb76b8ce356",
    agoraToken = "",
    channelName = "",
    hadCreateEngine = false,
    hadJoinChannel =false,
    uid = 0,
    mapConfig = nil,
    lastJoinTime = 0,

    createAgoraEngine = function()
        print('Streaming createAgoraEngine')
        if StreamingMgr  and not Streaming.hadCreateEngine then
            if ns_data.server_advert_config and ns_data.server_advert_config.AgoraConfig then 
                local agoraConfig = ns_data.server_advert_config.AgoraConfig
                Streaming.appId = agoraConfig.appId;
            end
            Streaming.hadCreateEngine = StreamingMgr:getInstance():createAgoraEngine(Streaming.appId)
        end
    end,

    enterWorld = function ()
        local mapid = CurWorld:getOWID()..''
        print('Streaming enterWorld',type(mapid), CurWorld:getOWID())
        print(ns_data.server_advert_config.AgoraConfig)
        if ns_data.server_advert_config and ns_data.server_advert_config.AgoraConfig then 
            local agoraConfig = ns_data.server_advert_config.AgoraConfig
            for k, v in pairs(agoraConfig) do
                if type(v) == "table" and type(v.mapid)=="string" and v.mapid == mapid then
                    Streaming.mapConfig = v;
                    break;
                end
            end
        end
    end,

    joinChannel = function()
        print('Streaming joinChannel')
        local token = Streaming.agoraToken;
        local channelName = Streaming.channelName;
        local uid = Streaming.uid;

        if StreamingMgr and type(token)=="string" and token ~="" then
            if  Streaming.hadCreateEngine then
                StreamingMgr:getInstance():joinChannel(token,channelName , "", uid);
                Streaming.hadJoinChannel =  true;
            end
		end
    end,

    leaveChannel = function ()
        if Streaming.hadJoinChannel then
            if StreamingMgr then
                StreamingMgr:getInstance():leaveChannel();
            end
            Streaming.hadJoinChannel = false;
        end
    end,

    leaveWorld = function ()
        print('Streaming leaveWorld')
        Streaming.leaveChannel();
        Streaming.mapConfig = nil;
    end,

    getToken = function(callback)
        local time = os.time()*1000;
        local str = string.format("channelName=%s&uid=%s&role=2&timestamp=%s&secretKey=0pYPsTwMkrHLjfqCqVt9OQ8y9SDpI4KY",Streaming.channelName,Streaming.uid,time)
        print('Streaming sign str',str)
        local sign =  gFunc_getmd5(str)
        local a,b,c = get_login_sign()
        local env = get_game_env();
        local host = "http://124.71.34.45:16932";
        if env == 0 then
            host = "http://agg.mini1.cn"
        end

        local url = host.."/rtc/fetchRtcToken?channelName="..Streaming.channelName..
        "&uid="..Streaming.uid.."&role=2".."&timestamp="..time..
        "&sign="..sign..
        "&miniSign="..a.."_"..c;

        print('Streaming getToken url:',url)
        ns_http.func.rpc_string(url, function (ret)
            if not ret then return end;
            ret = JSON:decode(ret)
            if  ret.meta.code == 0 then
                Streaming.agoraToken = ret.data.agoraToken;
                if callback then callback() end
            end
        end)
    end,
}

function ActorVideoUpdate(actorVideo)
    if not Streaming.hadCreateEngine or not Streaming.mapConfig then return end;
	local x,y,z = 0,0,0
    x,y,z = actorVideo:getPosition(x,y,z)
    x = x/100;
    y = y/100;
    z = z/100;
    local displayPos = { x = x,y = y,z = z}
    local x1,y1,z1 = 0,0,0
    x1,y1,z1 = CurMainPlayer:getPosition(x1,y1,z1)
    x1 = x1/100;
    y1 = y1/100;
    z1 = z1/100;
    local pos = {x = x1, y = y1,z = z1}

    local getDistance = function( pos1, pos2)
        local distance = math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x) + (pos1.y-pos2.y)*(pos1.y-pos2.y) + (pos1.z-pos2.z)*(pos1.z-pos2.z))
        return distance
    end

    local dis = getDistance(pos, displayPos)
    if dis > Streaming.mapConfig.maxPlayDis then 
        Streaming.leaveChannel()
    elseif os.time() - Streaming.lastJoinTime > 3 and not Streaming.hadJoinChannel then --每次进入频道都要间隔3秒以上
        for k, v in pairs(Streaming.mapConfig) do
            if type(v) == "table" and type(v.ActorVideoPos) == "table" and getDistance(displayPos,v.ActorVideoPos) < Streaming.mapConfig.maxPlayDis then
                Streaming.channelName = v.channelName;
                Streaming.uid = AccountManager:getUin()%100000000;
                Streaming.getToken(function ()
                    Streaming.joinChannel();
                end)
                Streaming.lastJoinTime = os.time();
                break;
            end
        end

    end
end