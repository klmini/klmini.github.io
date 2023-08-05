
BUFF_MAX_NUM = 20;

function BuffFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function BuffFrameCloseBtn_OnClick()
	local buffFrame 	= getglobal("BuffFrame");
	buffFrame:Hide();
end

function BuffFrame_OnShow()
	HideAllFrame("BuffFrame", true);

	if not getglobal("Shop"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

function BuffFrame_OnHide()
	ShowMainFrame();
	local buffFrameInfo 	= getglobal("BuffFrameInfo");
	buffFrameInfo:resetOffsetPos();

	if not getglobal("BuffFrame"):IsRehide() then
			ClientCurGame:setOperateUI(false);
	end
end

function BuffFrame_OnUpdate()
	local ride = CurMainPlayer:getRidingHorse();
	local t_buff = {}
	local num = 0;
	 local attrib;
	if MainPlayerAttrib and MainPlayerAttrib:getBuffNum() > 0 then
		num = MainPlayerAttrib:getBuffNum();
		attrib = MainPlayerAttrib;

		for i=1, num do
			local info = attrib:getBuffInfo(i-1);
			--装备的buff不显示
			if info and info.def and info.def.BuffType == 1 then
				table.insert(t_buff, {info=info, ownerType="player"});
			end
		end
	end

	if ride and ride:getLivingAttrib() and ride:getLivingAttrib():getBuffNum()>0 then
		num = ride:getLivingAttrib():getBuffNum();
		attrib = ride:getLivingAttrib();

		for i=1, num do
			local info = attrib:getBuffInfo(i-1);
			--装备的buff不显示
			if info and info.def and info.def.BuffType == 1 then
				table.insert(t_buff, {info=info, ownerType="ride"});
			end
		end
	end

    
	local getglobal = _G.getglobal;
	local buffFrameInfoPlane 	= getglobal("BuffFrameInfoPlane");
	local buffFrameInfoPlaneHeight = 0;
	for i=1, BUFF_MAX_NUM do
		local frame = getglobal("BuffFrameInfoBuff"..i);
		if i <= #t_buff then
			local frameHeight = 80;
			local descHeight = 29;
			local info = t_buff[i].info;
			if info.def.IconName ~= '' or SingleEditorFrame_Switch_New then
				frame:Show();
				local icon 		= getglobal("BuffFrameInfoBuff"..i.."Icon");
				local title 		= getglobal("BuffFrameInfoBuff"..i.."Title");
				local desc 		= getglobal("BuffFrameInfoBuff"..i.."Desc");
				local remainTime 	= getglobal("BuffFrameInfoBuff"..i.."RemainTime");
				local text = info.def.Desc;
                if SingleEditorFrame_Switch_New then
                    if info.def and info.def.Status and info.def.Status.EffInfo then
						if t_buff[i].ownerType == "player" then  --下面的描述都是跟“角色”强绑定的
							for i = 1, 5 do
								if info.def.Status.EffInfo[i-1].CopyID > 0 then
									local descStr = GetInst("ModsLibDataManager"):GetStatusEffectDescStr(info.def.Status.EffInfo[i-1])
									if descStr ~= "" then
										if text == info.def.Desc then
											local extentWidth = desc:GetTextExtentWidth(text)
											local descWidth = 410
											if extentWidth > descWidth then
												local maxlen = 75;-- 一行
												text = string.sub(text,1,maxlen-3) .. "..."
											end
											if text == "" then
												text = descStr
											else
												text = text  .. "\n" .. descStr
											end
										else
											text = text  .. "\n" .. descStr
										end
									end
								end
							end
						end
                        local path = GetInst("ModsLibDataManager"):GetStatusIconPath(info.def.ID);
                        icon:SetTexture(path, true)
                    end
                else
                    icon:SetTexture("ui/bufficons/"..info.def.IconName..".png");
                end

				local time = math.ceil( info.ticks*0.05 );
				local timetext = math.floor(time/60)..":"..math.mod(time, 60);
				if time >= 9999 then
					timetext = GetS(680);
				end
				remainTime:SetText(timetext);

				if info.def.Type == 0 then			--有益
					remainTime:SetTextColor(1, 194, 16);
				elseif info.def.Type == 1 then			--不利
					remainTime:SetTextColor(255, 137, 32);
				end

				desc:SetText(text, 67, 80, 82);
				local lineNum = desc:GetTextLines();
				if lineNum > 0 then
					frameHeight = frameHeight + lineNum*20;
					descHeight = descHeight + lineNum*20;
				end
				frame:SetHeight(frameHeight);
				desc:SetHeight(descHeight);
				title:SetText(info.def.Name);

				if i == 1 then
					frame:SetPoint("top", "BuffFrameInfoPlane", "top", 0, 0);
				else
					frame:SetPoint("top", "BuffFrameInfoBuff"..i-1, "bottom", 0, 0);
				end
				buffFrameInfoPlaneHeight = buffFrameInfoPlaneHeight + frame:GetHeight();
			else 
				frame:Hide();
			end
		else
			frame:Hide();
		end	
	end
	if buffFrameInfoPlaneHeight > 300 then
		buffFrameInfoPlane:SetHeight(buffFrameInfoPlaneHeight);
	else
		buffFrameInfoPlane:SetHeight(300);
	end
end