--[[
	继承自container panel, 实现多种状态的image
]]--

local FLuaCardHeadComponent = class("FLuaCardHeadComponent", function()
    return g_game.g_classFactory.newFLuaContainerPanel("FLuaCardHeadComponent")
end)

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] cloneCardHead
-- 用于新手指引，复制对象
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:cloneCardHead(cardHead)
	self.m_currentState = self.STATE_EMPTY_STATE
    self.m_data				= nil
        
    self.m_isSelect			= false
    self.m_isBlock			= false
	self:setSize(cc.size(104, 104))
	
	self:updateState()
end

function FLuaCardHeadComponent:cloneCardHead2(cardHead)
	self.m_currentState = self.STATE_EMPTY_STATE
    self.m_data				= cardHead.m_data
        
    self.m_isSelect			= false
    self.m_isBlock			= false
	self:setSize(cc.size(104, 104))
	
	self:updateState()
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] ctor
-- 构造函数
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:ctor()
    
    self:registerNodeEvent()   
    
    self.m_empty_image 	= nil
    self.m_block_image	= nil
    self.m_icon_image	= nil
    self.m_hight_light 	= nil
    self.m_quality_image = nil
    
    
    self.STATE_EMPTY_STATE	= 1
    self.STATE_BLOCK_STATE	= 2
    self.STATE_NORMAL_STATE = 3
    self.STATE_SELECT_STATE	= 4
    
    self.m_currentState		= self.STATE_BLOCK_STATE
    self.m_data				= nil
        
    self.m_isSelect			= false
    self.m_isBlock			= false
    
    self.m_isClick = false
    --选中索引
    self.m_selectIndexInList = nil
    self.m_cardEventCallBack = nil
    
	
    self.m_empty_image 	= fc.FExtensionsImage:create() 
    self.m_add_image = fc.FExtensionsImage:create()
    self.m_add_label = fc.FLabel:createBMFont()   
    
    self.m_block_image	= fc.FExtensionsImage:create()
    self.m_quality_image = fc.FExtensionsImage:create()
    self.m_icon_image	= fc.FExtensionsImage:create()
    self.m_lvBgImage = fc.FExtensionsImage:create()
    self.m_lvLabel = fc.FExtensionsImage:create()
    self.m_animation = g_game.g_classFactory.newFLuaAnimationComponent("FAC")
    self.m_hight_light 	= fc.FExtensionsImage:create()
    	
    self.m_openNum_label	= fc.FLabel:createBMFont()
    self.m_openNum_label:setFontSize(20)
    
    self.m_lvLabel = fc.FLabel:createBMFont()
    self.m_lvLabel:setFontSize(20)
    self.m_lvLabel:setColor(cc.c3b(255,255,255))
    
    self:appendComponent(self.m_empty_image)
    self:appendComponent(self.m_add_image)
    self:appendComponent(self.m_add_label) --空的可上阵  可点击上阵位
    
    self:appendComponent(self.m_block_image) --锁
    self:appendComponent(self.m_quality_image) --品质框
    self:appendComponent(self.m_icon_image)
    self:appendComponent(self.m_lvBgImage)
    self:appendComponent(self.m_lvLabel)
    self:appendComponent(self.m_animation)
    self:appendComponent(self.m_hight_light)
    self:appendComponent(self.m_openNum_label)
   
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] onEnter
-- on, 初始化事件监听
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:onEnter()   
	
	--注册touch回调函数
	local downCallback = function()		
		self.m_isClick = true
		if self.m_data == nil and self.m_isBlock == false then
			self.m_hight_light:setVisible(true)
		end
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_DOWN )
	local downCallback = function()			
		self.m_isClick = false
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_DRAG_INSIDE )
	local downCallback = function()			
		self.m_isClick = false
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_DRAG_OUTSIDE )
	local downCallback = function()			
		self.m_isClick = false
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_DRAG_ENTER )
	local downCallback = function()			
		self.m_isClick = false
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_DRAG_EXIT )
	local downCallback = function()			
		self.m_isClick = false
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_UPOUTSIDE )
	
	
	local downCallback = function()		
		if self.m_isClick == true then
			self:setSelect(true)
			self:updateState()	
			self:itemClick()
			self.m_isClick = false
		end	
		send_lua_event(g_game.g_f_lua_game_event.F_LUA_EFFECT_ANNIU)
	end	
	self:addHandleOfcomponentEvent(downCallback, g_game.g_f_touch_event.F_TOUCH_UPINSIDE )
   
    self.m_empty_image:setImage("batch_ui/baipinzhi_kuang.png")
    self.m_add_image:setImage("batch_ui/jiazhuangbei.png")
    self.m_add_label:setFontSize(24)
    self.m_add_label:setColor(cc.c3b(185,255,0))
    if LANGUAGE_TYPE then
    	self.m_add_label:setString("可上陣")
    else
    	self.m_add_label:setString("可上阵")
    end
    self.m_add_label:setAnchorPoint(cc.p(0.5,0.5))
    
    self.m_block_image:setImage("batch_ui/zhuangbei4_weikaiqi.png")
    self.m_hight_light:setImage("batch_ui/xuanzhongkuang.png")
    self.m_openNum_label:setColor(cc.c3b(255,255,255))
    self.m_openNum_label:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_openNum_label:setScale(1.3)
    
    self.m_empty_image:setSize(cc.size(104, 104))
    self.m_add_image:setSize(cc.size(36,37))
    self.m_block_image:setSize(cc.size(90, 90))
    self.m_hight_light:setSize(cc.size(115, 115))
    
    self.m_empty_image:setPositionInContainer(cc.p(52, 52))
    self.m_add_image:setPositionInContainer(cc.p(74,29))
    self.m_add_label:setPositionInContainer(cc.p(46,79))
    self.m_block_image:setPositionInContainer(cc.p(52, 52))
    self.m_quality_image:setPositionInContainer(cc.p(52,52))
    self.m_icon_image:setPositionInContainer(cc.p(52, 52))
    
    self.m_lvLabel:setPositionInContainer(cc.p(88,85))
	self.m_lvBgImage:setPositionInContainer(cc.p(88,85))
    self.m_hight_light:setPositionInContainer(cc.p(52, 52))
    self.m_openNum_label:setPositionInContainer(cc.p(52,52))
	
	self.m_animation:setSize(cc.size(102, 102))
	self.m_animation:setAnchorPoint(cc.p(0.5,0.5))
	self.m_animation:setPositionInContainer(cc.p(51, 51))	
	self.m_animation:setLoop(true)	
	self.m_animation:setAnimationScale(1)
	self.m_animation:setVisible(true)

	self:updateState()
	
end


function FLuaCardHeadComponent:onExit()    
    self:unregisterNodeEvent()
end

function FLuaCardHeadComponent:onEnterTransitionFinish()
end

function FLuaCardHeadComponent:onExitTransitionStart()
end

function FLuaCardHeadComponent:onCleanup()
end


function FLuaCardHeadComponent:registerNodeEvent(handler)
    if not handler then
        handler = function(event)
                      if event == "enter" then
                          self:onEnter()
                      elseif event == "exit" then
                          self:onExit()
                      elseif event == "enterTransitionFinish" then
                          self:onEnterTransitionFinish()
                      elseif event == "exitTransitionStart" then
                          self:onExitTransitionStart()
                      elseif event == "cleanup" then
                          self:onCleanup()
                      end
                  end
    end
    self:registerScriptHandler(handler)
end

function FLuaCardHeadComponent:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] setData
-- 设置数据，并根据数据设置状态
-- ["id"] Type:INTEGER Size:4 主键ID
-- 				["officerId"] Type:INTEGER Size:4 名臣ID
-- 				["officerLevel"] Type:INTEGER Size:4 名臣等级
-- 				["attack"] Type:INTEGER Size:4 攻击力
-- 				["defense"] Type:INTEGER Size:4 防御力
-- 				["intellect"] Type:INTEGER Size:4 智力
-- 				["soldierType"] Type:INTEGER Size:4 兵种类型
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:setData(data, isBlock)
	self.m_data = data
	self.m_isBlock = isBlock
	
	if self.m_isBlock then
		local openedLv = g_game.g_dictConfigManager:getOfficerCardNumOpenedLv(self.m_selectIndexInList)
		if LANGUAGE_TYPE == 3 then
			self.m_openNum_label:setString(openedLv.."級\n開啟")
		else
			self.m_openNum_label:setString(openedLv.."级\n开启")
		end
		
	end
	
	if self.m_data ~= nil then
		local cardResource = g_game.g_dictConfigManager:getCardHeadFile(self.m_data["officerId"])
		local resourceImage = g_game.g_resourceManager:getCardHead(cardResource)
		
		local quality = g_game.g_dictConfigManager:getCardQuality(self.m_data["officerId"])
		self.m_icon_image:setImage(resourceImage)
		self.m_icon_image:setExtensionsTextureRect(cc.rect(0,0,90,90))
		self.m_icon_image:setSize(cc.size(90,90))
		
		self.m_lvBgImage:setImage(g_game.g_f_quality_corner[quality])
		self.m_lvBgImage:setSize(cc.size(29,34))
		self.m_lvLabel:setString(self.m_data["officerLevel"])

		self.m_quality_image:setImage(g_game.g_f_quality_image[quality])
		self.m_quality_image:setSize(cc.size(104,104))
		
		if self.m_animation == nil then
		  	self.m_animation = g_game.g_classFactory.newFLuaAnimationComponent("FAC")	
		  	self:appendComponent(self.m_animation)
		  	self.m_animation:setComponentZOrder(2)
		end
		self.m_hight_light:setComponentZOrder(1)
		self.m_animation:setSize(cc.size(104, 104))
		self.m_animation:setAnchorPoint(cc.p(0.5,0.5))
		self.m_animation:setPositionInContainer(cc.p(52, 52))	
		self.m_animation:setLoop(true)	
		self.m_animation:setAnimationScale(1)
		self.m_animation:setVisible(true)
		if quality >= 3 then
			self.m_animation:setVisible(true)
			self.m_animation:runAnimation(g_game.g_f_main_ui_effect.UI_CARD[2], g_game.g_f_main_ui_effect.UI_CARD[quality])
		else
			self.m_animation:setVisible(false)
		end
	end
		
	self:updateState()		
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] getData
-- 返回数据
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:getData()
	return self.m_data
end
-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] setSelectIndex
-- 设置选中索引
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:setSelectIndex(index)
	self.m_selectIndexInList = index
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] getIndexInList
-- 返回选中索引
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:getIndexInList()
	return self.m_selectIndexInList
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] setCardEventCallBack
-- 设置监听
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:setCardEventCallBack(cardEventCallBack)
     self.m_cardEventCallBack = cardEventCallBack
end


-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] setSelect
-- 设置是否选中
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:setSelect(isSelect)
	self.m_isSelect = isSelect
	
	self:updateState()
end

-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] updateState
-- 更新显示状态
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:updateState()
	if self.m_isBlock == true then
		self.m_empty_image:setVisible(true)
		self.m_add_image:setVisible(false)
		self.m_add_label:setVisible(false)
		self.m_block_image:setVisible(true)
		self.m_openNum_label:setVisible(true)
		self.m_icon_image:setVisible(false)
		self.m_quality_image:setVisible(false)
		self.m_hight_light:setVisible(false)
		self.m_lvBgImage:setVisible(false)
		self.m_lvLabel:setVisible(false)
		self.m_currentState = self.STATE_BLOCK_STATE
		return
	end
	
	if self.m_data ~= nil then
		if self.m_isSelect == true then
			self.m_empty_image:setVisible(false)
			self.m_add_image:setVisible(false)
			self.m_add_label:setVisible(false)
			self.m_block_image:setVisible(false)
			self.m_icon_image:setVisible(true)
			self.m_quality_image:setVisible(true)
			self.m_hight_light:setVisible(true)
			self.m_openNum_label:setVisible(false)
			self.m_lvBgImage:setVisible(true)
			self.m_lvLabel:setVisible(true)
			self.m_currentState = self.STATE_SELECT_STATE
		else
			self.m_empty_image:setVisible(false)
			self.m_add_image:setVisible(false)
			self.m_add_label:setVisible(false)
			self.m_block_image:setVisible(false)
			self.m_icon_image:setVisible(true)
			self.m_quality_image:setVisible(true)
			self.m_hight_light:setVisible(false)
			self.m_openNum_label:setVisible(false)
			self.m_lvBgImage:setVisible(true)
			self.m_lvLabel:setVisible(true)
			self.m_currentState = self.STATE_NORMAL_STATE
		end
	else
	--self.m_empty_image  self.m_add_image self.m_add_label self.m_block_image
    --self.m_quality_image self.m_icon_image self.m_animation self.m_hight_light self.m_openNum_label
		self.m_empty_image:setVisible(true)
		self.m_add_image:setVisible(true)
		self.m_add_label:setVisible(true)
		self.m_block_image:setVisible(false)
		self.m_icon_image:setVisible(false)
		self.m_quality_image:setVisible(false)
		self.m_hight_light:setVisible(false)
		self.m_openNum_label:setVisible(false)
		self.m_lvBgImage:setVisible(false)
		self.m_lvLabel:setVisible(false)
		self.m_currentState = self.STATE_EMPTY_STATE
	end
end


-------------------------------------------------------------------------------
-- @function [parent=#FLuaCardHeadComponent] itemClick
-- 响应卡牌点击
-------------------------------------------------------------------------------
function FLuaCardHeadComponent:itemClick()
	if self.m_currentState == self.STATE_BLOCK_STATE then
		return
	end
	if self.m_currentState == self.STATE_NORMAL_STATE then
		return
	end
	if self.m_currentState == self.STATE_EMPTY_STATE then
		if self.m_cardEventCallBack then
			self.m_cardEventCallBack(self)
		end
		return
	end
	if self.m_currentState == self.STATE_SELECT_STATE then
		if self.m_cardEventCallBack then
			self.m_cardEventCallBack(self)
		end
		return
	end
	
	
end

return FLuaCardHeadComponent