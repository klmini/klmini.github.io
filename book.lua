BookInfo = {
	Uin = 0;
	Name = "";
	Author = "";
	PageIndex = 0; --当前所在页索引 0=封面
    PagesNum = 0;
	Content = {
        --[[ [1] = {
                "Uin" = 1001,         作者uin
                "Author" = "张三",    作者名
                "Synopsis" = "",      简介
                "Title" = "三记",     章节名
                "Child" = false,      是否子页  每章可能有多页
                "Content" = "你好啊",  内容
            }
        ]]
	};

    SetPageIndex = function(self, index)
        self.PageIndex = index;
    end;

    GetPageIndex = function(self)
        return self.PageIndex;
    end;

    SetPagesNum = function(self, num)
        self.PagesNum = num;
    end;

    GetPagesNum = function(self)
        return self.PagesNum;
    end;

    GetContent = function(self, pageIndex)
    	if pageIndex and pageIndex > 0 and pageIndex <= self.PagesNum then
    		return self.Content[pageIndex];
    	end
    end;
}

function BookFrame_OnShow()
    if not getglobal("BookFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true);
    end

    getglobal("BookFrameCover"):Show();
    getglobal("BookFrameContent"):Hide();
end

function BookFrameCloseBtn_OnClick()
    if not getglobal("BookFrame"):IsReshow() then
        ClientCurGame:setOperateUI(false);
    end

    getglobal("BookFrame"):Hide();
    ShowMainFrame();
end

function BookCoverFrame_OnShow()
    local grid = CurMainPlayer:getBackPack():index2Grid(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex())
    local str = grid:getUserdataStr()

    if string.len(str) > 0 then
        ParseBookInfo(str);
        UpBookCover();
        HideAllFrame("PaletteFrame", true);
    else
        BookFrameCloseBtn_OnClick();
    end
end

function BookCoverFrame_OnHide()
    BookInfo:SetPageIndex(0);
end

function BookCoverFrame_OnClick()
    BookFrameCloseBtn_OnClick();
end

function BookCoverFrameOpenBtn_OnClick()
    if BookInfo:GetPagesNum() > 1 then
    	getglobal("BookFrameCover"):Hide();
    	getglobal("BookFrameContent"):Show();

        BookInfo:SetPageIndex(1);
        UpBookCentent();
    end
end

--书内容 截取分页
function BookSubContent(str, num)
   local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + byteCount
        
        if num <= count then
            break
        end
    end

    return string.sub(str, 1, i-1), string.sub(str, i);
end

--解析书 信息
function ParseBookInfo(strjson)
    print("ParseBookInfo")
	BookInfo.Uin = 0;
	BookInfo.Name = "";
	BookInfo.Author = "";
	BookInfo.PageIndex = 0;
    BookInfo.Synopsis = "";
	BookInfo.Content = nil;
	BookInfo.Content = {};

	local bookTab = JSON:decode(strjson);
	if bookTab and type(bookTab) == "table" then
		if bookTab.uin then
			BookInfo.Uin = tonumber(bookTab.uin);
		end

        --书 增加多语言
        local lang = get_game_lang()
        if bookTab.multiLangName and bookTab.multiLangName ~= "" then
            bookTab.multiLangName = JSON:decode(bookTab.multiLangName)
            if bookTab.multiLangName.originalID and lang ~= bookTab.multiLangName.originalID and bookTab.multiLangName.textList[tostring(lang)] then
                bookTab.title = bookTab.multiLangName.textList[tostring(lang)]
            end
        end

		if bookTab.title then 
			BookInfo.Name = tostring(bookTab.title);
		end

        if bookTab.multiLangDetails and bookTab.multiLangDetails ~= "" then
            bookTab.multiLangDetails = JSON:decode(bookTab.multiLangDetails)
            if bookTab.multiLangDetails.originalID and lang ~= bookTab.multiLangDetails.originalID and bookTab.multiLangDetails.textList[tostring(lang)] then
                bookTab.context = bookTab.multiLangDetails.textList[tostring(lang)]
            end
        end

        if bookTab.context then
            BookInfo.Synopsis = tostring(bookTab.context);
        end

        if bookTab.multiLangEditor and bookTab.multiLangEditor ~= "" then
            bookTab.multiLangEditor = JSON:decode(bookTab.multiLangEditor)
            if bookTab.multiLangEditor.originalID and lang ~= bookTab.multiLangEditor.originalID and bookTab.multiLangEditor.textList[tostring(lang)] then
                bookTab.authorname = bookTab.multiLangEditor.textList[tostring(lang)]
            end
        end

		if bookTab.authorname then
			BookInfo.Author = tostring(bookTab.authorname);
		end
        local function DealShowText(mult,text,lan)
            local result = "";
            if mult and mult.originalID and
                 mult.originalID ~= lan and mult.textList[tostring(lan)] then
                result = mult.textList[tostring(lan)]
             else
                result = text;
            end
            return result
        end
		if bookTab.letters and type(bookTab.letters) == "table" then
            local pageNum = 0;
            local i = 1;
            local lang = get_game_lang()
			for i=1, #bookTab.letters do
				local ltsTab = bookTab.letters[i];
				local ltsTba = strjson;
				if ltsTab and type(ltsTab) == "table" then
					local letters = {};
					if ltsTab.uin then
                        letters["Uin"] = ltsTab.uin;
                    end

                    if ltsTab.authorname then
                        letters["Author"] = ltsTab.authorname;
                    end
                    local changetime = 0
                    if ltsTab.changetime then
                        changetime = ltsTab.changetime
                    end
                    local enableshow = CheckEnableShow(changetime);
                    if ltsTab.title then
                        if enableshow then
                            letters["Title"] = DealShowText(ltsTab.titleMul,ltsTab.title,lang)
                            --[[if ltsTab.titleMul and ltsTab.titleMul.originalID 
                            and ltsTab.titleMul.originalID ~= lang and ltsTab.titleMul.textList[tostring(lang)] then
                                letters["Title"] = ltsTab.titleMul.textList[tostring(lang)]
                            else
                                letters["Title"] = ltsTab.title;
                             end]]
                        else
                            if ltsTab.oldtitle then
                                if ltsTab.oldtitle ~="" then
                                    letters["Title"] = DealShowText(ltsTab.titleMul,ltsTab.oldtitle,lang)
                                else
                                    letters["Title"] = "";
                                end
                            else
                                letters["Title"] = "";
                            end
                           
                        end
                       
                    end

                    letters["Child"] = false;
                    pageNum = pageNum + 1;
                    local tempStr = "";
                    if enableshow then 
                        tempStr = ltsTab.context;
                        tempStr =  DealShowText(ltsTab.contextMul,tempStr,lang)
                        
                    else
                        if ltsTab.oldcontext then
                            if ltsTab.oldcontext ~="" then
                                tempStr = DealShowText(ltsTab.contextMul,ltsTab.oldcontext,lang)
                            else
                                tempStr = GetS(321000);
                            end
                        else
                            tempStr = GetS(321000);
                        end
                    end
                    local lineNum = 15;
                    local contentStr = "";
                    local contentObj = getglobal("BookFrameContentPageType1Content");
                	while(true)
                	do
                        local len = contentObj:GetTextExtentFitInWidth(tempStr, 480*lineNum, true, lineNum);
                        contentStr, tempStr = BookSubContent(tempStr, len);
                        letters["Content"] = contentStr;
                		BookInfo.Content[pageNum] = deep_copy_table(letters);

                        if string.len(tempStr) > 0 then
                			pageNum = pageNum + 1;
                            letters["Child"] = true;
                		else
                			break;
                		end
                    end
				end
			end
            BookInfo:SetPagesNum(pageNum);
		end
	end
end

--刷新书封面ui
function UpBookCover()
    local titleObj = getglobal("BookFrameCoverTitle");
    --local titleObj2 = getglobal("BookCoverFrameTitle2");
    local authorObj = getglobal("BookFrameCoverAuthor");

    if BookInfo.Name then
        -- if titleObj1:GetTextExtentWidth(BookInfo.Name) > 400 then
        --     titleObj1:Hide();
        --     titleObj2:Show();
        --     titleObj2:SetText(BookInfo.Name);
        -- else
            -- titleObj2:Hide();
            titleObj:Show();
            DefMgr:filterStringDirect(BookInfo.Name);
            titleObj:SetText(BookInfo.Name);
        -- end
    end

    if BookInfo.Author then
        authorObj:Show();
        DefMgr:filterStringDirect(BookInfo.Author);
        authorObj:SetText(BookInfo.Author);
    end
end

function BookContentFrameCloseBtn_OnClick()
	BookFrameCloseBtn_OnClick();
end

function BookContentFrameLeftBtn_OnClick()
    local pageIndex = BookInfo:GetPageIndex();
    if pageIndex > 1 then
        pageIndex = pageIndex - 1;
        BookInfo:SetPageIndex(pageIndex);
        UpBookCentent();
    end
end

function BookContentFrameRightBtn_OnClick()
    local pageIndex = BookInfo:GetPageIndex();
    if pageIndex < BookInfo:GetPagesNum() then
        pageIndex = pageIndex + 1;
        BookInfo:SetPageIndex(pageIndex);
        UpBookCentent();
    else
        ShowGameTips(GetS(21697));
    end
end

function UpBookCentent()
    getglobal("BookFrameContentPage"):SetText(GetS(21683, BookInfo:GetPageIndex(), BookInfo:GetPagesNum()));
    local pageIndex = BookInfo:GetPageIndex();
    local content = BookInfo:GetContent(pageIndex);

    if content then
        local pageType1 = getglobal("BookFrameContentPageType1");
        local pageType2 = getglobal("BookFrameContentPageType2");
        local pageType3 = getglobal("BookFrameContentPageType3");

        if content.Child then
            pageType1:Hide();
            pageType2:Show();
            pageType3:Hide();

            if content.Content then
                getglobal("BookFrameContentPageType2Content"):SetText(content.Content);
            end
        else
            DefMgr:filterStringDirect(content.Content);
            if content.Title and string.len(content.Title) > 0 then
                pageType1:Show();
                pageType2:Hide();
                pageType3:Hide();

                local titleObj1 = getglobal("BookFrameContentPageType1Title1");
                local titleObj2 = getglobal("BookFrameContentPageType1Title2");

                DefMgr:filterStringDirect(content.Title);
                if titleObj1:GetTextExtentWidth(content.Title) > titleObj1:GetWidth() then
                    titleObj1:Hide();
                    titleObj2:Show();
                    titleObj2:SetText(content.Title);
                else
                    titleObj2:Hide();
                    titleObj1:Show();
                    titleObj1:SetText(content.Title);
                end
                getglobal("BookFrameContentPageType1Author"):SetText(content.Author);
                getglobal("BookFrameContentPageType1Content"):SetText(content.Content);
            else
                pageType1:Hide();
                pageType2:Hide();
                pageType3:Show();

                getglobal("BookFrameContentPageType3Author"):SetText(content.Author);
                getglobal("BookFrameContentPageType3Content"):SetText(content.Content);
            end
        end 
    end
end