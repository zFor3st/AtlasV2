do
    local player = game.Players.LocalPlayer

    local character = player.Character or player.CharacterAdded:Wait()
    character:WaitForChild("Humanoid")
    character:WaitForChild("HumanoidRootPart")

    local ScreenGui = Instance.new("ScreenGui")
    local ImageButton = Instance.new("ImageButton")

    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    ImageButton.Parent = ScreenGui
    ImageButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ImageButton.Position = UDim2.new(0.120833337, 0, 0.0952890813, 0)
    ImageButton.Size = UDim2.new(0, 50, 0, 50)
    ImageButton.Image = "rbxassetid://6472991735"
    ImageButton.MouseButton1Click:connect(
        function()
            game:GetService("Players").LocalPlayer.PlayerGui.HIDDEN.Enabled =
                not game:GetService("Players").LocalPlayer.PlayerGui.HIDDEN.Enabled
        end
    )
end

do
    Library = {
        Size = {
            ["Windows"] = UDim2.new(0, 550, 0, 600),
            ["Mobile"] = UDim2.new(0, 585, 0, 320)
        }
    }

    Intitalized = false
end

do
    TextService = game:GetService("TextService")
    TweenService = game:GetService("TweenService")
    userInputService = game:GetService("UserInputService")
    InputService = userInputService
    CoreGui = game:GetService("Players").LocalPlayer.PlayerGui or game:GetService("CoreGui")
    Mouse = game:GetService("Players").LocalPlayer:GetMouse()
end

tween = {}
do
    local function CreateTweenObject(instance, tweenInfo, properties)
        local tween = TweenService:Create(instance, tweenInfo, properties)

        local tweenObject = {
            Tween = tween,
            Instance = instance,
            TweenInfo = tweenInfo,
            Properties = properties
        }

        function tweenObject:start()
            self.Tween:Play()
        end

        function tweenObject:pause()
            self.Tween:Pause()
        end

        function tweenObject:stop()
            self.Tween:Cancel()
        end

        function tweenObject:wait()
            self.Tween.Completed:Wait()
        end

        return tweenObject
    end

    function tween.new(instance, tweenInfo, properties)
        assert(typeof(instance) == "Instance", "First argument must be a valid Instance")
        assert(typeof(tweenInfo) == "TweenInfo", "Second argument must be a TweenInfo object")
        assert(typeof(properties) == "table", "Third argument must be a table of properties")

        return CreateTweenObject(instance, tweenInfo, properties)
    end

    function tween:CreateTween(instance, tweenInfo, properties, play)
        local tweenObject = self.new(instance, tweenInfo, properties)
        if play then
            tweenObject:start()
        end
        return tweenObject.Tween
    end

    function tween:TweenWithCallback(instance, tweenInfo, properties, callback)
        local tween = self:CreateTween(instance, tweenInfo, properties, true)

        tween.Completed:Connect(
            function()
                if callback and typeof(callback) == "function" then
                    callback()
                end
            end
        )

        return tween
    end

    function tween:TweenAndWait(instance, tweenInfo, properties)
        local tween = self:CreateTween(instance, tweenInfo, properties, true)
        tween.Completed:Wait()
        return tween
    end
end

Library.safeCallback = function(callback)
    return function(...)
        local success, result = pcall(callback, ...)
        if not success then
            warn("Error occurred in callback: " .. result)
        end
        return result
    end
end

Library.isMouseInsideFrame = function(frame)
    local mousePosition = userInputService:GetMouseLocation()
    local framePosition = frame.AbsolutePosition
    local frameSize = frame.AbsoluteSize

    return mousePosition.X >= framePosition.X and mousePosition.X <= framePosition.X + frameSize.X and
        mousePosition.Y >= framePosition.Y and
        mousePosition.Y <= framePosition.Y + frameSize.Y
end

Library.isTouchInsideFrame = function(input, myFrame)
    local touchPosition = input.Position
    local framePosition = myFrame.AbsolutePosition
    local frameSize = myFrame.AbsoluteSize

    local isTouchInside =
        touchPosition.X >= framePosition.X and touchPosition.X <= framePosition.X + frameSize.X and
        touchPosition.Y >= framePosition.Y and
        touchPosition.Y <= framePosition.Y + frameSize.Y

    if isTouchInside then
        return true
    end
    return false
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

Library.MakeDraggable = function(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos =
            UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        local Tween = TweenService:Create(object, TweenInfo.new(0.2), {Position = pos})
        Tween:Play()
    end

    topbarobject.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                        end
                    end
                )
            end
        end
    )

    topbarobject.InputChanged:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                DragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if input == DragInput and Dragging then
                Update(input)
            end
        end
    )
end

Library.updateCanvasSize = function(scrollFrame, listLayout, uiPadding)
    local paddingY = uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + paddingY)

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
        Library.safeCallback(
            function()
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + paddingY)
            end
        )
    )
end

Library.ApplyHoverEffect = function(clickFrame, textLabel)
    local function updateTextTransparency(transparency)
        tween.new(
            textLabel,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {TextTransparency = transparency}
        ):start()
    end

    clickFrame.InputBegan:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                updateTextTransparency(0)
            end
        end
    )

    clickFrame.InputEnded:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                updateTextTransparency(0.5)
            end
        end
    )
end

Library.newWindow = function(data)
    local a = data or {Title = "Skynet Library"}
    _G.DropdownAreOpened = false
    local funcs = {}

    local lib = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Container = Instance.new("Frame")
    local Tabs = Instance.new("Frame")
    local Scroll = Instance.new("ScrollingFrame")
    local UISorter = Instance.new("UIListLayout")
    local BaseSections = Instance.new("Frame")
    local UIPageLayout = Instance.new("UIPageLayout")
    local PageLists = Instance.new("Folder")
    local MainFramepadding = Instance.new("UIPadding")
    local TabPadding = Instance.new("UIPadding")

    lib.Name = "HIDDEN"
    lib.Parent = CoreGui

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = lib
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Position = UDim2.new(0.0682474896, 0, 0.083622247, 0)
    MainFrame.Selectable = true
    MainFrame.Size = UDim2.new(0, 585, 0, 320)

    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    MainFramepadding.Parent = MainFrame
    MainFramepadding.PaddingBottom = UDim.new(0, 0)
    MainFramepadding.PaddingLeft = UDim.new(0, 8)
    MainFramepadding.PaddingRight = UDim.new(0, 8)
    MainFramepadding.PaddingTop = UDim.new(0, 5)

    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.Active = true
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Position = UDim2.new(0.5, 0, 0.5, 15)
    Container.Size = UDim2.new(1, 0, 1, -45)

    BaseSections.Name = "BaseSections"
    BaseSections.Parent = Container
    BaseSections.AnchorPoint = Vector2.new(0.5, 0.5)
    BaseSections.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BaseSections.BackgroundTransparency = 1.000
    BaseSections.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BaseSections.BorderSizePixel = 0
    BaseSections.Position = UDim2.new(0.5, 0, 0.5, 15)
    BaseSections.ClipsDescendants = true
    BaseSections.Size = UDim2.new(1, 0, 1, -30)

    PageLists.Name = "PageLists"
    PageLists.Parent = BaseSections

    UIPageLayout.Parent = PageLists
    UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIPageLayout.EasingStyle = Enum.EasingStyle.Linear
    UIPageLayout.TweenTime = 0.2

    Tabs.Name = "Tabs"
    Tabs.Parent = Container
    Tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tabs.BackgroundTransparency = 1.000
    Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Tabs.BorderSizePixel = 0
    Tabs.Size = UDim2.new(0.2, 0, 1, 0)

    Scroll.Name = "Scroll"
    Scroll.Parent = Tabs
    Scroll.Active = true
    Scroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Scroll.BackgroundTransparency = 1.000
    Scroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Scroll.BorderSizePixel = 0
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 0
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY

    UISorter.Name = "UISorter"
    UISorter.Parent = Scroll
    UISorter.SortOrder = Enum.SortOrder.LayoutOrder
    UISorter.FillDirection = Enum.FillDirection.Vertical
    UISorter.Padding = UDim.new(0, 5)

    TabPadding.Parent = Scroll
    TabPadding.PaddingBottom = UDim.new(0, 0)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.PaddingTop = UDim.new(0, 1)

    -- TopBar
    local Topbar = Instance.new("Frame")
    local Title_10 = Instance.new("TextButton")
    local MenuController = Instance.new("Frame")
    local Minimize = Instance.new("TextButton")
    local UICorner_13 = Instance.new("UICorner")
    local Close = Instance.new("TextButton")
    local UICorner_14 = Instance.new("UICorner")
    local Maximize = Instance.new("TextButton")
    local UICorner_15 = Instance.new("UICorner")
    local ImageButton = Instance.new("ImageButton")

    Topbar.Name = "Topbar"
    Topbar.Parent = MainFrame
    Topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Topbar.BackgroundTransparency = 1.000
    Topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Topbar.BorderSizePixel = 0
    Topbar.Position = UDim2.new(0, 7, 0, 0)
    Topbar.Selectable = true
    Topbar.Size = UDim2.new(1.00100005, -14, 0, 30)
    Topbar.ZIndex = 2

    task.spawn(Library.MakeDraggable, Topbar, MainFrame)

    Title_10.Name = "Title"
    Title_10.Parent = Topbar
    Title_10.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title_10.BackgroundTransparency = 1.000
    Title_10.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title_10.BorderSizePixel = 0
    Title_10.Position = UDim2.new(0.0535701066, 0, 0, 0)
    Title_10.Size = UDim2.new(0.200000003, 0, 1, 0)
    Title_10.Font = Enum.Font.SourceSans
    Title_10.Text = a["Title"]
    Title_10.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title_10.TextSize = 18.000
    Title_10.TextXAlignment = Enum.TextXAlignment.Left

    MenuController.Name = "MenuController"
    MenuController.Parent = Topbar
    MenuController.AnchorPoint = Vector2.new(1, 0)
    MenuController.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MenuController.BackgroundTransparency = 1.000
    MenuController.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MenuController.BorderSizePixel = 0
    MenuController.Position = UDim2.new(0.973897457, 0, 0, 0)
    MenuController.Size = UDim2.new(0.0512553528, 0, 1, 0)

    Minimize.Name = "Minimize"
    Minimize.Parent = MenuController
    Minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    Minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Minimize.BorderSizePixel = 0
    Minimize.Position = UDim2.new(0.476213515, 0, 0.333333343, 0)
    Minimize.Size = UDim2.new(0, 10, 0, 10)
    Minimize.Font = Enum.Font.SourceSans
    Minimize.Text = ""
    Minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
    Minimize.TextSize = 14.000
    Minimize.TextTransparency = 1.000

    UICorner_13.CornerRadius = UDim.new(1, 0)
    UICorner_13.Parent = Minimize

    Close.Name = "Close"
    Close.Parent = MenuController
    Close.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0.992796421, 0, 0.333333343, 0)
    Close.Size = UDim2.new(0, 10, 0, 10)
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14.000
    Close.TextTransparency = 1.000

    UICorner_14.CornerRadius = UDim.new(1, 0)
    UICorner_14.Parent = Close

    Maximize.Name = "Maximize"
    Maximize.Parent = MenuController
    Maximize.BackgroundColor3 = Color3.fromRGB(44, 208, 19)
    Maximize.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Maximize.BorderSizePixel = 0
    Maximize.Position = UDim2.new(-0.00380160543, 0, 0.333333343, 0)
    Maximize.Size = UDim2.new(0, 10, 0, 10)
    Maximize.Font = Enum.Font.SourceSans
    Maximize.Text = ""
    Maximize.TextColor3 = Color3.fromRGB(0, 0, 0)
    Maximize.TextSize = 14.000
    Maximize.TextTransparency = 1.000

    UICorner_15.CornerRadius = UDim.new(1, 0)
    UICorner_15.Parent = Maximize

    ImageButton.Parent = Topbar
    ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageButton.BackgroundTransparency = 1.000
    ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageButton.BorderSizePixel = 0
    ImageButton.Position = UDim2.new(0.00822199322, 0, 0.233333334, 0)
    ImageButton.Size = UDim2.new(0, 16, 0, 16)
    ImageButton.Image = "rbxassetid://11422143469"

    local function maximizeWindow()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        MainFrame.Position = UDim2.new(0, 0, 0, 0)
        tween:CreateTween(MainFrame, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)}, true)

        print("Window maximized.")
    end

    local function minimizeWindow()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        tween:CreateTween(MainFrame, tweenInfo, {Size = UDim2.new(0, 585, 0, 320)}, true)
        MainFrame.Position = UDim2.new(0, 0, 0, 0)
        print("Window minimized.")
    end

    local function closeWindow()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        tween:CreateTween(MainFrame, tweenInfo, {BackgroundTransparency = 1}, true)
        tween:TweenWithCallback(
            MainFrame,
            tweenInfo,
            {Position = UDim2.new(MainFrame.Position.X, 0, 2, 0)},
            function()
                MainFrame.Visible = false
                print("Window closed.")
            end
        )
    end

    funcs.toggleLayout = function(isTwoSections)
        _G.DoubleLayout = isTwoSections
        local Pages = PageLists:GetChildren()

        for _, page in pairs(Pages) do
            if page.Name == "Page" then
                local ScrollFrame = page:FindFirstChildOfClass("ScrollingFrame")
                local SectionContainer = ScrollFrame and ScrollFrame:FindFirstChild("SectionContainer")

                if SectionContainer then
                    local LeftSide = SectionContainer:FindFirstChild("Left")
                    local RightSide = SectionContainer:FindFirstChild("Right")

                    for _, section in pairs(SectionContainer:GetChildren()) do
                        if section.Name == "Right" then
                            if isTwoSections then
                                section.Visible = true
                                section.ZIndex = 1
                                section.Position = UDim2.new(0.5, 0, 0, 0)
                                section.Size = UDim2.new(0.5, 0, 1, 0)
                                for _, element in pairs(LeftSide:GetDescendants()) do
                                    if element:GetAttribute("Side") == "Right" then
                                        element.Parent = RightSide:FindFirstChildOfClass("ScrollingFrame")
                                    end
                                end
                            else
                                section.Visible = false
                                section.ZIndex = -1
                                section.Position = UDim2.new(0, 0, 0.5, 0)
                                section.Size = UDim2.new(1, 0, 1, 0)
                                for _, element in pairs(RightSide:GetDescendants()) do
                                    if element:GetAttribute("Side") == "Right" then
                                        element.Parent = LeftSide:FindFirstChildOfClass("ScrollingFrame")
                                    end
                                end
                            end
                        elseif section.Name == "Left" then
                            if isTwoSections then
                                section.Position = UDim2.new(0, 0, 0, 0)
                                local tween =
                                    tween.new(
                                    section,
                                    TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                    {Size = UDim2.new(0.5, 0, 1, 0)}
                                )
                                tween:start()
                            else
                                local tween =
                                    tween.new(
                                    section,
                                    TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                    {Size = UDim2.new(1, 0, 1, 0)}
                                )
                                tween:start()
                                section.Position = UDim2.new(0, 0, 0, 0)
                            end
                        end
                    end
                end
            end
        end

        local OneLayouts = not isTwoSections

        tween.new(
            MainFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {Size = OneLayouts and Library.Size.Mobile or Library.Size.Windows}
        ):start()

        Scroll.AutomaticCanvasSize = OneLayouts and Enum.AutomaticSize.Y or Enum.AutomaticSize.X
        Scroll.ScrollingDirection = OneLayouts and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X

        tween.new(
            Tabs,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {Size = OneLayouts and UDim2.new(0.2, 0, 1, 0) or UDim2.new(1, 0, 0, 30)}
        ):start()
        tween.new(
            BaseSections,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {
                Position = OneLayouts and UDim2.new(0.2, 0, 0, 0) or UDim2.new(0.5, 0, 0.5, 15),
                Size = OneLayouts and UDim2.new(0.8, 0, 1, 0) or UDim2.new(1, 0, 1, -30)
            }
        ):start()

        BaseSections.AnchorPoint = OneLayouts and Vector2.new(0, 0) or Vector2.new(0.5, 0.5)

        UISorter.FillDirection = OneLayouts and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal

        for i, v in pairs(Scroll:GetChildren()) do
            if v:IsA("Frame") and v.Name == "Clickable" then
                v.Line.AnchorPoint = OneLayouts and Vector2.new(0.5, 0.5) or Vector2.new(0.5, 0.5)
                v.Line.Position = OneLayouts and UDim2.new(0.057, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.8, 2)
                v.Line.Rotation = OneLayouts and 0 or 90
                v.Line.Size = OneLayouts and UDim2.new(0, 2, 0.5, 0) or UDim2.new(0, 2, 1.3, 0)
                v.TextLabel.TextXAlignment = OneLayouts and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
                v.TextLabel.Position = OneLayouts and UDim2.new(0.12, 0, 0, 0) or UDim2.new(0, 0, 0, 0)

                v.Size = OneLayouts and UDim2.new(1, 0, 0, 25) or UDim2.new(0, 75, 0, 25)
            end
        end
    end

    Maximize.MouseButton1Click:Connect(maximizeWindow)
    Minimize.MouseButton1Click:Connect(minimizeWindow)
    Close.MouseButton1Click:Connect(closeWindow)

    funcs.newTab = function(options)
        local Clickable = Instance.new("Frame")
        local tabStroke = Instance.new("UIStroke")
        local UICorner_2 = Instance.new("UICorner")
        local Line = Instance.new("Frame")
        local UICorner_3 = Instance.new("UICorner")
        local TextButton = Instance.new("TextButton")
        local TextLabel = Instance.new("TextLabel")
        local padding = Instance.new("UIPadding")

        Clickable.Name = "Clickable"
        Clickable.Parent = Scroll
        Clickable.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
        Clickable.BackgroundTransparency = 0.1
        Clickable.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Clickable.BorderSizePixel = 0
        Clickable.Size = UDim2.new(0, 100, 0, 25)

        UICorner_2.CornerRadius = UDim.new(0, 3)
        UICorner_2.Parent = Clickable

        tabStroke.Name = "Stroke"
        tabStroke.Parent = Clickable
        tabStroke.Color = Color3.fromRGB(255, 255, 255)
        tabStroke.LineJoinMode = Enum.LineJoinMode.Round
        tabStroke.Thickness = 1
        tabStroke.Transparency = 0.9

        Line.Name = "Line"
        Line.Parent = Clickable
        Line.BackgroundColor3 = Color3.fromRGB(255, 221, 249)
        Line.BackgroundTransparency = 1
        Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0.057, 0, 0.200000003, 0)
        Line.Size = UDim2.new(0, 2, 0.600000024, 0)

        UICorner_3.CornerRadius = UDim.new(0, 10)
        UICorner_3.Parent = Line

        TextButton.Parent = Clickable
        TextButton.BackgroundColor3 = Color3.fromRGB(25, 27, 27)
        TextButton.BackgroundTransparency = 1.000
        TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextButton.BorderSizePixel = 0
        TextButton.Size = UDim2.new(1, 0, 1, 0)
        TextButton.ZIndex = 2
        TextButton.Font = Enum.Font.RobotoMono
        TextButton.Text = ""
        TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextButton.TextSize = 12.000
        TextButton.TextXAlignment = Enum.TextXAlignment.Left

        TextLabel.Parent = Clickable
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Position = UDim2.new(0.12, 0, 0, 0)
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = options.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 16.000
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Page = Instance.new("Frame")
        local UIListLayout = Instance.new("UIListLayout")
        local PageScroll = Instance.new("ScrollingFrame")
        local SectionContainer = Instance.new("Frame")
        local padding = Instance.new("UIPadding")

        Page.Name = "Page"
        Page.Parent = PageLists
        Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Page.BackgroundTransparency = 1.000
        Page.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Page.BorderSizePixel = 0
        Page.ClipsDescendants = true
        Page.Size = UDim2.new(1, 0, 1, 0)

        UIListLayout.Parent = Page
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        UIListLayout.Padding = UDim.new(0, 5)

        PageScroll.Name = "PageScroll"
        PageScroll.Parent = Page
        PageScroll.Active = true
        PageScroll.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
        PageScroll.BackgroundTransparency = 1.000
        PageScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PageScroll.BorderSizePixel = 0
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.ScrollBarThickness = 0

        SectionContainer.Name = "SectionContainer"
        SectionContainer.Parent = PageScroll
        SectionContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SectionContainer.BackgroundTransparency = 1.000
        SectionContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SectionContainer.BorderSizePixel = 0
        SectionContainer.Position = UDim2.new(-4.18026218e-08, 0, 0, 0)
        SectionContainer.Size = UDim2.new(1, 0, 1, 0)

        padding.Parent = SectionContainer
        padding.PaddingBottom = UDim.new(0, 5)
        padding.PaddingLeft = UDim.new(0, 3)
        padding.PaddingRight = UDim.new(0, 5)
        padding.PaddingTop = UDim.new(0, 0)

        local Right = Instance.new("Frame") -- Right Section
        local Scroll_3 = Instance.new("ScrollingFrame")
        local UIListLayout_5 = Instance.new("UIListLayout")
        local UIPadding_8 = Instance.new("UIPadding")

        Right.Name = "Right"
        Right.Parent = SectionContainer
        Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Right.BackgroundTransparency = 1.000
        Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Right.BorderSizePixel = 0
        Right.Position = UDim2.new(0.5, 0, 0, 0)
        Right.Size = UDim2.new(0.5, 0, 1, 0)
        Right.Visible = false
        Right.ZIndex = -1

        Scroll_3.Name = "Scroll"
        Scroll_3.Parent = Right
        Scroll_3.Active = true
        Scroll_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Scroll_3.BackgroundTransparency = 1.000
        Scroll_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Scroll_3.BorderSizePixel = 0
        Scroll_3.Size = UDim2.new(1, 0, 1, 0)
        Scroll_3.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll_3.ScrollBarThickness = 0

        UIListLayout_5.Parent = Scroll_3
        UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_5.Padding = UDim.new(0, 5)

        UIPadding_8.Parent = Scroll_3
        UIPadding_8.PaddingBottom = UDim.new(0, 3)
        UIPadding_8.PaddingLeft = UDim.new(0, 3)
        UIPadding_8.PaddingRight = UDim.new(0, 3)
        UIPadding_8.PaddingTop = UDim.new(0, 3)

        local Left = Instance.new("Frame")
        local Scroll_2 = Instance.new("ScrollingFrame")
        local UIListLayout_4 = Instance.new("UIListLayout")
        local UIPadding_7 = Instance.new("UIPadding")

        Left.Name = "Left"
        Left.Parent = SectionContainer
        Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Left.BackgroundTransparency = 1.000
        Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Left.BorderSizePixel = 0
        Left.Size = UDim2.new(1, 0, 1, 0)

        Scroll_2.Name = "Scroll"
        Scroll_2.Parent = Left
        Scroll_2.Active = true
        Scroll_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Scroll_2.BackgroundTransparency = 1.000
        Scroll_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Scroll_2.BorderSizePixel = 0
        Scroll_2.Size = UDim2.new(1, 0, 1, 0)
        Scroll_2.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll_2.ScrollBarThickness = 0

        UIListLayout_4.Parent = Scroll_2
        UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_4.Padding = UDim.new(0, 5)

        UIPadding_7.Parent = Scroll_2
        UIPadding_7.PaddingBottom = UDim.new(0, 3)
        UIPadding_7.PaddingLeft = UDim.new(0, 3)
        UIPadding_7.PaddingRight = UDim.new(0, 3)
        UIPadding_7.PaddingTop = UDim.new(0, 3)

        Library.updateCanvasSize(Scroll_2, UIListLayout_4, UIPadding_7)

        Library.updateCanvasSize(Scroll_3, UIListLayout_5, UIPadding_8)

        local function setLineTransparency(ins, transparency)
            if ins then
                TweenService:Create(
                    ins,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = transparency}
                ):Play()
            end
        end

        local function updateLine()
            for _, v in ipairs(Scroll:GetChildren()) do
                if v:IsA("Frame") and v.Name == "Clickable" then
                    setLineTransparency(v.Line, 1)
                end
            end
        end

        TextButton.MouseButton1Click:Connect(
            Library.safeCallback(
                function()
                    local OptionItems = lib:FindFirstChild("Items")
                    if OptionItems then
                        OptionItems.Visible = false
                    end
                    updateLine()

                    for _, v in ipairs(PageLists:GetChildren()) do
                        if v == Page then
                            UIPageLayout:JumpTo(v)
                            setLineTransparency(Line, 0)
                            break
                        end
                    end
                end
            )
        )

        if #PageLists:GetChildren() == 1 then
            setLineTransparency(Line, 0)
        end

        return {
            Hidden = function(bool)
                if type(bool) == "boolean" then
                    Clickable.Visible = bool
                    Page.Visible = bool
                end
            end,
            newSection = function(options)
                local Title = options.Title or "Section"
                local Side = options.Side or "Left"

                local Section = Instance.new("Frame")
                local UICorner_4 = Instance.new("UICorner")
                local TopBar = Instance.new("Frame")
                local Title = Instance.new("TextLabel")
                local Container_2 = Instance.new("Frame")
                local stroke = Instance.new("UIStroke")
                local UIPadding_2 = Instance.new("UIPadding")
                local UIListLayout_2 = Instance.new("UIListLayout")

                local shouldInsertTo =
                    Side == "Left" and Scroll_2 or Side == "Right" and Scroll_3 or print("insert failed.")

                Section.Name = "Section"
                Section.Parent = shouldInsertTo or (not _G.DoubleLayout and Scroll_2)
                Section.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                Section.BackgroundTransparency = 0.05
                Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Section.BorderSizePixel = 0
                Section.Size = UDim2.new(1, 0, 0, 0)
                Section.AutomaticSize = Enum.AutomaticSize.XY
                Section:SetAttribute("Side", Side)

                UICorner_4.CornerRadius = UDim.new(0, 3)
                UICorner_4.Parent = Section

                stroke.Name = "Stroke"
                stroke.Parent = Section
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.LineJoinMode = Enum.LineJoinMode.Round
                stroke.Thickness = 1
                stroke.Transparency = 0.8

                TopBar.Name = "TopBar"
                TopBar.Parent = Section
                TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TopBar.BackgroundTransparency = 1.000
                TopBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TopBar.BorderSizePixel = 0
                TopBar.Size = UDim2.new(1, 0, 0, 20)

                Title.Name = "Title"
                Title.Parent = TopBar
                Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title.BackgroundTransparency = 1.000
                Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Title.BorderSizePixel = 0
                Title.Position = UDim2.new(0, 8, 0, 0)
                Title.Size = UDim2.new(0.989313841, -3, 1, 0)
                Title.Font = Enum.Font.SourceSans
                Title.Text = options.Title or "section"
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextSize = 14.000
                Title.TextTransparency = 0.300
                Title.TextXAlignment = Enum.TextXAlignment.Left

                Container_2.Name = "Container"
                Container_2.Parent = Section
                Container_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Container_2.BackgroundTransparency = 1.000
                Container_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Container_2.BorderSizePixel = 0
                Container_2.AnchorPoint = Vector2.new(0.5, 0)
                Container_2.Position = UDim2.new(0.5, 0, 0, 20)
                Container_2.Size = UDim2.new(0.944623113, 0, 0.826086938, 0)
                Container_2.AutomaticSize = Enum.AutomaticSize.Y

                UIPadding_2.Parent = Container_2
                UIPadding_2.PaddingBottom = UDim.new(0, 10)
                UIPadding_2.PaddingLeft = UDim.new(0, 3)
                UIPadding_2.PaddingRight = UDim.new(0, 3)
                UIPadding_2.PaddingTop = UDim.new(0, 5)

                UIListLayout_2.Parent = Container_2
                UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout_2.Padding = UDim.new(0, 8)

                Container_2.ChildAdded:Connect(
                    function(element)
                        if element:GetAttribute("ParentSide") == nil then
                            element:SetAttribute("ParentSide", Side)
                        end
                    end
                )

                return {
                    Hidden = function(bool)
                        if type(bool) == "boolean" then
                            Section.Visible = bool
                        end
                    end,
                    Button = function(option)
                        local Title = option.Title or "Button"
                        local Callback =
                            option.Callback or
                            Library.safeCallback(
                                function()
                                    print("no callback.")
                                end
                            )

                        local Button = Instance.new("Frame")
                        local Click_4 = Instance.new("TextButton")
                        local Title_8 = Instance.new("TextLabel")
                        local UICorner_11 = Instance.new("UICorner")

                        Button.Name = "Button"
                        Button.Parent = Container_2
                        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Button.BackgroundTransparency = 0.950
                        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Button.BorderSizePixel = 0
                        Button.Size = UDim2.new(0.5, 0, 0, 20)
                        Button.AutomaticSize = Enum.AutomaticSize.X

                        Click_4.Name = "Click"
                        Click_4.Parent = Button
                        Click_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Click_4.BackgroundTransparency = 1.000
                        Click_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Click_4.BorderSizePixel = 0
                        Click_4.Size = UDim2.new(1, 0, 1, 0)
                        Click_4.ZIndex = 2
                        Click_4.Font = Enum.Font.SourceSans
                        Click_4.Text = ""
                        Click_4.TextColor3 = Color3.fromRGB(0, 0, 0)
                        Click_4.TextSize = 14.000
                        Click_4.TextTransparency = 1.000

                        Title_8.Name = "Title"
                        Title_8.Parent = Button
                        Title_8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Title_8.BackgroundTransparency = 1.000
                        Title_8.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Title_8.BorderSizePixel = 0
                        Title_8.Position = UDim2.new(0, 3, 0, 0)
                        Title_8.Size = UDim2.new(1, -2, 1, 0)
                        Title_8.Font = Enum.Font.SourceSans
                        Title_8.Text = Title
                        Title_8.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Title_8.TextSize = 14.000
                        Title_8.TextTransparency = 0.500

                        UICorner_11.CornerRadius = UDim.new(0, 3)
                        UICorner_11.Parent = Button

                        Click_4.MouseButton1Click:Connect(
                            Library.safeCallback(
                                function()
                                    if _G.DropdownAreOpened then
                                        return
                                    end
                                    if Callback then
                                        Callback()
                                    end
                                end
                            )
                        )

                        return {
                            Hidden = function(bool)
                                if type(bool) == "boolean" then
                                    Button.Visible = bool
                                end
                            end
                        }
                    end,
                    Toggle = function(option)
                        local Title = option.Title or "Toggle"
                        local Default = option.Default or false
                        local Callback = option.Callback or function(bool)
                                print("no callback state: " .. tostring(bool))
                            end

                        local Toggle = Instance.new("Frame")
                        local Click = Instance.new("TextButton")
                        local Title_2 = Instance.new("TextLabel")
                        local Corner = Instance.new("UICorner")
                        local Box = Instance.new("Frame")
                        local stroke = Instance.new("UIStroke")
                        local Circle = Instance.new("Frame")
                        local Corner_2 = Instance.new("UICorner")
                        local Corner_3 = Instance.new("UICorner")

                        Toggle.Name = "Toggle"
                        Toggle.Parent = Container_2
                        Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Toggle.BackgroundTransparency = 1.000
                        Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Toggle.BorderSizePixel = 0
                        Toggle.Size = UDim2.new(1, 0, 0, 20)
                        Toggle.AutomaticSize = Enum.AutomaticSize.X

                        Click.Name = "Click"
                        Click.Parent = Toggle
                        Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Click.BackgroundTransparency = 1.000
                        Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Click.BorderSizePixel = 0
                        Click.Size = UDim2.new(1, 0, 1, 0)
                        Click.ZIndex = 2
                        Click.Text = ""
                        Click.TextTransparency = 1.000

                        Title_2.Name = "Title"
                        Title_2.Parent = Toggle
                        Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Title_2.BackgroundTransparency = 1.000
                        Title_2.Position = UDim2.new(0, 0, 0, 0)
                        Title_2.Size = UDim2.new(1, -2, 1, 0)
                        Title_2.Font = Enum.Font.SourceSans
                        Title_2.Text = option.Title
                        Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Title_2.TextSize = 14.000
                        Title_2.TextTransparency = 0.500
                        Title_2.TextXAlignment = Enum.TextXAlignment.Left

                        Corner.CornerRadius = UDim.new(1, 1)
                        Corner.Parent = Toggle

                        Box.Name = "Box"
                        Box.Parent = Toggle
                        Box.BackgroundColor3 = Color3.fromRGB(255, 191, 248)
                        Box.BackgroundTransparency = 0.5
                        Box.Size = UDim2.new(0, 28, 0, 15)

                        Box.AnchorPoint = Vector2.new(0.5, 0.5)
                        Box.Position = UDim2.new(1, -(28 / 2), 0.5, 0)

                        stroke.Name = "Stroke"
                        stroke.Parent = Box
                        stroke.Color = Color3.fromRGB(255, 255, 255)
                        stroke.LineJoinMode = Enum.LineJoinMode.Round
                        stroke.Thickness = 1
                        stroke.Transparency = 0.9

                        Circle.Name = "Circle"
                        Circle.Parent = Box
                        Circle.BackgroundColor3 = Color3.fromRGB(255, 191, 248)
                        Circle.Size = UDim2.new(0, 10, 0, 10)

                        Circle.AnchorPoint = Vector2.new(0.5, 0.5)
                        Circle.Position = UDim2.new(0.5, 0, 0.5, 0)

                        Corner_2.CornerRadius = UDim.new(1, 0)
                        Corner_2.Parent = Circle
                        Corner_3.CornerRadius = UDim.new(1, 1)
                        Corner_3.Parent = Box

                        local function updateToggleState(isOn)
                            tween.new(
                                Circle,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {
                                    BackgroundColor3 = isOn and Color3.fromRGB(255, 191, 248) or
                                        Color3.fromRGB(60, 60, 60)
                                }
                            ):start()
                            tween.new(
                                Circle,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {Position = isOn and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)}
                            ):start()
                            tween.new(
                                Box,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {BackgroundTransparency = isOn and 0.5 or 1}
                            ):start()
                            tween.new(
                                Title_2,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {TextTransparency = isOn and 0 or 0.5}
                            ):start()
                            option.Callback(isOn)
                        end

                        updateToggleState(option.Default)

                        Click.MouseButton1Click:Connect(
                            function()
                                if _G.DropdownAreOpened then
                                    return
                                end
                                option.Default = not option.Default
                                updateToggleState(option.Default)
                            end
                        )

                        return {
                            SetValue = function(value, callback)
                                if type(value) == "boolean" then
                                    option.Default = value
                                    updateToggleState(value)
                                    if callback then
                                        callback(value)
                                    end
                                end
                            end,
                            Hidden = function(bool)
                                if type(bool) == "boolean" then
                                    Toggle.Visible = bool
                                end
                            end
                        }
                    end,
                    Label = function(option)
                        local func = {}

                        local Wrap = option.Wrap or false
                        local Title = option.Title or "Text"
                        local DescriptionText = option.Description or "Description"

                        local Label = Instance.new("Frame")
                        local Title_3 = Instance.new("TextLabel")
                        local Description = Instance.new("TextLabel")

                        Label.Name = "Label"
                        Label.Parent = Container_2
                        Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Label.BackgroundTransparency = 1.000
                        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Label.BorderSizePixel = 0
                        Label.Size = UDim2.new(1, 0, 0, 40)
                        Label.LayoutOrder = 1

                        Title_3.Name = "Title"
                        Title_3.Parent = Label
                        Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Title_3.BackgroundTransparency = 1.000
                        Title_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Title_3.BorderSizePixel = 0
                        Title_3.Position = UDim2.new(0, 0, 0, 0)
                        Title_3.Size = UDim2.new(1, 0, 0, 20)
                        Title_3.Font = Enum.Font.SourceSans
                        Title_3.Text = Title
                        Title_3.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Title_3.TextSize = 14.000
                        Title_3.TextXAlignment = Enum.TextXAlignment.Left
                        Title_3.TextYAlignment = Enum.TextYAlignment.Center
                        Title_3.TextWrapped = Wrap

                        Description.Name = "Description"
                        Description.Parent = Label
                        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Description.BackgroundTransparency = 1.000
                        Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Description.BorderSizePixel = 0
                        Description.Position = UDim2.new(0, 0, 0, 20)
                        Description.Size = UDim2.new(1, 0, 0, 20)
                        Description.Font = Enum.Font.SourceSans
                        Description.Text = DescriptionText
                        Description.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Description.TextSize = 12.000
                        Description.TextXAlignment = Enum.TextXAlignment.Left
                        Description.TextYAlignment = Enum.TextYAlignment.Center
                        Description.TextWrapped = Wrap

                        if Wrap then
                            local textHeight = Title_3.TextBounds.Y + Description.TextBounds.Y
                            Label.Size = UDim2.new(1, 0, 0, textHeight * 1.5)
                        end

                        return {
                            SetText = function(newTitle, newDescription)
                                if newTitle then
                                    Title_3.Text = newTitle
                                end
                                if newDescription then
                                    Description.Text = newDescription
                                end

                                if Wrap then
                                    local textHeight = Title_3.TextBounds.Y + Description.TextBounds.Y
                                    Label.Size = UDim2.new(1, 0, 0, textHeight + 5)
                                end
                            end,
                            Hidden = function(bool)
                                if type(bool) == "boolean" then
                                    Label.Visible = bool
                                end
                            end
                        }
                    end,
                    Input = function(option)
                        local Title = option.Title or "Input"
                        local Placeholder = option.HolderText or "Enter value here."
                        local Default = option.Default or ""
                        local Numberic = option.Numberic or false
                        local Finished = option.Finished or true
                        local Callback = option.Callback or function()
                            end

                        local Input = Instance.new("Frame")
                        Input.Name = "Input"
                        Input.Parent = Container_2
                        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Input.BackgroundTransparency = 1.000
                        Input.BorderSizePixel = 0
                        Input.Size = UDim2.new(1, 0, 0, 20)
                        Input.AutomaticSize = Enum.AutomaticSize.X

                        local Title_4 = Instance.new("TextLabel")
                        Title_4.Name = "Title"
                        Title_4.Parent = Input
                        Title_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Title_4.BackgroundTransparency = 1.000
                        Title_4.Size = UDim2.new(0.5, 0, 1, 0)
                        Title_4.Font = Enum.Font.SourceSans
                        Title_4.Text = Title
                        Title_4.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Title_4.TextSize = 14.000
                        Title_4.TextTransparency = 0.500
                        Title_4.TextXAlignment = Enum.TextXAlignment.Left

                        local Base = Instance.new("Frame")
                        Base.Name = "Base"
                        Base.Parent = Input
                        Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Base.BackgroundTransparency = 1.000
                        Base.Position = UDim2.new(0.5, 0, 0, 0)
                        Base.Size = UDim2.new(0.5, 0, 1, 0)

                        local stroke = Instance.new("UIStroke")
                        stroke.Name = "Stroke"
                        stroke.Parent = Base
                        stroke.Color = Color3.fromRGB(255, 255, 255)
                        stroke.LineJoinMode = Enum.LineJoinMode.Round
                        stroke.Thickness = 1
                        stroke.Transparency = 0.9

                        local UICorner_5 = Instance.new("UICorner")
                        UICorner_5.CornerRadius = UDim.new(0, 3)
                        UICorner_5.Parent = Base

                        local UIPadding = Instance.new("UIPadding")
                        UIPadding.Parent = Base
                        UIPadding.PaddingLeft = UDim.new(0, 3)
                        UIPadding.PaddingRight = UDim.new(0, 3)

                        local Input_2 = Instance.new("TextBox")
                        Input_2.Name = "Input"
                        Input_2.Parent = Base
                        Input_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Input_2.BackgroundTransparency = 1.000
                        Input_2.Size = UDim2.new(1, 0, 1, 0)
                        Input_2.Font = Enum.Font.SourceSans
                        Input_2.PlaceholderText = Placeholder
                        Input_2.Text = Default
                        Input_2.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Input_2.TextSize = 14.000
                        Input_2.TextTransparency = 0.500
                        Input_2.TextXAlignment = Enum.TextXAlignment.Left
                        Input_2.ClipsDescendants = true

                        if Numberic then
                            Input_2:GetPropertyChangedSignal("Text"):Connect(
                                function()
                                    Input_2.Text = Input_2.Text:gsub("[^%d]", "")
                                end
                            )
                        end

                        local function adjustBaseSize()
                            local textLength = #Input_2.Text
                            local newWidth = math.clamp(textLength * 0.01, 0.3, 0.5)
                            Base.Size = UDim2.new(newWidth, 0, 1, 0)
                            Base.Position = UDim2.new(1 - newWidth, 0, 0, 0)
                            Title_4.Size = UDim2.new(1 - newWidth, -5, 1, 0)
                        end

                        Input_2:GetPropertyChangedSignal("Text"):Connect(adjustBaseSize)

                        Input_2.FocusLost:Connect(
                            function(enterPressed)
                                if Finished or enterPressed then
                                    if Numberic then
                                        Callback(tonumber(Input_2.Text) or 0)
                                    else
                                        Callback(Input_2.Text)
                                    end
                                end
                            end
                        )

                        adjustBaseSize()
                    end,
                    Slider = function(option)
                        local Title = option.Title or "Slider"
                        local Min = option.Min or 0
                        local Default = option.Default or 0
                        local Max = option.Max or 100
                        local Rounding = option.Rounding or 0
                        local Callback = option.Callback or function()
                            end

                        local initialRelativePosition = (Default - Min) / (Max - Min)

                        local Slider = Instance.new("Frame")
                        local MainArea = Instance.new("Frame")
                        local TitleLabel = Instance.new("TextLabel")
                        local TextBox = Instance.new("TextBox")
                        local InteractArea = Instance.new("Frame")
                        local Base = Instance.new("Frame")
                        local BaseStroke = Instance.new("UIStroke")
                        local BaseCorner = Instance.new("UICorner")
                        local Progress = Instance.new("Frame")
                        local Circle = Instance.new("Frame")
                        local UICornerProgress = Instance.new("UICorner")
                        local UICornerCircle = Instance.new("UICorner")

                        Slider.Name = "Slider"
                        Slider.Parent = Container_2
                        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Slider.BackgroundTransparency = 1
                        Slider.Size = UDim2.new(1, 0, 0, 40)

                        MainArea.Name = "MainArea"
                        MainArea.Parent = Slider
                        MainArea.BackgroundTransparency = 1
                        MainArea.Size = UDim2.new(1, 0, 0, 20)

                        TitleLabel.Name = "TitleLabel"
                        TitleLabel.Parent = MainArea
                        TitleLabel.BackgroundTransparency = 1
                        TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
                        TitleLabel.Font = Enum.Font.SourceSans
                        TitleLabel.Text = Title
                        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TitleLabel.TextSize = 14
                        TitleLabel.TextTransparency = 0.5
                        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

                        TextBox.Parent = MainArea
                        TextBox.BackgroundTransparency = 1
                        TextBox.Size = UDim2.new(0.2, 0, 1, 0)
                        TextBox.Position = UDim2.new(0.8, 0, 0, 0)
                        TextBox.Font = Enum.Font.SourceSans
                        TextBox.Text = tostring(Default)
                        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TextBox.TextSize = 14
                        TextBox.TextXAlignment = Enum.TextXAlignment.Right
                        TextBox.ClearTextOnFocus = true

                        InteractArea.Name = "InteractArea"
                        InteractArea.Parent = Slider
                        InteractArea.BackgroundTransparency = 1
                        InteractArea.Position = UDim2.new(0, 0, 0, 30)
                        InteractArea.Size = UDim2.new(1, 0, 0, 10)

                        Base.Name = "Base"
                        Base.Parent = InteractArea
                        Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Base.BackgroundTransparency = 1
                        Base.Size = UDim2.new(1, 0, 0, 3)

                        BaseStroke.Parent = Base
                        BaseStroke.Color = Color3.fromRGB(255, 255, 255)
                        BaseStroke.LineJoinMode = Enum.LineJoinMode.Round
                        BaseStroke.Thickness = 1
                        BaseStroke.Transparency = 0.9

                        BaseCorner.Parent = Base
                        BaseCorner.CornerRadius = UDim.new(0.5, 0)

                        Progress.Name = "Progress"
                        Progress.Parent = Base
                        Progress.BackgroundColor3 = Color3.fromRGB(248, 186, 250)
                        Progress.Size = UDim2.new(initialRelativePosition, 0, 1, 0)

                        Circle.Name = "Circle"
                        Circle.Parent = InteractArea
                        Circle.BackgroundColor3 = Color3.fromRGB(248, 186, 250)
                        Circle.Size = UDim2.new(0, 10, 0, 10)
                        Circle.AnchorPoint = Vector2.new(0.5, 0.5)
                        Circle.Position = UDim2.new(initialRelativePosition, 0, 0.5, 0)

                        UICornerProgress.CornerRadius = UDim.new(0.5, 0)
                        UICornerProgress.Parent = Progress

                        UICornerCircle.CornerRadius = UDim.new(0.5, 0)
                        UICornerCircle.Parent = Circle

                        local function updateSlider(value)
                            local relativePosition = math.clamp((value - Min) / (Max - Min), 0, 1)
                            local roundedValue = math.floor((value) * 10 ^ Rounding) / 10 ^ Rounding

                            tween.new(
                                Progress,
                                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {
                                    Size = UDim2.new(relativePosition, 0, 1, 0)
                                }
                            ):start()

                            tween.new(
                                Circle,
                                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {
                                    Position = UDim2.new(relativePosition, 0, 0.225, 0)
                                }
                            ):start()

                            TextBox.Text = tostring(roundedValue)
                            Callback(roundedValue)
                        end

                        updateSlider(Default)

                        TextBox.FocusLost:Connect(
                            function()
                                local value = tonumber(TextBox.Text)
                                if value then
                                    updateSlider(math.clamp(value, Min, Max))
                                else
                                    TextBox.Text = tostring(Default)
                                end
                            end
                        )

                        TextBox:GetPropertyChangedSignal("Text"):Connect(
                            function()
                                TextBox.Text = TextBox.Text:gsub("[^%d]", "")
                            end
                        )

                        local dragging = false
                        local function onInputChanged(input)
                            if
                                dragging and
                                    table.find(
                                        {Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch},
                                        input.UserInputType
                                    )
                             then
                                local relativePosition =
                                    math.clamp((input.Position.X - Base.AbsolutePosition.X) / Base.AbsoluteSize.X, 0, 1)
                                local value = Min + relativePosition * (Max - Min)
                                updateSlider(value)
                            end
                        end

                        InteractArea.InputBegan:Connect(
                            function(input)
                                if
                                    table.find(
                                        {Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch},
                                        input.UserInputType
                                    )
                                 then
                                    dragging = true
                                    tween.new(
                                        TitleLabel,
                                        TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                        {TextTransparency = 0}
                                    ):start()
                                end
                            end
                        )

                        InteractArea.InputEnded:Connect(
                            function(input)
                                if
                                    table.find(
                                        {Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch},
                                        input.UserInputType
                                    )
                                 then
                                    dragging = false
                                    tween.new(
                                        TitleLabel,
                                        TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                        {TextTransparency = 0.5}
                                    ):start()
                                end
                            end
                        )

                        game:GetService("UserInputService").InputChanged:Connect(onInputChanged)

                        return {
                            Slider = function(value)
                                updateSlider(value)
                            end,
                            GetValue = function()
                                return currentValue
                            end
                        }
                    end,
                    Options = function(option)
                        local Dropdown = {
                            Title = option.Title or "Options",
                            Values = option.Values,
                            Value = option.MultiChoice and {},
                            Default = option.Default or 1,
                            MultiChoice = option.MultiChoice or false,
                            Callback = option.Callback or function(value)
                                end
                        }

                        local OpenedLists = false

                        local Options = Instance.new("Frame")
                        local Items = Instance.new("Frame")
                        local stroke = Instance.new("UIStroke")
                        local stroke1 = Instance.new("UIStroke")
                        local corner = Instance.new("UICorner")
                        local UICorner_9 = Instance.new("UICorner")
                        local Scrollable = Instance.new("ScrollingFrame")
                        local UIListLayout_3 = Instance.new("UIListLayout")
                        local Main = Instance.new("Frame")
                        local Title_6 = Instance.new("TextLabel")
                        local Click_2 = Instance.new("TextButton")
                        local PressArea = Instance.new("Frame")
                        local Icon = Instance.new("ImageLabel")
                        local Text = Instance.new("TextLabel")
                        local MAX_DROPDOWN_ITEMS = 8

                        Options.Name = "Options"
                        Options.Parent = Container_2
                        Options.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Options.BackgroundTransparency = 1.000
                        Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Options.BorderSizePixel = 0
                        Options.ClipsDescendants = true
                        Options.Size = UDim2.new(1, 0, 0, 20)
                        Options.AutomaticSize = Enum.AutomaticSize.Y

                        Main.Name = "Main"
                        Main.Parent = Options
                        Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Main.BackgroundTransparency = 1.000
                        Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Main.BorderSizePixel = 0
                        Main.Size = UDim2.new(1, 0, 0, 20)

                        Title_6.Name = "Title"
                        Title_6.Parent = Main
                        Title_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Title_6.BackgroundTransparency = 1.000
                        Title_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Title_6.BorderSizePixel = 0
                        Title_6.Position = UDim2.new(0, 0, 0, 0)
                        Title_6.Size = UDim2.new(1, 0, 1, 0)
                        Title_6.Font = Enum.Font.SourceSans
                        Title_6.Text = Dropdown.Title
                        Title_6.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Title_6.TextSize = 14.000
                        Title_6.TextTransparency = 0.500
                        Title_6.TextXAlignment = Enum.TextXAlignment.Left

                        Click_2.Name = "Click"
                        Click_2.Parent = Main
                        Click_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Click_2.BackgroundTransparency = 1.000
                        Click_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Click_2.BorderSizePixel = 0
                        Click_2.Size = UDim2.new(1, 0, 1, 0)
                        Click_2.ZIndex = 2
                        Click_2.Font = Enum.Font.SourceSans
                        Click_2.Text = ""
                        Click_2.TextColor3 = Color3.fromRGB(0, 0, 0)
                        Click_2.TextSize = 14.000
                        Click_2.TextTransparency = 1.000

                        PressArea.Name = "PressArea"
                        PressArea.Parent = Main
                        PressArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        PressArea.BackgroundTransparency = 1.000
                        PressArea.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        PressArea.BorderSizePixel = 0
                        PressArea.AnchorPoint = Vector2.new(1, 0.5)
                        PressArea.Position = UDim2.new(1, -1, 0.5, 0)
                        PressArea.Size = UDim2.new(0.4, 0, 0, 18)

                        stroke.Name = "Stroke"
                        stroke.Parent = PressArea
                        stroke.Color = Color3.fromRGB(255, 255, 255)
                        stroke.LineJoinMode = Enum.LineJoinMode.Round
                        stroke.Thickness = 1
                        stroke.Transparency = 0.9

                        corner.CornerRadius = UDim.new(0, 2)
                        corner.Parent = PressArea

                        Icon.Name = "Icon"
                        Icon.Parent = PressArea
                        Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Icon.BackgroundTransparency = 1.000
                        Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Icon.BorderSizePixel = 0
                        Icon.Position = UDim2.new(1, -16, 0, 2)
                        Icon.Size = UDim2.new(0, 12, 0, 12)
                        Icon.Image = "rbxassetid://11421095840"

                        Text.Name = "Text"
                        Text.Parent = PressArea
                        Text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Text.BackgroundTransparency = 1.000
                        Text.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Text.BorderSizePixel = 0
                        Text.Position = UDim2.new(0, 5, 0, 0)
                        Text.Size = UDim2.new(1, -21, 1, 0)
                        Text.Font = Enum.Font.SourceSans
                        Text.TextColor3 = Color3.fromRGB(255, 191, 248)
                        Text.TextSize = 14.000
                        Text.TextXAlignment = Enum.TextXAlignment.Left

                        Items.Name = "Items"
                        Items.Parent = lib
                        Items.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        Items.BackgroundTransparency = 0.05
                        Items.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Items.BorderSizePixel = 0
                        Items.AnchorPoint = Vector2.new(0, 0)
                        Items.Position = UDim2.new(1, -1, 0.4, 0)
                        Items.Size = UDim2.new(0.3, 0, 0, 63)
                        Items.Visible = false

                        stroke1.Name = "stroke1"
                        stroke1.Parent = Items
                        stroke1.Color = Color3.fromRGB(255, 255, 255)
                        stroke1.LineJoinMode = Enum.LineJoinMode.Round
                        stroke1.Thickness = 1
                        stroke1.Transparency = 0.9

                        UICorner_9.CornerRadius = UDim.new(0, 2)
                        UICorner_9.Parent = Items

                        Scrollable.Name = "Scrollable"
                        Scrollable.Parent = Items
                        Scrollable.Active = true
                        Scrollable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Scrollable.BackgroundTransparency = 1.000
                        Scrollable.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Scrollable.BorderSizePixel = 0
                        Scrollable.Size = UDim2.new(1, 0, 1, 0)
                        Scrollable.CanvasSize = UDim2.new(0, 0, 0, 0)
                        Scrollable.ScrollBarThickness = 0

                        local padding1 = Instance.new("UIPadding", Scrollable)
                        padding1.PaddingBottom = UDim.new(0, 0)
                        padding1.PaddingLeft = UDim.new(0, 3)
                        padding1.PaddingRight = UDim.new(0, 3)
                        padding1.PaddingTop = UDim.new(0, 0)

                        UIListLayout_3.Parent = Scrollable
                        UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

                        Library.updateCanvasSize(Scrollable, UIListLayout_3, padding1)

                        local updateItemsPositionAndSize = function()
                            Items.Size =
                                UDim2.new(
                                0,
                                PressArea.AbsoluteSize.X,
                                0,
                                PressArea.AbsoluteSize.Y + ((MAX_DROPDOWN_ITEMS * 20) + 3) or 60 + 3
                            )

                            Items.Position =
                                UDim2.new(
                                0,
                                PressArea.AbsolutePosition.X + 1,
                                0,
                                PressArea.AbsolutePosition.Y + PressArea.AbsoluteSize.Y + 5
                            )
                        end

                        Main:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateItemsPositionAndSize)
                        updateItemsPositionAndSize()

                        function Dropdown:Display()
                            local Values = Dropdown.Values
                            local Str = ""

                            if Dropdown.MultiChoice then
                                for Idx, Value in next, Values do
                                    if Dropdown.Value[Value] then
                                        Str = Str .. Value .. ", "
                                    end
                                end

                                Str = Str:sub(1, #Str - 2)
                            else
                                Str = Dropdown.Value or ""
                            end

                            Text.Text = (Str == "" and "None" or Str)
                        end

                        local BuildOptionLists = function()
                            local Values = Dropdown.Values
                            local Buttons = {}

                            for _, Button in ipairs(Scrollable:GetChildren()) do
                                if Button:IsA("TextButton") then
                                    Button:Destroy()
                                end
                            end

                            for i, val in next, Values do
                                local Table = {}

                                local optionValue = tostring(val)
                                local OptionButton = Instance.new("TextButton")
                                OptionButton.Name = "Option" .. i
                                OptionButton.Parent = Scrollable
                                OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                OptionButton.BackgroundTransparency = 1.000
                                OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                                OptionButton.BorderSizePixel = 0
                                OptionButton.Size = UDim2.new(1, 0, 0, 20)
                                OptionButton.Font = Enum.Font.SourceSans
                                OptionButton.Text = optionValue
                                OptionButton.TextTransparency = 0.5
                                OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                OptionButton.TextSize = 14.000
                                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                                OptionButton.ZIndex = 3

                                local Selected

                                if Dropdown.MultiChoice then
                                    Selected = Dropdown.Value[optionValue]
                                else
                                    Selected = Dropdown.Value == optionValue
                                end

                                function Table:Update()
                                    if Dropdown.MultiChoice then
                                        Selected = Dropdown.Value[optionValue]
                                    else
                                        Selected = Dropdown.Value == optionValue
                                    end

                                    OptionButton.TextTransparency = Selected and 0 or 0.5
                                    OptionButton.TextColor3 =
                                        Selected and Color3.fromRGB(255, 191, 248) or Color3.fromRGB(255, 255, 255)
                                end

                                OptionButton.MouseButton1Click:Connect(
                                    function()
                                        local Try = not Selected

                                        if Dropdown.MultiChoice then
                                            Selected = Try

                                            if Selected then
                                                Dropdown.Value[optionValue] = true
                                            else
                                                Dropdown.Value[optionValue] = nil
                                            end
                                        else
                                            Selected = Try

                                            if Selected then
                                                Dropdown.Value = optionValue
                                            else
                                                Dropdown.Value = nil
                                            end

                                            for _, OtherButton in next, Buttons do
                                                OtherButton:Update()
                                            end
                                        end

                                        Dropdown:Display()
                                        Table:Update()
                                        Dropdown.Callback(Dropdown.Value)
                                    end
                                )

                                Dropdown:Display()
                                Table:Update()

                                Buttons[OptionButton] = Table
                            end
                        end

                        function Dropdown:Open()
                            Items.Visible = true
                            _G.DropdownAreOpened = true
                            tween.new(
                                Title_6,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {TextTransparency = 0}
                            ):start()
                            tween.new(
                                Icon,
                                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {Rotation = 180}
                            ):start()
                        end

                        function Dropdown:Close()
                            Items.Visible = false
                            _G.DropdownAreOpened = false
                            tween.new(
                                Title_6,
                                TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                                {TextTransparency = 0.5}
                            ):start()
                            tween.new(
                                Icon,
                                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {Rotation = 0}
                            ):start()
                        end

                        InputService.InputBegan:Connect(
                            function(Input)
                                if
                                    table.find(
                                        {Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch},
                                        Input.UserInputType
                                    )
                                 then
                                    local AbsPos, AbsSize = Items.AbsolutePosition, Items.AbsoluteSize

                                    if
                                        Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or
                                            Mouse.Y < (AbsPos.Y - 20 - 1) or
                                            Mouse.Y > AbsPos.Y + AbsSize.Y
                                     then
                                        Dropdown:Close()
                                    end
                                end
                            end
                        )

                        function Dropdown:IsActive()
                            local result = false
                            for key, ui in pairs(lib:GetChildren()) do
                                if ui.Name == "Items" then
                                    if ui.Visible then
                                        result = true
                                        break
                                    end
                                end
                            end
                            return result
                        end

                        Click_2.MouseButton1Click:Connect(
                            function()
                                if Items.Visible then
                                    Dropdown:Close()
                                elseif not Items.Visible then
                                    if Dropdown:IsActive() then
                                        return
                                    end
                                    Dropdown:Open()
                                end
                            end
                        )

                        local Defaults = {}

                        if type(Dropdown.Default) == "string" then
                            local Idx = table.find(Dropdown.Values, Dropdown.Default)
                            if Idx then
                                table.insert(Defaults, Idx)
                            end
                        elseif type(Dropdown.Default) == "table" then
                            for _, Value in next, Dropdown.Default do
                                local Idx = table.find(Dropdown.Values, Value)
                                if Idx then
                                    table.insert(Defaults, Idx)
                                end
                            end
                        elseif type(Dropdown.Default) == "number" and Dropdown.Values[Dropdown.Default] ~= nil then
                            table.insert(Defaults, Dropdown.Default)
                        end

                        if next(Defaults) then
                            for i = 1, #Defaults do
                                local Index = Defaults[i]
                                if Dropdown.MultiChoice then
                                    Dropdown.Value[Dropdown.Values[Index]] = true
                                else
                                    Dropdown.Value = Dropdown.Values[Index]
                                end

                                if not Dropdown.MultiChoice then
                                    break
                                end
                            end
                        end

                        Dropdown:Display()

                        BuildOptionLists(Dropdown.Values)

                        return {
                            SetValues = function(new)
                                Dropdown.Values = new
                                BuildOptionLists(new)
                            end,
                            SetValue = function(Val)
                                if Dropdown.MultiChoice then
                                    local nTable = {}
                                    for Value, Bool in next, Val do
                                        if table.find(Dropdown.Values, Value) then
                                            nTable[Value] = true
                                        end
                                    end
                                    Dropdown.Value = nTable
                                else
                                    if not Val then
                                        Dropdown.Value = nil
                                    elseif table.find(Dropdown.Values, Val) then
                                        Dropdown.Value = Val
                                    end
                                end

                                BuildOptionLists(Dropdown.Value)
                                Library.safeCallback(Dropdown.Callback)
                            end
                        }
                    end
                }
            end
        }
    end
    return funcs
end
