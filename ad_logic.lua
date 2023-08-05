
--[[
	广告需求已经重构，新接入的广告不再走此逻辑
--]]
t_ad_data = {
	curADCallBack = nil, --播放成功的回调
	curAdCallData = nil,
	curADFailedCallBack = nil, --播放失败的回调
	onlineRoomFailNum = 0,
	positionId = 0;
	browserPositionId = 0; -- 当前播放广告的广告位id
	
	lostConnectPosId = 0; --只使用在断链时判断播放的广告为8号和6号

	exchangeNpcTrade = {},
    fruitInfo = {},
    
	reviveAdPositionData = {}; --播放广告复活广告位数据
	
    triggerID = {}; --触发器广告
	entryType = ""; --商店广告的来源UI（用于溯源）

	--[[
	Author: sundy
	EditTime: 2021-08-21
	Description: 
		new add
			新增单独的方法获取广告的加载状态
	--]]
	getAdLoadStatus = function(position)
		if AccountManager.ad_position_info  then
			local ad_info = AccountManager:ad_position_info(position);
			if ad_info then
				return Advertisement:hasLoaded(ad_info.platform_id, tonumber(position))
			end
		end
		return false
	end,

	--[[
	Author: sundy
	EditTime: 2021-08-21
	Description: 
		add param
		bIgnoreAdLoad: 
			忽略广告是否加载成功 
			true->忽略 
			false->不忽略

		modiffy line:
			-- old
			if not Advertisement:hasLoaded(ad_info.platform_id, tonumber(position)) then
			-- change to
			if not Advertisement:hasLoaded(ad_info.platform_id, tonumber(position)) and (not bIgnoreAdLoad) then

		change line:
	--]]
	canShow = function(position, extraInfo, bIgnoreAdLoad)
		local print = Android:Localize(Android.SITUATION.ADVERTISEMENT_101);
		local ad_info = nil;

		if AccountManager.ad_position_info then
			ad_info = AccountManager:ad_position_info(position);
		end

		print("kekeke ad_info", ad_info);
		if ad_info then
			t_ad_data.positionId = position;

			-- 开发者广告作弊惩罚 codeby:fym
			if position > 100 and position < 200 then
				local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
				if authorUin and mapId and not GetInst("AdService"):IsDeveloperAdCanShow(authorUin, mapId) then
					print("kekeke this map cannot show developer ad, cause IsDeveloperAdCanShow return false")
					return false
				end
			end

			if not Advertisement:hasLoaded(ad_info.platform_id, tonumber(position)) and (not bIgnoreAdLoad) then
				print("kekeke ad_info not hasLoaded", t_ad_data.positionId );
				return false;
			end

			if ad_info.iscoding or ad_info.position_id == nil or ad_info.platform_id == nil then
				print("kekeke ad_info iscoding or position_id or platform_id nil ");
				return false;
			else
				if extraInfo then
					if position == 4 then		--npc交易兑换物品
						if extraInfo.isLock then
							return false;
						else
							if extraInfo.tradeType == 1 then	--星星[Desc5]
								local rewardValue = 5;	--默认奖励5个星星
								if ad_info.extra and ad_info.extra.type == 1 then
									rewardValue = ad_info.extra.value
								end
								local getNum = math.floor(rewardValue/(extraInfo.price/extraInfo.num));
								if getNum > 0 then
									return true;
								end
							else
								return false;
							end
						end
					elseif position == 7 then	--分享获得迷你豆
						return true;
						--[[
						if extraInfo.adTimes >= 3 then
							return false;
						else
							return true;
						end
						]]
					end
				else
					if position == 6 then 	--联机失败
						local condition = 2;
						if ad_info.extra and ad_info.extra.type == 3 then
							condition = ad_info.extra.condition;
						end
						print("kekeke position", t_ad_data.onlineRoomFailNum, condition)
						if t_ad_data.onlineRoomFailNum >= condition then	--只要计数满足条件，不管玩家选择看不看广告，都清掉计数
							t_ad_data.onlineRoomFailNum = 0;
							return true;
						else
							return false;
						end
					else
						return true;	
					end
				end
			end
		else
			return false;
		end
	end,

	getWatchADIDAndType = function(position)
		local ad_info = AccountManager:ad_position_info(position);
		--[[
		if ad_info.platform_id == 1001 then	--NGA广告
			if ad_info.type == 1 then		--视频广告
				return "NGAVideoAd";
			end
		elseif ad_info.platform_id == 1002 then	--玉米广告
			if ad_info.type == 1 then		--视频
				return "YumiMediaAd";
			end
		end
		]]

		if ad_info and ad_info.type and ad_info.platform_id then
			local type = tostring(ad_info.type);
			return type, ad_info.platform_id;
		else
			print("kekeke ad_type or ad_platform_id is nil");
			return nil,nil;
		end
	end,

	-- 触发器广告播放顺序排序
	SortTriggerAD  = function (positionId)
		if #t_ad_data.triggerID ~= 0 then return end

		-- local positionId = {102 ,106,107}
		local ad_info = nil
		if AccountManager.ad_position_info then
			for index = 1, #positionId do
				ad_info = AccountManager:ad_position_info(positionId[index])
				if ad_info then
					if ad_info.trigger_priority then
						table.insert(t_ad_data.triggerID,ad_info)
					else
						t_ad_data.triggerID = positionId
						return
					end
				end 
			end

			table.sort(t_ad_data.triggerID , function (a,b)
				local r = false
				local proa = a.trigger_priority > 0 and a.trigger_priority or 100000000
				local prob = b.trigger_priority > 0 and b.trigger_priority or 100000000
				r = proa < prob
				if proa == prob then
					r = tonumber(a.position_id) < tonumber(b.position_id)
				end
				return r
			end)
		end
	end,

	-- 获取当前最优先的广告ID
	getCurrentTriggerID = function ()
		local finish = true
		if AccountManager.ad_position_info  then
			for key, value in pairs(t_ad_data.triggerID) do
				local ad_info = AccountManager:ad_position_info(value.position_id)
				if ad_info then
					local limit = ad_info.num_total
					local count = ad_info.finish.count
					if count < limit then
						finish = false
					end 
				end
	
				if tonumber(value.position_id) == 107 then -- 107 H5广告不用加载
					return finish,107
				end
	
				if t_ad_data.canShow(tonumber(value.position_id)) then
					return finish, tonumber(value.position_id)
				end
			end
		end
		return finish,nil
	end,

	--获取按优先级排序的广告位列表
	--[[
	t_adPosList = {
		{pos=26, trigger_priority=999999999},
		{pos=16, trigger_priority=999999999},
		{pos=14, trigger_priority=999999999},
	},
	]]
	getSortAD = function(t_adPosList)
		local ad_info = nil
		local t = {};
		if AccountManager.ad_position_info then
			for index = 1, #t_adPosList do
				ad_info = AccountManager:ad_position_info(t_adPosList[index].pos)
				print("kgq getCanShowAdPosByList getSortAD", ad_info);
				if ad_info and ad_info.trigger_priority then
					t_adPosList[index].trigger_priority = ad_info.trigger_priority;
				else 
					t_adPosList[index].trigger_priority = 999999999;
				end 
			end

			table.sort(t_adPosList , function (a,b)
				return  a.trigger_priority <= b.trigger_priority
			end)

			return t_adPosList;
		end

		return t_adPosList;
	end,

	-- 获取广告位列表里最优先并且能播放的广告ID
	getCanShowAdPosByList = function (t_adPosList, needSort)
		print("kgq getCanShowAdPosByList t_adPosList", t_adPosList);
		if needSort then
			t_adPosList = t_ad_data.getSortAD(t_adPosList);
		end
		if AccountManager.ad_position_info  then
			for i=1, #t_adPosList do
				local adPos = tonumber(t_adPosList[i].pos);
				if adPos then
					local ad_info = AccountManager:ad_position_info(adPos)
					print("kgq getCanShowAdPosByList ad_info", ad_info);
					if ad_info and t_ad_data.canShow(adPos) then
						return adPos;
					end
				end
			end
		end

		return nil
	end,
	
}

function GetFromMapid()
	-- 修改成新的取fromid方式
	if WorldMgr and WorldMgr.getFromWorldID then
		return WorldMgr:getFromWorldID()
	end

	assert(false)
	
	local mapid = 0
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local owid = CurWorld:getOWID()
		local desc = AccountManager:findWorldDesc(owid)
		if desc then
			mapid = (desc.fromowid == 0) and desc.worldid or desc.fromowid
		end
	else
		mapid = DeveloperFromOwid
	end
	return mapid
end

function StatisticsAD(type, position, reward,authorUin,mapId,itemId)
	Log("StatisticsAD type:" .. type..", position:"..(position or ''))
	local ad_info = nil;
	if AccountManager.ad_position_info then
		ad_info = AccountManager:ad_position_info(position);
	end
	if ad_info == nil then
		Log("StatisticsAD ad_info is nil")
		return 
	end

	Log("StatisticsAD ad_info = "..(table.tostring and table.tostring(ad_info) or ''))
	-- if authorUin and mapId and itemId then
	-- 	print("==============authorUin,mapId,itemId=========",authorUin,mapId,itemId)
	-- end

	if (type == 'show' or type == 'againshow') and ad_info.platform_id then -- 按钮显示
		local static_id = 1300
		local position_id = ad_info.position_id
		if type == 'againshow' then -- 再次观看按钮出现
			if position == 27 then
				position_id = 40
			elseif position == 9 then
				position_id = 41
			elseif position == 26 then
				position_id = 42
			end
		end
		if authorUin and mapId and itemId then
			--statisticsGameEvent(1300, "%s", ad_info.platform_id, "%s", ad_info.position_id,"%d",authorUin,"%d",mapId,"%d",itemId)
			statisticsGameEventNew(static_id,ad_info.platform_id,position_id,authorUin,mapId,itemId,GetCurrentCSRoomId())
		else
            --statisticsGameEvent(1300, "%s", ad_info.platform_id, "%s", ad_info.position_id)
            -- 105广告位埋点特殊处理，增加上报作者uin和地图id
            if position == 105 then
                statisticsGameEventNew(static_id,ad_info.platform_id,position_id,authorUin,mapId,"",GetCurrentCSRoomId())
            else
                statisticsGameEventNew(static_id,ad_info.platform_id,position_id,"","","",GetCurrentCSRoomId())
            end
		end
		if isSuportNativeAdChannel() and (ad_info.position_id == 15 or ad_info.position_id == "15") then
			SdkAdShow()
		end
	elseif (type == 'onclick' or type == 'againonclick') and ad_info.platform_id then
		local static_id = 1301
		local position_id = ad_info.position_id
		if type == 'againonclick' then -- 再次观看按钮点击
			if position == 27 then
				position_id = 40
			elseif position == 9 then
				position_id = 41
			end
		end
		if authorUin and mapId and itemId then
			--statisticsGameEvent(1301, "%s", ad_info.platform_id, "%s", ad_info.position_id,"%d",authorUin,"%d",mapId,"%d",itemId);
			statisticsGameEventNew(static_id, ad_info.platform_id, position_id,authorUin,mapId,itemId,GetCurrentCSRoomId());
		else
            --statisticsGameEvent(1301, "%s", ad_info.platform_id, "%s", ad_info.position_id );
            -- 105广告位埋点特殊处理，增加上报作者uin和地图id
            if position == 105 then
                statisticsGameEventNew(static_id,ad_info.platform_id,position_id,authorUin,mapId,"",GetCurrentCSRoomId())
            else
                statisticsGameEventNew(static_id,ad_info.platform_id,position_id,"","","",GetCurrentCSRoomId())
            end
		end
	elseif (type == 'finish' or  type == 'againfinish') and ad_info.platform_id then
		local rewardName = nil;
		local rewardNum = nil;
		if ad_info.extra then
			if ad_info.extra.type == 1 or ad_info.extra.type == '1' then
				rewardName = 'npc_trade';	
				if reward then
					rewardName = rewardName..reward.Name;
					rewardNum = reward.Num;
				end
			elseif ad_info.extra.type == 2 or ad_info.extra.type == '2' then
				rewardName = 'Shortening_fruit_growth_time';
				rewardNum = ad_info.extra.value;
			elseif ad_info.extra.type == 3 or ad_info.extra.type == '3' then
				rewardName = 'Online_Failure_Reward';
				rewardNum = ad_info.extra.value;
			elseif ad_info.extra.type == 4 or ad_info.extra.type == '4' then
				rewardName = 'Situ_Revive';
			elseif ad_info.extra.type == 5 or ad_info.extra.type == '5' then
				rewardName = 'NPC_Refresh_Goods';
			elseif ad_info.extra.type == 6 or ad_info.extra.type == '6' then
				rewardName = 'Share_Reward_MiniBean';
			end
		end
		local static_id = 1302
		local position_id = ad_info.position_id
		if type == 'againfinish' then -- 再次观看回调
			if position == 27 then
				position_id = 40
			elseif position == 9 then
				position_id = 41
			end
		end
		if rewardName and rewardNum then
			if authorUin and mapId and itemId then
				--statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", ad_info.position_id, "%s", rewardName, "%d", rewardNum,"%d",authorUin,"%d",mapId,"%d",itemId);
				statisticsGameEventNew(static_id,ad_info.platform_id, position_id, rewardName, rewardNum,authorUin,mapId,itemId,GetCurrentCSRoomId());
			else
				--statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", position_id, "%s", rewardName, "%d", rewardNum);
				statisticsGameEventNew(static_id,ad_info.platform_id,position_id,rewardName,rewardNum,"","","",GetCurrentCSRoomId());
			end
		elseif rewardName then
			if authorUin and mapId and itemId then
				--statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", position_id, "%s", rewardName,"%d",authorUin,"%d",mapId,"%d",itemId);
				statisticsGameEventNew(static_id,ad_info.platform_id,position_id,rewardName,"",authorUin,mapId,itemId,GetCurrentCSRoomId());
			else
				--statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", position_id, "%s", rewardName);
				statisticsGameEventNew(static_id,ad_info.platform_id,position_id,rewardName,"","","","",GetCurrentCSRoomId());
			end
		else
			if authorUin and mapId and itemId then
				--statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", position_id,"%d",authorUin,"%d",mapId,"%d",itemId);
				statisticsGameEventNew(static_id, ad_info.platform_id,position_id,"","",authorUin,mapId,itemId,GetCurrentCSRoomId());
			else
                --statisticsGameEvent(1302, "%s", ad_info.platform_id, "%s", position_id);
                -- 105广告位埋点特殊处理，增加上报作者uin和地图id
                if position == 105 then
                    statisticsGameEventNew(static_id, ad_info.platform_id, position_id, "","", authorUin, mapId, "", GetCurrentCSRoomId())
                else
                    statisticsGameEventNew(static_id, ad_info.platform_id, position_id,"","","","","",GetCurrentCSRoomId());
                end
			end
		end
	elseif type == 'load' and ad_info.platform_id then
		--print("================real 1 101 1303,authorUin,mapId,itemId================",authorUin,mapId,itemId)
		if authorUin and mapId and itemId then
			--statisticsGameEvent(1303, "%s", ad_info.platform_id, "%s", ad_info.position_id,"%d",authorUin,"%d",mapId,"%d",itemId)
			-- 20200205：业务数据量过大，关闭上报
			-- statisticsGameEventNew(1303, ad_info.platform_id,ad_info.position_id,authorUin,mapId,itemId)
		else
			--statisticsGameEvent(1303, "%s", ad_info.platform_id, "%s", ad_info.position_id)
			-- 20200205：业务数据量过大，关闭上报
			-- statisticsGameEventNew(1303,ad_info.platform_id,ad_info.position_id,"","","")
		end
	elseif type == 'ready' and ad_info.platform_id then
		if authorUin and mapId and itemId then
			--statisticsGameEvent(1304, "%s", ad_info.platform_id, "%s", ad_info.position_id,"%d",authorUin,"%d",mapId,"%d",itemId)
			-- 20200205：业务数据量过大，关闭上报
			-- statisticsGameEventNew(1304,ad_info.platform_id,ad_info.position_id,authorUin,mapId,itemId)
		else
			--statisticsGameEvent(1304, "%s", ad_info.platform_id, "%s", ad_info.position_id)
			-- 20200205：业务数据量过大，关闭上报
			-- statisticsGameEventNew(1304,ad_info.platform_id,ad_info.position_id,"","","")
		end
		threadpool:notify('ad.info.loadresult')  --added by nanlin 广播广告加载状态有变动
	elseif type == 'loadfail' and ad_info.platform_id then --added by nanlin 预加载失败通知
		threadpool:notify('ad.info.loadresult')  --added by nanlin 广播广告加载状态有变动
	end
end

--[[
--开发者商城商品看广告
function OnReqWatchADDeveloperShop(data,btnName,entryType)
	Log("OnReqWatchADDeveloperShop")
	if btnName == nil or btnName == 'right' then
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(101);
		if curWatchADType then
			t_ad_data.curADCallBack = OnResWatchADDeveloperShop;
			t_ad_data.entryType = entryType;
			local authUin,mapId,itemId = getCurItemSimpleInfos()
			StatisticsAD('load',101,nil,authUin,mapId,itemId)
			local ret = Advertisement:request(curWatchADType,id,101)

			if entryType == "Pass" then
				Advertisement:onRespWatchAdForAudit(1001);
				return;
			end
			if ClientMgr:getApiId() == 999 then
				-- SVN端看广告直接下发奖励
				local uin = AccountManager:getUin() or 0;
				if DeveloperAdCheckerUser(uin) then
					Advertisement:onRespWatchAdForAudit(1001);
					Log("999 developer ad store success")
				end
				return;
			end

			if ret ~= 0 and ret ~= 2 then
				StatisticsAD('ready',101,nil,authUin,mapId,itemId)
				--新埋点，根据不同来源做不同上报
				if mapId == nil or mapId == 0 then
					mapId = G_GetFromMapid()
				end
				local extra = {cid = tostring(mapId), standby3 = 101}
				if "DeveloperStore" == t_ad_data.entryType then
					standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
				end
				if "TopPurchaseInMap" == t_ad_data.entryType then
					standReportEvent("1003", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
				end
				if "TopPurchaseInMapOnline" == t_ad_data.entryType then
					standReportEvent("1001", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
				end
			end
		end
	end
end

function OnResWatchADDeveloperShop()
	Log("OnResWatchADDeveloperShop")
	DeveloperStoreAdGetItem(false,t_ad_data.entryType)
	getglobal("DeveloperStoreBuyItemFrame"):Hide();
end

--NPC商城商品看广告
function OnReqWatchADNpcShop(data,btnName)
	Log("OnReqWatchADNpcShop")
	if btnName == nil or btnName == 'right' then
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(109);
		if curWatchADType then
			t_ad_data.curADCallBack = OnResWatchADNpcShop;
			local authUin,mapId,itemId = getCurItemSimpleInfos()
			StatisticsAD('load',109,nil,authUin,mapId,itemId)
			local ret = Advertisement:request(curWatchADType,id,109)

			if ClientMgr:getApiId() == 999 then
				-- SVN端看广告直接下发奖励
				NpcShopAdGetItem()
				getglobal("NpcShopBuyFrame"):Hide()
				return;
			end

			if ret ~= 0 and ret ~= 2 then
				StatisticsAD('ready',109,nil,authUin,mapId,itemId)
				--新埋点
				if mapId == nil or mapId == 0 then
					mapId = G_GetFromMapid()
				end
				local extra = {cid = tostring(mapId), standby1 = 109}
				standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
			end
		end
	end
end

function OnResWatchADNpcShop()
	Log("OnResWatchADNpcShop")
	NpcShopAdGetItem()
	getglobal("NpcShopBuyFrame"):Hide();
	--新埋点
	local extra = {cid = tostring(GetFromMapid()), standby1 = 109}
	standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_complete", extra)
end

--开发者通行证看广告
function OnReqWatchADGetPassPort(data, btnName)
	if btnName == nil or btnName == 'right' then
		-- 鸿蒙渠道
		if ClientMgr and ClientMgr:getApiId() == 5 then
			ShowGameTips(GetS(100512), 3)
			return
		end
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(103);
		if curWatchADType then
			t_ad_data.curADCallBack = OnRespWatchADGetPassPort
			local authUin,mapId,itemId = getCurItemSimpleInfos()
			StatisticsAD('load', 103, nil, authUin, mapId, itemId)
			local ret = Advertisement:request(curWatchADType, id, 103)

			if ClientMgr:getApiId() == 999 then
				-- SVN端看广告直接下发奖励
				local uin = AccountManager:getUin() or 0;
				if DeveloperAdCheckerUser(uin) then
					Advertisement:onRespWatchAdForAudit(1001);
					Log("999 developer ad passport success")
				end
				return;
			end

			if ret ~= 0 and ret ~= 2 then
				StatisticsAD('ready', 103, nil, authUin, mapId, itemId)
				AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_play", {cid=tostring(mapId), standby3 = 103})--新埋点
			end
		end
	end
end

function OnRespWatchADGetPassPort()
	DeveloperStoreAdGetItem(true,DeveloperStoreAdGetItem)
	local authUin,mapId,itemId = getCurItemSimpleInfos()
	-- threadpool:work(function ()
	-- 	local adinfo = {
	-- 		uin = authUin,
	-- 		map_id = mapId,
	-- 		id = itemId,
	-- 	}
	-- 	AccountManager:ad_finish(103, adinfo)
	-- end)
	StatisticsAD('finish', 103, nil, authUin, mapId, itemId)
	AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_complete", {cid=tostring(mapId), standby3 = 103})--新埋点
end

--]]

function PcTriggerAdFinish(adid)
	t_ad_data.curADCallBack = nil;
	t_ad_data.curADFailedCallBack = nil;
	local mapid = GetFromMapid()
	SetPlayerPurchaseFlag(true, 4, 1);
	StatisticsAD('finish', adid, nil, '', mapid, '');
	local ret = AccountManager:ad_finish(adid,StatisticsParam or {})
	if ret == ErrorCode.OK then
		if t_ad_data.successCallBack then
			t_ad_data.successCallBack();
		end
	else
		if t_ad_data.failedCallBack then
			t_ad_data.failedCallBack(ret);
		end
	end
end

-- 触发器广告提示新旧方式的控制开关
function ad_trigger_tip_switch()
	local is_trigger_tip_on = false -- 默认旧的提示
	if ns_version then
		is_trigger_tip_on = check_apiid_ver_conditions(ns_version.ad_trigger_tips_switch, false)
	end
	return is_trigger_tip_on
end

--触发器播放广告, 102/107号广告
function TriggerToPlayAD(adid, StatisticsParam, SuccessCallback, failedCallBack)
	local result = false
	local is_ad_trigger_tip_on = ad_trigger_tip_switch()

	local success_callBack = function()
		print("success_callBack ret: ");
		t_ad_data.curADCallBack = nil;
		t_ad_data.curADFailedCallBack = nil;
		local mapid = GetFromMapid()
		SetPlayerPurchaseFlag(true, 4, 1);
		StatisticsAD('finish', adid, nil, '', mapid, '');

		if StatisticsParam then
			StatisticsParam.mapid = tostring(mapid);
		end
		local ret = AccountManager:ad_finish(adid, StatisticsParam or {})
		print("AccountManager:ad_finish: ret: ", ret);
		print("AccountManager:ad_finish: ErrorCode.OK:", ErrorCode.OK);
		if ret == ErrorCode.OK then
			if SuccessCallback then
				SuccessCallback();
			end
		else
			if failedCallBack then
				failedCallBack(ret);
			end
		end
	end
	local failed_callBack = function(ret)
		print("failed_callBack ret: ",ret);
		t_ad_data.curADCallBack = nil;
		t_ad_data.curADFailedCallBack = nil;
		if is_ad_trigger_tip_on then
			ShowGameTips(GetS(32002))
			if failedCallBack then
				failedCallBack();
			end
		else
			MessageBox(4, GetS(32002), function()
				if failedCallBack then
					failedCallBack();
				end
			end)
		end
	end

	-- if ClientMgr:getApiId() == 999 then
	-- 	-- SVN端看广告直接下发奖励
	-- 	t_ad_data.curADCallBack = success_callBack;
	-- 	t_ad_data.curADFailedCallBack = failed_callBack;
	-- 	local uin = AccountManager:getUin() or 0;
	-- 	if DeveloperAdCheckerUser(uin) then
	-- 		Advertisement:request(1, 1018, adid);
	-- 		Advertisement:onRespWatchAdForAudit(1001);
	-- 		Log("999 developer ad trigger success")
	-- 	end
	-- 	return;
	-- end

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(adid);
	if  curWatchADType then
		t_ad_data.curADCallBack = success_callBack;
		t_ad_data.curADFailedCallBack = failed_callBack;
		local mapid = GetFromMapid()
		StatisticsAD('onclick', adid, nil, '', mapid, '')
		if ClientMgr:isPC() then
			if adid == 106 then
				t_ad_data.successCallBack = SuccessCallback
				t_ad_data.failedCallBack = failedCallBack
				GetInst("UIManager"):Open("PcAdvertisement",{from = "trigger"})
			end
			-- local uin = AccountManager:getUin() or 0;
			-- if DeveloperAdCheckerUser(uin) then
			-- 	--Advertisement:request(1, 1018, adid);
			-- 	Advertisement:onRespWatchAdForAudit(1001);
			-- 	Log("999 developer ad trigger success")
			--	success_callBack()
			--end
		else
			if adid == 107 then -- 107 H5广告直接打开链接
				local addinfo = AccountManager:ad_position_info(adid)
				local url = nil
				if addinfo and addinfo.AD_URL and #addinfo.AD_URL > 0 then
					local ok, json = pcall(JSON.decode, JSON, addinfo.AD_URL)
					if ok then
						local tab = {}
						for key, value in pairs(json) do
							table.insert(tab, value)
						end
						local len = #json
						if #tab == 1 then
							url = tab[1]
						else
							url = tab[math.random(1,#tab)]
						end
					end 
				end
				if url then
					g_openBrowserUrlAuth(url)
					success_callBack()
					result = true
				else
					if is_ad_trigger_tip_on then
						ShowGameTips(GetS(32002))
						failedCallBack()  -- 获取广告失败 无可打开的H5广告页
					else
						MessageBox(4, GetS(32002), function() failedCallBack() end)
					end
					failed_callBack()
				end
			else
				Advertisement:request(curWatchADType, id, adid)
				result = true
			end
		end
	else
		--无广告
		if curWatchADType == nil then
			if is_ad_trigger_tip_on then
				ShowGameTips(GetS(32003))
				if failedCallBack then
					failedCallBack();
				end
			else
				MessageBox(4, GetS(32003), function()
					if failedCallBack then
						failedCallBack();
					end
				end)
			end
		else
			failed_callBack()
		end
	end
	return result
end

--触发器播放广告, 102/107号广告(带确认框)
function TriggerToPlayADWithMsgbox(adname, _successCallback, _failedCallBack, msg, triggerID)
	--直接发放广告且不上报回调
	local successCallbackWithoutReport = function ()
		print("TriggerToPlayADWithMsgbox successCallback")
		if _successCallback then
			_successCallback()
		end
	end
	if ns_version.triggerADSwitch and check_apiid_ver_conditions(ns_version.triggerADSwitch) and triggerID == 3160001 then--xyang20211227开关打开，屏蔽所有触发器广告，直接发放物品
		successCallbackWithoutReport()
		ShowGameTips(GetS(100802,adname),3)
		--埋点
		local uin = AccountManager:getUin() or 0;
		local gameType = ClientCurGame:isHost(uin) and "1003" or "1001"--1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
		local exData = {cid=tostring(GetFromMapid())}
		standReportEvent(gameType, "AD_FREE_TIP", "-", "view", exData)
		return
	end        
	local bOpen = false
	if msg == '1120004' or msg == '1120001' or msg == '1120006' or msg == '1120007' then--'UI.Button.TouchBegin' or 'UI.Button.Click'--xyang20220310 UI按钮按下和松开时单独处理
		bOpen = true
	end
	if triggerID == 3160005 and not bOpen then--xyang20221214播放广告（新）时，只有UI按钮按下和松开时会播放广告
		return
	end

	if IsStandAloneMode("") then return end
	local uin = AccountManager:getUin() or 0;

	local failedCallBack = _failedCallBack or function() end

	local is_ad_trigger_tip_on = ad_trigger_tip_switch()
	local exData = {standby1 = msg or "", standby2 = 1, cid=tostring(GetFromMapid())}
	if is_ad_trigger_tip_on then
		exData.standby2 = 2 --新弹窗
	else
		exData.standby2 = 1
	end
	--1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
	local gameType = ClientCurGame:isHost(uin) and "1003" or "1001"
	print("TriggerToPlayADWithMsgbox", msg, gameType)
	local successCallback = function ()
		print("TriggerToPlayADWithMsgbox successCallback")
		if _successCallback then
			_successCallback()
		end
		exData.standby3 = t_ad_data.positionId
		standReportEvent(gameType, "AD_POPUP", "AdPlayButton", "ad_complete", exData)
	end
	
	-- 鸿蒙渠道
	if ClientMgr and ClientMgr:getApiId() == 5 then
		ShowGameTips(GetS(100512), 3)
		failedCallBack()
		return
	end

	if type(adname) ~= 'string' then
		ShowGameTips("ADError:adname is not string")
		failedCallBack()
		return
	end
	--PC
	if ClientMgr:isPC() then
		--if ClientMgr:getApiId() == 999 then
		--	-- SVN端直接下发奖励
		--	local mapid = GetFromMapid()
		--	local adinfo = {
		--		mapid = mapid,
		--		triggername = adname,
		--		cs_roomid = GetCurrentCSRoomId(),
		--	};
		--	MessageBoxFrame2:Open(2,GetS(4022),GetS(32001, adname), function(btn)
		--		if btn == 'right' then
		--			-- 不播放广告，立即成功
		--			successCallback()
		--		else
		--			failedCallBack()
		--		end
		--	end)
		--	return;
		--end
		-- 飘窗显示提示文字
		if CurMainPlayer  then
			CurMainPlayer:notifyGameInfo2Self(1, 0, 0, GetS(32004))
		end
		failedCallBack()
		return
	end

	-- 广告奖励名设置颜色，默认是黄色
	local colorAdName = adname or ""
	if not string.find(colorAdName, "#c", 1, true) then
		colorAdName = "#cFFDA0A" .. colorAdName
	end
	 -- 只处理广告名变色
	colorAdName = colorAdName .. "#n"

	-- 方便运营同学测试 pc端999渠道短号直接提示是否播放
	if ClientMgr:getApiId() == 999 and ClientMgr:isPC() and DeveloperAdCheckerUser(uin) then
		if is_ad_trigger_tip_on then
			-- 新提示
			-- TriggerAdInMap 和 TopPurchaseInMap 不同时显示
			-- GetInst("UIManager"):Close("TopPurchaseInMap");
			if GetInst("MiniUIManager"):IsShown("TopPurchaseInMapAutoGen") then
				GetInst("MiniUIManager"):CloseUI("TopPurchaseInMapAutoGen")
			end
			-- if IsUIFrameShown("TriggerAdInMap") then
			-- 	GetInst("UIManager"):GetCtrl("TriggerAdInMap"):CloseBtnClicked()
			-- end
			if GetInst("MiniUIManager"):IsShown("TriggerAdInMapAutoGen") then
				GetInst("MiniUIManager"):CloseUI("TriggerAdInMapAutoGen")
			end
			local paramAdInMap = {
				disableOperateUI = true,
				adname = colorAdName,
				okCall = successCallback,
				cancelCall = failedCallBack,
			}
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ugc_triggerAdInMap"})
			GetInst("MiniUIManager"):OpenUI("TriggerAdInMapMainFrame", "miniui/miniworld/ugc_triggerAdInMap", "TriggerAdInMapAutoGen", paramAdInMap)

			-- GetInst("UIManager"):FadeIn("TriggerAdInMap", {
			-- 	disableOperateUI = true,
			-- 	adname = colorAdName,
			-- 	okCall = successCallback,
			-- 	cancelCall = failedCallBack,
			-- }, 0.3, 12)
		else
			-- 旧提示
			MessageBoxFrame2:Open(2,GetS(4022),GetS(32001, colorAdName), function(btn)
				if btn == 'right' then
					-- 不播放广告，立即成功
					successCallback()
				else
					failedCallBack()
				end
			end)
		end

		return;
	end

	-- pc 只有106广告位
	if ClientMgr:isPC() then
		t_ad_data.SortTriggerAD({106})
	else
		t_ad_data.SortTriggerAD({102, 106, 107, 108})
	end

	if #t_ad_data.triggerID == 0  then
		if ClientMgr:isPC() then
			-- 弹窗确定，改成飘窗tip
			if is_ad_trigger_tip_on then
				ShowGameTips(GetS(32004))
				failedCallBack()
			else
				MessageBox(4, GetS(32004), function() 
					standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "click")
					failedCallBack() 
				end)
			end
			standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "view")
			return
		end
	end

	-- 无广告
	local finish, adid = t_ad_data.getCurrentTriggerID()
	exData.standby3 = adid or 999
	if finish then --次数已满
		-- 改成飘窗提示
		if is_ad_trigger_tip_on then
			ShowGameTips(GetS(32003))
			failedCallBack()
			standReportEvent(gameType, "AD_LIMIT_POPUP"	, "-", "view", exData)
		else
			MessageBox(4, GetS(32003), function() 
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "click")
				standReportEvent(gameType, "AD_LIMIT_POPUP", "ConfirmButton", "click", exData)
				failedCallBack() end)

			standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "view")
			standReportEvent(gameType, "AD_LIMIT_POPUP"	, "-", "view", exData)
			standReportEvent(gameType, "AD_LIMIT_POPUP", "ConfirmButton", "view", exData)
		end
		
		return
	end

	--广告数据获取失败
	if not adid or  not t_ad_data.getWatchADIDAndType(adid) then
		if is_ad_trigger_tip_on then
			ShowGameTips(GetS(32002))
			failedCallBack()
			standReportEvent(gameType, "AD_GET_FAIL", "-", "view", exData)
		else
			MessageBox(4, GetS(32002), function() 
				failedCallBack()
				standReportEvent(gameType, "AD_GET_FAIL", "ConfirmButton", "click", exData)
			end)
			standReportEvent(gameType, "AD_GET_FAIL", "-", "view", exData)
			standReportEvent(gameType, "AD_GET_FAIL", "ConfirmButton", "view", exData)
		end
		return
	end

	-- 上报信息
	local mapid = GetFromMapid()
	if mapid == 0 then
		ShowGameTips("ADError:mapid get failed")
		failedCallBack()
		return
	end

	local adinfo = {
		mapid = mapid,
		triggername = adname,
		cs_roomid = GetCurrentCSRoomId(),
	}

	local _extend_data = GetInst("ExternalRecommendMgr") and GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam() or nil;
	adinfo.extend_data = _extend_data;

	-- 播放弹框
	StatisticsAD('show', adid, nil, '', mapid, '');--运营数据埋点

	if is_ad_trigger_tip_on then
		-- TriggerAdInMap 和 TopPurchaseInMap 不同时显示
		-- GetInst("UIManager"):Close("TopPurchaseInMap")
		if GetInst("MiniUIManager"):IsShown("TopPurchaseInMapAutoGen") then
			GetInst("MiniUIManager"):CloseUI("TopPurchaseInMapAutoGen")
		end
		-- if IsUIFrameShown("TriggerAdInMap") then
		-- 	GetInst("UIManager"):GetCtrl("TriggerAdInMap"):CloseBtnClicked()
		-- end
		if GetInst("MiniUIManager"):IsShown("TriggerAdInMapAutoGen") then
			GetInst("MiniUIManager"):CloseUI("TriggerAdInMapAutoGen")
		end
		local paramAdInMap = {
			disableOperateUI = true,
			adname = colorAdName,
			okCall = function() 
				local ret = TriggerToPlayAD(adid, adinfo, successCallback, failedCallBack)
				standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
				if ret then
					standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
				end
			end,
			cancelCall = function ()
				failedCallBack()
				standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
			end,
		}
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ugc_triggerAdInMap"})
		GetInst("MiniUIManager"):OpenUI("TriggerAdInMapMainFrame", "miniui/miniworld/ugc_triggerAdInMap", "TriggerAdInMapAutoGen", paramAdInMap)

		-- GetInst("UIManager"):FadeIn("TriggerAdInMap", {
		-- 	disableOperateUI = true,
		-- 	adname = colorAdName,
		-- 	okCall = function() 
		-- 		local ret = TriggerToPlayAD(adid, adinfo, successCallback, failedCallBack)
		-- 		standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
		-- 		if ret then
		-- 			standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
		-- 		end
		-- 	end,
		-- 	cancelCall = function ()
		-- 		failedCallBack()
		-- 		standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
		-- 	end,
		-- }, 0.3, 12)

		standReportEvent(gameType, "AD_POPUP"	, "-", "view", exData)
		standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "view", exData)
		standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "view", exData)
	else
		MessageBoxFrame2:Open(2,GetS(4022),GetS(32001, colorAdName), function(btn)
			if btn == 'right' then
				-- 播放广告
				local ret = TriggerToPlayAD(adid,adinfo, successCallback, failedCallBack)
				standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
				if ret then
					standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
				end
			else
				failedCallBack()
				standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
			end
		end)

		standReportEvent(gameType, "AD_POPUP"	, "-", "view", exData)
		standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "view", exData)
		standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "view", exData)
	end
	
end

-- 触发器广告排队队列
_G.SSTriggerADList = {}
local function TriggerToPlayADPop()
	-- 移除当前播放广告
	table.remove(SSTriggerADList, 1)

	-- 播放排队广告
	local adinfo = SSTriggerADList[1]
	if adinfo then
		if IsAdUseNewLogic(102) then
			TriggerToPlayADWithMsgboxNew(adinfo.adname, adinfo.successCallback, adinfo.failedCallBack, adinfo.msg, adinfo.triggerID)
		else			
			TriggerToPlayADWithMsgbox(adinfo.adname, adinfo.successCallback, adinfo.failedCallBack, adinfo.msg, adinfo.triggerID)
		end
	end
end
function TriggerToPlayADPush(adname, successCallback, failedCallBack, msg, triggerID)
	-- 播放结束需要检测队列是否有广告在排队
	local funcSuccess = successCallback or function() end
	local funcFailed = failedCallBack or function() end
	successCallback = function()
		funcSuccess()
		TriggerToPlayADPop()
	end
	failedCallBack = function()
		funcFailed()
		TriggerToPlayADPop()
	end

	local curtime = os.time()

	-- 剔除掉超时的信息
	local idx = 1
	while idx <= #SSTriggerADList do
		if curtime - SSTriggerADList[idx].time >= 30 then -- 30s
			table.remove(SSTriggerADList, idx)
		else
			idx = idx + 1
		end
	end

	-- 插入队列
	local adinfo = {
		adname = adname,
		successCallback = successCallback,
		failedCallBack = failedCallBack,
		time = curtime,
		msg = msg,
		triggerID = triggerID,
	}
	table.insert(SSTriggerADList, adinfo)

	local is_ad_trigger_tip_on = ad_trigger_tip_switch()

	-- 已经在播放广告了
	if #SSTriggerADList > 1 then
		if is_ad_trigger_tip_on then
			-- 顶掉正在展示的
			TriggerToPlayADPop()
		end
		return
	end

	-- 播放触发器广告
	if IsAdUseNewLogic(102) then
		TriggerToPlayADWithMsgboxNew(adname, successCallback, failedCallBack, msg, triggerID)
	else
		TriggerToPlayADWithMsgbox(adname, successCallback, failedCallBack, msg, triggerID)
	end
end
--[[
--存档界面看广告领取奖励 21号广告位
function OnReqWatchAD21ReceiveAwards()
	print("OnReqWatchAD21ReceiveAwards")
	local function WatchAD21ReceiveAwards()
		print("call WatchAD21ReceiveAwards")
		StatisticsAD('finish', 21);
		AccountManager:ad_finish(21);
		LobbyFrame21ADBtnCanShow();
	end

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(21);
	if  curWatchADType then
		print( "curWatchADType=" .. curWatchADType .. ", id=" .. id )
		t_ad_data.curADCallBack = WatchAD21ReceiveAwards;
		StatisticsAD('onclick', 21);
		Advertisement:request(curWatchADType, id, 21)
	else
		print("no curWatchADType") --无广告
	end

end

-- H5广告
function getServerCanshowAdvertisement(positionId)
  	return t_ad_data.canShow(positionId);   	
end

function getDeveloperShopGoodCanshowAdvertisement(positionId)
	return t_ad_data.canShow(positionId);
end

function OnReqWatchAdBrowser(positionId)
	print("OnReqWatchAdBrowser");
	StatisticsAD('onclick', positionId);

	local ret = -1;
	if (t_ad_data.canShow(positionId)) then
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(positionId);
		if curWatchADType then
			t_ad_data.browserPositionId = positionId;
			t_ad_data.curADCallBack = OnRespWatchAdBrowser; 
			ret = Advertisement:request(curWatchADType, id, positionId);
		end
	end
	return ret;
end

-- 网页广告需要回到游戏界面才会走这个逻辑，不符合实际情况。网页改为窗口模式，解决此问题
function OnRespWatchAdBrowser()
	Log("OnRespWatchAdBrowser");
	AccountManager:ad_finish(t_ad_data.browserPositionId);
	StatisticsAD('finish', t_ad_data.browserPositionId);
	Advertisement:onPlaySuccess(t_ad_data.browserPositionId);
end

-- 特殊处理
-- function OnBrowserWatchAdCallBack(positionId)
-- 	Log("OnSuccessWatchAdBrowser");
-- 	AccountManager:ad_finish(positionId);
-- 	StatisticsAD('finish', positionId);
-- 	Advertisement:onPlaySuccess(positionId);
-- end
--]]

--福利界面插屏广告
function OnReqWatchADMarketActivity()
	Log("OnReqWatchADMarketActivity");

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(11);
	if curWatchADType then
		--插屏广告，调用接口算一次曝光
		StatisticsAD('show', 11);
		if AccountManager.ad_show then
			AccountManager:ad_show(11);
		end

		local rewardValue = AccountManager:ad_position_info(11).extra.value
		t_ad_data.curADCallBack = OnRespWatchADMarketActivity;
		Advertisement:request(curWatchADType, id, 11, rewardValue)
	end 
end

function OnRespWatchADMarketActivity()
	Log("OnRespWatchADMarketActivity");
	AccountManager:ad_finish(11);
end

--工坊等待下载页面插屏广告
function OnReqWatchADDownMap()
	Log("OnReqWatchADDownMap");

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(12);
	if curWatchADType then
		--插屏广告，调用接口算一次曝光
		StatisticsAD('show', 12);
		if AccountManager.ad_show then
			AccountManager:ad_show(12);
		end

		local rewardValue = AccountManager:ad_position_info(12).extra.value
		t_ad_data.curADCallBack = OnRespWatchADDownMap;
		Advertisement:request(curWatchADType, id, 12, rewardValue)
	end
end

function OnRespWatchADDownMap()
	Log("OnRespWatchADDownMap");
	AccountManager:ad_finish(12);
end

--[[
--资源商店解锁商品广告
function OnReqWatchADByResourceShopUnlockGoods(callBack)
	print("OnReqWatchADByResourceShopUnlockGoods");
	local ad_finishCallBack = function()
		StatisticsAD('finish', 104);
		AccountManager:ad_finish(104);
		if callBack then
			callBack()
		end
	end

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(104);
	if curWatchADType then
		t_ad_data.curADCallBack = ad_finishCallBack;
		StatisticsAD('onclick', 104);
		local ret = Advertisement:request(curWatchADType, id, 104)
		if ret ~= 0 and ret ~= 2 then
			StatisticsAD('ready', 104)
		end
	end
end

--]]

-- 判断渠道是否支持原生广告
function isSuportNativeAdChannel()
	Log("isSuportNativeAdChannel")
	local apiid = ClientMgr:getApiId();
	return (apiid == 36 or apiid == 13 or IsAndroidBlockark())
end


-- 获取广告相关参数
function getSdkAdInfo()
	Log("getSdkAdInfo")
	if ClientMgr:getApiId() == 13 then
		return Advertisement:getInfo(1004, 15);
	elseif ClientMgr:getApiId() == 36 then
		Log("Advertisement:getInfo")
		return Advertisement:getInfo(1010, 15);
	elseif IsAndroidBlockark() then
		return Advertisement:getInfo(1015, 15);
	end
	return "";
end

-- 广告显示
function SdkAdShow()
	Log("SdkAdShow")
	if ClientMgr:getApiId() == 13 then
		Advertisement:show(1004, 15);
	elseif ClientMgr:getApiId() == 36 then
		Log("Advertisement:show")
		Advertisement:show(1010, 15);
	elseif IsAndroidBlockark() then
		Advertisement:show(1015, 15);
	end
end

-- 广告在lua层被点击
function SdkAdOnClick()
	Log("SdkAdOnClick")
	if ClientMgr:getApiId() == 13 then
		Advertisement:click(1004, 15);
	elseif ClientMgr:getApiId() == 36 then
		Log("Advertisement:click")
		Advertisement:click(1010, 15);
	elseif IsAndroidBlockark() then
		Advertisement:click(1015, 15);
	end
	AccountManager:ad_finish(15);
end


--事件上报代理，推荐页的上报都走这,方便统一管理(埋点)
function AD_StandReportEvent(cID,oID,event,eventTb)
	local sceneID = "";--统一ID
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	standReportEvent(sceneID,cID,oID,event,eventTb)
end