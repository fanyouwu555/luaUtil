local ScrollListView = class('ScrollListView');
----------------常用的方法----------------------
-- 移动到指定的item
-- mLoopListView:MovePanelToItemIndex(index == 0 ,offset)
-- 刷新界面
-- mLoopListView:RefreshAllShownItem();
-- 初始化规则的滑动列表
----------------------------------

-- scrollView 带有CS.SuperScrollView.LoopListView2组件的gameObject
-- prefabName 节点名称
-- totalNum 节点数量
-- param = { };
--[[
	--网格节点下面的具体cell数量，非网格是1
	param.column = 1;
	--对于多个prefab时候需要根据条件 返回一个prefab名称
	param.getPrefabNameFunc
	--cell刷新方法
	 param.viewFunc = nil;
	--cell上添加点击
	 param.addClickFunc = nil;
	 param.initParam = nil;
	 param.beginDragFunc = nil;
	 param.dragingFunc = nil;
	 param.endDragFunc = nil;
	 param.snapNearestChangedFunc = nil;
	--初始化参数 不填的使用 默认参数
	param.initParam = CS.SuperScrollView.LoopListViewInitParam.CopyDefaultInitParam();
		initParam.mDistanceForRecycle0 = 300; --mDistanceForRecycle0 should be larger than mDistanceForNew0
		initParam.mDistanceForNew0 = 200;
		initParam.mDistanceForRecycle1 = 300;--mDistanceForRecycle1 should be larger than mDistanceForNew1
		initParam.mDistanceForNew1 = 200;
		initParam.mSmoothDumpRate = 0.3f;
		initParam.mSnapFinishThreshold = 0.01f;
		initParam.mSnapVecThreshold = 145;
		initParam.mItemDefaultWithPaddingSize = 20;--item's default size (with padding)
	]]
function ScrollListView:ctor(scrollView, totalNum, param)
	if not param then
		param = { };
	end
	local mLoopListView = scrollView.transform:GetComponent(typeof(CS.SuperScrollView.LoopListView2))
	if not mLoopListView then
		traceError('need add LoopListView2')
		return nil;
	end
	self.gameObject = scrollView;

	self.mLoopListView = mLoopListView;
	self.totalNum = totalNum;

	self.isPage = param.isPage;
	self.column = param.column or 1;

	self.getPrefabNameFunc = param.getPrefabNameFunc;
	self.viewFunc = param.viewFunc;
	self.addClickFunc = param.addClickFunc;
	self.initParam = param.initParam;
	self.OnBeginDrag = param.beginDragFunc;
	self.OnDraging = param.dragingFunc;
	self.OnEndDrag = param.endDragFunc;
	self.OnSnapNearestChanged = param.snapNearestChangedFunc;

	if self.isPage then
		mLoopListView.ItemSnapEnable = true;
	end

	if self.OnBeginDrag then
		mLoopListView.mOnBeginDragAction = SafeBind(self.onBeginDrag, self);
	end
	if self.OnDraging then
		mLoopListView.mOnDragingAction = SafeBind(self.onDraging, self);
	end
	if self.OnEndDrag or self.isPage then
		mLoopListView.mOnEndDragAction = SafeBind(self.onEndDrag, self);
	end
	if self.OnSnapNearestChanged then
		mLoopListView.mOnSnapNearestChanged = SafeBind(self.onSnapNearestChanged, self);
	end

	self:initListView()


end




function ScrollListView:ItemPrefabDataList()
	return self.mLoopListView.ItemPrefabDataList
end

function ScrollListView:ItemList()
	return self.mLoopListView.ItemList
end


function ScrollListView:IsVertList()
	return self.mLoopListView.IsVertList
end

function ScrollListView:ItemTotalCount()
	return self.mLoopListView.ItemTotalCount
end

function ScrollListView:ContainerTrans()
	return self.mLoopListView.ContainerTrans
end


function ScrollListView:ScrollRect()
	return self.mLoopListView.ScrollRect
end

function ScrollListView:IsDraging()
	return self.mLoopListView.IsDraging
end

function ScrollListView:ItemSnapEnable()
	return self.mLoopListView.ItemSnapEnable
end


function ScrollListView:SupportScrollBar()
	return self.mLoopListView.SupportScrollBar
end

function ScrollListView:SnapMoveDefaultMaxAbsVec()
	return self.mLoopListView.SnapMoveDefaultMaxAbsVec
end

function ScrollListView:ShownItemCount()
	return self.mLoopListView.ShownItemCount
end


function ScrollListView:ViewPortSize()
	return self.mLoopListView.ViewPortSize
end


function ScrollListView:ViewPortWidth()
	return self.mLoopListView.ViewPortWidth
end

function ScrollListView:ViewPortHeight()
	return self.mLoopListView.ViewPortHeight
end

-- Get the nearest item index with the viewport snap point.
function ScrollListView:CurSnapNearestItemIndex()
	return self.mLoopListView.CurSnapNearestItemIndex + 1
end

----------------------------------------------------------------------

function ScrollListView:GetItemPrefabConfData(prefabName)
	return self.mLoopListView:GetItemPrefabConfData(prefabName);
end

function ScrollListView:OnItemPrefabChanged(prefabName)
	self.mLoopListView:OnItemPrefabChanged(prefabName);
end


function ScrollListView:ResetListView(resetPos)
	self.mLoopListView:ResetListView(resetPos or true);
end

-- /*
-- This method may use to set the item total count of the scrollview at runtime.
-- If this parameter is set -1, then means there are infinite items,
-- and scrollbar would not be supported, and the ItemIndex can be from –MaxInt to +MaxInt.
-- If this parameter is set a value >=0 , then the ItemIndex can only be from 0 to itemTotalCount -1.
-- If resetPos is set false, then the scrollrect’s content position will not changed after this method finished.
-- */
function ScrollListView:SetListItemCount(itemCount, resetPos)
	resetPos = resetPos or true;
	self.totalNum = itemCount;
	local num = self:GetRowNum()
	self.mLoopListView:SetListItemCount(num, resetPos);
end

-- //To get the visible item by itemIndex. If the item is not visible, then this method return null.
function ScrollListView:GetShownItemByItemIndex(itemIndex)
	return self.mLoopListView:GetShownItemByItemIndex(itemIndex -1);
end

function ScrollListView:GetShownItemNearestItemIndex(itemIndex)
	return self.mLoopListView:GetShownItemNearestItemIndex(itemIndex -1);
end


-- /*
-- All visible items is stored in a List<LoopListViewItem2> , which is named mItemList;
-- this method is to get the visible item by the index in visible items list. The parameter index is from 0 to mItemList.Count.
-- */
--function ScrollListView:GetShownItemByIndex(index)
--	return self.mLoopListView:GetShownItemByIndex(index -1)
--end


--function ScrollListView:GetShownItemByIndexWithoutCheck(index)
--	return self.mLoopListView:GetShownItemByIndexWithoutCheck(index -1)
--end

function ScrollListView:GetIndexInShownItemList(item)
	return self.mLoopListView:GetIndexInShownItemList(item)
end

function ScrollListView:DoActionForEachShownItem(action, param)
	self.mLoopListView:DoActionForEachShownItem(action, param)
end

function ScrollListView:NewListViewItem(itemPrefabName)
	return self.mLoopListView:NewListViewItem(itemPrefabName)
end

-- For a vertical scrollrect, when a visible item’s height changed at runtime, then this method should be called to let the LoopListView2 component reposition all visible items’ position.
-- For a horizontal scrollrect, when a visible item’s width changed at runtime, then this method should be called to let the LoopListView2 component reposition all visible items’ position.

function ScrollListView:OnItemSizeChanged(itemIndex)
	self.mLoopListView:OnItemSizeChanged(itemIndex-1)
end


-- To update a item by itemIndex.if the itemIndex-th item is not visible, then this method will do nothing.
-- Otherwise this method will first call onGetItemByIndex(itemIndex) to get a updated item and then reposition all visible items'position. 

function ScrollListView:RefreshItemByItemIndex(itemIndex)
	self.mLoopListView:RefreshItemByItemIndex(itemIndex-1)
end

-- snap move will finish at once.
function ScrollListView:FinishSnapImmediately()
	self.mLoopListView:FinishSnapImmediately()
end

-- This method will move the scrollrect content’s position to ( the positon of itemIndex-th item + offset ),
-- and offset is from 0 to scrollrect viewport size. 

function ScrollListView:MovePanelToItemIndex(itemIndex, offset)
	self.mLoopListView:MovePanelToItemIndex(itemIndex -1 , offset)
end


-- update all visible items.
function ScrollListView:RefreshAllShownItem()
	self.mLoopListView:RefreshAllShownItem();
end


function ScrollListView:RefreshAllShownItemWithFirstIndex(firstItemIndex)
	self.mLoopListView:RefreshAllShownItemWithFirstIndex(firstItemIndex -1);
end



function ScrollListView:RefreshAllShownItemWithFirstIndexAndPos(firstItemIndex, pos)
	self.mLoopListView:RefreshAllShownItemWithFirstIndexAndPos(firstItemIndex -1, pos)
end


function ScrollListView:UpdateAllShownItemSnapData()
	self.mLoopListView:UpdateAllShownItemSnapData()
end
-- Clear current snap target and then the LoopScrollView2 will auto snap to the CurSnapNearestItemIndex.
function ScrollListView:ClearSnapData()
	self.mLoopListView:ClearSnapData()
end

-- moveMaxAbsVec param is the max abs snap move speed, if the value <= 0 then LoopListView2 would use SnapMoveDefaultMaxAbsVec
function ScrollListView:SetSnapTargetItemIndex(itemIndex, moveMaxAbsVec)
	moveMaxAbsVec = moveMaxAbsVec or -1;
	self.mLoopListView:SetSnapTargetItemIndex(itemIndex - 1, moveMaxAbsVec)
end



function ScrollListView:ForceSnapUpdateCheck()
	self.mLoopListView:ForceSnapUpdateCheck()
end


function ScrollListView:UpdateListView(distanceForRecycle0, distanceForRecycle1, distanceForNew0, distanceForNew1)
	self.mLoopListView:UpdateListView()

end



---------------------------custom----------------------
function ScrollListView:onBeginDrag()
	local OnBeginDrag = self.OnBeginDrag;
	if OnBeginDrag then
		OnBeginDrag();
	end
end

function ScrollListView:onDraging()
	local OnDraging = self.OnDraging;
	if OnDraging then
		OnDraging();
	end
end

function ScrollListView:onEndDrag()
	local OnEndDrag = self.OnEndDrag;
	local isPage = self.isPage;
	local mLoopListView = self.mLoopListView;

	if OnEndDrag then
		OnEndDrag();
	end

	if not isPage then
		return
	end
	local vec = mLoopListView.ScrollRect.velocity.x;
	local curNearestItemIndex = mLoopListView.CurSnapNearestItemIndex;
	local item = mLoopListView:GetShownItemByItemIndex(curNearestItemIndex);
	if (not item) then
		mLoopListView.ClearSnapData();
		return;
	end
	if (math.abs(vec) < 50) then
		mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex);
		return;
	end
	local pos = mLoopListView:GetItemCornerPosInViewPort(item, CS.SuperScrollView.ItemCornerEnum.LeftTop);
	if (pos.x > 0) then
		if (vec > 0) then
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex - 1);
		else
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex);
		end

	elseif (pos.x < 0) then
		if (vec > 0) then
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex);
		else
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex + 1);
		end
	else
		if (vec > 0) then
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex - 1);
		else
			mLoopListView:SetSnapTargetItemIndex(curNearestItemIndex + 1);
		end
	end
end

function ScrollListView:onSnapNearestChanged(LoopListView2, LoopListViewItem2)
	local OnSnapNearestChanged = self.OnSnapNearestChanged;
	if OnSnapNearestChanged then
		OnSnapNearestChanged(LoopListView2, LoopListViewItem2);
	end
end

function ScrollListView:GetRowNum()
	local totalNum = self.totalNum;
	local column = self.column;
	local num = math.floor(totalNum / column);
	if totalNum % column > 0 then
		num = num + 1;
	end
	return num
end

function ScrollListView:GetPrefabList()
	local mLoopListView = self.mLoopListView;

	local prefabList = { };
	local ItemPrefabConfDataList = mLoopListView.ItemPrefabDataList
	for k, v in pairs(ItemPrefabConfDataList) do
		local ItemPrefabConfData = { };
		ItemPrefabConfData.mPadding = v.mPadding
		ItemPrefabConfData.mInitCreateCount = v.mInitCreateCount
		ItemPrefabConfData.mStartPosOffset = v.mStartPosOffset
		if not util.IsNil(v.mItemPrefab) then
			ItemPrefabConfData.prefabName = v.mItemPrefab.gameObject.name;
		else
			traceError('LoopListView2 need add itemPrefab')
			return nil;
		end
		table.insert(prefabList, ItemPrefabConfData)
	end
	return prefabList;
end

function ScrollListView:initListView()
	local mLoopListView = self.mLoopListView;
	local column = self.column;
	local getPrefabNameFunc = self.getPrefabNameFunc;
	local viewFunc = self.viewFunc;
	local addClickFunc = self.addClickFunc;

	local prefabList = self:GetPrefabList()
	if not prefabList then
		return;
	end
	local rowNum = self:GetRowNum()
	mLoopListView:InitListView(rowNum, SafeBind( function(listView, index)
		index = index + 1;

		local num = self:GetRowNum()
		if (index < 1 or index > num) then
			return nil;
		end
		local prefabName = ''
		if getPrefabNameFunc then
			prefabName = getPrefabNameFunc(index)
		else
			if prefabList and next(prefabList) then
				local data = Array.begin(prefabList)
				prefabName = data.prefabName
			end
		end
		local item = listView:NewListViewItem(prefabName);
		local childRoot = item.gameObject.transform;
		childRoot.gameObject.name = index
		if (item.IsInitHandlerCalled == false) then
			item.IsInitHandlerCalled = true;
			if addClickFunc then
				if column > 1 then
					local childNum = childRoot.childCount
					for i = 1, childNum do
						local childObj = childRoot:GetChild(i - 1)
						local listener = CS.SuperScrollView.ClickEventListener.Get(childObj.gameObject);
						listener:SetClickEventHandler(SafeBind2( function(obj)
							local parent = obj.transform.parent;
							local parentIndex = tonumber(parent.gameObject.name);
							local t =(parentIndex - 1) * childNum + i;
							addClickFunc(obj, t, i)
						end ));
					end
				else
					local listener = CS.SuperScrollView.ClickEventListener.Get(childRoot.gameObject);
					listener:SetClickEventHandler(SafeBind2( function(obj)
						local parentIndex = tonumber(obj.gameObject.name);
						addClickFunc(obj, parentIndex);
					end ));
				end
			end
		end
		totalNum = self.totalNum;
		if column > 1 then
			local childNum = childRoot.childCount
			for i = 1, childNum do
				local itemIndex =(index - 1) * column + i;
				local childObj = childRoot:GetChild(i - 1)
				if itemIndex <= totalNum then
					childObj.gameObject:SetActive(true)
					if viewFunc then
						viewFunc(childObj, itemIndex);
					end
				else
					childObj.gameObject:SetActive(false)
				end
			end
		else
			local itemIndex = index;
			if itemIndex <= totalNum then
				childRoot.gameObject:SetActive(true)
				if viewFunc then
					viewFunc(childRoot, itemIndex);
				end
			else
				childRoot.gameObject:SetActive(false)
			end
		end
		return item
	end ), self.initParam);
end


return ScrollListView
