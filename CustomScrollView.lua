local CustomScrollView = class("CustomScrollView");

function CustomScrollView.create()
	local temp = CustomScrollView.new();
	return temp;
end


function CustomScrollView:ctor()
	self:ResetItemData()
	MainValue.RegUpdate(MainValue,self);
end

function CustomScrollView:Destroy()
	self:ResetItemData();
	MainValue.UnRegUpdate(MainValue,self);
end


function CustomScrollView:ResetItemData()
	self.addItemIndex = 0;
	self.addItemDefaultNum = 1;
	self.totalNum = 0;
	self.itemsList = {};
	self.addItemState = false;
	self.dirctor = 1;--1是往上滑动,-1 往下滑动
end

---------SetData------------
--@ totalNum 创建的总数量
--@ DefNum 默认创建数
--@ scrollRect 
--@ func
---------------------
function CustomScrollView:SetData(totalNum,DefNum,scrollRect,func)
	self:ResetItemData();
	self.totalNum = totalNum or 1;
	self.addItemDefaultNum = DefNum or 1;
	self.func = func;
	self.addItemState = true;
	self.posY = 0;
	scrollRect.onValueChanged:RemoveAllListeners();
	scrollRect.onValueChanged:AddListener(SafeBind( function(v)
		local pos = scrollRect.content.anchoredPosition; 
		if self.posY > pos.y then
			self.dirctor = -1;
		else
			self.dirctor = 1; 
		end
		self.posY = pos.y;
		if self.addItemState == true then
			self:UpdateItem()
		end
		
	end));

end

--index设置到指定的位置,area 上下分别刷出的item
function CustomScrollView:SetToTargetItem(index,area)
	local minStep = index - area;
	local maxStep = index + area;
	if minStep < 1 then
		minStep = 1;
	end
	if maxStep > self.totalNum then
		maxStep = self.totalNum;
	end
	self.addItemIndex = minStep - 1;
	for i = minStep,maxStep do 
		self:UpdateItem();
	end
end

function CustomScrollView:Update()
	if (self.addItemState == false) or ( self.addItemIndex >= self.addItemDefaultNum) then
		return
	end
	for i = 1 , self.addItemDefaultNum do
		self:UpdateItem()
	end

end

function CustomScrollView:UpdateItem()
	if (self.addItemState == false) then
		return
	end
	self.addItemIndex = self.addItemIndex + self.dirctor;
--	dump(self.addItemIndex,'addItemIndex----')
--	dump(Array.size(self.itemsList),'Array.size(self.itemsList)----')
	if Array.size(self.itemsList) <= self.totalNum then
		if self.addItemIndex > self.totalNum  then
			self.addItemIndex = 1;
		end
		if self.addItemIndex <= 0  then
			self.addItemIndex = self.totalNum
		end
		if Array.size(self.itemsList) == self.totalNum then
			self.addItemState = false;
		end
	end
	local isExist = Array.find(self.itemsList,function(value) return value == self.addItemIndex end);
	if isExist then
		self:UpdateItem();
	else
--		dump(self.addItemIndex)
		table.insert(self.itemsList,self.addItemIndex)
		self:AddItem(self.addItemIndex)
	end
end

function CustomScrollView:AddItem(index)
	if self.func then
		self.func(index);
	end
end

return CustomScrollView;
