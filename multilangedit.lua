local CurrentLang;
local t_lang = {}
local langName = {}
local originaltext;
local pre_langbtn;
local MAX_WORD_COUNT = 0;
local save_dirty = false;
local t_datastruct;
--t_lang = {
--	id 	 = xxx,		语言对应id
--	name = xxx,		语言对应名称
--	text = xxx,		语言对应文本
--}


function MultiLangEditFrame_OnLoad( ... )
	local plane 	= "MultiLangEditFrameTabsBoxPlane"
	local btn 		= "MultiLangEditFrameTabsBoxLang"
	local num 		= 14
	
	for i=1, num do
		getglobal(btn..i):SetPoint("top",plane,"top",-8,10+75*(i-1))
	end

	for i=1,16 do
		table.insert(langName,GetS(2040+i))
	end
end

function MultiLangEditFrame_OnShow( ... )
	--if ClientCurGame:isInGame() then
	--	if not getglobal("MultiLangEditFrame"):IsReshow() then
    --	    ClientCurGame:setOperateUI(true)
   	-- 	end
   	--end
end

function MultiLangEditFrame_OnHide( ... )
	getglobal("MultiLangEditFrameMainSrcBoxEdit"):Clear()
	getglobal("MultiLangEditFrameMainDesBoxEdit"):Clear()
	--if ClientCurGame:isInGame() then
	--	if not getglobal("MultiLangEditFrame"):IsRehide() then
	--		ClientCurGame:setOperateUI(false);
	--	end
	--end
end

function MultiLangEditFrame_OnUpdate( ... )
	

end

function TranslateAllConfirmFrame_OnShow( ... )
	getglobal("TranslateAllConfirmFrameDesc"):SetText(GetS(21646),55,54,49)
	getglobal("TranslateAllConfirmFrameLeftBtnName"):SetText(GetS(21689))
	getglobal("TranslateAllConfirmFrameRightBtnName"):SetText(GetS(21688))

end

function MultiLangEditFrameCloseBtn_OnClick( ... )
	local dirty = false;
	if originaltext ~= getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText() then
		--ShowGameTips("1111")
		dirty = true
	else
		for i=1,#(t_lang) do
			local idx = t_lang[i].id;
			if t_datastruct["textList"][tostring(idx)] == nil then
				if t_lang[i].text ~= "" then
					dirty = true;
					break;
				end
			else
				if t_datastruct["textList"][tostring(idx)] ~= t_lang[i].text then
					dirty = true;
					break;
				end
			end
		end
	end


	if dirty == true then
		MessageBox(5, GetS(21693), function(btn)
			if btn == 'left' then
				getglobal("MultiLangEditFrame"):Hide()
				getglobal("MultiLangEditFrameMainDesBoxEdit"):Clear()
			else

			end
		end)
	else
		getglobal("MultiLangEditFrame"):Hide()
		getglobal("MultiLangEditFrameMainDesBoxEdit"):Clear()
	end
	
end

function MultiLangEditFrameTranslateAllBtn_OnClick( ... )
	for i=1,#(t_lang) do
		if t_lang[i].text~="" then
			getglobal("TranslateAllConfirmFrame"):Show()
			return;
		end
	end
	TranslateAllConfirmFrameRightBtn_OnClick()
	
end

function MultiLangEditFrameTranslateBtn_OnClick( ... )
	--print("srrc",get_game_lang_str())
	local srctext = getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText()
	local targettext = getglobal("MultiLangEditFrameMainDesBoxEdit")
	if t_lang[pre_langbtn].text ~= "" then
		MessageBox(31, GetS(21646), function(btn)
			if btn == 'left' then			
			else
				ShowTranslatingTips(true)
				local translatedText = Google_Language_Translate(srctext,get_game_lang_str(t_lang[pre_langbtn].id),get_game_lang_str())
				ShowTranslatingTips(false)
				if translatedText~="" then
					ShowGameTips(GetS(21691))
					targettext:SetText(translatedText)
					t_lang[pre_langbtn].text = translatedText
				else
					ShowGameTips(GetS(21692))
				end
			end
		end)
	else
		ShowTranslatingTips(true)
		local translatedText = Google_Language_Translate(srctext,get_game_lang_str(t_lang[pre_langbtn].id),get_game_lang_str())
		ShowTranslatingTips(false)
		if translatedText~="" then
			ShowGameTips(GetS(21691))
			targettext:SetText(translatedText)
			t_lang[pre_langbtn].text = translatedText
		else
			ShowGameTips(GetS(21692))
		end
	end

end

--SelectArchiveIndex只表示高亮的存档，不能用于地图分享那里
function SaveTranslatedResult(srctext)
	for i=1,#(t_lang) do
		t_datastruct["textList"][tostring(t_lang[i].id)] = ReplaceFilterString(t_lang[i].text)
	end
	t_datastruct["textList"][tostring(get_game_lang())] = ReplaceFilterString(srctext)
	SignManagerGetInstance():SetTextJsonTranslated(t_datastruct);
	getglobal("MultiLangEditFrame"):Hide()
	getglobal("MultiLangEditFrameMainDesBoxEdit"):Clear()
	save_dirty = false;

	local strType = SignManagerGetInstance().data.strType;
	local worldid = 0;
	local wdesc;
	if ClientCurGame:isInGame() then
		wdesc = AccountManager:getCurWorldDesc()
	else
		local archiveData = GetOneArchiveData(SelectArchiveIndex);
		if strType == "mapshare_name" or strType == "mapshare_desc" then
			archiveData = GetOneArchiveData(Translate_ArchiveIndex);
		end
		if archiveData == nil then return end
		wdesc = archiveData.info
	end
	if wdesc then worldid = wdesc.worldid end
	ShowTranslateTextState(strType, worldid);


end

function MultiLangEditFrameSaveBtn_OnClick( ... )
	local text = getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText()
	if save_dirty == true then
		MessageBox(31, GetS(21657), function(btn)
			if btn == 'left' then
				SaveTranslatedResult(text)			
			else
				local state = true;
				if srctext ~= "" then
					ShowTranslatingTips(true)
					for i=1,#(t_lang) do
						local translatedText = Google_Language_Translate(text,get_game_lang_str(t_lang[i].id),get_game_lang_str())
						if translatedText~="" then
							t_lang[i].text = translatedText
						else
							state = false;
						end
					end
					ShowTranslatingTips(false)
				else
					for i=1,#(t_lang) do
						t_lang[i].text = ""
					end
				end
				if state == true then
					ShowGameTips(GetS(21691))
				else
					ShowGameTips(GetS(21692))
				end
				SaveTranslatedResult(text)
			end
		end)
	else
		SaveTranslatedResult(text)
	end
	

end

function TranslateAllConfirmFrameCloseBtn_OnClick( ... )
	getglobal("TranslateAllConfirmFrame"):Hide()
end

function TranslateAllConfirmFrameLeftBtn_OnClick( ... )
	getglobal("TranslateAllConfirmFrame"):Hide()
	local srctext = getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText()
	local state = true
	if srctext ~= "" then
		ShowTranslatingTips(true)
		for i=1,#(t_lang) do
			if t_lang[i].text == "" then
				local translatedText = Google_Language_Translate(srctext,get_game_lang_str(t_lang[i].id),get_game_lang_str())
				if translatedText~="" then
					--targettext:SetText(translatedText)
					t_lang[i].text = translatedText
				else
					state = false;
				end
			end
		end
		ShowTranslatingTips(false)
	end
	if state == true then
		ShowGameTips(GetS(21691))
	else
		ShowGameTips(GetS(21692))
	end


	getglobal("MultiLangEditFrameMainDesBoxEdit"):SetText(t_lang[pre_langbtn].text)

	--检测空缺/超过限制
	for i=1,#(t_lang) do
		if t_lang[i].text == "" or #(t_lang[i].text) > MAX_WORD_COUNT then
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Show();
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Show();
		else
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Hide();
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Hide();
		end
	end
	save_dirty = false
	getglobal("TranslateAllConfirmFrame"):Hide()
end

function ShowTranslatingTips(state)
	getglobal("MultiLangEditFrameTabsBox"):setDealMsg(not state)
	getglobal("MultiLangEditFrameMainSrcBox"):setDealMsg(not state)
	getglobal("MultiLangEditFrameMainDesBox"):setDealMsg(not state)
	if state == true then
		getglobal("TranslatingTipsFrame"):Show()
	else
		getglobal("TranslatingTipsFrame"):Hide()
	end

end

function TranslateAllConfirmFrameRightBtn_OnClick( ... )
	getglobal("TranslateAllConfirmFrame"):Hide()
	local srctext = getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText()
	local state = true
	if srctext ~= "" then
		ShowTranslatingTips(true)
		for i=1,#(t_lang) do
			local translatedText = Google_Language_Translate(srctext,get_game_lang_str(t_lang[i].id),get_game_lang_str())
			if translatedText~="" then
				--targettext:SetText(translatedText)
				t_lang[i].text = translatedText
			else
				state = false
			end	
		end
		ShowTranslatingTips(false)
	else
		for i=1,#(t_lang) do
			t_lang[i].text = ""
		end
	end
	getglobal("MultiLangEditFrameMainDesBoxEdit"):SetText(t_lang[pre_langbtn].text)

	if state == true then
		ShowGameTips(GetS(21691))
	else
		ShowGameTips(GetS(21692))
	end

	--检测空缺/超过限制
	for i=1,#(t_lang) do
		if t_lang[i].text == "" or #(t_lang[i].text) > MAX_WORD_COUNT then
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Show();
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Show();
		else
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Hide();
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Hide();
		end
	end
	save_dirty = false;
	getglobal("TranslateAllConfirmFrame"):Hide()
end


function LangEditBtnTemplate_OnClick( ... )

	local name = this:GetName()
	--print("name:",name,pre_langbtn)
	local idx = this:GetClientID()
	local btn = "MultiLangEditFrameTabsBoxLang"
	getglobal(name.."Normal"):Hide()
	getglobal(name.."Checked"):Show()
	if pre_langbtn ~= nil then
		if btn..pre_langbtn ~= name then
			getglobal(btn..pre_langbtn.."Normal"):Show()
			getglobal(btn..pre_langbtn.."Checked"):Hide()
		end
	end
	getglobal("MultiLangEditFrameMainDesTitle"):SetText(GetS(21654, langName[t_lang[idx].id+1]))
	getglobal("MultiLangEditFrameMainDesBoxEdit"):SetText(t_lang[idx].text)
	CurrentLang = t_lang[idx].id
	pre_langbtn = idx

end

--点击翻译按钮，打开编辑界面...后续有必要的话，传worldid进来获取worlddesc
function OpenMultiLangEdit(datastruct, size, worldid)
	--getglobal("MultiLangEditFrameMainSrcBoxEdit"):SetSliderValue(2)
	MAX_WORD_COUNT = size
	Log("OpenMultiLangEdit:datastruct:")
	
	local WORD = 0;
	if ClientCurGame:isInGame() then
		WORD = AccountManager:getWorldSupportLang()	--信纸、留言板
	else
		if worldid then
			WORD = AccountManager:getWorldSupportLang(worldid)
		else
			local archiveData = GetOneArchiveData(SelectArchiveIndex);
			if archiveData == nil then
				return;
			end

			local wdesc = archiveData.info;			--插件库、分享
			if wdesc == nil then
				return;
			end

			WORD = AccountManager:getWorldSupportLang(wdesc.worldid)
		end
	end

	--print("current map lang:",WORD)
	originaltext =datastruct["textList"][tostring(get_game_lang())]
	t_lang = {}
	for i=0, 15 do
		if LuaInterface:band(WORD, math.pow(2, i))==math.pow(2, i) and i~=get_game_lang() then
			if i<=2 then
				table.insert(t_lang,{id=i,name=GetS(3495+i),text=""})
			else
				table.insert(t_lang,{id=i,name=GetS(975-3+i),text=""})
			end
		end
	end
	if #(t_lang)==0 then
		--ShowGameTips("请先设置支持的语言版本", 3);
		return
	end

	
	t_datastruct = datastruct;
	local btn = "MultiLangEditFrameTabsBoxLang"
	for i=1,#(t_lang) do
		getglobal(btn..i.."Title"):SetText(t_lang[i].name)
		local id = t_lang[i].id
		if datastruct.textList[tostring(id)] and datastruct.textList[tostring(id)]~="" then
			t_lang[i].text = datastruct.textList[tostring(id)]
		end
		--getglobal(btn..i):SetClientID(t_lang[i].id)
		getglobal(btn..i):Show()
		--if t_lang[i].text ~= "" and #(t_lang[i].text)<MAX_WORD_COUNT then
		--	getglobal(btn..i.."Icon"):Hide()
		--	ShowGameTips(tostring(t_lang[i].id).."XXX")
		--	ShowGameTips(tostring(i).."xxx")
		--else
		--	getglobal(btn..i.."Icon"):Show()
		--	ShowGameTips(tostring(t_lang[i].id).."YYY")
		--	ShowGameTips(tostring(i).."yyy")
		--end
		
	end

	for i=1,#(t_lang) do
		if t_lang[i].text==nil or  t_lang[i].text == "" or #(t_lang[i].text) > MAX_WORD_COUNT then
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Show()
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Show()
			--ShowGameTips(tostring(t_lang[i].name).."YYY")
			--ShowGameTips(tostring(i).."yyy")
		else
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Hide()
			getglobal("MultiLangEditFrameTabsBoxLang"..i.."IconBkg"):Hide()
			--ShowGameTips(tostring(t_lang[i].name).."XXX")
			--ShowGameTips(tostring(i).."xxx")
		end
	end
	for i= #(t_lang) + 1, 14 do
		getglobal(btn..i):Hide()
	end
	local height	 =10+75 * #(t_lang) - 5 
	if height < 480 then
		height = 480
		--getglobal("MultiLangEditFrameTabsBox"):setSlidingY(false)
		getglobal("MultiLangEditFrameTabsSlideBkg"):Hide()
	else
		--getglobal("MultiLangEditFrameTabsBox"):setSlidingY(true)
		getglobal("MultiLangEditFrameTabsSlideBkg"):Show()
	end
	getglobal("MultiLangEditFrameTabsBoxPlane"):SetHeight(height)

	Log("t_lang")
	
	--文本显示
	

	local main = "MultiLangEditFrameMain"
	getglobal(main.."SrcTitle"):SetText(GetS(21653, langName[get_game_lang()+1]))
	--初始化当前译文语言
	if CurrentLang == nil and #(t_lang)>0 then
		CurrentLang = t_lang[1].id
		getglobal("MultiLangEditFrameTabsBoxLang1Normal"):Hide()
		getglobal("MultiLangEditFrameTabsBoxLang1Checked"):Show()
		pre_langbtn = 1
	end
	if pre_langbtn > #(t_lang) then
		pre_langbtn=1
	end
	print("CurrentLang:",CurrentLang)
	getglobal(main.."DesTitle"):SetText(GetS(21654,langName[CurrentLang+1]))
	--getglobal(main.."SrcBoxEdit"):Clear()
	getglobal(main.."SrcBoxEdit"):setMaxChar(size)
	getglobal(main.."SrcBoxEdit"):SetText(originaltext)
	getglobal(main.."DesBoxEdit"):setMaxChar(size + 100)
	if t_lang[pre_langbtn].text ~= "" then
		getglobal(main.."DesBoxEdit"):SetText(t_lang[pre_langbtn].text)
	end

	getglobal("MultiLangEditFrame"):Show();
	getglobal(main.."DesBoxEdit"):setDrawOtherColor(true,MAX_WORD_COUNT,224,69,31)

end

function MultiLangEditFrameMainSrcBoxEdit_OnUpdate( ... )
	local main = "MultiLangEditFrameMain"
	local height = getglobal(main.."SrcBoxEdit"):getCurLineHeight();
	if height > 0 then
		if height +64 > 200 then
			--getglobal(main.."SrcBox"):setSlidingY(true)
			--getglobal(main.."SrcBoxPlane"):SetHeight(height+64)
			getglobal(main.."SrcBoxEdit"):SetHeight(height+64)
			getglobal("MultiLangEditFrameMainSlideBkg"):Show()
		else
			--getglobal(main.."SrcBoxPlane"):SetHeight(200)
			--getglobal(main.."SrcBox"):setSlidingY(false)
			getglobal(main.."SrcBoxEdit"):SetHeight(200)
			getglobal("MultiLangEditFrameMainSlideBkg"):Hide()
		end
	else
		getglobal(main.."SrcBoxEdit"):SetHeight(200)
		getglobal("MultiLangEditFrameMainSlideBkg"):Hide()
	end
end

function MultiLangEditFrameMainDesBoxEdit_OnUpdate( ... )
	local main = "MultiLangEditFrameMain"
	local height = getglobal(main.."DesBoxEdit"):getCurLineHeight();

	if height > 0 then
		if height + 64 > 200 then
			--getglobal(main.."DesBox"):setSlidingY(true)
			getglobal(main.."DesBoxEdit"):SetHeight(height+64)
			--getglobal(main.."DesBoxPlane"):SetHeight(height+64)
			getglobal("MultiLangEditFrameMainSlideBkg1"):Show()
		else
			--getglobal(main.."DesBoxPlane"):SetHeight(200)
			--getglobal(main.."DesBox"):setSlidingY(false)
			getglobal(main.."DesBoxEdit"):SetHeight(200)
			getglobal("MultiLangEditFrameMainSlideBkg1"):Hide()
		end
	else
		--getglobal(main.."DesBoxPlane"):SetHeight(200)
		getglobal(main.."DesBoxEdit"):SetHeight(200)
		getglobal("MultiLangEditFrameMainSlideBkg1"):Hide()
	end

	if getglobal(main.."DesBoxEdit"):GetText() == "" then
		getglobal(main.."DesTip"):Show()
		getglobal(main.."DesTip"):SetText(GetS(21656))
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."Icon"):Show();
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."IconBkg"):Show();
	elseif #(getglobal(main.."DesBoxEdit"):GetText()) > MAX_WORD_COUNT then
		getglobal(main.."DesTip"):Show()
		getglobal(main.."DesTip"):SetText(GetS(21655))
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."Icon"):Show();
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."IconBkg"):Show();
	else
		getglobal(main.."DesTip"):Hide()
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."Icon"):Hide();
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."IconBkg"):Hide();
	end

	--if getglobal(main.."DesBoxEdit"):GetText == "" then
	--	getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Show()
	--else
	--	getglobal("MultiLangEditFrameTabsBoxLang"..i.."Icon"):Hide()
	--end
	--t_lang[pre_langbtn].text = getglobal("MultiLangEditFrameMainDesBoxEdit"):GetText()
end

function ClearMultiLangEdit( ... )
	if CurrentLang ~= nil then
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."Checked"):Hide()
		getglobal("MultiLangEditFrameTabsBoxLang"..pre_langbtn.."Normal"):Show()
		CurrentLang = nil
	end
end

function MultiLangSrcTextEdit_OnFocusLost( ... )
	--local text = ReplaceFilterString(getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText())
	--getglobal("MultiLangEditFrameMainSrcBoxEdit"):SetText(text)
	if originaltext ~= getglobal("MultiLangEditFrameMainSrcBoxEdit"):GetText() then
		save_dirty = true;
	else
		save_dirty = false;
	end
end

function MultiLangDesTextEdit_OnFocusLost( ... )
	--local text = ReplaceFilterString(getglobal("MultiLangEditFrameMainDesBoxEdit"):GetText())
	t_lang[pre_langbtn].text = getglobal("MultiLangEditFrameMainDesBoxEdit"):GetText()
	--getglobal("MultiLangEditFrameMainDesBoxEdit"):SetText(text)
end