local finalCommonRGB55_54_49 = {r=55, g=54, b=49};

local Log = print;

new_modeditor = {
	config = {
		--方块
		block = {
			tab1 = {
				Name_StringID = 584, --基础设置
				attrtype1 = {
					Name_StringID = 587, --基础
					Attr = {
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4200, 	--爆炸抗性
							CanShow = function (def)
								return true;
							end,
							ENName = 'AntiExplode', JsonName = 'anti_explode', CurVal = 10, Min=-1, Max=500, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AntiExplode end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 20 then
									Desc_StringID = 4536;
								elseif val >= 20 and val < 50 then
									Desc_StringID = 4537;
								elseif val >= 50 and val <= 500 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4202,	--硬度
							CanShow = function (def)
								return true;
							end,
							ENName = 'Hardness', JsonName = 'hardness', CurVal = 5, Min=-1, Max=200, Step=0.5,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.Hardness end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 10 then
									Desc_StringID = 4536;
								elseif val >= 10 and val < 30 then
									Desc_StringID = 4537;
								elseif val >= 30 and val <= 200 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4204,	--地滑程度
							CanShow = function (def)
								return true;
							end,
							ENName = 'Slipperiness', JsonName = 'slipperiness', CurVal = 1, Min=0.1, Max=3, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.Slipperiness end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4206,	--燃烧速度
							CanShow = function (def)
								return true;
							end,
							ENName = 'BurnSpeed', JsonName = 'burn_speed', CurVal = 0, Min=0, Max=50, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.BurnSpeed end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val >= 0 and val < 10 then
									Desc_StringID = 4539;
								elseif val >= 10 and val < 30 then
									Desc_StringID = 4540;
								elseif val >= 30 and val <= 50 then
									Desc_StringID = 4541;
								end
								return GetS(Desc_StringID);
							end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4208,	--燃烧几率
							CanShow = function (def)
								return true;
							end,
							ENName = 'CatchFire', JsonName = 'catch_fire', CurVal = 0, Min=0, Max=100, Step=1,
							ValShowType = 'Percent',
							GetInitVal = function(def)	return def.CatchFire end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4210,	--光源强度
							CanShow = function (def)
								return true;
							end,
							ENName = 'LightSrc', JsonName = 'light_src', CurVal = 0, Min=0, Max=15, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.LightSrc end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 4 then
									Desc_StringID = 4536;
								elseif val >= 4 and val < 7 then
									Desc_StringID = 4537;
								elseif val >= 7 and val <= 15 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
						},
						
						{
							Type = 'Line',		--分割线
						},
						--[[
						{
							Type = 'Switch', 		--开关
							Name_StringID = 4458, 	--重力下落
							CurVal = false, 
							GetInitVal = function(def)
								if def.GravityEffect > 0 then
									return true;
								else
									return false;
								end
							end,
							Save = function(t_attr, def, t_property)
								if t_attr.CurVal then
									def.GravityEffect = 1
								else
									def.GravityEffect = 0
								end
								t_property["gravity_effect"] = def.GravityEffect
							end,
							Func = function(type, notUpdate)
							end,
						},
						]]
						{
							Type = 'Selection', 	--选择框
							Name_StringID = 4460, 	--掉落道具
							CanShow = function (def)
								return true;
							end,
							Def = 'ItemDef',
							ENName = 'DropItem',
							GetInitVal = function(def)
								local t = {};
								if def.ToolMineDrops[0].item > 0 then
									table.insert(t, def.ToolMineDrops[0].item);
								end
								return t;
							end,
							Boxes = {	
								{
									JsonName = 'tool_mine_drop1',
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								if #(t_attr.CurVal) > 0 then
									local id = t_attr.CurVal[1]
									local recordId = id;
									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									if id >= USER_MOD_NEWID_BASE then
										local paramDef = ModEditorMgr:getItemDefById(id)
										ModEditorMgr:setBlockForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;										
									end
									
									def.ToolMineDrops[0].item = id;
									def.ToolMineDrops[0].odds = 100;
									t_property[t_attr.Boxes[1].JsonName] = recordId;
								else
									def.ToolMineDrops[0].item = 0;
									def.ToolMineDrops[0].odds = 0;
									t_property[t_attr.Boxes[1].JsonName] = 0;
								end
							end,
						},
						
						{
							Type = 'Option', 		--选项
							Name_StringID = 4462, 	--移动碰撞，0：空气， 1：固体, 2: 液体， 3：不阻挡投射物
							Desc_StringID = 4463,	--描述
							ENName = 'MoveCollide', JsonName = 'move_collide', CurVal = 0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.MoveCollide end,
							Options	= {
								{
									Name_StringID = 4464, 	--选项1
									Desc_StringID = 4465,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4466, 	--选项2
									Desc_StringID = 4467,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4468, 	--选项2
									Desc_StringID = 4469,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
								{
									Name_StringID = 4470, 	--选项3
									Desc_StringID = 4471,	--描述3
									Color = finalCommonRGB55_54_49,
									Val = 3,
								},
								{
									Name_StringID = 6375, 	--选项3
									Desc_StringID = 6376,	--描述3
									Color = finalCommonRGB55_54_49,
									Val = 4,
								},
							},
						},
						{
							Type = 'Switch', 		--开关
							Name_StringID = 4596, 	--可否被击碎
							CurVal = false, 
							GetInitVal = function(def)
								return def.Breakable;
							end,
							Save = function(t_attr, def, t_property)
								if t_attr.CurVal then
									def.Breakable = true
									t_property['breakable'] = true
								else
									def.Breakable = false								
									t_property['breakable'] = false
								end
							end,
							Func = function(type, notUpdate)
							end,
						},
					},
				},
			},	
		},
		
		--生物
		actor = {
			tab1 = {
				Name_StringID = 584, --基础设置
				attrtype1 = {
					Name_StringID = 587, --基础
					Attr = {
						{
							Type = 'Slider',		--滑动条
							Name_StringID = 3648, 	--模型大小
							ENName = 'ModelScale', JsonName = 'model_scale', CurVal = 1, Min=0.1, Max=2, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.ModelScale end,
							GetDesc = function(val)
								local Desc_StringID;	--描述StringID
								if val >= 0.1 and val < 0.5 then
									Desc_StringID = 4805;
								elseif val >= 0.5 and val < 0.9 then
									Desc_StringID = 4806;
								elseif val >= 0.9 and val < 1.3 then
									Desc_StringID = 4807;
								elseif val >= 1.3 and val < 1.7 then
									Desc_StringID = 4808;
								elseif val >= 1.7 --[[and val <= 2]] then
									Desc_StringID = 4809;
								end
								return GetS(Desc_StringID);
							end,
						},
						
						{
							Type = 'Line',		--分割线
						},

						{
							Type = 'Switch', 		--开关
							Name_StringID = 3660, 	--是否可移动
							CurVal = false, 
							GetInitVal = function(def)
								if def.Speed > 0 then
									return true;
								else
									return false;
								end
							end,
							Save = function(t_attr, def, t_property)
								if not t_attr.CurVal then
									local t = new_modeditor.GetTableToENName(new_modeditor.config.actor.tab1.attrtype1.Attr, "Speed")
									if t then
										t.CurVal = 0;
									end
									--设置重力
									def["Mass"] = 999999;
									t_property["mass"] = 999999;
								end
							end,
							Func = function(type, notUpdate)
							 	new_modeditor.ChangeConfigShowPremise(type, 'IsMove')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},

						{
							Type = 'Slider',		--滑动条
							Name_StringID = 3649, 	--移动速度
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsMove');
							end,
							ENName = 'Speed', JsonName = 'speed', CurVal = 300, Min=0, Max=600, Step=1,
							GetInitVal = function(def)	return def.Speed end,
							GetDesc = function(val)
								local Desc_StringID = 4810;	--描述StringID
								if val >= 0 and val < 200 then
									Desc_StringID = 4810;
								elseif val >= 200 and val < 300 then
									Desc_StringID = 4811;
								elseif val >= 300 and val < 400 then
									Desc_StringID = 4807;
								elseif val >= 400 and val <= 500 then
									Desc_StringID = 4812;
								elseif val >= 500 and val <= 600 then
									Desc_StringID = 4813;
								end
								return GetS(Desc_StringID);
							end,
						},
					
						{
							Type = 'Line',		--分割线
						},
						
						{
							Type = 'Switch', 		--开关
							Name_StringID = 3650, 	--掉落
							CurVal = false, 
							GetInitVal = function(def)
								if def.DropItem[0] > 0 or def.DropItem[1] > 0 or def.DropItem[2] > 0 or def.DropExp > 0 then
									return true;
								else
									return false;
								end
							end,		
							Save = function(t_attr, def, t_property)
								if not t_attr.CurVal then
									local t = new_modeditor.GetTableToENName(new_modeditor.config.actor.tab1.attrtype1.Attr, "DropItem")
									if t then
										t.CurVal = {0, 0, 0};
									end
									t = new_modeditor.GetTableToENName(new_modeditor.config.actor.tab1.attrtype1.Attr, "DropExp")
									if t then
										t.CurVal = 0;
									end
								end
							end,
							Func = function(type, notUpdate)
							 	new_modeditor.ChangeConfigShowPremise(type, 'IsDrop')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},
				
						{
							Type = 'Selection', 	--选择框
							Name_StringID = 3651, 	--掉落道具
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsDrop');
							end,
							Def = 'ItemDef',
							ENName = 'DropItem',
							GetInitVal = function(def)
								local t = {};
								for i=1, 3 do
									local itemId = def.DropItem[i-1];
									table.insert(t, itemId);
								end
								return t;
							end,
							Boxes = {	
								{
									JsonName = 'drop_item1',
								},
								{
									JsonName = 'drop_item2',
								},
								{
									JsonName = 'drop_item3',
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								for i=1, 3 do
									def["DropItem"][i-1] = t_attr.CurVal[i];
									t_property[t_attr.Boxes[i].JsonName] = t_attr.CurVal[i];
								end
							end,
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 3652, 	--掉落经验
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsDrop');
							end,
							ENName = 'DropExp', JsonName = 'drop_exp', CurVal = 1, Min=0, Max=100, Step=1,
							GetInitVal = function(def)	return def.DropExp end,	
						},
		
						{
							Type = 'Line',		--分割线
						},

						--[[{
							Type = 'Switch', 		--开关
							Name_StringID = 3653, 	--击杀得分
							GetInitVal = function(def)	return def.KillScore>0 end,
							CurVal = false,
							Save = function(t_attr, def, t_property)
								if not t_attr.CurVal then
									local t = new_modeditor.GetTableToENName(new_modeditor.config.actor.tab1.attrtype1.Attr, "KillScore")
									if t then
										t.CurVal = 0;
									end
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'KillScore')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},]]

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 3657, 	--分数
							CanShow = function (def)
								return new_modeditor.MeetPremise('KillScore');
							end,
							ENName = 'KillScore', JsonName = 'kill_score', CurVal = 1, Min=0, Max=100, Step=1,
							GetInitVal = function(def)	return def.KillScore end,
						},
					},
				},
				attrtype2 = {
					Name_StringID = 4804, --战斗
					Attr = {
						--[[{
							Type = 'Switch', 		--开关
							Name_StringID = 3668, 	--主动攻击
							ENName = 'ActiveAtk', JsonName = 'active_atk', CurVal = false, 
							GetInitVal = function(def) return def.ActiveAtk end,
						},]]
						
						{
							Type = 'Option', 		--选项
							Name_StringID = 3656, 	--生物阵型
							Desc_StringID = 4833,	--描述
							ENName = 'TeamID', JsonName = 'team_id', CurVal = 0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.TeamID end,
							Options	= {
								{
									Name_StringID = 3663, 	--选项1
									Desc_StringID = 3666,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 3664, 	--选项2
									Desc_StringID = 3667,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 3665, 	--选项2
									Desc_StringID = 3666,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
								{
									Name_StringID = 4822, 	--选项3
									Desc_StringID = 3666,	--描述3
									Color = finalCommonRGB55_54_49,
									Val = 3,
								},	
								{
									Name_StringID = 4823, 	--选项4
									Desc_StringID = 3666,	--描述4
									Color = finalCommonRGB55_54_49,
									Val = 4,
								},
								{
									Name_StringID = 4824, 	--选项5
									Desc_StringID = 3666,	--描述5
									Color = finalCommonRGB55_54_49,
									Val = 5,
								},
								{
									Name_StringID = 4825, 	--选项6
									Desc_StringID = 3666,	--描述6
									Color = finalCommonRGB55_54_49,
									Val = 6,
								},								
							},
						},
					
						{
							Type = 'Line',		--分割线
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4300, 	--生命值
							ENName = 'Life', JsonName = 'life', CurVal = 1, Min=1, Max=1200, Step=1,
							GetInitVal = function(def)	return def.Life end,							
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4302, 	--攻击
							ENName = 'Attack', JsonName = 'attack', CurVal = 1, Min=1, Max=180, Step=1,
							GetInitVal = function(def)	return def.Attack end,							
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 3661, 	--攻击距离
							ENName = 'AttackDistance', JsonName = 'attack_distance', CurVal = 2, Min=1, Max=24, Step=1,
							GetInitVal = function(def)	return def.AttackDistance end,							
						    GetDesc = function(val)
								local Desc_StringID;	--描述StringID
								if val >= 0 and val < 4 then
									Desc_StringID = 4814;
								elseif val >= 4 and val < 10 then
									Desc_StringID = 4815;
								elseif val >= 10 and val <= 24 then
									Desc_StringID = 4816;
								end
								return GetS(Desc_StringID);
							end,
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4304, 	--视野范围
							ENName = 'ViewDistance', JsonName = 'view_distance', CurVal = 16, Min=1, Max=24, Step=1,
							GetInitVal = function(def)	return def.ViewDistance end,							
							GetDesc = function(val)
								local Desc_StringID = 4817;	--描述StringID
								if val >= 0 and val < 4 then
									Desc_StringID = 4817;
								elseif val >= 4 and val < 10 then
									Desc_StringID = 4818;
								elseif val >= 10 and val <= 24 then
									Desc_StringID = 4819;
								end
								return GetS(Desc_StringID);
							end,
						},
					},
				},
			},
			tab2 = {
				Name_StringID = 3645, --技能
			},
			tab3 = {
				Name_StringID = 3646, --基础设置
			},
		},
		
		--道具
		item = {
			tab1 = {
				Name_StringID = 584, --基础设置
				attrtype1 = {
					Name_StringID = 587, --基础
					Attr = {
						--[[{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4400, 	--堆叠数
							Def = 'ItemDef',
							ENName = 'StackMax', JsonName = 'stack_max', CurVal = 16, Min=1, Max=64, Step=1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.StackMax end,							
							GetDesc = function(val)
								local Desc_StringID = 4817;	--描述StringID
								if val >= 0 and val < 4 then
									Desc_StringID = 4817;
								elseif val >= 4 and val < 10 then
									Desc_StringID = 4818;
								elseif val >= 10 and val <= 64 then
									Desc_StringID = 4819;
								end
								return GetS(Desc_StringID);
							end,
						},]]
						--- 下面是工具的配置  ---
						{
							Type = 'Switch', 		--开关
							Name_StringID = 4402, 	--是否工具
							GetInitVal = function(def)
								return def.IsDefTool or (def.ID ~= 10100 and ToolDefCsv:get(def.ID) ~= nil);
							end,
							CanShow = function (def)
								return false;
							end,
							ENName = 'IsDefTool', JsonName = 'define_tool',
							CurVal = false,
							AddDef = function(val, id, copyid)
								ModEditorMgr:addToolDef(id, copyid);
							end,
							Save = function(t_attr, def, t_property)
								def["IsDefTool"] = t_attr.CurVal;
								t_property["define_tool"] = t_attr.CurVal;
								
								if t_attr.CurVal then
									local id = def.CopyID > 0 and def.CopyID or def.ID;
									local t = ToolDefCsv:get(id);
									if t == nil then	--工具表里找不到这个道具
										t_property["copy_toolid"] = 10100;	--保存默认的工具ID
									end
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'IsTool')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4408, 	--效率加成
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsTool');
							end,
							Def = 'ToolDef',
							ENName = 'Efficiency', JsonName = 'tool_efficient', CurVal = 0, Min=0, Max=1000, Step=10,
							ValShowType = 'Percent',
							GetInitVal = function(def)	return def.Efficiency end,							
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 300 then
									Desc_StringID = 4536;
								elseif val >= 300 and val < 600 then
									Desc_StringID = 4537;
								elseif val >= 600 and val <= 1000 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Efficiency"] = t_attr.CurVal;
									t_property["tool_efficient"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4412, 	--攻击力
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsTool');
							end,
							Def = 'ToolDef',
							ENName = 'Attack', JsonName = 'attack', CurVal = 10, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Attack end,							
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Attack"] = t_attr.CurVal;
									t_property["attack"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4414, 	--耐久度
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsTool');
							end,
							Def = 'ToolDef',
							ENName = 'Duration', JsonName = 'tool_duration', CurVal = 100, Min=1, Max=2000, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Duration end,							
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 300 then
									Desc_StringID = 4536;
								elseif val >= 300 and val < 1700 then
									Desc_StringID = 4537;
								elseif val >= 1700 and val <= 2000 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Duration"] = t_attr.CurVal;
									t_property["tool_duration"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4440, 	--蓄力时间
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsTool');
							end,
							Def = 'ToolDef',
							ENName = 'AccumulatorTime', JsonName = 'accumulate_time', CurVal = 0.5, Min=0, Max=10, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.AccumulatorTime end,							
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["AccumulatorTime"] = t_attr.CurVal;
									t_property["accumulate_time"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						--[[
						{
							Type = 'Option', 		--选项
							Name_StringID = 3683, 	--使用目标
							Desc_StringID = 3684,	--描述
							CanShow = function (def)
								return new_modeditor.MeetPremise({	PREQ={'IsTool', 'IsUseTool'} });
							end,
							ENName = 'UseTarget', JsonName = 'use_target', CurVal = 1,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.UseTarget end,
							Options	= {
								{
									Name_StringID = 3685, 	--选项1
									Desc_StringID = 3685,	--描述1
									Val = 0,
								},
								{
									Name_StringID = 3686, 	--选项2
									Desc_StringID = 3686,	--描述2
									Val = 4,
								},
								{
									Name_StringID = 3687, 	--选项2
									Desc_StringID = 3687,	--描述2
									Val = 9,
								},								
							},
							Func = function(val, notUpdate)
								new_modeditor.ChangeConfigShowPremise('remove', 'IsUseBow')
								new_modeditor.ChangeConfigShowPremise('remove', 'IsUseProjectile')
								if val == 4 then
									new_modeditor.ChangeConfigShowPremise('add', 'IsUseBow')
								elseif val == 9 then
									new_modeditor.ChangeConfigShowPremise('add', 'IsUseProjectile')
								end
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},]]
						{
							Type = 'Selection', 	--选择框
							Name_StringID = 4454, 	--弹药
							CanShow = function (def)
								local toolDef = ToolDefCsv:get(def.ID);
								if toolDef then
									return new_modeditor.MeetPremise('IsTool') and toolDef.ConsumeID > 0;
								else
									return false;
								end
							end,
							Def = 'ToolDef',
							ENName = 'ConsumeID',
							GetInitVal = function(def)
								return {def.ConsumeID};
							end,
							Boxes = {	
								{
									ENName = 'ConsumeID', JsonName = 'consume_itemid', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["ConsumeID"] = t_attr.CurVal[1];
									t_property["consume_itemid"] = tonumber(t_attr.CurVal[1]);
									local consumeDef = ModEditorMgr:getItemDefById(tonumber(t_attr.CurVal[1]));
									if consumeDef and consumeDef.CopyID > 0 then	--记录选择的投射物文件名，作为唯一标识
										t_property["consumeid_filename"] = consumeDef.EnglishName;
									end
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4456, 	--消耗数量
							CanShow = function (def)
								local toolDef = ToolDefCsv:get(def.ID);
								if toolDef then
									return new_modeditor.MeetPremise('IsTool') and toolDef.ConsumeID > 0;
								else
									return false;
								end
							end,
							Def = 'ToolDef',
							ENName = 'ConsumeCount', JsonName = 'consume_count', CurVal = 1, Min=1, Max=10, Step=1,
							GetInitVal = function(def)	return def.ConsumeCount end,							
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["ConsumeCount"] = t_attr.CurVal;
									t_property["consume_count"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						
						{
							Type = 'Line',		------------------------分割线，下面是食物--------------------------
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsTool') and new_modeditor.MeetPremise('IsProjectile');
							end,
						},
						
						{
							Type = 'Switch', 		--开关
							Name_StringID = 4404, 	--是否食物
							GetInitVal = function(def)
								return def.IsDefFood or (def.ID ~= 10100 and FoodDefCsv:get(def.ID) ~= nil);
							end,
							CanShow = function (def)
								return false;
							end,
							ENName = 'IsDefFood', JsonName = 'define_food',
							CurVal = false,
							AddDef = function(val, id, copyid)
								ModEditorMgr:addFoodDef(id, copyid);
							end,
							Save = function(t_attr, def, t_property)
								def["IsDefFood"] = t_attr.CurVal;
								t_property["define_food"] = t_attr.CurVal;
								
								if t_attr.CurVal then
									local id = def.CopyID > 0 and def.CopyID or def.ID;
									local t = FoodDefCsv:get(id);
									if t == nil then	--食物表里找不到这个道具
										t_property["copy_foodid"] = 10100;	--保存默认的食物ID
									end

									def["UseTarget"] = 5;
									t_property["use_target"] = 5;
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'IsFood')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4432, 	--使用时间
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsFood');
							end,
							Def = 'FoodDef',
							ENName = 'UseTime', JsonName = 'use_time', CurVal = 30, Min=0, Max=100, Step=1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.UseTime end,							
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								if val >= 0 and val < 30 then
									Desc_StringID = 4530;
								elseif val >= 30 and val < 60 then
									Desc_StringID = 4531;
								elseif val >= 60 and val <= 100 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["UseTime"] = t_attr.CurVal;
									t_property["use_time"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4434, 	--增加饥饿度
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsFood');
							end,
							Def = 'FoodDef',
							ENName = 'AddFood', JsonName = 'add_food', CurVal = 0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AddFood end,							
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["AddFood"] = t_attr.CurVal;
									t_property["add_food"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4436, 	--增加饥饿耐力
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsFood');
							end,
							Def = 'FoodDef',
							ENName = 'AddFoodSat', JsonName = 'add_foodstate', CurVal = 0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AddFoodSat end,							
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["AddFoodSat"] = t_attr.CurVal;
									t_property["add_foodstate"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4438, 	--增加治疗血量
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsFood');
							end,
							Def = 'FoodDef',
							ENName = 'HealAmount', JsonName = 'heal_actor', CurVal = 0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.HealAmount end,							
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["HealAmount"] = t_attr.CurVal;
									t_property["heal_actor"] = t_attr.CurVal;
								end
							end,
						},
						
							------------------------分割线，下面是投射物--------------------------

						{
							Type = 'Switch', 		--开关
							Name_StringID = 4406, 	--是否投射物
							GetInitVal = function(def)
								return def.IsDefProjectile or (def.ID ~= 10100 and ProjectileDefCsv:get(def.ID) ~= nil);
							end,
							CanShow = function (def)
								return false;
							end,
							ENName = 'IsDefProjectile', JsonName = 'define_projectile',
							CurVal = false,
							AddDef = function(val, id, copyid)
								ModEditorMgr:addProjectileDef(id, copyid);
							end,
							Save = function(t_attr, def, t_property)
								def["IsDefProjectile"] = t_attr.CurVal;
								t_property["define_projectile"] = t_attr.CurVal;
								
								if t_attr.CurVal then
									local id = def.CopyID > 0 and def.CopyID or def.ID;
									local t = ProjectileDefCsv:get(id);
									if t == nil then	--投射物表里找不到这个道具
										t_property["copy_projectileid"] = 10100;	--保存默认的投射物ID
									end
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'IsProjectile')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},
						
						{
							Type = 'Selection', 	--选择框
							Name_StringID = 3681, 	--投射物模型
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'Model',
							NotShowDel = true,
							GetInitVal = function(def)
								if def.ModelRelevantID > 0 then return {def.ModelRelevantID} end
								if def.ID == 10100 then return {0} end
								return {def.ID};
							end,
							Boxes = {	
								{
									ENName = 'Model', JsonName = 'projectile_Model', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								local modelDef = ProjectileDefCsv:get(t_attr.CurVal[1]);
								if projectileDef and modelDef then
									projectileDef["Model"] = modelDef.Model;
									projectileDef["ModelRelevantID"] = modelDef.ID;
									t_property["projectile_model"] = modelDef.Model;
									t_property["projectile_model_rid"] = modelDef.ID;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4428, 	--投射物攻击力
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'AttackValue', JsonName = 'projectile_attack', CurVal = 10, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AttackValue end,	
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["AttackValue"] = t_attr.CurVal;
									t_property["projectile_attack"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Option', 		--选项
							Name_StringID = 4430, 	--攻击类型
							Desc_StringID = 4431,	--描述
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'AttackType', JsonName = 'attack_type', CurVal = 1,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.AttackType end,
							Options	= {
								{
									Name_StringID = 4508, 	--点射
									--Desc_StringID = 3666,	--描述1
									Val = 0,
								},
								{
									Name_StringID = 4509, 	--爆炸
									--Desc_StringID = 3667,	--描述2
									Val = 1,
								},							
							},
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["AttackType"] = t_attr.CurVal;
									t_property["attack_type"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4416, 	--重力
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'Gravity', JsonName = 'gravity', CurVal = 3, Min=0, Max=10, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Gravity end,							
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 3 then
									Desc_StringID = 4536;
								elseif val >= 3 and val < 6 then
									Desc_StringID = 4537;
								elseif val >= 6 and val <= 10 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["Gravity"] = t_attr.CurVal;
									t_property["gravity"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4418, 	--初始速度
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'InitSpeed', JsonName = 'speed_init', CurVal = 500, Min=0, Max=2000, Step=50,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.InitSpeed end,							
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val >= 0 and val < 500 then
									Desc_StringID = 4539;
								elseif val >= 500 and val < 1000 then
									Desc_StringID = 4540;
								elseif val >= 1000 and val <= 2000 then
									Desc_StringID = 4541;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["InitSpeed"] = t_attr.CurVal;
									t_property["speed_init"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4420, 	--速度衰减
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'SpeedDecay', JsonName = 'speed_decay', CurVal = 0.2, Min=0, Max=1, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def) return def.SpeedDecay end,							
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val >= 0 and val < 0.3 then
									Desc_StringID = 4539;
								elseif val >= 0.3 and val < 0.7 then
									Desc_StringID = 4540;
								elseif val >= 0.7 and val <= 1 then
									Desc_StringID = 4541;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["SpeedDecay"] = t_attr.CurVal;
									t_property["speed_decay"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{
							Type = 'Option', 		--选项
							Name_StringID = 4424, 	--触发条件
							Desc_StringID = 4425,	--描述
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'TriggerCondition', JsonName = 'trigger_condition', CurVal = 1,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.TriggerCondition end,
							Options	= {
								{
									Name_StringID = 4505, 	--选项1
									--Desc_StringID = 3666,	--描述1
									Val = 1,
								},
								{
									Name_StringID = 4506, 	--选项2
									--Desc_StringID = 3667,	--描述2
									Val = 2,
								},
								{
									Name_StringID = 4507, 	--选项2
									--Desc_StringID = 3666,	--描述2
									Val = 3,
								},								
							},
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["TriggerCondition"] = t_attr.CurVal;
									t_property["trigger_condition"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4426, 	--触发延迟
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'TriggerDelay', JsonName = 'trigger_delay', CurVal = 0, Min=0, Max=10, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.TriggerDelay end,							
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								if val >= 0 and val < 4 then
									Desc_StringID = 4530;
								elseif val >= 4 and val < 10 then
									Desc_StringID = 4531;
								elseif val >= 10 and val <= 64 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["TriggerDelay"] = t_attr.CurVal;
									t_property["trigger_delay"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{
							Type = 'Switch', 		--开关
							Name_StringID = 4422, 	--是否可以拾取（不会填）
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsProjectile');
							end,
							Def = 'ProjectileDef',
							ENName = 'Pickable', JsonName = 'pickable', CurVal = false,
							GetInitVal = function(def)	return def.Pickable end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef and t_attr then
									local v = false
									if type(t_attr.CurVal) == "boolean" then ---
										v = t_attr.CurVal
									else
										t_attr.CurVal = false
									end
									projectileDef["Pickable"] = v;
									t_property["pickable"] = v;
								end
							end,							
						},
						
						------------------------分割线，下面是枪--------------------------

						{
							Type = 'Switch', 		--开关
							Name_StringID = 4406, 	--是否枪
							GetInitVal = function(def)
								return def.IsDefGun or (def.ID ~= 10100 and DefMgr:getGunDef(def.ID) ~= nil);
							end,
							CanShow = function (def)
								return false;
							end,
							ENName = 'IsDefGun', JsonName = 'define_gun',
							CurVal = false,
							AddDef = function(val, id, copyid)
								ModEditorMgr:addGunDef(id, copyid);
							end,
							Save = function(t_attr, def, t_property)
								def["IsDefGun"] = t_attr.CurVal;
								t_property["define_gun"] = t_attr.CurVal;
								if t_attr.CurVal then
									local id = def.CopyID > 0 and def.CopyID or def.ID;
									local t = DefMgr:getGunDef(id);
									if t == nil then	--枪物表里找不到这个道具
										t_property["copy_gunid"] = 10100;	--保存默认的枪ID
									end

									def["UseTarget"] = 8;
									t_property["use_target"] = 8;
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'IsGun')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},

						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4444, 	--枪攻击力
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsGun');
							end,
							Def = 'GunDef',
							ENName = 'Attack', JsonName = 'gun_attack', CurVal = 10, Min=0, Max=100, Step=1,
							GetInitVal = function(def)	return def.Attack end,							
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["Attack"] = t_attr.CurVal;
									t_property["gun_attack"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4446, 	--射击间隔
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsGun');
							end,
							Def = 'GunDef',
							ENName = 'FireInterval', JsonName = 'fire_interval', CurVal = 300, Min=50, Max=1000, Step=50,
							GetInitVal = function(def)	return def.FireInterval end,							
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								if val >= 0 and val < 300 then
									Desc_StringID = 4530;
								elseif val >= 300 and val < 600 then
									Desc_StringID = 4531;
								elseif val >= 600 and val <= 1000 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["FireInterval"] = t_attr.CurVal;
									t_property["fire_interval"] = t_attr.CurVal;
								end
							end,
						},
						
						{
							Type = 'Slider', 		--滑动条
							Name_StringID = 4450, 	--弹夹数
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsGun');
							end,
							Def = 'GunDef',
							ENName = 'Magazines', JsonName = 'magazines', CurVal = 32, Min=1, Max=300, Step=1,
							GetInitVal = function(def)	return def.Magazines end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["Magazines"] = t_attr.CurVal;
									t_property["magazines"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Selection', 	--选择框
							Name_StringID = 4454, 	--子弹
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsGun');
							end,
							
							Def = 'GunDef',
							ENName = 'BulletID',
							GetInitVal = function(def)
								return {def.BulletID};
							end,
							Boxes = {	
								{
									ENName = 'BulletID', JsonName = 'bullet_id', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["BulletID"] = t_attr.CurVal[1];
									t_property["bullet_id"] = tonumber(t_attr.CurVal[1]);
									local bulletDef = ModEditorMgr:getItemDefById(tonumber(t_attr.CurVal[1]));
									if bulletDef and bulletDef.CopyID > 0 then	--记录选择的投射物文件名，作为唯一标识
										t_property["bulletid_filename"] = bulletDef.EnglishName;
									end
								end
							end,
						},
						{
							Type = 'Option', 		--连发选项
							Name_StringID = 4448, 	--设计模式
							Desc_StringID = 4598,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'ContinuousFire', JsonName = 'continuous_fire', CurVal = 0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def)	return def.ContinuousFire end,	
							Options	= {
								{
									Name_StringID = 4600, 	--选项1
									Desc_StringID = 4600,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4601, 	--选项2
									Desc_StringID = 4601,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4599, 	--选项2
									Desc_StringID = 4599,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},						
							},
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["ContinuousFire"] = t_attr.CurVal;
									t_property["continuous_fire"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Option', 		--选项
							Name_StringID = 4452, 	--子弹要求
							Desc_StringID = 4453,	--描述
							CanShow = function (def)
								return new_modeditor.MeetPremise('IsGun');
							end,
							Def = 'GunDef',
							ENName = 'NeedBullet', JsonName = 'need_bullet', CurVal = 0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.NeedBullet end,
							Options	= {
								{
									Name_StringID = 4472, 	--选项1
									Desc_StringID = 4473,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4474, 	--选项2
									Desc_StringID = 4475,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4476, 	--选项2
									Desc_StringID = 4477,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},						
							},
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["NeedBullet"] = t_attr.CurVal;
									t_property["need_bullet"] = t_attr.CurVal;
								end
							end,
							Func = function(type, notUpdate)
								new_modeditor.ChangeConfigShowPremise(type, 'NeedBullet')
								if not notUpdate then
									UpdateNewSingleEditorAttr();
								end
							end,
						},
					},
				},
			},
		},
	},

	showConfigPremise = {},
		
	ChangeConfigShowPremise = function (type, premise)
		if type == 'add' then
			table.insert(new_modeditor.showConfigPremise, premise);
		elseif type == 'remove' then
			for i=1, #(new_modeditor.showConfigPremise) do
				if premise == new_modeditor.showConfigPremise[i] then
					table.remove(new_modeditor.showConfigPremise, i);
					return;
				end
			end
		end
	end,

	ShowByAttrVal = function (def, attrName, val, defName)
		def = new_modeditor.GetCurAttrDef(defName, def)
		if def[attrName] == val then
			return true;
		else
			return false;
		end
	end,

	MeetPremise = function (premise)
		if type(premise) == 'table' then
			local isOk = true;
			--检查必要前提
			if premise.PREQ then
				for i=1, #(premise.PREQ) do
					if not new_modeditor.InShowPremise(premise.PREQ[i]) then
						isOk = false;
					end
				end
			end
			if isOk then	--满足
				if premise.OneOfPR then
					--检查需要前提
					isOk = false;
					for i=1, #(premise.OneOfPR) do
						if new_modeditor.InShowPremise(premise.OneOfPR[i]) then
							isOk = true;
							break;
						end
					end
				end
			end

			return isOk;
		else
			return new_modeditor.InShowPremise(premise);
		end
		return false;
	end,

	InShowPremise = function (premise)
		for i=1,#(new_modeditor.showConfigPremise) do
			if premise == new_modeditor.showConfigPremise[i] then
				return true;
			end
		end
		return false;
	end,

	GetTableToENName = function(t, ENName)
		for i=1, #(t) do
			if t[i].ENName and t[i].ENName == ENName then
				return t[i];
			end
		end

		return nil;
	end,

	GetCurAttrDef = function (defStr, defaultDef)
		local def;
		if defStr == 'ToolDef' then	--工具表
			def = ModEditorMgr:getToolDefById(defaultDef.ID);
			if def == nil then def = ToolDefCsv:get(defaultDef.ID) end
			if def == nil then def = ToolDefCsv:get(10100) end
		elseif defStr == 'ProjectileDef' then	--投射物表
			def = ModEditorMgr:getProjectileDefById(defaultDef.ID);
			if def == nil then def = ProjectileDefCsv:get(defaultDef.ID) end
			if def == nil then def = ProjectileDefCsv:get(10100) end
		elseif defStr == 'FoodDef' then	--食物表
			def = ModEditorMgr:getFoodDefById(defaultDef.ID);
			if def == nil then def = FoodDefCsv:get(defaultDef.ID) end
			if def == nil then def = FoodDefCsv:get(10100) end
		elseif defStr == 'GunDef' then	--枪表
			def = ModEditorMgr:getGunDefById(defaultDef.ID);
			if def == nil then def = DefMgr:getGunDef(defaultDef.ID) end
			if def == nil then def = DefMgr:getGunDef(10100) end
		else
			def = defaultDef;
		end

		return def;
	end,

	Init = function (CurEditorClass, CurrentEditDef)
		new_modeditor.showConfigPremise = {};
		for k=1, 2 do
			local attrTypeKey = "attrtype"..k;
			local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
			if t then
				t = t.Attr;
				for i=1, #(t) do
					if t[i].Type ~= 'Line' then
						local def = new_modeditor.GetCurAttrDef(t[i].Def, CurrentEditDef);

						local val = t[i].GetInitVal(def);
						if t[i].ValShowType then
							if t[i].ValShowType == 'One_Decimal' then
								val = string.format("%.1f", val);
							end
						end 
						t[i].CurVal = val;
						--init show premise
						if t[i].Func then
							if t[i].Type == 'Option' then
								t[i].Func(val, true);
							else
								if val then
									t[i].Func('add', true);
								end
							end
						end
					end
				end
			end
		end

		--特殊处理
		--[[
		if CurEditorClass == 'item' and CurrentEditDef.IsDefTool then
			if CurrentEditDef.UseTarget == 0 or CurrentEditDef.UseTarget == 4 or CurrentEditDef.UseTarget == 9 then	--默认、使用弓、使用蓄力物品才可配置
				new_modeditor.ChangeConfigShowPremise('add', 'IsUseTool');
			end
		end
		]]
	end,
}

modeditor = {
	config = {
		--方块(方块也挪过来)
		block = {
			{	--外观

				Name_StringID = 1104,
				ResetEditorName = "",
				ResetEditorDesc = "";
				Attr = {
					{	--模型选择框

						Type = 'Selection',
						Name_StringID = 4709,
						Def = 'BlockDef',
						ENName = 'Icon',
						GetInitVal = function(def)
							local val = tonumber(def.Texture2);
							if tonumber(def.Texture2) then
								return {def.Texture2};
							end
							return {def.Icon};
						end,
						Boxes = {
							{
								JsonName = 'icon',
								NotShowDel = true,
							},
						},
						CurVal = {},
						Save = function(t_attr, def, t_property)
						end,
					},
				},
			},
			{	--属性
				Name_StringID = 1105,
				Attr = {
					{	--基础属性标题

						Type = 'Line',		--分隔线
						Title_StringID = 1130,
					},
					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4200, 	--爆炸抗性
						CanShow = function (def)
							return true;
						end,
						ENName = 'AntiExplode', JsonName = 'anti_explode', CurVal = 10, Min=-1, Max=500, Step=1,
						ValShowType = 'Int',
						GetInitVal = function(def)	return def.AntiExplode end,
						GetDesc = function(val)
							local Desc_StringID = 4536;	--描述StringID
							if val >= 0 and val < 20 then
								Desc_StringID = 4536;
							elseif val >= 20 and val < 50 then
								Desc_StringID = 4537;
							elseif val >= 50 and val <= 500 then
								Desc_StringID = 4538;
							end
							return GetS(Desc_StringID);
						end,
					},

					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4202,	--硬度
						CanShow = function (def)
							return true;
						end,
						ENName = 'Hardness', JsonName = 'hardness', CurVal = 5, Min=-1, Max=200, Step=0.5,
						ValShowType = 'One_Decimal',
						GetInitVal = function(def)	return def.Hardness end,
						GetDesc = function(val)
							local Desc_StringID = 4536;	--描述StringID
							if val >= 0 and val < 10 then
								Desc_StringID = 4536;
							elseif val >= 10 and val < 30 then
								Desc_StringID = 4537;
							elseif val >= 30 and val <= 200 then
								Desc_StringID = 4538;
							end
							return GetS(Desc_StringID);
						end,
					},

					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4204,	--地滑程度
						CanShow = function (def)
							return true;
						end,
						ENName = 'Slipperiness', JsonName = 'slipperiness', CurVal = 1, Min=0.1, Max=3, Step=0.1,
						ValShowType = 'One_Decimal',
						GetInitVal = function(def)	return def.Slipperiness end,
					},

					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4206,	--燃烧速度
						CanShow = function (def)
							return true;
						end,
						ENName = 'BurnSpeed', JsonName = 'burn_speed', CurVal = 0, Min=0, Max=50, Step=1,
						ValShowType = 'Int',
						GetInitVal = function(def)	return def.BurnSpeed end,
						GetDesc = function(val)
							local Desc_StringID = 4539;	--描述StringID
							if val >= 0 and val < 10 then
								Desc_StringID = 4539;
							elseif val >= 10 and val < 30 then
								Desc_StringID = 4540;
							elseif val >= 30 and val <= 50 then
								Desc_StringID = 4541;
							end
							return GetS(Desc_StringID);
						end,
					},

					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4208,	--燃烧几率
						CanShow = function (def)
							return true;
						end,
						ENName = 'CatchFire', JsonName = 'catch_fire', CurVal = 0, Min=0, Max=100, Step=1,
						ValShowType = 'Percent',
						GetInitVal = function(def)	return def.CatchFire end,
					},

					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 4210,	--光源强度
						CanShow = function (def)
							return true;
						end,
						ENName = 'LightSrc', JsonName = 'light_src', CurVal = 0, Min=0, Max=15, Step=1,
						ValShowType = 'Int',
						GetInitVal = function(def)	return def.LightSrc end,
						GetDesc = function(val)
							local Desc_StringID = 4536;	--描述StringID
							if val >= 0 and val < 4 then
								Desc_StringID = 4536;
							elseif val >= 4 and val < 7 then
								Desc_StringID = 4537;
							elseif val >= 7 and val <= 15 then
								Desc_StringID = 4538;
							end
							return GetS(Desc_StringID);
						end,
					},

					{
						Type = 'Line',		--分割线
					},
					{
						Type = 'Selection', 	--选择框
						Name_StringID = 4460, 	--掉落道具
						CanShow = function (def)
							return true;
						end,
						Def = 'ItemDef',
						ENName = 'DropItem',
						GetInitVal = function(def)
							local t = {};
							if def.ToolMineDrops[0].item > 0 then
								table.insert(t, def.ToolMineDrops[0].item);
							end
							return t;
						end,
						Boxes = {
							{
								JsonName = 'tool_mine_drop1',
							},
						},
						CurVal = {};
						Save = function(t_attr, def, t_property)
							if #(t_attr.CurVal) > 0 then
								local id = t_attr.CurVal[1]
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setBlockForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;
								end

								def.ToolMineDrops[0].item = id;
								def.ToolMineDrops[0].odds = 100;
								t_property[t_attr.Boxes[1].JsonName] = recordId;
							else
								def.ToolMineDrops[0].item = 0;
								def.ToolMineDrops[0].odds = 0;
								t_property[t_attr.Boxes[1].JsonName] = 0;
							end
						end,
					},
					{
						Type = 'Option', 		--选项
						Name_StringID = 4462, 	--移动碰撞，0：空气， 1：固体, 2: 液体， 3：不阻挡投射物
						Desc_StringID = 4463,	--描述
						ENName = 'MoveCollide', JsonName = 'move_collide', CurVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def) return def.MoveCollide end,
						Options	= {
							{
								Name_StringID = 4464, 	--选项1
								Desc_StringID = 4465,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{
								Name_StringID = 4466, 	--选项2
								Desc_StringID = 4467,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 4468, 	--选项2
								Desc_StringID = 4469,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
							{
								Name_StringID = 4470, 	--选项3
								Desc_StringID = 4471,	--描述3
								Color = finalCommonRGB55_54_49,
								Val = 3,
							},
							{
								Name_StringID = 6375, 	--选项3
								Desc_StringID = 6376,	--描述3
								Color = finalCommonRGB55_54_49,
								Val = 4,
							},
						},
					},
					{
						Type = 'Switch', 		--开关
						Name_StringID = 4596, 	--可否被击碎
						CurVal = false,
						GetInitVal = function(def)
							return def.Breakable;
						end,
						Save = function(t_attr, def, t_property)
							if t_attr.CurVal then
								def.Breakable = true
								t_property['breakable'] = true
							else
								def.Breakable = false
								t_property['breakable'] = false
							end
						end,
						Func = function(type, notUpdate)
						end,
					},
				}
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		--生物
		actor = {
			{	--1.外观大类

				Name_StringID = 1104,
				ResetEditorName = "",
				ResetEditorDesc = "";
				ResetEditorDialogue = "",
				Attr = {
					{	--模型选择框

						Type = 'Selection',
						Name_StringID = 4709,
						Def = 'MonsterDef',
						ENName = 'Icon',
						GetInitVal = function(def)
							if def.ModelType == 0 then
								if tonumber(def.Icon) then
									return {tonumber(def.Icon)};
								else
									return {def.Icon};
								end
							elseif def.ModelType == 3 then
								local model = string.sub(def.Model,2,string.len(def.Model))
								return {tonumber(def.ModelType) * 10000 + tonumber(model)}
							elseif def.ModelType == MONSTER_CUSTOM_MODEL or def.ModelType == MONSTER_FULLY_CUSTOM_MODEL or def.ModelType == MONSTER_IMPORT_MODEL then
								return {def.Model}
							else
								return {def.ModelType};
							end
						end,
						Boxes = {
							{
								JsonName = 'icon',
								NotShowDel = true,
							},
						},
						CurVal = {},
						ResetVal = {},
						SaveAvatar = function(t_attr)
							local modVal = math.floor(tonumber(t_attr.CurVal[1])/10000);
							local modelVal = tonumber(t_attr.CurVal[1]) - math.floor(tonumber(t_attr.CurVal[1])/10000) * 10000;
							if modVal == 3 then
								--avatar模型
								local avatarPlugins = AvatarGetPlugins()
								if avatarPlugins then
									for i = 1,#avatarPlugins do
										if avatarPlugins[i].id == modelVal then
											--找到了该Avatar模型的数据
											local plugin = avatarPlugins[i]
											return plugin
										end
									end
								end
							end
						end,
						Save = function(t_attr, def, t_property, t_extendData)
						    if not def then return end

						    if type(t_attr.CurVal[1]) == 'string' then
								def["Model"] = t_attr.CurVal[1];
								t_property["model"] = t_attr.CurVal[1];
								if t_extendData and t_extendData.modeltype and t_extendData.modeltype == FULLY_ACTOR_MODEL then
									def["ModelType"] = MONSTER_FULLY_CUSTOM_MODEL;
									t_property["model_type"] = MONSTER_FULLY_CUSTOM_MODEL;
								elseif  t_extendData and t_extendData.modeltype and t_extendData.modeltype == IMPORT_ACTOR_MODEL then
									def["ModelType"] = MONSTER_IMPORT_MODEL;
									t_property["model_type"] = MONSTER_IMPORT_MODEL;
								else
									def["ModelType"] = MONSTER_CUSTOM_MODEL;
									t_property["model_type"] = MONSTER_CUSTOM_MODEL;
								end
						    else
								local modVal = math.floor(tonumber(t_attr.CurVal[1])/10000);
								local modelVal = tonumber(t_attr.CurVal[1]) - math.floor(tonumber(t_attr.CurVal[1])/10000) * 10000;

								if modVal == 1 then --角色模型
									local roleDef = DefMgr:getRoleDef(tonumber(modelVal), 0)
									if roleDef then
										def["Icon"] = tostring(modelVal);
										t_property["icon"] = tostring(modelVal);
										def["Model"] = "p"..roleDef.Model;
										t_property["model"] = "p"..tonumber(roleDef.Model);
										def["ModelType"] = tonumber(t_attr.CurVal[1]);
										t_property["model_type"] = tonumber(t_attr.CurVal[1]);
										def["TextureID"] = 0;
										t_property["TextureID"] = 0;
										--碰撞盒子跟随模型变化
										def["Height"] = roleDef.Height;
										t_property["height"] = roleDef.Height;
										def["Width"] = roleDef.Width;
										t_property["width"] = roleDef.Width;

										--受击盒子跟随模型变化
										def["HitHeight"] = roleDef.HitHeight;
										t_property["hit_height"] = roleDef.HitHeight;
										def["HitWidth"] = roleDef.HitWidth;
										t_property["hit_width"] = roleDef.HitWidth;
										def["HitThickness"] = roleDef.HitThickness;
										t_property["hit_thickness"] = roleDef.HitThickness;

									end
								elseif modVal == 2 then --皮肤模型
									local skinDef = RoleSkinCsv:get(tonumber(modelVal));
									if skinDef then
										def["Icon"] = tostring(skinDef.Head);
										t_property["icon"] = tostring(skinDef.Head);
										def["Model"] = tostring(skinDef.Model);
										t_property["model"] = tostring(skinDef.Model);
										def["ModelType"] = tonumber(t_attr.CurVal[1]);
										t_property["model_type"] = tonumber(t_attr.CurVal[1]);
										def["TextureID"] = tonumber(skinDef.TextureID);
										t_property["TextureID"] = tonumber(skinDef.TextureID);
										--碰撞盒子跟随模型变化
										def["Height"] = skinDef.Height;
										t_property["height"] = skinDef.Height;
										def["Width"] = skinDef.Width;
										t_property["width"] = skinDef.Width;
										--受击盒子跟随模型变化
										def["HitHeight"] = skinDef.HitHeight;
										t_property["hit_height"] = skinDef.HitHeight;
										def["HitWidth"] = skinDef.HitWidth;
										t_property["hit_width"] = skinDef.HitWidth;
										def["HitThickness"] = skinDef.HitThickness;
										t_property["hit_thickness"] = skinDef.HitThickness;
										def["Effect"] = skinDef.Effect;
										t_property["Effect"] = skinDef.Effect;
									end
								elseif modVal == 3 then  --Avatar模型
									def["Icon"] = tostring("a" .. modelVal);
									t_property["icon"] = tostring("a" .. modelVal);
									def["Model"] = tostring("a" .. modelVal);
									t_property["model"] = tostring("a" .. modelVal);
									def["ModelType"] = tonumber(modVal);
									t_property["model_type"] = tonumber(modVal);

									--avatar模型本身沒有定义碰撞盒子，拿皮肤的替代
									local tempDef = RoleSkinCsv:get(1)
									if tempDef then
										--碰撞盒子跟随模型变化
										def["Height"] = tempDef.Height;
										t_property["height"] = tempDef.Height;
										def["Width"] = tempDef.Width;
										t_property["width"] = tempDef.Width;
										--受击盒子跟随模型变化
										def["HitHeight"] = tempDef.HitHeight;
										t_property["hit_height"] = tempDef.HitHeight;
										def["HitWidth"] = tempDef.HitWidth;
										t_property["hit_width"] = tempDef.HitWidth;
										def["HitThickness"] = tempDef.HitThickness;
										t_property["hit_thickness"] = tempDef.HitThickness;
										def["Effect"] = tempDef.Effect;
										t_property["Effect"] = tempDef.Effect;
									end
								elseif modVal == MONSTER_HORSE_MODEL then -- 坐骑模型 -- chenweiTODO 处理坐骑类型的数据存储
									-- modelVal == mosterId
									def["Icon"] = tostring(modelVal);
									t_property["icon"] = tostring(modelVal);
									local monsterDef = MonsterCsv:getOriginal(modelVal);
									if monsterDef then
										def["Model"] 				= monsterDef.Model;
										t_property["model"] 		= monsterDef.Model;
										def["ModelType"] 			= tonumber(t_attr.CurVal[1]);
										t_property["model_type"] 	= tonumber(t_attr.CurVal[1]);
										def["TextureID"] 			= monsterDef.TextureID;
										t_property["TextureID"] 	= monsterDef.TextureID;
										--碰撞盒子跟随模型变化
										def["Height"] 				= monsterDef.Height;
										t_property["height"] 		= monsterDef.Height;
										def["Width"] 				= monsterDef.Width;
										t_property["width"] 		= monsterDef.Width;
										--受击盒子跟随模型变化
										def["HitHeight"] 			= monsterDef.HitHeight;
										t_property["hit_height"] 	= monsterDef.HitHeight;
										def["HitWidth"] 			= monsterDef.HitWidth;
										t_property["hit_width"] 	= monsterDef.HitWidth;
										def["HitThickness"] 		= monsterDef.HitThickness;
										t_property["hit_thickness"] = monsterDef.HitThickness;
										def["Effect"] 				= monsterDef.Effect;
										t_property["Effect"] 		= monsterDef.Effect;
									end
								else
									local monsterId = modelVal;
									def["Icon"] = tostring(monsterId);
									t_property["icon"] = tostring(monsterId);
									local monsterDef = MonsterCsv:getOriginal(monsterId);
									if monsterDef then
										def["Model"] = monsterDef.Model;
										t_property["model"] = monsterDef.Model;
										def["ModelType"] = 0;
										t_property["model_type"] = 0;
										def["TextureID"] = monsterDef.TextureID;
										t_property["TextureID"] = monsterDef.TextureID;
										--碰撞盒子跟随模型变化
										def["Height"] = monsterDef.Height;
										t_property["height"] = monsterDef.Height;
										def["Width"] = monsterDef.Width;
										t_property["width"] = monsterDef.Width;
										--受击盒子跟随模型变化
										def["HitHeight"] = monsterDef.HitHeight;
										t_property["hit_height"] = monsterDef.HitHeight;
										def["HitWidth"] = monsterDef.HitWidth;
										t_property["hit_width"] = monsterDef.HitWidth;
										def["HitThickness"] = monsterDef.HitThickness;
										t_property["hit_thickness"] = monsterDef.HitThickness;
										def["Effect"] = monsterDef.Effect;
										t_property["Effect"] = monsterDef.Effect;
									end
								end
							end
						end,
						Reset = function(t_attr)
							local modelView = getglobal("NewEditorModelView");
							local body = modelView:getActorbody();
							if body then
								if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
									modelView:detachActorBody(body)
								else
									body:detachUIModelView(modelView);
								end
							end
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end;
						end,
					},
					{	--模型大小滑动条

						Type = 'Slider',
						Name_StringID = 3648,
						ENName = 'ModelScale', JsonName = 'model_scale', CurVal = 1, ResetVal = 1, Min=0.1, Max=2, Step=0.1,
						ValShowType = 'One_Decimal',
						GetInitVal = function(def)	return def.ModelScale end,
						GetDesc = function(val)
							local Desc_StringID;	--描述StringID
							if val >= 0.1 and val < 0.5 then
								Desc_StringID = 4805;
							elseif val >= 0.5 and val < 0.9 then
								Desc_StringID = 4806;
							elseif val >= 0.9 and val < 1.3 then
								Desc_StringID = 4807;
							elseif val >= 1.3 and val < 1.7 then
								Desc_StringID = 4808;
							elseif val >= 1.7 --[[and val <= 2]] then
								Desc_StringID = 4809;
							end
							return GetS(Desc_StringID);
						end,
						Save = function(t_attr, def, t_property)
							def["ModelScale"] = t_attr.CurVal;
							t_property["model_scale"] = tonumber(t_attr.CurVal) or t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
				},
			},
			{	--2.属性大类
				Name_StringID = 1105,

				Attr = {
					{	--基础属性标题

						Type = 'Line',		--分隔线
						Title_StringID = 1130,
					},

					{	--生物类型选项

						Type = 'Option',
						Name_StringID = 1107,
						Desc_StringID = 1108,	--描述
						ENName = 'Type', JsonName = 'type', CurVal = 0, ResetVal = 0, DefaultVal = 1,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def) return def.Type end,
						Options	= {
							{
								Name_StringID = 697, 	--选项1
								Desc_StringID = 697,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{
								Name_StringID = 696, 	--选项2
								Desc_StringID = 696,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
						},
						Save = function(t_attr, def, t_property)
							def["Type"] = t_attr.CurVal;
							t_property["type"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						Func = function(type, notUpdate)
							if not notUpdate then
								--UpdateSingleEditorAttr();
							end
						end,
					},

					{	--生命值滑动条

						Type = 'Slider',
						Name_StringID = 4300,
						ENName = 'Life', JsonName = 'life', CurVal = 1, ResetVal = 1, Min=1, Max=1200, Step=1,
						GetInitVal = function(def)	return def.Life end,
						Save = function(t_attr, def, t_property)
							def["Life"] = t_attr.CurVal;
							t_property["life"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--攻击力滑动条

						Type = 'Slider',
						Name_StringID = 4302,
						ENName = 'Attack', JsonName = 'attack', CurVal = 1, ResetVal = 1, Min=1, Max=180, Step=1,
						GetInitVal = function(def)	return def.Attack end,
						Save = function(t_attr, def, t_property)
							def["Attack"] = t_attr.CurVal;
							t_property["attack"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--高级属性标题

						Type = 'Line', 			--分隔线
						Title_StringID = 1131,
					},

					{	--是否可移动开关

						Type = 'Switch',
						Name_StringID = 3660,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							if def.Speed > 0 then
								return true;
							else
								return false;
							end
						end,
						Save = function(t_attr, def, t_property)
							if not t_attr.CurVal then
								local t = modeditor.GetTableToENName(modeditor.config.actor[2].Attr, "Speed")
								if t then
									t.CurVal = 0;
								end
								--设置重力
								def["Mass"] = 999999;
								t_property["mass"] = 999999;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							local type = t_attr.CurVal and 'add' or 'remove';
							t_attr.Func(type, true);
						end,
						Func = function(type, notUpdate)
						 	modeditor.ChangeConfigShowPremise(type, 'IsMove')
							if not notUpdate then
								UpdateSingleEditorAttr();
							end
						end,
					},

					{	--移动速度滑动条

						Type = 'Slider',
						Name_StringID = 3649,
						CanShow = function (def)
							return modeditor.MeetPremise('IsMove');
						end,
						ENName = 'Speed', JsonName = 'speed', CurVal = 300, ResetVal=300, Min=0, Max=600, Step=1,
						GetInitVal = function(def)	return def.Speed end,
						GetDesc = function(val)
							local Desc_StringID = 4810;	--描述StringID
							if val >= 0 and val < 200 then
								Desc_StringID = 4810;
							elseif val >= 200 and val < 300 then
								Desc_StringID = 4811;
							elseif val >= 300 and val < 400 then
								Desc_StringID = 4807;
							elseif val >= 400 and val <= 500 then
								Desc_StringID = 4812;
							elseif val >= 500 and val <= 600 then
								Desc_StringID = 4813;
							end
							return GetS(Desc_StringID);
						end,
						Save = function(t_attr, def, t_property)
							def["Speed"] = t_attr.CurVal;
							t_property["speed"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--移动特性多选项

						Type = 'MultiOption',
						Name_StringID = 1132,
						Desc_StringID = 1133,	--描述
						SaveType = 'AI',
						CurVal = {},
						ResetVal = {},
						CanShow = function()
							return modeditor.MeetPremise('IsMove');
						end,
						GetOptions = function()
							return OpenAiTable.GetSortOpenFeature2Class(1);
						end,
						GetInitVal = function(def)
							local t_val = {};
							local t_openAI = OpenAiTable.GetOpenFeature2Class(1);
							local t_sortKey = OpenAiTable.SortbyOrderId(t_openAI);
							for i=1, #(t_sortKey) do
								local actorAI = GetActorAI(def.ID, t_sortKey[i]);
								local val =  actorAI ~= "";
								table.insert(t_val, val);
							end
							return t_val;
						end,
						Save = function(t_attr, t_SaveAI)
							local t = OpenAiTable.GetSortOpenFeature2Class(1);
							for i=1, #(t) do
								if t_attr.CurVal[i] then
									table.insert(t_SaveAI, t[i].Parameters);
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end;
						end,
					},

					{
						Type = 'Line',		--分割线
					},

					{	--击杀怪物增加等级经验

						Type = 'Slider',
						Name_StringID = 34230,
						CanShow = function (def)
							return true;
						end,
						ENName = 'LvExp', JsonName = 'level_exp', CurVal = 1, ResetVal=1, Min=0, Max=10000, Step=1,
						GetInitVal = function(def)	return def.LevelExp end,
						Save = function(t_attr, def, t_property)
							def["LevelExp"] = t_attr.CurVal;
							t_property["level_exp"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						--鼠标悬浮提示
						MoustOverTip = 34231,
					},

					{
						Type = 'Line',		--分割线
					},

					{	--掉落开关

						Type = 'Switch',
						Name_StringID = 3650,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							if def.DropItem[0] > 0 or def.DropItem[1] > 0 or def.DropItem[2] > 0 or def.DropExp > 0 then
								return true;
							else
								return false;
							end
						end,
						Save = function(t_attr, def, t_property)
							if not t_attr.CurVal then
								local t = modeditor.GetTableToENName(modeditor.config.actor[2].Attr, "DropItem")
								if t then
									t.CurVal = {0, 0, 0};
								end
								t = modeditor.GetTableToENName(modeditor.config.actor[2].Attr, "DropExp")
								if t then
									t.CurVal = 0;
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							local type = t_attr.CurVal and 'add' or 'remove';
							t_attr.Func(type, true);
						end,
						Func = function(type, notUpdate)
						 	modeditor.ChangeConfigShowPremise(type, 'IsDrop')
							if not notUpdate then
								UpdateSingleEditorAttr();
							end
						end,
					},

					{	--掉落经验滑动条

						Type = 'Slider',
						Name_StringID = 3652,
						CanShow = function (def)
							return modeditor.MeetPremise('IsDrop');
						end,
						ENName = 'DropExp', JsonName = 'drop_exp', CurVal = 1, ResetVal=1, Min=0, Max=100, Step=1,
						GetInitVal = function(def)	return def.DropExp end,
						Save = function(t_attr, def, t_property)
							def["DropExp"] = t_attr.CurVal;
							t_property["drop_exp"] = t_attr.CurVal;
							if t_attr.CurVal == 0 then
								t_property["drop_exp_prob"] = 0
							else
								t_property["drop_exp_prob"] = 100
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--掉落道具选择框

						Type = 'Selection',
						Name_StringID = 3651,
						CanShow = function (def)
							return modeditor.MeetPremise('IsDrop');
						end,
						Def = 'ItemDef',
						ENName = 'DropItem',
						GetInitVal = function(def)
							local t = {};
							for i=1, 3 do
								local itemId = def.DropItem[i-1];
								table.insert(t, itemId);
							end
							return t;
						end,
						Boxes = {
							{
								JsonName = 'drop_item1',
							},
							{
								JsonName = 'drop_item2',
							},
							{
								JsonName = 'drop_item3',
							},
						},
						CurVal = {};
						ResetVal = {},
						Save = function(t_attr, def, t_property)
							for i=1, 3 do
								local id = t_attr.CurVal[i]
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setActorForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end

								def["DropItem"][i-1] = t_attr.CurVal[i];
								t_property[t_attr.Boxes[i].JsonName] = recordId;
								if t_attr.CurVal[i] == 0 then
									def["DropItemOdds"][i-1] = 0;
									t_property["drop_item_prob"..i] = 0;
								else
									def["DropItemOdds"][i-1] = 100;
									t_property["drop_item_prob"..i] = 100;
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end;
						end,
					},

					{
						Type = 'Line',		--分割线
					},

					{	--背包滑动条

						Type = 'Slider',
						Name_StringID = 1089,
						ENName = 'BagNum', JsonName = 'bag_num', CurVal = 10, ResetVal=10, Min=1, Max=30, Step=1,
						GetInitVal = function(def)	return def.BagNum end,
						Save = function(t_attr, def, t_property)
							def["BagNum"] = t_attr.CurVal;
							t_property["bag_num"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--饥饿度滑动条

						Type = 'Slider',
						Name_StringID = 8604,
						ENName = 'Food', JsonName = 'food', CurVal = 100, ResetVal=100, Min=1, Max=200, Step=1,
						GetInitVal = function(def)	return def.Food end,
						Save = function(t_attr, def, t_property)
							def["Food"] = t_attr.CurVal;
							t_property["food"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},

					{	--饥饿度消耗滑动条

						Type = 'Slider',
						Name_StringID = 1090,
						ENName = 'FoodReduce', JsonName = 'food_reduce', CurVal = 0, ResetVal=0, Min=0, Max=100, Step=1,
						GetInitVal = function(def)	return def.FoodReduce end,
						Save = function(t_attr, def, t_property)
							def["FoodReduce"] = t_attr.CurVal;
							t_property["food_reduce"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						GetDesc = function(val)
							return GetS(4611);
						end,
					},
				},
			},
			{
				Name_StringID = 3026,	--战斗
				Attr = {
					{	--基础属性标题

						Type = 'Line', 			--分隔线
						Title_StringID = 1130,
					},

					{	--生物阵营选项

						Type = 'Option',
						Name_StringID = 3656,
						Desc_StringID = 4833,	--描述
						ENName = 'TeamID', JsonName = 'team_id', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def) return def.TeamID end,
						Save = function(t_attr, def, t_property)
							def["TeamID"] = t_attr.CurVal;
							t_property["team_id"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						Options	= {
							{
								Name_StringID = 3663, 	--选项1
								Desc_StringID = 3666,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{
								Name_StringID = 3664, 	--选项2
								Desc_StringID = 3667,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 3665, 	--选项2
								Desc_StringID = 3666,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
							{
								Name_StringID = 4822, 	--选项3
								Desc_StringID = 3666,	--描述3
								Color = finalCommonRGB55_54_49,
								Val = 3,
							},
							{
								Name_StringID = 4823, 	--选项4
								Desc_StringID = 3666,	--描述4
								Color = finalCommonRGB55_54_49,
								Val = 4,
							},
							{
								Name_StringID = 4824, 	--选项5
								Desc_StringID = 3666,	--描述5
								Color = finalCommonRGB55_54_49,
								Val = 5,
							},
							{
								Name_StringID = 4825, 	--选项6
								Desc_StringID = 3666,	--描述6
								Color = finalCommonRGB55_54_49,
								Val = 6,
							},
						},
					},

					{	--攻击距离滑动条

						Type = 'Slider',
						Name_StringID = 3661,
						ENName = 'AttackDistance', JsonName = 'attack_distance', CurVal=2.0, ResetVal=2.0, Min=1.0, Max=24.0, Step=0.1,
						ValShowType = 'One_Decimal',
						GetInitVal = function(def)	return tonumber(def.AttackDistance) end,
						Save = function(t_attr, def, t_property)
							def["AttackDistance"] = tonumber(t_attr.CurVal);
							t_property["attack_distance"] = tonumber(t_attr.CurVal);
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					    GetDesc = function(val)
							local Desc_StringID;	--描述StringID
							if val < 4.0 then
								Desc_StringID = 4814;
							elseif val >= 4.0 and val < 10.0 then
								Desc_StringID = 4815;
							elseif val >= 10.0 then
								Desc_StringID = 4816;
							end
							return GetS(Desc_StringID);
						end,
					},

					{	--视野范围滑动条

						Type = 'Slider',
						Name_StringID = 4304,
						ENName = 'ViewDistance', JsonName = 'view_distance', CurVal=16, ResetVal=16, Min=1, Max=24, Step=1,
						GetInitVal = function(def)	return def.ViewDistance end,
						Save = function(t_attr, def, t_property)
							def["ViewDistance"] = t_attr.CurVal;
							t_property["view_distance"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						GetDesc = function(val)
							local Desc_StringID = 4817;	--描述StringID
							if val >= 0 and val < 4 then
								Desc_StringID = 4817;
							elseif val >= 4 and val < 10 then
								Desc_StringID = 4818;
							elseif val >= 10 and val <= 24 then
								Desc_StringID = 4819;
							end
							return GetS(Desc_StringID);
						end,
					},

					{	--高级属性标题

						Type = 'Line', 			--分隔线
						Title_StringID = 1131,
					},

					{	--是否能攻击开关

						Type = 'Switch',
						Name_StringID = 1136,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(5);	--攻击类型
							for i=1, #(t_openAI) do
								if GetActorAI(def.ID, t_openAI[i].Parameters.name) ~= "" then	--有攻击类型
									return true;
								end
							end
							return false;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							local type = t_attr.CurVal and 'add' or 'remove';
							print("kekeke Attack Switch", type, t_attr.ResetVal);
							t_attr.Func(type, true);
						end,

						Save = function(t_attr, def, t_property)
							if not t_attr.CurVal then
								--攻击类型AI去除
								local t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "AttackType")
								if t then
									t.CurVal = 0;
								end
								--攻击模式AI去除
								t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "AttackMode")
								if t then
									t.CurVal = 0;
								end
								--攻击效果选项去除
								local t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "BuffId")
								if t then
									t.CurVal = {0};
								end
								--攻击特性AI去除
								t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "AttackFeature")
								if t then
									for i=1, #(t.CurVal) do
										t.CurVal[i] = false;
									end
								end
							end
						end,

						Func = function(type, notUpdate)
						 	modeditor.ChangeConfigShowPremise(type, 'IsAttack')
							if not notUpdate then
								UpdateSingleEditorAttr();
							end
						end,
					},

					{	--攻击类型选项	近战 远程 爆炸

						Type = 'Option',
						Name_StringID = 4410,
						Desc_StringID = 1134,	--描述
						ENName = 'AttackType',
						CanShow = function (def)
							return modeditor.MeetPremise('IsAttack');
						end,
						CurVal = 1,
						ResetVal = 1,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(5);	--攻击类型
							for i=1, #(t_openAI) do
								if GetActorAI(def.ID, t_openAI[i].Parameters.name) ~= "" then	--有攻击类型
									return i;
								end
							end
							return 1;
						end,
						SaveType = 'DefAndAI',
						Save = function(t_attr, def, t_property, t_SaveAI)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(5);
							for i=1, #(t_openAI) do
								if t_attr.CurVal == i then
									if t_openAI[i].Parameters.name == 'projectile_attack' then
										local t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "ProjectileID");
										t_openAI[i].Parameters["projectileid"] = t.CurVal[1];

										local id = t.CurVal[1]

										-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
										if id >= USER_MOD_NEWID_BASE then
											local paramDef = ModEditorMgr:getItemDefById(id)
											ModEditorMgr:setActorForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
										end
									end
									table.insert(t_SaveAI, t_openAI[i].Parameters);
									if t_openAI[i].AttackType then
										def["AttackType"] = t_openAI[i].AttackType;
										t_property["attack_type"] = t_openAI[i].AttackType;
									end

								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							t_attr.Func(t_attr.CurVal, true);
						end,
						Options	= {
							{
								Name_StringID = 4152, 	--选项2
								Desc_StringID = 4152,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 4153, 	--选项2
								Desc_StringID = 4153,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
							{
								Name_StringID = 4154, 	--选项2
								Desc_StringID = 4154,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 3,
							},
						},
						Func = function(type, notUpdate)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(5)
							if t_openAI[type] then
								if t_openAI[type].Parameters.name == 'projectile_attack' then
									modeditor.ChangeConfigShowPremise('add', 'IsProjectileAttack')
								else
									modeditor.ChangeConfigShowPremise('remove', 'IsProjectileAttack')
								end
							end
							if not notUpdate then
								UpdateSingleEditorAttr();
							end
						end,
					},

					{	--投射物选择框

						Type = 'Selection',
						Name_StringID = 1141,
						ENName = 'ProjectileID',
						CanShow = function (def)
							return modeditor.MeetPremise({	PREQ={'IsAttack', 'IsProjectileAttack'} });
						end,
						GetInitVal = function(def)
							local aiStr = GetActorAI(def.ID, "projectile_attack");
							if aiStr ~= "" then
								return {aiStr.projectileid};
							end
							return {12051};
						end,
						Boxes = {
							{
								NotShowDel = true,
							},
						},
						CurVal = {},
						ResetVal = {},
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end
						end,
					},

					{	--攻击模式选项

						Type = 'Option',
						Name_StringID = 6175,
						Desc_StringID = 1135,	--描述
						ENName = 'AttackMode',
						CanShow = function (def)
							return modeditor.MeetPremise('IsAttack');
						end,
						CurVal = 1,
						ResetVal = 1,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(4);	--攻击模式
							for i=1, #(t_openAI) do
								if GetActorAI(def.ID, t_openAI[i].Parameters.name) ~= "" then
									return i;
								end
							end
							return 1;
						end,
						SaveType = 'AI',
						Save = function(t_attr, t_SaveAI)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(4);
							for i=1, #(t_openAI) do
								if t_attr.CurVal == i then
									if t_openAI[i].Parameters.name == 'leap_at_target' then		--跳跃攻击
										local t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "AttackDistance");
										t_openAI[i].Parameters["max_range"] = t.CurVal*100;
									end
									table.insert(t_SaveAI, t_openAI[i].Parameters);
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
						Options	= {
							{
								Name_StringID = 3655, 	--选项2
								Desc_StringID = 3655,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 6246, 	--选项2
								Desc_StringID = 6246,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
						},
						Func = function(type, notUpdate)
							if not notUpdate then
								--UpdateSingleEditorAttr();
							end
						end,
					},

					{	--攻击附带效果开关

						Type = 'Switch',
						Name_StringID = 1137,
						CanShow = function (def)
							return modeditor.MeetPremise('IsAttack');
						end,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							return def.BuffId > 0;
						end,
						Save = function(t_attr, def, t_property)
							if not t_attr.CurVal then
								--攻击效果选项去除
								local t = modeditor.GetTableToENName(modeditor.config.actor[3].Attr, "BuffId")
								if t then
									t.CurVal = {0};
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							local type = t_attr.CurVal and 'add' or 'remove';
							t_attr.Func(type, true);
						end,
						Func = function(type, notUpdate)
						 	modeditor.ChangeConfigShowPremise(type, 'IsAttackEffect')
							if not notUpdate then
								UpdateSingleEditorAttr();
							end
						end,
					},

					{	--攻击效果选项
						Type = 'Selection',
						Name_StringID = 1138,
						CanShow = function (def)
							return modeditor.MeetPremise({	PREQ={'IsAttack', 'IsAttackEffect'} });
						end,
						ENName = 'BuffId',
						GetInitVal = function(def)
							return {def.BuffId};
						end,
						Boxes = {
							{
								JsonName = 'buff_id',
							},
						},
						CurVal = {};
						ResetVal = {},
						Save = function(t_attr, def, t_property)
							local id = t_attr.CurVal[1]
							def["BuffId"] = id;
							local recordId = id;
							if type(id) == 'number' and id > USER_MOD_NEWID_BASE_STATUS and id < USER_MOD_NEWID_BASE_STATUS*5 then
								local paramDef = ModEditorMgr:getStatusDefById(id)
								ModEditorMgr:setActorForeignId(def, id, ModEditorMgr:getStatusKey(paramDef))
							-- elseif type(id) == 'number' and id <= USER_MOD_NEWID_BASE 
							-- 	and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
							-- 	and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
							-- 	recordId = id + CUSTOM_MOD_QUOTE;
							end
							t_property[t_attr.Boxes[1].JsonName] = recordId;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end
						end,
					},

					{	--攻击特性多选项

						Type = 'MultiOption',
						Name_StringID = 1139,
						Desc_StringID = 1140,	--描述
						ENName = 'AttackFeature',
						CanShow = function (def)
							return modeditor.MeetPremise('IsAttack');
						end,
						CurVal = {},
						ResetVal = {},
						GetOptions = function()
							return OpenAiTable.GetSortOpenFeature2Class(2);	--战斗特性
						end,
						GetInitVal = function(def)
							local t_val = {};
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(2);
							for i=1, #(t_openAI) do
								local actorAI = GetActorAI(def.ID, t_openAI[i].Parameters.name);
								local val =  actorAI ~= "";
								table.insert(t_val, val);
							end
							return t_val;
						end,
						SaveType = 'AI',
						Save = function(t_attr, t_SaveAI)
							local t_openAI = OpenAiTable.GetSortOpenFeature2Class(2);
							for i=1, #(t_openAI) do
								if t_attr.CurVal[i] then
									table.insert(t_SaveAI, t_openAI[i].Parameters);
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end
						end,
						Func = function(type, notUpdate)
							if not notUpdate then
								--UpdateSingleEditorAttr();
							end
						end,
					},
				},
			},
			{
				Name_StringID = 589,	--战斗
			},
			{	-- 互动大类
				Name_StringID = 11005,

				InteractData=
				{
					AllNum = 0;
					PlotAndTask = {};
				},

				Init = function ()

				end,

				GetAllNum= function()

				end,

				GetTaskAndPlot = function ()
					-- body
				end,

				SetPlotAndTask = function ()

				end,

			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		--道具
		item = {
			{	--外观

				Name_StringID = 1104,
				ResetEditorName = "",
				ResetEditorDesc = "";
				Attr = {
					{	--模型选择框

						Type = 'Selection',
						Name_StringID = 4709,
						Def = 'ItemDef',
						ENName = 'Icon',
						GetInitVal = function(def)
							return {def.Icon};
						end,
						Boxes = {
							{
								JsonName = 'icon',
								NotShowDel = true,
							},
						},
						CurVal = {},
						Save = function(t_attr, def, t_property)
						end,
					},
					{	--模型大小滑动条
						Type = 'Slider',
						Name_StringID = 3648,
						ENName = 'ModelScale', JsonName = 'ModelScale', CurVal = 1, ResetVal = 1, Min=0.1, Max=2, Step=0.1,
						ValShowType = 'One_Decimal',
						GetInitVal = function(def) return def.ModelScale end,
						GetDesc = function(val)
							local Desc_StringID;	--描述StringID
							if val >= 0.1 and val < 0.5 then
								Desc_StringID = 4805;
							elseif val >= 0.5 and val < 0.9 then
								Desc_StringID = 4806;
							elseif val >= 0.9 and val < 1.3 then
								Desc_StringID = 4807;
							elseif val >= 1.3 and val < 1.7 then
								Desc_StringID = 4808;
							elseif val >= 1.7 --[[and val <= 2]] then
								Desc_StringID = 4809;
							end
							return GetS(Desc_StringID);
						end,
						Def = 'PhysicsActorDef',
						AddDef = function(val, id, copyid)
							local target_id = copyid
							if not copyid or copyid <= 0 then
								target_id = id
							end
							local itemDef = ItemDefCsv:get(target_id)
							if not itemDef then
								print("item not found", copyid)
								return
							end
							if PhysicsActorCsv:get(itemDef.ID) then --physicsactor没有独立的type
								ModEditorMgr:addPhysicsActorDef(id,copyid);
							end
						end,
						Save = function(t_attr, def, t_property)
							local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
							if physicsActorDef then

								physicsActorDef["ModelScale"] = t_attr.CurVal;
								t_property["ModelScale"] = tonumber(t_attr.CurVal) or t_attr.CurVal;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
				},
			},

			{	--属性
				Name_StringID = 1105,



				Attr = {
						{	--AddDef
							Type = 'NoUI',
							CanShow = function (def)
								return false;
							end,
							AddDef = function(val, id, copyid)
								local target_id = copyid
								if not copyid or copyid <= 0 then
									target_id = id
								end
								local itemDef = ItemDefCsv:get(target_id)
								if not itemDef then
									print("item not found", copyid)
									return
								end
								local item_type = itemDef.Type

								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_PROJECTILE then
									ModEditorMgr:addToolDef(id, copyid);
								end
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									ModEditorMgr:addProjectileDef(id, copyid);
								end
								if PhysicsActorCsv:get(itemDef.ID) then --physicsactor没有独立的type
									ModEditorMgr:addPhysicsActorDef(id,copyid);
								end
								if item_type == ITEM_TYPE_GUN then
									ModEditorMgr:addGunDef(id, copyid);
								end
								if item_type == ITEM_TYPE_FOOD then
									ModEditorMgr:addFoodDef(id, copyid);
								end
                                if item_type == ITEM_TYPE_PACK then
                                    --ModEditorMgr:addFoodDef(id, copyid);
                                end

                                --TODO:增加装备定义
                                if item_type == ITEM_TYPE_EQUIP then
                                	ModEditorMgr:addToolDef(id, copyid);
									ModEditorMgr:addItemEquipDef(id, copyid);
								end
							end,
							Save = function(t_attr, def, t_property)
							end,
						},

						------------------------分割线，基础属性--------------------------
						--共用的基础属性
						{	--基础属性

							Type = 'Line',		--分隔线
							Title_StringID = 1130,
							CanShow = function (def)
								return true
							end,
						},
						{	--道具类型选项
							Type = 'OptionReadOnly',
							Name_StringID = 4478,
							Desc_StringID = 4478,	--描述
							ENName = 'Type', JsonName = 'type', CurVal=0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.Type end,
							Options	= {
								{
									Name_StringID = 4480, 	--普通类
									Desc_StringID = 4480,
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
								{
									Name_StringID = 4481, 	--工具类
									Desc_StringID = 4481,
									Color = finalCommonRGB55_54_49,
									Val = 3,
								},
								{
									Name_StringID = 4485, 	--弓类
									Desc_StringID = 4485,
									Color = finalCommonRGB55_54_49,
									Val = 7,
								},
								{
									Name_StringID = 4486, 	--投掷类
									Desc_StringID = 4486,
									Color = finalCommonRGB55_54_49,
									Val = 8,
								},
								{
									Name_StringID = 4488, 	--枪械类
									Desc_StringID = 4488,
									Color = finalCommonRGB55_54_49,
									Val = 10,
								},
								{
									Name_StringID = 4489, 	--食物类
									Desc_StringID = 4489,
									Color = finalCommonRGB55_54_49,
									Val = 11,
								},
                                {
                                    Name_StringID = 21754, 	--包裹类
                                    Desc_StringID = 21754,
                                    Color = finalCommonRGB55_54_49,
                                    Val = 15,
                                },
                                {
                                    Name_StringID = 100006, --装备类
                                    Desc_StringID = 21754,
                                    Color = finalCommonRGB55_54_49,
                                    Val = 9,
                                },
							},
							Save = function(t_attr, def, t_property)
							end,
						},
						{	--堆叠数
							Type = 'Slider', 		--滑动条
							Name_StringID = 4550, 	--堆叠数
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_MISC or item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'ItemDef',
							ENName = 'StackMax', JsonName = 'stack_max', CurVal=99, Min=1, Max=99, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.StackMax end,
							GetDesc = function(val)
								local Desc_StringID = 4817;	--描述StringID
								if val <= 16 then
									Desc_StringID = 4533;
								elseif val > 16 and val <= 32 then
									Desc_StringID = 4534;
								elseif val > 32 then
									Desc_StringID = 4535;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local itemDef = ModEditorMgr:getItemDefById(def.ID);
								if itemDef then
									itemDef["StackMax"] = t_attr.CurVal;
									t_property["stack_max"] = t_attr.CurVal;
								end
							end,
						},
						{	--攻击力
							Type = 'Slider', 		--滑动条
							Name_StringID = 4412, 	--攻击力
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Attack', JsonName = 'attack', CurVal=10, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Attack end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Attack"] = t_attr.CurVal;
									t_property["attack"] = t_attr.CurVal;
								end
							end,
						},
						{	--攻击消耗耐久度
							Type = 'Slider', 		--滑动条
							Name_StringID = 4551, 	--攻击消耗耐久度
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'AtkDuration', JsonName = 'attack_consume', CurVal=1, Min=1, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AtkDuration end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["AtkDuration"] = t_attr.CurVal;
									t_property["attack_consume"] = t_attr.CurVal;
								end
							end,
						},
						{	--是否可投掷
							Type = 'Switch', 		--开关
							Name_StringID = 4568, 	--是否可投掷
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'CanThrow', JsonName = 'can_throw', CurVal=false,
							GetInitVal = function(def)	return def.CanThrow end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["CanThrow"] = t_attr.CurVal;
									t_property["can_throw"] = t_attr.CurVal;
								end
							end,
							Func = function(type, notUpdate)
								modeditor.ChangeConfigShowPremise(type, "CanThrow")
								if not notUpdate then
									UpdateSingleEditorAttr();
								end
							end,
						},
						{	--蓄力模式
							Type = 'Option',
							Name_StringID = 4569,
							Desc_StringID = 4569,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return modeditor.MeetPremise('CanThrow');
								end
								return false
							end,
							ENName = 'AccumulatorType', JsonName = 'accumulator_type', CurVal=2, ResetVal=2, DefaultVal=2,
							GetOption = function(val, options)
								if options and val then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							Def = 'ToolDef',
							GetInitVal = function(def) return def.AccumulatorType end,
							Options	= {
								{
									Name_StringID = 4570, 	--普通蓄力
									Desc_StringID = 4570,
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4571, 	--蓄力满才能释放成功
									Desc_StringID = 4571,
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4572, 	--无需蓄力
									Desc_StringID = 4572,
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
							},
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["AccumulatorType"] = t_attr.CurVal;
									t_property["accumulator_type"] = tonumber(t_attr.CurVal);
								end
							end,
							Func = function(val, notUpdate)
								local operator = 'add'
								if val == 2 then
									operator = 'remove'
								end
								modeditor.ChangeConfigShowPremise(operator, "NeedAccumulatorTime")
								if not notUpdate then
									UpdateSingleEditorAttr();
								end
							end,
						},
						{	--投掷间隔
							Type = 'Slider', 		--滑动条
							Name_StringID = 4593, 	--投掷间隔
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return modeditor.MeetPremise('CanThrow') and not modeditor.MeetPremise('NeedAccumulatorTime');
								end
								return false
							end,
							Def = 'ItemDef',
							ENName = 'CoolDown', JsonName = 'cooldown', CurVal=0.2, Min=0.1, Max=1, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.CoolDown/1000 end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val <= 0.4  then
									Desc_StringID = 4530;
								elseif val > 0.4 and val <= 0.7 then
									Desc_StringID = 4531;
								elseif val > 0.7 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local itemDef = ModEditorMgr:getItemDefById(def.ID);
								if itemDef then
									itemDef["CoolDown"] = tonumber(t_attr.CurVal)*1000;
									t_property["cooldown"] = tonumber(t_attr.CurVal)*1000;
								end
							end,
						},
						{	--蓄力时间
							Type = 'Slider', 		--滑动条
							Name_StringID = 4440, 	--蓄力时间
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return modeditor.MeetPremise('CanThrow') and modeditor.MeetPremise('NeedAccumulatorTime');
								elseif item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'AccumulatorTime', JsonName = 'accumulate_time', CurVal=0.5, Min=0, Max=10, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.AccumulatorTime end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val <= 1.7  then
									Desc_StringID = 4530;
								elseif val > 1.7 and val <= 3.3 then
									Desc_StringID = 4531;
								elseif val > 3.3 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["AccumulatorTime"] = t_attr.CurVal;
									t_property["accumulate_time"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--初始速度加成
							Type = 'Slider', 		--滑动条
							Name_StringID = 4567, 	--初始速度加成
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_BOW then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'SpeedAdd', JsonName = 'speed_add', CurVal=0, Min=0, Max=2, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.SpeedAdd end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val <= 0.7  then
									Desc_StringID = 4539;
								elseif val > 0.7 and val <= 1.4 then
									Desc_StringID = 4540;
								elseif val > 1.4 then
									Desc_StringID = 4540;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["SpeedAdd"] = tonumber(t_attr.CurVal);
									t_property["speed_add"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--弹药
							Type = 'Selection', 	--选择框
							Name_StringID = 4454, 	--弹药
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								local toolDef = ToolDefCsv:get(def.ID);
								if item_type == ITEM_TYPE_BOW then
									return true;--toolDef.ConsumeID > 0
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'ConsumeID',
							GetInitVal = function(def)
								return {def.ConsumeID};
							end,
							Boxes = {
								{
									ENName = 'ConsumeID', JsonName = 'consume_itemid', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									local id = tonumber(t_attr.CurVal[1])
									local recordId = id;
									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									if id >= USER_MOD_NEWID_BASE then
										local paramDef = ModEditorMgr:getItemDefById(id)
										ModEditorMgr:setItemForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;
									end

									toolDef["ConsumeID"] = id;
									t_property["consume_itemid"] = recordId;
									local consumeDef = ModEditorMgr:getItemDefById(id);
									if consumeDef and consumeDef.CopyID > 0 then	--记录选择的投射物文件名，作为唯一标识
										t_property["consumeid_filename"] = consumeDef.EnglishName;
									end
								end
							end,
						},
						{	--消耗数量
							Type = 'Slider', 		--滑动条
							Name_StringID = 4456, 	--消耗数量
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								local toolDef = ToolDefCsv:get(def.ID);
								if item_type == ITEM_TYPE_BOW then
									return true; --toolDef.ConsumeID > 0
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'ConsumeCount', JsonName = 'consume_count', CurVal=1, Min=1, Max=10, Step=1,
							GetInitVal = function(def)	return def.ConsumeCount end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 4  then
									Desc_StringID = 4536;
								elseif val > 4 and val <= 7 then
									Desc_StringID = 4537;
								elseif val > 7 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["ConsumeCount"] = t_attr.CurVal;
									t_property["consume_count"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						--枪的基础属性
						{	--枪的类型选项
							Type = 'Option',
							Name_StringID = 4574,
							Desc_StringID = 4594,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							ENName = 'GunType', JsonName = 'gun_type', CurVal=10105, ResetVal=10105, DefaultVal=10105,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							Def = 'GunDef',
							GetInitVal = function(def) return def.GunType end,
							Options	= {
								{
									Name_StringID = 4575, 	--手枪类
									Desc_StringID = 4575,
									Color = finalCommonRGB55_54_49,
									Val = 10105,
								},
								{
									Name_StringID = 4576, 	--冲锋枪类
									Desc_StringID = 4576,
									Color = finalCommonRGB55_54_49,
									Val = 10106,
								},
								{
									Name_StringID = 4577, 	--狙击枪类
									Desc_StringID = 4577,
									Color = finalCommonRGB55_54_49,
									Val = 10107,
								},
								{
									Name_StringID = 4578, 	--重机枪类
									Desc_StringID = 4578,
									Color = finalCommonRGB55_54_49,
									Val = 10108,
								},
								--[[
								{
									Name_StringID = 4579, 	--霰弹枪类
									Desc_StringID = 4579,
									Color = finalCommonRGB55_54_49,
									Val = 10109,
								},]]
							},
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["GunType"] = t_attr.CurVal;
									t_property["gun_type"] = t_attr.CurVal;
								end
							end,
						},
						{	--枪的攻击力
							Type = 'Slider', 		--滑动条
							Name_StringID = 4444, 	--枪攻击力
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'Attack', JsonName = 'gun_attack', CurVal=10, Min=0, Max=100, Step=1,
							GetInitVal = function(def)	return def.Attack end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["Attack"] = t_attr.CurVal;
									t_property["gun_attack"] = t_attr.CurVal;
								end
							end,
						},
						{	--枪的射击间隔
							Type = 'Slider', 		--滑动条
							Name_StringID = 4446, 	--射击间隔
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'FireInterval', JsonName = 'fire_interval', CurVal=100, Min=10, Max=500, Step=10,
							GetInitVal = function(def)	return def.FireInterval end,
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								if val >= 0 and val < 100 then
									Desc_StringID = 4530;
								elseif val >= 100 and val < 200 then
									Desc_StringID = 4531;
								elseif val >= 200 and val <= 500 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["FireInterval"] = t_attr.CurVal;
									t_property["fire_interval"] = t_attr.CurVal;
								end
							end,
						},
						{	--枪的弹夹子弹数
							Type = 'Slider', 		--滑动条
							Name_StringID = 4450, 	--弹夹数
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'Magazines', JsonName = 'magazines', CurVal=32, Min=1, Max=300, Step=1,
							GetInitVal = function(def)	return def.Magazines end,
							GetDesc = function(val)
								local Desc_StringID = 4533;	--描述StringID
								if val <= 30  then
									Desc_StringID = 4533;
								elseif val > 30 and val <= 100 then
									Desc_StringID = 4534;
								elseif val > 100 then
									Desc_StringID = 4535;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["Magazines"] = t_attr.CurVal;
									t_property["magazines"] = t_attr.CurVal;
								end
							end,
						},
						{	--枪的子弹
							Type = 'Selection', 	--选择框
							Name_StringID = 4454, 	--子弹
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'BulletID',
							GetInitVal = function(def)
								return {def.BulletID};
							end,
							Boxes = {
								{
									ENName = 'BulletID', JsonName = 'bullet_id', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									local id = tonumber(t_attr.CurVal[1])
									local recordId = id;
									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									if id >= USER_MOD_NEWID_BASE then
										local paramDef = ModEditorMgr:getItemDefById(id)
										ModEditorMgr:setItemForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;
									end

									gunDef["BulletID"] = id;
									t_property["bullet_id"] = recordId;
									local bulletDef = ModEditorMgr:getItemDefById(id);
									if bulletDef and bulletDef.CopyID > 0 then	--记录选择的投射物文件名，作为唯一标识
										t_property["bulletid_filename"] = bulletDef.EnglishName;
									end
								end
							end,
						},
						{	--枪的弹药模式
							Type = 'Option', 		--选项
							Name_StringID = 4452, 	--子弹要求
							Desc_StringID = 4453,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'NeedBullet', JsonName = 'need_bullet', CurVal=0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.NeedBullet end,
							Options	= {
								{
									Name_StringID = 4472, 	--选项1
									Desc_StringID = 4473,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4474, 	--选项2
									Desc_StringID = 4475,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4476, 	--选项2
									Desc_StringID = 4477,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
							},
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["NeedBullet"] = t_attr.CurVal;
									t_property["need_bullet"] = t_attr.CurVal;
								end
							end,
						},
						{
							Type = 'Option', 		--连发选项
							Name_StringID = 4448, 	--设计模式
							Desc_StringID = 4598,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'ContinuousFire', JsonName = 'continuous_fire', CurVal = 0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def)	return def.ContinuousFire end,
							Options	= {
								{
									Name_StringID = 4600, 	--选项1
									Desc_StringID = 4600,	--描述1
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 4601, 	--选项2
									Desc_StringID = 4601,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4599, 	--选项2
									Desc_StringID = 4599,	--描述2
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
							},
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["ContinuousFire"] = t_attr.CurVal;
									t_property["continuous_fire"] = t_attr.CurVal;
								end
							end,
						},
						{	--枪的初始速度加成
							Type = 'Slider', 		--滑动条
							Name_StringID = 4567, 	--初始速度加成
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'SpeedAdd', JsonName = 'gun_speed_add', CurVal=0, Min=0, Max=2, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.SpeedAdd end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val <= 0.7  then
									Desc_StringID = 4539;
								elseif val > 0.7 and val <= 1.4 then
									Desc_StringID = 4540;
								elseif val > 1.4 then
									Desc_StringID = 4540;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["SpeedAdd"] = tonumber(t_attr.CurVal);
									t_property["gun_speed_add"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--枪的重量
							Type = 'Slider', 		--滑动条
							Name_StringID = 4585, 	--重量
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_GUN then
									return true
								end
								return false
							end,
							Def = 'GunDef',
							ENName = 'Weight', JsonName = 'weight', CurVal=0.5, Min=0, Max=20, Step=0.5,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.Weight/1000 end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 6.6  then
									Desc_StringID = 4536;
								elseif val > 6.6 and val <= 13.2 then
									Desc_StringID = 4537;
								elseif val > 13.2 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local gunDef = ModEditorMgr:getGunDefById(def.ID);
								if gunDef then
									gunDef["Weight"] = tonumber(t_attr.CurVal)*1000;
									t_property["weight"] = tonumber(t_attr.CurVal)*1000;
								end
							end,
						},
						--食物的基础属性
						{	--食物的使用时间
							Type = 'Slider', 		--滑动条
							Name_StringID = 4432, 	--使用时间
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'FoodDef',
							ENName = 'UseTime', JsonName = 'use_time', CurVal=1.5, Min=0.1, Max=5, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def) return def.UseTime/20 end,
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								if val >= 0 and val < 2 then
									Desc_StringID = 4530;
								elseif val >= 2 and val < 4 then
									Desc_StringID = 4531;
								elseif val >= 4 then
									Desc_StringID = 4532;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["UseTime"] = tonumber(t_attr.CurVal)*20;
									t_property["use_time"] = tonumber(t_attr.CurVal)*20;
								end
							end,
						},
						{	--食物的加饥饿度
							Type = 'Slider', 		--滑动条
							Name_StringID = 4434, 	--加饥饿度
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'FoodDef',
							ENName = 'AddFood', JsonName = 'add_food', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AddFood end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["AddFood"] = t_attr.CurVal;
									t_property["add_food"] = t_attr.CurVal;
								end
							end,
						},
						{	--食物的加饥饿耐力
							Type = 'Slider', 		--滑动条
							Name_StringID = 4436, 	--加饥饿耐力
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'FoodDef',
							ENName = 'AddFoodSat', JsonName = 'add_foodstate', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AddFoodSat end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["AddFoodSat"] = t_attr.CurVal;
									t_property["add_foodstate"] = t_attr.CurVal;
								end
							end,
						},
						{	--食物的体力值
							Type = 'Slider', 		--滑动条
							Name_StringID = 1564, 	--加体力值
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'FoodDef',
							ENName = 'HealStamina', JsonName = 'heal_stamina', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.HealStamina end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["HealStamina"] = t_attr.CurVal;
									t_property["heal_stamina"] = t_attr.CurVal;
								end
							end,
						},
						{	--食物的加治疗血量
							Type = 'Slider', 		--滑动条
							Name_StringID = 4438, 	--加治疗血量
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_FOOD then
									return true
								end
								return false
							end,
							Def = 'FoodDef',
							ENName = 'HealAmount', JsonName = 'heal_actor', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.HealAmount end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local foodDef = ModEditorMgr:getFoodDefById(def.ID);
								if foodDef then
									foodDef["HealAmount"] = t_attr.CurVal;
									t_property["heal_actor"] = t_attr.CurVal;
								end
							end,
						},

						------------------------分割线，采集属性--------------------------
						{	--采集属性
							Type = 'Line',
							Title_StringID = 4587,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
						},
						{	--工具类型
							Type = 'Option',
							Name_StringID = 4552,
							Desc_StringID = 4595,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Type', JsonName = 'tool_type', CurVal=6, ResetVal=6, DefaultVal=6,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.Type end,
							Options	= {
								{
									Name_StringID = 4553, 	--无
									Desc_StringID = 4553,
									Color = finalCommonRGB55_54_49,
									Val = 6,
								},
								{
									Name_StringID = 4554, 	--斧头
									Desc_StringID = 4554,
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},
								{
									Name_StringID = 4555, 	--镐
									Desc_StringID = 4555,
									Color = finalCommonRGB55_54_49,
									Val = 2,
								},
								{
									Name_StringID = 4556, 	--铲子
									Desc_StringID = 4556,
									Color = finalCommonRGB55_54_49,
									Val = 3,
								},
								--[[{
									Name_StringID = 4557, 	--剪刀
									Desc_StringID = 4557,
									Color = finalCommonRGB55_54_49,
									Val = 5,
								},]]
							},
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Type"] = t_attr.CurVal;
									t_property["tool_type"] = t_attr.CurVal;
								end
							end,
							Reset = function(t_attr)
							end,
							Func = function(type, notUpdate)
							end,
						},
						{	--工具等级
							Type = 'Slider', 		--滑动条
							Name_StringID = 4563, 	--工具等级
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Level', JsonName = 'tool_level', CurVal=1, Min=1, Max=5, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Level end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 2 then
									Desc_StringID = 4536;
								elseif val > 2 and val <= 4 then
									Desc_StringID = 4537;
								elseif val > 4 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Level"] = t_attr.CurVal;
									t_property["tool_level"] = t_attr.CurVal;
								end
							end,
						},
						{	--效率加成
							Type = 'Slider', 		--滑动条
							Name_StringID = 4408, 	--效率加成
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Efficiency', JsonName = 'tool_efficient', CurVal=0, Min=0, Max=1000, Step=10,
							ValShowType = 'Percent',
							GetInitVal = function(def)	return def.Efficiency end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 330 then
									Desc_StringID = 4536;
								elseif val > 330 and val <= 660 then
									Desc_StringID = 4537;
								elseif val > 660 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Efficiency"] = tonumber(t_attr.CurVal);
									t_property["tool_efficient"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--采集消耗耐久度
							Type = 'Slider', 		--滑动条
							Name_StringID = 4564, 	--采集消耗耐久度
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'CollectDuration', JsonName = 'collect_consume', CurVal=1, Min=1, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.CollectDuration end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["CollectDuration"] = t_attr.CurVal;
									t_property["collect_consume"] = t_attr.CurVal;
								end
							end,
						},

						------------------------分割线，耐久属性----------------------------
						{	--耐久属性
							Type = 'Line',
							Title_StringID = 4588,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE or item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
						},
						{	--耐久度
							Type = 'Slider', 		--滑动条
							Name_StringID = 4414, 	--耐久度
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE or item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Duration', JsonName = 'tool_duration', CurVal=100, Min=1, Max=2000, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Duration end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 500 then
									Desc_StringID = 4536;
								elseif val >= 500 and val < 1500 then
									Desc_StringID = 4537;
								elseif val >= 1500 and val <= 2000 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef["Duration"] = t_attr.CurVal;
									t_property["tool_duration"] = t_attr.CurVal;
								end
							end,
						},
						{	--修理材料1
							Type = 'Selection', 	--选择框
							Name_StringID = 4565, 	--修理材料1
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE or item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'RepairId',
							GetInitVal = function(def)
								return {def.RepairId[0]};
							end,
							Boxes = {
								{
									ENName = 'RepairId', JsonName = 'tool_repareid1', NotShowDel = true,
								},
							},
							CurVal = {};
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									local id = tonumber(t_attr.CurVal[1])
									local recordId = id;
									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									if id >= USER_MOD_NEWID_BASE then
										local paramDef = ModEditorMgr:getItemDefById(id)
										ModEditorMgr:setItemForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;										
									end

									toolDef.RepairId[0] = id;
									t_property["tool_repareid1"] = recordId;
								end
							end,
						},
						{	--修理量1
							Type = 'Slider', 		--滑动条
							Name_StringID = 4566, 	--修理量
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_TOOL or item_type == ITEM_TYPE_BOW or item_type == ITEM_TYPE_TOOL_PROJECTILE or item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'RepairAmount1', JsonName = 'tool_repare_amount1', CurVal=50, Min=1, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.RepairAmount[0] end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33 then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.RepairAmount[0] = t_attr.CurVal;
									t_property["tool_repare_amount1"] = t_attr.CurVal;
								end
							end,
						},

						------------------------分割线，投射物属性--------------------------
						{	--投射物属性
							Type = 'Line',
							Title_StringID = 4589,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
						},
						{	--攻击力
							Type = 'Slider', 		--滑动条
							Name_StringID = 4428, 	--投射物攻击力
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'AttackValue', JsonName = 'projectile_attack', CurVal=10, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.AttackValue end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 33  then
									Desc_StringID = 4536;
								elseif val > 33 and val <= 66 then
									Desc_StringID = 4537;
								elseif val > 66 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["AttackValue"] = tonumber(t_attr.CurVal);
									t_property["projectile_attack"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--攻击类型
							Type = 'Option', 		--选项
							Name_StringID = 4430, 	--攻击类型
							Desc_StringID = 4431,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'AttackType', JsonName = 'attack_type', CurVal=1, ResetVal=1, DefaultVal=1,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.AttackType end,
							Options	= {
								{
									Name_StringID = 4508, 	--点射
									--Desc_StringID = 3666,	--描述1
									Val = 0,
								},
								{
									Name_StringID = 4509, 	--爆炸
									--Desc_StringID = 3667,	--描述2
									Val = 1,
								},
							},
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["AttackType"] = t_attr.CurVal;
									t_property["attack_type"] = t_attr.CurVal;
								end
							end,
						},
						{	--重力
							Type = 'Slider', 		--滑动条
							Name_StringID = 4416, 	--重力
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									if modeditor.MeetPremise('CanPhysx') then
										return false
									else
										return true
									end
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'Gravity', JsonName = 'gravity', CurVal=3, Min=0, Max=10, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.Gravity end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val >= 0 and val < 3 then
									Desc_StringID = 4536;
								elseif val >= 3 and val < 6 then
									Desc_StringID = 4537;
								elseif val >= 6 and val <= 10 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							--Func = function() 		--开启物理设置开关时，质量置为不可编辑
							--	local state = modeditor.MeetPremise('CanPhysx') and 1 or 0;
							--	UpdateDisableBtn(state);
							--end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["Gravity"] = t_attr.CurVal;
									t_property["gravity"] = t_attr.CurVal;
								end
							end,
						},
						{	--初始速度
							Type = 'Slider', 		--滑动条
							Name_StringID = 4418, 	--初始速度
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'InitSpeed', JsonName = 'speed_init', CurVal=500, Min=0, Max=2000, Step=10,
							ValShowType = 'Int',
							GetInitVal = function(def)	return def.InitSpeed end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val >= 0 and val < 500 then
									Desc_StringID = 4539;
								elseif val >= 500 and val < 1000 then
									Desc_StringID = 4540;
								elseif val >= 1000 and val <= 2000 then
									Desc_StringID = 4541;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["InitSpeed"] = t_attr.CurVal;
									t_property["speed_init"] = t_attr.CurVal;
								end
							end,
						},
						{	--速度衰减
							Type = 'Slider', 		--滑动条
							Name_StringID = 4420, 	--速度衰减
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									if modeditor.MeetPremise('CanPhysx') then
										return false
									else
										return true
									end
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'SpeedDecay', JsonName = 'speed_decay', CurVal=0.2, Min=0, Max=1, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def) return def.SpeedDecay end,
							GetDesc = function(val)
								local Desc_StringID = 4539;	--描述StringID
								if val >= 0 and val < 0.3 then
									Desc_StringID = 4539;
								elseif val >= 0.3 and val < 0.7 then
									Desc_StringID = 4540;
								elseif val >= 0.7 and val <= 1 then
									Desc_StringID = 4541;
								end
								return GetS(Desc_StringID);
							end,
							--Func = function() 		--开启物理设置开关时，速度衰减置为不可编辑
							--	local state = modeditor.MeetPremise('CanPhysx') and 1 or 0;
							--	UpdateDisableBtn(state);
							--end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["SpeedDecay"] = t_attr.CurVal;
									t_property["speed_decay"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--触发条件
							Type = 'Option', 		--选项
							Name_StringID = 4424, 	--触发条件
							Desc_StringID = 4425,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'TriggerCondition', JsonName = 'trigger_condition', CurVal=1,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.TriggerCondition end,
							Options	= {
								{
									Name_StringID = 4505, 	--选项1
									--Desc_StringID = 3666,	--描述1
									Val = 1,
								},
								{
									Name_StringID = 4506, 	--选项2
									--Desc_StringID = 3667,	--描述2
									Val = 2,
								},
								{
									Name_StringID = 4507, 	--选项2
									--Desc_StringID = 3666,	--描述2
									Val = 3,
								},
								{
									Name_StringID = 4692, 	--选项2
									--Desc_StringID = 3666,	--描述2
									Val = 4,
								},
								{
									Name_StringID = 4693, 	--不触发
									Val = 5,
								},
							},
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["TriggerCondition"] = t_attr.CurVal;
									t_property["trigger_condition"] = t_attr.CurVal;
								end
							end,
						},
						{	--触发延迟
							Type = 'Slider', 		--滑动条
							Name_StringID = 4426, 	--触发延迟
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'TriggerDelay', JsonName = 'trigger_delay', CurVal=0, Min=0, Max=10, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def)	return def.TriggerDelay end,
							GetDesc = function(val)
								local Desc_StringID = 4530;	--描述StringID
								val = tonumber(val)
								if val>1000 then
									if val >= 5000 and val < 6500 then
										Desc_StringID = 4530;
									elseif val >= 6500 and val < 7500 then
										Desc_StringID = 4531;
									elseif val >= 7500 and val <= 8000 then
										Desc_StringID = 4532;
									end
								else
									if val >= 0 and val < 4 then
										Desc_StringID = 4530;
									elseif val >= 4 and val < 10 then
										Desc_StringID = 4531;
									elseif val >= 10 and val <= 64 then
										Desc_StringID = 4532;
									end
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef then
									projectileDef["TriggerDelay"] = t_attr.CurVal;
									t_property["trigger_delay"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--是否可拾取
							Type = 'Switch', 		--开关
							Name_StringID = 4422, 	--是否可以拾取（不会填）
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'Pickable', JsonName = 'pickable', CurVal=false,
							GetInitVal = function(def)	return def.Pickable end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef and t_attr then
									local v = false
									if type(t_attr.CurVal) == "boolean" then ---容错
										v = t_attr.CurVal
									else
										t_attr.CurVal = false
									end
									projectileDef["Pickable"] = v
									t_property["pickable"] = v
								end
							end,
						},
						{	--是否可破坏方块
							Type = 'Switch', 		--开关
							Name_StringID = 4597, 	--是否可以拾取（不会填）
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PROJECTILE or item_type == ITEM_TYPE_TOOL_PROJECTILE then
									return true
								end
								return false
							end,
							Def = 'ProjectileDef',
							ENName = 'Break', JsonName = 'break', CurVal=false,
							GetInitVal = function(def)	return def.Break end,
							Save = function(t_attr, def, t_property)
								local projectileDef = ModEditorMgr:getProjectileDefById(def.ID);
								if projectileDef and t_attr then
									local v = false
									if type(t_attr.CurVal) == "boolean" then ---
										v = t_attr.CurVal
									else
										t_attr.CurVal = false
									end
									projectileDef["Break"] = v
									t_property["break"] = v
								end
							end,
						},

						---------------------------物理道具属性----------------------------------------
						{	--物理设置分割线
							Type = 'Line',
							Title_StringID = 6583,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									if physicsActorDef.EditType == 2 or physicsActorDef.EditType == 3 then
										return true
									end
								end
								return false
							end,
							Def = 'PhysicsActorDef'
						},
						{	--是否开启高级物理
							Type = 'PhysxSwitch',
							Name_StringID = 11504,
							Desc_StringID = 11505,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									if physicsActorDef.EditType == 2 or physicsActorDef.EditType == 3 then
										return true
									end
								end
								return false
							end,
							Def = 'PhysicsActorDef',
							ENName = 'EditType', JsonName = 'EditType', Curval = 1,
							GetInitVal = function(def) return def.EditType end,
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["EditType"] = t_attr.CurVal;
									t_physics["EditType"] = t_attr.CurVal;
								end
							end,
							Func = function(type, notUpdate)
								modeditor.ChangeConfigShowPremise(type, "CanPhysx")
								if not notUpdate then
									UpdateSingleEditorAttr();
									UpdatePhysxModelScale();
								end
							end,
						},
						{	--物理材质选择
							Type = 'PhysxOption',
							Name_StringID = 11506,
							Desc_StringID = 11517,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									return modeditor.MeetPremise('CanPhysx');
								else
									return false
								end
							end,
							Def = 'PhysicsActorDef',
							ENName = 'MaterialID', JsonName = 'MaterialID', CurVal=1, ResetVal=1, DefaultVal=1,
							GetOption = function(val, options)
							end,
							GetInitVal = function(def)
								local id = def.MaterialID
								if DefMgr:getPhysicsMaterialDef(id) then
									return id;
								else
									return 11;
								end
							end,
							Options	= {
							},
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["MaterialID"] = t_attr.CurVal;
									t_physics["MaterialID"] = t_attr.CurVal;
								end
							end,
						},
						{	--线性阻力
							Type = 'PhysxSlider',
							Name_StringID = 11508,
							Desc_StringID = 11509,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									return modeditor.MeetPremise('CanPhysx');
								else
									return false
								end
							end,
							Def = 'PhysicsActorDef',
							ENName = 'Drag', JsonName = 'Drag', CurVal=0.5, Min=0, Max=1, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def) return def.Drag	end,
							GetDesc = function(val)
								local Desc_StringID = 4537;	--描述StringID
								if val >= 0 and val < 0.4 then
									Desc_StringID = 4536;
								elseif val >= 0.4 and val < 0.8 then
									Desc_StringID = 4537;
								elseif val >= 0.8 and val <= 1.0 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["Drag"] = t_attr.CurVal;
									t_physics["Drag"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--角阻力
							Type = 'PhysxSlider',
							Name_StringID = 11510,
							Desc_StringID = 11511,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									return modeditor.MeetPremise('CanPhysx');
								else
									return false
								end
							end,
							Def = 'PhysicsActorDef',
							ENName = 'AngularDrag', JsonName = 'AngularDrag', CurVal=0.5, Min=0, Max=1, Step=0.1,
							ValShowType = 'One_Decimal',
							GetInitVal = function(def) return def.AngularDrag end,
							GetDesc = function(val)
								local Desc_StringID = 4537;	--描述StringID
								if val >= 0 and val < 0.4 then
									Desc_StringID = 4536;
								elseif val >= 0.4 and val < 0.8 then
									Desc_StringID = 4537;
								elseif val >= 0.8 and val <= 1.0 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["AngularDrag"] = t_attr.CurVal;
									t_physics["AngularDrag"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--质量
							Type = 'PhysxSlider',
							Name_StringID = 11512,
							Desc_StringID = 11513,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									return modeditor.MeetPremise('CanPhysx');
								else
									return false
								end
							end,
							Def = 'PhysicsActorDef',
							ENName = 'Mass', JsonName = 'Mass', CurVal=1000, Min=300, Max=10000, Step=100,
							ValShowType = 'Int',
							GetInitVal = function(def) return def.Mass	end,
							GetDesc = function(val)
								local Desc_StringID = 4537;	--描述StringID
								if val >= 100 and val < 1100 then
									Desc_StringID = 4536;
								elseif val >= 1100 and val < 5000 then
									Desc_StringID = 4537;
								elseif val >= 5000 and val <= 10000 then
									Desc_StringID = 4538;
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["Mass"] = t_attr.CurVal;
									t_physics["Mass"] = t_attr.CurVal;
								end
							end,
						},
						{	--受重力影响
							Type = 'PhysxSwitch',
							Name_StringID = 11514,
							Desc_StringID = 11515,
							CanShow = function (def)
								if not def then return false; end
								local physicsActorDef;
								if def.ID then physicsActorDef = PhysicsActorCsv:get(def.ID) end
								if physicsActorDef == nil and def.ActorID then physicsActorDef = PhysicsActorCsv:get(def.ActorID) end
								if physicsActorDef then
									return modeditor.MeetPremise('CanPhysx');
								else
									return false
								end
							end,
							Def = 'PhysicsActorDef',
							ENName = 'UseGravity', JsonName = 'UseGravity', CurVal = 1,
							GetInitVal = function(def) return def.UseGravity end,
							Save = function(t_attr, def, t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["UseGravity"] = t_attr.CurVal;
									t_physics["UseGravity"] = t_attr.CurVal;
								end
							end,
						},
						{	--形状ID
							Type = 'PhysxShape',
							ENName = 'ShapeID', JsonName = 'ShapeID', CurVal = 1,
							Def = 'PhysicsActorDef',
							GetInitVal = function(def) return def.ShapeID end,
							Save = function(t_attr,def,t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["ShapeID"] = t_attr.CurVal;
									t_physics["ShapeID"] = t_attr.CurVal;
								end
							end,
						},
						{	--形状参数1
							Type = 'PhysxShape',
							ENName = 'ShapeVal1', JsonName = 'ShapeVal1', CurVal = 1,
							Def = 'PhysicsActorDef',
							GetInitVal = function(def) return def.ShapeVal1 end,
							Save = function(t_attr,def,t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["ShapeVal1"] = t_attr.CurVal;
									t_physics["ShapeVal1"] = t_attr.CurVal;
								end
							end,
						},
						{	--形状参数2
							Type = 'PhysxShape',
							ENName = 'ShapeVal2', JsonName = 'ShapeVal2', CurVal = 1,
							Def = 'PhysicsActorDef',
							GetInitVal = function(def) return def.ShapeVal2 end,
							Save = function(t_attr,def,t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["ShapeVal2"] = t_attr.CurVal;
									t_physics["ShapeVal2"] = t_attr.CurVal;
								end
							end,
						},
						{	--形状参数3
							Type = 'PhysxShape',
							ENName = 'ShapeVal3', JsonName = 'ShapeVal3', CurVal = 1,
							Def = 'PhysicsActorDef',
							GetInitVal = function(def) return def.ShapeVal3 end,
							Save = function(t_attr,def,t_physics)
								local physicsActorDef = ModEditorMgr:getPhysicsActorDefById(def.ID)
								if physicsActorDef then
									physicsActorDef["ShapeVal3"] = t_attr.CurVal;
									t_physics["ShapeVal3"] = t_attr.CurVal;
								end
							end,
						},
						---------------------------------------------包裹的基础属性---------------------------------------------------
						{	--包裹的类型选项
							Type = 'Option',
							Name_StringID = 21756,
							Desc_StringID = 21759,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									return true
								end
								return false
							end,
							ENName = 'iPackType', JsonName = 'gun_type', CurVal=0, ResetVal=0, DefaultVal=0,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							Def = 'PackDef',
							GetInitVal = function(def)
								CurVal = 0
								local packDef = getCurrentPackDef()
								if packDef then
									CurVal = packDef.iPackType
								end

								return CurVal
							end,
							Options	= {
								{
									Name_StringID = 21757, 	--固定产出
									Desc_StringID = 4575,
									Color = finalCommonRGB55_54_49,
									Val = 0,
								},
								{
									Name_StringID = 21760, 	--随机产出
									Desc_StringID = 4576,
									Color = finalCommonRGB55_54_49,
									Val = 1,
								},

							},
							Save = function(t_attr, def, t_property)
								local packDef = getCurrentPackDef()
								packDef.iPackType = t_attr.CurVal
								t_property["iPackType"] = t_attr.CurVal
							end,
							-- Func = function(val)
							-- 	selectPackType(val)
							-- end,
						},
						{	--产出物品数
							Type = 'PackSlider', 		--滑动条
							Name_StringID = 21761, 	--产出物品数
							Desc_StringID = 21804,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									local packDef = getCurrentPackDef()
									if packDef.iPackType == 1 then
										return true
									end
								end
								return false
							end,
							Def = 'PackDef',
							ENName = 'iMaxOpenNum', JsonName = 'iMaxOpenNum', CurVal=1, Min=1, Max=20, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								CurVal = 1
								local packDef = getCurrentPackDef()
								if packDef then
									CurVal = packDef.iMaxOpenNum
								end

								return CurVal
							end,
							Save = function(t_attr, def, t_property)
								local packDef = getCurrentPackDef()
								if packDef then
									packDef.iMaxOpenNum = t_attr.CurVal
									t_property["iMaxOpenNum"] = t_attr.CurVal
								end
							end,
						},
						{	--允许重复
							Type = 'PackSwitch', 		--开关
							Name_StringID = 21762, 	--允许重复
							Desc_StringID = 21805,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									local packDef = getCurrentPackDef()
									if packDef and packDef.iPackType == 1 then
										return true
									end
								end
								return false
							end,
							Def = 'PackDef',
							ENName = 'iRepeat', JsonName = 'iRepeat', CurVal=false,
							GetInitVal = function(def)
								local packDef = getCurrentPackDef()
								if packDef and packDef.iRepeat ~= 0 then
									return true
								end

								return false
							end,
							Save = function(t_attr, def, t_property)
								local packDef = getCurrentPackDef()
								if packDef then
									t_property["iRepeat"] = t_attr.CurVal;
								end
							end,
							Func = function(type, notUpdate)
								switchPackRepeatStatus(type == "add")
							end,
						},
						{	--高级属性
							Type = 'Line',
							Title_StringID = 1131,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									return true
								end
								return false
							end,
						},
						{	--开启条件
							Type = 'Switch', 		--开关
							Name_StringID = 21758, 	--开启条件
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK  then
									return true
								end
								return false
							end,
							Def = 'PackDef',
							ENName = 'CanCondition', JsonName = 'CanCondition', CurVal=false,
							GetInitVal = function(def)
								local packDef = getCurrentPackDef()
								if packDef and packDef.iNeedCostItem ~= 0 then
									return true
								end

								return false
							end,
							Save = function(t_attr, def, t_property)
								t_property["CanCondition"] = t_attr.CurVal;
							end,
						},
						{	--需要数量
							Type = 'Slider', 		--滑动条
							Name_StringID = 21763, 	--需要数量
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									local packDef = getCurrentPackDef()
									if packDef and packDef.iNeedCostItem ~= 0 then
										return true
									end
								end
								return false
							end,
							Def = 'PackDef',
							ENName = 'iCostItemNum', JsonName = 'iCostItemNum', CurVal=1, Min=1, Max=64, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								CurVal = 1
								local packDef = getCurrentPackDef()
								if not packDef then return 1 end

								CurVal = packDef.iCostItemInfo%1000
								if CurVal == 0 then
									CurVal = 1;
								end
								return CurVal
							end,
							Save = function(t_attr, def, t_property)
								t_property["iCostItemNum"] = t_attr.CurVal;
							end,
						},
						{	--消耗道具
							Type = 'Selection', 	--选择框
							Name_StringID = 21764, 	--消耗道具
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_PACK then
									local packDef = getCurrentPackDef()
									if packDef and packDef.iNeedCostItem ~= 0 then
										return true
									end
								end
								return false
							end,
							Def = 'PackDef',
							ENName = 'iCostItem',
							GetInitVal = function(def)
								local packDef = getCurrentPackDef()
								if not packDef then return {0} end
								local itemid = math.floor(packDef.iCostItemInfo/1000)
								local def = ItemDefCsv:getAutoUseForeignID(itemid)
								itemid = def and def.ID or 101

								return {itemid}
							end,
							Save = function(t_attr, def, t_property)
								t_property["iCostItem"] = t_attr.CurVal;
							end,
							Boxes = {
								{
									JsonName = 'drop_item1',
									NotShowDel = true,
								},
							},
							CurVal = {0},
						},

						---------------------------------------------装备类型属性---------------------------------------------
						--[[
						{	--装备类型(和上面的"工具类型"是互斥的, 同时只有一个显示, 都是修改参数'tool_type')
							Type = 'Option',
							Name_StringID = 4552,
							Desc_StringID = 4595,	--描述
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'Type', JsonName = 'tool_type', CurVal=6, ResetVal=6, DefaultVal=6,
							GetOption = function(val, options)
								if options then
									for k, v in pairs(options) do
										if v.Val == val then
											return v;
										end
									end
								end
								return nil;
							end,
							GetInitVal = function(def) return def.Type end,
							Options	= {
								{
									--8:头盔 9:胸甲 10:护腿 11:靴子 16:披风
									Name_StringID = 4553, 	--8:头盔
									Desc_StringID = 4553,
									Color = finalCommonRGB55_54_49,
									Val = 8,
								},
								{
									Name_StringID = 4554, 	--9:胸甲
									Desc_StringID = 4554,
									Color = finalCommonRGB55_54_49,
									Val = 9,
								},
								{
									Name_StringID = 4555, 	--10:护腿
									Desc_StringID = 4555,
									Color = finalCommonRGB55_54_49,
									Val = 10,
								},
								{
									Name_StringID = 4555, 	--11:靴子
									Desc_StringID = 4555,
									Color = finalCommonRGB55_54_49,
									Val = 11,
								},
								{
									Name_StringID = 4555, 	--16:披风
									Desc_StringID = 4555,
									Color = finalCommonRGB55_54_49,
									Val = 16,
								},
							},
							Save = function(t_attr, def, t_property)
								-- local toolDef = ModEditorMgr:getToolDefById(def.ID);
								-- if toolDef then
								-- 	toolDef["Type"] = t_attr.CurVal;
								-- 	t_property["tool_type"] = t_attr.CurVal;
								-- end
							end,
							Reset = function(t_attr)
							end,
							Func = function(type, notUpdate)
							end,
						},
						]]
						{	--物理防御分割线
							Type = 'Line',
							Title_StringID = 33044,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef'
						},
						{	--近战防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33045, 	--近战防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorPunch', JsonName = 'EquipArmorPunch', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.Armors[0];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.Armors[0] = tonumber(t_attr.CurVal);
									t_property["EquipArmorPunch"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--远程防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33046, 	--远程防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorRange', JsonName = 'EquipArmorRange', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.Armors[1];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.Armors[1] = tonumber(t_attr.CurVal);
									t_property["EquipArmorRange"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--爆炸防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33047, 	--爆炸防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorExplosion', JsonName = 'EquipArmorExplosion', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.Armors[2];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.Armors[2] = tonumber(t_attr.CurVal);
									t_property["EquipArmorExplosion"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--元素防御分割线
							Type = 'Line',
							Title_StringID = 33048,
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef'
						},
						{	--燃烧防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33049, 	--燃烧防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorBurn', JsonName = 'EquipArmorBurn', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.MagicArmors[0];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.MagicArmors[0] = tonumber(t_attr.CurVal);
									t_property["EquipArmorBurn"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--毒素防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33050, 	--毒素防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorToxin', JsonName = 'EquipArmorToxin', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.MagicArmors[1];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.MagicArmors[1] = tonumber(t_attr.CurVal);
									t_property["EquipArmorToxin"] = tonumber(t_attr.CurVal);
								end
							end,
						},
						{	--混乱防御
							Type = 'Slider', 		--滑动条
							Name_StringID = 33051, 	--混乱防御
							CanShow = function (def)
								if not def then return false; end
								local item_type = def.Type
								if item_type == ITEM_TYPE_EQUIP then
									return true
								end
								return false
							end,
							Def = 'ToolDef',
							ENName = 'EquipArmorChaos', JsonName = 'EquipArmorChaos', CurVal=0, Min=0, Max=100, Step=1,
							ValShowType = 'Int',
							GetInitVal = function(def)
								local val = def.MagicArmors[2];
								return val;
							end,
							GetDesc = function(val)
								local Desc_StringID = 4536;	--描述StringID
								if val <= 20 then
									Desc_StringID = 4536;	--低
								elseif val <= 80 then
									Desc_StringID = 4537;	--中
								elseif val > 80 then
									Desc_StringID = 4538;	--高
								end
								return GetS(Desc_StringID);
							end,
							Save = function(t_attr, def, t_property)
								local toolDef = ModEditorMgr:getToolDefById(def.ID);
								if toolDef then
									toolDef.MagicArmors[2] = tonumber(t_attr.CurVal);
									t_property["EquipArmorChaos"] = tonumber(t_attr.CurVal);
								end
							end,
						},

				},
			},
			{
				Name_StringID = 8502,	--道具技能
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		--配方
		craft = {
			{	--配方属性

				Name_StringID = 1232,
				CraftingItemID = DefMgr:getCraftEmptyHandID(),
				Attr = {
					{	--配方结果单个选择框
						Type = 'SingleSel',
						--Name_StringID = 4709,
						Def = 'CraftDef',
						ENName = 'ResultID',
						GetInitVal = function(def)
							return {id=def.ResultID, num=0};
						end,
						CurVal = {id=0, num=0},
						ResetVal = {id=0, num=0},
						Save = function(t_attr, def, t_property)
							if def then
								local id = t_attr.CurVal.id
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setCraftingForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end

								def["ResultID"] = t_attr.CurVal.id;
								t_property["result_id"] = recordId;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal.id = t_attr.ResetVal.id;
							t_attr.CurVal.num = t_attr.ResetVal.num;
						end,
					},
					{	--配方类型选项

						Type = 'Option',
						Name_StringID = 1236,
						Desc_StringID = 1237,	--描述
						ENName = 'Type', 
						JsonName = 'type', 
						CurVal = 0, 
						ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def) 
							local val = 0
							if def.getTypeSize and def.getTypeValue then
								if def:getTypeSize() > 0 then
									val = def:getTypeValue(0)
								end
							elseif type(def.Type) == 'number' then
								val = def.Type
							end
							return val
						end,
						Options	= {
							{--常用
								Name_StringID = 2135, 	--选项1
								Desc_StringID = 2135,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{--装备
								Name_StringID = 2136, 	--选项2
								Desc_StringID = 2136,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{--道具
								Name_StringID = 2137, 	--选项3
								Desc_StringID = 2137,	--描述3
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
							{--材料
								Name_StringID = 2138, 	--选项4
								Desc_StringID = 2138,	--描述4
								Color = finalCommonRGB55_54_49,
								Val = 3,
							},
							{--建筑
								Name_StringID = 2139, 	--选项5
								Desc_StringID = 2139,	--描述5
								Color = finalCommonRGB55_54_49,
								Val = 4,
							},
							{--装饰
								Name_StringID = 2140, 	--选项6
								Desc_StringID = 2140,	--描述6
								Color = finalCommonRGB55_54_49,
								Val = 5,
							},
							{--机械
								Name_StringID = 2141, 	--选项7
								Desc_StringID = 2141,	--描述7
								Color = finalCommonRGB55_54_49,
								Val = 6,
							},
						},
						Save = function(t_attr, def, t_property)
							if def.setTypeValue then
								def:setTypeValue(t_attr.CurVal)
							else
								def["Type"] = t_attr.CurVal;
							end
							t_property["type"] = t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--模型大小滑动条

						Type = 'Slider',
						Name_StringID = 1238,
						ENName = 'ResultCount', JsonName = 'result_count', CurVal = 1, ResetVal = 1, Min=1, Max=64, Step=1,
						GetInitVal = function(def)	return def.ResultCount end,
						GetDesc = function(val)
							return "";
						end,
						Save = function(t_attr, def, t_property)
							def["ResultCount"] = t_attr.CurVal;
							t_property["result_count"] = tonumber(t_attr.CurVal) or t_attr.CurVal;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--配方6个材料的单体选择框
						Type = 'SingleSel',
						--Name_StringID = 4709,
						Def = 'CraftDef',
						ENName = 'MaterialID',
						GetInitVal = function(def)
							local t_material = {}
							for i=1, 9 do
								if def.MaterialID[i-1] > 0 then
									table.insert(t_material, {id=def.MaterialID[i-1], num=def.MaterialCount[i-1]});
								end
							end
							print("kekeke Craft Material GetInitVal", t_material);
							return t_material;
						end,
						CurVal = {},
						ResetVal = {},
						Min=1, Max=64, Step=1,
						Save = function(t_attr, def, t_property)
							if def then
								print("kekeke Craft Material", t_attr.CurVal);
								for i=1, 9 do
									if t_attr.CurVal[i] then
										local id = t_attr.CurVal[i].id
										local recordId = id;
										-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
										if id >= USER_MOD_NEWID_BASE then
											local paramDef = ModEditorMgr:getItemDefById(id)
											ModEditorMgr:setCraftingForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
										-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
										-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
										-- 	recordId = id + CUSTOM_MOD_QUOTE;			
										end

										def["MaterialID"][i-1] = t_attr.CurVal[i].id;
										def["MaterialCount"][i-1] = t_attr.CurVal[i].num;
										t_property["material_id"..i] = recordId;
										t_property["material_count"..i] = t_attr.CurVal[i].num;
									else
										def["MaterialID"][i-1] = 0;
										def["MaterialCount"][i-1] = 0;
										t_property["material_id"..i] = 0;
										t_property["material_count"..i] = 0;
									end
								end
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = {};
							for i=1, #(t_attr.ResetVal) do
								table.insert(t_attr.CurVal,t_attr.ResetVal[i]);
							end
						end,
					},
					{	--配方结果单个选择框
						Type = 'craft_tool',
						--Name_StringID = 4709,
						Def = 'CraftDef',
						ENName = 'craft_tool',
						GetInitVal = function(def)
							return {id=def.CraftingItemID, num=0};
						end,
						CurVal = {id= DefMgr:getCraftEmptyHandID(), num=0},
						ResetVal = {id=DefMgr:getCraftEmptyHandID(), num=0},
						Save = function(t_attr, def, t_property)
							if def then
								local id = t_attr.CurVal.id
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setCraftingForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end

								def["CraftingItemID"] = t_attr.CurVal.id;
								t_property["CraftingItemID"] = recordId;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal.id = t_attr.ResetVal.id;
							t_attr.CurVal.num = t_attr.ResetVal.num;
						end,
					},
				},
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		--熔炼
		furnace = {
			{	--熔炼属性
				Name_StringID = 1246,
				Attr = {
					{	--熔炼材料单个选择框
						Type = 'SingleSel',
						ENName = 'MaterialID',
						GetInitVal = function(def)
							return {id=def.MaterialID, num=1};
						end,
						CurVal = {id=0, num=0},
						ResetVal = {id=0, num=0},
						Save = function(t_attr, def, t_property)
							if def then
								local id = t_attr.CurVal.id
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setFurnaceForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;			
								end

								def["MaterialID"] = t_attr.CurVal.id;
								t_property["materialid"] = recordId;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal.id = t_attr.ResetVal.id;
							t_attr.CurVal.num = t_attr.ResetVal.num;
						end,
					},
					{	--可否燃烧开关

						Type = 'Switch',
						Name_StringID = 1557,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							return def.Heat > 0;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							local type = t_attr.CurVal and 'add' or 'remove';
							t_attr.Func(type, true);
						end,
						Func = function(type, notUpdate)
						 	modeditor.ChangeConfigShowPremise(type, 'CanBurn')
							if not notUpdate then
								local t = modeditor.GetTableToENName(modeditor.config.furnace[1].Attr, "Heat")
								if t then
									if type == 'add' then
										t.CurVal = 100*0.05;
										getglobal("SingleEditorFrameBaseSetFurnaceHeat"):Show();
									elseif type == 'remove' then
										t.CurVal = 0;
										getglobal("SingleEditorFrameBaseSetFurnaceHeat"):Hide();
									end

									getglobal("SingleEditorFrameBaseSetFurnaceHeat".."Val"):SetText(t.CurVal);
									getglobal("SingleEditorFrameBaseSetFurnaceHeat".."Bar"):SetValue(t.CurVal);
								end
								t = modeditor.GetTableToENName(modeditor.config.furnace[1].Attr, "ProvideHeat")
								if t then
									if type == 'add' then
										t.CurVal = 5;
										getglobal("SingleEditorFrameBaseSetFurnaceProvideHeat"):Show();
									elseif type == 'remove' then
										t.CurVal = 0;
										getglobal("SingleEditorFrameBaseSetFurnaceProvideHeat"):Hide();
									end

									getglobal("SingleEditorFrameBaseSetFurnaceProvideHeat".."Val"):SetText(t.CurVal);
									getglobal("SingleEditorFrameBaseSetFurnaceProvideHeat".."Bar"):SetValue(t.CurVal);
								end
							end
						end,
					},
					{	--提供热量滑动条

						Type = 'Slider',
						Name_StringID = 1248,
						ENName = 'Heat', JsonName = 'heat', CurVal = 5, ResetVal = 5, Min=5, Max=2000, Step=5,
						GetInitVal = function(def)	return math.floor(def.Heat*0.05) end,
						GetDesc = function(val)
							return GetS(1250);
						end,
						CanShow = function()
							return modeditor.MeetPremise('CanBurn');
						end,
						Save = function(t_attr, def, t_property)
							def["Heat"] = math.floor(t_attr.CurVal/0.05);
							t_property["heat"] = math.floor(t_attr.CurVal/0.05);
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--熔炼材料单个选择框
						Def = 'FurnaceResultDef',
						Type = 'SingleSel',
						ENName = 'Result',
						Min=1, Max=64, Step=1,
						GetInitVal = function(def)
							local ret = {{},{},{}};
							if def then
								ret[1].id = def.Result or 0;
								ret[1].num = def.ResultNum or 1;
								ret[2].id = def.Result2 or 0;
								ret[2].num = def.ResultNum2 or 1;
								ret[3].id = def.Result3 or 0;
								ret[3].num = def.ResultNum3 or 1;
							else
								ret[1].id = 0;
								ret[1].num = 1;
								ret[2].id = 0;
								ret[2].num = 1;
								ret[3].id = 0;
								ret[3].num = 1;
							end
							return ret;
						end,
						--冒险新版本熔炼新改版, 新加中温产物,高温产物,原先的作为低温产物 
						--id:低温产物 id2:中温产物 id3:高温产物
						CurVal = {{id=0, num=1},{id=0,num=1},{id=0,num=1}},
						ResetVal = {{id=0, num=1},{id=0,num=1},{id=0,num=1}},
						Save = function(t_attr, def , t_property)
							if def then
								local id  = t_attr.CurVal[1].id
								local id2 = t_attr.CurVal[2].id
								local id3 = t_attr.CurVal[3].id
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setFurnaceForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;
								end
								if id2 >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id2)
									ModEditorMgr:setFurnaceForeignId(def, id2, ModEditorMgr:getItemKey(paramDef))
								end
								if id3 >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id3)
									ModEditorMgr:setFurnaceForeignId(def, id3, ModEditorMgr:getItemKey(paramDef))
								end

								def["Result"] = t_attr.CurVal[1].id;
								def["Result2"] = t_attr.CurVal[2].id;
								def["Result3"] = t_attr.CurVal[3].id;
								t_property["result"] = t_attr.CurVal[1].id;
								t_property["result2"] =  t_attr.CurVal[2].id;
								t_property["result3"] = t_attr.CurVal[3].id;
								def["ResultNum"] = t_attr.CurVal[1].num;
								def["ResultNum2"] = t_attr.CurVal[2].num;
								def["ResultNum3"] = t_attr.CurVal[3].num;
								t_property["resultNum"] = t_attr.CurVal[1].num;
								t_property["resultNum2"] =  t_attr.CurVal[2].num;
								t_property["resultNum3"] = t_attr.CurVal[3].num;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal[1].id = t_attr.ResetVal[1].id;
							t_attr.CurVal[1].num = t_attr.ResetVal[1].num;
							t_attr.CurVal[2].id = t_attr.ResetVal[2].id;
							t_attr.CurVal[2].num = t_attr.ResetVal[2].num;
							t_attr.CurVal[3].id = t_attr.ResetVal[3].id;
							t_attr.CurVal[3].num = t_attr.ResetVal[3].num;
						end,
					},
					{	--熔炼时间滑动条

						Type = 'Slider',
						Name_StringID = 1572,
						ENName = 'BurnTime', JsonName = 'burnTime', CurVal = 5, ResetVal = 5, Min=5, Max=2000, Step=5,
						GetInitVal = function(def)	
							return math.floor(def.BurnTime*0.05) 
						end,
						GetDesc = function(val)
							return GetS(1250);
						end,
						CanShow = function()
							return modeditor.MeetPremise('CanBurn');
						end,
						Save = function(t_attr, def, t_property)
							def["BurnTime"] = math.floor(t_attr.CurVal/0.05);
							t_property["burnTime"] = math.floor(t_attr.CurVal/0.05);
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--燃烧温度滑动条

						Type = 'Slider',
						Name_StringID = 1573,
						ENName = 'ProvideHeat', JsonName = 'provideHeat', CurVal = 5, ResetVal = 5, Min=5, Max=500, Step=5,
						GetInitVal = function(def)	
							return math.floor(def.ProvideHeat*20) 
						end,
						GetDesc = function(val)
							return GetS(1574);
						end,
						CanShow = function()
							return modeditor.MeetPremise('CanBurn');
						end,
						Save = function(t_attr, def, t_property)
							def["ProvideHeat"] = t_attr.CurVal/20.0;
							t_property["provideHeat"] = t_attr.CurVal/20.0;
							local a = math.floor(t_attr.CurVal/20.0)
							local b = a
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
				},
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		--剧情
		plot = {
			{	--1. 剧情基础属性
				Name_StringID = 11007,
				CreateTaskIDs = {},	--当前剧情创建的任务的id.
				Attr = {
					{	--1. 剧情名称, 输入框
						Type = "EditBox",
						ENName = "Name",
						JsonName = "name";
						GetInitVal = function(def)
							Log("plot:GetInitVal:Name:");
							--return def.Name;
							local Name = ConvertDialogueStr(def.Name);
							Log("Name1 = " .. def.Name);
							Log("Name2 = " .. Name);
							return Name;
						end,
						CurVal = "123456",
						ResetVal = "123456",
						Save = function(t_attr, def, t_property)
							Log("SaveNpcPlotName:");
							if def then
								Log("111:");
								t_property["name"] = t_attr.CurVal;
								def.Name = t_attr.CurVal;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--2. 图标, 单个选择框
						Type = 'SingleSel',
						ENName = 'Icon',
						JsonName = "icon";
						GetInitVal = function(def)
							return {id = def.Icon, num=1};	--def.Icon,是像这样的:mob_生物ID, item_道具ID, 根据前缀判断是生物还是道具
						end,
						CurVal = {id=0, num=0},
						ResetVal = {id=0, num=0},
						Save = function(t_attr, def, t_property)
							if def then
								t_property["icon"] = t_attr.CurVal.id;
								def.Icon = t_attr.CurVal.id;
							end
						end,
						Reset = function(t_attr)
							t_attr.CurVal.id = t_attr.ResetVal.id;
							t_attr.CurVal.num = t_attr.ResetVal.num;
						end,
					},
					{	--3. 前置条件, 选项

						Type = 'Option',
						Name_StringID = 11031,
						Desc_StringID = 11044,	--描述
						ENName = 'Condition', JsonName = 'condition', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							return 0;
						end,
						Options	= {
							{
								Name_StringID = 11045, 	--选项1:无
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{
								Name_StringID = 11046, 	--选项2:前置任务
								Color = finalCommonRGB55_54_49,
								Val = 1,
								Param = {TaskIDs = {}, },
							},
							{
								Name_StringID = 11047, 	--选项3:世界时间
								Color = finalCommonRGB55_54_49,
								Val = 2,
								Param = {StartTime=0, EndTime=0},
							},
							{
								Name_StringID = 11048, 	--选项4:拥有道具
								Color = finalCommonRGB55_54_49,
								Val = 3,
								Param = {ItemID=200, ItemNum=1},
							},
						},
						Save = function(t_attr, def, t_property)
							--LLTODO:前置条件保存, 待定
							Log("Save:Talk:Condition:");
							local tBase = modeditor.config.plot[1].Attr;
							local condition = {};
							condition[1] = {};
							condition[1].type = t_attr.CurVal;

							if t_attr.CurVal == 0 then 		--0:无

							elseif t_attr.CurVal == 1 then 	--1: 前置任务
								local recordId = 0;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								local id = tBase[6].CurVal;
								local IsMapDefault =  ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
													and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID();
								recordId = id;
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getNpcTaskDefById(id);
									if paramDef then
										ModEditorMgr:setNpcPlotForeignId(def, id, ModEditorMgr:getNpcTaskKey(paramDef))
									end
								-- elseif IsMapDefault == true and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end
								condition[1]["task_id1"] = recordId;
								
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								id = tBase[7].CurVal;
								recordId = id;
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getNpcTaskDefById(id);
									if paramDef then
										ModEditorMgr:setNpcPlotForeignId(def, id, ModEditorMgr:getNpcTaskKey(paramDef))
									end
								-- elseif IsMapDefault == true and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;
								end
								condition[1]["task_id2"] = recordId;
								
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								id = tBase[8].CurVal;
								recordId = id;
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getNpcTaskDefById(id);
									if paramDef then
										ModEditorMgr:setNpcPlotForeignId(def, id, ModEditorMgr:getNpcTaskKey(paramDef))
									end
								-- elseif IsMapDefault == true and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end
								condition[1]["task_id3"] = recordId;

							elseif t_attr.CurVal == 2 then 	--2: 前置时间
								condition[1]["start_time"] = tBase[9].CurVal;
								condition[1]["end_time"] = tBase[10].CurVal;
							elseif t_attr.CurVal == 3 then 	--3: 拥有道具
								condition[1]["num"] = tBase[12].CurVal;

								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								local id = tBase[11].CurVal.id;
								local recordId = id;
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getItemDefById(id)
									ModEditorMgr:setNpcPlotForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID()  and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;									
								end
								condition[1]["item_id"] = recordId;
							end
							t_property["condition"] = condition;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--4. 剧情对话,

						Type = 'PlotTalk',
						Name_StringID = 1236,
						Desc_StringID = 1237,	--描述
						ENName = 'Dialogues', JsonName = 'content', CurVal = 0, ResetVal = 0,
						GetInitVal = function(def) return def.Type end,
						Dialogues = {	--对话列表
							--[[示例结构
							{	--对话1
								ID = 1,
								Text = "",
								MultiLangText = "",	--多语言翻译
								Action = 1,
								Sound = "",
								Effect = "",
								Answers = {	--回答列表
									{	--回答1
										Text = "",		--回答内容
										FuncType = 1,	--触发功能
									},
									{	--回答2

									},
								},
							},
							{	--对话2

							},
							]]
						},
						Save = function(t_attr, def, t_property)
							Log("SavePlotDialogues:");
							local content = {};
							for i = 1, #t_attr.Dialogues do
								Log("i = " .. i);
								content[i] = {};
								content[i].id = t_attr.Dialogues[i].ID;
								content[i].text = t_attr.Dialogues[i].Text;
								content[i].action = t_attr.Dialogues[i].Action;
								content[i].sound = t_attr.Dialogues[i].Sound;
								content[i].effect = t_attr.Dialogues[i].Effect;
								content[i].answer = {};
								for j = 1, #t_attr.Dialogues[i].Answers do
									Log("j = " .. j);
									content[i].answer[j] = {};
									content[i].answer[j].text = t_attr.Dialogues[i].Answers[j].Text;
									content[i].answer[j].func_type = t_attr.Dialogues[i].Answers[j].FuncType;
									content[i].answer[j].val = t_attr.Dialogues[i].Answers[j].Val;
									content[i].answer[j].multilangtext = t_attr.Dialogues[i].Answers[j].MultiLangText;	--多语言支持
								end

								--多语言支持
								content[i].multilangtext = t_attr.Dialogues[i].MultiLangText;	--对话内容
							end
							t_property["content"] = content;
						end,
						Reset = function(t_attr)
							t_attr.CurVal = t_attr.ResetVal;
						end,
					},
					{	--5. 触发目标, 单个选择框
						Type = 'SingleSel',
						ENName = 'InteractID',
						GetInitVal = function(def)
							return {id=def.InteractID, num=1};
						end,
						CurVal = {id=0, num=0},
						ResetVal = {id=200, num=0},
						Save = function(t_attr, def, t_property)
							Log("Save:InteractID:");
							if def then
								Log("Save:InteractID: OK");
								local recordId = t_attr.CurVal.id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if t_attr.CurVal.id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getMonsterDefById(t_attr.CurVal.id)
									if paramDef then
										ModEditorMgr:setNpcPlotForeignId(def, t_attr.CurVal.id, ModEditorMgr:getActorKey(paramDef))
									end
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID()  and recordId > 0 then
								-- 	recordId = t_attr.CurVal.id + CUSTOM_MOD_QUOTE;
								end
								t_property["interact_id"] = recordId;
							end
						end,
						-- Reset = function(t_attr)
						-- 	t_attr.CurVal.id = t_attr.ResetVal.id;
						-- 	t_attr.CurVal.num = t_attr.ResetVal.num;
						-- end,
					},
					{	--6. 前置条件->前置任务1
						Type = 'PlotConditionTask',
						Name_StringID = 11046,
						Desc_StringID = 11049,	--描述
						ENName = 'Condition', JsonName = 'condition', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							return 0;
						end,
						Options	= {
							-- {
							-- 	Name_String = 11045, 	--选项1:无
							-- 	Color = finalCommonRGB55_54_49,
							-- 	Val = 0,
							-- },
						},
					},
					{	--7. 前置条件->前置任务2
						Type = 'PlotConditionTask',
						Name_StringID = 11046,
						Desc_StringID = 11049,	--描述
						ENName = 'Condition', JsonName = 'condition', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							return 0;
						end,
						Options	= {
						},
					},
					{	--8. 前置条件->前置任务3
						Type = 'PlotConditionTask',
						Name_StringID = 11046,
						Desc_StringID = 11049,	--描述
						ENName = 'Condition', JsonName = 'condition', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							return 0;
						end,
						Options	= {
						},
					},
					{	--9. 前置条件->开始时间
						Type = 'Slider',
						Name_StringID = 11032,
						ENName = 'Heat', JsonName = 'heat', CurVal = 9, ResetVal = 9, Min=0, Max=23, Step=1,
						GetInitVal = function(def)	return 9 end,
						GetDesc = function(val)
							return GetS(4653);
						end,
					},
					{	--10. 前置条件->结束时间
						Type = 'Slider',
						Name_StringID = 11033,
						ENName = 'Heat', JsonName = 'heat', CurVal = 9, ResetVal = 9, Min=0, Max=23, Step=1,
						GetInitVal = function(def)	return 9 end,
						GetDesc = function(val)
							return GetS(4653);
						end,
					},
					{	--11. 拥有道具, 单个选择框
						Type = 'SingleSel',
						ENName = 'ItemID',
						GetInitVal = function(def)
							return {id=200, num=1};
						end,
						CurVal = {id=200, num=0},
					},
					{	--12. 道具数量
						Type = 'Slider',
						Name_StringID = 11038,
						ENName = 'ItemNum', JsonName = 'heat', CurVal = 1, ResetVal = 9, Min=1, Max=64, Step=1,
						GetInitVal = function(def)	return 9 end,
						GetDesc = function(val)
							return "";--GetS(4653);
						end,
					},
					{	--13. 当前剧情创建的任务的id.
						Type = "EditBox",
						ENName = "CreateTaskIDs",
						CurVal = {},
						GetInitVal = function(def)
							return {};
						end,
						Save = function(t_attr, def, t_property)
							Log("Save:create_taskids:");
							local t_attr_val_copy = {};
							for i=1, #t_attr.CurVal do
								local id = t_attr.CurVal[i];
								local recordId = id;
								-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
								if id >= USER_MOD_NEWID_BASE then
									local paramDef = ModEditorMgr:getNpcTaskDefById(id);
									if paramDef then
										ModEditorMgr:setNpcPlotForeignId(def, id, ModEditorMgr:getNpcTaskKey(paramDef))
									end
								-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
								-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() and id > 0 then
								-- 	recordId = id + CUSTOM_MOD_QUOTE;								
								end
								t_attr_val_copy[i] = recordId;
							end
							t_property["create_taskids"] = t_attr_val_copy;
						end,
					},
				},
			},
			{	--2. 任务设置
				isNpcTaskSet = true,

				Name_StringID = 11008,
				TaskSet = {
					Type = 'PlotTask', 		--2. 剧情任务
					Name_StringID = 4460, 	--掉落道具
					CanShow = function (def)
						return false;
					end,
					Def = 'ItemDef',
					ENName = 'PlotTask',
					GetInitVal = function(def)
						return {};
					end,
					CurVal = {};
					NpcTask = {
						--[[结构示例
						{	--任务1
							ID = 1,
							CopyID = 0,
							Name = "砍树100棵",
							MultiLangText = "",			--多语言任务名
							IsDeliver = false,			--是否要交付
							ShowInNote = false,			--在冒险笔记显示
							InteractID = 200,			--交付目标
							IsRepeat = false,
							TaskContents = {			--任务类型
								{Type = 0, ID = 0, Num = 0},		--1. 无
								{Type = 1, ID = 3400, Num = 10},	--1. 击败生物
								{Type = 2, ID = 200, Num = 10},		--1. 交付道具
							},
							TaskRewards = {				--奖励类型
								{Type = 0, ID = 0, Num = 0},
								{},
							},
							Plots = {},					--对话:接任务之后
							UnCompleteds = {},			--对话:未完成
							Completeds = {},			--对话:已完成

						},
						{	--任务2

						}
						]]
					};
				},

				Attr = {
					Init = function(self, taskDef)
						Log("LLTODO:InitPlotTask:taskDef:");
						--将对应的任务, 赋值给Attr.
						for i = 1, #self do
							--初始值
							local val = self[i].GetInitVal(taskDef);
							self[i].CurVal = val;

							--显示控制
							if self[i].SetShowType then
								self[i]:SetShowType();
							end

							--多语言, 任务名字特殊处理
							if self[i].ENName == "Name" then
								self[i].MultiLangText = taskDef.MultiLangText;
								print("task:Init:MultiLangText:");
								print(self[i].MultiLangText);
							end
						end
					end,

					{	--1. 任务名字, 编辑框
						Type = 'EditBox',
						Name_StringID = 11072,
						ENName = 'Name', JsonName = 'name', CurVal = "", ResetVal = 0, MultiLangText = "",

						GetInitVal = function(def)
							Log("LLTODO:Task,GetInitVal:EditName!");
							return def.Name;
						end,

						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("LLTODO:Task,Save:EditName!");
							Log("Name = " .. t_attr.CurVal);
							t_property["name"] = t_attr.CurVal;
							def.Name = t_attr.CurVal;

							t_property["multilangtext"] = t_attr.MultiLangText;
							def.MultiLangText = t_attr.MultiLangText;
							g_Mod_Task_MultiLangText = t_attr.MultiLangText;
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							Log("SaveAttr2Task:EditBox:Name:");
							print(curTask);
							curTask.Name = self.CurVal;
							curTask.MultiLangText = self.MultiLangText;
						end,
					},
					{	--2. 任务类型,选项

						Type = 'Option',
						Def = "TaskType",
						Name_StringID = 11073,
						Desc_StringID = 11084,	--描述
						ENName = 'TaskContents', JsonName = 'type', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,

						--设置下面的控件是否显示
						SetShowType = function(self)
							Log("SetShowType:TaskContents: CurVal = " .. self.CurVal);
							if self.CurVal == 0 then
								modeditor.ChangeConfigShowPremise("remove", 'task_contents');
							else
								modeditor.ChangeConfigShowPremise("add", 'task_contents');
							end
						end,

						GetInitVal = function(def)
							Log("LLTODO:Task,GetInitVal:TaskContents!");
							if def.TaskContents and def.TaskContents[1] then
								Log("Type = " .. def.TaskContents[1].Type);
								return def.TaskContents[1].Type;
							end
							return 0;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("LLTODO:SaveContentType:");
							local content = {};
							t_property["taskcontent"] = {};
							for i = 1, 3 do
								t_property["taskcontent"][i] = {};
								t_property["taskcontent"][i].type = t_attr.CurVal;
							end
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							local content = {Type = 0, ID = 0, Num = 0};

							for i = 1, 3 do
								if not curTask.TaskContents[i] then
									curTask.TaskContents[i] = {Type = 0, ID = 0, Num = 0};
								end

								curTask.TaskContents[i].Type = self.CurVal;
							end

						end,
						Options	= {
							{
								Name_StringID = 11085, 	--选项1, 无
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{
								Name_StringID = 11086, 	--选项2, 击败生物
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 11087, 	--选项2, 交付道具
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
						},
					},
					{	--3. 任务目标,三选按钮
						Type = 'Selection',
						Name_StringID = 11088,
						CanShow = function (self)
							Log("CanShow:TastContents:");
							return modeditor.MeetPremise('task_contents');
						end,
						HasNumBtn = function() return true; end,
						Def = 'TaskContentsType',	--"ItemDef" 或 "MonsterDef", 依任务目标而定
						ENName = 'TaskContents',
						CurVal = {
							--[[结构示例
							{id = 3400, num = 1},
							{id = 3400, num = 1},
							{id = 3400, num = 1},
							]]
						},
						Min = 1, Max = 64, Step = 1,
						ResetVal = {},

						GetInitVal = function(def)
							local t = {};
							for i = 1, 3 do
								if def.TaskContents and def.TaskContents[i] then
									t[i] = {};
									t[i].id = def.TaskContents[i].ID;
									t[i].num = def.TaskContents[i].Num;
								end
							end
							return t;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("LLTODO:Save:TastContents:");
							for i = 1, 3 do
								if t_property["taskcontent"][i] and t_attr.CurVal[i] then

									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									local id = t_attr.CurVal[i].id;
									local recordId = id;
									if id >= USER_MOD_NEWID_BASE then
										if t_property["taskcontent"][i].type == 1 then --杀生物
											local paramDef = ModEditorMgr:getMonsterDefById(id);
											ModEditorMgr:setNpcTaskForeignId(def, id, ModEditorMgr:getActorKey(paramDef))
										elseif t_property["taskcontent"][i].type == 2 then --收集道具
											local paramDef = ModEditorMgr:getItemDefById(id);
											ModEditorMgr:setNpcTaskForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
										end
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- 		and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID()  and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;
									end
									t_property["taskcontent"][i].id = recordId;
									t_property["taskcontent"][i].num = t_attr.CurVal[i].num;						
								end
							end
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							for i = 1, 3 do
								if self.CurVal[i] and curTask.TaskContents[i] then
									curTask.TaskContents[i].ID = self.CurVal[i].id;
									curTask.TaskContents[i].Num = self.CurVal[i].num;
								end
							end
						end,
						Boxes = {
							{
								JsonName = 'drop_item1',
							},
							{
								JsonName = 'drop_item2',
							},
							{
								JsonName = 'drop_item3',
							},
						},
					},
					{	--4. 任务奖励,三选按钮
						Type = 'Selection',
						Name_StringID = 11074,
						HasNumBtn = function() return true; end,
						-- CanShow = function (self)
						-- 	Log("CanShow:TaskRewards:");
						-- 	return modeditor.MeetPremise('task_contents');
						-- end,
						HasNumBtn = function() return true; end,
						Def = 'ItemDef',
						ENName = 'TaskRewards',
						GetInitVal = function(def)
							local t = {};
							for i = 1, 4 do
								if def.TaskRewards and def.TaskRewards[i] and def.TaskRewards[i].Type == 0 then
									table.insert(t, {id = def.TaskRewards[i].ID, num = def.TaskRewards[i].Num});
								end
							end

							for i = 1, 3 do
								if not t[i] then
									t[i] = {id = 0, num = 0};
								end
							end
							return t;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("LLTODO:Save:TastContents111:");
							t_property["taskreward"] = {};
							for i = 1, 3 do
								if t_attr.CurVal[i] then
									Log("i = " .. i );

									-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
									local id = t_attr.CurVal[i].id;
									local recordId = id;
									if id >= USER_MOD_NEWID_BASE then
										local paramDef = ModEditorMgr:getItemDefById(id);
										ModEditorMgr:setNpcTaskForeignId(def, id, ModEditorMgr:getItemKey(paramDef))
									-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
									-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID()  and id > 0 then
									-- 	recordId = id + CUSTOM_MOD_QUOTE;
									end
									t_property["taskreward"][i] = {};
									t_property["taskreward"][i].id = recordId;
									t_property["taskreward"][i].num = t_attr.CurVal[i].num;
									t_property["taskreward"][i].type = 0;
								end
							end
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							Log("SaveAttr2Task:Reowrds:");
							for i = 1, 3 do
								Log("i = " .. i);
								if self.CurVal[i] and curTask.TaskContents[i] then
									curTask.TaskRewards[i].ID = self.CurVal[i].id;
									curTask.TaskRewards[i].Num = self.CurVal[i].num;
								end
							end
						end,
						Boxes = {
							{
								JsonName = 'drop_item1',
							},
							{
								JsonName = 'drop_item2',
							},
							{
								JsonName = 'drop_item3',
							},
						},
						Min = 1, Max = 64, Step = 1,
						CurVal = {};
					},
					{	--5. 经验,滑动条

						Type = 'Slider',
						Name_StringID = 11075,
						ENName = 'Attack', JsonName = 'attack', CurVal = 0, ResetVal = 0, Min=0, Max=999, Step=1,
						GetInitVal = function(def)
							for i = 1, 4 do
								if def.TaskRewards and def.TaskRewards[i] and def.TaskRewards[i].Type == 1 then
									return def.TaskRewards[i].Num;
								end
							end
							return 0;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							--不存在则新增.
							if t_property["taskreward"] then
								table.insert(t_property["taskreward"], {type = 1, num = t_attr.CurVal});
							else
								t_property["taskreward"] = {};
								table.insert(t_property["taskreward"], {type = 1, num = t_attr.CurVal});
							end
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							for i = 1, 4 do
								if curTask.TaskRewards[i] and curTask.TaskRewards[i].Type == 1 then
									curTask.TaskRewards[i].Num = self.CurVal;
									--已经存在直接赋值
									return;
								end
							end
							if #curTask.TaskRewards == 4 then -- 经验奖励在TaskRewards第4个位置前3个是任务奖励
								table.remove(curTask.TaskRewards,4)
							end
							--不存在则新增.
							table.insert(curTask.TaskRewards, {Type = 1, Num = self.CurVal});
						end,
					},
					{	--6. 剧情对话, 接剧情之后, 类型选项

						Type = 'Option',
						Def = "AfterTask",
						Name_StringID = 11076,
						Desc_StringID = 1108,	--描述
						ENName = 'Type', JsonName = 'type', CurVal = {}, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							Log("GetInitVal:AfterTask:def:");
							print(def.MultiLangText);
							return def.Plots;
						end,

						Options	= {
						},
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("plot_dialogue:");
							t_property["plot_dialogue"] = NpcTask_CreateDialoguesJsonTable(t_attr.CurVal);
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.Plots = self.CurVal;
						end,
					},
					{	--7. 是否需要交付, 开关

						Type = 'Switch',
						Name_StringID = 11077,
						CurVal = false,
						ResetVal = false,

						GetInitVal = function(def)
							Log("task:GetInitVal:switch:");
							if def.IsDeliver then
								Log("true:");
							else
								Log("false:");
							end

							return def.IsDeliver;
						end,

						--设置下面的控件是否显示
						SetShowType = function(self)
							Log("SetShowType:task_interactid:");
							if self.CurVal then
								modeditor.ChangeConfigShowPremise("add", 'task_interactid');
							else
								modeditor.ChangeConfigShowPremise("remove", 'task_interactid');
							end
						end,

						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							t_property["is_deliver"] = t_attr.CurVal;
						end,
						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.IsDeliver = self.CurVal;
						end,
					},
					{	--8. 交付目标选择按钮, 单格
						Type = 'Selection',
						Name_StringID = 11078,
						CanShow = function (self)
							Log("CanShow:InteractID:");
							return modeditor.MeetPremise('task_interactid');
						end,
						Def = 'MonsterDef',
						ENName = 'InteractID',
						CurVal = {
							--[[结构示例
							{id = 3400, num = 1},
							]]
						};
						ResetVal = {},
						GetInitVal = function(def)
							Log("task:GetInitVal:InteractID:");
							if def.InteractID then
								Log("id = " .. def.InteractID);
								return {{id = def.InteractID, num = 1}};
							end
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("TaskSave:InteractID:");
							if t_attr.CurVal == nil or t_attr.CurVal[1] == nil or t_attr.CurVal[1].id == nil then
								return;
							end
							local recordId = t_attr.CurVal[1].id;
							-- 若选择的参数是用户插件库的新增插件ID，需要保存id和key的对应关系
							if t_attr.CurVal[1].id >= USER_MOD_NEWID_BASE then
								local paramDef = ModEditorMgr:getMonsterDefById(t_attr.CurVal[1].id)
								if paramDef then
									ModEditorMgr:setNpcTaskForeignId(def, t_attr.CurVal[1].id, ModEditorMgr:getActorKey(paramDef))
								end
							-- elseif ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
							-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID()  and recordId > 0 then
							-- 	recordId = t_attr.CurVal[1].id + CUSTOM_MOD_QUOTE;
							end

							t_property["interact_id"] = recordId;
						end,
						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							Log("SaveAttr2Task:InteractID:");
							if self.CurVal and self.CurVal[1] then
								curTask.InteractID = self.CurVal[1].id;
							end
						end,
						Boxes = {
							{
								NotShowDel = false,
								JsonName = 'drop_item1',
							},
						},
					},
					{	--9. 交付对话, 任务未完成.选项

						Type = 'Option',
						Def = "NotCompleted",
						Name_StringID = 11080,
						Desc_StringID = 1108,	--描述
						ENName = 'Type', JsonName = 'type', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						CanShow = function (self)
							Log("CanShow:NotCompleted:");
							return modeditor.MeetPremise('task_interactid');
						end,
						GetInitVal = function(def)
							return def.UnCompleteds;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("Save:NotCompleted:");
							t_property["uncompleted_dialogue"] = NpcTask_CreateDialoguesJsonTable(t_attr.CurVal);
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.UnCompleteds = self.CurVal;
						end,
						Options	= {
						},
					},
					{	--10. 交付对话, 任务已完成, 选项

						Type = 'Option',
						Def = "Completed",
						Name_StringID = 11081,
						Desc_StringID = 1108,	--描述
						ENName = 'Type', JsonName = 'type', CurVal = 0, ResetVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						CanShow = function (self)
							Log("CanShow:Completed:");
							return modeditor.MeetPremise('task_interactid');
						end,
						GetInitVal = function(def)
							return def.Completeds;
						end,
						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							Log("Save:Completed:");
							t_property["completed_dialogue"] = NpcTask_CreateDialoguesJsonTable(t_attr.CurVal);
						end,

						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.Completeds = self.CurVal;
						end,
						Options	= {
						},
					},
					{	--11. 是否可重复
						Type = 'Switch',
						Name_StringID = 11091,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							Log("task:GetInitVal:switch:");
							if def.IsRepeat then
								Log("true:");
							else
								Log("false:");
							end

							return def.IsRepeat;
						end,

						--设置下面的控件是否显示
						SetShowType = function(self)
							Log("SetShowType:task_interactid:");
							if self.CurVal then
								modeditor.ChangeConfigShowPremise("add", 'task_interactid');
							else
								modeditor.ChangeConfigShowPremise("remove", 'task_interactid');
							end
						end,

						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							t_property["is_repeat"] = t_attr.CurVal;
						end,
						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.IsRepeat = self.CurVal;
						end,
					},
					{	--12. 启用接、交任务界面
						Type = 'Switch',
						Name_StringID = 11093,
						CurVal = false,
						ResetVal = false,
						GetInitVal = function(def)
							Log("task:GetInitVal:switch:");
							if def.IsRepeat then
								Log("true:");
							else
								Log("false:");
							end

							return def.UseInteract;
						end,

						--任务的保存函数叫"TaskSave". 不要写"Save"
						TaskSave = function(t_attr, def, t_property)
							t_property["use_interact"] = t_attr.CurVal;
						end,
						--将属性保存到对应的任务
						SaveAttr2Task = function(self, curTask)
							curTask.UseInteract = self.CurVal;
						end,
					},
				},
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
		},

		-- 商店
		store = {
			{	--1.商店设置
				Name_StringID = 21702,
				ResetEditorName = "",
				ResetEditorDesc = "";
				Attr = {


				},

			},
			{
				Name_StringID = 21705,	--商品设置
			},
		},

		--状态
		status = {
			{	--外观

				Name_StringID = 1104,
				Attr = {
					{--图标库
						CurVal = 0,
						GetInitVal = function(def)
							return def.Status.IconID
						end,
						Status_SetValue = function(self, val)
							self.CurVal = val
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								def.Status.IconID = self.CurVal
							end
						end,
						Getdef = function(self)
							local def
							if self.CurVal > 0 then
								def = GetInst("ModsLibDataManager"):GetIconLibConfList(tonumber(self.CurVal))
							end
							return def
						end,
						GetIconPath = function(self)
							local def,path = self:Getdef()
							if def and def.IconName then
								local define = GetInst("ModsLibSelectorMgr").define;
								local stateIconCfg = define.SelectorCfg[define.SelectorType.StateIcon];
								path = "ui/" .. stateIconCfg.filePath[def.Type] .. "/" .. def.IconName ..".png"
							end
							return path
						end,
					},
					{--特效库
						CurVal = 0,
						GetInitVal = function(def)
							return def.Status.ParticleID
						end,
						Status_SetValue = function(self, val)
							self.CurVal = val
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								def.Status.ParticleID = self.CurVal
							end
						end,
						Getdef = function(self)
							local def
							if self.CurVal > 0 then
								def = DefMgr:getParticleDef(tonumber(self.CurVal))
							end
							return def
						end,
						GetIconPath = function(self)
							local def,path = self:Getdef()
							if def then
								path = "ui/particlesicons/" .. def.IconName .. ".png";
							end
							return path
						end,
					},
					{--音效库
						CurVal = 0,
						SoundType = 0,
						Status_SetSoundType = function(self, type)
							self.SoundType = type
						end,
						GetInitVal = function(def)
							return def.Status.SoundID
						end,
						Status_SetValue = function(self, val)
							self.CurVal = val
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								def.Status.SoundID = self.CurVal
								--是否循环播放
								if self.SoundType ~= 0 then
									def.SoundType = self.SoundType
								end
							end
						end,
						Getdef = function(self)
							local def
							if self.CurVal > 0 then
								def = DefMgr:getSoundDef(tonumber(self.CurVal))
							end
							return def
						end,
						GetIconPath = function(self)
							local def,path = self:Getdef()
							if def then
								path = "ui/sounds/" .. def.IconName .. ".png";
							end
							return path
						end,
					},
				},
			},
			{	--效果
				Name_StringID = 8627,
			},
			{	--属性
				Name_StringID = 1105,
				Attr = {
					{	--持续时长标题
			
						Type = 'Line',		--分隔线
						Title_StringID = 25413,
					},
					{
						Type = 'RadioOption',
						Name_StringID = 25414,
						CurVal = 1,
						MaxBtnNum = 3,
						GetInitVal = function(def)
							if not def or not def.Status then return 1 end

							return def.Status.LimitTime > 0 and 2 or 1
						end,
						Options	= {
							{--无限
								Name_StringID = 25415, 	--选项1
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{--有限
								Name_StringID = 25416, 	--选项2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
						},
						ContrlDefault = function()
							return 2
						end,
						Func = function(type, notUpdate, needcontrl)
							if needcontrl then
						 		modeditor.ChangeConfigShowPremise(type, 'Continuous')
						 	end
						end,
					},
					{
						Type = 'Slider', 		--滑动条
						Name_StringID = 25417,	--地滑程度
						CanShow = function (def)
							return modeditor.MeetPremise('Continuous')
						end,
						ENName = 'Slipperiness', JsonName = 'slipperiness', CurVal = 10, Min=1, Max=1200, Step=1,
						ValShowType = 'Int',
						GetInitVal = function(def)
							if def and def.Status then
								local limitTime = tonumber(def.Status.LimitTime)
								if type(limitTime) == 'number' and limitTime ~= 0 then
									return tonumber(limitTime)
								end
							end
							return 1
						end,
						Status_Save = function(self, def)
                            if def then
                                def.Status = def.Status or {}
                                if self.CanShow() then
                                    def.Status.LimitTime = self.CurVal
                                else
                                    def.Status.LimitTime = 0
                                end
                            end
						end,
					},
					{	--属性标题
			
						Type = 'Line',		--分隔线
						Title_StringID = 25405,
					},
					{--状态类型
						Type = 'Option', 		--选项
						Name_StringID = 25418, 	--状态类型，0：有利状态， 1：不利状态
						Desc_StringID = 25453,	--描述
						ENName = 'MoveCollide', JsonName = 'move_collide', CurVal = 0,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							if def and def.Type then
								return def.Type
							end
							return 0
						end,
						Options	= {
							{--有利
								Name_StringID = 25419, 	--选项1
								Desc_StringID = 25419,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 0,
							},
							{--不利
								Name_StringID = 25420, 	--选项2
								Desc_StringID = 25420,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
						},
						Status_Save = function(self, def)
							def = def or {}
							def.Type = self.CurVal
						end,
					},
					{--优先级
						Type = 'Option', 		--选项
						Name_StringID = 25421, 	--优先级，0：覆盖， 1：并存
						Desc_StringID = 25452,	--描述
						ENName = 'Priority', JsonName = 'Priority', CurVal = 1,
						GetIsDisEnableBtn = function(def)
							if def and (def.ID == 1001000 or def.ID >= 10000000) then
								return false
							end
							return true
						end,
						GetOption = function(val, options)
							if options then
								for k, v in pairs(options) do
									if v.Val == val then
										return v;
									end
								end
							end
							return nil;
						end,
						GetInitVal = function(def)
							if def and def.Status and def.Status.Priority then
								return def.Status.Priority
							end
							return 1
						end,
						Options	= {
							{
								Name_StringID = 25422, 	--选项1
								Desc_StringID = 25422,	--描述1
								Color = finalCommonRGB55_54_49,
								Val = 1,
							},
							{
								Name_StringID = 25423, 	--选项2
								Desc_StringID = 25423,	--描述2
								Color = finalCommonRGB55_54_49,
								Val = 2,
							},
						},
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								def.Status.Priority = self.CurVal
							end
						end,
					},
					{
						Type = 'Switch', 		--开关
						Name_StringID = 25424, 	--死亡不清除
						CurVal = true,
						GetInitVal = function(def)
							if not def or not def.Status then return true end
							return def.Status.DeathClear == 2
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								if self.CurVal then
									def.Status.DeathClear = 2
								else
									def.Status.DeathClear = 1
								end
							end
						end,
						Func = function(type, notUpdate)
						end,
					},
					{
						Type = 'Switch', 		--开关
						Name_StringID = 25427, 	--主动攻击清除
						CurVal = true,
						GetInitVal = function(def)
							if not def or not def.Status then return true end
							return def.Status.AttackClear == 1
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								if self.CurVal then
									def.Status.AttackClear = 1
								else
									def.Status.AttackClear =2
								end
							end
						end,
						Func = function(type, notUpdate)
						end,
					},
					{
						Type = 'Switch', 		--开关
						Name_StringID = 25428, 	--受到伤害清除
						CurVal = true,
						GetInitVal = function(def)
							if not def or not def.Status then return true end
							return def.Status.DamageClear == 1
						end,
						Status_Save = function(self, def)
							if def then
								def.Status = def.Status or {}
								if self.CurVal then
									def.Status.DamageClear = 1
								else
									def.Status.DamageClear = 2
								end
							end
						end,
						Func = function(type, notUpdate)
						end,
					},
				}
			},
			{	--触发器
				Name_StringID = 300265,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16601,
				triggerBtn = true,
			},
			{
				--脚本
				Name_StringID = 13002,
				Only_InGame = true,		-- 只在游戏内显示
				Name_StringID_local = 16602,
			}
			},
	},

	showConfigPremise = {},

	ChangeConfigShowPremise = function (type, premise)
		if type == 'add' then
			if not modeditor.InShowPremise(premise) then
				table.insert(modeditor.showConfigPremise, premise);
			end
		elseif type == 'remove' then
			for i=1, #(modeditor.showConfigPremise) do
				if premise == modeditor.showConfigPremise[i] then
					table.remove(modeditor.showConfigPremise, i);
					return;
				end
			end
		end
	end,

	MeetPremise = function (premise)
		if type(premise) == 'table' then
			local isOk = true;
			--检查必要前提
			if premise.PREQ then
				for i=1, #(premise.PREQ) do
					if not modeditor.InShowPremise(premise.PREQ[i]) then
						isOk = false;
					end
				end
			end
			if isOk then	--满足
				if premise.OneOfPR then
					--检查需要前提
					isOk = false;
					for i=1, #(premise.OneOfPR) do
						if modeditor.InShowPremise(premise.OneOfPR[i]) then
							isOk = true;
							break;
						end
					end
				end
			end

			return isOk;
		else
			return modeditor.InShowPremise(premise);
		end
		return false;
	end,

	InShowPremise = function (premise)
		for i=1,#(modeditor.showConfigPremise) do
			if premise == modeditor.showConfigPremise[i] then
				return true;
			end
		end
		return false;
	end,

	GetTableToENName = function(t, ENName)
		for i=1, #(t) do
			if t[i].ENName and t[i].ENName == ENName then
				return t[i];
			end
		end

		return nil;
	end,

	Init = function (CurEditorClass, CurrentEditDef)
		modeditor.showConfigPremise = {};
		for k=1, #(modeditor.config[CurEditorClass]) do
			if CurEditorClass == "plot" and k == 2 then
				--npc任务设置不在这里初始化
			else
				local t = modeditor.config[CurEditorClass][k].Attr;
				if t then
					for i=1, #(t) do
						if t[i].Type ~= 'Line' and t[i].Type ~= 'NoUI' then
							local def = modeditor.GetCurAttrDef(t[i].Def, CurrentEditDef);
							print("123:",t[i].Type)
							local val = t[i].GetInitVal(def);
							if t[i].ValShowType then
								if t[i].ValShowType == 'One_Decimal' then
									val = string.format("%.1f", val);
								end
							end
							t[i].CurVal = val;

							if t[i].ResetVal ~= nil then
								if type(t[i].ResetVal) == 'table' and type(val) == 'table' then
									for j=1, #(val) do
										table.insert(t[i].ResetVal, val[j]);
									end
								else
									t[i].ResetVal = val;
								end
							end
							--init show premise
							if t[i].Func then
								if t[i].Type == 'Option' then
									t[i].Func(val, true);
								else
									if val then
										if t[i].Name_StringID == 11504 then
											if t[i].CurVal == 3 then
												t[i].Func('add', true);
											end
										elseif t[i].Type == 'RadioOption' and t[i].ContrlDefault then
											local bContrl, contrltype = false
											if t[i].ContrlDefault then bContrl = true end
											if bContrl and t[i].CurVal == t[i].ContrlDefault() then
												contrltype = 'add'
											else
												contrltype = 'remove'
											end
											t[i].Func(contrltype, false, bContrl)
										else
											t[i].Func('add', true);
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end,

	GetCurAttrDef = function (defStr, defaultDef)
		local def;
		if defStr == 'ToolDef' then	--工具表
			def = ModEditorMgr:getToolDefById(defaultDef.ID);
			if def == nil then def = ToolDefCsv:get(defaultDef.ID) end
			if def == nil then def = ToolDefCsv:get(10100) end
		elseif defStr == 'ProjectileDef' then	--投射物表
			def = ModEditorMgr:getProjectileDefById(defaultDef.ID);
			if def == nil then def = ProjectileDefCsv:get(defaultDef.ID) end
			if def == nil then def = ProjectileDefCsv:get(10100) end
		elseif defStr == 'FoodDef' then	--食物表
			def = ModEditorMgr:getFoodDefById(defaultDef.ID);
			if def == nil then def = FoodDefCsv:get(defaultDef.ID) end
			if def == nil then def = FoodDefCsv:get(10100) end
		elseif defStr == 'GunDef' then	--枪表
			def = ModEditorMgr:getGunDefById(defaultDef.ID);
			if def == nil then def = DefMgr:getGunDef(defaultDef.ID) end
			if def == nil then def = DefMgr:getGunDef(10100) end
		elseif defStr == 'PhysicsActorDef' then --物理表
			def = ModEditorMgr:getPhysicsActorDefById(defaultDef.ID);
			if def == nil then def = PhysicsActorCsv:get(defaultDef.ID) end
			if def == nil then def = PhysicsActorCsv:get(10100) end
		else
			def = defaultDef;
		end
		return def;
	end,
}

interactData = {

	plotAndTask={

	},

	typeList={},

	allNum =0 ,
	monsterId = 0,
	Dialogue=nil,

	Init = function ()
		if interactData.monsterId == 0 or interactData.monsterId == nil then  
			Log("interactData initialization failed");
			return
		end

		local plotNum = DefMgr:getNpcPlotDefNum();
		local taskNum = DefMgr:getNpcTaskDefNum();
		
		if plotNum== nil or plotNum== 0 or taskNum==nil or taskNum== 0 then 
			return
		end

		local index = 0;
		for i =0 ,plotNum-1 do 
			local plot = DefMgr:getNpcPlotDefByIndex(i);
			
			if plot and plot.InteractID == interactData.monsterId then 
				plot.InteractType = 1 ;
				index = index+1;
				interactData.typeList[index]=1;
				interactData.plotAndTask[index] = plot;
			end
		end

		for i = 0 ,taskNum-1 do 
			local task = DefMgr:getNpcTaskDefByIndex(i);

			if task and task.InteractID ==interactData.monsterId then 
				task.InteractType = 2 ;
				index = index+1;
				interactData.typeList[index]=2;
				interactData.plotAndTask[index] = task;
			end
		end

		interactData.SetAllNum(index);

	end,

	GetType=function (index)
		if index ==nil then return end ;
		local typeInteract = interactData.typeList[index];
		if typeInteract ==nil then return end ;
		return typeInteract;
	end,

	GetAllNum = function()
		return interactData.allNum;
	end,

	GetTaskOrPlotByIndex= function (index)
		if index == nil then 
			Log("get Taskdef or PlotDef fail :GetTaskOrPlotByIndex= function (index)");
			return;
		end

		local allNum=interactData.GetAllNum();
		if allNum<=0 then return end

		return interactData.plotAndTask[index] ;
	end,

	GetTaskAndPlot = function ()
		return interactData.plotAndTask;
	end,

	SetAllNum = function (num)
		if num ==nil then return end

		if num ==0 then 
			local listNum =  #interactData.plotAndTask;
			if listNum >=0 then 
				interactData.allNum = listNum;
			end
		else
			interactData.allNum = num ;
		end
	
	end,

	SetPlotAndTask = function ()
		-- body
	end,

	SetMonsterId = function (id)
		if id ~= nil then 
			interactData.monsterId= id;
		end 
	end,

	Reset = function ()
		interactData.allNum= 0 ;
		interactData.plotAndTask = {};
	end,

	
}


--物理材质
PhysxMatConfig = {
					ResetName = "",
					AddDef = function(id, iscopy)
						local physxMatDef = ModEditorMgr:addPhysicsMaterialDef(id, iscopy);
						if physxMatDef then
							return physxMatDef;
						end
					end,

					Attr ={
						--------------------------分割线，材质属性--------------------------------
						{
							Type = 'PhysxMatTemplate',
							Name_StringID = 11506,
							ENName = 'Template', JsonName = 'Template', CurVal = 0,
							--GetOption = function(val, options)
							--	if options then
							--		for k, v in pairs(options) do
							--			if v.ID == val then
							--				return v;
							--			end
							--		end
							--	end
							--	return nil;
							--end,
							GetInitVal = function(def) return def.NameStringID end,
							Save = function(def,t_attr,t_property)
								local PhysxMatDef = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
								if PhysxMatDef then
									t_property["Template"] = t_attr.CurVal
									PhysxMatDef["NameStringID"] = t_attr.CurVal
								end

							end,
							--此处直接读csv表中相关字段进行判断，显示设置为预设的材质
							Options	= {
								{	--预设: 皮球
									Name = GetS(11533),
									ID = 12,
									NameStringID = 11533,
								},
								{	--预设: 木材
									Name = GetS(11534),
									ID = 13,
									NameStringID = 11534,
								},
								{	--预设: 金属
									Name = GetS(11535),
									ID = 14,
									NameStringID = 11535,
								},

							},
						},
			
						{	--材质名称编辑
							Type = 'PhysxMatNameEdit',
							Name_StringID = 11523,
							ENName = 'Name', JsonName = 'Name', CurVal = 0,
							GetInitVal = function(def) return def.Name end,
							Save = function(def,t_attr,t_property)
								local PhysxMatDef = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
								if PhysxMatDef then
									t_property["Name"] = t_attr.CurVal;
									PhysxMatDef["Name"] = t_attr.CurVal;
								end
							end,

						},
						{	--动摩擦力
							Type = "PhysxMatSlider",
							Name_StringID = 11525,
							ENName = 'DynamicFriction', JsonName = 'DynamicFriction', CurVal = 0,
							GetInitVal = function(def) return def.DynamicFriction end,
							Save = function(def, t_attr, t_property)
								local PhysxMatDef = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
								if PhysxMatDef then
									PhysxMatDef["DynamicFriction"] = t_attr.CurVal
									t_property["DynamicFriction"] = t_attr.CurVal
								end
							end,
						},
						{	--静摩擦力
							Type = "PhysxMatSlider",
							Name_StringID = 11527,
							ENName = 'StaticFriction', JsonName = 'StaticFriction', CurVal = 0,
							GetInitVal = function(def) return def.StaticFriction end,
							Save = function(def, t_attr, t_property)
								local PhysxMatDef = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
								if PhysxMatDef then
									PhysxMatDef["StaticFriction"] = t_attr.CurVal
									t_property["StaticFriction"] = t_attr.CurVal
								end
							end,
						},
						{	--弹力
							Type = "PhysxSlider",
							Name_StringID = 11532,
							ENName = 'Bouncyness', JsonName = 'Bouncyness', CurVal = 0,
							GetInitVal = function(def) return def.Bouncyness end,
							Save = function(def, t_attr, t_property)
								local PhysxMatDef = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
								if PhysxMatDef then
									PhysxMatDef["Bouncyness"] = t_attr.CurVal
									t_property["Bouncyness"] = t_attr.CurVal
								end
							end,
						},
					},

					Init = function(def)
						local t_attr = PhysxMatConfig.Attr
						for i=1,#(t_attr) do
							if t_attr[i].GetInitVal(def) then
								t_attr[i].CurVal = t_attr[i].GetInitVal(def)
							end
							if t_attr[i].ENName == 'Name' then
								if getglobal("PhysxMaterialNameEditInput"):GetText()~="" then
									t_attr[i].CurVal = getglobal("PhysxMaterialNameEditInput"):GetText()
								end
							end
						end
					end

				}


NpcStoreTable = {
    CurEditorIndex = 1,

	itemList ={},

    config = {
    	ItemID = 100,
    	Name = "",
    	Desc = "",

        Attr = {
            {
                Type = 'Selection',
                Name_StringID = 6317, --选择生物
                CurVal = 100,
                CurNum = 1,
                CanShow = true
            },
            {
                Type = 'Selection',
                Name_StringID = 6317, --选择生物
                CurVal = 101,
                CurNum = 1,
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21713, --星星[Desc5]
                CurVal = 0, Min = 0, Max = 999, Step = 1,
                ValShowType = 'Int',
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21715, --单次可[Desc5]数量
                CurVal = 1, Min = 1, Max = 64, Step = 1,
                ValShowType = 'Int',
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21716, --可[Desc5]次数
                CurVal = 301, Min = 1, Max = 301, Step = 1,
                ValShowType = 'Int',
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21718, --补充时间
                CurVal = 5, Min = 5, Max = 3600, Step = 5,
                ValShowType = 'Int',
                CanShow = true
            },
			{
				Type = 'Switch',
				Name_StringID = 21717, --补充时间
				CurVal = 0,
				ValShowType = 'Int',
				CanShow = true
			},
			{
				Type = 'ADSwitch',
				Name_StringID = 21719, --补充时间
				CurVal = 0,
				ValShowType = 'Int',
				CanShow = true
			},
        },


	}
}


