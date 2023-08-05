--声明
local AvatarBodyManager = Class("AvatarBodyManager")

--实例
local instance = nil

--获取实例
function AvatarBodyManager:GetInst()
	if instance == nil then 
		instance = ClassList["AvatarBodyManager"].instance()
	end 
	return instance
end

--初始化
function AvatarBodyManager:Init()
	self.data = {}
	self.define = {}

	--部件类型
	self.define.skinPartType = 
	{
		none = 0,
		head = 1,
		face = 2,
		mask = 3,
		coat = 4,
		glove = 5,
		pants = 6,
		shoes = 7,
		back = 8,
		footprint = 9,
		skin = 10,
		max = 10,
	}
	--部件类型个数
	self.define.skinPartTypeNum = self.define.skinPartType.max
	--基础部件
	self.define.baseSkinParts = 
	{
		{partId = 2,partType = 1},
		{partId = 3,partType = 4},
		{partId = 4,partType = 6},
	}
	--默认风格图片
	self.define.actorDefaultTexPath = "entity/player/player12/body.png"

	self.data.bodySkinPartIds ={}
end

--获取角色当前穿戴的部件ID
function AvatarBodyManager:GetBodySkinPartIds(body)
	local bodyId = body:getAvtBodyID()
	return self.data.bodySkinPartIds[bodyId]
end

--添加角色当前穿戴的部件ID
function AvatarBodyManager:AddBodySkinPartId(body,partType,partId)
	local bodyId = body:getAvtBodyID()
	if not self.data.bodySkinPartIds[bodyId] then 
		self.data.bodySkinPartIds[bodyId] = {}
	end 
	self.data.bodySkinPartIds[bodyId][partType] = partId
end

--删除角色当前穿戴的部件ID
function AvatarBodyManager:DelBodySkinPartId(body,partType)
	local bodyId = body:getAvtBodyID()
	if self.data.bodySkinPartIds[bodyId] then 
		self.data.bodySkinPartIds[bodyId][partType] = nil
	end 
end

--获取角色当前穿戴的部件ID

--添加皮肤部件 
--必传参数：
--param.id = number or table 部件ID
--param.body = 使用的角色
--可选参数：
--param.handleId = 本次添加皮肤操作的id，用来防止异步冲突
--param.isAsyn = 是否异步加载
--param.asynInterval = 每次异步加载的时间间隔
--param.style = 风格
--param.color = 颜色
--param.isClearEmpty = 是否清除默认部件
function AvatarBodyManager:AddSkinPart(param)
	--添加
	local function add(id,body)
		local partDef = GetInst("ShopDataManager"):GetSkinPartDefById(id)
		if partDef then 
			local partType = partDef.Part 
			local partId = partDef.ModelID 
			local shieldTypes = loadstring("return " .. partDef.ShieldID)()

			--先脱下需要屏蔽的部件
			if shieldTypes and #shieldTypes > 0 then
				for j = 1,#shieldTypes do
					local aShieldType = shieldTypes[j]
					if aShieldType == self.define.skinPartType.face then 
						body:exchangePartFace(0,aShieldType,false,"", body:getSkinColorModel())
					elseif aShieldType == self.define.skinPartType.skin then 
						body:exchangePartFace(body:getFaceModel(),2,false,"", 0)
					elseif aShieldType == self.define.skinPartType.footprint then 
						local footPrint = UIActorBodyManager:getPointBody(param.pointBodyId or 1,false)
						if footPrint then
							footPrint:stopEffectParticle(true)
						end
					else
						body:hideAvatarPartModel(aShieldType)
					end 
					self:DelBodySkinPartId(body,aShieldType)
				end 
			end 

			--添加部件
			if partType == self.define.skinPartType.face then 
				local isSuccess = body:exchangePartFace(partId,partType,true, "",  body:getSkinColorModel())
				if isSuccess then
					self:AddBodySkinPartId(body,partType,partId) 
				end 
			elseif  partType == self.define.skinPartType.skin then
				body:exchangePartFace(body:getFaceModel(),2,true, "", partId)
			elseif partType == self.define.skinPartType.footprint then 
				local footPrint = UIActorBodyManager:getPointBody(param.pointBodyId or 1,false)
				footPrint:stopEffectParticle(true)
				if param.actorView then 
					local x, y, z = -70, 20, -320
					if param.footPrintPoint then
						x = param.footPrintPoint.x or -70
						y = param.footPrintPoint.y or 20
						z = param.footPrintPoint.z or -320
					end
					if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
						footPrint:playEffectParticle(3, partId)
						param.actorView:attachActorBodyToScene(footPrint, x, y, z)
					else
						footPrint:playEffectParticle(3,partId,param.actorView, x, y, z)
					end
				end 
				self:AddBodySkinPartId(body,partType,partId) 
			else
				local isSuccess = body:addAvatarPartModel(partId,partType)
				if isSuccess then
					self:AddBodySkinPartId(body,partType,partId) 
				end 
			end

			--补充默认部件
			if not param.isClearEmpty then
				self:FillDefaultSkinPart(body)
			end
			if partType == self.define.skinPartType.head then 
				body:showSkin("part1", partDef.ShieldEar ~= 1)
			end
		end 
	end 

	--清理
	local function clear(ids,body)
		for i = 1,#ids do 
			local partDef = GetInst("ShopDataManager"):GetSkinPartDefById(ids[i])
			if partDef and partDef.Part then 
				--移除与当前需要穿戴的部位一致的部件
				if partDef.Part == self.define.skinPartType.face then 
					body:exchangePartFace(0, partDef.Part,false, "", body:getSkinColorModel())
				elseif partDef.Part == self.define.skinPartType.footprint then 
				elseif partDef.Part == self.define.skinPartType.skin then
					body:exchangePartFace(body:getFaceModel(),2,true, "", 0)
				else
					body:hideAvatarPartModel(partDef.Part)
				end 
				self:DelBodySkinPartId(body, partDef.Part)

				--移除上一次屏蔽本部件的部件
				local bodySkinPartIds = self:GetBodySkinPartIds(body)
				if bodySkinPartIds then
					for k,v in pairs(bodySkinPartIds) do 
						local aPartDef = GetInst("ShopDataManager"):GetSkinPartDefById(v) 
						if aPartDef then 
							local shieldTypes = loadstring("return " .. aPartDef.ShieldID)()
							if shieldTypes and #shieldTypes > 0 then 
								for c = 1,#shieldTypes do 
									local aShieldType = shieldTypes[c]
									if aShieldType == partDef.Part then
										if aPartDef.Part == self.define.skinPartType.face or aPartDef.Part == self.define.skinPartType.skin  then 
											body:exchangePartFace(0,aPartDef.Part,false)
										elseif aShieldType == self.define.skinPartType.footprint and aPartDef.Part == self.define.skinPartType.footprint then 
											local footPrint = UIActorBodyManager:getPointBody(param.pointBodyId or 1,false)
											if footPrint then
												footPrint:stopEffectParticle(true)
											end
										else
											body:hideAvatarPartModel(aPartDef.Part)
										end
										self:DelBodySkinPartId(body,aPartDef.Part)
									end 
								end 
							end 
						end 
					end 
				end
				if partDef.Part == self.define.skinPartType.head then 
					body:showSkin("part1", true)
				end
			end

		end 
		if not param.isClearEmpty then
			self:FillDefaultSkinPart(body)
		end 
	end 

	if param and param.id and param.body then
		if type(param.id) == "number" then 
			clear({param.id},param.body)
 			add(param.id,param.body)
		elseif type(param.id) == "table" then 
			clear(param.id,param.body)
			if param.isAsyn then
				--异步加载
				self.handleId = param.handleId or self.handleId
				local addPartIndex = 0
				threadpool:work(function()
					if #param.id == 0 then
						self:SetSkinStyle(param.style)
						self:SetSkinPartColor(param.color)
					end
					
					while addPartIndex < #param.id and (not param.handleId or self.handleId == param.handleId) do
						if tolua.isnull(param.body) then
							break
						end
						addPartIndex = addPartIndex + 1
						add(param.id[addPartIndex],param.body)
						if addPartIndex == #param.id then 
							if self.handleId == param.handleId then
								self.handleId = nil 
							end 
							self:SetSkinStyle(param.style)
							self:SetSkinPartColor(param.color)
						end 
						threadpool:wait(param.asynInterval or 0.3) 
					end 
				end)
			else
				--同步加载
				local addPartIndex = 0
				threadpool:work(function()
					while addPartIndex < #param.id do
						if tolua.isnull(param.body) then
							break
						end
						addPartIndex = addPartIndex + 1
						add(param.id[addPartIndex],param.body)
						threadpool:wait(0.02)
					end
					self:SetSkinStyle(param.style)
					self:SetSkinPartColor(param.color)
				end) 
			end 
		end 
	end 
end

--去除皮肤部件
--必传参数：
--param.body = 使用的角色
--可选参数：
--param.type = 部件类型
--param.isAll = 是否全部去除
--param.isAllEmpty = 是否全部去除，且不要默认部件 
--param.isARTexture = 是否穿上AR贴图
function AvatarBodyManager:DelSkinPart(param)
	local function canDel(delType)
		if not param.type then 
			if param.isAll then 
				return true 
			elseif param.isAllEmpty then 
				return true 
			else
				return false
			end 
		else
			if delType == param.type then 
				return true 
			else
				return false 
			end 
		end 
	end 
	if param and param.body then
		for i = 1,self.define.skinPartTypeNum do 
			if canDel(i) then 
				if i == self.define.skinPartType.face and not param.isARTexture then
					param.body:exchangePartFace(0,i,false, "", param.body:getSkinColorModel())
				elseif i == self.define.skinPartType.skin then
					param.body:exchangePartFace( param.body:getFaceModel(),2,true, "", 0)
				elseif i == self.define.skinPartType.footprint then 
					local footPrint = UIActorBodyManager:getPointBody(param.pointBodyId or 1,false)
					footPrint:stopEffectParticle(true)
				else
					param.body:hideAvatarPartModel(i)
				end
				if i == self.define.skinPartType.head then 
					param.body:showSkin("part1", true)
				end
			end 
		end 

		if param.isAll then
			--恢复默认部件
			self:AddDefaultSkinPart(param.body)
		elseif param.isAllEmpty then 
		else
			--补充默认部件
			if param.type and param.type == self.define.skinPartType.coat then
				self:FillDefaultSkinPartWithoutCheck(param.body)
			else
				self:FillDefaultSkinPart(param.body)
			end 
		end 
	end 
end 

--穿上默认部件
function AvatarBodyManager:AddDefaultSkinPart(body,partType)
	local baseSkinPartsDef = self.define.baseSkinParts
	if partType then 
		--指定部位
		for i = 1,#baseSkinPartsDef do
			local aType = baseSkinPartsDef[i].partType
			local aId = baseSkinPartsDef[i].partId
			if aType == partType then 
				body:addAvatarPartModel(aId,aType)
			end 
		end
	else
		--全部
		body:addAvatarPartModel(baseSkinPartsDef[1].partId,baseSkinPartsDef[1].partType)
		body:addAvatarPartModel(baseSkinPartsDef[2].partId,baseSkinPartsDef[2].partType)
		body:addAvatarPartModel(baseSkinPartsDef[3].partId,baseSkinPartsDef[3].partType)
	end 
end

--补充默认部件（不检测遮挡关系）
function AvatarBodyManager:FillDefaultSkinPartWithoutCheck(body)
	local lackPartTypes = {}
	for i = 1,self.define.skinPartTypeNum do 
		if not body:IsShowAvatar(i) then
			lackPartTypes[i] = true
		else
			lackPartTypes[i] = false 
		end 
	end

	local baseSkinPartsDef = self.define.baseSkinParts
	for i = 1,#baseSkinPartsDef do
		local aType = baseSkinPartsDef[i].partType
		local aId = baseSkinPartsDef[i].partId
		if lackPartTypes[aType] then 
			body:addAvatarPartModel(aId,aType)
		end 
	end
end

--补充默认部件(检测遮挡关系)
function AvatarBodyManager:FillDefaultSkinPart(body)
	local function isSheild(partType)
		local bodySkinPartIds = self:GetBodySkinPartIds(body)
		if bodySkinPartIds then
			for k,v in pairs(bodySkinPartIds) do 
				local aPartDef = GetInst("ShopDataManager"):GetSkinPartDefById(v) 
				if aPartDef then 
					local shieldTypes = loadstring("return " .. aPartDef.ShieldID)()
					if shieldTypes and #shieldTypes > 0 then 
						for c = 1,#shieldTypes do 
							local aShieldType = shieldTypes[c]
							if aShieldType == partType then 
								return true  
							end 
						end 
					end 
				end 
			end 
		end 
		return false 
	end 
	local lackPartTypes = {}
	for i = 1,self.define.skinPartTypeNum do 
		if not body:IsShowAvatar(i) and not isSheild(i) then
			lackPartTypes[i] = true
		else
			lackPartTypes[i] = false 
		end 
	end

	local baseSkinPartsDef = self.define.baseSkinParts
	for i = 1,#baseSkinPartsDef do
		local aType = baseSkinPartsDef[i].partType
		local aId = baseSkinPartsDef[i].partId
		if lackPartTypes[aType] then 
			body:addAvatarPartModel(aId,aType)
		end 
	end
end

--设置皮肤风格
--必传参数：
--param.body = 使用的角色
--param.styleInfo = 风格信息
--可选参数：
--param.isAsyn = 是否异步加载
--param.asynInterval = 每次异步加载的时间间隔
function AvatarBodyManager:SetSkinStyle(param)
	if param and param.body and param.styleInfo then
		-- if param.isAsyn then 
			threadpool:work(function() 
				if param.styleInfo.Path then
					UIActorBodyManager:resetAvatarTexture(param.body:getAvtBodyID(),param.styleInfo.Path)
				end 
			end)
			threadpool:work(function() 
				threadpool:wait(param.asynInterval or 0.01)
				local style = param.styleInfo.Style
				if style then
					if style.Solid and style.Solid == 1 then
						param.body:resetAcotorTexture(true)
					else
						param.body:resetAcotorTexture(false)
					end
				end 
			end)
			threadpool:work(function() 
				if param.asynInterval then
					threadpool:wait(param.asynInterval * 2)
				else
					threadpool:wait(0.02 * 2)
				end 
				local style = param.styleInfo.Style
				if style then
					local reTinting = 0
					if style.Tinting == 0 then 
						reTinting = 1
					else
						reTinting = 0
					end 
					if reTinting == 1 then
						if style.Hue and style.Saturability and style.Brightness then 
							param.body:alterAvatarPartColor((style.Hue + 1) / 2,(style.Saturability + 1) / 2,(style.Brightness + 1) / 2,0,0,1)
						end 
					else
						if style.Hue and style.Saturability and style.Brightness and style.Acutance then
							param.body:alterBodyStyle(style.Hue,style.Saturability,style.Brightness,style.Acutance,style.Solid == 1 or false)
						end 
					end
				end
			end)
		-- else
		-- 	--这里有BUG，同步加载加载不出效果，暂时都用异步
		-- 	UIActorBodyManager:resetAvatarTexture(param.body:getAvtBodyID(),param.styleInfo.Path)
		-- 	local style = param.styleInfo.Style
		-- 	if style.Solid and style.Solid == 1 then
		-- 		param.body:resetAcotorTexture(true)
		-- 	else
		-- 		param.body:resetAcotorTexture(false)
		-- 	end
		-- 	if style.Tinting and style.Tinting == 1 then
		-- 		param.body:alterAvatarPartColor((style.Hue + 1) / 2,(style.Saturability + 1) / 2,(style.Brightness + 1) / 2,0,0,1)
		-- 	else
		-- 		param.body:alterBodyStyle(style.Hue,style.Saturability,style.Brightness,style.Acutance,style.Solid == 1 or false)
		-- 	end
		-- end  
	end 
end 

--设置皮肤部件颜色
--必传参数：
--param.body = 使用的角色
--param.colorInfo = 颜色信息
--可选参数：
--param.isAsyn = 是否异步加载
--param.asynInterval = 每次异步加载的时间间隔
function AvatarBodyManager:SetSkinPartColor(param)
	local function setColor(colorInfo)
		for k,v in pairs(colorInfo.color) do
			if #v == 4 then
				local partIds = self:GetBodySkinPartIds(param.body)
				if partIds then 
					local isIn = false 
					for k, v in pairs(partIds) do
						if v == colorInfo.partId then
							isIn = true;
							break 
						end
					end
					if isIn then 
						param.body:alterAvatarPartColor(v[2],v[3],v[4],colorInfo.partType,colorInfo.partId,v[1])
					end 
				end 
			end
		end
	end 
	if param and param.body and param.colorInfo then 
		if param.isAsyn then
			local setIndex = 0
			threadpool:work(function() 
				while setIndex < #param.colorInfo do
					setIndex = setIndex + 1
					local aColorInfo = param.colorInfo[setIndex]
					setColor(aColorInfo)
					threadpool:wait(param.asynInterval or 0.75) 
				end 
			end)
		else
			for i = 1,#param.colorInfo do 
				local aColorInfo = param.colorInfo[i]
				setColor(aColorInfo)
			end 
		end 
	end 
end

--设置AR皮肤贴图
--必传参数：
--param.body = 使用的角色
--param.code = 贴图下载成功或失败(GetInst("ShopService"):VerifyARTexture(uin, seatID))
--param.path = 贴图路径
--param.uin  = 迷你号(兼容原有逻辑暂时保留)
function AvatarBodyManager:SetARTexPaht(param)
	if param and param.body and  param.code and param.path and param.uin then
		if param.code == 1 or (param.uin == AccountManager:getUin() and param.code ~= 2 and param.code ~= -1) then
			param.body:setARTexPaht(param.path)
			if string.find(param.path, "entity/player/player12") then
				param.body:setBodyType(3);
				self:AddDefaultSkinPart(param.body)
			else
				param.body:setBodyType(4);
				--AR皮肤，在未添加任何部件的情况下，是完全空白的
				self:DelSkinPart({body = param.body,isAllEmpty = true})
			end
		else
			param.body:setBodyType(3);
			self:AddDefaultSkinPart(param.body)
		end
	else
		print("参数获取失败")
	end
end