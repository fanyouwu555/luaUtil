local UiUtil = { }

-- 面板相关的全局方法如,面板上动画.


function UiUtil.replaceSprite(icon, name, iconName)
	if (not icon) then
		return nil;
	end

	if (iconName == nil) then
		iconName = name;
		name = nil;
	end

	if (iconName == nil or iconName == "") then
		return nil;
	end

	local sprite = uiManager:LoadSprite(iconName);
	if sprite then
		local image = unity.GetChildImageComponent(icon, name);
		if (image) then
			image.sprite = sprite;
		end
		return image;
	else
		traceWarning('dont exist item icon:' .. iconName);
	end
	return nil;
end

function UiUtil.SetChildButtonTransitonpressedSprite(gameObject, name, spritePath)
	local tmp = unity.GetChildButtonComponent(gameObject, name);
	if (tmp) then
		local sprite = uiManager:LoadSprite(spritePath)
		tmp.transition = CS.UnityEngine.UI.Selectable.Transition.SpriteSwap;
		local state = tmp.spriteState;
		state.pressedSprite = sprite;
		tmp.spriteState = state;
	end
end

function UiUtil.SetChildrenParticleSystemOrderLayer(gameObject, name, order)
	if (not order) then
		order = name;
		name = nil;
	end

	local component = unity.GetAllChildrenRendererComponent(gameObject, name);
	Array.for_each(component, function(value) value.sortingOrder = order; end);
end


function UiUtil.SetParticleSystemOrderLayer(gameObject, name, panel)
	local order = panel:GetParentCanvasOrder();
	UiUtil.SetChildrenParticleSystemOrderLayer(gameObject, name, order + 1)
end




function UiUtil.SetParticleSystemStartScale(gameObject, name)
	local scale = unity.GetParticleStartScale();
	if (name) then
		gameObject = unity.Find(gameObject, name);
	end
	-- dump(gameObject);

	local component = unity.GetAllChildComponent(gameObject, 'ParticleSystem', true);
	-- dump(component,'component');

	Array.for_each(component, function(value)
		local newValue = value.main.startSize.constant * scale;
		value.main.startSize = CS.UnityEngine.ParticleSystem.MinMaxCurve(newValue);
	end );
end



function UiUtil.SetCanvasOrderLayer(gameObject, name, order)
	if (not order) then
		order = name;
		name = nil;
	end
	local obj = unity.GetChildCanvasComponent(gameObject, name)
	obj.overrideSorting = true;
	obj.sortingOrder = order
end


function UiUtil.addGrayAndChild(gameObject, isRecursive)
	if (not gameObject) then
		return;
	end
	if gameObject.activeSelf == false then
		return
	end

	local image = unity.GetChildImageComponent(gameObject);
	if (image) then
		if ((image.material and image.material.name ~= 'gray') or(not image.material)) then
			local shaderMaterial = uiManager:LoadMaterial('common/gray');
			image.material = shaderMaterial;
		end
	end

	local text = gameObject.transform:GetComponent('Text');
	if text ~= nil and text.material.name ~= 'gray' then
		local shaderMaterial = uiManager:LoadMaterial('common/gray');
		-- image.material = shaderMaterial;
		text.material = shaderMaterial
		-- CS.UnityEngine.Material(shaderMaterial);
	end

	if (isRecursive) then
		unity.ForEachAllChild(gameObject, function(child)
			UiUtil.addGrayAndChild(child, true);
		end );
	end
end



function UiUtil.removeGrayAndChild(gameObject, isRecursive)
	if (not gameObject) then
		return;
	end
	local image = unity.GetChildImageComponent(gameObject);
	if image ~= nil and image.material.name == 'gray' then
		image.material = nil;
	end

	local text = gameObject.transform:GetComponent('Text');
	if text ~= nil and text.material.name == 'gray' then
		-- local shaderMaterial = uiManager:LoadMaterial('common/gray');
		-- image.material = shaderMaterial;
		text.material = nil
		-- CS.UnityEngine.Material(shaderMaterial);
	end
	-- local text = gameObject.transform:GetComponent('Text');
	-- if text ~= nil and text.material.name ~= 'gray' then
	-- 	local shaderMaterial = uiManager:LoadMaterial('common/gray');
	-- 		-- image.material = shaderMaterial;
	-- 	text.material = shaderMaterial--CS.UnityEngine.Material(shaderMaterial);
	-- end

	if (isRecursive) then
		unity.ForEachAllChild(gameObject, function(child)
			UiUtil.removeGrayAndChild(child, true);
		end );
	end
end

local UiCanvasInterval = 20;


function UiUtil.CloneCanvas(parent, order, cloneCanvasName)
	if (not parent) then return; end

	order = order or 0;

	local newOrder = nil;
	local num = 1;
	if (parent.transform.childCount > 0) then
		local lastGameObject = parent.transform:GetChild(parent.transform.childCount - 1).gameObject;
		local lastOrder = lastGameObject:GetComponent(typeof(CS.UnityEngine.Canvas)).sortingOrder;
		-- traceWarning('lastGameObject = %s , %d', lastGameObject.name, lastOrder);
		if (lastOrder < order) then
			newOrder = order + lastOrder + UiCanvasInterval;
		else
			newOrder = lastOrder + UiCanvasInterval;
		end
	else
		newOrder = order + num;
	end

	local canvas = CS.UnityEngine.GameObject.Find('GameGUI/CanvasPrefab');

	local root = unity.ClonePrefab(canvas, cloneCanvasName or 'Clone_Canvas', parent.transform);
	root:GetComponent(typeof(CS.UnityEngine.Canvas)).sortingOrder = newOrder;
	return root;
end



function UiUtil.CloneCanvasByName(name, ...)
	local rootName = string.format('GameGUI/%s_Root', name);
	local parent = CS.UnityEngine.GameObject.Find(rootName);
	return UiUtil.CloneCanvas(parent, ...);
end





function UiUtil.CopyToClipboard(str)
	if (CS.NativeHelper.isAndroid and CS.AndroidHelper.CopyTextToClipboard) then
		CS.AndroidHelper.CopyTextToClipboard(str);
	elseif (CS.NativeHelper.isIOS and CS.iOSHelper.CopyTextToClipboard) then
		CS.iOSHelper.CopyTextToClipboard(str);
	else
		CS.UnityHelper.CopyToClipboard(str)
	end
end



function UiUtil.InitGridScrollListView(scrollView, totalNum, param)
	local data = require('Engine.UI.ScrollListView').create(scrollView, totalNum, param)
	return data
end


function UiUtil.SetDropDown(obj, strList, func, defTab, imgList)
	defTab = defTab or 1;
	defTab = defTab - 1;
	local dropDown = unity.GetChildDropdownComponent(obj);
	dropDown:ClearOptions();
	if imgList and next(imgList) then
		local sList = { };
		for k, v in pairs(imgList) do
			local sprite = uiManager:LoadSprite(v);
			if not sprite then
				sprite = uiManager:LoadSprite('common/common_default_Button');
			end
			local it = CS.UnityEngine.UI.Dropdown.OptionData();
			it.image = sprite;
			it.text = language:getValue(strList[k])
			table.insert(sList, it)
		end
		dropDown:AddOptions(sList);
	else
		local str = CS.UnityHelper.ToListString(strList);
		dropDown:AddOptions(str);
	end
	unity.addDropdownListener(obj, SafeBind( function(value)
		if func then
			func(value + 1)
		end
	end ));
	dropDown.value = defTab;
	dropDown:RefreshShownValue()
	if dropDown.captionText then
		dropDown.captionText.text = dropDown.options[dropDown.value].text
	end
	if dropDown.captionImage then
		dropDown.captionImage.sprite = dropDown.options[dropDown.value].sprite
	end

end

function UiUtil.MoveScrollViewPos(view, time, pstY, pstX)
	pstY = pstY or 0;
	pstX = pstX or 0;

	local rectTransform = view.transform:GetComponent('RectTransform');
	local targetPosY = rectTransform.anchoredPosition.y;

	local posY = rectTransform.anchoredPosition.y - pstY
	local posX = rectTransform.anchoredPosition.x - pstX
	rectTransform.anchoredPosition = CS.UnityEngine.Vector2(posX, posY);

	view.transform:DOLocalMove(CS.UnityEngine.Vector3(posX, targetPosY, 1), time)
end

function UiUtil.MoveScrollViewPosLocal(view, time, pstY, pstX)
	pstY = pstY or 0;
	pstX = pstX or 0;

	local rectTransform = view.transform:GetComponent('RectTransform');
	local targetPosY = rectTransform.localPosition.y;

	local posY = rectTransform.localPosition.y - pstY
	local posX = rectTransform.localPosition.x - pstX
	rectTransform.localPosition = CS.UnityEngine.Vector3(posX, posY, 0);

	view.transform:DOLocalMove(CS.UnityEngine.Vector3(posX, targetPosY, 1), time)
end

function UiUtil.addButtonListener(gameObject, name, func, audioName)
	if (type(name) == 'function') then
		audioName = func;
		func = name;
		name = nil;
	end

	local button = unity.GetChildButtonComponent(gameObject, name);
	if (button) then
		button.onClick:RemoveAllListeners();
		audioName = audioName or SoundEffects.UI.Normal;
		button.onClick:AddListener(SafeBind( function()
		--	MainValue.soundManager:playEffect(audioName);
			if func then
				func();
			end
		end ));
	end
	return button;
end

-- function UiUtil.addButtonPointerDrag(gameObject, name, func)
-- 	if (not func) then
-- 		func = name;
-- 		name = nil;
-- 	end

-- 	local btn = unity.GetChildButtonComponent(gameObject, name);

-- 	local trigger = btn.gameObject:GetComponent("EventTrigger");

-- 	local entry = CS.UnityEngine.EventSystems.EventTrigger.Entry();
-- 	entry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.Drag;
-- 	-- entry.callback = CS.UnityEngine.EventSystems.EventTrigger.TriggerEvent();
-- 	entry.callback:RemoveAllListeners();
-- 	entry.callback:AddListener(func);

-- 	trigger.triggers:Add(entry);
-- end

function UiUtil.addButtonPointerDown(gameObject, name, func)
	if (not func) then
		func = name;
		name = nil;
	end

	local btn = unity.GetChildButtonComponent(gameObject, name);

	local trigger = btn.gameObject:GetComponent("EventTrigger");

	local entry = CS.UnityEngine.EventSystems.EventTrigger.Entry();
	entry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerDown;
	-- entry.callback = CS.UnityEngine.EventSystems.EventTrigger.TriggerEvent();
	entry.callback:RemoveAllListeners();
	entry.callback:AddListener(SafeBind( function()func() end));

	trigger.triggers:Add(entry);
end

function UiUtil.addButtonPointerUp(gameObject, name, func)
	if (not func) then
		func = name;
		name = nil;
	end

	local btn = unity.GetChildButtonComponent(gameObject, name);

	local trigger = btn.gameObject:GetComponent("EventTrigger");

	local entry = CS.UnityEngine.EventSystems.EventTrigger.Entry();
	entry.eventID = CS.UnityEngine.EventSystems.EventTriggerType.PointerUp;
	-- entry.callback = CS.UnityEngine.EventSystems.EventTrigger.TriggerEvent();
	entry.callback:RemoveAllListeners();
	entry.callback:AddListener(SafeBind( function()func() end));

	trigger.triggers:Add(entry);
end



function UiUtil.addMuteButtonListener(gameObject, name, func)
	if (not func) then
		func = name;
		name = nil;
	end

	local button = UnityUtil.GetChildButtonComponent(gameObject, name);

	if (button) then
		button.onClick:RemoveAllListeners();
		button.onClick:AddListener(func);
	end
	return button;
end




local global_canvas_size = nil;

-- 获取画布大小
-- return Vector2
function UiUtil.GetCanvasSize()
	if (not global_canvas_size) then
		local parentTransform = CS.UnityEngine.GameObject.Find('GameGUI/CanvasPrefab');
		local rectTransform = parentTransform.transform:GetComponent('RectTransform');
		local size = rectTransform.rect.size;
		local x = size.x;
		if (x > 720) then x = 720; end
		global_canvas_size = { x = x, y = size.y };
	end

	return global_canvas_size.x, global_canvas_size.y;
end



-- 获得CanvasGroup组件,如果没有则添加上
function UiUtil.GetCanvasGroup(obj)
	local group = unity.GetChildCanvasGroupComponent(obj);
	if (not group) then
		group = obj:AddComponent(typeof(CS.UnityEngine.CanvasGroup));
	end
	return group;
end



local function popPanelOpenAnimation(obj)
	-- 添加CanvasGroup
	local group = UiUtil.GetCanvasGroup(obj);
	if (not group) then
		return;
	end

	local dur = ConstValue.Animation.ShowPopPanel;
	group.alpha = 0;
	group:DOFade(1, dur);

	obj.transform.localScale = CS.UnityEngine.Vector3(0.25, 0.25, 1);
	obj.transform:DOScale(CS.UnityEngine.Vector3.one, dur):SetEase(CS.DG.Tweening.Ease.OutBack);
	return dur;
end



local function popPanelCloseAnimation(obj, func)
	local group = unity.GetChildCanvasGroupComponent(obj);
	if (not group) then
		return nil;
	end

	local dur = ConstValue.Animation.HidePopPanel;
	obj.transform:DOScale(CS.UnityEngine.Vector3(0.25, 0.25, 1), dur);
	group:DOFade(0, dur);
	return dur;
end


local function popPanelCloseAnimationByFtueState(obj, target, func)
	local group = unity.GetChildCanvasGroupComponent(obj);
	if (not group) then
		return nil;
	end

	local pos = unity.ConvertToGameObject(target, obj)
	-- dump(pos)
	local dur = 0.55;
	obj.transform:DOScale(CS.UnityEngine.Vector3(0.05, 0.05, 1), dur);
	obj.transform:DOLocalMove(pos, dur):SetEase(CS.DG.Tweening.Ease.InQuad)
	-- group:DOFade(0, dur);
	return dur;
end


local function playPopPanelAnimationByFtueState(animationFunc, panelClass, content, target, func)
	local dur = animationFunc(content, target);
	if (func) then
		if (dur) then
			panelClass:StartCoroutine( function()
				coroutine.yield(CS.UnityEngine.WaitForSeconds(dur));
				func();
			end );
		else
			func();
		end;
	end
end



local function playPopPanelAnimation(animationFunc, panelClass, content, func)
	local dur = animationFunc(content);
	if (func) then
		if (dur) then
			panelClass:StartCoroutine( function()
				coroutine.yield(CS.UnityEngine.WaitForSeconds(dur));
				func();
			end );
		else
			func();
		end;
	end
end




function UiUtil.ShowPanelAni(panelClass, content, func)
	playPopPanelAnimation(popPanelOpenAnimation, panelClass, content, func);
end

function UiUtil.ClosePanelAni(panelClass, content, func)
	playPopPanelAnimation(popPanelCloseAnimation, panelClass, content, func);
end


function UiUtil.ClosePanelAniByFtueState(panelClass, content, target, func)
	playPopPanelAnimationByFtueState(popPanelCloseAnimationByFtueState, panelClass, content, target, func);
end


-- function UiUtil.ShowSpineAni(panelClass, content, func)
-- -- playPopPanelAnimation(popPanelOpenAnimation, panelClass, content, func);
-- end


function UiUtil.CloseSpineAni(obj)
	if (not obj) then return; end

	local spine = unity.GetChildComponent(obj, nil, 'SkeletonGraphic');
	if (not spine) then return; end

	local dur = ConstValue.Animation.HidePopPanel;
	spine:DOFade(0, dur);
end





return UiUtil;
