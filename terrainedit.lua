
---------------------------------------左侧导航按钮:begin-----------------------------------------------------------------------------------
-- {nameStrID = 690, },			--冰原
-- {nameStrID = 9112, },		--冰山
-- {nameStrID = 9113, },		--盆地
-- {nameStrID = 9114, },		--竹林盆地
-- {nameStrID = 9115, },		--桃树盆地
-- {nameStrID = 9116, },		--盆地边缘

--参数:begin
local m_TerrainEdit_TerrainSetParam = {
	Tab = {
		leftFrameUI = "TerrainEditFrameLeftFrame",
		bIsFirstShow = true,
		curTabIndex = 1,

		--1. 地貌生成
		{
			nameID = 9098,	--地貌生成

			MainTerrain = {
				curMainTerrainIndex = 1,
				bIsFirstShow = true;
				{	--1.沙漠
					nameID = 688,
					icon = "img_shamo",
					MainTerrainID = 2;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--沙漠
							nameID = 688,
							ChildTerrainID = 2;
							Set = {},
						},
						{
							--沙漠山丘
							nameID = 9151,
							ChildTerrainID = 13;
							Set = {},

							--结构
							--[[
							Set = {
								--高度
								Height = { Min = 20, Max = 80, },

								--地表层方块
								SurfaceBlock = { Type = "SurfaceBlock", blockID = 0, },

								--填充层方块
								FillBlock = { Type = "FillBlock", blockID = 0, },

								--填充层厚度
								FillHeight = { nameID = 9108, Val = 30, },

								--地形生成概率
								Probability = { nameID = 9109, Val = 60, },
							},
							]]
						},
					},	--子地貌end
				},

				{	--2. 森林
					nameID = 689,
					icon = "img_senglin",
					MainTerrainID = 3;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1森林
							nameID = 689,
							ChildTerrainID = 3;
							Set = {},
						},
						{
							--1森林山丘
							nameID = 9152,
							ChildTerrainID = 14;
							Set = {},
						},
					},
				},
				{	--3. 峭壁
					nameID = 692,
					icon = "img_gaoshan",
					MainTerrainID = 4;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1峭壁
							nameID = 692,
							ChildTerrainID = 4;
							Set = {},
						},
						{
							--1峭壁边缘
							nameID = 9157,
							ChildTerrainID = 20;
							Set = {},
						},
					},
				},
				{	--4. 草原
					nameID = 687,
					icon = "img_caoyuan",
					MainTerrainID = 1;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1草原
							nameID = 687,
							ChildTerrainID = 1;
							Set = {},
						},
						{
							--1冰原
							nameID = 690,
							ChildTerrainID = 8;
							Set = {},
						},
						{
							--1红土
							nameID = 9149,
							ChildTerrainID = 11;
							Set = {},
						},
						{
							--1红土海岸
							nameID = 9150,
							ChildTerrainID = 12;
							Set = {},
						},
					},
				},
				{	--5. 沼泽
					nameID = 730,
					icon = "img_zaozhe",
					MainTerrainID = 5;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1沼泽
							nameID = 730,
							ChildTerrainID = 5;
							Set = {},
						},
					},
				},
				{	--6. 针叶林
					nameID = 693,
					icon = "img_songshulin",
					MainTerrainID = 6;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1针叶林
							nameID = 693,
							ChildTerrainID = 6;
							Set = {},
						},
						{
							--1针叶林山丘
							nameID = 9153,
							ChildTerrainID = 15;
							Set = {},
						},
					},
				},
				{	--7. 丛林
					nameID = 694,
					icon = "img_lindi",
					MainTerrainID = 7;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1丛林
							nameID = 694,
							ChildTerrainID = 7;
							Set = {},
						},
						{
							--1丛林山丘
							nameID = 9154,
							ChildTerrainID = 17;
							Set = {},
						},
					},
				},
				{	--8. 盆地
					nameID = 9113,
					icon = "img_pendi",
					MainTerrainID = 23;
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--23盆地
							nameID = 9113,
							ChildTerrainID = 23;
							Set = {},
						},
						{
							--24盆地边缘
							nameID = 9116,
							ChildTerrainID = 24;
							Set = {},
						},
						{
							--25竹林盆地
							nameID = 9114,
							ChildTerrainID = 25;
							Set = {},
						},
						{
							--26桃树盆地
							nameID = 9115,
							ChildTerrainID = 26;
							Set = {},
						},
					},
				},
				{	--9. 雨林
					nameID = 2075,--define in stringdef.csv
					icon = "img_yulin",--\res\ui\mobile\texture0\terrainedit\img_yulin.png
					MainTerrainID = 39;--default ChildTerrainID
					ChildTerrain = {
						curChildTerrainIndex = 1,
						{
							--1雨林
							nameID = 2075,
							ChildTerrainID = 39;--define in BiomeTypes.h BIOME_TYPE --- BIOME_RAINFOREST=39
							Set = {},
						},
					},
				},
				--初始化
				Init = function(self)
					Log("MainTerrain: Init:");
					self:InitSet();
					self:LoadSet();
				end,

				--初始化设置, 这个函数必须调用.
				InitSet = function(self)
					Log("InitSet:");
					for i = 1, #self do
						for j = 1, #(self[i].ChildTerrain) do
							self[i].ChildTerrain[j].Set = {};
							self[i].ChildTerrain[j].Set = {
								--高度
								Height = { Min = 20, Max = 80, },

								--地表层方块
								SurfaceBlock = { Type = "SurfaceBlock", blockID = 0, },

								--填充层方块
								FillBlock = { Type = "FillBlock", blockID = 0, },

								--填充层厚度
								FillHeight = { nameID = 9108, Val = 30, },

								--地形生成概率
								Probability = { nameID = 9109, Val = 60, },
							};
						end
					end
				end,

				--加载设置, 从CSV中加载原始配置.
				LoadSet = function(self)
					Log("LoadSet:");
					local MainTerrain = self;
					for i = 1, #MainTerrain do
						local ChildTerrain = MainTerrain[i].ChildTerrain;

						for j = 1, #ChildTerrain do
							local Set = ChildTerrain[j].Set;
							local ChildTerrainID =  ChildTerrain[j].ChildTerrainID;
							local def = DefMgr:getOriginalBiomeDefById(ChildTerrainID);

							if def ~= nil then
								Set.Height.Min = math.floor((def.MinHeight + 1.9) * 64 / 3.8 + 32);				--小值:要将"存表值" 转化为"拉值".
								Set.Height.Max = math.floor(def.MaxHeight * 64 / 4 + Set.Height.Min + 16);			--大值: 16，为校正值, 回算的时候要减掉
								Set.SurfaceBlock.blockID = def.TopBlock or 0;
								Set.FillBlock.blockID = def.FillBlock or 0;
								Set.FillHeight.Val = def.FillDepth or 0;
								Set.Probability.Val = def.geneRate or 0;

								Log("i = " .. i .. ", j = " .. j);
								Log("minVal = " .. def.MinHeight .. ", maxVal = " .. def.MaxHeight);

								--if Set.Height.Min < 0 then Set.Height.Min = 0 end;
								if Set.Height.Max < 0 then Set.Height.Max = 0 end;
								if Set.FillHeight.Val < 0 then Set.FillHeight.Val = 0 end;
								if Set.Probability.Val < 0 then Set.Probability.Val = 0 end;
							end
						end
					end
				end,

				Update = function(self)
					Log("MainTerrain: Update():");
					local curMainTerrainIndex = self.curMainTerrainIndex;
					local ChildTerrain = self[curMainTerrainIndex].ChildTerrain;
					local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;
					Log("curMainTerrainIndex = " .. curMainTerrainIndex);
					Log("curChildTerrainIndex = " .. curChildTerrainIndex);

					--1. 主地貌
					if true then
						local mainTerrainBoxUI = "TerrainFrameMainTerrainBox";
						for i = 1, #self do
							local btnUI = mainTerrainBoxUI .. "Btn" .. i;
							local btn = getglobal(btnUI);
							local name = getglobal(btnUI .. "Name");
							local icon = getglobal(btnUI .. "Icon");
							local normal = getglobal(btnUI .."Normal");
							local checked = getglobal(btnUI .. "Checked");

							if self.bIsFirstShow then
								btn:Show();
								btn:SetPoint("left", mainTerrainBoxUI .. "Plane", "left", 150 * (i - 1), 0);
								name:SetText(GetS(self[i].nameID));
								icon:SetTexUV(self[i].icon);
							end

							if i == curMainTerrainIndex then
								checked:Show();
								normal:Hide();
								name:SetTextColor(255, 255, 255);
							else
								checked:Hide();
								normal:Show();
								name:SetTextColor(185, 185, 185);
							end
						end
					end

					--2. 子地貌
					if true then
						local childTerrainBoxUI = "TerrainFrameChildTerrainBox";
						for i = 1, 99 do
							local btnUI = childTerrainBoxUI .. "Btn" .. i;
							if not HasUIFrame(btnUI) then
								break;
							end

							local btn = getglobal(btnUI);
							local name = getglobal(btnUI .. "Name");
							local normal = getglobal(btnUI .."Normal");
							local checked = getglobal(btnUI .. "Checked");
							local jiantou = getglobal(btnUI .. "Jiantou");
							if ChildTerrain and i <= #ChildTerrain then
								btn:Show();
								btn:SetPoint("topleft", childTerrainBoxUI .. "Plane", "topleft", 0, 59 * (i - 1));
								name:SetText(GetS(ChildTerrain[i].nameID));

								if i == curChildTerrainIndex then
									normal:Hide();
									checked:Show();
									jiantou:Show();
									name:SetTextColor(60, 73, 76);
								else
									normal:Show();
									checked:Hide();
									jiantou:Hide();
									name:SetTextColor(60, 73, 76);
								end
							else
								btn:Hide();
							end
						end
						local plane = getglobal(childTerrainBoxUI .. "Plane");
						local planeW = plane:GetWidth();
						local planeH = 59 * (#ChildTerrain);
						local boxH = getglobal(childTerrainBoxUI):GetHeight();
						if planeH < boxH then planeH = boxH; end
						plane:SetSize(planeW, planeH);
					end

					--3. 设置
					if true then
						if ChildTerrain and #ChildTerrain > 0 and ChildTerrain[curChildTerrainIndex].Set then
							local Set = ChildTerrain[curChildTerrainIndex].Set;
							local SetFrameUI = "TerrainEditFrameBodyPage1RightFrame";

							--地貌名字
							local nameStrID	= ChildTerrain[curChildTerrainIndex].nameID
							getglobal("TerrainEditFrameBodyPage1CenteFrameTerrName"):SetText(GetS(nameStrID) .. GetS(10504));

							--高度
							getglobal("TerrainEditFrameBodyPage1RightFrameHeightHeightBar"):SetValue1(Set.Height.Min);
							getglobal("TerrainEditFrameBodyPage1RightFrameHeightHeightBar"):SetValue2(Set.Height.Max);

							--地表层方块
							local blockID = Set.SurfaceBlock.blockID;
							local btnUI = "TerrainEditFrameBodyPage1RightFrameSurfaceBlockBtn";
							local btn = getglobal(btnUI);
							local delBtn = getglobal(btnUI .. "Del");
							local icon = getglobal(btnUI .. "Icon");
							local name = getglobal(btnUI .. "Name");
							if blockID == 0 then
								delBtn:Hide();
								icon:Hide();
								name:Hide();
							else
								local def = DXBJGetBlockByID(blockID);
								local blkdef = BlockDefCsv:get(def.ID)
								if blkdef ~= nil then 
									Log("DXBJUpdateBlockSlot topblock not nil")
									DXBJUpdateBlockSlot(btn, def);
								else
									Log("DXBJUpdateBlockSlot topblock is nil")
								end
								delBtn:Show();
								icon:Show();
								name:Show();
							end


							--填充层方块
							local blockID = Set.FillBlock.blockID;
							local btnUI = "TerrainEditFrameBodyPage1RightFrameFillBlockBtn";
							local btn = getglobal(btnUI);
							local delBtn = getglobal(btnUI .. "Del");
							local icon = getglobal(btnUI .. "Icon");
							local name = getglobal(btnUI .. "Name");
							if blockID == 0 then
								delBtn:Hide();
								icon:Hide();
								name:Hide();
							else
								local def = DXBJGetBlockByID(blockID);
								DXBJUpdateBlockSlot(btn, def);
								delBtn:Show();
								icon:Show();
								name:Show();
							end

							--填充层厚度
							getglobal(SetFrameUI .. "FillHeightTitle"):SetText(GetS(Set.FillHeight.nameID));
							local text = Set.FillHeight.Val .. GetS(9111);
							getglobal(SetFrameUI .. "FillHeightNum"):SetText(text);

							--生成概率
							getglobal(SetFrameUI .. "ProbabilityTitle"):SetText(GetS(Set.Probability.nameID));
							local text = Set.Probability.Val .. "%";
							getglobal(SetFrameUI .. "ProbabilityNum"):SetText(text);
						end
					end

					self.bIsFirstShow = false;

					--刷新地形预览
					--TerrainEdit_UpdateTerrainView();
				end,

				MainBtn_OnClick = function(self, id, bIsUpdateView)
					self.curMainTerrainIndex = id or 1;
					self:ChildBtn_OnClick(1, bIsUpdateView);
					--self:Update();
				end,

				ChildBtn_OnClick = function(self, id, bIsUpdateView)
					Log("ChildBtn_OnClick")
					local curMainTerrainIndex = self.curMainTerrainIndex;
					self[curMainTerrainIndex].ChildTerrain.curChildTerrainIndex = id or 1;
					self:Update();
					if bIsUpdateView then
						--刷新地形预览
						Log("UpdateView!");
						TerrainEdit_UpdateTerrainView();
					end
				end,

				--方块格数调节
				BlockNumSet = function(self, ID, Flag)
					--Flag == 1: 减.
					local curMainTerrainIndex = self.curMainTerrainIndex;
					local ChildTerrain = self[curMainTerrainIndex].ChildTerrain;
					local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;

					if ChildTerrain and #ChildTerrain > 0 and ChildTerrain[curChildTerrainIndex].Set then
						local Set = ChildTerrain[curChildTerrainIndex].Set;
						if Flag == 1 then Set[ID].Val = Set[ID].Val - 1; else Set[ID].Val = Set[ID].Val + 1; end

						if Set[ID].Val < 1 then
							Set[ID].Val = 1;
							--返回false, 表示不用刷新预览地图.
							return false;
						end

						self:Update();

						return true;
					end
				end,

				--高度滑动条调节
				HeightSliderSet = function(self, Val_1, Val_2)
					--传进来的是"拉值", 要转化为"存表值".
					local SetFrameUI = "TerrainEditFrameBodyPage1RightFrame";
					local curMainTerrainIndex = self.curMainTerrainIndex;
					local ChildTerrain = self[curMainTerrainIndex].ChildTerrain;
					local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;

					if ChildTerrain and #ChildTerrain > 0 and ChildTerrain[curChildTerrainIndex].Set then
						local Set = ChildTerrain[curChildTerrainIndex].Set;
						if Val_1 > 96 then Val_1 = 96; end;		 --Val_1:最大为96
						Set.Height.Min = Val_1;
						Set.Height.Max = Val_2;
						Log("HeightSliderSet: Val_1 = " .. Val_1 .. ", Val_2 = " .. Val_2);
					end
				end,

				--方块选择
				SetBlock = function(self, SelectType, blockID)
					Log("SetBlock: SelectType = " .. SelectType);
					local curMainTerrainIndex = self.curMainTerrainIndex;
					local ChildTerrain = self[curMainTerrainIndex].ChildTerrain;
					local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;

					if SelectType and blockID then
						if ChildTerrain and #ChildTerrain > 0 and ChildTerrain[curChildTerrainIndex].Set then
							local Set = ChildTerrain[curChildTerrainIndex].Set;
							if SelectType == "SurfaceBlock" then
								Set.SurfaceBlock.blockID = blockID;
							elseif SelectType == "FillBlock" then
								Set.FillBlock.blockID = blockID;
							end

							self:Update();
						end
					end
				end,
			},	--主地貌end
		},--end:Tab1

		--2. 地表生成
		{
			nameID = 9099,	--地表生成
			Class = {
				btnFirstNameUI = "TerrainEditFrameBodyPage2CenterClassBtn",
				itemBox = "TerrainFrameSurfaceItemBox";
				curTerrainIndex = 1,
				TerrainList = {},

				--结构修改
				--[[
				curTerrainIndex = 1,
				TerrainList = {
					{
						--沙漠
						nameID = 9112
						terrainID = 0,
						curClassIndex = 1,
						ItemClass = {
							{
								--1. 植物
								nameID = 9117,
								curItemIndex = 1,
								ItemList = {
									{blockID = 300, nDensityVal = 30, Name = "ChunkFlowers301"},
									{blockID = 301, nDensityVal = 30, Name = "ChunkFlowers301"},
									{...},
								},
							},
							{
								--2. 建筑
								nameID = 9118,
							},
							{
								--3. 道具
								nameID = 9119,
							},
						},
					},
					{
						--草原
						nameID = 9112
						terrainID = 0,
						curClassIndex = 1,
						ItemClass = {
							{},
							{},
						},
					},
					{...}
				},
				]]

				--初始化
				Init = function(self)
					Log("Class:Init:");
					self:InitTerrainList();
					self:LoadItemList();
				end,

				InitTerrainList = function(self)
				--{{
					Log("InitTerrainList:");
					self.TerrainList = nil;
					self.TerrainList = {};
					--地形
					for j = 1, #(g_SurfaceAndActor_TerrainConfig.Terrain) do
						table.insert(self.TerrainList, {
								nameID = g_SurfaceAndActor_TerrainConfig.Terrain[j].nameID,
								terrainID = g_SurfaceAndActor_TerrainConfig.Terrain[j].terrainID,
								curClassIndex = 1,
								ItemClass = {},
							}
						);

						self.TerrainList[j].ItemClass[1] = {
							--1. 植物
							nameID = 9117,
							curItemIndex = 1,
							ItemList = {},
						};

						--加载植物条目: 浓度为0的隐藏掉.
						local t = TerrainParameterBlocks.PlantBlock[1].t;
						for k = 1, #t do
							table.insert(self.TerrainList[j].ItemClass[1].ItemList, {
								blockID = t[k].ID,
								nDensityVal = t[k].nDensityVal,
								Name = t[k].Name,
							});

							--初始化滑动条属性
							local itemUI = self.itemBox .. k;
							if HasUIFrame(itemUI) then
								local bar = getglobal(itemUI .. "SliderBar");
								bar:SetMinValue(50);
								bar:SetMaxValue(1000);
								bar:SetValueStep(50);
								getglobal(itemUI .. "SelBtn"):Disable(false);	--使不能点击
							end
						end

						self.TerrainList[j].ItemClass[2] = {
							--2. 建筑
							nameID = 9118,
							curItemIndex = 1,
							ItemList = {},
						};

						self.TerrainList[j].ItemClass[3] = {
							--3. 道具
							nameID = 9119,
							curItemIndex = 1,
							ItemList = {},
						};
					end
				--}}
				end,

				--加载Item
				LoadItemList = function(self)
					Log("LoadItemList:");
					local TerrainList = self.TerrainList;
					for i = 1, #TerrainList do
						local ItemClass = TerrainList[i].ItemClass;
						local terrainID = TerrainList[i].terrainID;

						Log("--------terrainID: " .. terrainID .. " -------- ");
						--获取原始的定义.
						local def = DefMgr:getOriginalBiomeDefById(terrainID);
						if def ~= nil then
							for j = 1, #ItemClass do
								local ItemList = ItemClass[j].ItemList;
								if j == 1 then
									for k = 1, #ItemList do
										--每一个植物条目
										local blockID = ItemList[k].blockID;
										local Name = ItemList[k].Name;

										if def[Name] then
											--单值
											ItemList[k].nDensityVal = def[Name];
											--Log("1111: Name = " .. Name .. ", nDensityVal = " .. def[Name]);
										else
											--数组
											local nDensityVal = 0;
											if string.find(Name, "ChunkGrass") then
												--Log("3333: ChunkGrass:")
												nDensityVal = DefMgr:getOriginalBiomeArrayVal(terrainID, blockID, "ChunkGrass");
											elseif string.find(Name, "ChunkFlowers") then
												--Log("4444: ChunkFlowers:")
												nDensityVal = DefMgr:getOriginalBiomeArrayVal(terrainID, blockID, "ChunkFlowers");
											elseif string.find(Name, "ChunkCorals") then
												--Log("5555: ChunkCorals:")
												nDensityVal = DefMgr:getOriginalBiomeArrayVal(terrainID, blockID, "ChunkCorals");
											elseif string.find(Name, "ChunkSeaPlants") then
												--Log("5555: ChunkCorals:")
												nDensityVal = DefMgr:getOriginalBiomeArrayVal(terrainID, blockID, "ChunkSeaPlants");
											elseif string.find(Name, "ChunkJaggedFern") then
												--Log("5555: ChunkCorals:")
												nDensityVal = DefMgr:getOriginalBiomeArrayVal(terrainID, blockID, "ChunkJaggedFern");
											elseif string.find(Name, "ChunkTreex") then
												--加载"树"的初始浓度, 树和别的植物有些区别, 在lua表中配置初始值.
												local plantConfig = g_SurfaceAndActor_TerrainConfig.Terrain[i].plantConfig;
												if plantConfig then
													for k = 1, #plantConfig do
														if Name == plantConfig[k].Name then
															nDensityVal = plantConfig[k].nDensityVal;
															break;
														end
													end
												end
											end

											ItemList[k].nDensityVal = nDensityVal;
											--Log("2222: Name = " .. Name .. ", nDensityVal = " .. nDensityVal);
										end

									end
								end
							end
						end
					end
				end,

				--刷新"类别"按钮
				UpdateClassBtn = function(self)
				---{{
					Log("UpdateClassBtn:");
					local curTerrainIndex = self.curTerrainIndex;
					local ItemClass = self.TerrainList[curTerrainIndex].ItemClass;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;

					for i = 1, #ItemClass do
						local btnUI = self.btnFirstNameUI .. i;
						local btn = getglobal(btnUI);
						local name = getglobal(btnUI .. "Name");
						local checked = getglobal(btnUI .. "Checked");
						local leftOffset = 0;
						local x = leftOffset + (i - 1) * 170;

						btn:SetPoint("left", self.btnFirstNameUI, "left", x, 0);
						name:SetText(GetS(ItemClass[i].nameID));
						if i == curClassIndex then
							checked:Show();
							name:SetTextColor(76, 76, 76);
						else
							checked:Hide();
							name:SetTextColor(55, 54, 48);
						end

						if 1 ~= i then
							getglobal(btnUI .. "Normal"):SetGray(true);
							btn:Disable();
						end
					end
				---}}
				end,

				--"类别"按钮点击
				ClassBtn_OnClick = function(self, id)
					Log("ClassBtn_OnClick:");
					local curTerrainIndex = self.curTerrainIndex;
					self.TerrainList[curTerrainIndex].curClassIndex = id or 1;
					self:UpdateClassBtn();
					self:UpdateItemList();	--刷新该地形的条目
				end,

				--"地形"按钮点击
				TerrainBtn_OnClick = function(self, id)
					Log("TerrainBtn_OnClick:");
					self.curTerrainIndex = id;
					self:UpdateTerrainBtn();
					self:ClassBtn_OnClick(1);
				end,

				--刷新"地形"按钮
				UpdateTerrainBtn = function(self)
				---{{
					Log("UpdateTerrainBtn:");
					local curTerrainIndex = self.curTerrainIndex;
					local BoxUI = "TerrainFrameSurfaceTerrainBox";
					local planeUI = BoxUI .. "Plane";
					local y = 0;
					for i = 1, 99 do
						local btnUI = BoxUI .. i;
						if not HasUIFrame(btnUI) then
							break;
						end

						local btn = getglobal(btnUI);
						local normal = getglobal(btnUI .. "Normal");
						local checked = getglobal(btnUI .. "Checked");
						local jiantou = getglobal(btnUI .. "Jiantou");
						local name = getglobal(btnUI .. "Name");
						local TerrainList = self.TerrainList;

						if i <= #TerrainList then
							btn:Show();
							btn:SetPoint("topright", planeUI, "topright", 18, y);
							name:SetText(GetS(TerrainList[i].nameID));
							y = y + 70;

							if i == curTerrainIndex then
								--选中
								normal:Hide();
								checked:Show();
								jiantou:Show();
								name:SetTextColor(76, 76, 76);
							else
								normal:Show();
								checked:Hide();
								jiantou:Hide();
								name:SetTextColor(76, 76, 76);
							end
						else
							btn:Hide();
						end
					end

					local planeH = y;
					local planeW = getglobal(planeUI):GetWidth();
					if y < 530 then planeH = 530; end;
					getglobal(planeUI):SetSize(planeW, planeH);

					--getglobal(BoxUI):resetOffsetPos();
				---}}
				end,

				--刷新"条目"列表, nDensityVal == 0的隐藏掉.
				UpdateItemList = function(self)
				---{{
					Log("UpdateItemList:");
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local ItemList = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList;

					local topOffset = 0;
					local y = topOffset;
					local planeUI = self.itemBox .. "Plane";

					for i = 1, 99 do
						local itemUI = self.itemBox .. i;

						if not HasUIFrame(itemUI) then
							break;
						end

						local item = getglobal(itemUI);

						if i <= #ItemList then
							if ItemList[i].nDensityVal == 0 then
								item:Hide();
							else
								--位置
								item:Show();
								item:SetPoint("top", planeUI, "top", 0, y);
								y = y + 127;
							end

							self:UpdateSignalItem(ItemList[i], i);
						else
							item:Hide();
						end
					end

					local AddNewBtn = getglobal(self.itemBox .. "AddNewBtn");
					AddNewBtn:SetPoint("top", planeUI, "top", 0, y);
					--AddNewBtn:SetClientID(#ItemList + 1);

					y = y + 127;
					local planeH = y;
					local planeW = getglobal(planeUI):GetWidth();
					if y < 366 then planeH = 366; end;
					getglobal(planeUI):SetSize(planeW, planeH);
				---}}
				end,

				--更新"单个条目""
				UpdateSignalItem = function(self, ItemData, ItemIndex)
				---{{
					--Log("UpdateSignalItem:");
					if ItemData and ItemIndex then
						--1. 方块选择按钮
						local itemUI = self.itemBox .. ItemIndex;
						local blockID = ItemData.blockID;
						local def = DXBJGetBlockByID(blockID);
						local btn = getglobal(itemUI .. "SelBtn");
						DXBJUpdateBlockSlot(btn, def);

						--2. 滑动条
						local nDensityVal = ItemData.nDensityVal;
						if self:IsSpecialPlant(blockID) then
							Log("SpecialPlant: blockID = " .. blockID .. "nDensityVal = " .. nDensityVal);
							nDensityVal = math.floor(nDensityVal / 100);
						end

						local bar = getglobal(itemUI .. "SliderBar");
						bar:SetValue(nDensityVal);
					end
				---}}
				end,

				--删除条目: 将,nDensityVal 设为0
				DeleteItem = function(self, index)
				---{{
					if index then
						Log("DeleteItem: index = " .. index);
						local curTerrainIndex = self.curTerrainIndex;
						local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
						local ItemList = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList;

						if index <= #ItemList then
							--table.remove(ItemList, index);
							ItemList[index].nDensityVal = 0;
							self:UpdateItemList();
						end
					end
				---}}
				end,

				--设置滑动条值
				SetSliderVal = function(self, val, index)
				---{{
					if val and index then
						local curTerrainIndex = self.curTerrainIndex;
						local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
						local blockID = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList[index].blockID;
						Log("SetSliderVal: val = " .. val .. "index = " .. index);

						if self:IsSpecialPlant(blockID) then
							Log("SpecialPlant: blockID = " .. blockID);
							val = val * 100;
						end
						self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList[index].nDensityVal = val;
					end
				---}}
				end,

				IsSpecialPlant = function(self, blockID)
				--{{
					Log("IsSpecialPlant:");
					local SpecialList = TerrainParameterBlocks.PlantBlock.SpecialList;
					for i = 1, #SpecialList do
						if blockID == SpecialList[i] then
							return true;
						end
					end
					return false;
				--}}
				end,

				--方块选择
				ItemSelBtn_OnClick = function(self, index)
				---{{
					Log("ItemSelBtn_OnClick: index = " .. index);
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local ItemList = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList;
					if index then
						-- if index > #ItemList then
						-- 	Log("AddItem:");
						-- 	table.insert(ItemList, {blockID = 0, nDensityVal = 0,});
						-- 	--self:UpdateItemList();
						-- else
						-- 	--修改
						-- 	Log("ModefyItem:");
						-- end
						--新增按钮的id是0, 即 index == 0表示新增.
						self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].curItemIndex = index or 1;
					end
				---}}
				end,

				SetItemSelBtn = function(self, blockID)
				---{{
					Log("SetItemSelBtn:");
					if blockID then
						local curTerrainIndex = self.curTerrainIndex;
						local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
						local curItemIndex = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].curItemIndex;
						local ItemList = self.TerrainList[curTerrainIndex].ItemClass[curClassIndex].ItemList;

						if curItemIndex == 0 then
							--0: 表示新增
							local nShowItemNum = 0;
							local offsetY = 0;

							for i = 1, #ItemList do
								if getglobal(self.itemBox .. i):IsShown() then nShowItemNum = nShowItemNum + 1; end

								if ItemList[i].blockID == blockID then
									--新增植物, 等价于将 nDensityVal 改为大于0.
									if ItemList[i].nDensityVal > 0 then
										--如果该植物已经存在, 提示"该植物已经存在"
										ShowGameTips(GetS(10508), 3);
										offsetY = 0 - (nShowItemNum - 3) * 127;
									else
										--不存在则添加
										ItemList[i].nDensityVal = 30;
										ShowGameTips(GetS(4079), 3);
										offsetY = 0 - (nShowItemNum - 2) * 127;
									end

									--滑动窗口定位到该植物处
									Log("nShowItemNum = " .. nShowItemNum);
									Log("offsetY = " .. offsetY);
									getglobal(self.itemBox):setCurOffsetY(offsetY);
									break;
								end
							end
						else
							--修改:
							ItemList[curItemIndex].blockID = blockID;
						end

						self:UpdateItemList()
					end
				---}}
				end,
			},
			
		},--end:Tab2

		--3. 生物生成
		{
			nameID = 9100,	--生物生成
			Class = {
				btnFirstNameUI = "TerrainEditFrameBodyPage3CenterClassBtn",
				monsterBoxUI = "TerrainFrameMonsterSelectBox";
				itemBox = "TerrainFrameSurfaceItemBox",
				curTerrainIndex = 1,
				TerrainList = {},
				OriginalMonsterInfo = {},		--用来保存原始的生物数量信息, 以备恢复默认时使用
				bIsFirstLoadMonsterNum = true,	--和'OriginalMonsterInfo'配合使用.

				--[[
				--结构变更: 地形分类下面有生物分类, 生物分类下面有不同的生物, 每一个生物有一个数量.
				curTerrainIndex = 1,
				TerrainList = {
					{
						--沙漠
						nameID = 9112
						terrainID = 0,
						curClassIndex = 1,
						MonsterClass = {
							{
								--1. 动物
								nameID = 9125,
								maxNum = 50,
								typeID = 1,
								curMonsterIndex = 1,
								MonsterList = {
									{MonsterID = 3101, curNum = 0, },
									{MonsterID = 3102, curNum = 0, },
									{...},
								},
							},
							{
								--2. 稀有动物
							},
							{
								--3. 飞行生物
							},
							{
								--4. 怪物
							},
						},
					},
					{
						--草原
						nameID = 9112
						terrainID = 0,
						curClassIndex = 1,
						MonsterClass = {
							{},
							{},
						},
					},
					{...}
				},
				--]]

				--初始化
				Init = function(self)
				--{{
					Log("Monster: Init:");
					self:InitTerrainList();
				--}}
				end,

				--初始化地形列表, 从配置表里读过来, 并初始化: TerrainList[] = {nameID, terrainID, curMonsterIndex, MonsterListSet}.
				InitTerrainList = function(self)
				--{{
					Log("InitTerrainList:");
					self.TerrainList = nil;
					self.TerrainList = {};
					--地形
					for j = 1, #(g_SurfaceAndActor_TerrainConfig.Terrain) do
						table.insert(self.TerrainList, {
								nameID = g_SurfaceAndActor_TerrainConfig.Terrain[j].nameID,
								terrainID = g_SurfaceAndActor_TerrainConfig.Terrain[j].terrainID,
								curClassIndex = 1,
								MonsterClass = {},
							}
						);

						--生物分类
						for nMonsterClassIndex = 1, #g_TerrainParameter_MonsterConfig do
							table.insert(self.TerrainList[j].MonsterClass, {
									nameID = g_TerrainParameter_MonsterConfig[nMonsterClassIndex].nameID,
									maxNum = g_TerrainParameter_MonsterConfig[nMonsterClassIndex].maxNum,
									typeID = g_TerrainParameter_MonsterConfig[nMonsterClassIndex].typeID,
									curMonsterIndex = 1,
									MonsterList = {},
								}
							);

							--生物
							for nMonsterIndex = 1, #g_TerrainParameter_MonsterConfig[nMonsterClassIndex].MonsterIDList do
								table.insert(self.TerrainList[j].MonsterClass[nMonsterClassIndex].MonsterList, {
										MonsterID = g_TerrainParameter_MonsterConfig[nMonsterClassIndex].MonsterIDList[nMonsterIndex],
										curNum = 0;
									}
								);
							end
						end
					end

					--加载生物数量
					self:LoadMonsterNum();
				--}}
				end,

				--加载生物数量从csv表
				LoadMonsterNum = function(self)
				--{{
				Log("LoadMonsterNum:");
					for i = 1, #self.TerrainList do
						local terrainID = self.TerrainList[i].terrainID;

						for j = 1, #self.TerrainList[i].MonsterClass do
							for k = 1, #self.TerrainList[i].MonsterClass[j].MonsterList do
								local Monster = self.TerrainList[i].MonsterClass[j].MonsterList[k];
								local MonsterID = Monster.MonsterID
								local curNum = DefMgr:getOriginalBiomeArrayVal(terrainID, MonsterID, "MonsterNum");
								Monster.curNum = curNum;

								Log("i = " .. i .. ", j = " .. j .. ", curNum = " .. curNum);
							end
						end
					end

					--第一次加载的时候把数据保存起来.
					if self.bIsFirstLoadMonsterNum then
						self.bIsFirstLoadMonsterNum = false;
						self.OriginalMonsterInfo = {};

						for i = 1, #self.TerrainList do
							self.OriginalMonsterInfo[i] = {};
							self.OriginalMonsterInfo[i].MonsterClass = {};

							for j = 1, #self.TerrainList[i].MonsterClass do
								self.OriginalMonsterInfo[i].MonsterClass[j] = {};
								self.OriginalMonsterInfo[i].MonsterClass[j].MonsterList = {};

								for k = 1, #self.TerrainList[i].MonsterClass[j].MonsterList do
									local _curNum = self.TerrainList[i].MonsterClass[j].MonsterList[k].curNum;
									self.OriginalMonsterInfo[i].MonsterClass[j].MonsterList[k] = {curNum = _curNum};
								end
							end
						end

						Log("OriginalMonsterInfo :");
					end
				--}}
				end,

				--生物数量恢复默认, 和别的恢复默认有些区别, 生物需要将第一次加载的默认值保存起来以备后续使用.
				ReSetMonsterNum = function(self)
					Log("ReSetMonsterNum:");
					for i = 1, #self.TerrainList do
						local terrainID = self.TerrainList[i].terrainID;

						for j = 1, #self.TerrainList[i].MonsterClass do
							for k = 1, #self.TerrainList[i].MonsterClass[j].MonsterList do
								local MonsterID = self.TerrainList[i].MonsterClass[j].MonsterList[k].MonsterID;
								local curNum = self.OriginalMonsterInfo[i].MonsterClass[j].MonsterList[k].curNum;
								local def = DefMgr:getBiomeDef(terrainID);
								ModMgr:SetBiomeMonsterValByID(MonsterID, curNum, def);

								self.TerrainList[i].MonsterClass[j].MonsterList[k].curNum = curNum;
							end
						end
					end

					Log("OriginalMonsterInfo :");

					self:UpdateMonsterBtn();
					self:UpdateMonsterNumPreview();
				end,

				--"地形"按钮点击
				TerrainBtn_OnClick = function(self, id)
				--{{
					Log("TerrainBtn_OnClick:");
					self.curTerrainIndex = id;
					self:UpdateTerrainBtn();
					self:ClassBtn_OnClick(1);
					self:UpdateMonsterNumPreview();
				--}}
				end,

				--"类别"按钮点击
				ClassBtn_OnClick = function(self, id)
				--{{
					Log("ClassBtn_OnClick:");
					local curTerrainIndex = self.curTerrainIndex;
					self.TerrainList[curTerrainIndex].curClassIndex = id or 1;
					self:UpdateClassBtn();
					self:MonsterBtn_OnClick(1);
					self:UpdatePreViewFrame();
					self:UpdateMonsterNumPreview();
				--}}
				end,

				--"生物"按钮点击
				MonsterBtn_OnClick = function(self, id)
				--{{
					Log("MonsterBtn_OnClick:");
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].curMonsterIndex = id;
					self:UpdateMonsterBtn();
				--}}
				end,

				--"类别"按钮状态
				UpdateClassBtn = function(self)
				---{{
					Log("UpdateClassBtn:");
					local curTerrainIndex = self.curTerrainIndex;
					local MonsterClass = self.TerrainList[curTerrainIndex].MonsterClass;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;

					for i = 1, #MonsterClass do
						local btnUI = self.btnFirstNameUI .. i;
						local btn = getglobal(btnUI);
						local name = getglobal(btnUI .. "Name");
						local checked = getglobal(btnUI .. "Checked");
						local leftOffset = 0;
						local x = leftOffset + (i - 1) * 170;

						btn:SetPoint("left", self.btnFirstNameUI, "left", x, 0);
						name:SetText(GetS(MonsterClass[i].nameID));
						if i == curClassIndex then
							checked:Show();
							name:SetTextColor(76, 76, 76);
						else
							checked:Hide();
							name:SetTextColor(76, 76, 76);
						end
					end
				---}}
				end,

				--"地形"按钮状态
				UpdateTerrainBtn = function(self)
				---{{
					Log("UpdateTerrainBtn:");
					local BoxUI = "TerrainFrameMonsterTerrainBox";
					local planeUI = BoxUI .. "Plane";
					local y = 0;
					for i = 1, 99 do
						local btnUI = BoxUI .. i;
						if not HasUIFrame(btnUI) then
							break;
						end

						local btn = getglobal(btnUI);
						local checked = getglobal(btnUI .. "Checked");
						local name = getglobal(btnUI .. "Name");
						local jiantou = getglobal(btnUI .. "Jiantou");
						local curTerrainIndex = self.curTerrainIndex;
						local TerrainList = self.TerrainList;

						if i <= #TerrainList then
							btn:Show();
							btn:SetPoint("top", planeUI, "top", 0, y);
							name:SetText(GetS(TerrainList[i].nameID));
							y = y + 58;

							if i == curTerrainIndex then
								--选中
								checked:Show();
								jiantou:Show();
								name:SetTextColor(76, 76, 76);
							else
								checked:Hide();
								jiantou:Hide();
								name:SetTextColor(76, 76, 76);
							end
						else
							btn:Hide();
						end
					end

					local planeH = y;
					local planeW = getglobal(planeUI):GetWidth();
					if y < 538 then planeH = 538; end;
					getglobal(planeUI):SetSize(planeW, planeH);

					getglobal(self.monsterBoxUI):resetOffsetPos();
				---}}
				end,

				--"生物"按钮刷新
				UpdateMonsterBtn = function(self)
				--{{
					Log("UpdateMonsterBtn:");
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local curMonsterIndex = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].curMonsterIndex;
					local MonsterList = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].MonsterList;
					
					local boxUI = self.monsterBoxUI;
					local planeUI = boxUI .. "Plane";
					local x = 5;

					for i = 1, 99 do
						local btnUI = boxUI .. "Btn" .. i;
						if not HasUIFrame(btnUI) 
							then break;
						end

						local btn = getglobal(btnUI);
						local name = getglobal(btnUI .. "Name");
						local icon = getglobal(btnUI .. "Icon");
						local checked = getglobal(btnUI .. "Checked");

						if i <= #MonsterList then
							Log("i = " .. i .. ", ID = " .. MonsterList[i].MonsterID);
							local monsterDef = TerrainEditMonster_GetMonsterDefByID(MonsterList[i].MonsterID);

							if monsterDef then
								Log("monsterDef.ID = " .. monsterDef.ID);
								btn:Show();
								name:SetText(monsterDef.Name);
								btn:SetPoint("left", planeUI, "left", x, 0);
								x = x + 114;
								SetActorIcon(icon, monsterDef.ID);

								if i == curMonsterIndex then
									checked:Show();

									--测试: 显示当前生物数量.
									-- local num = MonsterList[i].curNum;
									-- local text = ": " .. monsterDef.Name .. "的数量为：" .. num;
									-- getglobal("TerrainEditFrameBodyPage3CenterPreViewCurNum"):SetText(text);
								else
									checked:Hide();
								end
							else

							end
						else
							btn:Hide();
						end
					end

					local plane = getglobal(planeUI);
					local boxW = getglobal(boxUI):GetWidth();
					local planeH = plane:GetHeight();
					if x < boxW then x = boxW; end
					plane:SetSize(x, planeH);
				--}}
				end,

				--"预览"界面刷新
				UpdatePreViewFrame = function(self)
				--{{
					Log("UpdatePreViewFrame:");
					--动物总量最大为：50只
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local text = GetS(self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].nameID) .. GetS(9131) .. "：#cffd556" .. self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].maxNum .. GetS(9132) .. "#n";
					local MaxNumDesc = getglobal("TerrainEditFrameBodyPage3CenterPreViewMaxNum");
					MaxNumDesc:SetText(text);
				--}}
				end,

				--设置生物数量
				SetMonsterNum = function(self, nType)
				--{{
					Log("SetMonsterNum:");
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local curMonsterIndex = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].curMonsterIndex;
					local MonsterList = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].MonsterList;
					----
					local terrainID = self.TerrainList[curTerrainIndex].terrainID;
					local MonsterID = MonsterList[curMonsterIndex].MonsterID;
					local monsterDef =  MonsterCsv:get(MonsterID);
					local monsterType = 1;
					if monsterDef ~= nil then
						monsterType  = monsterDef.Type 
					end 
					local terrainmonsterview = getglobal("TerrainEditFrameBodyPage3CenterPreViewTerrainMonsterPreview");
					if nType == 1 then
						--加											
						local addNum =  terrainmonsterview:getNeedAddNumForShowOneMonster(1,terrainID,monsterType, MonsterID)
						Log("curNum = " .. MonsterList[curMonsterIndex].curNum .." addNum = " .. addNum);
						MonsterList[curMonsterIndex].curNum = MonsterList[curMonsterIndex].curNum + addNum;
					else
						local deNum =  terrainmonsterview:getNeedAddNumForShowOneMonster(0,terrainID,monsterType,MonsterID)
						Log("curNum = " .. MonsterList[curMonsterIndex].curNum .." deNum = " .. deNum);
						MonsterList[curMonsterIndex].curNum = MonsterList[curMonsterIndex].curNum - deNum;						
					end

					if MonsterList[curMonsterIndex].curNum < 0 then MonsterList[curMonsterIndex].curNum = 0; end
					
					
					--设置生物的值到mod
					local terrainID = self.TerrainList[curTerrainIndex].terrainID;
					local MonsterID = MonsterList[curMonsterIndex].MonsterID;
					local def = DefMgr:getBiomeDef(terrainID);
					ModMgr:SetBiomeMonsterValByID(MonsterID, MonsterList[curMonsterIndex].curNum, def);
					self:UpdateMonsterNumPreview();
				--}}
				end,

				--刷新生物数量预览
				UpdateMonsterNumPreview = function(self)
					Log("UpdateMonsterNumPreview:");
					--设置生物的值到mod
					local curTerrainIndex = self.curTerrainIndex;
					local curClassIndex = self.TerrainList[curTerrainIndex].curClassIndex;
					local terrainID = self.TerrainList[curTerrainIndex].terrainID;
					local typeID = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].typeID;
					local curNum = self.TerrainList[curTerrainIndex].MonsterClass[curClassIndex].curNum;
					local terrainmonsterview = getglobal("TerrainEditFrameBodyPage3CenterPreViewTerrainMonsterPreview");
					terrainmonsterview:setBiomeMonster(terrainID, typeID);
					Log("typeID = " .. typeID);
				end,
			},
		},--end:Tab3

		--4. 矿物生成
		{
			nameID = 9101,	--矿物生成
			ItemBoxUI = "TerrainFrameMineralBox",
			curItemIndex = 0,
			ItemList = {},
			--[[
			ItemList = {
				{
					mineralID = 400, 
					minHeight = 0, 
					maxHeight = 20,
					SeniorParam = {
						--矿物高级属性
						nReplaceBlockID = 0,			--1. 替换方块
						bSwitchIsOpen = false,			--2. 出行方式(无用)
						--3. 部分方式(待定)
						nProbability = 50,				--4. 出现概率(无用)
						TryGenCount = 5,	            --5. 最大矿石数量
						nVeinNum = 5,					--6. 矿脉生成数量
					},
				},
				{...},
			},
			]]

			Init = function(self)
			--{{
				Log("Init:");
				self:InitItemList();
				self:LoadItemList();
				self:UpdateItemList();

			--}}
			end,

			InitItemList = function(self)
			--{{
				Log("InitItemList:");
				self.curItemIndex = 0;
				self.ItemList = nil;
				self.ItemList = {};
			--}}
			end,

			--加载CSV中的原始数据: 相当于恢复默认.
			LoadItemList = function(self)
			--{{
				Log("LoadItemList:");
				self.ItemList = nil;
				self.ItemList = {};
				local ItemList = self.ItemList;
				local nIndex = 1;
				local t = g_TerrainParameter_MineralConfig.MineralList;

				for i = 1, #t do
					local blockID = t[i].mineralID;
					local def = DefMgr:getOriginalOreDefById(blockID);	--获取默认值
					
					if def then
						ItemList[nIndex] = nil;
						ItemList[nIndex] = {};
						ItemList[nIndex].SeniorParam = nil;
						ItemList[nIndex].SeniorParam = {};

						ItemList[nIndex].mineralID = blockID;
						ItemList[nIndex].minHeight = def.MinHeight or 1;
						ItemList[nIndex].maxHeight = def.MaxHeight or 1;
						ItemList[nIndex].SeniorParam.nReplaceBlockID = def.ReplaceBlock or 0;
						ItemList[nIndex].SeniorParam.TryGenCount = def.TryGenCount or 1;
						ItemList[nIndex].SeniorParam.nVeinNum = def.MaxVeinBlocks or 1;
						nIndex = nIndex + 1;
					end
				end

				--刷新UI
				--self:UpdateItemList();
			--}}
			end,

			UpdateItemList = function(self)
			--{{
				Log("UpdateItemList:");
				local y = 0;
				local planeUI = self.ItemBoxUI .. "Plane";
				local plane = getglobal(planeUI);

				for i = 1, 99 do
					local itemUI = self.ItemBoxUI .. "Item" .. i;
					if not HasUIFrame(itemUI) then
						break;
					end

					item = getglobal(itemUI);
					getglobal(itemUI .. "SelBtn"):Disable(false);	--使不能点击

					if i <= #self.ItemList then
						item:Show();
						item:SetPoint("top", planeUI, "top", 0, y);
						y = y + 133;

						self:UpdateSignalItem(i);
					else
						item:Hide();
					end
				end

				local AddNewBtn = getglobal(self.ItemBoxUI .. "AddNewBtn");
				AddNewBtn:SetPoint("top", planeUI, "top", 0, y);
				AddNewBtn:SetClientID(#self.ItemList + 1);
				y = y + 127;

				local boxH = getglobal(self.ItemBoxUI):GetHeight();
				local planeW = plane:GetWidth();
				if y < boxH then y = boxH; end
				plane:SetSize(planeW, y);
			--}}
			end,

			UpdateSignalItem = function(self, ItemIndex)
			--{{
				Log("UpdateItemList:");
				local itemUI = self.ItemBoxUI .. "Item" .. ItemIndex;
				local ItemData = self.ItemList[ItemIndex];

				if ItemData and ItemIndex then
					--1. 方块选择按钮
					local mineralID = ItemData.mineralID;
					local def = DXBJGetBlockByID(mineralID);
					local btn = getglobal(itemUI .. "SelBtn");
					DXBJUpdateBlockSlot(btn, def);

					--2. 滑动条
					local bar = getglobal(itemUI .. "HeightBar");
					bar:SetValue1(ItemData.minHeight);
					bar:SetValue2(ItemData.maxHeight);
				end
			--}}
			end,

			--方块选择
			ItemSelBtn_OnClick = function(self, index)
			---{{
				Log("ItemSelBtn_OnClick: index = " .. index);
				if index then
					if index > #(self.ItemList) then
						--添加, mineralID=0用来表示增加, 但没有点击确定, 因此在关掉选择器的时候, 需要去掉=0的条目.
						Log("AddItem:");
						--[[
						--插入操作不能放在这里, 因为有可能打开了选择器, 但是没有点击确定, 而是关闭了.
						table.insert(self.ItemList, {
								mineralID = 0, 
								minHeight = 10, 
								maxHeight = 80,
								SeniorParam = {nReplaceBlockID = 0, bSwitchIsOpen = false, nProbability = 50, TryGenCount = 5, nVeinNum = 5,},
							}
						);
						]]
					else
						--修改
						Log("ModefyItem:");
					end

					self.curItemIndex = index or 1;
				end
			---}}
			end,

			SetItemSelBtn = function(self, blockdef)
			---{{
				Log("SetItemSelBtn:");
				if blockdef then
					local curItemIndex = self.curItemIndex;
					if curItemIndex > #(self.ItemList) then
						--添加: 插入一条Item.
						local bCanAdd = true;
						for i = 1, #self.ItemList do
							if self.ItemList[i].mineralID == blockdef.ID then
								--已经存在, 不能重复插入
								bCanAdd = false;
								ShowGameTips(GetS(10508), 3);
								break;
							end
						end

						if bCanAdd then
							ShowGameTips(GetS(4079), 3);
							table.insert(self.ItemList, {
									mineralID = 0, 
									minHeight = 10, 
									maxHeight = 80,
									SeniorParam = {nReplaceBlockID = 0, bSwitchIsOpen = false, nProbability = 50, TryGenCount = 5, nVeinNum = 5,},
								}
							);

							self.ItemList[curItemIndex].mineralID = blockdef.ID;
						end
					end

					self:UpdateItemList()
				end
			---}}
			end,

			--滑动条值设置
			SetSliderVal = function(self, index, Val_1, Val_2)
			--{{
				self.ItemList[index].minHeight = Val_1;
				self.ItemList[index].maxHeight = Val_2;
			--}}
			end,
		},--end:Tab4

		Update = function(self)
		---{{
			Log("Update(): curTabIndex = " .. self.curTabIndex );
			for i = 1, #self do
				local itemUI = self.leftFrameUI .. "Btn" .. i;
				local item = getglobal(itemUI);
				local name = getglobal(itemUI .. "Name");
				local checked = getglobal(itemUI .. "Checked");
				local childPage = getglobal("TerrainEditFrameBodyPage" .. i);

				if self.bIsFirstShow then
					item:Show();
					item:SetPoint("top", self.leftFrameUI, "top", 0, 22 + 65 * (i - 1));
					name:SetText(GetS(self[i].nameID));
				end

				if i == self.curTabIndex then
					checked:Show();
					name:SetTextColor(255, 153, 63);
					childPage:Show();
				else
					checked:Hide();
					name:SetTextColor(158, 225, 231);
					childPage:Hide();
				end
			end

			self.bIsFirstShow = false;
		---}}
		end,

		TabBtn_OnClick = function(self, id)
		---[[
			Log("TabBtn_OnClick:");
			self.curTabIndex = id or 1;
			self:Update();
		---]]
		end,
	},--Tab:end
};


--创建地图页面调用
function TerrainParamFrameEditBtn_OnClick()
	Log("TerrainParamFrameEditBtn_OnClick:");

	OpenTerrainEditFrame();
end

--主界面关闭按钮
function TerrainEditFrameTopCloseBtn_OnClick()	
	ModMgr:resetAllocatedIdBase();
	getglobal("TerrainEditFrame"):Hide();
	ModEditorMgr:onleaveEditCurrentMod();	
end

function TerrainEditFrame_OnShow()
	Log("TerrainEditFrame_OnShow:");
	getglobal("WorldRuleBox"):setDealMsg(false);
end

function TerrainEditFrame_OnHide()
	getglobal("WorldRuleBox"):setDealMsg(true);
end

function TerrainEditFrame_OnLoad()
	Log("TerrainEditFrame_OnLoad:");

	--关闭按钮/标题栏
	UITemplateBaseFuncMgr:registerFunc("TerrainEditFrameCloseBtn", TerrainEditFrameTopCloseBtn_OnClick, "地形编辑器关闭按钮");
	getglobal("TerrainEditFrameTitleName"):SetText(GetS(9097));

	--LZLDO 拟解决Title与子页面的层级问题
	getglobal("TerrainEditFrameTitle"):SetFrameLevel(2253)
	getglobal("TerrainEditFrameCloseBtn"):SetFrameLevel(2254)
	getglobal("TerrainEditFrameHelpBtn"):SetFrameLevel(2254)
end

local g_bIsTerrainEditFrameFirstShow = true;
function OpenTerrainEditFrame()
	Log("OpenTerrainEditFrame:");
	ModEditorMgr:resetCurrentEditMod()

	getglobal("TerrainEditFrame"):Show();
	getglobal("TerrainEditFrame"):SetFrameLevel(2253)

	--MiniBase 设置层级在CreateWorldRuleFrame上面
	if MiniBaseManager:isMiniBaseGame() then
		local worldRuleLevel = getglobal("CreateWorldRuleFrame"):GetFrameLevel()
		getglobal("TerrainEditFrame"):SetFrameLevel(worldRuleLevel + 10)
	end
	
	--加载自定义方块
	TerrainParameterBlocks:LoadCustomBlock();

	--初始化数据, 只进行一次.
	if g_bIsTerrainEditFrameFirstShow then
		--g_bIsTerrainEditFrameFirstShow = false;
		--1. 地形生成初始化
		m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:Init();
		--2. 地表生成初始化
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:Init();
		--4. 矿物生成初始化
		m_TerrainEdit_TerrainSetParam.Tab[4]:Init();
	end

	--3. 生物每次都初始化, 要加载自定义生物.
	m_TerrainEdit_TerrainSetParam.Tab[3].Class:Init();

	--全部恢复默认(每次打开界面重置)
	-- Log("ReSetAllSet:");
	-- m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:LoadSet();
	-- m_TerrainEdit_TerrainSetParam.Tab[2].Class:LoadItemList();
	-- m_TerrainEdit_TerrainSetParam.Tab[3].Class:ReSetMonsterNum();
	-- m_TerrainEdit_TerrainSetParam.Tab[4]:LoadItemList();
	 TerrainEditFrameBottomSave();

	TerrainEditLeftBtnTemplate_OnClick(1);			--左侧导航按钮初始为第一个
	TerrainEditMainBtnTemplate_OnClick(1);			--主地形按钮初始位第一个
end

function TerrainEditLeftBtnTemplate_OnClick(id)
	Log("TerrainEditLeftBtnTemplate_OnClick:");

	if id then
		id = id;
	else
		id = this:GetClientID();
	end

	m_TerrainEdit_TerrainSetParam.Tab:TabBtn_OnClick(id);
end

local curBiomeId --当前选中的biome
local curBiomeParentId --当前选中的父地形
local CurrentEditDef,CurEditorIsCopied
local isChanged = false
--恢复默认设置
function TerrainEditFrameBottomResetBtn_OnClick()
	print("----TerrainEditFrameBottomResetBtn_OnClick-------")
	--local biomeDef = DefMgr:getBiomeDefById(curBiomeId)
	
	local curTabIndex = m_TerrainEdit_TerrainSetParam.Tab.curTabIndex;

	if 1 == curTabIndex then
		--地貌生成.
		--刷新UI
		m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:LoadSet();
		m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:Update();
	elseif 2 == curTabIndex then
		--地表生成.
		--刷新UI
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:LoadItemList();
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:UpdateItemList();
	elseif 3 == curTabIndex then
		m_TerrainEdit_TerrainSetParam.Tab[3].Class:ReSetMonsterNum();
	elseif 4 == curTabIndex then
		--矿物生成
		--刷新UI
		m_TerrainEdit_TerrainSetParam.Tab[4]:LoadItemList();
		m_TerrainEdit_TerrainSetParam.Tab[4]:UpdateItemList();
	end
    
	local terrainpreview = getglobal("TerrainEditFrameBodyPage1CenteFrameTerrainPrewView");
	local worldType = CurNewWorldType;
	if CurNewWorldType == -1 then
		worldType = 0
	end 
	local MainTerrain = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain;
	local curMainTerrainIndex = MainTerrain.curMainTerrainIndex;
	local ChildTerrain = MainTerrain[curMainTerrainIndex].ChildTerrain;
	local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;
	local curSelSubTerrainId = ChildTerrain[curChildTerrainIndex].ChildTerrainID;
	terrainpreview:setTempWorld(worldType,CurNewWorldTerrType,curSelSubTerrainId);
	
	ShowGameTips(GetS(10509), 3);
end
 
function NewTerrainEditorBiomeSave(editDef,t,isCopy)
	--print("-------------- TerrainEditorSave-------", CurrentEditDef, CurEditorIsCopied)
	CurrentEditDef = def
	CurEditorIsCopied = isCopy
	local t_info = {mod_desc={}, property={}, foreign_ids={}};
		
	
	t_info.property["id"] = editDef.ID;
	--if CurEditorIsCopied or editDef.CopyID > 0 then
	t_info.property["copyid"] = editDef.copyId;
	--end
    -- 插件描述信息
    if string.len(editDef.ModDescInfo.version) == 0 then
        t_info.mod_desc["version"] = ModMgr:getCurUserModVersion()
    else
        t_info.mod_desc["version"] = editDef.ModDescInfo.version
    end
    if string.len(editDef.ModDescInfo.author) == 0 then
        t_info.mod_desc["author"] = AccountManager:getUin()
    else
        t_info.mod_desc["author"] = editDef.ModDescInfo.author
    end
    if string.len(editDef.ModDescInfo.uuid) == 0 then
		if ModEditorMgr:getCurrentEditModDesc() then
			t_info.mod_desc["uuid"] = ModEditorMgr:getCurrentEditModDesc().uuid
		else
			t_info.mod_desc["uuid"] = ""
		end
    else
        t_info.mod_desc["uuid"] = editDef.ModDescInfo.uuid
    end
    if string.len(editDef.ModDescInfo.filename) == 0 then
       t_info.mod_desc["filename"] = editDef.ModDescInfo.filename
    end

	t_info.property["parentId"] = tonumber(editDef.parentId);
	t_info.property["minHeight"] = tonumber(editDef.MinHeight);
	t_info.property["maxHeight"] = tonumber(editDef.MaxHeight);
	t_info.property["topBlockId"] = tonumber(editDef.TopBlock)
	t_info.property["fillBlockId"] = tonumber(editDef.FillBlock);
	t_info.property["fillDepth"] = tonumber(editDef.FillDepth);
	t_info.property["geneRate"] = tonumber(editDef.geneRate);
	---Log("editDef.copyId = " .. editDef.copyId .. ", editDef.TopBlock = " .. editDef.TopBlock .. ", editDef.FillBlock = " .. editDef.FillBlock);

	--植物
	---Log("NewTerrainEditorBiomeSave: Plant:");
	t_info.property["ChunkPumpkin"] = editDef.ChunkPumpkin;
	t_info.property["ChunkWatermelon"] = editDef.ChunkWatermelon ;
	t_info.property["ChunkDeadBush"] = editDef.ChunkDeadBush;
	t_info.property["ChunkReeds"] = editDef.ChunkReeds;
	t_info.property["ChunkCactus"] = editDef.ChunkCactus;
	t_info.property["ChunkMushroom"] = editDef.ChunkMushroom;
	t_info.property["ChunkWaterlily"] = editDef.ChunkWaterlily;
	t_info.property["ChunkDuckweed"] = editDef.ChunkDuckweed;
	--t_info.property["ChunkGrass"] = editDef.ChunkGrass;
	-- t_info.property["ChunkGrassNum"] = editDef.ChunkGrassNum;
	-- t_info.property["ChunkFlowers"] = editDef.ChunkFlowers;
	-- t_info.property["ChunkFlowerNum"] = editDef.ChunkFlowerNum;
	-- t_info.property["ChunkCorals"] = editDef.ChunkCorals;
	-- t_info.property["ChunkCoralNum"] = editDef.ChunkCoralNum;
	---t_info.property["ChunkSeaPlants"] = editDef.ChunkSeaPlants;
	--t_info.property["ChunkSeaPlantNum"] = editDef.ChunkSeaPlantNum;
	t_info.property["ChunkGrass"] = {}
	t_info.property["ChunkGrassNum"] = {}
	t_info.property["ChunkFlowers"] = {}
	t_info.property["ChunkFlowerNum"] = {}
	t_info.property["ChunkCorals"] = {}
	t_info.property["ChunkCoralNum"] = {}
	t_info.property["ChunkSeaPlants"] = {}
	t_info.property["ChunkSeaPlantNum"] = {}
	t_info.property["ChunkNewCorals"] = {}
	t_info.property["ChunkNewCoralNum"] = {}
	t_info.property["ChunkJaggedFern"] = {}
	t_info.property["ChunkJaggedFernNum"] = {}
	for i = 1,4 do
	  local index = i -1; 
	  local id = DefMgr:getBiomeDefId(2, editDef.ID,index)
      local count = DefMgr:getBiomeDefNum(2, editDef.ID,index)
      t_info.property["ChunkGrass"][i] = id
      t_info.property["ChunkGrassNum"][i] = count
      ---Log("biomedef save monster --------------------"..id..count);
    end 

    for i = 1,4 do
	  local index = i -1; 
	  local id = DefMgr:getBiomeDefId(3, editDef.ID,index)
      local count = DefMgr:getBiomeDefNum(3, editDef.ID,index)
      t_info.property["ChunkFlowers"][i] = id
      t_info.property["ChunkFlowerNum"][i] = count
     --- Log("biomedef save ChunkFlowers --------------------"..editDef.ID.. "," ..id..","..count);
    end 

    for i = 1,8 do
	  local index = i -1; 
	  local id = DefMgr:getBiomeDefId(4, editDef.ID,index)
      local count = DefMgr:getBiomeDefNum(4, editDef.ID,index)
      t_info.property["ChunkCorals"][i] = id
      t_info.property["ChunkCoralNum"][i] = count
     --Log("biomedef save ChunkCorals --------------------"..id .. ", " ..count);
    end 

    for i = 1,4 do
	  local index = i -1; 
	  local id = DefMgr:getBiomeDefId(5, editDef.ID,index)
      local count = DefMgr:getBiomeDefNum(5, editDef.ID,index)
      t_info.property["ChunkSeaPlants"][i] = id
      t_info.property["ChunkSeaPlantNum"][i] = count
      --Log("biomedef save monster --------------------"..id..count);
    end 

	for i = 1,8 do
		local index = i -1; 
		local id = DefMgr:getBiomeDefId(7, editDef.ID,index)
		local count = DefMgr:getBiomeDefNum(7, editDef.ID,index)
		t_info.property["ChunkNewCorals"][i] = id
		t_info.property["ChunkNewCoralNum"][i] = count
	   --Log("biomedef save ChunkCorals --------------------"..id .. ", " ..count);
	  end 
	for i = 1,1 do
		local index = i -1; 
		local id = DefMgr:getBiomeDefId(8, editDef.ID,index)
		local count = DefMgr:getBiomeDefNum(8, editDef.ID,index)
		t_info.property["ChunkJaggedFern"][i] = id
		t_info.property["ChunkJaggedFernNum"][i] = count
	   --Log("biomedef save ChunkCorals --------------------"..id .. ", " ..count);
	  end 
	t_info.property["ChunkTreex"] = {}
	t_info.property["ChunkTreeNum"] = {}
	
	
    for i = 1,10 do
    	local index = i -1; 
    	local id = DefMgr:getBiomeDefId(6, editDef.ID,index)
        local count = DefMgr:getBiomeDefNum(6, editDef.ID,index)
        t_info.property["ChunkTreex"][i] = id
        t_info.property["ChunkTreeNum"][i] = count
        --Log("biomedef save monster --------------------"..id..count);
    end 

	--Log("elliott biome dataStr1");	
	t_info.property["biomeMonster"] = {}
	t_info.property["biomeMonsterNum"] = {}
	
	
    for i = 1,48 do
    	  local index = i -1; 
    	  local id = DefMgr:getBiomeDefId(1, editDef.ID,index)
          local count = DefMgr:getBiomeDefNum(1, editDef.ID,index)
          t_info.property["biomeMonster"][i] = id
          t_info.property["biomeMonsterNum"][i] = count
          --Log("biomedef save monster --------------------"..id..count);
    end 	
	
	Log("t_info:XXXX");

	local dataStr = JSON:encode(t_info);
	---Log("elliott biome dataStr:"..dataStr);
	return dataStr;
end

--矿物保存
function NewTerrainEditorOreSave(editDef)
	CurrentEditDef = def
	CurEditorIsCopied = isCopy
	local t_info = {property={}};

	t_info.property["id"] = editDef.ID;	
	t_info.property["copyid"] = editDef.copyId;

	t_info.property["MinHeight"] = editDef.MinHeight;
	t_info.property["MaxHeight"] = editDef.MaxHeight;
	t_info.property["TryGenCount"] = editDef.TryGenCount;
	t_info.property["MaxVeinBlocks"] = editDef.MaxVeinBlocks;
	t_info.property["ReplaceBlock"] = editDef.ReplaceBlock;

	local dataStr = JSON:encode(t_info);
	--Log("elliott ore dataStr:"..dataStr);
	return dataStr;
end 

--保存
function TerrainEditFrameBottomSave(curTabIndex)
	print("----TerrainEditFrameBottomSave-------");

	-- if curTabIndex then
	-- 	curTabIndex = curTabIndex;
	-- else
	-- 	curTabIndex = m_TerrainEdit_TerrainSetParam.Tab.curTabIndex;
	-- end
	-- Log("curTabIndex = " .. curTabIndex);

	--把前三个标签页的数据全部汇总到这里, 然后统一保存.
	local m_biomeDef = nil;
	local m_biomeDef = {};

    ModEditorMgr:clearBiomeDef()
    
	if true then
		--1. 地貌生成.
		local MainTerrain = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain;

		for i = 1, #MainTerrain do
			local MainTerrainID = MainTerrain[i].MainTerrainID;
			local ChildTerrain = MainTerrain[i].ChildTerrain;

			for j = 1, #ChildTerrain do
				local ChildTerrainID = ChildTerrain[j].ChildTerrainID;
				local Set = ChildTerrain[j].Set;

				local parentId = MainTerrainID or 0;
				local copyId = ChildTerrainID or 0;
				local minHeight = (Set.Height.Min - 32) * 3.8 / 64 - 1.9;							--Set.Height.Min or 1;
				local maxHeight = (Set.Height.Max - Set.Height.Min - 16) / 16;						--Set.Height.Max or 5;
				if maxHeight > 2 then maxHeight = 2; end 											--最大值为2
				minHeight = string.format("%.1f", minHeight);
				maxHeight = string.format("%.1f", maxHeight);
				Log("pushValue: Set.Height.Min = " .. Set.Height.Min .. ", Set.Height.Max = " .. Set.Height.Max);
				Log("saveValue: minHeight = " .. minHeight .. ", maxHeight = " .. maxHeight);
				local topBlockId = Set.SurfaceBlock.blockID or 165;
				local fillBlockId = Set.FillBlock.blockID or 165;
				local fillDepth = Set.FillHeight.Val or 2;
				local geneRate = Set.Probability.Val or 100;

				local def =  ModEditorMgr:retriveTempBiomeDef(parentId, copyId)
				if def ~= nil then
					def.MinHeight = minHeight
					def.MaxHeight = maxHeight	
					def.FillBlock = fillBlockId
					def.FillDepth = fillDepth
					def.TopBlock = topBlockId
					def.geneRate = geneRate
					--local t_1_info = {};
					--local dataStr = NewTerrainEditorBiomeSave(def, t_1_info, true);
					--Log(" ----TerrainEditorSave----"..dataStr)
					--local name = "biomes_"..def.copyId;
					--ModEditorMgr:requestCreateBiome(dataStr, name)

					--{{
					if nil == m_biomeDef[def.copyId] then
						Log("1.copyId = " .. def.copyId);
						m_biomeDef[def.copyId] = {};
						m_biomeDef[def.copyId].ID = def.ID;
						m_biomeDef[def.copyId].copyId = def.copyId;
						m_biomeDef[def.copyId].parentId = def.parentId;
						m_biomeDef[def.copyId].ModDescInfo = def.ModDescInfo;
						m_biomeDef[def.copyId].MinHeight = def.MinHeight;
						m_biomeDef[def.copyId].MaxHeight = def.MaxHeight;
						m_biomeDef[def.copyId].TopBlock = def.TopBlock;
						m_biomeDef[def.copyId].FillBlock = def.FillBlock;
						m_biomeDef[def.copyId].FillDepth = def.FillDepth;
						m_biomeDef[def.copyId].geneRate = def.geneRate;
						m_biomeDef[def.copyId].ChunkPumpkin = def.ChunkPumpkin;
						m_biomeDef[def.copyId].ChunkWatermelon = def.ChunkWatermelon;
						m_biomeDef[def.copyId].ChunkDeadBush = def.ChunkDeadBush;
						m_biomeDef[def.copyId].ChunkReeds = def.ChunkReeds;
						m_biomeDef[def.copyId].ChunkCactus = def.ChunkCactus;
						m_biomeDef[def.copyId].ChunkMushroom = def.ChunkMushroom;
						m_biomeDef[def.copyId].ChunkWaterlily = def.ChunkWaterlily;
						m_biomeDef[def.copyId].ChunkDuckweed = def.ChunkDuckweed;
					end
					m_biomeDef[def.copyId].MinHeight = minHeight;
					m_biomeDef[def.copyId].MaxHeight = maxHeight;	
					m_biomeDef[def.copyId].FillBlock = fillBlockId;
					m_biomeDef[def.copyId].FillDepth = fillDepth;
					m_biomeDef[def.copyId].TopBlock = topBlockId;
					m_biomeDef[def.copyId].geneRate = geneRate;
					--}}
				end 
			end
		end
	end

	if true then
		--2. 地表生成.

		--{{植物
		local TerrainList = m_TerrainEdit_TerrainSetParam.Tab[2].Class.TerrainList;
		for i = 1, #TerrainList do
			local ItemClass = TerrainList[i].ItemClass;
			local terrainID = TerrainList[i].terrainID;
			local parentId = TerraiEdit_GetParentByChildTerrainId(terrainID);

			local def =   ModEditorMgr:retriveTempBiomeDef(parentId, terrainID);
			if def ~= nil then
				--{{
				if nil == m_biomeDef[def.copyId] then
					Log("2.copyId = " .. def.copyId);
					m_biomeDef[def.copyId] = {};
					m_biomeDef[def.copyId].ID = def.ID;
					m_biomeDef[def.copyId].copyId = def.copyId;
					m_biomeDef[def.copyId].parentId = def.parentId;
					m_biomeDef[def.copyId].ModDescInfo = def.ModDescInfo;
					m_biomeDef[def.copyId].MinHeight = def.MinHeight;
					m_biomeDef[def.copyId].MaxHeight = def.MaxHeight;
					m_biomeDef[def.copyId].TopBlock = def.TopBlock;
					m_biomeDef[def.copyId].FillBlock = def.FillBlock;
					m_biomeDef[def.copyId].FillDepth = def.FillDepth;
					m_biomeDef[def.copyId].geneRate = def.geneRate;
					m_biomeDef[def.copyId].ChunkPumpkin = def.ChunkPumpkin;
					m_biomeDef[def.copyId].ChunkWatermelon = def.ChunkWatermelon;
					m_biomeDef[def.copyId].ChunkDeadBush = def.ChunkDeadBush;
					m_biomeDef[def.copyId].ChunkReeds = def.ChunkReeds;
					m_biomeDef[def.copyId].ChunkCactus = def.ChunkCactus;
					m_biomeDef[def.copyId].ChunkMushroom = def.ChunkMushroom;
					m_biomeDef[def.copyId].ChunkWaterlily = def.ChunkWaterlily;
					m_biomeDef[def.copyId].ChunkDuckweed = def.ChunkDuckweed;
				end
				--}}

				for j = 1, #ItemClass do
					local ItemList = ItemClass[j].ItemList;

					for k = 1, #ItemList do
						--每一个植物条目
						local blockID = ItemList[k].blockID;
						local Name = ItemList[k].Name;
						local nDensityVal = ItemList[k].nDensityVal;
						Log("terrainID = " .. terrainID .. ", blockID = " .. blockID .. ", nDensityVal = " .. nDensityVal .. ", Name = " .. Name);

						if def[Name] then
							--单值
							def[Name] = nDensityVal;
							ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, Name);
							Log("1111: Name = " .. Name .. ", val = " .. def[Name]);

							--{{
							m_biomeDef[def.copyId][Name] = nDensityVal;
							--}}
						else
							--数组
							--Log("2222: Name = " .. Name);
							if string.find(Name, "ChunkGrass") then
								--Log("3333: ChunkGrass:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkGrass");
							elseif string.find(Name, "ChunkFlowers") then
								--Log("4444: ChunkFlowers:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkFlowers");

								
							elseif string.find(Name, "ChunkCorals") then
								--Log("5555: ChunkCorals:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkCorals");
							elseif string.find(Name, "ChunkSeaPlants") then
								--Log("5555: ChunkCorals:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkSeaPlants");
							elseif string.find(Name, "ChunkTreex") then
								Log("5555: ChunkTreex:");
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkTreex");
							elseif string.find(Name, "ChunkNewCorals") then
								--Log("5555: ChunkCorals:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkNewCorals");
							elseif string.find(Name, "ChunkJaggedFern") then
								--Log("5555: ChunkCorals:")
								ModMgr:SetBiomeChunkArrayValByIndex(blockID, nDensityVal, def, "ChunkJaggedFern");
							end
						end

						--local t_2_info = {};
						--local dataStr = NewTerrainEditorBiomeSave(def, t_2_info, true);
						--local name = "biomes_"..def.copyId;
						--ModEditorMgr:requestCreateBiome(dataStr, name);
					end
				end
			end
		end
		--}}
	end

	if true then
		--3. 生物生成
		local TerrainList = m_TerrainEdit_TerrainSetParam.Tab[3].Class.TerrainList;

		--地形
		for i = 1, #TerrainList do
			local MonsterClass = TerrainList[i].MonsterClass;
			local terrainID = TerrainList[i].terrainID;
			Log("生物生成terrainID"..terrainID)

			local def =   DefMgr:getBiomeDef(terrainID);  ----  ModEditorMgr:retriveTempBiomeDef(terrainID, terrainID)

			if def ~= nil then
				--{{
				if nil == m_biomeDef[def.copyId] then
					Log("3.copyId = " .. def.copyId);
					m_biomeDef[def.copyId] = {};
					m_biomeDef[def.copyId].ID = def.ID;
					m_biomeDef[def.copyId].copyId = def.copyId;
					m_biomeDef[def.copyId].parentId = def.parentId;
					m_biomeDef[def.copyId].ModDescInfo = def.ModDescInfo;
					m_biomeDef[def.copyId].MinHeight = def.MinHeight;
					m_biomeDef[def.copyId].MaxHeight = def.MaxHeight;
					m_biomeDef[def.copyId].TopBlock = def.TopBlock;
					m_biomeDef[def.copyId].FillBlock = def.FillBlock;
					m_biomeDef[def.copyId].FillDepth = def.FillDepth;
					m_biomeDef[def.copyId].geneRate = def.geneRate;
					m_biomeDef[def.copyId].ChunkPumpkin = def.ChunkPumpkin;
					m_biomeDef[def.copyId].ChunkWatermelon = def.ChunkWatermelon;
					m_biomeDef[def.copyId].ChunkDeadBush = def.ChunkDeadBush;
					m_biomeDef[def.copyId].ChunkReeds = def.ChunkReeds;
					m_biomeDef[def.copyId].ChunkCactus = def.ChunkCactus;
					m_biomeDef[def.copyId].ChunkMushroom = def.ChunkMushroom;
					m_biomeDef[def.copyId].ChunkWaterlily = def.ChunkWaterlily;
					m_biomeDef[def.copyId].ChunkDuckweed = def.ChunkDuckweed;
				end
				m_biomeDef[def.copyId].biomeMonster = {};
				m_biomeDef[def.copyId].biomeMonsterNum = {};
				--}}
				
		        local t_3_info = {biomeMonster={}, biomeMonsterNum={}};
				local  biomeMonster = {}
		    	local  biomeMonsterNum = {}
				for j = 1, #MonsterClass do
					local MonsterList = MonsterClass[j].MonsterList;

					--单个生物
					for k = 1, #MonsterList do
						local MonsterID = MonsterList[k].MonsterID;
						local curNum = MonsterList[k].curNum;
						Log("MonsterID = " .. MonsterID .. ", curNum = " .. curNum);
						t_3_info["biomeMonster"][k] = MonsterID;
						t_3_info["biomeMonsterNum"][k] = curNum;
						ModMgr:SetBiomeMonsterValByID(MonsterID, MonsterList[k].curNum, def);

						--{{
						m_biomeDef[def.copyId].biomeMonster[k] = MonsterID;
						m_biomeDef[def.copyId].biomeMonsterNum[k] = curNum;
						--}}
					end	
				end

				-- local dataStr = NewTerrainEditorBiomeSave(def, t_3_info, true);
				-- local name = "biomes_"..def.copyId;
				-- ModEditorMgr:requestCreateBiome(dataStr, name);
			end				
		end

		--汇总, 一次保存前三个标签页的json文件.
		if m_biomeDef then
			Log("m_biomeDef:");
			--for i = 1, #m_biomeDef do
			  for i = 0,MAX_BIOME_TYPE - 1 do
				if m_biomeDef[i] then
					local dataStr = NewTerrainEditorBiomeSave(m_biomeDef[i], {}, true);
					local name = "biomes_" .. m_biomeDef[i].copyId;
					print("biomeSave-"..m_biomeDef[i].copyId.."--"..m_biomeDef[i].ID.."---"..dataStr)
					ModEditorMgr:requestCreateBiome(dataStr, name);
				end
			end
		end
	end

	if true then
		--4. 矿物生成
		--每次保存矿物前先把矿物目录清空
		ModMgr:enableClearMapDefaultOreWorld();

		local ItemList = m_TerrainEdit_TerrainSetParam.Tab[4].ItemList;

		for i = 1, #ItemList do			
			local minHeight = ItemList[i].minHeight;
			local maxHeight = ItemList[i].maxHeight;
			local mineralID = ItemList[i].mineralID;
			local nReplaceBlockID = ItemList[i].SeniorParam.nReplaceBlockID;
			local TryGenCount = ItemList[i].SeniorParam.TryGenCount;
			local nVeinNum = ItemList[i].SeniorParam.nVeinNum;
			
			local def = ModEditorMgr:retriveTempOreDef(mineralID)
			if def ~= nil then
				def.MinHeight = minHeight;
				def.MaxHeight = maxHeight;
				def.TryGenCount = TryGenCount;
				def.MaxVeinBlocks = nVeinNum;
				def.ReplaceBlock = nReplaceBlockID;
				local dataStr = NewTerrainEditorOreSave(def)	
				local name = "ores_"..def.ID	
				ModEditorMgr:requestCreateOre(dataStr,name)	
			end 
		end
	end

	ModEditorMgr:requestSaveTempMapModSetting()
	
	--飘字:"保存成功"
	---ShowGameTips(GetS(3940), 3);

	if CurNewWorldType == 4 then 
		CreateWorldRuleSetIsModifyTerrain(true)
	else
		CreateWorldSetIsModifyTerrain(true)
	end 
end

--根据自地形id获取父地形id
function TerraiEdit_GetParentByChildTerrainId(_ChildTerrainID)
	local MainTerrain = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain;

	Log("_ChildTerrainID = " .. _ChildTerrainID);

	for i = 1, #MainTerrain do
		local MainTerrainID = MainTerrain[i].MainTerrainID;
		local ChildTerrain = MainTerrain[i].ChildTerrain;

		for j = 1, #ChildTerrain do
			local ChildTerrainID = ChildTerrain[j].ChildTerrainID;

			if _ChildTerrainID == ChildTerrainID then
				--找到了返回.
				Log("YYY: ID = " .. MainTerrainID);
				return MainTerrainID;
			end
		end
	end

	--没找到返回自己.
	Log("XXX: ID = " .. _ChildTerrainID);
	return _ChildTerrainID;
end

function TerrainEditFrameBottomSaveBtn_OnClick()
	print("----TerrainEditFrameBottomSaveBtn_OnClick-------")	
	
	--4个标签页全部保存.
	threadpool:work(function ()
		TerrainEditFrameBottomSave();
	end)
	--local terrainpreview = getglobal("TerrainEditFrameBodyPage1CenteFrameTerrainPrewView");
	--terrainpreview:clearTempWorld();	
	ModMgr:resetAllocatedIdBase();
	getglobal("TerrainEditFrame"):Hide();	
	ModEditorMgr:onleaveEditCurrentMod();
end

function TerrainEdit_ParseBiomePlant()

end

--刷新地形缩略图
function TerrainEdit_UpdateTerrainView()
	if not g_bIsTerrainEditFrameFirstShow then
		Log("TerrainEdit_UpdateTerrainView:");
		threadpool:work(function ()
			TerrainEditFrameBottomSave()
		end)
		local terrainpreview = getglobal("TerrainEditFrameBodyPage1CenteFrameTerrainPrewView");
		local worldType = CurNewWorldType;
		if CurNewWorldType == -1 then
			worldType = 0
		end 
		local MainTerrain = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain;
		local curMainTerrainIndex = MainTerrain.curMainTerrainIndex;
		local ChildTerrain = MainTerrain[curMainTerrainIndex].ChildTerrain;
		local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;
		local curSelSubTerrainId = ChildTerrain[curChildTerrainIndex].ChildTerrainID;
		terrainpreview:setTempWorld(worldType,CurNewWorldTerrType,curSelSubTerrainId);
	end
end
---------------------------------------左侧导航按钮:end----------------------------------------------------

----------------------------------------------childpage1: 地貌生成-----------------------------------------
--主地貌
function TerrainEditMainBtnTemplate_OnClick(id)
	local bIsUpdateView = false;

	if id then
		id = id;
	else
		id = this:GetClientID();
		bIsUpdateView = true;
	end

	Log("TerrainEditMainBtnTemplate_OnClick: id = " .. id);
	m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:MainBtn_OnClick(id, bIsUpdateView);
end

--子地貌
function TerrainEditChildTerrBtnTemplate_OnClick(id)
	local bIsUpdateView = false;

	if id then
		id = id;
	else
		id = this:GetClientID();
		bIsUpdateView = true;
	end

	Log("TerrainEditChildTerrBtnTemplate_OnClick: id = " .. id);
	m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:ChildBtn_OnClick(id, bIsUpdateView);
end

--数值调节
function TerrainEditNumSetBtnTemplateLeftBtn_OnClick(Type)
	--Type == 1: 减.
	Log("TerrainEditNumSetBtnTemplateLeftBtn_OnClick:");
	local parentUI = this:GetParent();
	local ret = true;

	if parentUI then
		if parentUI == "TerrainEditFrameBodyPage1RightFrameFillHeight" then
			--填充层厚度
			ret = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:BlockNumSet("FillHeight", Type);
		elseif parentUI == "TerrainEditFrameBodyPage1RightFrameProbability" then
			--生成概率
			ret = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:BlockNumSet("Probability", Type);
		else

		end

		--刷新地形预览
		if ret then
			TerrainEdit_UpdateTerrainView();
		end
	end
end

function TerrainEditBodyPage1_OnShow()
	Log("TerrainEditBodyPage1_OnShow:"..CurNewWorldType.." "..CurNewWorldTerrType);
	local terrainpreview = getglobal("TerrainEditFrameBodyPage1CenteFrameTerrainPrewView");	
	local worldType = CurNewWorldType;
	if CurNewWorldType == -1 then
		worldType = 0
	end 
	local MainTerrain = m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain;
    local curMainTerrainIndex = MainTerrain.curMainTerrainIndex;
	local ChildTerrain = MainTerrain[curMainTerrainIndex].ChildTerrain;
	local curChildTerrainIndex = ChildTerrain.curChildTerrainIndex;
	local curSelSubTerrainId = ChildTerrain[curChildTerrainIndex].ChildTerrainID;
	if CurNewWorldTerrType == nil then
		CurNewWorldTerrType = 1
	end 
	terrainpreview:setTempWorld(worldType,CurNewWorldTerrType,curSelSubTerrainId);		
	terrainpreview:setCenter(0, 30, 0);

	--始终放最后一行
	if g_bIsTerrainEditFrameFirstShow then
		g_bIsTerrainEditFrameFirstShow = false;
	end
end

function TerrainEditBodyPage1_OnHide()
	Log("TerrainEditBodyPage1_OnHide:");
	--local terrainpreview = getglobal("TerrainEditFrameBodyPage1CenteFrameTerrainPrewView");	
	--terrainpreview:clearTempWorld()
	Log("TerrainEditBodyPage1_OnHide:clear");
end 

function TerrainEditFrameBodyPage1CenteFrame_OnUpdate()
	--Log("TerrainEditFrameBodyPage1CenteFrame_OnUpdate:");	
	--ClientMgr:updateViewTerrain();	
end 

--双滑动条: 高度调节
function TerrainSet_HeightBar_OnValueChanged()
	Log("TerrainSet_HeightBar_OnValueChanged:");
	local barUI = "TerrainEditFrameBodyPage1RightFrameHeightHeightBar";
	local bar = getglobal(barUI);
	local minValue = bar:GetMinValue();
	local maxValue = bar:GetMaxValue();
	local sumLen = maxValue - minValue;

	local value1 = math.floor(bar:GetValue1());
	local value2 = math.floor(bar:GetValue2());
	local ratio1 = (value1 - minValue) / sumLen;
	local ratio2 = (value2 - minValue) / sumLen;
	local width1   = math.floor(232 * ratio1);
	local width2   = math.floor(232 * ratio2);
	Log("V1 = " .. value1 .. ", V2 = " .. value2);

	getglobal(barUI .. "Bkg1"):ChangeTexUVWidth(width1)
	getglobal(barUI .. "Bkg1"):SetWidth(width1);
	getglobal(barUI .. "Bkg2"):ChangeTexUVWidth(width2)
	getglobal(barUI .. "Bkg2"):SetWidth(width2);

	local text = GetS(9104) .. "：" .. value1 .. GetS(9111);
	getglobal("TerrainEditFrameBodyPage1RightFrameHeightMinHeightTitle"):SetText(text);
	local text = GetS(9105) .. "：" .. value2 - 16 .. GetS(9111);
	getglobal("TerrainEditFrameBodyPage1RightFrameHeightMaxHeightTitle"):SetText(text);
	m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:HeightSliderSet(value1, value2);

	--刷新地形预览
	--TerrainEdit_UpdateTerrainView();
end

function TerrainSet_HeightBar_OnMouseUp()
	Log("TerrainSet_HeightBar_OnMouseUp:");
	--刷新地形预览
	TerrainEdit_UpdateTerrainView();
end

-----------------------------------------------childpage1:end----------------------------------------------


-----------------------------------------------childpage2:地表生成: begin----------------------------------
function TerrainEditFrameChildPage2_OnShow()
	Log("TerrainEditFrameChildPage2_OnShow:");
	TerrainEditTerrainBtnTemplate_OnClick(1);
end

--"类别"按钮点击: 地表生成, 和生物生成都会用.
function TerrainSurfaceClassBtnTemplate_OnClick(id)
	Log("TerrainSurfaceClassBtnTemplate_OnClick:");

	if id then id = id else id = this:GetClientID(); end

	local curTabIndex = m_TerrainEdit_TerrainSetParam.Tab.curTabIndex;

	m_TerrainEdit_TerrainSetParam.Tab[curTabIndex].Class:ClassBtn_OnClick(id);
end

--"地形"按钮: 地表生成, 和生物生成都会用.
function TerrainEditTerrainBtnTemplate_OnClick(id)
	Log("TerrainEditTerrainBtnTemplate_OnClick:");

	if id then id = id; else id = this:GetClientID(); end

	local curTabIndex = m_TerrainEdit_TerrainSetParam.Tab.curTabIndex;

	m_TerrainEdit_TerrainSetParam.Tab[curTabIndex].Class:TerrainBtn_OnClick(id);
end

--新增
function TerrainFrameSurfaceItemBoxAddNewBtn_OnClick()
	local id = this:GetClientID();
	TerrainEditSelBtnAddItem("SurfaceItem", id);
end

--删除
function TerrainPlantItemTemplateDelBtn_OnClick()
	Log("TerrainPlantItemTemplateDelBtn_OnClick:");

	local btnName = this:GetName();
	local index = this:GetParentFrame():GetClientID();
	local curTabIndex = m_TerrainEdit_TerrainSetParam.Tab.curTabIndex;
	Log("index = " .. index);

	if curTabIndex == 2 then
		--地表生成: 植物选择
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:DeleteItem(index);
	else
		
	end
end
-----------------------------------------------childpage2:end----------------------------------------------

-----------------------------------------------childpage3:生物生成: begin----------------------------------
function TerrainEditFrameChildPage3_OnShow()
	Log("TerrainEditFrameChildPage3_OnShow:");
	--初始化地形到第一个.
	m_TerrainEdit_TerrainSetParam.Tab[3].Class:TerrainBtn_OnClick(1);
	local TerrainList = m_TerrainEdit_TerrainSetParam.Tab[3].Class.TerrainList;
	local curTerrainIndex = m_TerrainEdit_TerrainSetParam.Tab[3].Class.curTerrainIndex;
	local terrainID = TerrainList[curTerrainIndex].terrainID;
	Log("TerrainEditFrameChildPage3_OnShow:1");
	
	---local terrainmonsterview1 = getglobal("TerrainMonsterPreview")
	local terrainmonsterview = getglobal("TerrainEditFrameBodyPage3CenterPreViewTerrainMonsterPreview")
	Log("TerrainEditFrameChildPage3_OnShow:2");
	terrainmonsterview:setBiomeMonster(terrainID,1) 
	Log("TerrainEditFrameChildPage3_OnShow:3");
end

function TerrainEditFrameChildPage3_OnHide()
	Log("TerrainEditFrameChildPage3_OnHide:");
	--初始化地形到第一个.
	m_TerrainEdit_TerrainSetParam.Tab[3].Class:TerrainBtn_OnClick(1);
	----local terrainmonsterview = getglobal("TerrainEditFrameBodyPage3CenterPreViewTerrainMonsterPrewView")

end

--生物选择按钮
function TerrainEditMonsterBtnTemplate_OnClick(id)
	Log("TerrainEditMonsterBtnTemplate_OnClick:");

	if id then id = id; else id = this:GetClientID(); end

	m_TerrainEdit_TerrainSetParam.Tab[3].Class:MonsterBtn_OnClick(id);
end

--数量增/减
function TerrainEdit_MonsterSetNumAddBtn(nType)
	--nType == 1: 增加.
	m_TerrainEdit_TerrainSetParam.Tab[3].Class:SetMonsterNum(nType);
end

--通过ID获取生物定义
function TerrainEditMonster_GetMonsterDefByID(id)
	local monsterDef = ModEditorMgr:getMonsterDefById(id);
	if not monsterDef then
		monsterDef = MonsterCsv:get(id);
	end

	return monsterDef;
end
-----------------------------------------------childpage3:生物生成: end----------------------------------


-----------------------------------------------childpage4:矿物生成: begin----------------------------------
function TerrainEditFrameChildPage4_OnShow()
	
end


--新增
function TerrainFrameMineralBoxAddNewBtn_OnClick()
	local id = this:GetClientID();
	TerrainEditSelBtnAddItem("MineralBox", id);
end

--高级设置
function TerrainEditMineralItemTemplateSetBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();

	SetMineralSeniorSetFrame(index);
end
-----------------------------------------------childpage4:矿物生成: end----------------------------------


-----------------------------------------------矿物高级属性: begin---------------------------------------
local m_MineralSeniorParam = {
	curMineralItemIndex = 0,		--当前条目
	nReplaceBlockID = 0,			--1. 替换方块
	bSwitchIsOpen = false,			--2. 出行方式开关
	SliderList = {
		{max = 50, min = 1, step = 1, curVal = 5, nameID = 9144, UI = "MineralSeniorSetFrameBodyMaxNum"},			--矿脉矿石数量:nVeinNum
		{max = 25, min = 1, step = 1, curVal = 5, nameID = 9145, UI = "MineralSeniorSetFrameBodyVeinNum"},			--矿脉生成密度:TryGenCount
	},

	Init = function(self, nItemIndex)
	--{{
		Log("Init:");
		self.curMineralItemIndex = nItemIndex;
		self:Load();
		self:InitSlider();
	--}}
	end,

	Load = function(self)
	--{{
		Log("Load:");
		if self.curMineralItemIndex > 0 then
			local SeniorParam = m_TerrainEdit_TerrainSetParam.Tab[4].ItemList[self.curMineralItemIndex].SeniorParam;
			self.nReplaceBlockID = SeniorParam.nReplaceBlockID;
			self.SliderList[1].curVal = SeniorParam.nVeinNum;
			self.SliderList[2].curVal = SeniorParam.TryGenCount;
		end
	--}}
	end,

	InitSlider = function(self)
	--{{
		Log("InitSlider:");
		for i = 1, #self.SliderList do
			local Slider = self.SliderList[i];
			local bar = getglobal(Slider.UI .. "Bar");
			local name = getglobal(Slider.UI .. "Name");

			bar:SetMaxValue(Slider.max);
			bar:SetMinValue(Slider.min);
			bar:SetValueStep(Slider.step);
			bar:SetValue(Slider.curVal);
			name:Show();
			name:SetText(GetS(Slider.nameID));
		end
	--}}
	end,

	SetSliderVal = function(self, value, id)
	--{{
		Log("SetSliderVal:");
		if value and id then
			self.SliderList[id].curVal = value;
		end
	--}}
	end,

	SetBlock = function(self, blockID)
	--{{
		Log("SetBlock:");
		self.nReplaceBlockID = blockID;
		self:Update();
	--}}
	end,

	OkBtn_OnClick = function(self)
	--{{
		--确认按钮: 将高级属性面板的数据, 保存到矿物条目中.其实就是跟Load()中的操作倒过来.
		Log("OkBtn_OnClick:");
		if self.curMineralItemIndex > 0 then
			local SeniorParam = m_TerrainEdit_TerrainSetParam.Tab[4].ItemList[self.curMineralItemIndex].SeniorParam;
			SeniorParam.nReplaceBlockID = self.nReplaceBlockID;
			SeniorParam.nVeinNum = self.SliderList[1].curVal;
			SeniorParam.TryGenCount = self.SliderList[2].curVal;
		end
	--}}
	end,

	DelBtn_OnClick = function(self)
	--{{
		Log("DelBtn_OnClick:");
		table.remove(m_TerrainEdit_TerrainSetParam.Tab[4].ItemList, self.curMineralItemIndex);
		m_TerrainEdit_TerrainSetParam.Tab[4]:UpdateItemList();
	--}}
	end,

	Update = function(self)
	--{{
		Log("Update:");
		--1. 替换方块
		local btnUI = "MineralSeniorSetFrameBodyReplaceBlockSelBtn";
		local btn = getglobal(btnUI);
		local delBtn = getglobal(btnUI .. "Del");
		local icon = getglobal(btnUI .. "Icon");

		if self.nReplaceBlockID > 0 then
			local blockdef = DXBJGetBlockByID(self.nReplaceBlockID);
			if blockdef then
				DXBJUpdateBlockSlot(btn, blockdef);
				delBtn:Show();
				icon:Show();
			end
		else
			--没有选择方块, 则不显示删除按钮.
			delBtn:Hide();
			icon:Hide();
		end

		--2. 出行方式
		--TerrainEdit_SetSwitchState(self.bSwitchIsOpen);

		--3. 出现概率

	--}}
	end,
};

--打开矿物高级属性面板
function SetMineralSeniorSetFrame(nItemIndex)
	Log("SetMineralSeniorSetFrame: nItemIndex = " .. nItemIndex);

	m_MineralSeniorParam:Init(nItemIndex);
	m_MineralSeniorParam:Update();
	getglobal("MineralSeniorSetFrameBodyReplaceBlockSelBtnName"):Hide();
	getglobal("MineralSeniorSetFrame"):Show();
end

function MineralSeniorSetFrame_OnShow()
	--标题栏
	getglobal("MineralSeniorSetFrameBodyTitleFrameName"):SetText(GetS(9146));
	-- huangfubin 2019/11/12 由于 TerrainEditFrame_OnLoad() 的时候把title的层级设高了，这里也调整下窗口的层级
	getglobal("MineralSeniorSetFrame"):SetFrameLevel(2255)
end

function MineralSeniorSetFrame_OnHide()

end

function MineralSeniorSetFrameCloseBtn_OnClick()
	getglobal("MineralSeniorSetFrame"):Hide();
end

--确认
function MineralSeniorSetFrameBodyOkBtn_OnClick()
	Log("MineralSeniorSetFrameBodyOkBtn_OnClick:");
	m_MineralSeniorParam:OkBtn_OnClick();
	MineralSeniorSetFrameCloseBtn_OnClick();
end

--删除
function MineralSeniorSetFrameBodyDelBtn_OnClick()
	Log("MineralSeniorSetFrameBodyDelBtn_OnClick:");
	m_MineralSeniorParam:DelBtn_OnClick();
	MineralSeniorSetFrameCloseBtn_OnClick();
end

--开关: 出行方式
function MineralSeniorSetFrameGoWaySwitchBtn_OnClick()
	local switchName = this:GetName();
	local state = false;
	local bkg = getglobal(this:GetName().."Bkg");
	local point = getglobal(switchName.."Point");
	
	if point:GetRealLeft() - bkg:GetRealLeft() > 20  then			--先前状态：开
		point:SetPoint("left", this:GetName(), "left", 4, -3);
		state = false;
	else								--先前状态：关
		point:SetPoint("right", this:GetName(), "right", -6, -3);
		state = true;
	end

	--m_MineralSeniorParam.bSwitchIsOpen = state;
end

function TerrainEdit_SetSwitchState(bIsOpen)
	Log("TerrainEdit_SetSwitchState:");
	local switchName = "MineralSeniorSetFrameBodyGoWaySwitch";
	local bkg = getglobal(switchName.."Bkg");
	local point = getglobal(switchName.."Point");
	
	if bIsOpen  then
		--开
		point:SetPoint("right", switchName, "right", -6, -3);
	else
		point:SetPoint("left", switchName, "left", 4, -3);
	end
end

--双滑动条
function TerrainEditMineralItemBar_OnValueChanged()
	local nTotalWidth = 330;
	local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local value1 = math.floor(this:GetValue1());
	local value2 = math.floor(this:GetValue2());
	local ratio1 = value1 / 127;
	local ratio2 = value2 / 127;
	local width1   = math.floor(nTotalWidth * ratio1);
	local width2   = math.floor(nTotalWidth * ratio2);
	local barUI = this:GetName();
	local pro1 = getglobal(barUI .. "Pro1");
	local pro2 = getglobal(barUI .. "Pro2");
	local val1 = getglobal(this:GetParentFrame():GetName() .. "Val1");
	local val2 = getglobal(this:GetParentFrame():GetName() .. "Val2");

	Log("OnValueChanged: value1 = " .. value1 .. ",value2 = " .. value2 .. ", width1 = " .. width1 .. ", width2 = " .. width2);
	pro1:ChangeTexUVWidth(width1)
	pro1:SetWidth(width1);
	pro2:ChangeTexUVWidth(width2)
	pro2:SetWidth(width2);
	val1:SetText(value1 .. GetS(9111));
	val2:SetText(value2 .. GetS(9111));

	m_TerrainEdit_TerrainSetParam.Tab[4]:SetSliderVal(index, value1, value2);
end

function TerrainEditMineralItemBarLeftBtn_OnClick(nType)
	--nType == 1: 左边, 减.
	Log("TerrainEditMineralItemBarLeftBtn_OnClick:");
	local bar = getglobal(this:GetParent().."Bar");
	local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local value1 = math.floor(bar:GetValue1());
	local value2 = math.floor(bar:GetValue2());

	if nType == 1 then
		value1 = value1 - 1;
		if value1 < 0 then value1 = 0; end
		bar:SetValue1(value1);
	else
		value2 = value2 + 1;
		if value2 > 127 then value2 = 127; end
		bar:SetValue2(value2);
	end

	m_TerrainEdit_TerrainSetParam.Tab[4]:SetSliderVal(index, value1, value2);
end
-----------------------------------------------矿物高级属性: end-----------------------------------------


-----------------------------------------------格子选择器:begin----------------------------------------------
local g_TerrainEditSelectFrameParam = {
	nMaxBlock = 81,
	TabConfig = nil,
	Tab = {},
	CurTabIndex = 1,
	CurBlockIndex = 0,	--默认不选择
	SelectType = "",
	TabFrameUI = "DXBJChooseOriginalFrameTabs",
	BlockBoxUI = "DXBJOriginalGridBox",

	Init = function(self)
		Log("g_TerrainEditSelectFrameParam: Init():");
		self.Tab = {};
		self.CurTabIndex = 1;
		self.CurBlockIndex = 0;
		self.SelectType = "";
	end,
};

--方块选择: SurfaceBlock:地表方块选择; FillBlock:填充层方块选择;
function TerrainEditSelBtnTemplate_OnClick()
	Log("TerrainEditSelBtnTemplate_OnClick1:");
	
	--加载自定义方块
	TerrainParameterBlocks:LoadCustomBlock();
	Log("TerrainEditSelBtnTemplate_OnClick2:");
	
	local btnName = this:GetName();
	local m_TerrainEdit_SelectBtnType = "";

	if string.find(btnName, "SurfaceBlock") then
		--蒂表层方块
		m_TerrainEdit_SelectBtnType = "SurfaceBlock";
		g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.SurfaceBlock;
	elseif string.find(btnName, "FillBlock") then
		--填充层方块
		m_TerrainEdit_SelectBtnType = "FillBlock";
		g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.FillBlock;
	elseif string.find(btnName, "SurfaceItem") then
		--地表生成, LLDO:地表和矿物应该只能是添加和删除, 没有修改.
		-- local id = this:GetParentFrame():GetClientID();
		-- m_TerrainEdit_SelectBtnType = "SurfaceItem";
		-- m_TerrainEdit_TerrainSetParam.Tab[2].Class:ItemSelBtn_OnClick(id);
		-- g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.PlantBlock;
		return;
	elseif string.find(btnName, "MineralBox") then
		--矿物生成
		-- local id = this:GetParentFrame():GetClientID();
		-- m_TerrainEdit_SelectBtnType = "MineralBox";
		-- m_TerrainEdit_TerrainSetParam.Tab[4]:ItemSelBtn_OnClick(id);
		-- g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.Mineral;
		return;
	elseif string.find(btnName, "ReplaceBlock") then
		--替换方块
		m_TerrainEdit_SelectBtnType = "ReplaceBlock";
		g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.Mineral;
	else
		m_TerrainEdit_SelectBtnType = "";
	end

	if m_TerrainEdit_SelectBtnType then
		DXBJSetChooseOriginalFrame(m_TerrainEdit_SelectBtnType);
	end
end

--方块删除按钮:
function TerrainEditSelBtnTemplateDelBtn_OnClick()
	local btnName = this:GetName();
	local m_TerrainEdit_SelectBtnType = "";

	if string.find(btnName, "SurfaceBlock") then
		--地表层方块
		m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:SetBlock("SurfaceBlock", 0);
	elseif string.find(btnName, "FillBlock") then
		m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:SetBlock("FillBlock", 0);
	elseif string.find(btnName, "ReplaceBlock") then
		--矿物高级属性
		m_MineralSeniorParam:SetBlock(0);
	end
end

--增加条目, 打开选择器
function TerrainEditSelBtnAddItem(SelectType, id)
	Log("TerrainEditSelBtnAddItem: SelectType = " .. SelectType .. ", id = " .. id);

	if SelectType == "SurfaceItem" then
		--地表生成.
		Log("SurfaceItem:");
		g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.PlantBlock;
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:ItemSelBtn_OnClick(id);
		DXBJSetChooseOriginalFrame(SelectType);
	elseif SelectType == "MineralBox" then
		Log("MineralBox:");
		g_TerrainEditSelectFrameParam.TabConfig = TerrainParameterBlocks.Mineral;
		m_TerrainEdit_TerrainSetParam.Tab[4]:ItemSelBtn_OnClick(id);
		DXBJSetChooseOriginalFrame(SelectType);
	else
		Log("XXXXXXXX:");
	end
end

function DXBJChooseOriginalFrame_OnLoad()
	--标题栏
	getglobal("DXBJChooseOriginalFrameTitleFrameName"):SetText(GetS(3960));

	for i=1, g_TerrainEditSelectFrameParam.nMaxBlock/9 do
		for j=1, 9 do
			local index = (i-1)*9+j;
			local grid = getglobal(g_TerrainEditSelectFrameParam.BlockBoxUI .. index);
			grid:SetPoint("topleft", g_TerrainEditSelectFrameParam.BlockBoxUI .. "Plane", "topleft", (j-1)*84, (i-1)*84);
			grid:SetClientID(index);
		end
	end
end

function DXBJChooseOriginalFrame_OnShow()
	TerrainEdit_SetDealMsg(false);
end

function DXBJChooseOriginalFrame_OnHide()
	TerrainEdit_SetDealMsg(true);
end

function DXCJChooseOriginalFrameClose_OnClick()
	getglobal("DXBJChooseOriginalFrame"):Hide();
end

--获取方块定义根据ID
function DXBJGetBlockByID(blockID)
	-- local blockdef = BlockDefCsv:get(blockID)
 --    if blockdef then
 --        if ModEditorMgr:getBlockDefById(blockdef.ID) then
 --            blockdef = ModEditorMgr:getBlockDefById(blockdef.ID)
 --        end
 --    end

 --    return blockdef;

 	local def = ModEditorMgr:getBlockItemDefById(blockID);
    if def == nil then
		def = ModEditorMgr:getItemDefById(blockID);
	end
	if def == nil then
		def = ItemDefCsv:get(blockID);
	end

	return def;
end

--打开选择器
function DXBJSetChooseOriginalFrame(SelectType)
	Log("DXBJSetChooseOriginalFrame:");

	--local Parameter = TerrainParameterBlocks;
	local Parameter = g_TerrainEditSelectFrameParam.TabConfig;

	if Parameter then
		g_TerrainEditSelectFrameParam:Init();
		g_TerrainEditSelectFrameParam.SelectType = SelectType;

		for i=1, #(Parameter) do
			local t_choose_block = {};

	        for j=1, #(Parameter[i].t) do
	        	local blockID = 0;
	        	if type(Parameter[i].t[j]) == "table" then
	        		----植物配置表结构有点儿特殊, 有个ID字段.
	        		blockID = Parameter[i].t[j].ID;
	        	else
	        		blockID = Parameter[i].t[j];
	        	end

	            local def = ModEditorMgr:getBlockItemDefById(blockID);
	            if def == nil then
					def = ModEditorMgr:getItemDefById(blockID);
				end
				if def == nil then
					def = ItemDefCsv:get(blockID);
				end

	            if def then
	            	table.insert(t_choose_block, {Type=Parameter[i].EditType, Def = def});
	            end
	        end

	        table.insert(g_TerrainEditSelectFrameParam.Tab, {Type = Parameter[i].EditType, EditTypeStringId = Parameter[i].EditTypeStringId, BlockList = t_choose_block});
	    end


	    getglobal("DXBJChooseOriginalFrameTitleFrameName"):SetText(GetS(Parameter.FrameTitleStringId));
	    DXBJEditorTabTemplate_OnClick(1);
		getglobal("DXBJChooseOriginalFrame"):Show();
	end
end

--切换Tab
function DXBJEditorTabTemplate_OnClick(id)
	Log("DXBJEditorTabTemplate_OnClick:");

	if id then id = id; else id = this:GetClientID(); end

	g_TerrainEditSelectFrameParam.CurTabIndex = id;
	g_TerrainEditSelectFrameParam.CurBlockIndex = 0;
	DXBJUpdateSelectFrame();
end

--刷新Tab状态
function DXBJUpdateSelectFrame()
	Log("DXBJUpdateSelectFrame:");
	for i = 1, 4 do
		local tabBtnUI = g_TerrainEditSelectFrameParam.TabFrameUI .. i;
		local tabBtn = getglobal(tabBtnUI);
		local tabBtnName = getglobal(tabBtnUI .. "Name");
		local checked = getglobal(tabBtnUI .. "Checked");

		if i <= #g_TerrainEditSelectFrameParam.Tab then
			--Tab
			tabBtn:Show();
			tabBtnName:SetText(GetS(g_TerrainEditSelectFrameParam.Tab[i].EditTypeStringId));

			if i == g_TerrainEditSelectFrameParam.CurTabIndex then
				--选中
				checked:Show();
				tabBtnName:SetTextColor(76, 76, 76);
			else
				checked:Hide();
				tabBtnName:SetTextColor(205, 174, 129);
			end
		else
			tabBtn:Hide();
		end
	end

	DXBJSelectFrameLoadSlot();
end

--加载对应Tab的格子
function DXBJSelectFrameLoadSlot()
	Log("DXBJSelectFrameLoadSlot:");
	local CurTabIndex = g_TerrainEditSelectFrameParam.CurTabIndex;

	if g_TerrainEditSelectFrameParam.Tab and g_TerrainEditSelectFrameParam.Tab[CurTabIndex] then
		local BlockList = g_TerrainEditSelectFrameParam.Tab[CurTabIndex].BlockList;

		if BlockList then
			for i = 1, g_TerrainEditSelectFrameParam.nMaxBlock do
				local slotUI = g_TerrainEditSelectFrameParam.BlockBoxUI .. i;
				local slot = getglobal(slotUI);
				local checked = getglobal(slotUI .. "Checked");

				if i <= #BlockList then
					slot:Show();
					checked:Hide();
					DXBJUpdateBlockSlot(slot, BlockList[i].Def);
				else
					slot:Hide();
				end
			end

			--调整滑动窗口高度
			local num = #BlockList or 1;
			local planeH = 84 * math.ceil(num / 9);
			local plane = getglobal(g_TerrainEditSelectFrameParam.BlockBoxUI .. "Plane");
			local boxH = getglobal(g_TerrainEditSelectFrameParam.BlockBoxUI):GetRealHeight();
			if planeH < boxH then planeH = boxH; end
			plane:SetSize(plane:GetWidth(), planeH);
		end

	end
end

--更新单个格子
function DXBJUpdateBlockSlot(slot, blockdef)
	local slotname = slot:GetName();
	if blockdef then
		-- if blockdef.CopyID > 0 then
		-- 	getglobal(slotname.."Checked"):Show();
		-- else
		-- 	getglobal(slotname.."Checked"):Hide();
		-- end
		
		local def = BlockDefCsv:get(blockdef.ID, false);
		local def_item = ModEditorMgr:getBlockItemDefById(blockdef.ID);
		local name, id;
		
		if def_item then
			name = def_item.Name
			id = def_item.ID
		elseif def then
			name = def.Name
			id = def.ID
		end
		
		--图片
		if id then
			SetItemIcon(getglobal(slotname.."Icon"), id);
			if string.find(slotname, "TerrainFrameSurfaceItemBox") then
				getglobal(slotname.."AddIcon"):Hide();
			end
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
			if string.find(slotname, "TerrainFrameSurfaceItemBox") then
				getglobal(slotname.."AddIcon"):Show();
			end
		end

		--名字, 这个函数格子和按钮是通用的, 格子是没有name的, 这里要区别
		local nameUI = slotname .. "Name";
		if HasUIFrame(nameUI) then
			getglobal(nameUI):SetText(name);
		end

		--UpdateSlotSelBtn(slotname, blockdef.EnglishName, FrameStack.cur().CurrentSel.selectedBlockFileNames, FrameStack.cur().CurrentSel.disabledBlockFileNames);
	end
end

--点击格子
function DXBJOriginalGridTemplate_OnClick()
	Log("DXBJOriginalGridTemplate_OnClick:");
	local id = this:GetClientID();

	if id then
		local CurTabIndex = g_TerrainEditSelectFrameParam.CurTabIndex;
		local BlockList = g_TerrainEditSelectFrameParam.Tab[CurTabIndex].BlockList;

		for i = 1, #BlockList do
			local slotUI = g_TerrainEditSelectFrameParam.BlockBoxUI .. i;

			if HasUIFrame(slotUI) then
				local slot = getglobal(slotUI);
				local checked = getglobal(slotUI .. "Checked");

				if id == i then
					--选中
					checked:Show();
					g_TerrainEditSelectFrameParam.CurBlockIndex = id;

					--弹出提示
					local blockdef = BlockList[i].Def;
					if blockdef then
						UpdateTipsFrame(blockdef.Name,0);
					end
				else
					checked:Hide();
				end
			else
				break;
			end
		end
	end
end

--确定选择
function DXCJChooseOriginalFrameOkBtn_OnClick()
	local SelectType = g_TerrainEditSelectFrameParam.SelectType;
	local CurTabIndex = g_TerrainEditSelectFrameParam.CurTabIndex;
	local BlockList = g_TerrainEditSelectFrameParam.Tab[CurTabIndex].BlockList;
	local CurBlockIndex = g_TerrainEditSelectFrameParam.CurBlockIndex;

	if SelectType and CurBlockIndex > 0 then
		Log("DXCJChooseOriginalFrameOkBtn_OnClick: SelectType = " .. SelectType .. ", CurBlockIndex = " .. CurBlockIndex);
		local blockdef = BlockList[CurBlockIndex].Def;

		if SelectType == "SurfaceBlock" or SelectType == "FillBlock" then
			--地貌生成
			m_TerrainEdit_TerrainSetParam.Tab[1].MainTerrain:SetBlock(SelectType, blockdef.ID);
			
			--刷新地形预览
			TerrainEdit_UpdateTerrainView();
		elseif SelectType == "SurfaceItem" then
			--地表生成
			m_TerrainEdit_TerrainSetParam.Tab[2].Class:SetItemSelBtn(blockdef.ID);
		elseif SelectType == "MineralBox" then
			--矿物生成
			m_TerrainEdit_TerrainSetParam.Tab[4]:SetItemSelBtn(blockdef);
		elseif SelectType == "ReplaceBlock" then
			--替换方块
			m_MineralSeniorParam:SetBlock(blockdef.ID);
		else

		end
	end

	DXCJChooseOriginalFrameClose_OnClick();
end

--打开选择器时, 使后面的滑动框无效
function TerrainEdit_SetDealMsg(isDeal)
	getglobal("TerrainFrameSurfaceItemBox"):setDealMsg(isDeal);
	getglobal("TerrainFrameMineralBox"):setDealMsg(isDeal);
end
-----------------------------------------------格子选择器:end----------------------------------------------

-----------------------------------------------其它--------------------------------------------------------
--单滑动条
function TerrainEditSignalSliderTemplateBar_OnValueChanged()
	local value = this:GetValue();
	local barUI = this:GetName();
	local pro = getglobal(barUI .. "Pro");
	local sliderUI = this:GetParent();
	local valObj = getglobal(sliderUI .. "Val");
	local desc = getglobal(sliderUI .. "Desc");

	if m_TerrainEdit_TerrainSetParam.Tab.curTabIndex == 2 then
		--地表生成, 植被密度
		local id = this:GetParentFrame():GetParentFrame():GetClientID();
		-- local ratio = value / 1000;
		local ratio = (value - this:GetMinValue()) / (this:GetMaxValue() - this:GetMinValue());
		local width = math.floor(328 * ratio);

		--设置当前地形, 当前植物的密度值.
		m_TerrainEdit_TerrainSetParam.Tab[2].Class:SetSliderVal(value, id);

		--设置UI
		pro:ChangeTexUVWidth(width)
		pro:SetWidth(width);
		valObj:Hide();

		--浓度描述
		local m_DensityConfig = TerrainParameterBlocks.PlantBlock.m_DensityConfig;
		for i = 1, #m_DensityConfig do
			if value <= m_DensityConfig[i].value then
				desc:SetText(GetS(m_DensityConfig[i].descID));
				break;
			end
		end
	elseif m_TerrainEdit_TerrainSetParam.Tab.curTabIndex == 4 then
		--矿物生成, 高级
		local id = this:GetParentFrame():GetClientID();
		local ratio = (value - this:GetMinValue()) / (this:GetMaxValue() - this:GetMinValue());
		local width = math.floor(328 * ratio);

		pro:ChangeTexUVWidth(width)
		pro:SetWidth(width);

		local text = "";
		if id == 1 then
			text = GetS(9142, value);	--最多@1个.
		elseif id == 2 then
			for i = 1, #g_TerrainParameter_MineralConfig.VeinNumDesc do
				if value <= g_TerrainParameter_MineralConfig.VeinNumDesc[i].num then
					text = text .. value .. "\t" .. GetS(g_TerrainParameter_MineralConfig.VeinNumDesc[i].descStrID);
					break;
				end
			end
		end
		Log("text = " .. text);
		valObj:Show();
		valObj:SetText(text);
		desc:Hide();

		m_MineralSeniorParam:SetSliderVal(value, id);
	else

	end
end

function TerrainEditSignalSliderTemplateLeftBtn_OnClick(nType)
	--nType == 1: 减
	if nType then
		Log("TerrainEditSignalSliderTemplateLeftBtn_OnClick: nType = " .. nType);
		local bar = getglobal(this:GetParent().."Bar");
		local value = bar:GetValue();
		local index = this:GetParentFrame():GetParentFrame():GetClientID();
		local maxValue = bar:GetMaxValue();
		local minValue = bar:GetMinValue();

		if m_TerrainEdit_TerrainSetParam.Tab.curTabIndex == 2 then
			--地表生成, 植被密度
			if nType == 1 then value = value - 50; else value = value + 50; end
			if value < minValue then value = minValue; end;
			if value > maxValue then value = maxValue; end;
			m_TerrainEdit_TerrainSetParam.Tab[2].Class:SetSliderVal(value, index);

		elseif m_TerrainEdit_TerrainSetParam.Tab.curTabIndex == 4 then
			--矿物生成, 高级
			if nType == 1 then value = value - 1; else value = value + 1; end
			if value < minValue then value = minValue; end;
			if value > maxValue then value = maxValue; end;
		else

		end

		bar:SetValue(value);
	end
end
