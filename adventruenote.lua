
--------------------------------------数据-----------------------------------------
local curTaskIndex = 1;
local npcTaskListNum = 18;
local npcTaskFrameName=nil;
local curTaskID = -1;
local curPlotId = -1;
local npcT_showType =-1 ;  --1:接受任务，2：交付任务


npcTaskData = {
	
	task = {},
	tasksIdTable={},

	taskNum = 0,

	currentTaskInfo =function() 
		local taskInfo= CurMainPlayer:getTaskInfo(curTaskID);
		if taskInfo==nil then 
			Log("task info is nil :currentTaskInfo =function() ")
			return nil ;
		else
			return taskInfo;
		end
	end,

	currentTaskDef =function() 
		local taskDef =DefMgr:getNpcTaskDef(curTaskID);
		if taskDef==nil then 
			Log("task def is nil :currentTaskDef =function() ");
			return nil;
		else
			return taskDef;
		end
	end,

	Init = function ()
		npcTaskData.Reset();

		local taskInfoNum = CurMainPlayer:getTaskNum();
		if taskInfoNum ==nil then 
			Log("get task number is fail");
			return;
		end

		local index =0;
		
		for i= 0 ,taskInfoNum-1 do 
			local taskID = 0;
			local taskInfo=nil;
			local taskDef=nil;

			taskInfo,taskID = CurMainPlayer:getTaskInfoByIndex(i,taskID);
			taskDef =DefMgr:getNpcTaskDef(taskID);
			if taskInfo ==nil or taskID ==nil or taskDef==nil  then
				Log("init taskInfo or taskID or taskDef fail :Init = function ()");
				return;
			end

			if taskDef.ShowInNote==true and taskInfo.state~=2 then 
				index = index +1;
				npcTaskData.tasksIdTable[index] = taskID;
				npcTaskData.SetTask(index,taskInfo);
			
			end
		end

		if index ~= 0 then 
			npcTaskData.SetNum(index);
		end

	end,

	GetNum = function ()
		if npcTaskData.taskNum == nil then 
			Log("NPC TASK data num is null")
			return
		end

		return npcTaskData.taskNum;
	end,

	GetTask = function ()
		if npcTaskData.task == nil then
			Log("npc Task Data is null");
		 	return 
		end 

		return npcTaskData.task

	end,

	GetTaskIDByIndex = function (taskIndex)

		local id = npcTaskData.tasksIdTable[taskIndex];
		if id ==nil then Log(" GetTaskIDByIndex task id is nil "); return;end
		return id;
	end,

	GetTaskDefByIndex = function (index)
		local id = npcTaskData.tasksIdTable[index];
		if id ==nil then Log(" task id is nil "); return;end

		local taskDef = DefMgr:getNpcTaskDef(id);
		if taskDef ==nil then Log("get task def fail "); return end

		return taskDef;
	end,

	GetTaskById =function (id)
		if id == nil or npcTaskData.task== nil then return end 
		for i =1 , npcTaskData.GetNum() do 
			if i == id then 
				return npcTaskData.task[i] ;
			end
		end
		Log(" npc task by id is nil ");
		return nil;
	end,

	SetNum = function (num)
		if num == nil then return end
		npcTaskData.taskNum = num;
	end,

	SetTask = function (index,list)
		if index == nil or list== nil then return end 

		npcTaskData.task[index]=list;
	end,

	Reset = function ()
		npcTaskData.taskNum=0;
		npcTaskData.task={};
		npcTaskData.tasksIdTable={};
	end,

}


-------------------------------------界面------------------------------------------
function AdventureNoteFrame_OnShow()--冒险笔记界面显示
	--标题栏
	getglobal("AdventureNoteFrameTitleFrameName"):SetText(GetS(11001));
	--血条地图等UI界面的显示与否成为了自定义ui功能的一部分，避免打开背包HideAllFrame中的操作写死其显隐性所以这里注释掉
	-- HideAllFrame("AdventureNoteFrame", true);
	
	if not getglobal("AdventureNoteFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	AdventrueNoteInitGata();
	getglobal("AdventureNoteFrameTaskList"):Show();
	getglobal("TaskDetailFrame"):Show();
end

function AdventureNoteFrame_OnHide( ... )--冒险笔记界面隐藏
	
	-- ShowMainFrame();

	if not getglobal("AdventureNoteFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function AdventureNoteFrame_TaskDelete() -- 单个任务删除方法
	
	-- 1. TODO先对数据进行操作
	-- 2.界面刷新
	MessageBox(5, GetS(11089),function(btn)
		if btn == 'left' then
			ShowTaskDetail_DeleteBtnCb();
		end
	end);
end

function TaskDetailFrame_OnShow() -- 具体任务内容界面显示方法
	ShowTaskDetail()
end

function AdventureNoteFrameTaskBtn() -- 任务列表单个任务点击方法
	--- 1 操作数据
	--- 2 重新显示数据
	
	curTaskIndex = this:GetClientID();
	curTaskID= npcTaskData.GetTaskIDByIndex(curTaskIndex);

	if curTaskID ==nil then return end;

	getglobal("AdventureNoteFrameTaskList"):Show();
	getglobal("TaskDetailFrame"):Show();
end

function AdventureNoteFrameTaskList_OnShow() --任务列表显示方法
	AN_TaskListLayout() -- 布局方法
	AN_TaskListCheckState()
	AN_TaskListShowDetail() -- 任务列表按钮内容显示
	
end

function AdventureNoteFrame_Close( ... ) --冒险笔记界面关闭按钮点击方法

	getglobal("AdventureNoteFrame"):Hide();
end

--------------------------------------界面逻辑--------------------------------------------

function AdventrueNoteInitGata() --数据初始化
	npcTaskData:Init();
	curTaskIndex =1;
	curTaskID= npcTaskData.GetTaskIDByIndex(curTaskIndex);
	getglobal("AdventureNoteFrameTaskListTaskBtn"..curTaskIndex):Checked();
end

function ShowTaskDetail_DeleteBtnCb()
	CurMainPlayer:removeTask(curTaskID);

	getglobal("AdventureNoteFrame"):Show();
	
end

function AN_TaskListLayout()
	local height = 0 ;
	local ui_frame = nil;

	local defNum = npcTaskData.GetNum();
	for i = 1, npcTaskListNum do 

		ui_frame = getglobal("AdventureNoteFrameTaskListTaskBtn"..i);
		if i <= defNum and defNum ~= nil and defNum ~= 0 then 
			ui_frame:SetPoint("top", "AdventureNoteFrameTaskListPlane", "top", 0, height);
			ui_frame:SetClientID(i);
			height = ui_frame:GetHeight() +height + 14;
			ui_frame:Show();
		else
			ui_frame:Hide();
		end

	end

	if height < 515 then
		height = 515;
	end
    
	getglobal("AdventureNoteFrameTaskListPlane"):SetHeight(height);
	
end

function AN_TaskListShowDetail()
	local taskNum =npcTaskData.GetNum();

	if taskNum ==nil or taskNum==0 then return end;

	for i = 1 ,taskNum do 

		local def = npcTaskData.GetTaskDefByIndex(i);

		local icon = getglobal("AdventureNoteFrameTaskListTaskBtn"..i.."Icon");
		local name = getglobal("AdventureNoteFrameTaskListTaskBtn"..i.."Name");
		if def==nil then
			getglobal("AdventureNoteFrameTaskListTaskBtn"..i):Hide();
			return;
		else
			local defName=ConvertDialogueStr(def.Name);
			defName = DefMgr:filterString(defName);
			if defName then
				name:SetText(defName);
			end
		end

		local TaskType;
		if def:getTaskContentDeNum()>0 then 
			TaskType= def:getTaskContentDef(0).Type;
		end
		if TaskType ==nil then Log("Task Type is Null"); end
		if def:getTaskContentDeNum()==0 then askType =0 ;end

		icon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");

		if TaskType ==0 or TaskType==nil then
			icon:SetTextureHuiresXml("ui/mobile/texture2/friend.xml");
			icon:SetTexUV("icon_chat")
		elseif TaskType==1 then
			icon:SetTexUV("icon_attack")
		elseif TaskType== 2 then
			icon:SetTexUV("icon_collect")
		end
	end
end


function  AN_TaskListCheckState()

	local defNum = npcTaskData.GetNum();
	if defNum==nil or defNum==0 then return end 
	for i=1,defNum do
		local ui_frame = getglobal("AdventureNoteFrameTaskListTaskBtn"..i);
		local ui_text = getglobal("AdventureNoteFrameTaskListTaskBtn"..i.."Name");

		if i ~= curTaskIndex then
			ui_frame:Enable();
			ui_frame:DisChecked();
		else 
			ui_frame:Disable();
		end
	end
end

function ShowTaskDetail()
	if curTaskIndex ==0 then Log("current task id is nil"); end

	if npcTaskData.GetNum() ==0 then 
		getglobal("AdventureNoteFrameNullBkg"):Show();
		getglobal("AdventureNoteFrameNullTitle"):Show();
		getglobal("TaskDetailFrame"):Hide();
		return;
	else
		getglobal("AdventureNoteFrameNullBkg"):Hide();
		getglobal("AdventureNoteFrameNullTitle"):Hide();
	end

	local ui_frame = getglobal("TaskDetailFrameTaskName");

	local def = npcTaskData.GetTaskDefByIndex(curTaskIndex);
	if def == nil then 
		getglobal("AdventureNoteFrameNullBkg"):Show();
		getglobal("AdventureNoteFrameNullTitle"):Show();
		getglobal("TaskDetailFrame"):Hide();
		ui_frame:Hide();
		return;
	else 
		-----任务名字
		local defName=ConvertDialogueStr(def.Name);
		defName = DefMgr:filterString(defName);
		if  defName then
			ui_frame:SetText(defName);
		end
	end

-----任务内容
	npcTaskFrameName="TaskDetailFrame";
	ShowTaskDetail_ContentShow();
	ShowTaskDetail_ScheduleShow();
	ShowTaskDetail_RewardShow();
	ShowTaskDetail_TargetShow()
end

function ShowTaskDetail_ContentShow()
	local def = npcTaskData.currentTaskDef();
	local InteractName = nil ;

	local ui_frame = getglobal(npcTaskFrameName.."TaskContent");
	ui_frame:Hide();

	if def ==nil then Log("def is nil :ShowTaskDetail_ContentShow()")  return  end;

	local num =  def:getTaskContentDeNum();
	if num == 0 then  Log("num is nil :ShowTaskDetail_ContentShow()")  end
	local content = nil;

	local ContentNum = nil;
	local ContentName = nil;
	Log("交互目标："..def.InteractID);
	if def.InteractID~=nil and def.InteractID~= 0 then
		local monsterDef = MonsterCsv:get(def.InteractID);
		if monsterDef then
			InteractName = monsterDef.Name;
			InteractName = ConvertDialogueStr(InteractName);
		end
		content=GetS(11209,InteractName).."。"
	end

	if num ~= 0 then
		if def:getTaskContentDef(0).Type ==1 then 
			content = GetS(11211).."：";
		elseif def:getTaskContentDef(0).Type==2 then
			content = GetS(11212).."：";
		end 

	
		for i = 0 ,num-1 do 
			local taskDef = def:getTaskContentDef(i);
			local id = taskDef.ID;

				ContentNum = taskDef.Num;
			if ContentNum ~= 0 then 
				if i~=0 then 
					content = content.."，";
				end
				if taskDef.Type == 1 then
					ContentName = MonsterCsv:get(id).Name;
					if ContentName~=nil then
						content = content ..ContentName.."x"..ContentNum;
					end
				elseif taskDef.Type == 2 then
					ContentName = ItemDefCsv:get(id).Name;
					if ContentName~=nil then
						content = content ..ContentName.."x"..ContentNum;
					end
				end
			end
			
		end

		taskDef = def:getTaskContentDef(0);
		if taskDef.Type~= 0 and def.IsDeliver == true then
			content = content .. GetS(11213,InteractName);
		elseif taskDef.Type == 0 and def.IsDeliver == false then
			content=GetS(11221)
		elseif taskDef==nil or taskDef.Type==0 then
			content=GetS(11209,InteractName).."。"
		end
	end


	if content ==nil  or content== "击败生物："or content == "收集道具：" then 
		Log("content is nil :ShowTaskDetail_ContentShow()");
		return;
	end

	content = DefMgr:filterString(content);
	ui_frame:SetText(content);
	ui_frame:Show();
end

function ShowTaskDetail_ScheduleShow()
	local task = npcTaskData.currentTaskInfo();
	local def = npcTaskData.currentTaskDef();

	local ui_frame = getglobal(npcTaskFrameName.."TaskSchedule");
	local ui_frame_tile = getglobal(npcTaskFrameName.."TaskScheduleTitle");
	ui_frame:Hide();
	ui_frame_tile:Hide();

	local content = nil;
	local curGetNum = 0; 

	local ContentNum = nil;
	local ContentName = nil;

	local num = def:getTaskContentDeNum();
	if num == 0 then return end
	local taskDef = def:getTaskContentDef(0);

	ui_frame_tile:Show();
	ui_frame:Show();

	if taskDef.Type ==0 or num == 0 then 
		ui_frame_tile:Hide();
		ui_frame:Hide();
		return;
	elseif taskDef.Type ==1 then 
		content = GetS(11215);
	elseif taskDef.Type ==2 then 
		content = GetS(11216);
	end

	-- 
	local id ;
	local indexComplete=0;
	local contentShowNum = 0;
	for i = 0 ,num-1 do 
		taskDef = def:getTaskContentDef(i);
		ContentNum = taskDef.Num;

		if ContentNum~=0 then 
			if task ==nil then
				curGetNum=0
			else
				curGetNum =task:getTaskContent(i).completednum;
			end

			taskDef = def:getTaskContentDef(i);
			id = taskDef.ID;

			if curGetNum>= ContentNum then
				indexComplete = indexComplete+1;
			end

			if i~=0 then 
				content = content.."、";
			end

			if taskDef.Type == 1 then
				ContentName = MonsterCsv:get(id).Name;
				if ContentName~=nil then
					content = content ..ContentName.." "..curGetNum.."/"..ContentNum;
					contentShowNum=contentShowNum+1;
				end
			elseif taskDef.Type == 2 then
				ContentName = ItemDefCsv:get(id).Name;
				if ContentName~=nil then
					content = content .. ContentName.." "..curGetNum.."/"..ContentNum;
					contentShowNum=contentShowNum+1;
				end
			end
		end
	end

	if content ==nil  or content==  "击败：" or content == "收集：" then 
		Log("content is nil :ShowTaskDetail_ScheduleShow()");
		return;
	end

	if indexComplete >= contentShowNum and contentShowNum~=0 then 
		ui_frame:SetText(content);
		ui_frame:SetTextColor(0, 128, 0);
		ui_frame_tile:SetTextColor(0, 128, 0);
	else 
		ui_frame:SetText(content);
		ui_frame:SetTextColor(61, 69, 70);
		ui_frame_tile:SetTextColor(61, 69, 70);
	end
	ui_frame:Show();
end

function ShowTaskDetail_RewardShow()
	local def = npcTaskData.currentTaskDef();
	local rewardDef = nil; 
	local rewardNum = 0; 

	local ui_frame = nil;
	local ui_text = nil;

	ui_frame=getglobal("NpcTaskFrameDetailRewardTitle");
	
	if npcTaskFrameName=="NpcTaskFrameDetail" and npcT_showType==1 then  --待做，进度和奖励部分的排版问题
		ui_frame:SetPoint("left", "NpcTaskFrameDetail", "left", 35, 40);
	elseif npcTaskFrameName=="NpcTaskFrameDetail" and npcT_showType==2 then
		ui_frame:SetPoint("left", "NpcTaskFrameDetail", "left", 35, 130);
	end

	rewardNum = def:getTaskRewardDeNum();
	local showIndex = 1;

	for i = 0 ,3 do
		ui_frame = getglobal(npcTaskFrameName.."RewardItem"..i+1);
		ui_frame:Hide();
		
		if i<rewardNum then
			
			rewardDef = def:getTaskRewardDef(i);

			ui_frame= getglobal(npcTaskFrameName.."RewardItem"..showIndex.."Icon");
			ui_text = getglobal(npcTaskFrameName.."RewardItem"..showIndex.."Num");

			if rewardDef.Type == 0 then
				if rewardDef.ID~=nil and rewardDef.ID~=0 then
					local iconName = ItemDefCsv:get(rewardDef.ID).Icon;
					if iconName ==nil then 
						Log("iconName is nil :ShowTaskDetail_RewardShow()");
					else
						SetItemIcon(ui_frame,rewardDef.ID);
					end
				end
			elseif rewardDef.Type==1 then
				ui_frame:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
				ui_frame:SetTexUV("icon_exp");			
			end
			ui_text:SetText(rewardDef.Num);

			if rewardDef.Num ~= 0 then
				getglobal(npcTaskFrameName.."RewardItem"..showIndex):Show();
				showIndex = showIndex+1; 
			end
		end

	end
end

function ShowTaskDetail_TargetShow()
	local def = npcTaskData.currentTaskDef();
	local ui_frame = getglobal(npcTaskFrameName.."TargetNpc");
	local ui_text = getglobal(npcTaskFrameName.."DeliveryTargetTitle");

	ui_frame:Hide();
	ui_text:Hide();
	
	ui_frame:Disable();
	if def ==nil then 
		Log("def is nil :ShowTaskDetail_TargetShow()");
		return
	end

	if def.IsDeliver==true then 
		if npcTaskFrameName=="TaskDetailFrame" then
			ui_frame:SetPoint("left", npcTaskFrameName.."DeliveryTargetTitle", "left", 130, -50);
			ui_text:SetPoint("Bottomright", npcTaskFrameName, "Bottomright", 35, 25);
		elseif	 npcTaskFrameName=="NpcTaskFrameDetail" then
			ui_text:SetPoint("Bottomright", npcTaskFrameName, "Bottomright", 68, 37);
		end

		ui_text:SetText(GetS(11078));
		ui_frame:Show();
		ui_text:Show();

		ui_frame = getglobal(npcTaskFrameName.."TargetNpcIcon");
		SetActorIcon(ui_frame,def.InteractID);

	else
		if npcTaskFrameName=="TaskDetailFrame" then
			ui_text:SetPoint("Bottomright", npcTaskFrameName, "Bottomright", 80, 25);
		elseif  npcTaskFrameName=="NpcTaskFrameDetail" then
			ui_text:SetPoint("Bottomright", npcTaskFrameName, "Bottomright", 100, 37);
		end
		ui_text:SetText(GetS(11217));
		ui_text:Show();

	end

end


------------------------------------NpcTaskFrame---------------------------------------------


function NpcTaskFrame_RightOnClick() ---右边按钮点击
	NpcTaskFrame_HandlerTask()
	getglobal("NpcTaskFrame"):Hide();
end


function NpcTaskFrame_LeftOnClick()   --左边按钮点击
	getglobal("NpcTaskFrame"):Hide();
end

function NpcTaskFrame_OnLoad()
	this:RegisterEvent("GIE_CLOSE_DIALOGUE");
end

function NpcTaskFrame_OnShow() --界面显示回调方法
	--HideAllFrame("NpcTaskFrame", true);
	
	if not getglobal("NpcTaskFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
	NpcTaskFrame_ShowDetail()
end

function NpcTaskFrame_OnHide()  --界面隐藏会回调方法
	ShowMainFrame();

	if getglobal("NpcDialogueFrame"):IsShown() then 
		getglobal("NpcDialogueFrame"):Hide();
	end
	CurMainPlayer:closePlotDialogue();

	if not getglobal("NpcTaskFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	NpcTaskFrame_ResetData();
end

function NpcTaskFrameClose_OnClick()
	getglobal("NpcTaskFrame"):Hide();
end

function NpcTaskFrame_OnEvent()
	if arg1 == "GIE_CLOSE_DIALOGUE" then
		getglobal("NpcTaskFrame"):Hide();
	end

end

--------界面逻辑

function NpcTaskFrame_AcceptTask(taskid, plotid)
	curTaskID= taskid;
	curPlotId=plotid;
	npcT_showType=1;
	getglobal("NpcTaskFrame"):Show();
end

function NpcTaskFrame_DeliverTask(taskid)
	curTaskID= taskid;
	npcT_showType=2;
	getglobal("NpcTaskFrame"):Show();
end

function NpcTaskFrame_ShowDetail() --显示界面信息
	if npcT_showType==-1 then return end

	npcTaskFrameName="NpcTaskFrameDetail";

	local def = npcTaskData.currentTaskDef();
	local text = DefMgr:filterString(def.Name);
	text = ConvertDialogueStr(text);
	if text then
		getglobal("NpcTaskFrameDetailTaskName"):SetText(text);
	end
	ShowTaskDetail_ContentShow();
	ShowTaskDetail_RewardShow();
	
	if npcT_showType==1 then
		getglobal("NpcTaskFrameTitleFrameName"):SetText(GetS(11218));
		getglobal("NpcTaskFrameDetailTaskSchedule"):Hide();
		getglobal("NpcTaskFrameDetailTaskScheduleTitle"):Hide();

		getglobal("NpcTaskFrameDetailDeliveryTargetTitle"):Show();
		getglobal("NpcTaskFrameDetailTargetNpc"):Show();
		ShowTaskDetail_TargetShow();

		
		getglobal("NpcTaskFrameRightBtnName"):SetText(GetS(11218));

	elseif npcT_showType==2 then 
		getglobal("NpcTaskFrameTitleFrameName"):SetText(GetS(11219));
		getglobal("NpcTaskFrameDetailTaskSchedule"):Show();
		getglobal("NpcTaskFrameDetailTaskScheduleTitle"):Show();

		getglobal("NpcTaskFrameDetailDeliveryTargetTitle"):Hide();
		getglobal("NpcTaskFrameDetailTargetNpc"):Hide();

		getglobal("NpcTaskFrameRightBtnName"):SetText(GetS(11051));

		ShowTaskDetail_ScheduleShow();
	end
end

function NpcTaskFrame_HandlerTask()  --点击右边按钮处理
	if npcT_showType==-1 then return end

	if npcT_showType==1 then 
		AcceptTask(curTaskID, curPlotId);
	elseif npcT_showType==2 then 
		CompleteTask(curTaskID);
	end

end

function NpcTaskFrame_ResetData()  -- 重置数据显示
	npcT_showType =-1;
end