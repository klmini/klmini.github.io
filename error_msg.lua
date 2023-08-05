local setmetatable = _G.setmetatable
local getmetatable = _G.getmetatable
local table = _G.table
local string = _G.string 
local tostring = _G.tostring
local tonumber = _G.tonumber
local type = _G.type
local os = _G.os
local next = _G.next

-- 用来处理服务器通用错误消息飘字

ns_error_msg = { }


--消息错误码对应列表
ns_error_msg.msg_dict = {
	zip_file_full = 9768,          --备份文件满
	error_password =  3115,        --密码错误
	error_expire_time = 9590,      --服务器[Desc5]时间到期
	expire_time = 9590,     	   --服务器[Desc5]时间到期
	error_params = 9624,           --请求参数错误

	--error_node_group = 1,          --系统节点群错误
	--error_node_node_id = 1,        --系统节点错误
	--room_shared_fail = 1,          --系统错误
	--pid_err = 1,                   --进程ID错误
	--db_error = 1,                  --数据库失败

	game_is_online = 9592,        --游戏仍然在线
	game_not_online = 9546,       --游戏不在线


	player_full = 9616,            --游戏内玩家已满
	error_wid = 9628,              --地图id错误
	error_no_wdesc = 9629,         --保存地图时，关键文件找不到，地图文件不全
	error_create_zip = 9629,       --保存地图压缩失败
	error_wid_or_file_id = 9628,   --地图id不存在 (删除或者加载备份的时候)
	error_zip_not_exist = 9629,    --备份文件不存在
	error_unzip = 9629,            --解压还原备份失败

	error_cleanup_room = 9630,     --重置房间数据失败

	error_op = "error_op",         --不存在的操作

	error_wid_not_set = 9504,      --未设置地图ID
	error_stat_not_RUNNING = 9546, --地图是未开放状态（停机状态）


	error_player_max = 9618,       --错误的最大玩家数（只能是10，20，30，40）
	error_duration_lg_180 = 9617,  --[Desc5]房间总时间超过180天
	cost_fail = 709,               --扣费失败
	price_error = 9618,            --错误的费用值


	not_buy_room_before = 9631,          --未[Desc5]过此房间
	error_getStartConfig = 9628,         --启动房间参数配置错误
	error_start_game_playernum = 9618,   --错误的最大玩家数
	error_password_too_long = 3115,      --密码太长
	error_start_game_params = 9628,      --启动游戏参数错误

	start_fail = 9844,      			--云服启动失败
	start_interval_limit = 9844,  		--云服启动超时
	error_get_available_port = 9844,    --云服没有可用端口
	error_worldid = 9844, 				--地图id错误
	room_name_check_time_out = 9844, 	--名字得脏字检查超时
	room_name_dirty = 9844, 			--名字得脏字检查不通过
	room_memo_check_time_out = 9844, 	--描述得脏字检查超时
	room_memo_dirty = 9844, 			--描述得脏字检查不通过
	passcard_expire_time = 9844,		--地图通行证过期
	no_room = 9844, 					--房间不存在
	sys_node_error = 9844, 				-- 文件上传失败
	error_group_server_url_config = 9844,--文件上传失败
	error_uin_or_room_id2 = 9844, 		--云服分配节点失败
	error_uin_or_room_id3 = 9844, 		--云服分配节点失败

	white_existed = 9619,                --白名单已存在此玩家
	black_existed = 9620,                --黑名单已存在此玩家

	not_found = 9621,                    --删除黑白名单的时候，找不到该玩家

	error_m1_full = 9622,                --添加超管已满
	error_m2_full = 9623,                --添加普管已满

	error_room_type = 9618,              --[Desc5]或升级房间-错误的房间类型
	error_duration_day = 9618,           --[Desc5]或升级房间-错误的时间(只能是30天的倍数)
	error_update = 9633,                 --[Desc5]或升级房间-升级失败

	room_id_limit = 9632,                --已经[Desc5]了5个房间
	error_cost_num = 9618,               --[Desc5]花费的迷你币异常

	error_cant_buy_room = 9527,          --当前玩家无法[Desc5]
	black_list          = 9528,          --玩家在黑名单中，不能进
	not_in_white_list   = 9529,          --房主设置了白名单， 玩家不在白名单中
	not_friend	 = 9646,				 --该云服设置了好友可进入，请添加服主为好友后才能进入

	map_added = 3890, 					 -- 已收藏成功
	list_size_limit = 9701,				 -- 云服收藏已达上限

	not_login1 = 16323,   --未登陆
	file_size_error = 16324,--资源过小
	error_file_size_large = 16325,--资源过大
	error_res_list_full = 16326,--资源数量已达上限
	error_res_total_size = 16327,--资源空间已达上限
	--error_res_id = 16328,--错误的资源ID    重复定义
	res_is_using = 16329,--资源正在商品中上架,不能取消上传
	res_not_found = 16330,--该资源不存在
	error_goods_type = 16331,--错误的商品类型
	error_goods_name_empty = 16332,--商品名称不能为空
	goods_list_full = 16333,--商品数量已达上限
	error_src_list = 16334,--组成商品的资源参数错误
	error_res_is_using = 16335,--资源已在其他商品中上架
	error_empty_list_detail = 16336,--资源详细信息为空
	error_uin_goods_id = 16337,--错误的商品ID
	error_goods_not_exist = 16338,--商品不存在,无法提交审核
	error_goods_not_retry = 16339,--商品审核未完成,不能再次提交
	error_goods_not_belong = 16340,--这不是你的商品,无权操作
	error_uin = 16341,--错误的迷你号
	error_op = 16342,--错误的举报参数
	error_self_goods = 16343,--自己不能评价自己的商品
	error_already_pdc = 16344,--已经评价过该商品了
	error_goods_name_nil = 16345,--商品名称为空,无法评价
	error_goods_main_nil = 16346,--商品信息为空,无法评价
	sys_error = 16347,--系统忙,暂时查不到评价情况
	error_system = 16348,--系统忙,暂时无法收藏
	goods_name_check_time_out = 16355,	--商品名称校验超时
	goods_name_dirty = 16356,			--商品名称不合规
	goods_desc_check_time_out = 16357,	--商品描述校验超时
	goods_desc_dirty = 16358,			--商品描述不合规
	error_res_id = 16363,				--错误的资源ID
	down_count_empty = 16366,			--剩余商品下载次数不足
	goods_off = 16367,					--该商品已下架，无法下载
	goods_fail_fate = 16368,			--该商品涉嫌违规，无法下载
	goods_down_forbid = 16369,			--该商品无法下载
	error_goods_retry_fail = 16370,		--商品重新审核失败
	sys_cm_ban = 16371,					--您的资源工坊权限已被封禁
	forbid_add_goods = 4746,			--功能即将发布，敬请期待
	game_ver_low = 158,                 --游戏版本太低，请升级版本

	black_stat = 10650, 				--地图状态已发生变化，请重新登录
	noRealNameMobile00 = 100218,		--身份证  手机绑定校验失败
	noRealNameMobile01 = 10643,			--手机绑定校验失败
	noRealNameMobile10 = 22037,			--身份证绑定校验失败
	error_max_buy = 9773,				--系统总云服数量当天达到上限
	error_this_mapid_not_bind_mapid = 9774, --您要上传的地图存档与已绑定地图存档不一致

	--地图模版化
	not_template    = 34439,    --非模板地图
	not_buy         = 9271,     --未[Desc5]
	not_checked     = 34438,    --地图未审核
	temptype_error  = 34440,    --模版类型错误
	not_self_map    = 34643,    --新地图id非法
	params_error    = 16314,    --参数错误

	maintain_not_m1 = 9547,     -- 维护状态服主和超管可以进（统一给了9547的提示）

	no_node_url     = 9590,     -- 节点不存在，给云服到期的提示

	error_goods_is_checking_not_del = 33219,    --审核中的商品允许下架,但下架后不能删除
	error_goods_is_fail_fate        = 33220,    --违规的插件包不允许上架

	--家园各种错误状态的处理
	success             = 41373,    -- 注册成功 
	param_error         = 41374,    -- 参数不正确 
	sign_error          = 41375,    -- 签名不正确 
	item_less_error     = 41376,    -- 物品数量不足 
	item_xls_error      = 41377,    -- id错误读表失败 
	item_config_error   = 41378,    -- 物品对应的配置表错误 
	item_id_error       = 41379,    -- 物品ID错误 
	manor_coin_less     = 41012,    -- 家园币不足 
	manor_level_less    = 41381,    -- 家园等级不足 
	manor_not_owner_op  = 41435,    -- 家园-不是家园主的操作 
	manor_banned_error  = 3632,     -- 该地图涉嫌违规，无法进入游戏
	manor_costtype_not_exist_error  = 41380,    -- 未知消耗类型
	cooking_bench_has_learn         = 41583,	-- 这道菜已经学过啦
	-- 玩法背包 15 - 20 
	playing_data_error              = 41436,    -- 玩法背包数据错误 
	playing_mult_goods_error        = 41437,    -- 玩法背包中存在多个相同配置ID 
	playing_goods_id_error          = 41438,    -- 玩法背包物品ID对应的物品信息不存在 
	playing_goods_num_not_enough    = 41382,    -- 玩法背包中对应的物品数量不足
	-- 创造背包 21 - 30 
	building_bag_read_bag_error         = 41383,    -- 创造背包读取背包数据失败 
	building_bag_param_costitems_error  = 4028,     -- 创造背包costitems参数错误 
	building_bag_item_locked            = 41059,    -- 物品未解锁 
	building_bag_item_notneed_unlock    = 41439,    -- 物品不需要解锁 
	building_bag_item_unlocked          = 41385,    -- 物品已被解锁 
	building_bag_unlock_groupreward_not_available   = 41386,    -- 系列解锁奖励不可领取 
	building_bag_unlock_groupreward_available       = 41387,    -- 系列解锁奖励可领取 
	building_bag_unlock_groupreward_received        = 41388,    -- 系列解锁奖励已领取 
	-- 农场玩法(31-50) 
	farmlandid_error            = 41440,    -- 农场配置表ID错误 
	farm_unlock_failed          = 41389,    -- 农场解锁失败 
	farm_unlock_level_failed    = 41390,    -- 农场_家园等级不够 
	farm_is_unlock_error        = 41441,    -- 农场ID未解锁 
	farm_is_use_error           = 41391,    -- 农场被占用 
	farm_seed_info_error        = 41442,    -- 农场种植信息未找到 
	farm_seed_state_error       = 41443,    -- 农场_农物状态不对 
    farm_seed_tree_pos_error    = 41495,    -- 家园农场，树木种植需要间隔两个格子
	-- 养殖场玩法(51-80) 
	breed_Ranch_level_error         = 41444,    -- 养殖场升级配置表ID 
	breed_next_level_error          = 41392,    -- 养殖场升级等级错误 
	breed_animal_seed_info_error    = 41393,    -- 养殖场_宠物蛋信息错误 
	breed_unlock_level_failed       = 41390,    -- 养殖场_家园等级不够 
	breed_animal_seed_id_error      = 41445,    -- 养殖场_动物蛋ID错误 
	breed_animal_info_error         = 41395,    -- 养殖场_动物信息错误 
	breed_animal_food_id_error      = 41396,    -- 养殖场_动物对应的食物ID错误 
	breed_animal_hunger_error       = 41397,    -- 养殖场_动物处于饥饿状态 
	breed_animal_hunger_time_error  = 41398,    -- 养殖场_动物的饥饿时间未进入 
	breed_animal_maturity_error     = 41399,    -- 养殖场_动物已经成熟 
	breed_animal_growing_error      = 41400,    -- 养殖场_动物未成熟 
	breed_animal_not_hunger_error   = 41401,    -- 养殖场_动物不是饥饿状态 
	breed_animal_growth_time_error  = 41402,    -- 养殖场_成熟时间未到 
	breed_animal_unkown_error       = 41403,    -- 养殖场_未知原因报错 
	breed_animal_childhood_error    = 41404,    -- 养殖场_动物是幼年 
	breed_Ranch_not_info_error      = 41405,    -- 养殖场-养殖配置表信息异常 
	breed_Ranch_upper_limit_error   = 41406,    -- 养殖场-养殖等级对应的可养殖的动物数量错误
	-- 祈愿玩法(81-110) 
	prayer_tree_info_error          = 41407,    -- 祈愿-祈愿树信息异常 
	prayer_open_info_error          = 41408,    -- 祈愿-开启信息异常 
	prayer_ballot_time_error        = 41409,    -- 祈愿-中签间隔时间未到 
	prayer_Random_time_error        = 41410,    -- 祈愿-随机间隔时间未到 
	prayer_tree_not_create_error    = 41411,    -- 祈愿-未中签 
	prayer_data_error               = 41412,    -- 祈愿-祈愿数据异常 
	prayer_tree_exist               = 41413,    -- 祈愿-祈愿树存在 
	prayer_tree_grown_error         = 41414,    -- 祈愿-祈愿树不在成熟阶段 
	prayer_tree_wish_start_error    = 41415,    -- 祈愿-祈愿树不在开始阶段 
	prayer_tree_config_error        = 41416,    -- 祈愿-祈愿树配置表信息异常 
	prayer_tree_wish_time_error     = 41417,    -- 祈愿-祈愿开启后,祈愿结束时间还没有到 
	prayer_tree_not_owner_error     = 41446,    -- 祈愿-祈愿树的主人不对 
	prayer_tree_have_wish_error     = 41418,    -- 祈愿-祈愿者已经祈愿过 
	prayer_tree_reuse_open_error    = 41419,    -- 祈愿-祈愿树重复开启 
	-- 宠物玩法(111-130) 
	pet_grid_config_error           = 41447,    -- 宠物_宠物格子配置信息不对 
	pet_info_not_exist_error        = 41448,    -- 宠物-宠物信息不存在 
	pet_config_not_exist_error      = 41449,    -- 宠物-宠物配置信息不存在 
	pet_exp_not_enough_error        = 41420,    -- 宠物-进化经验不足 
	pet_item_num_not_enough_error   = 41421,    -- 宠物-合成数量不足 
	pet_grid_has_unlocak_error      = 41422,    -- 宠物-宠物栏已经解锁 
	pet_max_state_error             = 41423,    -- 宠物-宠物进化最高级别 
	pet_create_data_failed_error    = 41450,    -- 宠物-创建宠物数据失败 
	pet_explore_config_error        = 41424,    -- 宠物-探险地图配置异常 
	pet_event_config_error          = 41425,    -- 宠物-探险地图事件配置异常 
	pet_event_pack_config_error     = 41426,    -- 宠物-探险地图事件包配置异常 
	pet_explore_maxpetnum_error     = 41427,    -- 宠物-探险地图探险数量 
	pet_grid_max_error              = 41428,    -- 宠物-宠物格子数超过上限 
	pet_is_fatigue_state_error      = 41429,    -- 宠物-宠物疲劳状态 
	pet_explore_not_exist_error     = 41451,    -- 宠物-探险地图信息不存在 
	pet_explore_is_start_error      = 41430,    -- 宠物-该探险地图探险已经开始 
	pet_is_explore_state_error      = 41555,    -- 宠物-宠物探险中,无法进行该操作
	pet_is_feed_weight_error        = 41688,    -- 宠物-携带的食物太重了
	pet_is_specialskill_error       = 41684,    -- 宠物-能力需求不满足时
	pet_not_temp_training_attr = 101038,   -- 没有上次宠物洗练属性记录
	pet_training_action_error  = 101039,   -- 操作错误

	-- 家园抽奖 (系列家具[Desc5]) (131-140) 
	draw_open_time_error        = 41452,    -- 不在抽奖时间内 
	draw_ver_less_error         = 41453,    -- 版本不足 
	draw_env_debug_error        = 41454,    -- 环境不符合条件(open_server 区服) 
	draw_param_costitems_error  = 4028,     -- 家园抽奖costitems参数错误 
    draw_xls_error              = 41464,    -- draw配置表错误 
    draw_open_time_begin_error  = 41079,    -- 抽奖未开始 
	draw_open_time_end_error    = 41080,    -- 抽奖已结束 
	
	-- 家园升级(141-150) 
	manor_lv_config_error   = 41456,    -- 家园升级等级配置信息不存在 
	manor_max_lv            = 41431,    -- 家园满级了 
	-- 物品制作(151-160) 
	craft_has_unlocked      = 41432,    -- 物品已被解锁 
	craft_locked            = 41433,    -- 物品未被解锁 
	craft_not_need_unlock   = 41457,    -- 物品不需要被解锁, 免费(表格控制) 
	-- 自建(161-170) 
	building_max_level              = 41434,    -- 达到最大自建等级 
	building_param_costitems_error  = 4028,     -- 自建costitems参数错误 
	-- 账号服相关（171-190） 
	account_bag_item_less   = 41459,    -- 账号服物品不足 
	account_query_error     = 41460,    -- 请求账号服失败 
	account_minicoin_less   = 456,      -- 迷你币不足 
	account_minibean_less   = 41013,    -- 迷你豆不足 
	account_minidian_less   = 30123,    -- 迷你点不足 
	account_coin_cant_add   = 41479,    -- 账号服货币禁止增加
	lua_config_error_ver    = 158,      -- 版本过小，请升级版本
	lua_config_error_apiid  = 3479,     -- 渠道有误（此功能暂未开放。）
	shop_sell_uplimit_error = 3293,     -- 商人,出售数量限制了（没有剩余次数）
    shop_trade_info_error   = 41378,    -- 商人,配置表错误 （物品对应的配置表错误）
    item_coin_id_error      = 40950,    -- 配置表中货币类型ID相关配置异常
    playing_not_item_type_error         = 40951,    -- 不是玩法背包物品
    building_bag_not_item_type_error    = 40952,    -- 不是创造背包物品
	--家园相关
	farm_land_has_open_error    		=41516,      --农场-此块地已开垦过
    farm_land_has_close_error  			=41517,      --农场-此块地已还原过
    farm_land_num_is_not_enough 		=41518,      --农场-开垦数量不够
	--breed_animal_manure_info_error 	= 44, --养殖场--掉落的肥料信息错误
	farm_breed_use_manure_has_ing 		= 41521,
	farm_use_manure_type_error 			= 41514, --农场-肥料类型异常
	breed_has_been_harvested_error		= 41524,  --养殖场-主机生物已被收割
	task_not_allowed_giveup       		= 101100,   -- 该任务不能放弃 
    task_is_giveup                		= 101101,   -- 该任务已放弃
    task_daily_completed_limit    		= 101102,   -- 每日任务完成个数已达上限
    task_giveup_times_limit       		= 101103,   -- 已超过最大可放弃数
}



---显示一个错误飘字
---msg_       : 类似的结构体：{ ret=0, msg="zip_error" },  或者一个字符串:zip_error
---p_second_  : 显示时间，默认为5
function ns_error_msg.show( msg_, p_second_,withoutFilter)
	local second_ = p_second_ or 5
	local errorStr = ""
	if type(msg_) == 'table' then
		if  type(msg_.msg) == 'string' then
			if  msg_.flag and type(msg_.flag) == 'string' then
				--暂时只有身份证手机绑定需要这种格式  后续有新加再改
				if msg_.flag == "01" or msg_.flag == "10" or msg_.flag == "00" then
					errorStr = ns_error_msg.GetS(msg_.msg .. msg_.flag)
					ShowGameTipsWithoutFilter(errorStr, second_ )
				else
					errorStr = ns_error_msg.GetS(msg_.msg)
					ShowGameTips(errorStr , second_ )
				end
			else
				errorStr = ns_error_msg.GetS(msg_.msg, msg_.ret)
				if withoutFilter then
					ShowGameTipsWithoutFilter(errorStr)
				else
					ShowGameTips( errorStr, second_ )
				end
			end
		elseif msg_.ret then
			errorStr = "error_ret:" .. msg_.ret
			ShowGameTips( errorStr, second_ )
		else
			errorStr = uu.to_str(msg_)
			ShowGameTips( errorStr, second_ )
		end
	elseif type(msg_) == 'string' then
		errorStr = ns_error_msg.GetS(msg_)
		ShowGameTips( errorStr, second_ )
	else
		errorStr = uu.to_str(msg_)
		ShowGameTips( errorStr, second_ )
	end
	return errorStr
end


----------------------------------------------------------帮助函数----------------
---通过msg_字符串查找错误码
function ns_error_msg.GetS( msg_, ret)
	local msg_find_ = ns_error_msg.msg_dict[msg_]
	if  msg_find_ then
		if  type( msg_find_ ) == "number" then
			if type(ret) == "number" or type(ret) == "string" then
				return GetS(msg_find_, ret)
			end
			return GetS(msg_find_)
		elseif type( msg_find_ ) == "string" then
			return msg_find_
		end
	end
	return msg_
end

