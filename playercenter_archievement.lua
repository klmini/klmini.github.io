
--个人中心成就系统上报

local m_Archievement_TypeMap = {
--	taskId = "任务id" taskType = "任务类型标识"		, name = "任务名字"			参数列表: param_add:是否带增量 	param_count:是否带数量 	param_pos:是否带位置.
	{taskId = 1001, taskType = "daemon_hunter"			, name = "猎魔者"				,param_add = true, 		param_count = false, 	param_pos = true,	},
	{taskId = 1002, taskType = "treasures_hunter"		, name = "宝藏猎手"				,param_add = true, 		param_count = false, 	param_pos = true,	},
	{taskId = 1003, taskType = "survival_expert"		, name = "生存达人"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1004, taskType = "extremity_god"			, name = "极限战神"				,param_add = true, 		param_count = false, 	param_pos = true,	},
	{taskId = 1005, taskType = "mystery_gift"			, name = "神秘礼物/神秘惊喜"		,param_add = true, 		param_count = false, 	param_pos = false,	},
	{taskId = 1006, taskType = "gold_celeb"				, name = "金牌网红"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1007, taskType = "appreciate_expert"		, name = "鉴赏大师"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1008, taskType = "happy_partner"			, name = "快乐小伙伴"			,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1009, taskType = "super_star"				, name = "超级明星"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1010, taskType = "like_friendship"		, name = "点赞之交"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1011, taskType = "green_house"			, name = "绿色家园/手留余香"		,param_add = true, 		param_count = false, 	param_pos = false,	},
	{taskId = 1012, taskType = "deinsectization_expert"	, name = "除虫巧手"				,param_add = true, 		param_count = false, 	param_pos = false,	},
	{taskId = 1013, taskType = "encyclopaedia"			, name = "百科全书/收藏馆长"		,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1014, taskType = "harvest"				, name = "大丰收/耕耘与收获"		,param_add = true, 		param_count = false, 	param_pos = false,	},
	{taskId = 1015, taskType = "thrive"					, name = "茁壮成长"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1016, taskType = "fully_assembled"		, name = "全员集结"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1017, taskType = "strong"					, name = "强大如我"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1018, taskType = "transfiguration"		, name = "华丽变身"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1019, taskType = "beast_train"			, name = "驯兽高手"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1020, taskType = "wardrobe"				, name = "百变衣橱"				,param_add = false, 	param_count = true, 	param_pos = false,	},
	{taskId = 1021, taskType = "who_am_i"				, name = "我是谁？"				,param_add = true, 		param_count = false, 	param_pos = false,	},
	{taskId = 1022, taskType = "day_day_up"				, name = "天天向上"				,param_add = true, 		param_count = false, 	param_pos = false,	},
};


local m_PlayerCenter_Archievement = {
	func = {
		data = {
			fileKey = "playercenter_archivement",	--setkv和getkv的key值
		},

		--上报服务器
		Report2Server = function(self, _type, _param, _callback)
			--[[
			-Type : id. org:1001, 1002 ...
			_param = {
				add = 1,
				count = 1,
				pos = {x = 1, y = 1, z = 1};
			};
			]]
			print("Report2Server:");
			print("_type:", _type, ", param: ", _param);
			_param = _param or {};

			local url_param = "";			--上报的参数
			local bIsNeedReport = false;	--是否需要上报
			local playerUin = nil;			--客机的UIN

			if _param and _param.uin and _param.uin > 0 then
				playerUin = _param.uin;
			end

			--参数
			for i = 1, #m_Archievement_TypeMap do
				--print("m_Archievement_TypeMap[i].taskId = ", m_Archievement_TypeMap[i].taskId);

				if _type == m_Archievement_TypeMap[i].taskId  then
					print("OK:");

					local item = m_Archievement_TypeMap[i];

					print(item);

					--1. 类型
					url_param = url_param .. "&" .. item.taskType .. "=1";

					--2. 参数add
					if item.param_add then
						local add = (_param and _param.add) or 1;	--默认值:1
						url_param = url_param .. "&add=" .. add;
					end

					--3. 参数count
					if item.param_count and _param.count then
						url_param = url_param .. "&count=" .. _param.count;

						--？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
						-- if _param.count and _param.count == 0 then
						-- 	print("_param.count == 0, 不要上报?????");
						-- 	return;
						-- end
					end

					--4. 参数pos
					if item.param_pos and _param.pos then
						url_param = url_param .. "&pos=" .. _param.pos;
					end

					--5. test
					if _param.test then
						url_param = url_param .. "&test=" .. _param.test;
					end

					print("url_param:");
					print(url_param);

					bIsNeedReport = true;
					break;
				end
			end

			--上报
			if  ns_version and ns_version.proxy_url then
				print("ns_version.proxy_url = " .. ns_version.proxy_url);
				--[[
				--url例子:
				--local pos = "x" .. "_" .. "y" .. "_" .. "z";	--宝箱的位置
				url = ns_version.proxy_url .. '/miniw/achieve?act=set_achieve_task' .. "&" .. http_getS1();
				url = url .. "&user_action=achieve";
				url = url .. "&daemon_hunter=1";	--任务类型
				url = url .. "&add=1";				--增量
				url = url .. "&count=1";			--数量
				url = url .. "&pos=" .. pos;		--宝箱位置信息
				]]

                if bIsNeedReport then
					url = g_http_common .. '/miniw/achieve?';
					--url_param = "'act=set_achieve_task' .. '&' .. http_getS1() .. '&user_action=achieve'" ..url_param
					url_param = "act=" .. "set_achieve_task" .. url_param .. "&"
					url_param = url_param .. http_getS1() .. "&" .. "user_action=" .. "achieve"
					--url = url .. url_param;
					if playerUin then
						--如果是客机, 需要加上客机uin
						--url = url .. "&op_uin=" .. playerUin;
						url_param = url_param .. "&" .. "op_uin=" .. playerUin
					end
					local encodekey = ""
					if ns_version.ach_check_param_cfg and ns_version.ach_check_param_cfg.check_key ~= "" then
						encodekey = XorEncrypt(ns_version.ach_check_param_cfg.check_key)
					end
					-- local function split(str,reps )
					-- 	local resultStrList = {}
					-- 	string.gsub(str,'[^'..reps..']+',function ( w )
					-- 		table.insert(resultStrList,w)
					-- 	end)
					-- 	table.sort(resultStrList)
					-- 	return resultStrList
					-- end
					local res = split(url_param,"&")
					table.sort(res)
					local new_url_param = ""
					for i =1,#res do
						if i ~= #res then
							new_url_param = new_url_param ..res[i].. "&"
						else
							new_url_param = new_url_param ..res[i]
						end
					end
					local md5 = gFunc_getmd5(new_url_param..encodekey);
					url = url..new_url_param .."&auth="..md5;
					print("url=" .. url);
					local callback = function(ret, _param)
						print("Report2Server_callback:");
						print(ret);

						if ret and ret.ret == 0 then
							print("OK:");

							if _param and _param._type == 1002 then
								--更新宝箱位置缓存
								--self:saveChestCache(_param.pos);
							end
						end
					end

					_callback = _callback or callback;
					_param._type = _type;
					ns_http.func.rpc( url, _callback, _param, nil, true);
				end
			else
				--ip配置文件拉取失败
				print("error:IP配置文件拉取失败");
				return;
			end
		end,

		--检测角色数量和等级信息: 在每次打开成就面板的时候来检测, 省去了再解锁角色和天赋的时候去触发的繁琐
		checkRoleInfo = function(self)
			print("checkRoleInfo:");
			--local num = DefMgr:getRoleDefNum();
			local t_StorePlayerModel = { 1, 2, 8, 7, 6, 4, 9, 10, 5, 3 };
			local count = 0;				--已拥有的数量
			local maxRoleLv = 0;			--最大等级数(所有已解锁的天赋等级之和)

			for i = 1, #t_StorePlayerModel do
				local genuisLv = AccountManager:getAccountData():getGenuisLv(i);
				if genuisLv >= 0 then
					--已解锁
					count = count + 1;

					print("genuisLv = ", genuisLv);
					maxRoleLv = maxRoleLv + genuisLv;
				else
					print("未解锁: i = ", i);
				end
			end

			--角色数量
			--检测是否上报
			print("count = ", count);
			if count > 0 then
				self:compareWithCache(1016, count, "roleCount");
			end

			--天赋等级
			--检测是否上报
			print("maxRoleLv = ", maxRoleLv);
			if maxRoleLv > 0 then
				self:compareWithCache(1017, maxRoleLv, "maxRoleLv");
			end
		end,

		--检测皮肤
		checkSkinInfo = function(self)
			print("checkSkinInfo:");
			local skinNum = RoleSkinCsv:getNum();
			local skinCount = 0;	--永久拥有的数量

			for i=1, skinNum do
				local skinDef = RoleSkinCsv:getByIndex(i-1);

				if skinDef then
					local skinTime = AccountManager:getAccountData():getSkinTime(skinDef.ID);
					
					if skinTime < 0 then
						--永久拥有
						print("skinDef.Name:", skinDef.Name);
						skinCount = skinCount + 1;
					end
				end
			end

			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};
			print("cacheInfo1:", cacheInfo);

			--检测是否上报
			if skinCount > 0 then
				self:compareWithCache(1018, skinCount, "skinCount");
			end
		end,

		--检测avator数量
		checkAvatorSkinInfo = function(self)
			print("checkAvatorSkinInfo:");

			threadpool:work(function ()
				local avatorPartCount = 0;
				-- local code, skinTab = AccountManager:avatar_skin_info_list(partCfgTab);
				-- print("checkAvatorSkinInfo:222");
				-- print("code = ", code);
				-- print(skinTab);
	
				-- if code == 0 then
				-- 	for k, v in pairs(skinTab) do
		  --               if k and v and v.ExpireTime == -1 then
		  --               	--永久的
		  --               	avatorPartCount = avatorPartCount + 1;
		  --               end
		  --           end
				-- end
				avatorPartCount = AccountManager:avatar_skin_count();
	
				print("checkAvatorSkinInfo:333");
				if avatorPartCount and avatorPartCount > 0 then
					self:compareWithCache(1020, avatorPartCount, "avatorPartCount");
				end
			end)
		end,

		--检测坐骑
		checkHorseInfo = function(self)
			print("checkHorseInfo:");
			local num = DefMgr:getStoreHorseNum();
			local houseCount = 0;
			local BaseHorseIdList = {};

			for i=1, num do
				local storeHorseDef = DefMgr:getStoreHorseByIndex(i-1);

				if storeHorseDef then
					--csv表里面坐骑"BaseHorseID"有相同的, 应该排除
					local id = storeHorseDef.BaseHorseID;

					if BaseHorseIdList and BaseHorseIdList[id] then
						--已经算过一次了
						print("已经算过一次:id=", id);
					else
						local level = AccountManager:getAccountData():getHorseLevel(id);

						print("horse id=", id, "level = ", level);
						BaseHorseIdList[id] = true;

						if level >= 0 then
							--已解锁
							print("解锁了:");
							houseCount = houseCount + 1;
						end
					end
				end
			end

			--检测是否上报
			print("houseCount = ", houseCount);
			self:compareWithCache(1019, houseCount, "houseCount");
		end,

		checkStoreInfo = function(self)
			print("checkStoreInfo:");
			self:checkRoleInfo();			--角色数量
			self:checkSkinInfo();			--皮肤数量
			self:checkHorseInfo();			--坐骑数量
			self:checkAvatorSkinInfo();		--avator数量
		end,

		--检查好友数量and粉丝数量and是否是鉴赏家
		checkFriendInfo = function(self, friendCount, fansCount, expert)
			print("checkFriendInfo:");
			print("friendCount = ", friendCount, ", fansCount = ", fansCount, ", expert = ", expert);

			if friendCount > 0 then
				self:compareWithCache(1008, friendCount, "friendCount");
			end

			if friendCount > 0 then
				self:compareWithCache(1009, fansCount, "fansCount");
			end

			--鉴赏家等级: stat == 0:非鉴赏家, stat == 2:鉴赏家
			local stat = expert and expert.stat or 0;
			local level = expert and expert.level or 0;
			print("checkFriendInfo:expert: expert = ", expert);
			if stat == 2 then
				self:compareWithCache(1007, level, "expertLevel");
			end
		end,

		--检查连续登录, 一天只报一次
		checkLoginCount = function(self)
			print("checkLoginCount:");
			--date是一个时间表date={year=XX, month=XX, day=XX, hour=...};
			local date = os.date("*t", os.time());

			print(date);
			if date then
				local loginTime = date.year + date.month + date.day;
				self:compareWithCache(1022, loginTime, "loginTime");
			end
		end,

		--检查自己的精选地图的数量
		checkChosenMapCount = function(self, chosenMapCount)
			print("checkChosenMapCount:");
			if chosenMapCount > 0 then
				self:compareWithCache(1006, chosenMapCount, "chosenMapCount");
			end
		end,

		--检查果实等级
		checkPlaneLevel = function(self, level)
			print("checkPlaneLevel:", level);
			if level > 0 then
				self:compareWithCache(1015, level, "plantLevel");
			end
		end,

		--检查图鉴数量
		checkHandbookCount = function(self)
			threadpool:work(function()
 				threadpool:wait(1);
 				local handbookCount = getUnlockedBookSum();
				print("checkHandbookCount:, handbookCount = ", handbookCount);
				if handbookCount > 0 then
					self:compareWithCache(1013, handbookCount, "handbookCount");
				end
 			end);
		end,

		--和cache比较,看是否需要上报
		compareWithCache = function(self, _type, curCount, cacheKey)
			print("compareWithCache:");
			print("uin = ", AccountManager:getUin());
			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};

			print(_type, curCount, cacheKey, cacheInfo);

			--缓存每3 * 24h清理一次, 只清理cacheKey对应的数据
			local timeKey = cacheKey .. "_lasttime";
			local lasttime = cacheInfo[timeKey] or 0;
			local nowtime = os.time();
			if (nowtime - lasttime) > 3 * 24 * 60 * 60 then
				print("清理缓存:");
				-- cacheInfo = {};
				cacheInfo[cacheKey] = 0;		--清理对应的值
				cacheInfo[timeKey] = nowtime;	--重置时间
			end

			local cacheCount = cacheInfo[cacheKey] or 0;
			cacheCount = tonumber(cacheCount);

			print("cacheCount = ", cacheCount);

			--暂时不适用cache, cache始终设置-1
			--cacheCount = -1;
			
			--上报
			if curCount > 0 and curCount ~= cacheCount then
				print("111:");

				local _param = {count = curCount};

				local callback = function(ret, userdata)
					if ret and ret.ret == 0 then
						print("222:successful:");
						--上报成功, 更新缓存
						cacheInfo[cacheKey] = curCount;
						setkv(k, cacheInfo, k);
						print("cacheKey = ", cacheKey);
						print("cacheInfo2:", cacheInfo);
					end
				end
				
				self:Report2Server(_type, _param, callback);
			end
		end,

		--清理kv缓存
		clearkvCache = function(self)
			print("clearkvCache:");
			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};

			print(cacheInfo);
			clearkv(k, k);

			local cacheInfo = getkv(k, k) or {};
			print(cacheInfo);
		end,

		--打开地牢宝箱时, 检查该箱子是否需要上报
		canChestReport = function(self, pos)
			print("checkChest:");

			if not pos then
				print("pos没值:");
				return false;
			end

			local canReport = true;
			local cacheKey = "chestPosList";
			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};
			print("cacheInfo1:", cacheInfo);

			if cacheInfo and cacheInfo[cacheKey] then
				for i = 1, #(cacheInfo[cacheKey]) do
					if pos == cacheInfo[cacheKey][i] then
						print("111: dont report chest:");
						canReport = false;
						break;
					end
				end
			else
				print("333:");
				canReport = true;
			end

			if canReport then
				--更新缓存
				self:saveChestCache(pos);
			end

			return canReport;
		end,

		--更新宝箱位置缓存
		saveChestCache = function(self, pos)
			print("saveChestCache:");
			if not pos then return; end

			local cacheKey = "chestPosList";
			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};
			print("cacheInfo1:", cacheInfo);

			cacheInfo[cacheKey] = cacheInfo[cacheKey] or {};
			table.insert(cacheInfo[cacheKey], pos);
			setkv(k, cacheInfo, k);
			print("cacheInfo2:", cacheInfo);
		end,

		--神秘礼物
		checkReward = function(self, task_id)
			print("checkReward: task_id = ", task_id);
			if task_id and task_id > 0 then
				--if task_id >= 13131 and task_id <= 13144 then
					print("checkReward:神秘礼物数量+1:");
					-- local _param = {add = 1};
					-- self:Report2Server(1005, _param);

					--每攒够5次才上报一次
					local _type = 1005
					local _add = 1;
					local threshold = 3;
					local cacheKey = "Reward";
					self:checkTotalAdd(_type, _add, threshold, cacheKey);
				--end
			end
		end,

		--累计上报, 如累计5次上报一次:add:需要累加的值 threshold:阈值
		--onlyReport:仅仅上报, _add置为0, 只是把缓存的数据读出来, 然后上报, 不管达没达到阈值.每次进入个人中心, 都检查一次缓存.
		checkTotalAdd = function(self, _type, _add, threshold, cacheKey, onlyReport)
			print("checkTotalAdd:", _type, add, threshold, cacheKey, onlyReport);
			local k = self.data.fileKey;
			local cacheInfo = getkv(k, k) or {};
			local value = cacheInfo[cacheKey] or 0;

			value = value + _add;
			print("reward value = " .. value);

			--仅仅只是取出缓存的数据, 然后上报.
			if onlyReport then
				print("onlyReport111:");
			end

			local callback = function(ret, userdata)
				if ret and ret.ret == 0 then
					print("checkTotalAdd:successful:");
					--上报成功, 把当前值置0
					cacheInfo[cacheKey] = 0;
					setkv(k, cacheInfo, k);
				end
			end

			--value >= 阈值 或 仅仅上报
			if value > 0 and (value >= threshold or  onlyReport) then
				print("need report:");
				local _param = {add = value};
				self:Report2Server(_type, _param, callback);
			else
				print("do not need report:");
				cacheInfo[cacheKey] = value;
				setkv(k, cacheInfo, k);
			end
		end,

		--进入个人中心时, 检查累计上报的缓存, 如果累计数量>0, 那么上报
		checkTotalAdd_OnlyReport = function(self)
			print("checkTotalAdd_OnlyReport:");
			--浇水, _add一定给0, 这里只是检查缓存.
			self:checkTotalAdd(1011, 0, 5, "homechest_water", true);

			--除虫
			self:checkTotalAdd(1012, 0, 3, "homechest_monster", true);

			--收获果实
			self:checkTotalAdd(1014, 0, 5, "homechest_fruit", true);

			--收获礼物
			self:checkTotalAdd(1005, 0, 3, "Reward", true);
		end,

		--检查实名认证
		checkRealname = function(self)
			print("checkRealname:");
			if AccountManager.idcard_info then
				local idCardInfo = AccountManager:idcard_info();
				if idCardInfo == nil then
					--未认证					
				else
					--已经实名认证
					print("checkRealname:ok:");
					local k = self.data.fileKey;
					local cacheInfo = getkv(k, k) or {};
					local cacheKey = "RealName";

					local value = cacheInfo[cacheKey] or 0;

					local date = os.date("*t", os.time());

					print(date);
					if date then
						local now = date.year + date.month + date.day;
						
						if now ~= value then
							--没有上报过, 需要上报, 每天检查一次
							print("上报实名认证:");
							local _param = {add = 1};
							self:Report2Server(1021, _param);

							cacheInfo[cacheKey] = now;
							setkv(k, cacheInfo, k);
						else
							--已上报不用再次上报
						end
					end
				end
			end
		end,
	},
}

function ArchievementGetInstance()
	print("ArchievementGetInstance:");
	return m_PlayerCenter_Archievement;
end