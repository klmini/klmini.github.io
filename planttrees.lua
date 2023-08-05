function LoadPlantTreeData()
	Log('LoadPlantTreeData');
	local num = AccountManager:getMyWorldList():getNumWorld();
	for t=1, num do
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(t-1);
		if worldInfo and (worldInfo.fromowid == 1752346657768 or worldInfo.worldid == 1752346657768) and CurWorld:getOWID()==worldInfo.worldid then
			WWW_getZhishu201803OthersList(276);
			return;
		end
	end
end

function InitPlantTree(userlist_)
	local num = AccountManager:getMyWorldList():getNumWorld();
	for t=1, num do
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(t-1);
		if worldInfo and (worldInfo.fromowid == 1752346657768 or worldInfo.worldid == 1752346657768) and CurWorld:getOWID()==worldInfo.worldid then
			local datanum = #userlist_;
			Log('datanum='..datanum);
			local num = DefMgr:getPlantTreesNum();
			if datanum < num then
				num = datanum;
			end
			for i = 1, num do
				local platTreesDef = DefMgr:getPlantTreesDef(i - 1);
				user_ = userlist_[i];
				local inputstr = user_.nickname..' '..GetS(359)..user_.uin..' '..GetS(9079)..user_.txt;
				Log('inputstr='..inputstr);
				if ClientCurGame:SetSigns(inputstr, platTreesDef.x , platTreesDef.y, platTreesDef.z) == true then
					
				else
					for j = 1, 3 do
						for m = -1, 1 do
							for n = -1, 1 do
									if ClientCurGame:SetSigns(inputstr, platTreesDef.x + m, platTreesDef.y - j + 1, platTreesDef.z + n) == true then
										break;
									end
							end
						end
					end
				end
			end
			return;
		end
	end
end