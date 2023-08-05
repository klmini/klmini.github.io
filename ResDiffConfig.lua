--读取配置优先级 （语言）> (语言common) > (国家) > (国家common) 
--此处配置的国家和语言要与get_game_country()、get_game_lang()接口获取的值一致

--在游戏进度条加载的,类似原本的toc配置
g_tUI_DIFF = { 
    --[[
    ["common"] = {  --无适配的语言配置时，读取这里的配置
        ["country_common"] = {  --无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/minilobby.xml"] = "overseas_res/rescommon/ui/minilobby.xml",
            },
            newxml = {      --新增的xml
                "overseas_res/rescommon/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/rescommon/ui/testlogic.lua",
            },
        },
        
        ["us"] = { --美国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res1/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res1/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/res1/ui/testlogic2.lua",
            }
        },

        ["gb"] = { --英国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res2/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res2ui/minilobby2.xml",
            },
        }     
    },

    ["en"] = { --英文
        ["country_common"] = {  --公共配置，无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/minilobby.xml"] = "overseas_res/res2/ui/minilobby.xml",
            },
            newxml = {      --新增的xml
                "overseas_res/res2/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/res2/ui/testlogic2.lua",
            },
        },
        ["us"] = { --美国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res1/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res1/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/res1/ui/testlogic2.lua",
            }
        },
        ["gb"] = { --英国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res1/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res1/ui/minilobby2.xml",
            },
        }
    },

    ["jp"] = { --日文
        ["country_common"] = {  --公共配置，无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/minilobby.xml"] = "overseas_res/rescommon/ui/minilobby.xml",
            },
            newxml = {      --新增的xml
                "overseas_res/rescommon/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/rescommon/ui/testlogic.lua",
            },
        },
        ["us"] = { --美国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res1/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res1/ui/minilobby2.xml",
            },
            lua = {
                "overseas_res/res1/ui/testlogic2.lua",
            }
        },
        ["gb"] = { --英国
            replacexml = {
                ["ui/mobile/minilobby.xml"] = "overseas_res/res1/ui/minilobby.xml",
            },
            newxml = {
                "overseas_res/res1/ui/minilobby2.xml",
            },
        }
    },
    
    ...更多的语言对应的xml、lua加载配置
    ]] 
    ["common"] = {
        ["country_common"] = {
             replacexml = {  --替换原来的xml
                ["ui/mobile/selectrole.xml"] = {path="universe/ui/mobile/selectrole.xml"},
                ["ui/mobile/login.xml"] = {path="universe/ui/mobile/login.xml"},
                ["ui/mobile/minilobby.xml"] = "universe/ui/mobile/minilobby.xml",
                ["ui/mobile/setting.xml"] = {path="universe/ui/mobile/setting.xml"},      
            },
            newxml = {      --新增的xml
            },
            lua = {
                --"universe/ui/mobile/Enum.lua",
                "universe/ui/mobile/autojump_fuc.lua",
                "universe/ui/mobile/globalFunction.lua",
                "universe/ui/mobile/globaldataExt.lua",
                "universe/ui/mobile/lobbyCompatibleFuncInterfaceExt.lua",
                "universe/ui/mobile/new_player_guide/NewPlayerGuide.lua",
                "universe/ui/mobile/locallanguageconfig.lua",
            },
        },
    }
}

--在游戏中使用到的时候加载的
g_tUI_DIFF_DYNAMIC = { 
    --[[
    ["common"] = {  --无适配的语言配置时，读取这里的配置
        ["country_common"] = {  --无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/mvc/NewBattlePass/NewBPBuyCard/NewBPBuyCard.xml"] = {path="overseas_res/rescommon/ui/NewBPBuyCard.xml"},  
            },
            newxml = {      --新增的xml
                {path="overseas_res/rescommon/ui/NewBPBuyCard2.xml", name=""},
            },
        },
        ["us"] = {  --美国
            replacexml = {  --替换原来的xml
                ["ui/mobile/mvc/NewBattlePass/NewBPBuyCard/NewBPBuyCard.xml"] = {path="overseas_res/res1/ui/NewBPBuyCard.xml"},  
            },
            newxml = {      --新增的xml
                {path="overseas_res/res1/ui/NewBPBuyCard2.xml", name=""},
            },
        },
    },
    
    ["en"] = { --英文
        ["country_common"] = {  --公共配置，无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/mvc/NewBattlePass/NewBPBuyCard/NewBPBuyCard.xml"] = {path="overseas_res/res2/ui/NewBPBuyCard.xml"},  
            },
            newxml = {      --新增的xml
                {path="overseas_res/res2/ui/NewBPBuyCard2.xml", name=""},
            },
        },
        ["gb"] = {  --英国
            replacexml = {  --替换原来的xml
                ["ui/mobile/mvc/NewBattlePass/NewBPBuyCard/NewBPBuyCard.xml"] = {path="overseas_res/rescommon/ui/NewBPBuyCard.xml"},  
            },
            newxml = {      --新增的xml
                {path="overseas_res/rescommon/ui/NewBPBuyCard2.xml", name=""},
            },
        },
    },

    ...更多的国家语言对应的xml、lua加载配置
    ]]
    ["common"] = {  --无适配的语言配置时，读取这里的配置
        ["country_common"] = {  --无适配的国家配置时，读取这里的配置
            replacexml = {  --替换原来的xml
                ["ui/mobile/account.xml"] = "universe/ui/mobile/account.xml",
                ["ui/mobile/loading.xml"] = "universe/ui/mobile/loading.xml",                       
               
                ["ui/mobile/room.xml"] = {path="universe/ui/mobile/room.xml"},  
                ["ui/mobile/lobby.xml"] = {path="universe/ui/mobile/lobby.xml"},  
                ["ui/mobile/createworld.xml"] = {path="universe/ui/mobile/createworld.xml"},  
                ["ui/mobile/achievement.xml"] = {path="universe/ui/mobile/achievement.xml"},  
                ["ui/mobile/playmain.xml"] = {path="universe/ui/mobile/playmain.xml"},  
                ["ui/mobile/roleattr.xml"] = {path="universe/ui/mobile/roleattr.xml"}, 
                ["ui/mobile/archivegrade.xml"] = {path="universe/ui/mobile/archivegrade.xml"}, 
                ["ui/mobile/ride.xml"] = {path="universe/ui/mobile/ride.xml"},  
                ["ui/mobile/homechest.xml"] = {path="universe/ui/mobile/homechest.xml"},  
                ["ui/mobile/createworldrule.xml"] = {path="universe/ui/mobile/createworldrule.xml"},  
                ["ui/mobile/share.xml"] = {path="universe/ui/mobile/share.xml"},  
                ["ui/mobile/miniworks.xml"] = {path="universe/ui/mobile/miniworks.xml"},  
                ["ui/mobile/playercenter.xml"] = {path="universe/ui/mobile/playercenter.xml"},  
                ["ui/mobile/replaytheater.xml"] = {path="universe/ui/mobile/replaytheater.xml"},  
                ["ui/mobile/developerstore.xml"] = {path="universe/ui/mobile/developerstore.xml"},  
                ["ui/mobile/friend.xml"] = {path="universe/ui/mobile/friend.xml"},  
                ["ui/mobile/friendchat.xml"] = {path="universe/ui/mobile/friendchat.xml"},
                ["ui/mobile/playercenter_new.xml"] = {path="universe/ui/mobile/playercenter_new.xml"},   
                ["ui/mobile/PlayerExhibitionCenter.xml"] = {path="universe/ui/mobile/PlayerExhibitionCenter.xml"},   
                ["ui/mobile/multilangedit.xml"] = {path="universe/ui/mobile/multilangedit.xml"},  
                ["ui/mobile/activityMain.xml"] = {path="universe/ui/mobile/activityMain.xml"},  
                ["ui/mobile/activity.xml"] = {path="universe/ui/mobile/activity.xml"},  
                ["ui/mobile/marketactivity.xml"] = {path="universe/ui/mobile/marketactivity.xml"},  
                ["ui/mobile/tips.xml"] = {path="universe/ui/mobile/tips.xml"},
                ["ui/mobile/mvc/shop/Shop.xml"] = {path="universe/ui/mobile/mvc/shop/Shop.xml"}, 
                ["ui/mobile/mvc/shop/shopCustomSkinLib/ShopCustomSkinLib.xml"] = {path="universe/ui/mobile/mvc/shop/shopCustomSkinLib/ShopCustomSkinLib.xml"},    
                ["ui/mobile/mvc/developer/toolObjLib/ToolObjLib.xml"] = {path="universe/ui/mobile/mvc/developer/toolObjLib/ToolObjLib.xml"},  
                ["ui/mobile/mvc/shop/shopARFactory/ShopARFactory.xml"] = {path="universe/ui/mobile/mvc/shop/shopARFactory/ShopARFactory.xml"},  
                ["ui/mobile/mvc/shop/shopMounts/ShopMounts.xml"] = {path="universe/ui/mobile/mvc/shop/shopMounts/ShopMounts.xml"},  
                ["ui/mobile/mvc/shop/shopItem/ShopItem.xml"] = {path="universe/ui/mobile/mvc/shop/shopItem/ShopItem.xml"},  
                ["ui/mobile/mvc/shop/shopWarehouse/ShopWarehouse.xml"] = {path="universe/ui/mobile/mvc/shop/shopWarehouse/ShopWarehouse.xml"},  
                ["ui/mobile/mvc/shop/shopSkinDisplay/ShopSkinDisplay.xml"] = {path="universe/ui/mobile/mvc/shop/shopSkinDisplay/ShopSkinDisplay.xml"},  
                ["ui/mobile/mvc/shop/shopPrizeDraw/ShopPrizeDraw.xml"] = {path="universe/ui/mobile/mvc/shop/shopPrizeDraw/ShopPrizeDraw.xml"},  
                ["ui/mobile/mvc/shop/shopFragment/ShopFragMent.xml"] = {path="universe/ui/mobile/mvc/shop/shopFragment/ShopFragMent.xml"},  
                ["ui/mobile/mvc/shop/shopAdvert/ShopAdvert.xml"] = {path="universe/ui/mobile/mvc/shop/shopAdvert/ShopAdvert.xml"},  
                ["ui/mobile/mvc/cloudserver/lobby/CloudServerLobby.xml"] = {path="universe/ui/mobile/mvc/cloudserver/lobby/CloudServerLobby.xml"},  
                ["ui/mobile/mvc/homeland/homemain/HomeMain.xml"] = {path="universe/ui/mobile/mvc/homeland/homemain/HomeMain.xml"}, 
                ["ui/mobile/mvc/miniworks/MiniWorks.xml"] = {path="universe/ui/mobile/mvc/miniworks/MiniWorks.xml"},   
                ["ui/mobile/mvc/miniworks/main/MiniWorksMain.xml"] = {path="universe/ui/mobile/mvc/miniworks/main/MiniWorksMain.xml"},  
                ["ui/mobile/mvc/newAccountSystem/AccountSysLogin/LoginUI/LoginUI.xml"] = {path="universe/ui/mobile/mvc/newAccountSystem/AccountSysLogin/LoginUI/LoginUI.xml"},  
                ["ui/mobile/mvc/lobby/MiniLobbyEx/MiniLobbyEx.xml"] = {path="universe/ui/mobile/mvc/lobby/MiniLobbyEx/MiniLobbyEx.xml"},  
                ["ui/mobile/mvc/lobby/lobbyMapArchiveList/lobbyMapArchiveList.xml"] = {path="universe/ui/mobile/mvc/lobby/lobbyMapArchiveList/lobbyMapArchiveList.xml"},  
                ["ui/mobile/mvc/developer/modeSet/quickEntry/DeveloperQuickEntry.xml"] = {path="universe/ui/mobile/mvc/developer/modeSet/quickEntry/DeveloperQuickEntry.xml"},  
                ["ui/mobile/mvc/developer/modeSet/modeSet/DeveloperModeSet.xml"] = {path="universe/ui/mobile/mvc/developer/modeSet/modeSet/DeveloperModeSet.xml"},  
                ["ui/mobile/mvc/homeland/closet/HomelandCloset.xml"] = {path="universe/ui/mobile/mvc/homeland/closet/HomelandCloset.xml"},  
                ["ui/mobile/mvc/craft/Craft.xml"] = {path="universe/ui/mobile/mvc/craft/Craft.xml"},  
                ["ui/mobile/mvc/shop/shopAdvert/ShopAdvertLottery/ShopAdvertLottery.xml"] = {path="universe/ui/mobile/mvc/shop/shopAdvert/ShopAdvertLottery/ShopAdvertLottery.xml"},  
                ["ui/mobile/mvc/homeland/GuideTask/HomeLandGuideTask.xml"] = {path="universe/ui/mobile/mvc/homeland/GuideTask/HomeLandGuideTask.xml"},  
                ["ui/mobile/mvc/miniworks/archiveInfoFrameEx/ArchiveInfoFrameEx.xml"] = {path="universe/ui/mobile/mvc/miniworks/archiveInfoFrameEx/ArchiveInfoFrameEx.xml"},  
            },
            newxml = {      --新增的xml
                {path = "universe/ui/mobile/recommendmap.xml", name = "RecommendMapFrame"},
                {path = "universe/ui/mobile/newsift.xml", name = "NewSiftFrame"},
                {path = "universe/ui/mobile/overseasadventureguide.xml", name = "AdventureGuideFrame"},
                {path = "universe/ui/mobile/mvc/more_reward_show/MoreRewardExhibition.xml", name = ""},
                {path = "universe/ui/mobile/mvc/miniworks/popups/MiniWorksPopups.xml", name = ""},
                {path = "universe/ui/mobile/online_lobby/OnlineLobby.xml", name = "NoneMapFrameTips"},
                {path = "universe/ui/mobile/mvc/map/recommend/PopularRecommend.xml", name = "" },
                {path = "universe/ui/mobile/mvc/map/deeplink/DeepLinkMap.xml", name = ""},
                {path = "universe/ui/mobile/mvc/pushopentip/PushOpenTip.xml", name = ""},
                {path = "universe/ui/mobile/mvc/pushopentip/PushOpenTip.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/center_recommend/MapRecommend.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/content/MiniContent.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/CreationMode/CreationMode.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/developer/DeveloperDialog.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/map_dialog/MapDialog.xml", name = ""},
                {path = "universe/ui/mobile/mvc/index/SurvivalMode/SurvivalMode.xml", name = ""},
                {path = "universe/ui/mobile/mvc/MiniCenter/MiniCenter.xml", name = ""},
                {path = "universe/ui/mobile/mvc/miniworks/search/MiniWorksFrameSearch.xml", name = ""},
            },
            lua = {
            },
        },
    },
}
