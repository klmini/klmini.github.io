
if _G.ns_a4399 then return end

ns_a4399 = {      -- namespace activity 4399

	server_config       = {},
	ma_config_task_id   = 0,          --下载server_config任务ID
	png_task_list       = {},         --下载png文件的列表
};




function Activity4399Frame_OnLoad()

	if ClientMgr:getApiId() == 2 then
		--4399平台
	else
		do return end;
	end


	--if  g_debug_ui == true then
		--g_debug_ui_hide = getglobal("Activity4399Frame");
	--end	


	for i=1, 6 do
		local btn_name = "Activity4399FrameReward" .. i;
		getglobal( btn_name ):SetPoint( "topleft", "Activity4399FrameChenDi", "bottomleft", (i-1)*136+94, 84 );
	end

	
end


function Activity4399Frame_OnEvent()
end



function Activity4399Frame_OnShow()
	SetCurEditBox("Activity4399FrameEdit");
end


function Activity4399Frame_OnHide()
end


function Activity4399FrameCloseBtn_OnClick()
	getglobal("Activity4399Frame"):Hide();
end

function Activity4399FrameEdit_OnEnterPressed()
	Activation4399Btn_OnClick();
end

function Activation4399Btn_OnClick()

	local apiId = ClientMgr:getApiId();
	local cdkey = getglobal("Activity4399FrameEdit"):GetText();
	
	Log( "cdkey=" .. cdkey );
	
	if cdkey == "" then
		ShowGameTips(GetS(281), 3);
		return;
	end
	local ret = AccountManager:getAccountData():notifyServerActivationCodeReward(apiId, cdkey);
	if ret == 0 then
		ShowGameTips(GetS(285), 3);
	end

end




-----------------------------------逻辑函数部分--------------------


ns_a4399.func =         --避免和其他全局函数冲突
{
	--下载ma_config.lua
	downloadLua = function()
		ns_http.func.rpc( g_http_root .. "miniw/tg/a4399new.lua", ns_a4399.func.downloadLua_callback );          --加载4399配置文件
	end,


	downloadLua_callback = function(ret)
		Log( "call downloadLua_callback . " );
		 
		ns_a4399.server_config = ret;
		ns_a4399.func.resetUI();
	end,


	--更新UI
	resetUI = function()

		if  ns_a4399.server_config then
		
			if ns_a4399.server_config.text then
				for k, v in pairs( ns_a4399.server_config.text ) do
					Log( "k = " .. k );					
					getglobal(k):SetText( v );					
				end
			end


			if ns_a4399.server_config.gift then				
			
				local  btn_name = "Activity4399Frame";
			
				for j=1, 6 do		
					if j <= #ns_a4399.server_config.gift then
						getglobal( btn_name .. "Reward" .. j ):Show();
						
						local day_  = ns_a4399.server_config.gift[j].day;
						local id_   = ns_a4399.server_config.gift[j].id;
						local num_  = ns_a4399.server_config.gift[j].num;
						
						if day_ and id_ and num_ then
							local name_ = getglobal( btn_name .. "Reward" .. j .. "Name" );
							local numf_ = getglobal( btn_name .. "Reward" .. j .. "Num" );
							local icon_ = getglobal( btn_name .. "Reward" .. j .. "Icon" );

							local itemDef = ItemDefCsv:get(id_);
							if itemDef then
								--name_:SetText(itemDef.Name);
								----------StringBuilder-----
								name_:SetText(GetS(3593, day_));
								numf_:SetText("x".. num_ );
							end

							Log( "pic_file_name=" .. "items/" .. itemDef.Icon .. ".png" .. ", pos=" .. j*110-80 );
							icon_:SetTexture( "items/" .. itemDef.Icon .. ".png"  );							
							
							
						end					
						
					else
						getglobal( btn_name .. "Reward" .. j ):Hide();
					end
				end
				
			end			
			
		end

	end,
	

};
