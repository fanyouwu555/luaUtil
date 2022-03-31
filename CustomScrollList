local CustomScrollList = class("CustomScrollList");
-- Introduction: 无限列表
-- Content上禁止挂载ContentSizeFilter和LayOutGroup之类组件
function CustomScrollList:ctor()

	------------公开的-----------
	self.onItemRender = nil;
	-- 排序方式
	self.Arrangement =
	{
		-- <summary>
		-- 横排
		-- </summary>
		Horizontal = 0,
		-- <summary>
		-- 竖排
		-- </summary>
		Vertical = 1
	}

	-- <summary>
	-- 水平对齐
	-- </summary>
	self.HorizontalAlign =
	{
		-- <summary>
		-- 居左
		-- </summary>		
		Left = 0;
		-- <summary>
		-- 居中
		-- </summary>
		Middle = 1,

		-- <summary>
		-- 局右
		-- </summary>
		Right = 2,
	}




	-- <summary>
	-- 垂直对齐
	-- </summary>
	self.VerticalAlign =
	{
		-- <summary>
		-- 居上
		-- </summary>
		Top = 0,

		-- <summary>
		-- 居中
		-- </summary>
		Middle = 1,

		-- <summary>
		-- 局下
		-- </summary>
		Bottom = 2,
	}
	-- <summary>
	-- 行距
	-- </summary>
	self.rowSpace = 0;

	-- <summary>
	-- 列距
	-- </summary>
	self.columuSpace = 0;


	-- <summary>
	-- 边缘留空 上
	-- </summary>
	self.marginTop = 0;

	-- <summary>
	-- 边缘留空 下
	-- </summary>
	self.marginBottom = 0;

	-- <summary>
	-- 边缘留空 左
	-- </summary>
	self.marginLeft = 0;

	-- <summary>
	-- 边缘留空 右
	-- </summary>
	self.marginRight = 0;



	self.arrangement = self.Arrangement.Vertical;
	self.horizontalAlign = self.HorizontalAlign.Left;
	self.verticalAlign = self.VerticalAlign.Top;

	-----------------私有的-----------------------

	self.item = nil;
	self.scrollRect = nil;
	self.viewPort = nil;
	self.content = nil;
	self.itemSize = nil;
	self.items = { };
	--contains  key = dataIndex,value = viewIndex
	self.contains = { };
	-- 视图外的viewIndex
	self.outOfContains = {};
	-- //需要渲染的总数据个数
	self.childCount = 0;
	-- //当前第一个元素索引
	self.scrollLineIndex = 0;
	-- //在UI中显示的个数(不乘以maxPerLine)
	self.totalCount = 0;
	-- //第一个元素所在位置
	self.startPos = nil;
	-- //当前渲染起始坐标
	self.startIndex = 0;
	-- //当前渲染结束坐标
	self.endIndex = 0;
	self.maxPerLine = 0;

	self.valueChangedFunc = nil;
end

-- 必须绑定ugui创建的ScrollView;
function CustomScrollList:SetScrollView(value)
	self.gameObject = value;
	self.transform = value.transform
end
-- <summary>
-- 渲染子节点
-- </summary>
function CustomScrollList:SetChild(value)
	self:SetItem(value);
end

function CustomScrollList:GetChild()
	return self.item;
end

-- <summary>
-- 总个数
-- </summary>
function CustomScrollList:SetChildTotalCount(value)
	self:SetChildCount(value, true);
end

function CustomScrollList:GetChildTotalCount()
	return self.childCount;
end

-- <summary>
-- 设置显示窗口大小
-- </summary>
function CustomScrollList:SetViewPortSize(value)
	self:SetViewPort(value);
end

function CustomScrollList:GetViewPortSize()
	return self.viewPort;
end


function CustomScrollList.create(...)
	local temp = CustomScrollList.new(...);
	return temp;
end

function CustomScrollList:initView()
	if self.maxPerLine == 0 then
		self.maxPerLine = 1
	end
	self.items = { };
	self.contains = { };
	self.outOfContains = { };
	self.scrollRect = self.transform:GetComponent('ScrollRect');
	if self.scrollRect.vertical == true then
		self.arrangement = self.Arrangement.Vertical;
	else
		self.arrangement = self.Arrangement.Horizontal;
	end
	self.content = self.scrollRect.content:GetComponent('RectTransform')
	if (not self.content) then
		trace("ScrollRect " .. self.scrollRect.gameObject.name .. " Has No Content, Please Check And Retry.");
		return;
	end
	local rectTransform = self.transform:GetComponent('RectTransform')

	self.viewPort = rectTransform.rect.size;

	self.content.anchorMax = CS.UnityEngine.Vector2(0, 1);
	self.content.anchorMin = CS.UnityEngine.Vector2(0, 1);
	self.content.pivot = CS.UnityEngine.Vector2(0, 1);
	self:ReBuild();
end


-- <summary>
-- 当子节点、Mask、maxPerLine
-- </summary>
function CustomScrollList:ReBuild()
	if ((self.scrollRect == nil) or(self.content == nil) or(self.item == nil)) then
		return;
	end
	self:ResetChildren();

	local maskSize = self.viewPort;
	local count = 0;
	if (self.arrangement == self.Arrangement.Horizontal) then
		-- 横向列数
		count = math.ceil(maskSize.x / self.itemSize.x) + 1;
		self.startPos = CS.UnityEngine.Vector2.zero;
		self.startPos.x = self.marginLeft;
		if (self.verticalAlign == self.VerticalAlign.Top) then
			self.startPos.y = - self.marginTop;
		elseif (self.verticalAlign == self.VerticalAlign.Middle) then
			self.startPos.y = -(maskSize.y * 0.5 -(self.itemSize.y * self.maxPerLine +(self.maxPerLine - 1) * self.rowSpace) * 0.5);
		elseif (self.verticalAlign == self.VerticalAlign.Bottom) then
			self.startPos.y = -(maskSize.y - self.marginBottom - self.itemSize.y * self.maxPerLine - self.rowSpace *(self.maxPerLine - 1));
		end
	elseif (self.arrangement == self.Arrangement.Vertical) then
		-- //竖向行数
		count = math.ceil(maskSize.y / self.itemSize.y) + 1;
		self.startPos = CS.UnityEngine.Vector2.zero;
		-- //重置开始节点位置
		self.startPos.y = - self.marginTop;
		if (self.horizontalAlign == self.HorizontalAlign.Left) then

			self.startPos.x = self.marginLeft;

		elseif (self.horizontalAlign == self.HorizontalAlign.Middle) then

			self.startPos.x =(maskSize.x * 0.5 -(self.itemSize.x * self.maxPerLine +(self.maxPerLine - 1) * self.columuSpace) * 0.5);

		elseif (self.horizontalAlign == self.HorizontalAlign.Right) then

			self.startPos.x = maskSize.x - self.marginRight - self.itemSize.x * self.maxPerLine - self.columuSpace *(self.maxPerLine - 1);
		end

	end
	self.totalCount = count;

	self:SetChildCount(self.childCount, true);
--	self:BackTop();

	self.scrollRect.onValueChanged:RemoveAllListeners();
	self.scrollRect.onValueChanged:AddListener(SafeBind(self.OnValueChanged, self));
end

function CustomScrollList:AddValueChangedFunc(func)
	self.valueChangedFunc = func;
end

-- <summary>
-- 列表滚动
-- </summary>
-- <param name="vec"></param>
function CustomScrollList:OnValueChanged(vec)
	if (self.arrangement == self.Arrangement.Horizontal) then
		vec.x = CS.UnityEngine.Mathf.Clamp(vec.x, 0, 1);
		if self.valueChangedFunc then
			self.valueChangedFunc(vec.x);
		end
	elseif (self.arrangement == self.Arrangement.Vertical) then
		vec.y = CS.UnityEngine.Mathf.Clamp(vec.y, 0, 1);
		if self.valueChangedFunc then
			self.valueChangedFunc(vec.y);
		end
	end
	local curLineIndex = self:GetCurLineIndex();
	if (curLineIndex ~= self.scrollLineIndex) then
		self:UpdateRectItem(curLineIndex, false);
	end
end

-- <summary>
-- 获取页面第一行索引
-- </summary>
-- <returns></returns>
function CustomScrollList:GetCurLineIndex()

	if (self.arrangement == self.Arrangement.Horizontal) then
		local tmp = 0;
		if self.content.anchoredPosition.x < 0.1 then
			tmp = self.content.anchoredPosition.x;
		else
			tmp = 0.1 - self.marginLeft;
		end
		return math.floor(math.abs(tmp /(self.columuSpace + self.itemSize.x)))
	elseif (self.arrangement == self.Arrangement.Vertical) then
		local tmp = 0;
		if self.content.anchoredPosition.y > -0.1 then
			tmp = self.content.anchoredPosition.y;
		else
			tmp = -0.1 - self.marginTop;
		end
		return math.floor(math.abs(tmp /(self.rowSpace + self.itemSize.y)))
	end
	return 0;
end


-- <summary>
-- 更新数据（待修改问出现的才刷新）
-- </summary>
-- <param name="curLineIndex"></param>
-- <param name="forceRender"></param>
function CustomScrollList:UpdateRectItem(curLineIndex, forceRender)

	if (curLineIndex < 0) then
		return;
	end
	self.startIndex = curLineIndex * self.maxPerLine;
	self.endIndex =(curLineIndex + self.totalCount) * self.maxPerLine;
	if (self.endIndex >= self.childCount) then
		self.endIndex = self.childCount;
	end
	-- 渲染序号
	self.contains = { };
	-- //items的索引.
	self.outOfContains = { };
	-- //如果当前已渲染的item中包含
	for i = 1, #self.items do
		local index = tonumber(self.items[i].gameObject.name);
		if (index < self.startIndex or index >= self.endIndex) then

			table.insert(self.outOfContains, i);
			self.items[i].gameObject:SetActive(false);

		else
			self.items[i].gameObject:SetActive(true);
			self.contains[tostring( index)] = i;
		end
	end

	-- *************更改渲染****************
	for i = self.startIndex, self.endIndex - 1 do
		if (not self.contains[tostring(i)]) then
			local child = self.items[self.outOfContains[1]];
			table.remove(self.outOfContains,1);
			child.gameObject:SetActive(true);
			local row = math.floor( i / self.maxPerLine);
			local col = math.fmod (i, self.maxPerLine);
			if (self.arrangement == self.Arrangement.Vertical) then
				local ps = self.startPos + CS.UnityEngine.Vector2(col * self.itemSize.x +(col) * self.columuSpace, - row * self.itemSize.y -(row) * self.rowSpace);
				child.localPosition =  CS.UnityEngine.Vector3(ps.x,ps.y,0);
			else
				local ps = self.startPos + CS.UnityEngine.Vector2(row * self.itemSize.x +(row) * self.columuSpace, - col * self.itemSize.y -(col) * self.rowSpace);
				child.localPosition =  CS.UnityEngine.Vector3(ps.x,ps.y,0);
			end
			child.gameObject.name = tostring(i);
			if (self.onItemRender) then
				self.onItemRender(i, child);
			end

		elseif (forceRender) then

			if (self.onItemRender) then
				self.onItemRender(i, self.items[self.contains[tostring(i)]]);
			end
		end
	end

	self.scrollLineIndex = curLineIndex;
end
-- <summary>
-- 移除当前所有
-- </summary>
function CustomScrollList:ResetChildren()

	self.items = { };
	for i = 0, self.content.childCount - 1 do
		local child = self.content:GetChild(i);
		child.gameObject:SetActive(false);
	end
end

-- <summary>
-- 创建新节点
-- </summary>
-- <param name="index"></param>
function CustomScrollList:CreateItem(index)

	local child = nil;
	if (self.content.childCount > index) then
		child = self.content:GetChild(index);
	else
		local item = self:GetChild();
		local obj = CS.UnityEngine.GameObject.Instantiate(item);
		obj.transform:SetParent(self.content);
		obj.transform.localScale = CS.UnityEngine.Vector3.one;
		child = obj.transform;
	end
	child.gameObject.name = tostring(index);
	table.insert(self.items, child);
	return child:GetComponent('RectTransform');
end

-- <summary>
-- 设置资源
-- </summary>
-- <param name="child"></param>
function CustomScrollList:SetItem(child)

	if (child == nil) then
		return;
	end
	self.item = child;
	local itemTrans = child.transform:GetComponent('RectTransform');
	itemTrans.pivot = CS.UnityEngine.Vector2(0, 1);
	self.itemSize = itemTrans.sizeDelta;
	self:ReBuild();
end
-- <summary>
-- 更新需要渲染的个数
-- </summary>
-- <param name="value"></param>
function CustomScrollList:SetChildCount(value, forceRender)

	if (value < 0) then
		self.childCount = 0;
	else
		self.childCount = value;
	end
	-- 还未初始化
	if (self.totalCount <= 0) then
		return;
	end
	if (value > #self.items and #self.items < self.maxPerLine * self.totalCount) then

		-- 当前格子数量少于应生成的数量
		local count = #self.items;
		local max = 0;
		if value < self.maxPerLine * self.totalCount then
			max = value
		else
			max = self.maxPerLine * self.totalCount;
		end
		for i = count, max - 1 do
			local row = math.floor( i / self.maxPerLine);
			local col = math.fmod (i, self.maxPerLine);
			local child = self:CreateItem(i);
			if (self.arrangement == self.Arrangement.Vertical) then
				local ps = self.startPos + CS.UnityEngine.Vector2(col * self.itemSize.x +(col) * self.columuSpace, - row * self.itemSize.y -(row) * self.rowSpace);
				child.localPosition = CS.UnityEngine.Vector3(ps.x,ps.y,0)
			else
				local ps = self.startPos + CS.UnityEngine.Vector2(row * self.itemSize.x +(row) * self.columuSpace, - col * self.itemSize.y -(col) * self.rowSpace);
				child.localPosition = CS.UnityEngine.Vector3(ps.x,ps.y,0)
			end
		end
	end

	if (self.content == nil) then
		return;
	end
	-- 设置self.content的大小
	local rc = math.ceil(self.childCount / self.maxPerLine);
	if (self.arrangement == self.Arrangement.Horizontal) then

		self.content.sizeDelta = CS.UnityEngine.Vector2(self.marginLeft + self.marginRight + self.itemSize.x * rc + self.columuSpace *(rc - 1),
		self.viewPort.y);
		if (self.content.sizeDelta.x > self.viewPort.x and self.content.anchoredPosition.x < self.viewPort.x - self.content.sizeDelta.x) then
			self.content.anchoredPosition = CS.UnityEngine.Vector2(self.viewPort.x - self.content.sizeDelta.x, self.content.anchoredPosition.y);
		end
	else

		self.content.sizeDelta = CS.UnityEngine.Vector2(self.viewPort.x, self.marginTop + self.marginBottom + self.itemSize.y * rc + self.rowSpace *(rc - 1));
		if (self.content.sizeDelta.y > self.viewPort.y and self.content.anchoredPosition.y > self.content.sizeDelta.y - self.viewPort.y) then
			self.content.anchoredPosition = CS.UnityEngine.Vector2(self.content.anchoredPosition.x, self.content.sizeDelta.y - self.viewPort.y);
		end
	end
	self:UpdateRectItem(self:GetCurLineIndex(), true);
end


-- <summary>
-- 添加子节点
-- </summary>
-- <param name="index"></param>
function CustomScrollList:AddChild(index)

	if (index < 0) then
		return;
	end
	self.startIndex = self.scrollLineIndex * self.maxPerLine;
	self.endIndex =(self.scrollLineIndex + self.totalCount) * self.maxPerLine;
	self:SetChildCount(self.childCount + 1, index >= self.startIndex and index < self.endIndex);
	self:RefreshView();
end


-- <summary>
-- 删除子节点
-- </summary>
-- <param name="index"></param>
function CustomScrollList:RemoveChild(index)

	if (index < 0 or index >= self.childCount) then
		return;
	end
	self.startIndex = self.scrollLineIndex * self.maxPerLine;
	self.endIndex =(self.scrollLineIndex + self.totalCount) * self.maxPerLine;
	self:SetChildCount(self.childCount - 1, index >= self.startIndex and index < self.endIndex);
	self:RefreshView();
end


--强制刷新显示的子节点位置
function CustomScrollList:RefreshView()
	for k,child in pairs (self.items )do
		local i = tonumber(child.gameObject.name);
		local row = math.floor( i / self.maxPerLine);
		local col = math.fmod (i, self.maxPerLine);
		if (self.arrangement == self.Arrangement.Vertical) then
			local ps = self.startPos + CS.UnityEngine.Vector2(col * self.itemSize.x +(col) * self.columuSpace, - row * self.itemSize.y -(row) * self.rowSpace);
			child.localPosition =  CS.UnityEngine.Vector3(ps.x,ps.y,0);

		else
			local ps = self.startPos + CS.UnityEngine.Vector2(row * self.itemSize.x +(row) * self.columuSpace, - col * self.itemSize.y -(col) * self.rowSpace);
			child.localPosition =  CS.UnityEngine.Vector3(ps.x,ps.y,0);
		end
		child.gameObject.name = tostring(i);
	end
end
-- <summary>
-- 设置显示窗口大小(现在貌似可以废弃了)
-- </summary>
-- <param name="port"></param>
function CustomScrollList:SetViewPort(port)

	if (port == viewPort) then
		return;
	end
	self.viewPort = port;
	self:ReBuild();
end

-- <summary>
-- 设置行列最大
-- </summary>
-- <param name="max"></param>
function CustomScrollList:SetMaxPerLine(max)

	self.maxPerLine = max;
	self:ReBuild();
end

-- <summary>
-- 返回顶部
-- </summary>
function CustomScrollList:BackTop()
	self.content.localPosition = CS.UnityEngine.Vector3.zero;
	self:UpdateRectItem(0, true);
end

-- <summary>
-- 返回底部
-- </summary>
function CustomScrollList:BackBottom()
	if (self.arrangement == self.Arrangement.Vertical) then
		self.content.localPosition = CS.UnityEngine.Vector3(0, - self.viewPort.y + self.content.sizeDelta.y, 0);
	else
		self.content.localPosition = CS.UnityEngine.Vector3(self.viewPort.x - self.content.sizeDelta.x, 0);
	end
	self:UpdateRectItem(math.ceil(self.childCount / self.maxPerLine) - self.totalCount + 1, true);
end

function CustomScrollList:RefreshViewItem()
	self:UpdateRectItem(self.scrollLineIndex, true);
end

function CustomScrollList:SetArrangement(arr)
	self.arrangement = arr;
end

function CustomScrollList:SetHorizontal(h)
	self.horizontalAlign = h;
end

function CustomScrollList:SetVerticle(v)
	self.verticalAlign = v;
end

-----------------------------------pageView------------------------------

--设定为翻页模式
function CustomScrollList:SetPageViewState(func)
	self.pageviewState = true;
	-- //滑动的起始坐标
	self.targethorizontal = 0;
	-- //是否拖拽结束
	self.isDrag = false;
	-- //求出每页的临界角，页索引从0开始
	self.posList = { };
	self.currentPageIndex = 0;
	self.OnPageChanged = func;

	self.stopMove = true;
	-- //滑动速度
	self.smooting = 1;
	--滑动翻页敏感度
	self.sensitivity = 1;
	self.startTime = 0;

	self.startDragHorizontal = 0;
	self:addDragDropEvent();
	self:initPageView();
	MainValue.RegUpdate(MainValue,self);

end

--设置为嵌套模式 传入父节点的scrollRect 只有子节点需要加
function CustomScrollList:setNestScrollListModel(scrollRect)
	self.anotherScrollRect = scrollRect;
	self:addDragDropEvent();
	self.isNestScrollRect = true;
end


--添加拖拽事件
function CustomScrollList:addDragDropEvent()
	local DragDropEvents = self.transform:GetComponent('DragDropEvents');
	if not DragDropEvents then
		DragDropEvents = self.gameObject:AddComponent( typeof( CS.DragDropEvents ) );
	end
	if DragDropEvents then
		DragDropEvents.OnBeginDragAction = SafeBind( self.OnBeginDrag,self);
		DragDropEvents.OnEndDragAction = SafeBind( self.OnEndDrag,self);
		DragDropEvents.OnDragAction = SafeBind( self.OnDrag,self);
	end
end

--移除注册的update 不用的时候一定要调用
function CustomScrollList:removeScrollList()
	MainValue.UnRegUpdate(MainValue, self);
end

--初始化翻页
function CustomScrollList:initPageView()

	self.viewWidth = self:getViewWidth()
	local x = self.columuSpace;
	--未显示的长度
	local horizontalLength = self:getContentWidth() - self.viewWidth;
	for i = 0, self.childCount - 1 do
		local tmp = ((self.viewWidth + x) * i / horizontalLength) 
		self.posList[i] = (tmp);
	end
end

function CustomScrollList:getViewWidth()
	local v =  self.transform:GetComponent('RectTransform').rect
	if (self.arrangement == self.Arrangement.Horizontal) then
		return v.width
	else
		return v.height
	end
end

function CustomScrollList:getContentWidth()
	local v = self.content.rect
	if (self.arrangement == self.Arrangement.Horizontal) then
		return v.width
	else
		return v.height
	end
end

function CustomScrollList:getNormalizedPosition()
	if (self.arrangement == self.Arrangement.Horizontal) then
		return self.scrollRect.horizontalNormalizedPosition; 
	else
		return self.scrollRect.verticalNormalizedPosition; 
	end
end

function CustomScrollList:OnBeginDrag(eventData)
	if self.isNestScrollRect then
		self.anotherScrollRect.scrollRect:OnBeginDrag (eventData);
		self.anotherScrollRect:OnBeginDrag (eventData);
	end
	if not self.pageviewState then
		return
	end
	self.isDrag = true;
	self.startDragHorizontal = self:getNormalizedPosition()

end

function CustomScrollList:OnEndDrag(eventData)
	
	if self.isNestScrollRect then
		self.anotherScrollRect.scrollRect:OnEndDrag (eventData);
		self.anotherScrollRect:OnEndDrag (eventData);
		self.anotherScrollRect.scrollRect.enabled = true;
		--self.scrollRect.enabled = true;
	end
	if not self.pageviewState then
		return
	end

	local posX = self:getNormalizedPosition()
	posX = posX +((posX - self.startDragHorizontal) * self.sensitivity);
	if posX > 1 then
		posX = 1;
	end
	if posX < 0 then
		posX = 0;
	end
	local index = 0;
	local offset = CS.UnityEngine.Mathf.Abs(self.posList[index] - posX);
	for i = 1, table.nums(self.posList) - 1 do
		local temp = CS.UnityEngine.Mathf.Abs(self.posList[i] - posX);
		if (temp < offset) then
			index = i;
			offset = temp;
		else
			break;
		end
	end
	self:SetPageIndex(index);
	self:StopMove(index);
end

function CustomScrollList:OnDrag(eventData)
	if self.isNestScrollRect then
		self.anotherScrollRect.scrollRect:OnDrag(eventData);
		self.anotherScrollRect:OnDrag(eventData);
		local delta = eventData.delta;
		if (self.arrangement == self.Arrangement.Horizontal) then
			local dir = math.abs(delta.x) > math.abs(delta.y)
--			self.scrollRect.enabled = dir;
			self.anotherScrollRect.scrollRect.enabled = not dir ;
		else
			local dir = math.abs(delta.y) > math.abs(delta.x)
--			self.scrollRect.enabled = dir;
			self.anotherScrollRect.scrollRect.enabled = not dir ;
		end
	end

	if not self.pageviewState then
		return
	end

end




function CustomScrollList:Update() 
	if not self.pageviewState then
		return
	end
	if not self.scrollRect or  util.IsNil(self.scrollRect) then
		self:removeScrollList();
		return
	end
	if (not self.isDrag and not self.stopMove) then
		self.startTime = CS.UnityEngine.Time.deltaTime + self.startTime;
		local t = self.startTime * self.smooting;

	if (self.arrangement == self.Arrangement.Horizontal) then
		self.scrollRect.horizontalNormalizedPosition = CS.UnityEngine.Mathf.Lerp(self:getNormalizedPosition(), self.targethorizontal, t);
	else
		self.scrollRect.verticalNormalizedPosition = CS.UnityEngine.Mathf.Lerp(self:getNormalizedPosition(), self.targethorizontal, t);
	end

		if (t >= 1) then
			self.stopMove = true;
		end
	end
end


function CustomScrollList:pageTo(index) 
	if (index >= 0 and index < table.nums(self.posList)) then
		self.targethorizontal = self.posList[index];
		self.currentPageIndex = index;
		self:StopMove(index);
		if (self.arrangement == self.Arrangement.Horizontal) then
			self.scrollRect.horizontalNormalizedPosition =  self.targethorizontal
		else
			self.scrollRect.verticalNormalizedPosition = self.targethorizontal
		end
		if self.OnPageChanged then
			self.OnPageChanged(index);
		end
	else
		trace('no page '.. index);
	end
end

function CustomScrollList:turnLeft() 
	if self.currentPageIndex then
		self:pageTo(self.currentPageIndex - 1);
	end
end

function CustomScrollList:turnRight() 
	if self.currentPageIndex then
		self:pageTo(self.currentPageIndex + 1);
	end
end


function CustomScrollList:SetPageIndex (index) 
	if self.currentPageIndex ~= index then
		self.currentPageIndex = index;
		if self.OnPageChanged then
			self.OnPageChanged(index);
		end
	end
end

function CustomScrollList:StopMove( index )
	 --设置当前坐标，更新函数进行插值  
	self.targethorizontal = self.posList[index];
	self.isDrag = false;
	self.startTime = 0;
	self.stopMove = false;

end
return CustomScrollList
