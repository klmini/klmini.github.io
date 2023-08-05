
SkinConfigCtrl = {} 
local SkinConfigCtrl = _G.SkinConfigCtrl;
SkinConfigCtrl.data = {}
SkinConfigCtrl.data.skinlist = {
		{
			-- 湖绿皮肤
			id = 2, 
			active = true,  --- 是否正在使用 		
			savepath = "bulitin:ui/mobile/texture2/", 
			skinname = "bulitin2",
			desc = "21751",
			size = 0
		}, 
		{
			-- 麦黄皮肤
			id = 3, 
			active = false, 			
			savepath = "networkskin:data/http/skins/networkskin3.zip", 
			skinname = "networkskin3",
			desc = "21752",
			size = 0
		}, 
		{
			-- 宝蓝皮肤
			id = 4, 
			active = false,			
			savepath = "networkskin:data/http/skins/networkskin4.zip", 
			skinname = "networkskin4",
			desc = "21753",
			size = 0
		},
		{ 
			-- 粉色皮肤
			id = 5, 
			active = false, 			
			savepath = "networkskin:data/http/skins/networkskin5.zip", 
			skinname = "networkskin5",
			desc = "32301",
			size = 0
		}
};


SkinConfigCtrl.data.textinfolist = {
        {	 
			id = 3,  -- 麦黄皮肤
            textinfoname = 'networkskin3',    ----第一套皮肤名字，此命名不要改动
			basecolor = 'ffffcda1',   ----对应皮肤下所有的textcolor基础值，  颜色值以十六进制填写
			QRcolor = 'ffffcda1',			--二维码颜色
			
			--[[
			replacecolor1 = {        ----某种颜色color值在该风格要用什么颜色替换   
				origcolor = '',	         ----原来的色值，颜色值以十六进制填写
				replacecolor = '',		 ---置换的色值，颜色值以十六进制填写			
			    textctrlname = '',       -----强制指明那个控件要换成这个颜色，可以添加多个控件，以逗号隔开
				textctrlname_exclude = '',  ------强制指明那个控件要排除不换成这个颜色，可以添加多个控件，以逗号隔开
			}, 
			replacecolor2 = {       
				origcolor = '',	
				replacecolor = '',					
			    textctrlname = '',
				textctrlname_exclude = '',
			}, 
			replacecolor3 = {      
				origcolor = '',	
				replacecolor = '',					
			    textctrlname = '',
				textctrlname_exclude = '',
			}, 	
			]]

			--replacecolor:替换颜色表, 设置字体颜色的时候, 遍历这个表, 如果fontstring的颜色和origcolor相同, 则替换成'replacecolor'.
			replacecolor1 = {
				origcolor = 'ff871b',	
				replacecolor = 'ffcda1',
			},

			replacecolor2 = {
				origcolor = 'ff993f',
				replacecolor = '944e1a',
			},

			replacecolor3 = {
				origcolor = '9ee1e7',
				replacecolor = 'aa733e',
			},

			replacecolor4 = {
				origcolor = '4c4c4c',
				replacecolor = '95501d',
			},

			replacecolor5 = {
				origcolor = 'bfe4e3',
				replacecolor = 'a99183',
			},

			-----
			replacecolor6 = {
				origcolor = '3c494c',	
				replacecolor = '373631',
			},

			replacecolor7 = {
				origcolor = 'ff871c',
				replacecolor = '95561c',
			},

			replacecolor8 = {
				origcolor = '8e8777',
				replacecolor = '8e8777',
			},

			replacecolor9 = {
				origcolor = 'ff871a',
				replacecolor = '835017',
			},

			replacecolor10 = {
				origcolor = '8e8778',
				replacecolor = '373631',
			},

			-----
			replacecolor11 = {
				origcolor = '373631',	
				replacecolor = '373631',
			},

			replacecolor12 = {
				origcolor = '373630',
				replacecolor = '373631',
			},

			replacecolor13 = {
				origcolor = '373633',
				replacecolor = '835017',
			},

			replacecolor14 = {
				origcolor = '373433',
				replacecolor = '91440b',
			},

			replacecolor15 = {
				origcolor = '333737',
				replacecolor = '487726',
			},

			-----16
			replacecolor16 = {
				origcolor = '373333',	
				replacecolor = '933d3b',
			},

			replacecolor17 = {
				origcolor = '363535',
				replacecolor = '944e1a',
			},

			replacecolor18 = {
				origcolor = '4d7074',
				replacecolor = 'ffcda1',
			},

			replacecolor19 = {
				origcolor = '37362f',
				replacecolor = '373631',
			},

			replacecolor20 = {
				origcolor = '3d4546',
				replacecolor = '3d4546',
			},

			-----21
			replacecolor21 = {
				origcolor = '657476',	
				replacecolor = '657476',
			},

			replacecolor22 = {
				origcolor = '4d7075',
				replacecolor = '373631',
			},

			replacecolor23 = {
				origcolor = 'b9b9b9',
				replacecolor = 'cabab0',
			},

			replacecolor24 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},

			replacecolor25 = {
				origcolor = 'e0dcca',
				replacecolor = 'e0dcca',
			},

			-----26
			replacecolor26 = {
				origcolor = '01c210',	
				replacecolor = '01c210',
			},

			replacecolor27 = {
				origcolor = 'ff723a',
				replacecolor = 'ff723a',
			},

			replacecolor28 = {
				origcolor = 'e91515',
				replacecolor = 'e91515',
			},

			replacecolor29 = {
				origcolor = 'ffd800',
				replacecolor = 'ffffff',
			},

			replacecolor30 = {
				origcolor = '8e999b',
				replacecolor = '8e999b',
			},

			replacecolor31 = {
				origcolor = '009789',
				replacecolor = '6d8e00',
			},

			replacecolor32 = {
				origcolor = '355454',
				replacecolor = '533426',
			},

			replacecolor33 = {
				origcolor = 'b1feff',
				replacecolor = 'f2e2d0',
			},

			replacecolor34 = {
				origcolor = '4d8483',
				replacecolor = 'a56e41',
			},

			replacecolor35 = {
				origcolor = 'e5fffb',
				replacecolor = 'e7bd87',
			},

			replacecolor36 = {
				origcolor = '93d5cb',
				replacecolor = 'd09c6b',
			},
			
			replacecolor37 = {
				origcolor = '373632',
				replacecolor = '373632',
			},
			
			replacecolor38 = {
				origcolor = '46f1f2',
				replacecolor = 'ff8b41',
			},
			
			replacecolor39 = {
				origcolor = 'f3f8f7',
				replacecolor = '815c4a',
			},
			
			replacecolor40 = {
				origcolor = 'e466ff',
				replacecolor = 'e466ff',
			},
			
			replacecolor41 = {
				origcolor = '96a19d',
				replacecolor = '949387',
			},
			
			replacecolor42 = {
				origcolor = '3d4546',
				replacecolor = '3d4546',
			},
			
			replacecolor43 = {
				origcolor = 'e8671b',
				replacecolor = 'a64600',
			},
			
			replacecolor44 = {
				origcolor = '01c010',
				replacecolor = '057308',
			},
			
			replacecolor45 = {
				origcolor = '017cc2',
				replacecolor = '056399',
			},
			
			replacecolor46 = {
				origcolor = 'e91514',
				replacecolor = 'cf1c1c',
			},
			
			replacecolor47 = {
				origcolor = 'e8671b',
				replacecolor = 'a64600',
			},
			
			replacecolor48 = {
				origcolor = '01c010',
				replacecolor = '057308',
			},
			
			replacecolor49 = {
				origcolor = '017cc2',
				replacecolor = '056399',
			},
			
			replacecolor50 = {
				origcolor = 'e91514',
				replacecolor = 'cf1c1c',
			},
			
			replacecolor51 = {
				origcolor = '009788',
				replacecolor = '03766d',
			},
			
			replacecolor52 = {
				origcolor = '373629',
				replacecolor = '835017',
			},
			
			replacecolor53 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},

			replacecolor54 = {
				origcolor = '2d6262',
				replacecolor = 'ffffff',
			},

			replacecolor55 = {
				origcolor = '6f9196',
				replacecolor = 'b3896e',
			},
		
			replacecolor56 = {
				origcolor = '393833',
				replacecolor = '393833',
			},
		
			replacecolor57 = {
				origcolor = '8e8779',
				replacecolor = '8e8779',
			},
			--txtcolor:指定字体颜色表: 通过在xml中给fontstring控件加上三个属性（basecolor="3" basecolornormal="3" basecolorchecked="2")来指定替换色.
			--fontstring.basecolor是和txtcolor.id对应的值, 如果在'txtcolor'表中找到了basecolor对应的txtcolor值, 那么就用textcolor1.textcolor替换.
            txtcolor1 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置   
            	id = 1,			--id, 唯一标识 
				textcolor = 'ffcda1',	     ----最重要的颜色值
			    textctrlname = '',   --------强制指明那个控件要换成这个颜色，可以添加多个控件，以逗号隔开
				textctrlname_exclude = '', ------强制指明那个控件要排除不换成这个颜色，可以添加多个控件，以逗号隔开，比如: 'aaa','bbb'
			},
			txtcolor2 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置   
				id = 2, 
				textcolor = '944e1a',	   
			    textctrlname = '',
				textctrlname_exclude = '',
			},		
			
			txtcolor3 = {
				id = 3,
				textcolor = 'aa733e',
			},
			txtcolor4 = {
				id = 4,
				textcolor = '95501d',
			},	
			
			txtcolor5 = {
				id = 5,
				textcolor = 'a99183',
			},	

			-----
			txtcolor6 = {
				id = 6,
				textcolor = '373631',
			},
			txtcolor7 = {
				id = 7,
				textcolor = '95561c',
			},	
			
			txtcolor8 = {
				id = 8,
				textcolor = '8e8777',
			},	

			txtcolor9 = {
				id = 9,
				textcolor = '835017',
			},	
			
			txtcolor10 = {
				id = 10,
				textcolor = '373631',
			},	
		},
		{
			id = 4,     -- 宝蓝皮肤              ---------此处指第二套风格的文本颜色值配置信息
            textinfoname = 'networkskin4',
			basecolor = 'ff871b',   ----对应皮肤下所有的textcolor
			QRcolor = 'ffaabb',			--二维码颜色
			
			-----------------------------------------------------------------
			replacecolor1 = {
				origcolor = 'ff871b',	
				replacecolor = 'eaf8f9',
			},

			replacecolor2 = {
				origcolor = 'ff993f',
				replacecolor = '84580a',
			},

			replacecolor3 = {
				origcolor = '9ee1e7',
				replacecolor = 'dde8e9',
			},

			replacecolor4 = {
				origcolor = '4c4c4c',
				replacecolor = '4279a0',
			},

			replacecolor5 = {
				origcolor = 'bfe4e3',
				replacecolor = 'dde8e9',
			},

			-----
			replacecolor6 = {
				origcolor = '3c494c',	
				replacecolor = '3c494c',
			},

			replacecolor7 = {
				origcolor = 'ff871c',
				replacecolor = '84580a',
			},

			replacecolor8 = {
				origcolor = '8e8777',
				replacecolor = '2c4059',
			},

			replacecolor9 = {
				origcolor = 'ff871a',
				replacecolor = '84580a',
			},

			replacecolor10 = {
				origcolor = '8e8778',
				replacecolor = 'dde8e9',
			},

			-----
			replacecolor11 = {
				origcolor = '373631',	
				replacecolor = '2c4059',
			},

			replacecolor12 = {
				origcolor = '373630',
				replacecolor = '2c4059',
			},

			replacecolor13 = {
				origcolor = '373633',
				replacecolor = '84580a',
			},

			replacecolor14 = {
				origcolor = '373433',
				replacecolor = '84580a',
			},

			replacecolor15 = {
				origcolor = '333737',
				replacecolor = 'dde8e9',
			},

			-----16
			replacecolor16 = {
				origcolor = '373333',	
				replacecolor = '7f2613',
			},

			replacecolor17 = {
				origcolor = '363535',
				replacecolor = '115e94',
			},

			replacecolor18 = {
				origcolor = '4d7074',
				replacecolor = '4e7188',
			},

			replacecolor19 = {
				origcolor = '37362f',
				replacecolor = '5a6990',
			},

			replacecolor20 = {
				origcolor = '3d4546',
				replacecolor = '3a3b41',
			},

			-----21
			replacecolor21 = {
				origcolor = '657476',	
				replacecolor = '9496a0',
			},

			replacecolor22 = {
				origcolor = '4d7075',
				replacecolor = '4e7188',
			},

			replacecolor23 = {
				origcolor = 'b9b9b9',
				replacecolor = 'c4e0e3',
			},

			replacecolor24 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},

			replacecolor25 = {
				origcolor = 'e0dcca',
				replacecolor = 'adddf3',
			},

			-----26
			replacecolor26 = {
				origcolor = '01c210',	
				replacecolor = '01c210',
			},

			replacecolor27 = {
				origcolor = 'ff723a',
				replacecolor = 'ff723a',
			},

			replacecolor28 = {
				origcolor = 'e91515',
				replacecolor = 'e91515',
			},

			replacecolor29 = {
				origcolor = 'ffd800',
				replacecolor = 'ffffff',
			},

			replacecolor30 = {
				origcolor = '8e999b',
				replacecolor = '8e999b',
			},

			replacecolor31 = {
				origcolor = '009789',
				replacecolor = '009789',
			},

			replacecolor32 = {
				origcolor = '355454',
				replacecolor = 'ebf6ff',
			},

			replacecolor33 = {
				origcolor = 'b1feff',
				replacecolor = 'c1e8fe',
			},

			replacecolor34 = {
				origcolor = '4d8483',
				replacecolor = '557ea0',
			},

			replacecolor35 = {
				origcolor = 'e5fffb',
				replacecolor = 'e8f2f0',
			},

			replacecolor36 = {
				origcolor = '93d5cb',
				replacecolor = 'b5edff',
			},
			
			replacecolor37 = {
				origcolor = '373632',
				replacecolor = '373632',
			},
			
			replacecolor38 = {
				origcolor = '46f1f2',
				replacecolor = '46f1f1',
			},
			
			replacecolor39 = {
				origcolor = 'f3f8f7',
				replacecolor = '115e94',
			},
			
			replacecolor40 = {
				origcolor = 'e466ff',
				replacecolor = 'e466ff',
			},
			
			replacecolor41 = {
				origcolor = '96a19d',
				replacecolor = '8b939a',
			},
			
			replacecolor42 = {
				origcolor = '3d4546',
				replacecolor = '3a3b41',
			},
			
			replacecolor43 = {
				origcolor = 'e8671b',
				replacecolor = 'e8671b',
			},
			
			replacecolor44 = {
				origcolor = '01c010',
				replacecolor = '069912',
			},
			
			replacecolor45 = {
				origcolor = '017cc2',
				replacecolor = '017cc2',
			},
			
			replacecolor46 = {
				origcolor = 'e91514',
				replacecolor = 'e91514',
			},
			
			replacecolor47 = {
				origcolor = 'e8671b',
				replacecolor = 'e8671b',
			},
			
			replacecolor48 = {
				origcolor = '01c010',
				replacecolor = '069912',
			},
			
			replacecolor49 = {
				origcolor = '017cc2',
				replacecolor = '017cc2',
			},
			
			replacecolor50 = {
				origcolor = 'e91514',
				replacecolor = 'e91514',
			},
			
			replacecolor51 = {
				origcolor = '009788',
				replacecolor = '009788',
			},
			
			replacecolor52 = {
				origcolor = '373629',
				replacecolor = '48799c',
			},
			
			replacecolor53 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},

			replacecolor54 = {
				origcolor = '2d6262',
				replacecolor = '294257',
			},
			
			replacecolor55 = {
				origcolor = '6f9196',
				replacecolor = '6f9196',
			},
		
			replacecolor56 = {
				origcolor = '393833',
				replacecolor = '393833',
			},
		
			replacecolor57 = {
				origcolor = '8e8779',
				replacecolor = '797d8e',
			},
			-----------------------------------------------------------------------------------------------
		
            txtcolor1 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置    
				textcolor = 'eaf8f9',	   
			    textctrlname = '',
				textctrlname_exclude = '',
			},
			txtcolor2 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置    
				textcolor = '84580a',	   
			    textctrlname = '',
				textctrlname_exclude = '',
			},

			txtcolor3 = {
				textcolor = 'dde8e9',
			},
			txtcolor4 = {
				textcolor = '4279a0',
			},	
			
			txtcolor5 = {
				textcolor = 'dde8e9',
			},			
			    
		},	
		{	
			id = 5,     -- 粉色皮肤              ---------此处指第四套风格的文本颜色值配置信息
			textinfoname = 'networkskin5',
			basecolor = 'ff871b',   ----对应皮肤下所有的textcolor
			QRcolor = 'fcfaf0',			--二维码颜色
			
			-----------------------------------------------------------------
			replacecolor1 = {
				origcolor = 'ff871b',	
				replacecolor = 'fcfaf0',
			},
		
			replacecolor2 = {
				origcolor = 'ff993f',
				replacecolor = 'c93a54',
			},
		
			replacecolor3 = {
				origcolor = '9ee1e7',
				replacecolor = 'b75b6c',
			},
		
			replacecolor4 = {
				origcolor = '4c4c4c',
				replacecolor = 'c93a54',
			},
		
			replacecolor5 = {
				origcolor = 'bfe4e3',
				replacecolor = 'fcfaf0',
			},

			replacecolor6 = {
				origcolor = '3c494c',	
				replacecolor = '7f4945',
			},
		
			replacecolor7 = {
				origcolor = 'ff871c',
				replacecolor = '7f4945',
			},
		
			replacecolor8 = {
				origcolor = '8e8777',
				replacecolor = 'b75b6c',
			},
		
			replacecolor9 = {
				origcolor = 'ff871a',
				replacecolor = '7f4945',
			},
		
			replacecolor10 = {
				origcolor = '8e8778',
				replacecolor = 'b75b6c',
			},
		
			replacecolor11 = {
				origcolor = '373631',	
				replacecolor = '98646e',
			},
		
			replacecolor12 = {
				origcolor = '373630',
				replacecolor = '98646e',
			},
		
			replacecolor13 = {
				origcolor = '373633',
				replacecolor = '9b3232',
			},
		
			replacecolor14 = {
				origcolor = '373433',
				replacecolor = '685d99',
			},
		
			replacecolor15 = {
				origcolor = '333737',
				replacecolor = 'ac4558',
			},
		
			replacecolor16 = {
				origcolor = '373333',	
				replacecolor = 'ffe4e4',
			},
		
			replacecolor17 = {
				origcolor = '363535',
				replacecolor = '706161',
			},
		
			replacecolor18 = {
				origcolor = '4d7074',
				replacecolor = '96253a',
			},
		
			replacecolor19 = {
				origcolor = '37362f',
				replacecolor = '574646',
			},
		
			replacecolor20 = {
				origcolor = '3d4546',
				replacecolor = '574646',
			},
		
			replacecolor21 = {
				origcolor = '657476',	
				replacecolor = '766d65',
			},
		
			replacecolor22 = {
				origcolor = '4d7075',
				replacecolor = '763b54',
			},
		
			replacecolor23 = {
				origcolor = 'b9b9b9',
				replacecolor = 'd8d5d5',
			},
		
			replacecolor24 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},
		
			replacecolor25 = {
				origcolor = 'e0dcca',
				replacecolor = 'ebe8e8',
			},
		
			replacecolor26 = {
				origcolor = '01c210',	
				replacecolor = '01c210',
			},
		
			replacecolor27 = {
				origcolor = 'ff723a',
				replacecolor = 'ff723a',
			},
		
			replacecolor28 = {
				origcolor = 'e91515',
				replacecolor = 'e91515',
			},
		
			replacecolor29 = {
				origcolor = 'ffd800',
				replacecolor = 'ebe8e8',
			},
		
			replacecolor30 = {
				origcolor = '8e999b',
				replacecolor = '8e999b',
			},
		
			replacecolor31 = {
				origcolor = '009789',
				replacecolor = '009789',
			},
					
			replacecolor32 = {
				origcolor = '355454',
				replacecolor = 'fff9d8',
			},
		
			replacecolor33 = {
				origcolor = 'b1feff',
				replacecolor = 'fff9d8',
			},
		
			replacecolor34 = {
				origcolor = '4d8483',
				replacecolor = '92545f',
			},
		
			replacecolor35 = {
				origcolor = 'e5fffb',
				replacecolor = 'fff9d8',
			},
		
			replacecolor36 = {
				origcolor = '93d5cb',
				replacecolor = 'ffe4ce',
			},
			
			replacecolor37 = {
				origcolor = '373632',
				replacecolor = '373632',
			},
			
			replacecolor38 = {
				origcolor = '46f1f2',
				replacecolor = 'eb3556',
			},
			
			replacecolor39 = {
				origcolor = 'f3f8f7',
				replacecolor = '7d2f3d',
			},
			
			replacecolor40 = {
				origcolor = 'e466ff',
				replacecolor = 'e466ff',
			},
			
			replacecolor41 = {
				origcolor = '96a19d',
				replacecolor = 'b6aaac',
			},
			
			-- 重复 replacecolor20
			replacecolor42 = {
				origcolor = '3d4546',
				replacecolor = '574646',
			},
			
			replacecolor43 = {
				origcolor = 'e8671b',
				replacecolor = 'e8671b',
			},
			
			replacecolor44 = {
				origcolor = '01c010',
				replacecolor = '069912',
			},
			
			replacecolor45 = {
				origcolor = '017cc2',
				replacecolor = '017cc2',
			},
			
			replacecolor46 = {
				origcolor = 'e91514',
				replacecolor = 'e91514',
			},
			
			replacecolor47 = {
				origcolor = 'e8671b',
				replacecolor = 'e8671b',
			},
			
			replacecolor48 = {
				origcolor = '01c010',
				replacecolor = '069912',
			},
			
			replacecolor49 = {
				origcolor = '017cc2',
				replacecolor = '017cc2',
			},
			
			replacecolor50 = {
				origcolor = 'e91514',
				replacecolor = 'e91514',
			},
			
			replacecolor51 = {
				origcolor = '009788',
				replacecolor = '009788',
			},
			
			replacecolor52 = {
				origcolor = '373629',
				replacecolor = '595959',
			},
			
			-- 重复 replacecolor24
			replacecolor53 = {
				origcolor = 'ffffff',
				replacecolor = 'ffffff',
			},
		
			replacecolor54 = {
				origcolor = '2d6262',
				replacecolor = '5e3c4f',
			},
			
			replacecolor55 = {
				origcolor = '6f9196',
				replacecolor = '836d6d',
			},
		
			replacecolor56 = {
				origcolor = '393833',
				replacecolor = '603937',
			},
		
			replacecolor57 = {
				origcolor = '8e8779',
				replacecolor = 'a18483',
			},
			-----------------------------------------------------------------------------------------------
		
			txtcolor1 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置    
				textcolor = 'eaf8f9',	   
				textctrlname = '',
				textctrlname_exclude = '',
			},
			txtcolor2 = {        ----对应皮肤下的某种颜色和使用该颜色的控件名称设置    
				textcolor = '84580a',	   
				textctrlname = '',
				textctrlname_exclude = '',
			},
		
			txtcolor3 = {
				textcolor = 'dde8e9',
			},
			txtcolor4 = {
				textcolor = '4279a0',
			},	
			
			txtcolor5 = {
				textcolor = 'dde8e9',
			},		
				
		},
};

SkinConfigCtrl.downloaSkinIdList = {} --为了控制下载进度显示，增加一个队列控制
gSkinlistVersion = 2;
SkinConfigCtrl.downloadSkin = function(skin)	
	local print = Android:Localize(Android.SITUATION.UI_THEME);
    if skin == nil then return end
	
	local sskinverkey_prefix_url = "downloadurl"..tostring(gSkinlistVersion)
	local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)
    local url =  skin[sskinverkey_prefix_url] 
	if url == nil then 	
	    url = skin["downloadurl"]
	end 
	local name = skin["skinname"]
	local nameUpdate = name .. "_update" --这里增加一个更新备份命名
	local md5 =  skin[sskinverkey_prefix_md5] 
	if md5 == nil then 	
	    md5 = skin["md5"]	
	end 
	if url and name and md5 then 
		local savePath = 'data/http/skins/'..name..'.zip'
		-- 如果因为生效中被占用zip，启用备份名字先下载，重启的时候再删除旧资源，将备份资源更换正式名字
		if gFunc_isStdioFileExist(savePath) then
			savePath = 'data/http/skins/'..nameUpdate..'.zip'
		end
		local  cb_download_ok_  = function (obj, errcode)
			if errcode == 0 then
				print("SkinConfigCtrl.downloadSkin:file ok")			
				if gFunc_isStdioFileExist(savePath) then
					print("SkinConfigCtrl.downloadSkin chkmd5")
					local filemd5 = gFunc_getSmallFileMd5(savePath)
					if filemd5 ~= md5 then 
						print("SkinConfigCtrl.downloadSkin chkmd5 failed!",filemd5)
						gFunc_deleteStdioFile(savePath)
						print("Download skin md5 check failed !!!!", 5);
						ShowGameTips(GetS(30013), 5);
					else
					    local sssavePath = 'networkskin:data/http/skins/'..name..'.zip'
						skin["savepath"] = sssavePath	
						SkinConfigCtrl.useSkin(name)
						--UISkin换肤更新提示
						UpdateUISkinTickBtnTitle()
					end 
				else
					print("SkinConfigCtrl.downloadSkin 1 file fails",errcode)
					ShowGameTips(GetS(30013), 5);
				end			
			else
			   print("SkinConfigCtrl.downloadSkin 2 file fails",errcode)
			   ShowGameTips(GetS(30013), 5);
			end 		
			skin["downloading"] = false;

			-- 更新下载进度显示的时候，最后一个下载任务完成再隐藏进度条
			for i=#SkinConfigCtrl.downloaSkinIdList,1,-1 do
				if SkinConfigCtrl.downloaSkinIdList[i] == skin.id then
					table.remove(SkinConfigCtrl.downloaSkinIdList,i)
				end
			end
			if 0 == #SkinConfigCtrl.downloaSkinIdList then
				getglobal("SkinDownloadMessageBoxProgressTex"):Hide()
				getglobal("SkinDownloadMessageBoxProgressBarBkg"):Hide()		
			    getglobal("SkinDownloadMessageBoxProgressTex"):SetWidth(0)	
				getglobal("SkinDownloadMessageBoxProgressText"):Hide()	
				local tips = GetS(30007)
				getglobal("SkinDownloadMessageBoxDesc"):SetText(tips, 55, 54, 49)	

				--增加基础设置界面的进度显示
				getglobal("GameSetFrameBaseLayersScrollProgressTex"):Hide()
				getglobal("GameSetFrameBaseLayersScrollProgressBarBkg"):Hide()		
			    getglobal("GameSetFrameBaseLayersScrollProgressTex"):SetWidth(0)	
				getglobal("GameSetFrameBaseLayersScrollProgressText"):Hide()
			end
			
			--已下载主题都已是最新
			if false == IsLocalUISkin() then
				local pUpdateTip = getglobal("GameSetFrameBaseLayersScrollUISkinUpdateTip")
				local strtip = pUpdateTip:GetText()
				if strtip == "" then
					pUpdateTip:Show()
					pUpdateTip:SetText(GetS(30040))
				end
			end
		end
		local  cb_download_progress_  = function (obj1,obj2)
			---print("SkinConfigCtrl.cb_download_progress_:",obj1,obj2)
			-- 加一层判断，只更新当前第一个下载任务的进度显示
			if SkinConfigCtrl.downloaSkinIdList[1] == skin.id then
	            local progress = tonumber(obj1)    			
				getglobal("SkinDownloadMessageBoxProgressTex"):SetWidth(400 * (progress / 100.0));
				local ssprogress = tostring(obj1) or '0'
				local ssdowntips =  GetS(30014)..string.format(':%s%%',ssprogress)
				getglobal("SkinDownloadMessageBoxProgressText"):SetText(ssdowntips)

				--基础设置界面的进度显示
				local sskinname = GetUISkinNameDescBySkinId(skin.id)
				ssdowntips = string.format(GetS(30039),sskinname)
				ssdowntips = ssdowntips .. string.format(':%s%%',ssprogress)
				getglobal("GameSetFrameBaseLayersScrollProgressTex"):SetWidth(200 * (progress / 100.0))
				getglobal("GameSetFrameBaseLayersScrollProgressText"):SetText(ssdowntips)
				-- 显示进度的时候不显示提示
				getglobal("GameSetFrameBaseLayersScrollUISkinUpdateTip"):Hide()
			end
		end
		-- 管理下载显示队列，调整当前下载到最前面显示
		print("SkinConfigCtrl.downloadSkin:",url,name)
		for i=#SkinConfigCtrl.downloaSkinIdList,1,-1 do
			if SkinConfigCtrl.downloaSkinIdList[i] == skin.id then
				table.remove(SkinConfigCtrl.downloaSkinIdList,i)
			end
		end
		table.insert(SkinConfigCtrl.downloaSkinIdList,1,skin.id)

		ns_http.func.downloadFile(url,savePath, md5, cb_download_ok_,skin, cb_download_progress_);
	end
end 

SkinConfigCtrl.useSkinId = function(id) 
    local idindex = tonumber(id)
	for k, v in pairs(SkinConfigCtrl.data.skinlist) do       
		local vid = v["id"]	
		----print("SkinConfigCtrl.useSkinId for",vid)
		if tonumber(vid) == idindex then 
			local name = v["skinname"]
			print("SkinConfigCtrl.useSkinId",name)
			SkinConfigCtrl.useSkin(name) 
			break;
		end  
	end	
end 

SkinConfigCtrl.useSkin = function(tag)    
	SkinConfigCtrl.refreshCfgList();
	print("SkinConfigCtrl.data.skinlist1:",SkinConfigCtrl.data.skinlist)
    print("SkinConfigCtrl.useSkin",tag)
    local skin = SkinConfigCtrl.getSkinInfo(tag)
	if skin == nil then 
	     skin = SkinConfigCtrl.getSkinInfo('bulitin2')
		 SkinConfigCtrl.justSaveUseSkin(skin)
		 SkinTickUseSingleSelect('default')
		 return;
	end 
	if string.find(tag,"bulitin") ~= nil then      ---内置的皮肤
		SkinConfigCtrl.justSaveUseSkin(skin)		
		return;
	else 
	    
		local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)    
		local md5 =  skin[sskinverkey_prefix_md5] 
		if md5 == nil then 	
			md5 = skin["md5"]	
		end 
		-- 这里优先判断更新备份包
		local savePath = "data/http/skins/"..tostring(tag).."_update.zip"
		if not gFunc_isStdioFileExist(savePath) then
			savePath = "data/http/skins/"..tostring(tag)..".zip"
		end
		-- 本地皮肤直接使用皮肤
		if IsLocalUISkin() == true or (gFunc_isStdioFileExist(savePath) and  gFunc_getSmallFileMd5(savePath)) == md5 then 
			SkinConfigCtrl.justSaveUseSkin(skin)					
		else
		    if skin["downloading"]  == nil or skin["downloading"] == false then 
				skin["downloading"] = true
				SkinConfigCtrl.downloadSkin(skin)
			end 
		end 
	end
end


SkinConfigCtrl.justSaveUseSkin = function(skin)
    local skinId = tonumber(skin["id"]) 
	ClientMgr:setGameData("uiskin", skinId);
	SkinTickUseSingleSelect()
	skin["active"] = true 
	for k, v in pairs(SkinConfigCtrl.data.skinlist) do       
		local name = v["skinname"]	
		if name ~= skin["skinname"] then 
			v["active"]=false	
		end 
	end
	
	for k, v in pairs(SkinConfigCtrl.data.skinlist) do       
		local name = v["skinname"]	
		if name == skin["skinname"] then 
			v["active"]=true
            break;			
		end 
	end
	SkinConfigCtrl.data.skinver = gSkinlistVersion 
	print("SkinConfigCtrl.useSkin skinlist2:",SkinConfigCtrl.data.skinlist)
	----持久化到文件，c++层重启动的时候会去读取同时设置到ResourceManager中去
	local jsonFile = JSON:encode(SkinConfigCtrl.data);  
	local length = string.len(jsonFile)	
	--print("SkinConfigCtrl.useSkin encode:",jsonFile)
	gFunc_writeBinaryFile("data/skincfg.data",jsonFile,length);	
	

end

SkinConfigCtrl.getSkinInfo = function(tag) ----获取当前使用的皮肤名
    local skin = nil;
    for k, v in pairs(SkinConfigCtrl.data.skinlist) do       
	    local name = v["skinname"]		
        if name == tag then 
		   skin = v;
		   break;
	    end  
	end	
	return skin;
end

SkinConfigCtrl.getCurUseSkinId = function() ----获取当前使用的皮肤id
	local length = 0;	
    local skincfgstr = gFunc_readBinaryFile("data/skincfg.data",length);
    if skincfgstr then
    	skincfgstr = JSON:decode(skincfgstr);
    end

    if skincfgstr and skincfgstr.skinlist then
	    for k, v in pairs(skincfgstr.skinlist) do 
			if v["active"] == true then 			
				return tonumber(v["id"])           		
			end 
		end
	end
	return 2;
end


SkinConfigCtrl.getSkinInfoById = function(id) ----获取当前使用的皮肤名
    local skin = nil;
    local idindex = tonumber(id)
	for k, v in pairs(SkinConfigCtrl.data.skinlist) do       
		local vid = v["id"]			
		if tonumber(vid) == idindex then 
			skin = v;
			break;
		end  
	end	
	return skin;
end

-- 刷新本地皮肤配置表
SkinConfigCtrl.refreshCfgList = function()
    if ns_version == nil then return end
	ns_version.skinlist = SkinConfigCtrl.data.skinlist
	print("SkinConfigCtrl ns_version.skinlist:",ns_version.skinlist)    
    for k, v in pairs(ns_version.skinlist) do  
		local name = v["skinname"]	
	    local skin = SkinConfigCtrl.getSkinInfo(name)		
        if skin == nil then 
		    table.insert(SkinConfigCtrl.data.skinlist,v)
	    else
			local n=#SkinConfigCtrl.data.skinlist
			local index = nil
			for i=1,n do
				if SkinConfigCtrl.data.skinlist[i] and SkinConfigCtrl.data.skinlist[i]["skinname"] == name  then
					index = i;
					break;
				end
			end
			if index then
				SkinConfigCtrl.data.skinlist[index] = v;
			end 
		end
	end
end


SkinConfigCtrl.chkCurSkinCanUse = function()
	local curskinid =  SkinConfigCtrl.getCurUseSkinId();
	if curskinid ~= 2 then 
		 Log("skininfofix0")
		SkinConfigCtrl.refreshCfgList(); 
		 
		  
		 local curskinfo = SkinConfigCtrl.getSkinInfoById(curskinid)
		 local newmd5 = nil
		 local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)    
		 if curskinfo ~= nil then 		 	  
		 	newmd5 =  curskinfo[sskinverkey_prefix_md5] 
			if newmd5 == nil then 	
					newmd5 = curskinfo["md5"]	
		 	 end 
         end

		 local curmd5 = nil;
		 local length = 0;	
		 local skincfgstr = gFunc_readBinaryFile("data/skincfg.data",length);
		 if skincfgstr then
			 skincfgstr = JSON:decode(skincfgstr);
		 end
	 
		 if skincfgstr and skincfgstr.skinlist then
			 for k, v in pairs(skincfgstr.skinlist) do 
				 if v["active"] == true then 
					---local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)    
					local md5 =  v[sskinverkey_prefix_md5] 
					if md5 == nil then 	
						md5 = v["md5"]	
					end 			
					curmd5 =  md5           		
				 end 
			 end
		 end

		--本地皮肤不重置
		 if IsLocalUISkin() == false and curskinfo ~= nil and curmd5 ~= nil then 
 			print("skininfofix1",curskinfo )	 		
 			local curskinname = curskinfo["skinname"]
 			local savePath = "data/http/skins/"..tostring(curskinname)..".zip";
 			print("skininfofix2",curmd5 ,gFunc_getSmallFileMd5(savePath))
 			-- 当主题下载文件被手动清了以后，也应该重置回默认主题
 			if gFunc_isStdioFileExist(savePath) then
 				if gFunc_getSmallFileMd5(savePath) ~= curmd5 then 
   					gFunc_deleteStdioFile("data/skincfg.data")
   				end
   			else
   				gFunc_deleteStdioFile("data/skincfg.data")
	 		end 
			if newmd5 ~= nil and  newmd5 ~= curmd5 then 
   				gFunc_deleteStdioFile("data/skincfg.data")
	 		end 
		end 
	end 
   
end
-- 判断某个主题是否需要更新
SkinConfigCtrl.isSkinNeedUpdate = function ( skinId )
	-- 本地皮肤不检查更新
	if IsLocalUISkin() == true then return false end

	-- 本地默认主题不需要更新
	if 2 == skinId then return false end

	SkinConfigCtrl.refreshCfgList(); 
	local curskinfo = SkinConfigCtrl.getSkinInfoById(skinId)
	local newmd5 = nil
	local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)    
	if curskinfo ~= nil then 		 	  
		newmd5 =  SkinConfigCtrl.getSkinMd5(curskinfo)
	end

	if curskinfo ~= nil and newmd5 ~= nil then 	 		
		local curskinname = curskinfo["skinname"]
		local curskinUpdateName = curskinname .. "_update"
		-- 优先判断更新下载的文件
		local savePath = "data/http/skins/"..tostring(curskinUpdateName)..".zip"
		if not gFunc_isStdioFileExist(savePath) then
			savePath = "data/http/skins/"..tostring(curskinname)..".zip"
		end
		if gFunc_isStdioFileExist(savePath) and  gFunc_getSmallFileMd5(savePath) ~= newmd5 then 
			-- 已下载的主题，md5值不一致时需要更新
			return true
		end  
	end
	-- 默认不需要更新
	return false
end

SkinConfigCtrl.getSkinMd5 = function(skininfo)
	local sskinverkey_prefix_md5 = "md5"..tostring(gSkinlistVersion)    
	local md5 =  skininfo[sskinverkey_prefix_md5] 
	if md5 == nil then 	
		md5 = skininfo["md5"]	
	end 
	return md5
end

SkinConfigCtrl.getQRCodeColorRGBA = function()
	local skin = SkinConfigCtrl.getSkinInfo("bulitin2"); -- TODO
	return _ColorHexString2ArgbByte(skin.qrcode or "7C6248"); -- 旧版颜色
end

-- 记录当次提示更新的主题zip文件MD5，方便下次判断提示显示的时候是不是已经提示过了
SkinConfigCtrl.recordSkinUpdate = function ()
	gFunc_deleteStdioFile("data/skinupdaterecord.data")
	if ns_version.skinlist == nil then return end
	local record = {}
	for k,v in pairs(ns_version.skinlist) do
		local md5 = SkinConfigCtrl.getSkinMd5(v)
		table.insert(record, md5)
	end
	local jsonFile = JSON:encode(record)  
	local length = string.len(jsonFile)	
	gFunc_writeBinaryFile("data/skinupdaterecord.data",jsonFile,length);
end

