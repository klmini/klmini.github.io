function FestivalActivitiesEventOnTrigger(player,world,eventType,toolId, posx, posy, posz , face)
    if eventType == "eatfood" then  --食用食物
        if toolId == 11901 then --庆典月饼
            Mooncake_OnUse()
        end
    elseif eventType == "interactBlock" then
        local blockId = world:getBlockID(posx,posy,posz)
        if blockId == 1146 then --庆典花灯
            if toolId == 817 or toolId == 11055 then
                player:createFirework(11,100);
                world:destroyBlock(posx,posy,posz,false);
            end
        end
    end 
end

function Mooncake_OnUse()
    local moonCakeRewards ={}
    local activities = ns_data.server_advert_config.festivalActivities and ns_data.server_advert_config.festivalActivities.activities
    for _, value in ipairs(activities) do
        if value.name == '中秋活动' then
            moonCakeRewards =value.moonCakeRewards
        end
    end
    
    local tem = 0
    for _, value in pairs(moonCakeRewards) do
        tem = tem + value[3]
    end

    local rand = math.random(tem)
    local itemid = -1;
    local count = 0
    tem = 0;
    for _, value in pairs(moonCakeRewards) do
        tem = tem + value[3]
        if rand < tem then
            itemid = value[1]
            count = value[2]
            break
        end
    end

    if itemid ~= -1 and count ~= 0 then
        ClientBackpack:addItem(itemid, count);
        ShowGameTips("受到了月亮的祝福，获得了#G"..DefMgr:getItemDef(itemid).Name, 3,nil,nil ,false,true)
    end
end


IsPlayingErhu = false
StartPlayErhuEffectTime = 0;

function PlayErhuEffect(player)
    StartPlayErhuEffectTime = os.time();
    if IsPlayingErhu == false then
        player:playSoundByTrigger("item.11900.urheen", 1.0, 1.0,true)
        IsPlayingErhu = true
        DelayStopPlayErhuEffect(player)
    end
end

function DelayStopPlayErhuEffect(player)
    threadpool.delay(this,1.2,function ()
        if os.time() - StartPlayErhuEffectTime >= 1 then 
            player:stopSoundByTrigger("item.11900.urheen")
            IsPlayingErhu = false
        else
            DelayStopPlayErhuEffect(player)
        end
    end)
end