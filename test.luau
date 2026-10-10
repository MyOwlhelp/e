--[[
	Fancy UI Library

	10/10/2026
	6:22 PM
	GMT+7
]]

local Fancy = {
	Elements = {},
	Modules = {},
	Tabs = {},
	Topbars = {},
	SelectedTab = nil,
	MainUI = nil,
	WindowSettings = nil,
	Window = nil,
	WindowAPI = nil,
	Refs = nil,
	Theme = nil,
	ThemeName = "Default"
}

local WindowDefaults = {
	Title = "Fancy UI",
	Center = true,
	Resizeable = true,
	Shadow = false,
	Position = UDim2.fromOffset(323, 34),
	Size = UDim2.fromOffset(691, 457),
	MinSize = Vector2.new(540, 350),
	Theme = "Default",
	ToggleKey = Enum.KeyCode.K,
	Configuration = {
		AutoSave = true,
		AutoLoad = true,
		FileName = "FancyConfig",
		CustomFolder = "FancyUI"
	}
}

local clref = (typeof(cloneref) == "function" and cloneref or typeof(clonereference) == "function" and clonereference) or function(...)
	return ...
end

local function GetService(service)
	local instance = game:GetService(service) or game:FindService(service)
	if instance and clref then
		return clref(instance)
	end
	return instance
end

local Services = {
	UserInputService = GetService("UserInputService"),
	TweenService = GetService("TweenService"),
	TextService = GetService("TextService"),
	HttpService = GetService("HttpService"),
	RunService = GetService("RunService"),
	Workspace = GetService("Workspace"),
	CoreGui = GetService("CoreGui"),
	Players = GetService("Players")
}

local LP = Services.Players.LocalPlayer
local HiddenUI = (typeof(gethui) == "function" and gethui()) or (LP and clref(LP.PlayerGui)) or Services.CoreGui
if HiddenUI then
	if HiddenUI:FindFirstChild("FancyUI") then
		pcall(function()
			HiddenUI.FancyUI:Destroy()
		end)
	end
	if HiddenUI:FindFirstChild("FancyTopbars") then
		pcall(function()
			HiddenUI.FancyTopbars:Destroy()
		end)
	end
end

local SaveManager = {
	Folder = "FancyUI/Configs",
	DefaultName = "FancyConfig",
	AutoSaveInterval = 60,
	DebounceDelay = 2
}

local SaveManager_Internal = {
	FileApi = false,
	Registry = {},
	Pending = {},
	MemoryConfigs = {},
	AutoSaveToken = 0,
	DebounceToken = 0
}

local InstanceModule = {}
local Notifications = {}

local Signal = {}
local Utility = {}

local Elements = {
	Button = {},
	Dropdown = {},
	Input = {},
	Keybind = {},
	Paragraph = {},
	Section = {},
	Slider = {},
	Tab = {},
	Toggle = {},
	Topbar = {},
	Window = {}
}

function InstanceModule:Create(className, properties)
	if typeof(className) ~= "string" then return nil end

	local ok, new = pcall(Instance.new, className)
	if not ok or not new then return nil end

	local parent
	if typeof(properties) == "table" then
		parent = properties.Parent
		for name, value in properties do
			if name ~= "Parent" then
				pcall(function()
					new[name] = value
				end)
			end
		end
	end

	if parent ~= nil then
		pcall(function()
			new.Parent = parent
		end)
	end

	return clref(new)
end

InstanceModule.New = InstanceModule.Create

Fancy.MainUI = InstanceModule:Create("ScreenGui", {
	Name = "FancyUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	Parent = HiddenUI
})

Fancy.TopbarUI = InstanceModule:Create("ScreenGui", {
	Name = "FancyTopbars",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 1000,
	Parent = HiddenUI
})

Fancy.NotifyLayer = Fancy.TopbarUI or Fancy.MainUI

if not Fancy.MainUI then
	warn("[Fancy] Failed to create the ScreenGui")
	return
end

local Icons = {
	Icons = {
		["a-arrow-down"] = "rbxassetid://92867583610071",
		["a-arrow-up"] = "rbxassetid://132318504999733",
		["a-large-small"] = "rbxassetid://111491496660216",
		["accessibility"] = "rbxassetid://114029945302017",
		["activity"] = "rbxassetid://94212016861936",
		["air-vent"] = "rbxassetid://81517226012329",
		["airplay"] = "rbxassetid://115020759309179",
		["alarm-clock-check"] = "rbxassetid://76437352099157",
		["alarm-clock-minus"] = "rbxassetid://77364179863205",
		["alarm-clock-off"] = "rbxassetid://97904885874823",
		["alarm-clock-plus"] = "rbxassetid://80468822979214",
		["alarm-clock"] = "rbxassetid://126259032907535",
		["alarm-smoke"] = "rbxassetid://96965448419685",
		["album"] = "rbxassetid://127358331163602",
		["align-center-horizontal"] = "rbxassetid://81570549209434",
		["align-center-vertical"] = "rbxassetid://118470463752466",
		["align-end-horizontal"] = "rbxassetid://139502909745427",
		["align-end-vertical"] = "rbxassetid://96528869059554",
		["align-horizontal-distribute-center"] = "rbxassetid://97220086126656",
		["align-horizontal-distribute-end"] = "rbxassetid://106128590702022",
		["align-horizontal-distribute-start"] = "rbxassetid://76074660002997",
		["align-horizontal-justify-center"] = "rbxassetid://75732302772427",
		["align-horizontal-justify-end"] = "rbxassetid://129167626402283",
		["align-horizontal-justify-start"] = "rbxassetid://130161830325281",
		["align-horizontal-space-around"] = "rbxassetid://91646106782950",
		["align-horizontal-space-between"] = "rbxassetid://103886093046990",
		["align-start-horizontal"] = "rbxassetid://125674804697729",
		["align-start-vertical"] = "rbxassetid://105020230154823",
		["align-vertical-distribute-center"] = "rbxassetid://93791183635525",
		["align-vertical-distribute-end"] = "rbxassetid://139354223511433",
		["align-vertical-distribute-start"] = "rbxassetid://74961997822126",
		["align-vertical-justify-center"] = "rbxassetid://134754696166569",
		["align-vertical-justify-end"] = "rbxassetid://92569381441969",
		["align-vertical-justify-start"] = "rbxassetid://99692844572718",
		["align-vertical-space-around"] = "rbxassetid://96206012459190",
		["align-vertical-space-between"] = "rbxassetid://124998077349706",
		["ambulance"] = "rbxassetid://78599995190651",
		["ampersand"] = "rbxassetid://75272915739209",
		["ampersands"] = "rbxassetid://126947193455996",
		["amphora"] = "rbxassetid://137370389604364",
		["anchor"] = "rbxassetid://92181172123618",
		["angry"] = "rbxassetid://74237056000103",
		["annoyed"] = "rbxassetid://80064369052011",
		["antenna"] = "rbxassetid://99628923540956",
		["anvil"] = "rbxassetid://100203029845919",
		["aperture"] = "rbxassetid://83396154449972",
		["app-window-mac"] = "rbxassetid://79587216113811",
		["app-window"] = "rbxassetid://93142176757189",
		["apple"] = "rbxassetid://104349242902442",
		["archive-restore"] = "rbxassetid://78956681942188",
		["archive-x"] = "rbxassetid://75830115088395",
		["archive"] = "rbxassetid://122180020814574",
		["armchair"] = "rbxassetid://105384358373973",
		["arrow-big-down-dash"] = "rbxassetid://137987229582002",
		["arrow-big-down"] = "rbxassetid://81081164158885",
		["arrow-big-left-dash"] = "rbxassetid://97827621354677",
		["arrow-big-left"] = "rbxassetid://85973092492641",
		["arrow-big-right-dash"] = "rbxassetid://117825834972403",
		["arrow-big-right"] = "rbxassetid://82960676755590",
		["arrow-big-up-dash"] = "rbxassetid://99260194327483",
		["arrow-big-up"] = "rbxassetid://93136954756149",
		["arrow-down-0-1"] = "rbxassetid://120961896217875",
		["arrow-down-1-0"] = "rbxassetid://93474255891850",
		["arrow-down-a-z"] = "rbxassetid://99554596207900",
		["arrow-down-from-line"] = "rbxassetid://132045845807798",
		["arrow-down-left"] = "rbxassetid://102899325237364",
		["arrow-down-narrow-wide"] = "rbxassetid://129105261655061",
		["arrow-down-right"] = "rbxassetid://123109928624974",
		["arrow-down-to-dot"] = "rbxassetid://101675355931221",
		["arrow-down-to-line"] = "rbxassetid://87050478931254",
		["arrow-down-up"] = "rbxassetid://85780258549577",
		["arrow-down-wide-narrow"] = "rbxassetid://88461733425991",
		["arrow-down-z-a"] = "rbxassetid://76115279362232",
		["arrow-down"] = "rbxassetid://98764963621439",
		["arrow-left-from-line"] = "rbxassetid://87857914437603",
		["arrow-left-right"] = "rbxassetid://131324733048447",
		["arrow-left-to-line"] = "rbxassetid://118645136026970",
		["arrow-left"] = "rbxassetid://102531941843733",
		["arrow-right-from-line"] = "rbxassetid://74073639809355",
		["arrow-right-left"] = "rbxassetid://77015754304300",
		["arrow-right-to-line"] = "rbxassetid://78632510329852",
		["arrow-right"] = "rbxassetid://113692007244654",
		["arrow-up-0-1"] = "rbxassetid://105257823943016",
		["arrow-up-1-0"] = "rbxassetid://134175521693798",
		["arrow-up-a-z"] = "rbxassetid://77763416595160",
		["arrow-up-down"] = "rbxassetid://81019887641527",
		["arrow-up-from-dot"] = "rbxassetid://124408496673275",
		["arrow-up-from-line"] = "rbxassetid://95777664626453",
		["arrow-up-left"] = "rbxassetid://123490598231261",
		["arrow-up-narrow-wide"] = "rbxassetid://73006024672636",
		["arrow-up-right"] = "rbxassetid://129280608535523",
		["arrow-up-to-line"] = "rbxassetid://108818207813537",
		["arrow-up-wide-narrow"] = "rbxassetid://87437426951568",
		["arrow-up-z-a"] = "rbxassetid://107546173611884",
		["arrow-up"] = "rbxassetid://89282378235317",
		["arrows-up-from-line"] = "rbxassetid://133710016938621",
		["asterisk"] = "rbxassetid://88552752106723",
		["at-sign"] = "rbxassetid://79059152889146",
		["atom"] = "rbxassetid://73167696981648",
		["audio-lines"] = "rbxassetid://70930641819242",
		["audio-waveform"] = "rbxassetid://86462036665209",
		["award"] = "rbxassetid://132740088158419",
		["axe"] = "rbxassetid://132405197863294",
		["axis-3d"] = "rbxassetid://122438676546804",
		["baby"] = "rbxassetid://93472926933440",
		["backpack"] = "rbxassetid://140420225386018",
		["badge-alert"] = "rbxassetid://101829200081951",
		["badge-cent"] = "rbxassetid://133345018873154",
		["badge-check"] = "rbxassetid://76078495178149",
		["badge-dollar-sign"] = "rbxassetid://127139803581141",
		["badge-euro"] = "rbxassetid://120016477674659",
		["badge-indian-rupee"] = "rbxassetid://75659682309981",
		["badge-info"] = "rbxassetid://131995373201472",
		["badge-japanese-yen"] = "rbxassetid://99081574588615",
		["badge-minus"] = "rbxassetid://140321561183881",
		["badge-percent"] = "rbxassetid://121359224294885",
		["badge-plus"] = "rbxassetid://100325578561866",
		["badge-pound-sterling"] = "rbxassetid://119688217279444",
		["badge-question-mark"] = "rbxassetid://121464963737502",
		["badge-russian-ruble"] = "rbxassetid://108839463659864",
		["badge-swiss-franc"] = "rbxassetid://91447608372740",
		["badge-turkish-lira"] = "rbxassetid://137839965873529",
		["badge-x"] = "rbxassetid://122931434733842",
		["badge"] = "rbxassetid://116620312917084",
		["baggage-claim"] = "rbxassetid://86922213051957",
		["ban"] = "rbxassetid://90767043015246",
		["banana"] = "rbxassetid://140713420056179",
		["bandage"] = "rbxassetid://129660129590770",
		["banknote-arrow-down"] = "rbxassetid://139366449345199",
		["banknote-arrow-up"] = "rbxassetid://133758343082529",
		["banknote-x"] = "rbxassetid://95348701438065",
		["banknote"] = "rbxassetid://104840231536668",
		["barcode"] = "rbxassetid://118473018143689",
		["barrel"] = "rbxassetid://130647115622774",
		["baseline"] = "rbxassetid://124677132511270",
		["bath"] = "rbxassetid://76031400297942",
		["battery-charging"] = "rbxassetid://80139357470047",
		["battery-full"] = "rbxassetid://70906718268972",
		["battery-low"] = "rbxassetid://139659256984314",
		["battery-medium"] = "rbxassetid://105934079398915",
		["battery-plus"] = "rbxassetid://91931341486966",
		["battery-warning"] = "rbxassetid://115230083817257",
		["battery"] = "rbxassetid://70765800346189",
		["beaker"] = "rbxassetid://80902539995520",
		["bean-off"] = "rbxassetid://98164436608714",
		["bean"] = "rbxassetid://89491967076869",
		["bed-double"] = "rbxassetid://73820193212911",
		["bed-single"] = "rbxassetid://113423940880634",
		["bed"] = "rbxassetid://97726529032925",
		["beef"] = "rbxassetid://105850162318915",
		["beer-off"] = "rbxassetid://120333134736361",
		["beer"] = "rbxassetid://116404978807744",
		["bell-dot"] = "rbxassetid://93161277118810",
		["bell-electric"] = "rbxassetid://100277767266983",
		["bell-minus"] = "rbxassetid://126334890449727",
		["bell-off"] = "rbxassetid://78560046118930",
		["bell-plus"] = "rbxassetid://77014333795836",
		["bell-ring"] = "rbxassetid://94612128913941",
		["bell"] = "rbxassetid://97392696311902",
		["between-horizontal-end"] = "rbxassetid://81602774794322",
		["between-horizontal-start"] = "rbxassetid://76112384929846",
		["between-vertical-end"] = "rbxassetid://72817612571631",
		["between-vertical-start"] = "rbxassetid://85278312190301",
		["biceps-flexed"] = "rbxassetid://82004462003936",
		["bike"] = "rbxassetid://102930322246035",
		["binary"] = "rbxassetid://91751953950088",
		["binoculars"] = "rbxassetid://101460003267896",
		["biohazard"] = "rbxassetid://95956532900432",
		["bird"] = "rbxassetid://132284145117371",
		["birdhouse"] = "rbxassetid://83999157401433",
		["bitcoin"] = "rbxassetid://95459240442938",
		["blend"] = "rbxassetid://111679612185257",
		["blinds"] = "rbxassetid://71164165283925",
		["blocks"] = "rbxassetid://72212693357737",
		["bluetooth-connected"] = "rbxassetid://96315134002985",
		["bluetooth-off"] = "rbxassetid://80600044218117",
		["bluetooth-searching"] = "rbxassetid://100673019606426",
		["bluetooth"] = "rbxassetid://90506573139443",
		["bold"] = "rbxassetid://116141470019166",
		["bolt"] = "rbxassetid://102881251417484",
		["bomb"] = "rbxassetid://139223800924636",
		["bone"] = "rbxassetid://111242153474115",
		["book-a"] = "rbxassetid://104067275658465",
		["book-alert"] = "rbxassetid://124159928044853",
		["book-audio"] = "rbxassetid://109208148317037",
		["book-check"] = "rbxassetid://115999656081696",
		["book-copy"] = "rbxassetid://108543407492005",
		["book-dashed"] = "rbxassetid://127430784795958",
		["book-down"] = "rbxassetid://101011730128222",
		["book-headphones"] = "rbxassetid://108670200799574",
		["book-heart"] = "rbxassetid://112788845135284",
		["book-image"] = "rbxassetid://80808285757226",
		["book-key"] = "rbxassetid://116024426170705",
		["book-lock"] = "rbxassetid://118765061220571",
		["book-marked"] = "rbxassetid://73211024251780",
		["book-minus"] = "rbxassetid://112724962046282",
		["book-open-check"] = "rbxassetid://130848362492667",
		["book-open-text"] = "rbxassetid://100629528672195",
		["book-open"] = "rbxassetid://129845326810392",
		["book-plus"] = "rbxassetid://140267785051233",
		["book-text"] = "rbxassetid://94011772484232",
		["book-type"] = "rbxassetid://97817304725443",
		["book-up-2"] = "rbxassetid://130161620853665",
		["book-up"] = "rbxassetid://98640174079190",
		["book-user"] = "rbxassetid://128489189240523",
		["book-x"] = "rbxassetid://118754548186537",
		["book"] = "rbxassetid://125383279695672",
		["bookmark-check"] = "rbxassetid://93940443347986",
		["bookmark-minus"] = "rbxassetid://96807096039910",
		["bookmark-plus"] = "rbxassetid://121469724491615",
		["bookmark-x"] = "rbxassetid://112272342584706",
		["bookmark"] = "rbxassetid://121093149326239",
		["boom-box"] = "rbxassetid://99901322535868",
		["bot-message-square"] = "rbxassetid://96145330292478",
		["bot-off"] = "rbxassetid://140417690560013",
		["bot"] = "rbxassetid://80451686744860",
		["bottle-wine"] = "rbxassetid://131675403196921",
		["bow-arrow"] = "rbxassetid://124089655150375",
		["box"] = "rbxassetid://101768155599700",
		["boxes"] = "rbxassetid://136372617578355",
		["braces"] = "rbxassetid://117761094704041",
		["brackets"] = "rbxassetid://74368995728099",
		["brain-circuit"] = "rbxassetid://70547962410202",
		["brain-cog"] = "rbxassetid://132039205501538",
		["brain"] = "rbxassetid://92424107303177",
		["brick-wall-fire"] = "rbxassetid://92980588705520",
		["brick-wall-shield"] = "rbxassetid://75954432775071",
		["brick-wall"] = "rbxassetid://112878522258821",
		["briefcase-business"] = "rbxassetid://129135125207283",
		["briefcase-conveyor-belt"] = "rbxassetid://108665725653714",
		["briefcase-medical"] = "rbxassetid://119917756334087",
		["briefcase"] = "rbxassetid://96754188164225",
		["bring-to-front"] = "rbxassetid://132975903553748",
		["brush-cleaning"] = "rbxassetid://71728977448805",
		["brush"] = "rbxassetid://127035535799640",
		["bubbles"] = "rbxassetid://106183424168227",
		["bug-off"] = "rbxassetid://88020025049245",
		["bug-play"] = "rbxassetid://80107955888092",
		["bug"] = "rbxassetid://83626408925438",
		["building-2"] = "rbxassetid://77873775611951",
		["building"] = "rbxassetid://110616258983082",
		["bus-front"] = "rbxassetid://89863432456045",
		["bus"] = "rbxassetid://133798469717463",
		["cable-car"] = "rbxassetid://128643682205596",
		["cable"] = "rbxassetid://128449944504901",
		["cake-slice"] = "rbxassetid://136769828413242",
		["cake"] = "rbxassetid://103131590503275",
		["calculator"] = "rbxassetid://74915716529646",
		["calendar-1"] = "rbxassetid://98458364171044",
		["calendar-arrow-down"] = "rbxassetid://108415736543437",
		["calendar-arrow-up"] = "rbxassetid://70574654109118",
		["calendar-check-2"] = "rbxassetid://120231170248276",
		["calendar-check"] = "rbxassetid://71551019465748",
		["calendar-clock"] = "rbxassetid://119132152594595",
		["calendar-cog"] = "rbxassetid://122402172360287",
		["calendar-days"] = "rbxassetid://99072017568595",
		["calendar-fold"] = "rbxassetid://117368871270394",
		["calendar-heart"] = "rbxassetid://88839008103676",
		["calendar-minus-2"] = "rbxassetid://98846170279891",
		["calendar-minus"] = "rbxassetid://137354318924383",
		["calendar-off"] = "rbxassetid://109726151749217",
		["calendar-plus-2"] = "rbxassetid://112264562093883",
		["calendar-plus"] = "rbxassetid://125266115249843",
		["calendar-range"] = "rbxassetid://103641849247576",
		["calendar-search"] = "rbxassetid://92010083223634",
		["calendar-sync"] = "rbxassetid://78082218499697",
		["calendar-x-2"] = "rbxassetid://107518051061147",
		["calendar-x"] = "rbxassetid://106703374806500",
		["calendar"] = "rbxassetid://114792700814035",
		["camera-off"] = "rbxassetid://81057636835256",
		["camera"] = "rbxassetid://79950339943067",
		["candy-cane"] = "rbxassetid://71689468772492",
		["candy-off"] = "rbxassetid://110232752314832",
		["candy"] = "rbxassetid://107812129154678",
		["cannabis"] = "rbxassetid://98792006538601",
		["captions-off"] = "rbxassetid://105223545364193",
		["captions"] = "rbxassetid://104960225031445",
		["car-front"] = "rbxassetid://87380942739063",
		["car-taxi-front"] = "rbxassetid://122455403384057",
		["car"] = "rbxassetid://121065933462582",
		["caravan"] = "rbxassetid://120070979471783",
		["card-sim"] = "rbxassetid://134490550095771",
		["carrot"] = "rbxassetid://119118221444304",
		["case-lower"] = "rbxassetid://129303130603241",
		["case-sensitive"] = "rbxassetid://125410273293056",
		["case-upper"] = "rbxassetid://111633433531325",
		["cassette-tape"] = "rbxassetid://137065788934157",
		["cast"] = "rbxassetid://98202245922071",
		["castle"] = "rbxassetid://119275077187784",
		["cat"] = "rbxassetid://124252153404931",
		["cctv"] = "rbxassetid://99979894766624",
		["chart-area"] = "rbxassetid://123446436762366",
		["chart-bar-big"] = "rbxassetid://72336824986044",
		["chart-bar-decreasing"] = "rbxassetid://107217459044963",
		["chart-bar-increasing"] = "rbxassetid://88268905998571",
		["chart-bar-stacked"] = "rbxassetid://98478751113024",
		["chart-bar"] = "rbxassetid://105389816384108",
		["chart-candlestick"] = "rbxassetid://125676898615697",
		["chart-column-big"] = "rbxassetid://98598733210787",
		["chart-column-decreasing"] = "rbxassetid://73586137373563",
		["chart-column-increasing"] = "rbxassetid://120421615068601",
		["chart-column-stacked"] = "rbxassetid://86031449675105",
		["chart-column"] = "rbxassetid://97915995538580",
		["chart-gantt"] = "rbxassetid://88811660555940",
		["chart-line"] = "rbxassetid://101833156055618",
		["chart-network"] = "rbxassetid://104027882693561",
		["chart-no-axes-column-decreasing"] = "rbxassetid://123371717192542",
		["chart-no-axes-column-increasing"] = "rbxassetid://140383830943049",
		["chart-no-axes-column"] = "rbxassetid://94078751170351",
		["chart-no-axes-combined"] = "rbxassetid://121424233161912",
		["chart-no-axes-gantt"] = "rbxassetid://131936541106368",
		["chart-pie"] = "rbxassetid://113412261630136",
		["chart-scatter"] = "rbxassetid://108217585014571",
		["chart-spline"] = "rbxassetid://90307460742494",
		["check-check"] = "rbxassetid://95183312173858",
		["check-line"] = "rbxassetid://115122343485290",
		["check"] = "rbxassetid://93898873302694",
		["chef-hat"] = "rbxassetid://121744015002573",
		["cherry"] = "rbxassetid://139519182403183",
		["chess-bishop"] = "rbxassetid://121701705580238",
		["chess-king"] = "rbxassetid://90885687223462",
		["chess-knight"] = "rbxassetid://96467707042169",
		["chess-pawn"] = "rbxassetid://111318574652751",
		["chess-queen"] = "rbxassetid://98304702099749",
		["chess-rook"] = "rbxassetid://76223925830262",
		["chevron-down"] = "rbxassetid://134243273101015",
		["chevron-first"] = "rbxassetid://105243363790238",
		["chevron-last"] = "rbxassetid://89268452603731",
		["chevron-left"] = "rbxassetid://73780377692148",
		["chevron-right"] = "rbxassetid://92473583511724",
		["chevron-up"] = "rbxassetid://122444883127455",
		["chevrons-down-up"] = "rbxassetid://139404716013205",
		["chevrons-down"] = "rbxassetid://100524612205956",
		["chevrons-left-right-ellipsis"] = "rbxassetid://125035817741526",
		["chevrons-left-right"] = "rbxassetid://87910685945204",
		["chevrons-left"] = "rbxassetid://82617201744347",
		["chevrons-right-left"] = "rbxassetid://87149546686569",
		["chevrons-right"] = "rbxassetid://139121276490483",
		["chevrons-up-down"] = "rbxassetid://131833120209646",
		["chevrons-up"] = "rbxassetid://100467452364672",
		["chromium"] = "rbxassetid://128165143739006",
		["church"] = "rbxassetid://113714744350666",
		["cigarette-off"] = "rbxassetid://77797883078452",
		["circle-alert"] = "rbxassetid://83898160590116",
		["circle-arrow-down"] = "rbxassetid://95901860261344",
		["circle-arrow-left"] = "rbxassetid://102148876968988",
		["circle-arrow-out-down-left"] = "rbxassetid://140598097856694",
		["circle-arrow-out-down-right"] = "rbxassetid://119952801379305",
		["circle-arrow-out-up-left"] = "rbxassetid://132858212688303",
		["circle-arrow-out-up-right"] = "rbxassetid://81783743753173",
		["circle-arrow-right"] = "rbxassetid://70786767999559",
		["circle-arrow-up"] = "rbxassetid://84395128546494",
		["circle-check-big"] = "rbxassetid://93202927221730",
		["circle-check"] = "rbxassetid://85262178816537",
		["circle-chevron-down"] = "rbxassetid://137069490345718",
		["circle-chevron-left"] = "rbxassetid://130250009740827",
		["circle-chevron-right"] = "rbxassetid://125943696958495",
		["circle-chevron-up"] = "rbxassetid://111223574026321",
		["circle-dashed"] = "rbxassetid://126799443883746",
		["circle-divide"] = "rbxassetid://106398997754208",
		["circle-dollar-sign"] = "rbxassetid://91106238890387",
		["circle-dot-dashed"] = "rbxassetid://111451232827180",
		["circle-dot"] = "rbxassetid://82947033619201",
		["circle-ellipsis"] = "rbxassetid://91687150884779",
		["circle-equal"] = "rbxassetid://95133963751438",
		["circle-fading-arrow-up"] = "rbxassetid://104648212910336",
		["circle-fading-plus"] = "rbxassetid://91847890443490",
		["circle-gauge"] = "rbxassetid://108157549473765",
		["circle-minus"] = "rbxassetid://133556159576809",
		["circle-off"] = "rbxassetid://97923456918886",
		["circle-parking-off"] = "rbxassetid://128369410981252",
		["circle-parking"] = "rbxassetid://124034962915196",
		["circle-pause"] = "rbxassetid://139337739700879",
		["circle-percent"] = "rbxassetid://133311912860256",
		["circle-play"] = "rbxassetid://120408917249739",
		["circle-plus"] = "rbxassetid://113157136350384",
		["circle-pound-sterling"] = "rbxassetid://105476153083828",
		["circle-power"] = "rbxassetid://140676030155098",
		["circle-question-mark"] = "rbxassetid://97516698664325",
		["circle-slash-2"] = "rbxassetid://136766902186549",
		["circle-slash"] = "rbxassetid://125206439913049",
		["circle-small"] = "rbxassetid://73685402843600",
		["circle-star"] = "rbxassetid://120318414957104",
		["circle-stop"] = "rbxassetid://87400503942659",
		["circle-user-round"] = "rbxassetid://95489465399880",
		["circle-user"] = "rbxassetid://136220511671311",
		["circle-x"] = "rbxassetid://76821953846248",
		["circle"] = "rbxassetid://130359823580534",
		["circuit-board"] = "rbxassetid://107695264369312",
		["citrus"] = "rbxassetid://139018222976433",
		["clapperboard"] = "rbxassetid://132660667070200",
		["clipboard-check"] = "rbxassetid://92649798577170",
		["clipboard-clock"] = "rbxassetid://123957515687745",
		["clipboard-copy"] = "rbxassetid://125851897718493",
		["clipboard-list"] = "rbxassetid://96460215958908",
		["clipboard-minus"] = "rbxassetid://107968008485671",
		["clipboard-paste"] = "rbxassetid://74382068849983",
		["clipboard-pen-line"] = "rbxassetid://77711589791615",
		["clipboard-pen"] = "rbxassetid://75290966822953",
		["clipboard-plus"] = "rbxassetid://134285318675662",
		["clipboard-type"] = "rbxassetid://89949374318028",
		["clipboard-x"] = "rbxassetid://102222456890103",
		["clipboard"] = "rbxassetid://89601995828423",
		["clock-1"] = "rbxassetid://129363225422045",
		["clock-10"] = "rbxassetid://104332695855541",
		["clock-11"] = "rbxassetid://119023205186105",
		["clock-12"] = "rbxassetid://117789618723068",
		["clock-2"] = "rbxassetid://134710777209413",
		["clock-3"] = "rbxassetid://136385631189327",
		["clock-4"] = "rbxassetid://121808839832144",
		["clock-5"] = "rbxassetid://85082019959457",
		["clock-6"] = "rbxassetid://71009733505593",
		["clock-7"] = "rbxassetid://103111188546225",
		["clock-8"] = "rbxassetid://110059272125337",
		["clock-9"] = "rbxassetid://77610027126437",
		["clock-alert"] = "rbxassetid://97157344465162",
		["clock-arrow-down"] = "rbxassetid://92349314416042",
		["clock-arrow-up"] = "rbxassetid://111484286332629",
		["clock-check"] = "rbxassetid://85231630218857",
		["clock-fading"] = "rbxassetid://93205297285245",
		["clock-plus"] = "rbxassetid://93367709263150",
		["clock"] = "rbxassetid://121808839832144",
		["closed-caption"] = "rbxassetid://99832644030788",
		["cloud-alert"] = "rbxassetid://91967273658626",
		["cloud-check"] = "rbxassetid://97318598202432",
		["cloud-cog"] = "rbxassetid://96497764065749",
		["cloud-download"] = "rbxassetid://121435581993566",
		["cloud-drizzle"] = "rbxassetid://139525315752605",
		["cloud-fog"] = "rbxassetid://76650233148776",
		["cloud-hail"] = "rbxassetid://72320462748242",
		["cloud-lightning"] = "rbxassetid://133517088924849",
		["cloud-moon-rain"] = "rbxassetid://127667837827018",
		["cloud-moon"] = "rbxassetid://71938114737914",
		["cloud-off"] = "rbxassetid://131907154501444",
		["cloud-rain-wind"] = "rbxassetid://107414583736721",
		["cloud-rain"] = "rbxassetid://105547081967408",
		["cloud-snow"] = "rbxassetid://72307126270226",
		["cloud-sun-rain"] = "rbxassetid://99041604425705",
		["cloud-sun"] = "rbxassetid://86114208148727",
		["cloud-upload"] = "rbxassetid://93307473217005",
		["cloud"] = "rbxassetid://121226497050352",
		["cloudy"] = "rbxassetid://105360479023346",
		["clover"] = "rbxassetid://74925550436750",
		["club"] = "rbxassetid://108490365816628",
		["code-xml"] = "rbxassetid://130150477351734",
		["code"] = "rbxassetid://107380207681249",
		["codepen"] = "rbxassetid://135643965971885",
		["codesandbox"] = "rbxassetid://106911852964823",
		["coffee"] = "rbxassetid://106864403231093",
		["cog"] = "rbxassetid://116544501716299",
		["coins"] = "rbxassetid://116510979641930",
		["columns-2"] = "rbxassetid://113004100221850",
		["columns-3-cog"] = "rbxassetid://121589691981064",
		["columns-3"] = "rbxassetid://115223357399375",
		["columns-4"] = "rbxassetid://130807991968419",
		["combine"] = "rbxassetid://79908476334048",
		["command"] = "rbxassetid://93648221906330",
		["compass"] = "rbxassetid://115123411028382",
		["component"] = "rbxassetid://110027788875080",
		["computer"] = "rbxassetid://77480056459407",
		["concierge-bell"] = "rbxassetid://140384259310436",
		["cone"] = "rbxassetid://97759550688437",
		["construction"] = "rbxassetid://106539489968173",
		["contact-round"] = "rbxassetid://71907624112229",
		["contact"] = "rbxassetid://75868297719012",
		["container"] = "rbxassetid://91507237573499",
		["contrast"] = "rbxassetid://112796643981497",
		["cookie"] = "rbxassetid://73159504540002",
		["cooking-pot"] = "rbxassetid://94959783129799",
		["copy-check"] = "rbxassetid://91177247988892",
		["copy-minus"] = "rbxassetid://109524509933035",
		["copy-plus"] = "rbxassetid://113618379616952",
		["copy-slash"] = "rbxassetid://93805787810390",
		["copy-x"] = "rbxassetid://106557557978061",
		["copy"] = "rbxassetid://78979572434545",
		["copyleft"] = "rbxassetid://78559055698593",
		["copyright"] = "rbxassetid://129433635747111",
		["corner-down-left"] = "rbxassetid://90473561177832",
		["corner-down-right"] = "rbxassetid://86512767702085",
		["corner-left-down"] = "rbxassetid://139876989150630",
		["corner-left-up"] = "rbxassetid://126228268096099",
		["corner-right-down"] = "rbxassetid://89237035551302",
		["corner-right-up"] = "rbxassetid://112851237026705",
		["corner-up-left"] = "rbxassetid://84669279763024",
		["corner-up-right"] = "rbxassetid://115099889693145",
		["cpu"] = "rbxassetid://77549309870247",
		["creative-commons"] = "rbxassetid://90408210735312",
		["credit-card"] = "rbxassetid://99163352872346",
		["croissant"] = "rbxassetid://130710485559420",
		["crop"] = "rbxassetid://116344601101413",
		["cross"] = "rbxassetid://101833377863588",
		["crosshair"] = "rbxassetid://134242818164054",
		["crown"] = "rbxassetid://127843403295538",
		["cuboid"] = "rbxassetid://75618807946111",
		["cup-soda"] = "rbxassetid://121098640829562",
		["currency"] = "rbxassetid://90551250119972",
		["cylinder"] = "rbxassetid://90569677179169",
		["dam"] = "rbxassetid://76874486231393",
		["database-backup"] = "rbxassetid://103403210984699",
		["database-zap"] = "rbxassetid://131199921258418",
		["database"] = "rbxassetid://126791525623846",
		["decimals-arrow-left"] = "rbxassetid://120198500638749",
		["decimals-arrow-right"] = "rbxassetid://118263047146797",
		["delete"] = "rbxassetid://126279426372342",
		["dessert"] = "rbxassetid://71508133278830",
		["diameter"] = "rbxassetid://97429051503783",
		["diamond-minus"] = "rbxassetid://128989071438290",
		["diamond-percent"] = "rbxassetid://107717860105959",
		["diamond-plus"] = "rbxassetid://134701163723675",
		["diamond"] = "rbxassetid://105846996304890",
		["dice-1"] = "rbxassetid://112650149591038",
		["dice-2"] = "rbxassetid://112278274566793",
		["dice-3"] = "rbxassetid://118526270626312",
		["dice-4"] = "rbxassetid://113365650364004",
		["dice-5"] = "rbxassetid://72768312430593",
		["dice-6"] = "rbxassetid://85376239182543",
		["dices"] = "rbxassetid://81268120302865",
		["diff"] = "rbxassetid://135052708609715",
		["disc-2"] = "rbxassetid://91419420404185",
		["disc-3"] = "rbxassetid://135470554736048",
		["disc-album"] = "rbxassetid://74693460404344",
		["disc"] = "rbxassetid://101908120120777",
		["divide"] = "rbxassetid://136678191878278",
		["dna-off"] = "rbxassetid://89612426361540",
		["dna"] = "rbxassetid://74007982981741",
		["dock"] = "rbxassetid://121997427160252",
		["dog"] = "rbxassetid://71920105558570",
		["dollar-sign"] = "rbxassetid://127320961224019",
		["donut"] = "rbxassetid://72204922742657",
		["door-closed-locked"] = "rbxassetid://74027613267551",
		["door-closed"] = "rbxassetid://136249099949073",
		["door-open"] = "rbxassetid://91306356501736",
		["dot"] = "rbxassetid://137321056643916",
		["download"] = "rbxassetid://134814648082393",
		["drafting-compass"] = "rbxassetid://99701976182841",
		["drama"] = "rbxassetid://110297795801577",
		["dribbble"] = "rbxassetid://80231809663849",
		["drill"] = "rbxassetid://108644821412796",
		["drone"] = "rbxassetid://117299095794783",
		["droplet-off"] = "rbxassetid://119365002225172",
		["droplet"] = "rbxassetid://100597455015098",
		["droplets"] = "rbxassetid://140111846025180",
		["drum"] = "rbxassetid://136979060344890",
		["drumstick"] = "rbxassetid://104662462521709",
		["dumbbell"] = "rbxassetid://80277236776212",
		["ear-off"] = "rbxassetid://87421916192807",
		["ear"] = "rbxassetid://121894949934209",
		["earth-lock"] = "rbxassetid://88814147073745",
		["earth"] = "rbxassetid://76231597751076",
		["eclipse"] = "rbxassetid://114829622118222",
		["egg-fried"] = "rbxassetid://90622538210545",
		["egg-off"] = "rbxassetid://92288321309285",
		["egg"] = "rbxassetid://117851493400222",
		["ellipsis-vertical"] = "rbxassetid://117978708573781",
		["ellipsis"] = "rbxassetid://140019550645825",
		["equal-approximately"] = "rbxassetid://105382689698323",
		["equal-not"] = "rbxassetid://76864449458032",
		["equal"] = "rbxassetid://123467780715624",
		["eraser"] = "rbxassetid://133957773112410",
		["ethernet-port"] = "rbxassetid://75391715149314",
		["euro"] = "rbxassetid://72229646524456",
		["ev-charger"] = "rbxassetid://97906158859623",
		["expand"] = "rbxassetid://137492887754537",
		["external-link"] = "rbxassetid://129331830773832",
		["eye-closed"] = "rbxassetid://111063268625789",
		["eye-off"] = "rbxassetid://135928786788378",
		["eye"] = "rbxassetid://100033680381365",
		["facebook"] = "rbxassetid://72098528632192",
		["factory"] = "rbxassetid://102170024318039",
		["fan"] = "rbxassetid://78391400440696",
		["fast-forward"] = "rbxassetid://121615540167909",
		["feather"] = "rbxassetid://91872927606406",
		["fence"] = "rbxassetid://123451565578029",
		["ferris-wheel"] = "rbxassetid://79729205796176",
		["figma"] = "rbxassetid://134182122852301",
		["file-archive"] = "rbxassetid://77018106869967",
		["file-axis-3d"] = "rbxassetid://133912328009885",
		["file-badge"] = "rbxassetid://74564895394477",
		["file-box"] = "rbxassetid://119264004071690",
		["file-braces-corner"] = "rbxassetid://77253337986109",
		["file-braces"] = "rbxassetid://95314128621234",
		["file-chart-column-increasing"] = "rbxassetid://134449481172067",
		["file-chart-column"] = "rbxassetid://82048481252560",
		["file-chart-line"] = "rbxassetid://71954360551345",
		["file-chart-pie"] = "rbxassetid://81072193564497",
		["file-check-corner"] = "rbxassetid://76295552859171",
		["file-check"] = "rbxassetid://82604001452455",
		["file-clock"] = "rbxassetid://102325208830990",
		["file-code-corner"] = "rbxassetid://78293841184371",
		["file-code"] = "rbxassetid://130978036895504",
		["file-cog"] = "rbxassetid://101385347151368",
		["file-diff"] = "rbxassetid://96147216772241",
		["file-digit"] = "rbxassetid://89220220354580",
		["file-down"] = "rbxassetid://120650154178290",
		["file-exclamation-point"] = "rbxassetid://102821865889635",
		["file-headphone"] = "rbxassetid://100533735901986",
		["file-heart"] = "rbxassetid://132214916401696",
		["file-image"] = "rbxassetid://123334057511782",
		["file-input"] = "rbxassetid://124728604166044",
		["file-key"] = "rbxassetid://118790255921100",
		["file-lock"] = "rbxassetid://72170228691242",
		["file-minus-corner"] = "rbxassetid://119263271735124",
		["file-minus"] = "rbxassetid://111014798459222",
		["file-music"] = "rbxassetid://134948051536671",
		["file-output"] = "rbxassetid://92146832572911",
		["file-pen-line"] = "rbxassetid://104622936345006",
		["file-pen"] = "rbxassetid://79556179730240",
		["file-play"] = "rbxassetid://89006821567838",
		["file-plus-corner"] = "rbxassetid://76544604043974",
		["file-plus"] = "rbxassetid://78881710800060",
		["file-question-mark"] = "rbxassetid://127617422859576",
		["file-scan"] = "rbxassetid://129480105228213",
		["file-search-corner"] = "rbxassetid://90974165234008",
		["file-search"] = "rbxassetid://97780235974933",
		["file-signal"] = "rbxassetid://122070252538165",
		["file-sliders"] = "rbxassetid://85787771732439",
		["file-spreadsheet"] = "rbxassetid://134501869359270",
		["file-stack"] = "rbxassetid://138929929862605",
		["file-symlink"] = "rbxassetid://91865722036510",
		["file-terminal"] = "rbxassetid://116757454755476",
		["file-text"] = "rbxassetid://90496405707281",
		["file-type-corner"] = "rbxassetid://124902230275209",
		["file-type"] = "rbxassetid://115272552799361",
		["file-up"] = "rbxassetid://131173039312748",
		["file-user"] = "rbxassetid://99552018455009",
		["file-video-camera"] = "rbxassetid://81719056173960",
		["file-volume"] = "rbxassetid://111264764438958",
		["file-x-corner"] = "rbxassetid://87554136773609",
		["file-x"] = "rbxassetid://107333775515154",
		["file"] = "rbxassetid://74748492079329",
		["files"] = "rbxassetid://102806336233202",
		["film"] = "rbxassetid://120978945609706",
		["fingerprint"] = "rbxassetid://112173305232811",
		["fire-extinguisher"] = "rbxassetid://111643493006960",
		["fish-off"] = "rbxassetid://89756724887508",
		["fish-symbol"] = "rbxassetid://118475177681618",
		["fish"] = "rbxassetid://124360663785796",
		["flag-off"] = "rbxassetid://112944528856799",
		["flag-triangle-left"] = "rbxassetid://88045221285272",
		["flag-triangle-right"] = "rbxassetid://108292480304566",
		["flag"] = "rbxassetid://78183383236196",
		["flame-kindling"] = "rbxassetid://139728976917928",
		["flame"] = "rbxassetid://98218034436456",
		["flashlight-off"] = "rbxassetid://79780362871740",
		["flashlight"] = "rbxassetid://100286985600444",
		["flask-conical-off"] = "rbxassetid://112597970025298",
		["flask-conical"] = "rbxassetid://128406680901165",
		["flask-round"] = "rbxassetid://127508287324940",
		["flip-horizontal-2"] = "rbxassetid://103726993598186",
		["flip-horizontal"] = "rbxassetid://122937530107837",
		["flip-vertical-2"] = "rbxassetid://103836358956328",
		["flip-vertical"] = "rbxassetid://108003917346888",
		["flower-2"] = "rbxassetid://72934574245145",
		["flower"] = "rbxassetid://86129438272762",
		["focus"] = "rbxassetid://87493973153317",
		["fold-horizontal"] = "rbxassetid://92835712442240",
		["fold-vertical"] = "rbxassetid://108873727253656",
		["folder-archive"] = "rbxassetid://97312009460206",
		["folder-check"] = "rbxassetid://128492920904557",
		["folder-clock"] = "rbxassetid://111964836738545",
		["folder-closed"] = "rbxassetid://118286209350843",
		["folder-code"] = "rbxassetid://70624096349370",
		["folder-cog"] = "rbxassetid://85299519462846",
		["folder-dot"] = "rbxassetid://138687772725278",
		["folder-down"] = "rbxassetid://118044108459225",
		["folder-git-2"] = "rbxassetid://101394054141166",
		["folder-git"] = "rbxassetid://121885778095158",
		["folder-heart"] = "rbxassetid://79104747211105",
		["folder-input"] = "rbxassetid://90699920697871",
		["folder-kanban"] = "rbxassetid://78313285104072",
		["folder-key"] = "rbxassetid://85270407596791",
		["folder-lock"] = "rbxassetid://119201572260567",
		["folder-minus"] = "rbxassetid://85648718999010",
		["folder-open-dot"] = "rbxassetid://74741494767354",
		["folder-open"] = "rbxassetid://76018996254888",
		["folder-output"] = "rbxassetid://101532447937612",
		["folder-pen"] = "rbxassetid://112770491173911",
		["folder-plus"] = "rbxassetid://91865663406119",
		["folder-root"] = "rbxassetid://103333751154693",
		["folder-search-2"] = "rbxassetid://71276453442655",
		["folder-search"] = "rbxassetid://110568075123861",
		["folder-symlink"] = "rbxassetid://127485747227189",
		["folder-sync"] = "rbxassetid://91544602659796",
		["folder-tree"] = "rbxassetid://85577554337861",
		["folder-up"] = "rbxassetid://72008269765857",
		["folder-x"] = "rbxassetid://91699618247635",
		["folder"] = "rbxassetid://80846616596607",
		["folders"] = "rbxassetid://110351216219061",
		["footprints"] = "rbxassetid://139192589041315",
		["forklift"] = "rbxassetid://72030930983101",
		["forward"] = "rbxassetid://97545944739523",
		["frame"] = "rbxassetid://109080612832751",
		["framer"] = "rbxassetid://108384807262391",
		["frown"] = "rbxassetid://124407301067982",
		["fuel"] = "rbxassetid://106447647274511",
		["fullscreen"] = "rbxassetid://77793665526178",
		["funnel-plus"] = "rbxassetid://100780233821928",
		["funnel-x"] = "rbxassetid://70984385812555",
		["funnel"] = "rbxassetid://108829540827529",
		["gallery-horizontal-end"] = "rbxassetid://74672430161161",
		["gallery-horizontal"] = "rbxassetid://80004001442122",
		["gallery-thumbnails"] = "rbxassetid://136219289862706",
		["gallery-vertical-end"] = "rbxassetid://106461402088317",
		["gallery-vertical"] = "rbxassetid://119299431466725",
		["gamepad-2"] = "rbxassetid://92483947987410",
		["gamepad-directional"] = "rbxassetid://84342305212226",
		["gamepad"] = "rbxassetid://121607283959010",
		["gauge"] = "rbxassetid://110273524101447",
		["gavel"] = "rbxassetid://78952298198456",
		["gem"] = "rbxassetid://112904952151156",
		["georgian-lari"] = "rbxassetid://98084432591687",
		["ghost"] = "rbxassetid://113822048130017",
		["gift"] = "rbxassetid://109855212076373",
		["git-branch-minus"] = "rbxassetid://97385010649411",
		["git-branch-plus"] = "rbxassetid://125944221134316",
		["git-branch"] = "rbxassetid://90490195516649",
		["git-commit-horizontal"] = "rbxassetid://133646041800147",
		["git-commit-vertical"] = "rbxassetid://122098032990350",
		["git-compare-arrows"] = "rbxassetid://84874426520216",
		["git-compare"] = "rbxassetid://91945124438792",
		["git-fork"] = "rbxassetid://89954992404765",
		["git-graph"] = "rbxassetid://86166832019304",
		["git-merge"] = "rbxassetid://131833355158059",
		["git-pull-request-arrow"] = "rbxassetid://94507974577439",
		["git-pull-request-closed"] = "rbxassetid://78070600389091",
		["git-pull-request-create-arrow"] = "rbxassetid://127422677061091",
		["git-pull-request-create"] = "rbxassetid://105929577383926",
		["git-pull-request-draft"] = "rbxassetid://76173459869943",
		["git-pull-request"] = "rbxassetid://138463010991471",
		["github"] = "rbxassetid://120349554354380",
		["gitlab"] = "rbxassetid://114054627192933",
		["glass-water"] = "rbxassetid://115526102400988",
		["glasses"] = "rbxassetid://87936407455373",
		["globe-lock"] = "rbxassetid://134065526704402",
		["globe"] = "rbxassetid://114238209622913",
		["goal"] = "rbxassetid://120517954878160",
		["gpu"] = "rbxassetid://95577823614219",
		["graduation-cap"] = "rbxassetid://93771896340220",
		["grape"] = "rbxassetid://134760640415561",
		["grid-2x2-check"] = "rbxassetid://138468840220821",
		["grid-2x2-plus"] = "rbxassetid://91811610580247",
		["grid-2x2-x"] = "rbxassetid://72407303981388",
		["grid-2x2"] = "rbxassetid://99050491897640",
		["grid-3x2"] = "rbxassetid://95528684210010",
		["grid-3x3"] = "rbxassetid://70419024781206",
		["grip-horizontal"] = "rbxassetid://136255899715930",
		["grip-vertical"] = "rbxassetid://137183678565296",
		["grip"] = "rbxassetid://109058783556768",
		["group"] = "rbxassetid://107643418926671",
		["guitar"] = "rbxassetid://75915531867926",
		["ham"] = "rbxassetid://74465607934635",
		["hamburger"] = "rbxassetid://93086916815495",
		["hammer"] = "rbxassetid://83545120140895",
		["hand-coins"] = "rbxassetid://126990543175462",
		["hand-fist"] = "rbxassetid://83341608917591",
		["hand-grab"] = "rbxassetid://88867162163985",
		["hand-heart"] = "rbxassetid://117507367668412",
		["hand-helping"] = "rbxassetid://89897738419446",
		["hand-metal"] = "rbxassetid://113619498548713",
		["hand-platter"] = "rbxassetid://88594727743168",
		["hand"] = "rbxassetid://130703864968637",
		["handbag"] = "rbxassetid://135675846264061",
		["handshake"] = "rbxassetid://78442115255814",
		["hard-drive-download"] = "rbxassetid://73913801230614",
		["hard-drive-upload"] = "rbxassetid://85762133615118",
		["hard-drive"] = "rbxassetid://88183305858463",
		["hard-hat"] = "rbxassetid://128050846767382",
		["hash"] = "rbxassetid://82890331678520",
		["hat-glasses"] = "rbxassetid://101165538224815",
		["haze"] = "rbxassetid://108857561768901",
		["hdmi-port"] = "rbxassetid://103693661037020",
		["heading-1"] = "rbxassetid://118129315662110",
		["heading-2"] = "rbxassetid://110209069670094",
		["heading-3"] = "rbxassetid://90267885237062",
		["heading-4"] = "rbxassetid://129625620307602",
		["heading-5"] = "rbxassetid://120386663181267",
		["heading-6"] = "rbxassetid://90959079775093",
		["heading"] = "rbxassetid://129254312067735",
		["headphone-off"] = "rbxassetid://85038251615641",
		["headphones"] = "rbxassetid://118833729589183",
		["headset"] = "rbxassetid://129269236787694",
		["heart-crack"] = "rbxassetid://110987638564119",
		["heart-handshake"] = "rbxassetid://111483078692002",
		["heart-minus"] = "rbxassetid://96827380163326",
		["heart-off"] = "rbxassetid://89748414415617",
		["heart-plus"] = "rbxassetid://94877796283249",
		["heart-pulse"] = "rbxassetid://129352925579546",
		["heart"] = "rbxassetid://116559368303288",
		["heater"] = "rbxassetid://140478466880916",
		["helicopter"] = "rbxassetid://111557171735930",
		["hexagon"] = "rbxassetid://127592089339199",
		["highlighter"] = "rbxassetid://77411555641113",
		["history"] = "rbxassetid://123980022019922",
		["hop-off"] = "rbxassetid://103386036934034",
		["hop"] = "rbxassetid://82778923997672",
		["hospital"] = "rbxassetid://105868763850707",
		["hotel"] = "rbxassetid://132283390859718",
		["hourglass"] = "rbxassetid://86160434939203",
		["house-heart"] = "rbxassetid://136054771868597",
		["house-plug"] = "rbxassetid://71438263712075",
		["house-plus"] = "rbxassetid://118495165208309",
		["house-wifi"] = "rbxassetid://126495519725698",
		["house"] = "rbxassetid://98755624629571",
		["ice-cream-bowl"] = "rbxassetid://124867218454386",
		["ice-cream-cone"] = "rbxassetid://90751397288639",
		["id-card-lanyard"] = "rbxassetid://90761480469224",
		["id-card"] = "rbxassetid://75354294622640",
		["image-down"] = "rbxassetid://78972295741235",
		["image-minus"] = "rbxassetid://101066016918565",
		["image-off"] = "rbxassetid://81934811700938",
		["image-play"] = "rbxassetid://129501806784210",
		["image-plus"] = "rbxassetid://70391970623917",
		["image-up"] = "rbxassetid://126610009605241",
		["image-upscale"] = "rbxassetid://106963545024679",
		["images"] = "rbxassetid://79350649395557",
		["import"] = "rbxassetid://116545008906029",
		["inbox"] = "rbxassetid://112591360302868",
		["indian-rupee"] = "rbxassetid://113038778381805",
		["infinity"] = "rbxassetid://98083086936965",
		["info"] = "rbxassetid://124560466474914",
		["inspection-panel"] = "rbxassetid://70905313146088",
		["instagram"] = "rbxassetid://119864798614855",
		["italic"] = "rbxassetid://96220378864282",
		["iteration-ccw"] = "rbxassetid://140221832794083",
		["iteration-cw"] = "rbxassetid://95534489554662",
		["japanese-yen"] = "rbxassetid://106362863465813",
		["joystick"] = "rbxassetid://99416790224739",
		["kanban"] = "rbxassetid://125934100055431",
		["kayak"] = "rbxassetid://136107544609389",
		["key-round"] = "rbxassetid://83619031955390",
		["key-square"] = "rbxassetid://94621420033649",
		["key"] = "rbxassetid://96510194465420",
		["keyboard-music"] = "rbxassetid://121058541758636",
		["keyboard-off"] = "rbxassetid://92466375369772",
		["keyboard"] = "rbxassetid://121474456068237",
		["lamp-ceiling"] = "rbxassetid://80032758469141",
		["lamp-desk"] = "rbxassetid://85290686983238",
		["lamp-floor"] = "rbxassetid://104585881375892",
		["lamp-wall-down"] = "rbxassetid://91271394132073",
		["lamp-wall-up"] = "rbxassetid://132141464337445",
		["lamp"] = "rbxassetid://110730830653382",
		["land-plot"] = "rbxassetid://96449039620294",
		["landmark"] = "rbxassetid://76885079756393",
		["languages"] = "rbxassetid://90816903776498",
		["laptop-minimal-check"] = "rbxassetid://114352019833865",
		["laptop-minimal"] = "rbxassetid://136705765566068",
		["laptop"] = "rbxassetid://111387063244975",
		["lasso-select"] = "rbxassetid://105609719912753",
		["lasso"] = "rbxassetid://121072936884007",
		["laugh"] = "rbxassetid://104491311361166",
		["layers-2"] = "rbxassetid://70536710516357",
		["layers"] = "rbxassetid://81973586053257",
		["layout-dashboard"] = "rbxassetid://139929981863901",
		["layout-grid"] = "rbxassetid://81344910161871",
		["layout-list"] = "rbxassetid://87462136296578",
		["layout-panel-left"] = "rbxassetid://125092469751491",
		["layout-panel-top"] = "rbxassetid://91943941515944",
		["layout-template"] = "rbxassetid://115564446417985",
		["leaf"] = "rbxassetid://119951075637174",
		["leafy-green"] = "rbxassetid://105146290493154",
		["lectern"] = "rbxassetid://106166425183862",
		["library-big"] = "rbxassetid://106794530191412",
		["library"] = "rbxassetid://114334671982047",
		["life-buoy"] = "rbxassetid://81168450671956",
		["ligature"] = "rbxassetid://111397873269411",
		["lightbulb-off"] = "rbxassetid://83795722296178",
		["lightbulb"] = "rbxassetid://103871245626488",
		["line-squiggle"] = "rbxassetid://109555164424447",
		["link-2-off"] = "rbxassetid://76885956296867",
		["link-2"] = "rbxassetid://86072351557466",
		["link"] = "rbxassetid://131607023382430",
		["linkedin"] = "rbxassetid://132842789255788",
		["list-check"] = "rbxassetid://72374358471156",
		["list-checks"] = "rbxassetid://99809353635593",
		["list-chevrons-down-up"] = "rbxassetid://137409641500711",
		["list-chevrons-up-down"] = "rbxassetid://81825351389084",
		["list-collapse"] = "rbxassetid://124505247702401",
		["list-end"] = "rbxassetid://77650610048119",
		["list-filter-plus"] = "rbxassetid://96385120752336",
		["list-filter"] = "rbxassetid://103321376129527",
		["list-indent-decrease"] = "rbxassetid://137879979228193",
		["list-indent-increase"] = "rbxassetid://79051053161201",
		["list-minus"] = "rbxassetid://138507965142671",
		["list-music"] = "rbxassetid://126380635781840",
		["list-ordered"] = "rbxassetid://83212528113913",
		["list-plus"] = "rbxassetid://112384738137814",
		["list-restart"] = "rbxassetid://91703153577421",
		["list-start"] = "rbxassetid://84828348299727",
		["list-todo"] = "rbxassetid://132980603752108",
		["list-tree"] = "rbxassetid://97685396239010",
		["list-video"] = "rbxassetid://93648525452489",
		["list-x"] = "rbxassetid://113025303988861",
		["list"] = "rbxassetid://113179976918783",
		["loader-circle"] = "rbxassetid://116535712789945",
		["loader-pinwheel"] = "rbxassetid://108513357940900",
		["loader"] = "rbxassetid://78408734580845",
		["locate-fixed"] = "rbxassetid://137367361548433",
		["locate-off"] = "rbxassetid://73729216338137",
		["locate"] = "rbxassetid://84467676590391",
		["lock-keyhole-open"] = "rbxassetid://110863509313073",
		["lock-keyhole"] = "rbxassetid://78672912777756",
		["lock-open"] = "rbxassetid://93597915325122",
		["lock"] = "rbxassetid://134724289526879",
		["log-in"] = "rbxassetid://103768533135201",
		["log-out"] = "rbxassetid://84895399304975",
		["logs"] = "rbxassetid://89772091251787",
		["lollipop"] = "rbxassetid://84681611583044",
		["luggage"] = "rbxassetid://76619236486400",
		["magnet"] = "rbxassetid://135162361226972",
		["mail-check"] = "rbxassetid://86921536259917",
		["mail-minus"] = "rbxassetid://81989813236553",
		["mail-open"] = "rbxassetid://122785416858638",
		["mail-plus"] = "rbxassetid://104886401588341",
		["mail-question-mark"] = "rbxassetid://126540170949819",
		["mail-search"] = "rbxassetid://135616173775287",
		["mail-warning"] = "rbxassetid://81495303676089",
		["mail-x"] = "rbxassetid://74607841705644",
		["mail"] = "rbxassetid://103945161245599",
		["mailbox"] = "rbxassetid://82765503320335",
		["mails"] = "rbxassetid://90673453450080",
		["map-minus"] = "rbxassetid://129525760577747",
		["map-pin-check-inside"] = "rbxassetid://107130529843809",
		["map-pin-check"] = "rbxassetid://118110914690154",
		["map-pin-house"] = "rbxassetid://80546885029816",
		["map-pin-minus-inside"] = "rbxassetid://79005529692964",
		["map-pin-minus"] = "rbxassetid://74518762643623",
		["map-pin-off"] = "rbxassetid://82474689391020",
		["map-pin-pen"] = "rbxassetid://113515395277504",
		["map-pin-plus-inside"] = "rbxassetid://134639656514430",
		["map-pin-plus"] = "rbxassetid://91875228967029",
		["map-pin-x-inside"] = "rbxassetid://126235934252379",
		["map-pin-x"] = "rbxassetid://101085273547316",
		["map-pin"] = "rbxassetid://84279202219901",
		["map-pinned"] = "rbxassetid://103963788475034",
		["map-plus"] = "rbxassetid://129388826743495",
		["map"] = "rbxassetid://95107167260947",
		["mars-stroke"] = "rbxassetid://131973193186828",
		["mars"] = "rbxassetid://111287112372511",
		["martini"] = "rbxassetid://82977695401058",
		["maximize-2"] = "rbxassetid://73085922906397",
		["maximize"] = "rbxassetid://76045941763188",
		["medal"] = "rbxassetid://79016002264450",
		["megaphone-off"] = "rbxassetid://124280774193935",
		["megaphone"] = "rbxassetid://118759541854879",
		["meh"] = "rbxassetid://132197867028557",
		["memory-stick"] = "rbxassetid://93212591343119",
		["menu"] = "rbxassetid://77021539815611",
		["merge"] = "rbxassetid://126201866476775",
		["message-circle-code"] = "rbxassetid://112865244991651",
		["message-circle-dashed"] = "rbxassetid://81525157881897",
		["message-circle-heart"] = "rbxassetid://101990756073677",
		["message-circle-more"] = "rbxassetid://92856823884663",
		["message-circle-off"] = "rbxassetid://134955643890328",
		["message-circle-plus"] = "rbxassetid://106562979649273",
		["message-circle-question-mark"] = "rbxassetid://107700302759934",
		["message-circle-reply"] = "rbxassetid://137071749508334",
		["message-circle-warning"] = "rbxassetid://119020096067894",
		["message-circle-x"] = "rbxassetid://126843387725536",
		["message-circle"] = "rbxassetid://127255077587058",
		["message-square-code"] = "rbxassetid://110968863152123",
		["message-square-dashed"] = "rbxassetid://107653455516238",
		["message-square-diff"] = "rbxassetid://75472190472625",
		["message-square-dot"] = "rbxassetid://127806382463916",
		["message-square-heart"] = "rbxassetid://75612811742074",
		["message-square-lock"] = "rbxassetid://81268215619563",
		["message-square-more"] = "rbxassetid://120139782405970",
		["message-square-off"] = "rbxassetid://99961019005789",
		["message-square-plus"] = "rbxassetid://76934450256199",
		["message-square-quote"] = "rbxassetid://116670768629340",
		["message-square-reply"] = "rbxassetid://130985622754637",
		["message-square-share"] = "rbxassetid://131017005324026",
		["message-square-text"] = "rbxassetid://94899503194205",
		["message-square-warning"] = "rbxassetid://138432903962261",
		["message-square-x"] = "rbxassetid://137285463279462",
		["message-square"] = "rbxassetid://83881670383280",
		["messages-square"] = "rbxassetid://97532166733358",
		["mic-off"] = "rbxassetid://82123034444822",
		["mic-vocal"] = "rbxassetid://99082286164362",
		["mic"] = "rbxassetid://89640799126523",
		["microchip"] = "rbxassetid://73937907669903",
		["microscope"] = "rbxassetid://116875530102782",
		["microwave"] = "rbxassetid://108411735353008",
		["milestone"] = "rbxassetid://101618292325920",
		["milk-off"] = "rbxassetid://72388480962742",
		["milk"] = "rbxassetid://96221903896918",
		["minimize-2"] = "rbxassetid://116269596042539",
		["minimize"] = "rbxassetid://121304296213645",
		["minus"] = "rbxassetid://118026365011536",
		["monitor-check"] = "rbxassetid://86651948439229",
		["monitor-cloud"] = "rbxassetid://85931096038318",
		["monitor-cog"] = "rbxassetid://94345128715799",
		["monitor-dot"] = "rbxassetid://130394010063680",
		["monitor-down"] = "rbxassetid://97466933743423",
		["monitor-off"] = "rbxassetid://74395526657953",
		["monitor-pause"] = "rbxassetid://76002184067562",
		["monitor-play"] = "rbxassetid://133018824306217",
		["monitor-smartphone"] = "rbxassetid://84335680433378",
		["monitor-speaker"] = "rbxassetid://81744810060380",
		["monitor-stop"] = "rbxassetid://98708958984757",
		["monitor-up"] = "rbxassetid://96035360858377",
		["monitor-x"] = "rbxassetid://126265210441423",
		["monitor"] = "rbxassetid://72664649203050",
		["moon-star"] = "rbxassetid://82782200506348",
		["moon"] = "rbxassetid://83380517901735",
		["motorbike"] = "rbxassetid://94580787368233",
		["mountain-snow"] = "rbxassetid://105315495740588",
		["mountain"] = "rbxassetid://73269957566415",
		["mouse-off"] = "rbxassetid://75267871697595",
		["mouse-pointer-2-off"] = "rbxassetid://104701076865632",
		["mouse-pointer-2"] = "rbxassetid://117093892862228",
		["mouse-pointer-ban"] = "rbxassetid://106849413057133",
		["mouse-pointer-click"] = "rbxassetid://107150227368485",
		["mouse-pointer"] = "rbxassetid://72322454962935",
		["mouse"] = "rbxassetid://73096068864710",
		["move-3d"] = "rbxassetid://103365982054003",
		["move-diagonal-2"] = "rbxassetid://117298577948096",
		["move-diagonal"] = "rbxassetid://101433481954184",
		["move-down-left"] = "rbxassetid://102819433534567",
		["move-down-right"] = "rbxassetid://101479760041877",
		["move-down"] = "rbxassetid://70510115135583",
		["move-horizontal"] = "rbxassetid://88513523439149",
		["move-left"] = "rbxassetid://137614740247980",
		["move-right"] = "rbxassetid://132455779472989",
		["move-up-left"] = "rbxassetid://139079815540148",
		["move-up-right"] = "rbxassetid://105885140592646",
		["move-up"] = "rbxassetid://84505444262658",
		["move-vertical"] = "rbxassetid://86234730730899",
		["move"] = "rbxassetid://116138709011735",
		["music-2"] = "rbxassetid://134397426600888",
		["music-3"] = "rbxassetid://94466120066498",
		["music-4"] = "rbxassetid://132459323665838",
		["music"] = "rbxassetid://113343203848535",
		["navigation-2-off"] = "rbxassetid://116569611780763",
		["navigation-2"] = "rbxassetid://81889066747907",
		["navigation-off"] = "rbxassetid://87003270290777",
		["navigation"] = "rbxassetid://79308213542922",
		["network"] = "rbxassetid://127410729922644",
		["newspaper"] = "rbxassetid://123479530460544",
		["nfc"] = "rbxassetid://76822396542242",
		["non-binary"] = "rbxassetid://78442360386235",
		["notebook-pen"] = "rbxassetid://140380614761023",
		["notebook-tabs"] = "rbxassetid://127371085570083",
		["notebook-text"] = "rbxassetid://93061585217270",
		["notebook"] = "rbxassetid://136132108664987",
		["notepad-text-dashed"] = "rbxassetid://135793446376219",
		["notepad-text"] = "rbxassetid://93404682958966",
		["nut-off"] = "rbxassetid://78795397311573",
		["nut"] = "rbxassetid://127146410705656",
		["octagon-alert"] = "rbxassetid://140438367956051",
		["octagon-minus"] = "rbxassetid://74720436795421",
		["octagon-pause"] = "rbxassetid://103161463909039",
		["octagon-x"] = "rbxassetid://90498161006311",
		["octagon"] = "rbxassetid://120803515514852",
		["omega"] = "rbxassetid://70414080018786",
		["option"] = "rbxassetid://100776883894054",
		["orbit"] = "rbxassetid://108926136860562",
		["origami"] = "rbxassetid://136020626667101",
		["package-2"] = "rbxassetid://70394974762575",
		["package-check"] = "rbxassetid://102374216055130",
		["package-minus"] = "rbxassetid://114492858789692",
		["package-open"] = "rbxassetid://132890233237818",
		["package-plus"] = "rbxassetid://129261988138366",
		["package-search"] = "rbxassetid://95465120894145",
		["package-x"] = "rbxassetid://70818501607442",
		["package"] = "rbxassetid://97261141732706",
		["paint-bucket"] = "rbxassetid://124275586663284",
		["paint-roller"] = "rbxassetid://115248074358348",
		["paintbrush-vertical"] = "rbxassetid://105151296591292",
		["paintbrush"] = "rbxassetid://125572663700289",
		["palette"] = "rbxassetid://86350350950064",
		["panda"] = "rbxassetid://132509022802512",
		["panel-bottom-close"] = "rbxassetid://74287004071159",
		["panel-bottom-dashed"] = "rbxassetid://131084651621603",
		["panel-bottom-open"] = "rbxassetid://107768659586540",
		["panel-bottom"] = "rbxassetid://132127145048511",
		["panel-left-close"] = "rbxassetid://126579818823552",
		["panel-left-dashed"] = "rbxassetid://75536606374585",
		["panel-left-open"] = "rbxassetid://111075816195767",
		["panel-left-right-dashed"] = "rbxassetid://110100707973959",
		["panel-left"] = "rbxassetid://97419752870313",
		["panel-right-close"] = "rbxassetid://139528655524132",
		["panel-right-dashed"] = "rbxassetid://94959793877311",
		["panel-right-open"] = "rbxassetid://118114419142794",
		["panel-right"] = "rbxassetid://116365035443156",
		["panel-top-bottom-dashed"] = "rbxassetid://134737235653344",
		["panel-top-close"] = "rbxassetid://83578325777808",
		["panel-top-dashed"] = "rbxassetid://70522913169237",
		["panel-top-open"] = "rbxassetid://137959875507454",
		["panel-top"] = "rbxassetid://75838479462875",
		["panels-left-bottom"] = "rbxassetid://72996856149149",
		["panels-right-bottom"] = "rbxassetid://90659068960726",
		["panels-top-left"] = "rbxassetid://79858853850600",
		["paperclip"] = "rbxassetid://92088291163453",
		["parentheses"] = "rbxassetid://78950955173096",
		["parking-meter"] = "rbxassetid://84652733960568",
		["party-popper"] = "rbxassetid://111626795712193",
		["pause"] = "rbxassetid://74873705394436",
		["paw-print"] = "rbxassetid://112218825427601",
		["pc-case"] = "rbxassetid://122978648019101",
		["pen-line"] = "rbxassetid://109108135755303",
		["pen-off"] = "rbxassetid://84807123119438",
		["pen-tool"] = "rbxassetid://106145404953445",
		["pen"] = "rbxassetid://72037878096321",
		["pencil-line"] = "rbxassetid://88392917053533",
		["pencil-off"] = "rbxassetid://103330927652832",
		["pencil-ruler"] = "rbxassetid://110120288284597",
		["pencil"] = "rbxassetid://137986121120732",
		["pentagon"] = "rbxassetid://79184802179890",
		["percent"] = "rbxassetid://130155041032013",
		["person-standing"] = "rbxassetid://125020872044147",
		["philippine-peso"] = "rbxassetid://91173798254675",
		["phone-call"] = "rbxassetid://70555587592860",
		["phone-forwarded"] = "rbxassetid://113269614319737",
		["phone-incoming"] = "rbxassetid://82863576359288",
		["phone-missed"] = "rbxassetid://130156165198376",
		["phone-off"] = "rbxassetid://133318623553383",
		["phone-outgoing"] = "rbxassetid://104576478735825",
		["phone"] = "rbxassetid://128804946640049",
		["pi"] = "rbxassetid://74936036243146",
		["piano"] = "rbxassetid://85008880789520",
		["pickaxe"] = "rbxassetid://105888023317688",
		["picture-in-picture-2"] = "rbxassetid://112803319544468",
		["picture-in-picture"] = "rbxassetid://80579597835123",
		["piggy-bank"] = "rbxassetid://79498575790721",
		["pilcrow-left"] = "rbxassetid://103803000849583",
		["pilcrow-right"] = "rbxassetid://104881733911870",
		["pilcrow"] = "rbxassetid://139512780392871",
		["pill-bottle"] = "rbxassetid://118394692404597",
		["pill"] = "rbxassetid://73280534813448",
		["pin-off"] = "rbxassetid://127696372451750",
		["pin"] = "rbxassetid://120978111007514",
		["pipette"] = "rbxassetid://133167932934404",
		["pizza"] = "rbxassetid://126964453193501",
		["plane-landing"] = "rbxassetid://122555692211889",
		["plane-takeoff"] = "rbxassetid://117179478829575",
		["plane"] = "rbxassetid://126985561580989",
		["play"] = "rbxassetid://135609604299893",
		["plug-2"] = "rbxassetid://97912386476366",
		["plug-zap"] = "rbxassetid://74506269884055",
		["plug"] = "rbxassetid://99782373064495",
		["plus"] = "rbxassetid://111774323017047",
		["pocket-knife"] = "rbxassetid://134075428063965",
		["pocket"] = "rbxassetid://136686762542964",
		["podcast"] = "rbxassetid://109577075549215",
		["pointer-off"] = "rbxassetid://95488389312794",
		["pointer"] = "rbxassetid://92615117311099",
		["popcorn"] = "rbxassetid://139446511232750",
		["popsicle"] = "rbxassetid://112696318077073",
		["pound-sterling"] = "rbxassetid://127482649469130",
		["power-off"] = "rbxassetid://118768311012214",
		["power"] = "rbxassetid://96479131758775",
		["presentation"] = "rbxassetid://106134583757890",
		["printer-check"] = "rbxassetid://130273549443689",
		["printer"] = "rbxassetid://76080649734247",
		["projector"] = "rbxassetid://103281856385283",
		["proportions"] = "rbxassetid://130046855997237",
		["puzzle"] = "rbxassetid://136837798892463",
		["pyramid"] = "rbxassetid://107811442374127",
		["qr-code"] = "rbxassetid://105329945723350",
		["quote"] = "rbxassetid://103271711590001",
		["rabbit"] = "rbxassetid://98580518804206",
		["radar"] = "rbxassetid://138528222906635",
		["radiation"] = "rbxassetid://104499586848433",
		["radical"] = "rbxassetid://132758286926047",
		["radio-receiver"] = "rbxassetid://129598303378835",
		["radio-tower"] = "rbxassetid://93958663130054",
		["radio"] = "rbxassetid://85611589536956",
		["radius"] = "rbxassetid://89814505307129",
		["rail-symbol"] = "rbxassetid://134295386306962",
		["rainbow"] = "rbxassetid://132488862841895",
		["rat"] = "rbxassetid://127400975953159",
		["ratio"] = "rbxassetid://126369423897295",
		["receipt-cent"] = "rbxassetid://91557573925201",
		["receipt-euro"] = "rbxassetid://94015722210295",
		["receipt-indian-rupee"] = "rbxassetid://89718170439990",
		["receipt-japanese-yen"] = "rbxassetid://132472560758851",
		["receipt-pound-sterling"] = "rbxassetid://73934967569625",
		["receipt-russian-ruble"] = "rbxassetid://105164576936853",
		["receipt-swiss-franc"] = "rbxassetid://72503668620116",
		["receipt-text"] = "rbxassetid://138483536013737",
		["receipt-turkish-lira"] = "rbxassetid://91950765836342",
		["receipt"] = "rbxassetid://77877895901792",
		["rectangle-circle"] = "rbxassetid://100642423153903",
		["rectangle-ellipsis"] = "rbxassetid://112919953980965",
		["rectangle-goggles"] = "rbxassetid://98605436666727",
		["rectangle-horizontal"] = "rbxassetid://90224199814966",
		["rectangle-vertical"] = "rbxassetid://117277050590967",
		["recycle"] = "rbxassetid://140417023381961",
		["redo-2"] = "rbxassetid://70451039017914",
		["redo-dot"] = "rbxassetid://94252981719732",
		["redo"] = "rbxassetid://116150342119054",
		["refresh-ccw-dot"] = "rbxassetid://106702246753270",
		["refresh-ccw"] = "rbxassetid://117913330389477",
		["refresh-cw-off"] = "rbxassetid://140179498843054",
		["refresh-cw"] = "rbxassetid://138133190015277",
		["refrigerator"] = "rbxassetid://102614042652753",
		["regex"] = "rbxassetid://100727200791841",
		["remove-formatting"] = "rbxassetid://112833162022628",
		["repeat-1"] = "rbxassetid://130144534857095",
		["repeat-2"] = "rbxassetid://85927537182704",
		["repeat"] = "rbxassetid://121886242955173",
		["replace-all"] = "rbxassetid://127862728198635",
		["replace"] = "rbxassetid://128404082279430",
		["reply-all"] = "rbxassetid://71723137343562",
		["reply"] = "rbxassetid://109788633497028",
		["rewind"] = "rbxassetid://95205297521988",
		["ribbon"] = "rbxassetid://94265331526851",
		["rocket"] = "rbxassetid://87412317685854",
		["rocking-chair"] = "rbxassetid://110420269495360",
		["roller-coaster"] = "rbxassetid://112426178972099",
		["rose"] = "rbxassetid://126336840238769",
		["rotate-3d"] = "rbxassetid://76300551576392",
		["rotate-ccw-key"] = "rbxassetid://74976035240976",
		["rotate-ccw-square"] = "rbxassetid://90515853170424",
		["rotate-ccw"] = "rbxassetid://110116685948665",
		["rotate-cw-square"] = "rbxassetid://77095448159303",
		["rotate-cw"] = "rbxassetid://84183336178654",
		["route-off"] = "rbxassetid://106350402024079",
		["route"] = "rbxassetid://89968303228953",
		["router"] = "rbxassetid://102130331994471",
		["rows-2"] = "rbxassetid://112556185960101",
		["rows-3"] = "rbxassetid://117215586961375",
		["rows-4"] = "rbxassetid://125646021959055",
		["rss"] = "rbxassetid://131789058984793",
		["ruler-dimension-line"] = "rbxassetid://70673861371412",
		["ruler"] = "rbxassetid://81432445547423",
		["russian-ruble"] = "rbxassetid://126357936542156",
		["sailboat"] = "rbxassetid://87110567187540",
		["salad"] = "rbxassetid://128864507821603",
		["sandwich"] = "rbxassetid://104573187458917",
		["satellite-dish"] = "rbxassetid://136742443888305",
		["satellite"] = "rbxassetid://134967053164645",
		["saudi-riyal"] = "rbxassetid://102282769104635",
		["save-all"] = "rbxassetid://116946975799440",
		["save-off"] = "rbxassetid://87085435778560",
		["save"] = "rbxassetid://126116963775616",
		["scale-3d"] = "rbxassetid://72414199620352",
		["scale"] = "rbxassetid://108203682317477",
		["scaling"] = "rbxassetid://122360365318466",
		["scan-barcode"] = "rbxassetid://96889457154761",
		["scan-eye"] = "rbxassetid://99244790601968",
		["scan-face"] = "rbxassetid://109959345069668",
		["scan-heart"] = "rbxassetid://106280819776142",
		["scan-line"] = "rbxassetid://126544908146540",
		["scan-qr-code"] = "rbxassetid://105409149549927",
		["scan-search"] = "rbxassetid://80009010551347",
		["scan-text"] = "rbxassetid://73702396787766",
		["scan"] = "rbxassetid://123104789658180",
		["school"] = "rbxassetid://76351530290068",
		["scissors-line-dashed"] = "rbxassetid://122237447974173",
		["scissors"] = "rbxassetid://118665510911274",
		["screen-share-off"] = "rbxassetid://107677572669805",
		["screen-share"] = "rbxassetid://85137895705653",
		["scroll-text"] = "rbxassetid://97321022666868",
		["scroll"] = "rbxassetid://74072101474951",
		["search-check"] = "rbxassetid://75442076191356",
		["search-code"] = "rbxassetid://117114794592802",
		["search-slash"] = "rbxassetid://96483932261041",
		["search-x"] = "rbxassetid://137319957522951",
		["search"] = "rbxassetid://121018724060431",
		["section"] = "rbxassetid://91732188298948",
		["send-horizontal"] = "rbxassetid://111734392411664",
		["send-to-back"] = "rbxassetid://75340312862253",
		["send"] = "rbxassetid://127751956873796",
		["separator-horizontal"] = "rbxassetid://84864453699927",
		["separator-vertical"] = "rbxassetid://84031801478581",
		["server-cog"] = "rbxassetid://138470287250966",
		["server-crash"] = "rbxassetid://132810618000212",
		["server-off"] = "rbxassetid://114048751507723",
		["server"] = "rbxassetid://92188766517878",
		["settings-2"] = "rbxassetid://135684703553372",
		["settings"] = "rbxassetid://80758916183665",
		["shapes"] = "rbxassetid://129989433311409",
		["share-2"] = "rbxassetid://71210767962065",
		["share"] = "rbxassetid://87340985053299",
		["sheet"] = "rbxassetid://134902122480171",
		["shell"] = "rbxassetid://140212943563599",
		["shield-alert"] = "rbxassetid://114995877719925",
		["shield-ban"] = "rbxassetid://108765041044649",
		["shield-check"] = "rbxassetid://87354736164608",
		["shield-ellipsis"] = "rbxassetid://114794739892123",
		["shield-half"] = "rbxassetid://117842634172647",
		["shield-minus"] = "rbxassetid://89965059528921",
		["shield-off"] = "rbxassetid://133426959132690",
		["shield-plus"] = "rbxassetid://100664857995498",
		["shield-question-mark"] = "rbxassetid://135722075265150",
		["shield-user"] = "rbxassetid://124832775645347",
		["shield-x"] = "rbxassetid://73370117343811",
		["shield"] = "rbxassetid://110987169760162",
		["ship-wheel"] = "rbxassetid://130797795829448",
		["ship"] = "rbxassetid://83995100553930",
		["shirt"] = "rbxassetid://106579555405966",
		["shopping-bag"] = "rbxassetid://71885477293226",
		["shopping-basket"] = "rbxassetid://138646411956433",
		["shopping-cart"] = "rbxassetid://128420521375441",
		["shovel"] = "rbxassetid://102465000512056",
		["shower-head"] = "rbxassetid://75884944024117",
		["shredder"] = "rbxassetid://122125164414463",
		["shrimp"] = "rbxassetid://102625900815307",
		["shrink"] = "rbxassetid://90953687918880",
		["shrub"] = "rbxassetid://127326280714343",
		["shuffle"] = "rbxassetid://132382786975101",
		["sigma"] = "rbxassetid://126884244870899",
		["signal-high"] = "rbxassetid://130436670012270",
		["signal-low"] = "rbxassetid://73674683500458",
		["signal-medium"] = "rbxassetid://125003021367019",
		["signal-zero"] = "rbxassetid://130045332414754",
		["signal"] = "rbxassetid://78424889355261",
		["signature"] = "rbxassetid://114402748013000",
		["signpost-big"] = "rbxassetid://115780185675001",
		["signpost"] = "rbxassetid://106584743791433",
		["siren"] = "rbxassetid://134210267818039",
		["skip-back"] = "rbxassetid://70466132711334",
		["skip-forward"] = "rbxassetid://124844823753990",
		["skull"] = "rbxassetid://137726256442333",
		["slack"] = "rbxassetid://96089719516736",
		["slash"] = "rbxassetid://117792185664263",
		["slice"] = "rbxassetid://95810504278179",
		["sliders-horizontal"] = "rbxassetid://85538382643347",
		["sliders-vertical"] = "rbxassetid://101190569086853",
		["smartphone-charging"] = "rbxassetid://102837532613995",
		["smartphone-nfc"] = "rbxassetid://82326425754446",
		["smartphone"] = "rbxassetid://96623008834511",
		["smile-plus"] = "rbxassetid://131981881472144",
		["smile"] = "rbxassetid://105880397565283",
		["snail"] = "rbxassetid://70904536548363",
		["snowflake"] = "rbxassetid://101235206534566",
		["soap-dispenser-droplet"] = "rbxassetid://77258480479465",
		["sofa"] = "rbxassetid://114427687218324",
		["solar-panel"] = "rbxassetid://132448188047921",
		["soup"] = "rbxassetid://115092551871618",
		["space"] = "rbxassetid://87072088914178",
		["spade"] = "rbxassetid://131444449466462",
		["sparkle"] = "rbxassetid://111044800239623",
		["sparkles"] = "rbxassetid://138635884129147",
		["speaker"] = "rbxassetid://96227183003618",
		["speech"] = "rbxassetid://87013139446349",
		["spell-check-2"] = "rbxassetid://81556731785534",
		["spell-check"] = "rbxassetid://91913483031334",
		["spline-pointer"] = "rbxassetid://84842840956804",
		["spline"] = "rbxassetid://129406685807412",
		["split"] = "rbxassetid://105112438805988",
		["spool"] = "rbxassetid://124541981347743",
		["spotlight"] = "rbxassetid://77571742539344",
		["spray-can"] = "rbxassetid://128372039366326",
		["sprout"] = "rbxassetid://100091687832508",
		["square-activity"] = "rbxassetid://89496630185293",
		["square-arrow-down-left"] = "rbxassetid://108194680296901",
		["square-arrow-down-right"] = "rbxassetid://99403846801050",
		["square-arrow-down"] = "rbxassetid://135962519626588",
		["square-arrow-left"] = "rbxassetid://111671474549238",
		["square-arrow-out-down-left"] = "rbxassetid://125714881756353",
		["square-arrow-out-down-right"] = "rbxassetid://89971003001390",
		["square-arrow-out-up-left"] = "rbxassetid://103759986579087",
		["square-arrow-out-up-right"] = "rbxassetid://91221896066807",
		["square-arrow-right"] = "rbxassetid://113920471701361",
		["square-arrow-up-left"] = "rbxassetid://112424670290693",
		["square-arrow-up-right"] = "rbxassetid://76602291406940",
		["square-arrow-up"] = "rbxassetid://106998604646718",
		["square-asterisk"] = "rbxassetid://89186832353625",
		["square-bottom-dashed-scissors"] = "rbxassetid://79076980104803",
		["square-chart-gantt"] = "rbxassetid://104034017316411",
		["square-check-big"] = "rbxassetid://115320390907184",
		["square-check"] = "rbxassetid://134682053539509",
		["square-chevron-down"] = "rbxassetid://91032307924592",
		["square-chevron-left"] = "rbxassetid://73143404829510",
		["square-chevron-right"] = "rbxassetid://90612077729930",
		["square-chevron-up"] = "rbxassetid://85565910197337",
		["square-code"] = "rbxassetid://81604576616881",
		["square-dashed-bottom-code"] = "rbxassetid://100354801563230",
		["square-dashed-bottom"] = "rbxassetid://101102319625624",
		["square-dashed-kanban"] = "rbxassetid://90388067649847",
		["square-dashed-mouse-pointer"] = "rbxassetid://121016142178467",
		["square-dashed-top-solid"] = "rbxassetid://117157577548540",
		["square-dashed"] = "rbxassetid://136905537847606",
		["square-divide"] = "rbxassetid://99894657101970",
		["square-dot"] = "rbxassetid://116613421354866",
		["square-equal"] = "rbxassetid://110283363706707",
		["square-function"] = "rbxassetid://86075219551088",
		["square-kanban"] = "rbxassetid://114537101260131",
		["square-library"] = "rbxassetid://73810931222081",
		["square-m"] = "rbxassetid://117662700410577",
		["square-menu"] = "rbxassetid://104067089444415",
		["square-minus"] = "rbxassetid://116764432015770",
		["square-mouse-pointer"] = "rbxassetid://76141850603920",
		["square-parking-off"] = "rbxassetid://100857293535141",
		["square-parking"] = "rbxassetid://133116656122387",
		["square-pause"] = "rbxassetid://86608552787615",
		["square-pen"] = "rbxassetid://120239476110475",
		["square-percent"] = "rbxassetid://87111930314567",
		["square-pi"] = "rbxassetid://75383328781618",
		["square-pilcrow"] = "rbxassetid://131854284699367",
		["square-play"] = "rbxassetid://108186325238481",
		["square-plus"] = "rbxassetid://114713264461873",
		["square-power"] = "rbxassetid://129240437805187",
		["square-radical"] = "rbxassetid://132645931868292",
		["square-round-corner"] = "rbxassetid://104592745113567",
		["square-scissors"] = "rbxassetid://110601255612411",
		["square-sigma"] = "rbxassetid://113231244246816",
		["square-slash"] = "rbxassetid://105477013908757",
		["square-split-horizontal"] = "rbxassetid://76095370148660",
		["square-split-vertical"] = "rbxassetid://88589192032058",
		["square-square"] = "rbxassetid://136555087357875",
		["square-stack"] = "rbxassetid://100463396619394",
		["square-star"] = "rbxassetid://94506958703720",
		["square-stop"] = "rbxassetid://80018708472943",
		["square-terminal"] = "rbxassetid://83969264476798",
		["square-user-round"] = "rbxassetid://86484997229302",
		["square-user"] = "rbxassetid://70771214183445",
		["square-x"] = "rbxassetid://125136183850190",
		["square"] = "rbxassetid://86304921356806",
		["squares-exclude"] = "rbxassetid://102345385822324",
		["squares-intersect"] = "rbxassetid://120869602570119",
		["squares-subtract"] = "rbxassetid://131484650948795",
		["squares-unite"] = "rbxassetid://96673080107843",
		["squircle-dashed"] = "rbxassetid://129936702532522",
		["squircle"] = "rbxassetid://82426632573807",
		["squirrel"] = "rbxassetid://112864252085343",
		["stamp"] = "rbxassetid://92370779813368",
		["star-half"] = "rbxassetid://117449275562979",
		["star-off"] = "rbxassetid://75742832732503",
		["star"] = "rbxassetid://136141469398409",
		["step-back"] = "rbxassetid://108672750005121",
		["step-forward"] = "rbxassetid://126131872136145",
		["stethoscope"] = "rbxassetid://122331031702148",
		["sticker"] = "rbxassetid://79938203791608",
		["sticky-note"] = "rbxassetid://111894074643919",
		["store"] = "rbxassetid://90338129673705",
		["stretch-horizontal"] = "rbxassetid://87665042192343",
		["stretch-vertical"] = "rbxassetid://95265463417122",
		["strikethrough"] = "rbxassetid://103417324549613",
		["subscript"] = "rbxassetid://74553514785183",
		["sun-dim"] = "rbxassetid://129141645592715",
		["sun-medium"] = "rbxassetid://130278807964710",
		["sun-moon"] = "rbxassetid://75752898854559",
		["sun-snow"] = "rbxassetid://112791898014579",
		["sun"] = "rbxassetid://110150589884127",
		["sunrise"] = "rbxassetid://134705665494098",
		["sunset"] = "rbxassetid://75904872203588",
		["superscript"] = "rbxassetid://96887696590118",
		["swatch-book"] = "rbxassetid://126786244872453",
		["swiss-franc"] = "rbxassetid://113497920041625",
		["switch-camera"] = "rbxassetid://76841154349737",
		["sword"] = "rbxassetid://124448418211665",
		["swords"] = "rbxassetid://81872698913435",
		["syringe"] = "rbxassetid://123891270479254",
		["table-2"] = "rbxassetid://95751552281545",
		["table-cells-merge"] = "rbxassetid://95363715175258",
		["table-cells-split"] = "rbxassetid://114799086088649",
		["table-columns-split"] = "rbxassetid://111011625447949",
		["table-of-contents"] = "rbxassetid://135044763275414",
		["table-properties"] = "rbxassetid://125062886015372",
		["table-rows-split"] = "rbxassetid://96443733673997",
		["table"] = "rbxassetid://109109148250737",
		["tablet-smartphone"] = "rbxassetid://133680859813404",
		["tablet"] = "rbxassetid://128403991264386",
		["tablets"] = "rbxassetid://80835787970735",
		["tag"] = "rbxassetid://129104970103940",
		["tags"] = "rbxassetid://107179263080798",
		["tally-1"] = "rbxassetid://115301298241643",
		["tally-2"] = "rbxassetid://110363186864027",
		["tally-3"] = "rbxassetid://97655344572540",
		["tally-4"] = "rbxassetid://102633494371890",
		["tally-5"] = "rbxassetid://88031817475886",
		["tangent"] = "rbxassetid://123263132981724",
		["target"] = "rbxassetid://87563802520297",
		["telescope"] = "rbxassetid://91755049143647",
		["tent-tree"] = "rbxassetid://76698322463977",
		["tent"] = "rbxassetid://109779587826330",
		["terminal"] = "rbxassetid://106783148545356",
		["test-tube-diagonal"] = "rbxassetid://75662704378840",
		["test-tube"] = "rbxassetid://98801015650164",
		["test-tubes"] = "rbxassetid://92555361447433",
		["text-align-center"] = "rbxassetid://84051028246390",
		["text-align-end"] = "rbxassetid://130041738343555",
		["text-align-justify"] = "rbxassetid://80279880143030",
		["text-align-start"] = "rbxassetid://134489585487649",
		["text-cursor-input"] = "rbxassetid://107551944047171",
		["text-cursor"] = "rbxassetid://115984654447300",
		["text-initial"] = "rbxassetid://129458097472087",
		["text-quote"] = "rbxassetid://139278366448736",
		["text-search"] = "rbxassetid://92345384671606",
		["text-select"] = "rbxassetid://117087320884956",
		["text-wrap"] = "rbxassetid://114804318314018",
		["theater"] = "rbxassetid://108558145549163",
		["thermometer-snowflake"] = "rbxassetid://121876188028425",
		["thermometer-sun"] = "rbxassetid://106693240074310",
		["thermometer"] = "rbxassetid://106546011492311",
		["thumbs-down"] = "rbxassetid://87794009914015",
		["thumbs-up"] = "rbxassetid://111137070767020",
		["ticket-check"] = "rbxassetid://105428777212507",
		["ticket-minus"] = "rbxassetid://78966299769328",
		["ticket-percent"] = "rbxassetid://80834774406405",
		["ticket-plus"] = "rbxassetid://110086734392189",
		["ticket-slash"] = "rbxassetid://89045681172265",
		["ticket-x"] = "rbxassetid://88674114109926",
		["ticket"] = "rbxassetid://126527071492145",
		["tickets-plane"] = "rbxassetid://100367018248695",
		["tickets"] = "rbxassetid://135268612687833",
		["timer-off"] = "rbxassetid://110916370767271",
		["timer-reset"] = "rbxassetid://110052125369932",
		["timer"] = "rbxassetid://85473888890506",
		["toggle-left"] = "rbxassetid://85887872573050",
		["toggle-right"] = "rbxassetid://90411952142550",
		["toilet"] = "rbxassetid://80930782432931",
		["tool-case"] = "rbxassetid://87533537832522",
		["tornado"] = "rbxassetid://88358291515768",
		["torus"] = "rbxassetid://70855707283051",
		["touchpad-off"] = "rbxassetid://78784008075456",
		["touchpad"] = "rbxassetid://74882354908014",
		["tower-control"] = "rbxassetid://95937619060532",
		["toy-brick"] = "rbxassetid://86293483924633",
		["tractor"] = "rbxassetid://103376704722051",
		["traffic-cone"] = "rbxassetid://74110220470369",
		["train-front-tunnel"] = "rbxassetid://105194827005114",
		["train-front"] = "rbxassetid://125237934215370",
		["train-track"] = "rbxassetid://77451032453723",
		["tram-front"] = "rbxassetid://93315182364998",
		["transgender"] = "rbxassetid://135530817673639",
		["trash-2"] = "rbxassetid://109843431391323",
		["trash"] = "rbxassetid://106723740584310",
		["tree-deciduous"] = "rbxassetid://123124389219004",
		["tree-palm"] = "rbxassetid://103846705893963",
		["tree-pine"] = "rbxassetid://124662547202594",
		["trees"] = "rbxassetid://121203841375919",
		["trello"] = "rbxassetid://130987241149527",
		["trending-down"] = "rbxassetid://139309232226438",
		["trending-up-down"] = "rbxassetid://85083293981691",
		["trending-up"] = "rbxassetid://81819858538839",
		["triangle-alert"] = "rbxassetid://125920361880643",
		["triangle-dashed"] = "rbxassetid://124324079103935",
		["triangle-right"] = "rbxassetid://116930791412791",
		["triangle"] = "rbxassetid://126330486745540",
		["trophy"] = "rbxassetid://131545003268773",
		["truck-electric"] = "rbxassetid://111873446387359",
		["truck"] = "rbxassetid://86662707764771",
		["turkish-lira"] = "rbxassetid://114589876174070",
		["turntable"] = "rbxassetid://129870346487856",
		["turtle"] = "rbxassetid://118295081560334",
		["tv-minimal-play"] = "rbxassetid://99201833426972",
		["tv-minimal"] = "rbxassetid://100382201729427",
		["tv"] = "rbxassetid://135687724791776",
		["twitch"] = "rbxassetid://71383308134888",
		["twitter"] = "rbxassetid://88791703276842",
		["type-outline"] = "rbxassetid://80108627791690",
		["type"] = "rbxassetid://133543553793564",
		["umbrella-off"] = "rbxassetid://72395143739955",
		["umbrella"] = "rbxassetid://127502210274589",
		["underline"] = "rbxassetid://123709229216544",
		["undo-2"] = "rbxassetid://113885292059932",
		["undo-dot"] = "rbxassetid://132055277744844",
		["undo"] = "rbxassetid://111258459077271",
		["unfold-horizontal"] = "rbxassetid://117128358526398",
		["unfold-vertical"] = "rbxassetid://116593025265499",
		["ungroup"] = "rbxassetid://106674800451003",
		["university"] = "rbxassetid://84652528263642",
		["unlink-2"] = "rbxassetid://128131898892572",
		["unlink"] = "rbxassetid://139835795227752",
		["unplug"] = "rbxassetid://90171381619874",
		["upload"] = "rbxassetid://138212042425501",
		["usb"] = "rbxassetid://117230058949613",
		["user-check"] = "rbxassetid://81775205032725",
		["user-cog"] = "rbxassetid://92795491530865",
		["user-lock"] = "rbxassetid://78892639693821",
		["user-minus"] = "rbxassetid://126976941957511",
		["user-pen"] = "rbxassetid://87445472574836",
		["user-plus"] = "rbxassetid://118514469915884",
		["user-round-check"] = "rbxassetid://118794737621941",
		["user-round-cog"] = "rbxassetid://78239503290053",
		["user-round-minus"] = "rbxassetid://98944176636447",
		["user-round-pen"] = "rbxassetid://108155244324878",
		["user-round-plus"] = "rbxassetid://113301899567470",
		["user-round-search"] = "rbxassetid://71565774381870",
		["user-round-x"] = "rbxassetid://122367980560930",
		["user-round"] = "rbxassetid://136485052187963",
		["user-search"] = "rbxassetid://101335649828115",
		["user-star"] = "rbxassetid://98777846316000",
		["user-x"] = "rbxassetid://139748155894754",
		["user"] = "rbxassetid://81589895647169",
		["users-round"] = "rbxassetid://103005444008339",
		["users"] = "rbxassetid://115398113982385",
		["utensils-crossed"] = "rbxassetid://109520762270383",
		["utensils"] = "rbxassetid://139952569804235",
		["utility-pole"] = "rbxassetid://101965541238242",
		["variable"] = "rbxassetid://104743088438151",
		["vault"] = "rbxassetid://108049164599845",
		["vector-square"] = "rbxassetid://86713728565344",
		["vegan"] = "rbxassetid://119489190688082",
		["venetian-mask"] = "rbxassetid://102636443033920",
		["venus-and-mars"] = "rbxassetid://120227752103771",
		["venus"] = "rbxassetid://82891342220859",
		["vibrate-off"] = "rbxassetid://113446447326246",
		["vibrate"] = "rbxassetid://108330910738733",
		["video-off"] = "rbxassetid://132239189859305",
		["video"] = "rbxassetid://107587444636945",
		["videotape"] = "rbxassetid://114816894323398",
		["view"] = "rbxassetid://118717253976805",
		["voicemail"] = "rbxassetid://134313454010227",
		["volleyball"] = "rbxassetid://83889351124153",
		["volume-1"] = "rbxassetid://98514588731639",
		["volume-2"] = "rbxassetid://89344380902620",
		["volume-off"] = "rbxassetid://103047478058767",
		["volume-x"] = "rbxassetid://139252359189540",
		["volume"] = "rbxassetid://103236289817396",
		["vote"] = "rbxassetid://89409762851246",
		["wallet-cards"] = "rbxassetid://129728715308337",
		["wallet-minimal"] = "rbxassetid://137800448816116",
		["wallet"] = "rbxassetid://132331555762628",
		["wallpaper"] = "rbxassetid://74682121235494",
		["wand-sparkles"] = "rbxassetid://82546429942392",
		["wand"] = "rbxassetid://114580617777835",
		["warehouse"] = "rbxassetid://78388887451080",
		["washing-machine"] = "rbxassetid://104194127573858",
		["watch"] = "rbxassetid://130544621618405",
		["waves-ladder"] = "rbxassetid://101808619355514",
		["waves"] = "rbxassetid://96340135183647",
		["waypoints"] = "rbxassetid://102450133666017",
		["webcam"] = "rbxassetid://104148487911129",
		["webhook-off"] = "rbxassetid://96370548093471",
		["webhook"] = "rbxassetid://112812457747322",
		["weight"] = "rbxassetid://103860559844854",
		["wheat-off"] = "rbxassetid://133294844612307",
		["wheat"] = "rbxassetid://85261952080359",
		["whole-word"] = "rbxassetid://90111083954485",
		["wifi-cog"] = "rbxassetid://110500263326209",
		["wifi-high"] = "rbxassetid://81954601342139",
		["wifi-low"] = "rbxassetid://138217335635913",
		["wifi-off"] = "rbxassetid://74113634330106",
		["wifi-pen"] = "rbxassetid://91290205064712",
		["wifi-sync"] = "rbxassetid://84043971055177",
		["wifi-zero"] = "rbxassetid://124286465246123",
		["wifi"] = "rbxassetid://104669375183960",
		["wind-arrow-down"] = "rbxassetid://127753987414870",
		["wind"] = "rbxassetid://114551690399915",
		["wine-off"] = "rbxassetid://108294164302317",
		["wine"] = "rbxassetid://115743721332829",
		["workflow"] = "rbxassetid://99186544029189",
		["worm"] = "rbxassetid://115752311548091",
		["wrench"] = "rbxassetid://112148279212860",
		["x"] = "rbxassetid://110786993356448",
		["youtube"] = "rbxassetid://123663668456341",
		["zap-off"] = "rbxassetid://81385483183652",
		["zap"] = "rbxassetid://130551565616516",
		["zoom-in"] = "rbxassetid://127956924984803",
		["zoom-out"] = "rbxassetid://108334162607319"
	},
	Aliases = {
		x = "delete",
		close = "delete",
		settings = "cog",
		home = "house",
		user = "circle-user-round",
		player = "circle-user-round",
		players = "circle-user-round",
		sparkles = "gem",
		logo = "gem",
		zap = "bolt",
		plus = "circle-plus",
		minus = "circle-minus",
		star = "circle-star",
		maximize = "maximize",
	}
}

Icons.Fallback = Icons.Icons.circle

function Icons.Get(name)
	if typeof(name) ~= "string" or #name == 0 then
		return Icons.Fallback
	end

	if string.find(name, "rbxassetid://", 1, true) or string.find(name, "rbxasset://", 1, true) then
		return name
	end

	if name:match("^%d+$") then
		return "rbxassetid://" .. name
	end

	local key = Icons.Aliases[name] or name
	return Icons.Icons[key] or Icons.Fallback
end

function Icons.Exists(name)
	if typeof(name) ~= "string" then return false end
	if string.find(name, "rbxassetid://", 1, true) or string.find(name, "rbxasset://", 1, true) or name:match("^%d+$") then
		return true
	end
	return Icons.Icons[name] ~= nil or Icons.Aliases[name] ~= nil
end

local Themes = {
	--[[Default = {
		Primary = Color3.fromRGB(11, 12, 15),
		Secondary = {
			[1] = Color3.fromRGB(16, 18, 23),
			[2] = Color3.fromRGB(24, 27, 36),
		},
		Accent = Color3.fromRGB(56, 125, 255),
		Slider = Color3.fromRGB(56, 125, 255),
		Text = Color3.fromRGB(240, 242, 248),
		SubText = Color3.fromRGB(132, 137, 153),
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.93,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.35,
		Success = Color3.fromRGB(50, 225, 125),
		Warning = Color3.fromRGB(255, 180, 45),
		Danger = Color3.fromRGB(255, 68, 85),
		Info = Color3.fromRGB(75, 155, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},]]

	Default = {
		Primary = Color3.fromRGB(12, 12, 13),
		Secondary = {
			[1] = Color3.fromRGB(18, 18, 20),
			[2] = Color3.fromRGB(28, 28, 32),
		},
		Accent = Color3.fromRGB(245, 245, 250),
		Slider = Color3.fromRGB(215, 215, 222),
		Text = Color3.fromRGB(245, 245, 248),
		SubText = Color3.fromRGB(130, 130, 138),
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.92,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.40,
		Success = Color3.fromRGB(60, 220, 120),
		Warning = Color3.fromRGB(255, 190, 50),
		Danger = Color3.fromRGB(255, 65, 75),
		Info = Color3.fromRGB(150, 160, 175),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Midnight = {
		Primary = Color3.fromRGB(9, 10, 16),
		Secondary = {
			[1] = Color3.fromRGB(14, 15, 25),
			[2] = Color3.fromRGB(22, 24, 40),
		},
		Accent = Color3.fromRGB(100, 105, 255),
		Slider = Color3.fromRGB(100, 105, 255),
		Text = Color3.fromRGB(235, 238, 248),
		SubText = Color3.fromRGB(128, 133, 158),
		Stroke = Color3.fromRGB(140, 150, 255),
		StrokeTransparency = 0.91,
		Shadow = Color3.fromRGB(4, 5, 10),
		ShadowTransparency = 0.30,
		Success = Color3.fromRGB(45, 225, 140),
		Warning = Color3.fromRGB(255, 175, 50),
		Danger = Color3.fromRGB(255, 70, 90),
		Info = Color3.fromRGB(120, 130, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Light = {
		Primary = Color3.fromRGB(236, 238, 243),
		Secondary = {
			[1] = Color3.fromRGB(248, 249, 252),
			[2] = Color3.fromRGB(224, 227, 235),
		},
		Accent = Color3.fromRGB(20, 95, 255),
		Slider = Color3.fromRGB(20, 95, 255),
		Text = Color3.fromRGB(18, 20, 28),
		SubText = Color3.fromRGB(110, 115, 130),
		Stroke = Color3.fromRGB(0, 0, 0),
		StrokeTransparency = 0.92,
		Shadow = Color3.fromRGB(15, 20, 35),
		ShadowTransparency = 0.85,
		Success = Color3.fromRGB(25, 185, 85),
		Warning = Color3.fromRGB(230, 150, 10),
		Danger = Color3.fromRGB(235, 45, 60),
		Info = Color3.fromRGB(25, 110, 245),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	--[[Graphite = {
		Primary = Color3.fromRGB(12, 12, 13),
		Secondary = {
			[1] = Color3.fromRGB(18, 18, 20),
			[2] = Color3.fromRGB(28, 28, 32),
		},
		Accent = Color3.fromRGB(245, 245, 250),
		Slider = Color3.fromRGB(215, 215, 222),
		Text = Color3.fromRGB(245, 245, 248),
		SubText = Color3.fromRGB(130, 130, 138),
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.92,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.40,
		Success = Color3.fromRGB(60, 220, 120),
		Warning = Color3.fromRGB(255, 190, 50),
		Danger = Color3.fromRGB(255, 65, 75),
		Info = Color3.fromRGB(150, 160, 175),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},]]

	Slate = {
		Primary = Color3.fromRGB(10, 13, 17),
		Secondary = {
			[1] = Color3.fromRGB(16, 20, 26),
			[2] = Color3.fromRGB(24, 30, 40),
		},
		Accent = Color3.fromRGB(38, 175, 255),
		Slider = Color3.fromRGB(38, 175, 255),
		Text = Color3.fromRGB(235, 240, 248),
		SubText = Color3.fromRGB(125, 138, 155),
		Stroke = Color3.fromRGB(180, 210, 255),
		StrokeTransparency = 0.90,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.38,
		Success = Color3.fromRGB(50, 225, 135),
		Warning = Color3.fromRGB(255, 195, 40),
		Danger = Color3.fromRGB(255, 75, 85),
		Info = Color3.fromRGB(40, 180, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Obsidian = {
		Primary = Color3.fromRGB(10, 8, 13),
		Secondary = {
			[1] = Color3.fromRGB(16, 13, 22),
			[2] = Color3.fromRGB(26, 21, 35),
		},
		Accent = Color3.fromRGB(170, 75, 255),
		Slider = Color3.fromRGB(170, 75, 255),
		Text = Color3.fromRGB(242, 238, 248),
		SubText = Color3.fromRGB(140, 130, 155),
		Stroke = Color3.fromRGB(220, 180, 255),
		StrokeTransparency = 0.91,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.32,
		Success = Color3.fromRGB(55, 225, 130),
		Warning = Color3.fromRGB(255, 185, 45),
		Danger = Color3.fromRGB(255, 65, 80),
		Info = Color3.fromRGB(160, 95, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Crimson = {
		Primary = Color3.fromRGB(13, 9, 10),
		Secondary = {
			[1] = Color3.fromRGB(20, 13, 15),
			[2] = Color3.fromRGB(32, 19, 23),
		},
		Accent = Color3.fromRGB(255, 45, 75),
		Slider = Color3.fromRGB(255, 45, 75),
		Text = Color3.fromRGB(248, 238, 240),
		SubText = Color3.fromRGB(152, 128, 133),
		Stroke = Color3.fromRGB(255, 140, 160),
		StrokeTransparency = 0.91,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.36,
		Success = Color3.fromRGB(50, 225, 130),
		Warning = Color3.fromRGB(255, 180, 45),
		Danger = Color3.fromRGB(255, 45, 75),
		Info = Color3.fromRGB(255, 95, 120),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Ember = {
		Primary = Color3.fromRGB(13, 11, 9),
		Secondary = {
			[1] = Color3.fromRGB(21, 16, 13),
			[2] = Color3.fromRGB(33, 25, 20),
		},
		Accent = Color3.fromRGB(255, 115, 25),
		Slider = Color3.fromRGB(255, 115, 25),
		Text = Color3.fromRGB(248, 240, 235),
		SubText = Color3.fromRGB(155, 138, 126),
		Stroke = Color3.fromRGB(255, 190, 150),
		StrokeTransparency = 0.91,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.38,
		Success = Color3.fromRGB(55, 225, 125),
		Warning = Color3.fromRGB(255, 185, 35),
		Danger = Color3.fromRGB(255, 65, 70),
		Info = Color3.fromRGB(255, 145, 65),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Aurora = {
		Primary = Color3.fromRGB(9, 13, 13),
		Secondary = {
			[1] = Color3.fromRGB(14, 21, 20),
			[2] = Color3.fromRGB(21, 33, 31),
		},
		Accent = Color3.fromRGB(35, 230, 175),
		Slider = Color3.fromRGB(35, 230, 175),
		Text = Color3.fromRGB(235, 248, 244),
		SubText = Color3.fromRGB(125, 155, 148),
		Stroke = Color3.fromRGB(150, 255, 225),
		StrokeTransparency = 0.90,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.36,
		Success = Color3.fromRGB(35, 230, 175),
		Warning = Color3.fromRGB(255, 195, 45),
		Danger = Color3.fromRGB(255, 70, 85),
		Info = Color3.fromRGB(45, 215, 230),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	Rose = {
		Primary = Color3.fromRGB(13, 9, 13),
		Secondary = {
			[1] = Color3.fromRGB(20, 13, 20),
			[2] = Color3.fromRGB(32, 20, 32),
		},
		Accent = Color3.fromRGB(255, 80, 175),
		Slider = Color3.fromRGB(255, 80, 175),
		Text = Color3.fromRGB(248, 238, 246),
		SubText = Color3.fromRGB(155, 128, 150),
		Stroke = Color3.fromRGB(255, 160, 220),
		StrokeTransparency = 0.91,
		Shadow = Color3.fromRGB(0, 0, 0),
		ShadowTransparency = 0.36,
		Success = Color3.fromRGB(55, 225, 135),
		Warning = Color3.fromRGB(255, 185, 45),
		Danger = Color3.fromRGB(255, 60, 80),
		Info = Color3.fromRGB(235, 100, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	},

	DeepBlue = {
		Primary = Color3.fromRGB(7, 10, 16),
		Secondary = {
			[1] = Color3.fromRGB(11, 16, 26),
			[2] = Color3.fromRGB(18, 26, 42),
		},
		Accent = Color3.fromRGB(0, 160, 255),
		Slider = Color3.fromRGB(0, 160, 255),
		Text = Color3.fromRGB(232, 242, 255),
		SubText = Color3.fromRGB(120, 140, 170),
		Stroke = Color3.fromRGB(120, 200, 255),
		StrokeTransparency = 0.89,
		Shadow = Color3.fromRGB(2, 4, 8),
		ShadowTransparency = 0.28,
		Success = Color3.fromRGB(45, 230, 145),
		Warning = Color3.fromRGB(255, 185, 45),
		Danger = Color3.fromRGB(255, 65, 80),
		Info = Color3.fromRGB(0, 170, 255),
		Font = Enum.Font.GothamMedium,
		TitleFont = Enum.Font.GothamBold,
	}
}

function Utility.Tween(object, time, properties, style, direction)
	if not object or typeof(properties) ~= "table" then return nil end
	local tween = Services.TweenService:Create(object, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

function Utility.SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then return end

	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[Fancy] Callback error: " .. tostring(err))
	end

	if typeof(SaveManager.QueueSave) == "function" and Fancy.WindowSettings and typeof(Fancy.WindowSettings.Configuration) == "table" and Fancy.WindowSettings.Configuration.AutoSave then
		SaveManager.QueueSave()
	end
end

function Utility.Round(number, decimals)
	local factor = 10 ^ (decimals or 0)
	return math.floor(number * factor + 0.5) / factor
end

function Utility.Comma(number)
	local formatted = tostring(math.floor(number))
	while true do
		local replaced
		formatted, replaced = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if replaced == 0 then
			break
		end
	end
	return formatted
end

function Utility.ResolveSize(size, fallbackWidth, fallbackHeight)
	if typeof(size) ~= "UDim2" then
		return UDim2.fromOffset(fallbackWidth or 691, fallbackHeight or 457)
	end
	local camera = Services.Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local x = size.X.Scale > 0 and math.floor(size.X.Scale * viewport.X + 0.5) or size.X.Offset
	local y = size.Y.Scale > 0 and math.floor(size.Y.Scale * viewport.Y + 0.5) or size.Y.Offset
	if x <= 0 then
		x = fallbackWidth or 691
	end
	if y <= 0 then
		y = fallbackHeight or 457
	end
	return UDim2.fromOffset(x, y)
end

local function resolveThemeKey(theme, key)
	local value = theme
	for part in string.gmatch(tostring(key), "[^.]+") do
		if typeof(value) ~= "table" then return nil end
		value = value[tonumber(part) or part]
		if value == nil then return nil end
	end
	return value
end

function Utility.ApplyTheme(root, theme)
	if not root or typeof(theme) ~= "table" then return end

	local function apply(object)
		local bindings = {
			{ object:GetAttribute("FancyBackground"), "BackgroundColor3" },
			{ object:GetAttribute("FancyText"), "TextColor3" },
			{ object:GetAttribute("FancyStroke"), "Color" },
			{ object:GetAttribute("FancyImage"), "ImageColor3" },
			{ object:GetAttribute("FancyScrollBar"), "ScrollBarImageColor3" },
		}
		for _, binding in bindings do
			if binding[1] then
				local color = resolveThemeKey(theme, binding[1])
				if typeof(color) == "Color3" then
					pcall(function()
						object[binding[2]] = color
					end)
				end
			end
		end
	end

	apply(root)
	for _, object in root:GetDescendants() do
		apply(object)
	end
end

function Utility.ElementBase(container, settings)
	local Theme = Fancy.Theme
	settings = typeof(settings) == "table" and settings or {}

	local hasDescription = typeof(settings.Description) == "string" and settings.Description ~= ""
	local height = settings.Height or (hasDescription and 50 or 32)

	local Card = InstanceModule:Create("Frame", {
		Name = tostring(settings.Name or settings.Title or "Element"),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Secondary[2],
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = container,
	})
	Card:SetAttribute("FancyBackground", "Secondary.2")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Card })

	local stroke = InstanceModule:Create("UIStroke", {
		Color = Theme.Stroke,
		Transparency = math.min((Theme.StrokeTransparency or 0.92) + 0.02, 1),
		Parent = Card,
	})
	stroke:SetAttribute("FancyStroke", "Stroke")

	local Hover = InstanceModule:Create("Frame", {
		Name = "HoverWash",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Hover:SetAttribute("FancyBackground", "Stroke")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Hover })

	Card.MouseEnter:Connect(function()
		Utility.Tween(Hover, 0.12, { BackgroundTransparency = 0.965 })
	end)
	Card.MouseLeave:Connect(function()
		Utility.Tween(Hover, 0.18, { BackgroundTransparency = 1 })
	end)

	local Label = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 10, 0, hasDescription and 8 or 0),
		Size = UDim2.new(1, -20, 0, hasDescription and 14 or height),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = tostring(settings.Name or settings.Title or "Element"),
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Card,
	})
	Label:SetAttribute("FancyText", "Text")

	local Description
	if hasDescription then
		Description = InstanceModule:Create("TextLabel", {
			Position = UDim2.new(0, 10, 0, 26),
			Size = UDim2.new(1, -20, 0, 13),
			BackgroundTransparency = 1,
			Font = Theme.Font,
			Text = settings.Description,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Card,
		})
		Description:SetAttribute("FancyText", "SubText")
	end

	return Card, Label, Description, settings, Hover
end

function Utility.MakeDraggable(handle, target, canDrag, onMoved)
	if not handle or not target then return end

	local DRAG_DEADZONE = 4

	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if target.Parent == nil then return end
		if canDrag and not canDrag() then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)

	local endedConnection
	local changedConnection

	local function disconnect()
		endedConnection:Disconnect()
		changedConnection:Disconnect()
	end

	endedConnection = Services.UserInputService.InputEnded:Connect(function(input)
		if target.Parent == nil then
			disconnect()
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	Services.UserInputService.TouchEnded:Connect(function(touch)
		if dragging and touch.UserInputState == Enum.UserInputState.Cancel then
			dragging = false
		end
	end)

	changedConnection = Services.UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if target.Parent == nil then
			disconnect()
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if math.abs(delta.X) < DRAG_DEADZONE and math.abs(delta.Y) < DRAG_DEADZONE then
				return
			end

			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

			if typeof(onMoved) == "function" then
				onMoved(target)
			end
		end
	end)
end

do
	local ENCODE_CHARS = buffer.fromstring("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
	local ENCODE_URL_CHARS = buffer.fromstring("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")

	local DECODE_LUT = buffer.create(256)
	buffer.fill(DECODE_LUT, 0, 0xFF, 256)

	for i = 0, 63 do
		local charCode = buffer.readu8(ENCODE_CHARS, i)
		buffer.writeu8(DECODE_LUT, charCode, i)
	end

	buffer.writeu8(DECODE_LUT, 45, 62)
	buffer.writeu8(DECODE_LUT, 95, 63)

	local function toBuffer(input)
		if type(input) == "string" then
			return buffer.fromstring(input)
		end
		return input
	end

	local function encodeInternal(src)
		local srcLen = buffer.len(src)
		if srcLen == 0 then
			return buffer.create(0)
		end

		local rem = srcLen % 3
		local mainLen = srcLen - rem

		local dstLen = (mainLen // 3 + 1) * 4
		if rem == 0 then
			dstLen = (mainLen // 3) * 4
		end

		local dst = buffer.create(dstLen)
		local srcIdx = 0
		local dstIdx = 0

		while srcIdx < mainLen do
			local b0 = buffer.readu8(src, srcIdx)
			local b1 = buffer.readu8(src, srcIdx + 1)
			local b2 = buffer.readu8(src, srcIdx + 2)
			srcIdx += 3

			local n = bit32.bor(bit32.lshift(b0, 16), bit32.lshift(b1, 8), b2)
			buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(n, 18)))
			buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 12), 0x3F)))
			buffer.writeu8(dst, dstIdx + 2, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 6), 0x3F)))
			buffer.writeu8(dst, dstIdx + 3, buffer.readu8(ENCODE_CHARS, bit32.band(n, 0x3F)))
			dstIdx += 4
		end

		if rem == 1 then
			local b0 = buffer.readu8(src, srcIdx)
			buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(b0, 2)))
			buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.lshift(bit32.band(b0, 0x03), 4)))
			buffer.writeu8(dst, dstIdx + 2, 61)
			buffer.writeu8(dst, dstIdx + 3, 61)
		elseif rem == 2 then
			local b0 = buffer.readu8(src, srcIdx)
			local b1 = buffer.readu8(src, srcIdx + 1)
			local n = bit32.bor(bit32.lshift(b0, 8), b1)
			buffer.writeu8(dst, dstIdx, buffer.readu8(ENCODE_CHARS, bit32.rshift(n, 10)))
			buffer.writeu8(dst, dstIdx + 1, buffer.readu8(ENCODE_CHARS, bit32.band(bit32.rshift(n, 4), 0x3F)))
			buffer.writeu8(dst, dstIdx + 2, buffer.readu8(ENCODE_CHARS, bit32.lshift(bit32.band(n, 0x0F), 2)))
			buffer.writeu8(dst, dstIdx + 3, 61)
		end

		return dst
	end

	local function decodeInternal(src)
		local srcLen = buffer.len(src)
		if srcLen == 0 then
			return buffer.create(0)
		end

		while srcLen > 0 do
			local last = buffer.readu8(src, srcLen - 1)
			if last == 10 or last == 13 or last == 32 or last == 9 then
				srcLen -= 1
			else
				break
			end
		end

		if srcLen == 0 then
			return buffer.create(0)
		end

		local pad = 0
		if srcLen >= 2 and buffer.readu8(src, srcLen - 1) == 61 then
			pad = 1
			if buffer.readu8(src, srcLen - 2) == 61 then
				pad = 2
			end
		end

		local outputLen
		if pad > 0 then
			if srcLen % 4 ~= 0 then
				error("Invalid Base64 input: padded length must be a multiple of 4")
			end
			if srcLen >= 3 and buffer.readu8(src, srcLen - 3) == 61 then
				error("Invalid Base64 input: too many padding characters")
			end
			outputLen = (srcLen // 4) * 3 - pad
		else
			local rem = srcLen % 4
			if rem == 0 then
				outputLen = (srcLen // 4) * 3
			elseif rem == 2 then
				outputLen = (srcLen // 4) * 3 + 1
			elseif rem == 3 then
				outputLen = (srcLen // 4) * 3 + 2
			else
				error("Invalid Base64 input: invalid unpadded string length")
			end
		end

		if outputLen < 0 then
			error("Invalid Base64 input: invalid length")
		end

		local dst = buffer.create(outputLen)
		local fullEnd = pad > 0 and srcLen - 4 or srcLen - (srcLen % 4)
		local srcIdx = 0
		local dstIdx = 0

		while srcIdx < fullEnd do
			local c0 = buffer.readu8(src, srcIdx)
			local c1 = buffer.readu8(src, srcIdx + 1)
			local c2 = buffer.readu8(src, srcIdx + 2)
			local c3 = buffer.readu8(src, srcIdx + 3)
			srcIdx += 4

			local v0 = buffer.readu8(DECODE_LUT, c0)
			local v1 = buffer.readu8(DECODE_LUT, c1)
			local v2 = buffer.readu8(DECODE_LUT, c2)
			local v3 = buffer.readu8(DECODE_LUT, c3)

			if bit32.bor(v0, v1, v2, v3) >= 64 then
				error("Invalid Base64 character encountered")
			end

			local n = bit32.bor(bit32.lshift(v0, 18), bit32.lshift(v1, 12), bit32.lshift(v2, 6), v3)
			buffer.writeu8(dst, dstIdx, bit32.rshift(n, 16))
			buffer.writeu8(dst, dstIdx + 1, bit32.band(bit32.rshift(n, 8), 0xFF))
			buffer.writeu8(dst, dstIdx + 2, bit32.band(n, 0xFF))
			dstIdx += 3
		end

		local remaining = outputLen - dstIdx
		if remaining == 1 then
			local c0 = buffer.readu8(src, srcIdx)
			local c1 = buffer.readu8(src, srcIdx + 1)
			local v0 = buffer.readu8(DECODE_LUT, c0)
			local v1 = buffer.readu8(DECODE_LUT, c1)

			if bit32.bor(v0, v1) >= 64 then
				error("Invalid Base64 character encountered")
			end

			buffer.writeu8(dst, dstIdx, bit32.bor(bit32.lshift(v0, 2), bit32.rshift(v1, 4)))
		elseif remaining == 2 then
			local c0 = buffer.readu8(src, srcIdx)
			local c1 = buffer.readu8(src, srcIdx + 1)
			local c2 = buffer.readu8(src, srcIdx + 2)
			local v0 = buffer.readu8(DECODE_LUT, c0)
			local v1 = buffer.readu8(DECODE_LUT, c1)
			local v2 = buffer.readu8(DECODE_LUT, c2)

			if bit32.bor(v0, v1, v2) >= 64 then
				error("Invalid Base64 character encountered")
			end

			local n = bit32.bor(bit32.lshift(v0, 10), bit32.lshift(v1, 4), bit32.rshift(v2, 2))
			buffer.writeu8(dst, dstIdx, bit32.rshift(n, 8))
			buffer.writeu8(dst, dstIdx + 1, bit32.band(n, 0xFF))
		end

		return dst
	end

	Utility.Base64 = {
		Encode = function(str)
			if typeof(str) ~= "string" then
				return ""
			end

			if typeof(crypt) == "table" and typeof(crypt.base64) == "table" and typeof(crypt.base64.encode) == "function" then
				return crypt.base64.encode(str)
			end

			return buffer.tostring(encodeInternal(toBuffer(str), false))
		end,
		Decode = function(str)
			if typeof(str) ~= "string" then
				return ""
			end

			if typeof(crypt) == "table" and typeof(crypt.base64) == "table" and typeof(crypt.base64.decode) == "function" then
				return crypt.base64.decode(str)
			end

			return buffer.tostring(decodeInternal(toBuffer(str)))
		end
	}
end

Signal.__index = Signal

function Utility.Signal()
	return setmetatable({ _bindable = Instance.new("BindableEvent") }, Signal)
end

function Signal:Connect(callback)
	return self._bindable.Event:Connect(callback)
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Wait()
	return self._bindable.Event:Wait()
end

function Signal:Destroy()
	self._bindable:Destroy()
end

function Notifications.Send(props)
	if not Fancy or not Fancy.MainUI then return end
	props = typeof(props) == "table" and props or {}

	local host = Fancy.NotifyLayer or Fancy.MainUI
	if not host then return end

	local Theme = Fancy.Theme or Themes.Default
	if not Theme then return end

	local typeIcons = { Success = "circle-check", Warning = "circle-alert", Danger = "circle-x", Info = "info" }
	local kind = props.Type and typeIcons[props.Type] and props.Type or "Info"
	local color = props.Color or Theme[kind] or Theme.Accent

	local notificationOrder = 0

	local duration = tonumber(props.Duration)
	if duration == nil then
		duration = 4
	end

	local function resolveIcon(name)
		if typeof(name) ~= "string" then
			return nil
		end
		if string.find(name, "rbxassetid", 1, true) then
			return name
		end
		if Icons then
			return Icons.Get(name)
		end
		return nil
	end

	local holder = host:FindFirstChild("FancyNotifications")
	if not holder then
		holder = Instance.new("Frame")
		holder.Name = "FancyNotifications"
		holder.AnchorPoint = Vector2.new(1, 0)
		holder.Position = UDim2.new(1, -16, 0, 16)
		holder.Size = UDim2.new(0, 300, 1, -32)
		holder.BackgroundTransparency = 1
		holder.ClipsDescendants = true
		holder.ZIndex = 50
		holder.Parent = host

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = holder
	end

	notificationOrder = notificationOrder - 1

	local Toast = Instance.new("Frame")
	Toast.Name = "Toast"
	Toast.Size = UDim2.new(1, 0, 0, 58)
	Toast.LayoutOrder = notificationOrder
	Toast.BackgroundTransparency = 1
	Toast.Parent = holder

	local Card = Instance.new("Frame")
	Card.Name = "Card"
	Card.Size = UDim2.new(1, 0, 1, 0)
	Card.Position = UDim2.fromOffset(320, 0)
	Card.BackgroundColor3 = props.BackgroundColor or Theme.Primary
	Card.BorderSizePixel = 0
	Card.Parent = Toast

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = Card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Stroke
	stroke.Transparency = Theme.StrokeTransparency or 0.92
	stroke.Parent = Card

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.Position = UDim2.new(0, 8, 0.5, 0)
	bar.Size = UDim2.new(0, 3, 1, -16)
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.Parent = Card

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local icon = Instance.new("ImageLabel")
	icon.Position = UDim2.new(0, 20, 0, 21)
	icon.Size = UDim2.fromOffset(16, 16)
	icon.BackgroundTransparency = 1
	icon.Image = resolveIcon(props.Icon) or resolveIcon(typeIcons[kind]) or "rbxassetid://124560466474914"
	icon.ImageColor3 = color
	icon.Parent = Card

	local title = Instance.new("TextLabel")
	title.Position = UDim2.new(0, 44, 0, 12)
	title.Size = UDim2.new(1, -54, 0, 14)
	title.BackgroundTransparency = 1
	title.Font = Theme.TitleFont
	title.Text = props.Title or "Notification"
	title.TextSize = 12
	title.TextColor3 = Theme.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = Card

	local text = Instance.new("TextLabel")
	text.Position = UDim2.new(0, 44, 0, 28)
	text.Size = UDim2.new(1, -54, 0, 24)
	text.BackgroundTransparency = 1
	text.Font = Theme.Font
	text.Text = props.Text or props.Content or ""
	text.TextSize = 11
	text.TextColor3 = Theme.SubText
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.TextWrapped = true
	text.Parent = Card

	local closed = false
	local progressTween

	local function close()
		if closed then return end
		closed = true
		if progressTween then
			progressTween:Cancel()
		end
		Services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(320, 0) }):Play()
		task.delay(0.35, function()
			Toast:Destroy()
		end)
	end

	local click = Instance.new("TextButton")
	click.Size = UDim2.new(1, 0, 1, 0)
	click.BackgroundTransparency = 1
	click.Text = ""
	click.Parent = Card
	click.Activated:Connect(close)

	Services.TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 0) }):Play()

	if duration > 0 then
		local progress = Instance.new("Frame")
		progress.AnchorPoint = Vector2.new(0, 1)
		progress.Position = UDim2.new(0, 0, 1, 0)
		progress.Size = UDim2.new(1, 0, 0, 2)
		progress.BackgroundColor3 = color
		progress.BackgroundTransparency = 0.45
		progress.BorderSizePixel = 0
		progress.ZIndex = 2
		progress.Parent = Card
		progressTween = Services.TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 2) })
		task.delay(duration, close)
	end
end

local function notify(props)
	if Fancy and Fancy.MainUI then
		Notifications.Send(props)
	end
end

local function encode(data)
	if typeof(data) ~= "table" then return nil end
	local ok, json = pcall(Services.HttpService.JSONEncode, Services.HttpService, data)
	if not ok or typeof(json) ~= "string" then return nil end
	local okB64, encoded = pcall(Utility.Base64.Encode, json)
	if okB64 and typeof(encoded) == "string" then
		return encoded
	end
	return nil
end

local function decode(content)
	if typeof(content) ~= "string" or #content == 0 then return nil end
	local ok, json = pcall(Utility.Base64.Decode, content)
	if not ok or typeof(json) ~= "string" then return nil end
	local okJson, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, json)
	if okJson and typeof(data) == "table" then
		return data
	end
	return nil
end

local function sanitize(name)
	name = tostring(name or "")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[^%w%s%-_]", "")
	return name
end

local function configPath(name)
	return SaveManager.Folder .. "/" .. name .. ".json"
end

local function ensureFolder()
	if not SaveManager_Internal.FileApi then
		return true
	end
	local built = ""
	for segment in string.gmatch(SaveManager.Folder, "[^/\\]+") do
		built = built == "" and segment or built .. "/" .. segment
		if not isfolder(built) then
			pcall(makefolder, built)
		end
	end
	return isfolder(SaveManager.Folder)
end

local function writeConfig(path, json)
	if SaveManager_Internal.FileApi then
		return (pcall(writefile, path, json))
	end
	SaveManager_Internal.MemoryConfigs[path] = json
	return true
end

local function readConfig(path)
	if SaveManager_Internal.FileApi then
		if not isfile(path) then return nil end
		local ok, content = pcall(readfile, path)
		if ok and typeof(content) == "string" then
			return content
		end
		return nil
	end
	return SaveManager_Internal.MemoryConfigs[path]
end

local function deleteConfig(path)
	if SaveManager_Internal.FileApi then
		if isfile(path) then
			return (pcall(delfile, path))
		end
		return true
	end
	SaveManager_Internal.MemoryConfigs[path] = nil
	return true
end

local function checkReady()
	if Initialized and Fancy then
		return true
	end
	notify({ Title = "SaveManager", Text = "Not initialized", Type = "Warning", Duration = 6 })
	return false
end

function SaveManager:Initialize()
	SaveManager_Internal.FileApi = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function" and typeof(isfolder) == "function" and typeof(makefolder) == "function"

	local config = {}
	if Fancy and typeof(Fancy.WindowSettings) == "table" and typeof(Fancy.WindowSettings.Configuration) == "table" then
		config = Fancy.WindowSettings.Configuration
	end

	if not Initialized then
		if typeof(config.CustomFolder) == "string" and #sanitize(config.CustomFolder) > 0 then
			SaveManager.Folder = sanitize(config.CustomFolder) .. "/Configs"
		end

		if typeof(config.FileName) == "string" and #sanitize(config.FileName) > 0 then
			SaveManager.DefaultName = sanitize(config.FileName)
		end

		if not SaveManager_Internal.FileApi then
			notify({
				Title = "SaveManager",
				Text = "File system API unavailable configs are in-memory for this session",
				Type = "Warning",
				Duration = 7,
			})
		end
	end

	Initialized = true

	if config.AutoLoad ~= false then
		task.defer(function()
			if not (Fancy and Fancy.MainUI) then return end
			if not SaveManager:Get(SaveManager.DefaultName) then return end
			local ok, applied, deferred = SaveManager:Load(SaveManager.DefaultName, true)
			if ok then
				local total = (applied or 0) + (deferred or 0)
				if total > 0 then
					notify({
						Title = "SaveManager",
						Text = ("Auto-loaded '%s' %d flags"):format(SaveManager.DefaultName, total),
						Type = "Success",
						Duration = 4,
					})
				end
			end
		end)
	end

	if config.AutoSave then
		SaveManager:EnableAutoSave(tonumber(config.AutoSaveInterval) or SaveManager.AutoSaveInterval)
	end
end

function SaveManager.Register(flag, api)
	if flag == nil then
		return
	end
	if typeof(flag) ~= "string" or #flag == 0 then
		warn("[Fancy] SaveManager.Register: flag must be a non-empty string")
		return
	end

	if SaveManager_Internal.Registry[flag] then
		warn(("[Fancy] SaveManager: flag '%s' registered twice keeping the newest element"):format(flag))
		SaveManager.Unregister(flag)
	end

	local entry = {
		Get = api.Get,
		Set = api.Set,
		Connection = nil,
	}

	if typeof(api.Instance) == "Instance" then
		entry.Connection = api.Instance.Destroying:Connect(function()
			SaveManager.Unregister(flag)
		end)
	end

	SaveManager_Internal.Registry[flag] = entry

	local pendingValue = SaveManager_Internal.Pending[flag]
	if pendingValue ~= nil then
		Pending[flag] = nil
		task.spawn(function()
			pcall(entry.Set, pendingValue)
		end)
	end
end

function SaveManager.Unregister(flag)
	local entry = SaveManager_Internal.Registry[flag]
	if not entry then return end
	if entry.Connection then
		pcall(function()
			entry.Connection:Disconnect()
		end)
	end
	SaveManager_Internal.Registry[flag] = nil
end

function SaveManager:GetFlag(flag)
	local entry = SaveManager_Internal.Registry[flag]
	if not entry then return nil end
	local ok, value = pcall(entry.Get)
	return ok and value or nil
end

function SaveManager:SetFlag(flag, value, silent)
	local entry = SaveManager_Internal.Registry[flag]
	if not entry then
		warn(("[Fancy] SaveManager: no element registered with flag '%s'"):format(tostring(flag)))
		return false
	end
	return (pcall(entry.Set, value, silent))
end

function SaveManager:GetFlags()
	local flags = {}
	for flag in SaveManager_Internal.Registry do
		flags[flag] = SaveManager:GetFlag(flag)
	end
	return flags
end

function SaveManager:Get(name)
	if not checkReady() then return nil end
	name = sanitize(name)
	if name == "" then return nil end
	local content = readConfig(configPath(name))
	if not content then return nil end
	return decode(content)
end

SaveManager.GetSave = SaveManager.Get

function SaveManager:Save(name, silent)
	if not checkReady() then return false end
	name = sanitize(name ~= nil and name or SaveManager.DefaultName)
	if name == "" then
		notify({ Title = "SaveManager", Text = "Invalid config name", Type = "Warning" })
		return false
	end
	if not ensureFolder() then
		notify({ Title = "SaveManager", Text = "Couldn't create the config folder", Type = "Danger" })
		return false
	end

	local flags = {}
	for flag, entry in SaveManager_Internal.Registry do
		local ok, value = pcall(entry.Get)
		if ok then
			flags[flag] = value
		end
	end

	local count = 0
	for _ in flags do
		count = count + 1
	end

	local payload = encode({
		Theme = Fancy.ThemeName,
		SavedAt = os.time(),
		Flags = flags,
	})

	if not payload then
		notify({ Title = "SaveManager", Text = "Failed to encode the config (flags must be string/number/boolean)", Type = "Danger" })
		return false
	end

	if not writeConfig(configPath(name), payload) then
		notify({ Title = "SaveManager", Text = "Failed to write '" .. name .. "'", Type = "Danger" })
		return false
	end

	if not silent then
		notify({
			Title = "SaveManager",
			Text = ("Saved '%s' %d flags"):format(name, count),
			Type = "Success",
		})
	end

	return true
end

function SaveManager:Load(name, silent)
	if not checkReady() then return false end
	name = sanitize(name ~= nil and name or SaveManager.DefaultName)

	local data = SaveManager:Get(name)
	if not data then
		if not silent then
			notify({ Title = "SaveManager", Text = "Config '" .. name .. "' not found", Type = "Warning" })
		end
		return false
	end

	local flagsTable = typeof(data.Flags) == "table" and data.Flags or {}
	local applied, deferred = 0, 0
	local nextPending = {}

	for flag, value in flagsTable do
		local entry = SaveManager_Internal.Registry[flag]
		if entry then
			if pcall(entry.Set, value) then
				applied = applied + 1
			end
		else
			nextPending[flag] = value
			deferred = deferred + 1
		end
	end
	Pending = nextPending

	if typeof(data.Theme) == "string" and Themes[data.Theme] and Fancy.MainUI then
		Fancy.Theme = Themes[data.Theme]
		Fancy.ThemeName = data.Theme
		pcall(Utility.ApplyTheme, Fancy.MainUI, Fancy.Theme)
	end

	if not silent then
		notify({
			Title = "SaveManager",
			Text = ("Loaded '%s' %d flags%s"):format(
				name,
				applied,
				deferred > 0 and (" + " .. deferred .. " deferred") or ""),
			Type = "Success",
		})
	end

	return true, applied, deferred
end

function SaveManager:Delete(name, silent)
	if not checkReady() then return false end
	name = sanitize(name)
	if name == "" then
		notify({ Title = "SaveManager", Text = "Invalid config name", Type = "Warning" })
		return false
	end

	local path = configPath(name)
	if SaveManager_Internal.FileApi and not isfile(path) then
		if not silent then
			notify({ Title = "SaveManager", Text = "Config '" .. name .. "' not found", Type = "Warning" })
		end
		return false
	end

	if not deleteConfig(path) then
		notify({ Title = "SaveManager", Text = "Failed to delete '" .. name .. "' (is delfile supported?)", Type = "Danger" })
		return false
	end

	if not silent then
		notify({ Title = "SaveManager", Text = "Deleted '" .. name .. "'", Type = "Info" })
	end

	return true
end

function SaveManager:GetConfigs()
	local names = {}

	if SaveManager_Internal.FileApi and typeof(listfiles) == "function" then
		local ok, files = pcall(listfiles, SaveManager.Folder)
		if ok and typeof(files) == "table" then
			for _, path in files do
				local name = string.match(tostring(path), "([^/\\]+)%.json$")
				if name then
					table.insert(names, name)
				end
			end
		end
	else
		for path in SaveManager_Internal.MemoryConfigs do
			local name = string.match(path, "([^/\\]+)%.json$")
			if name then
				table.insert(names, name)
			end
		end
	end

	table.sort(names)
	return names
end

function SaveManager:SetFolder(path)
	if typeof(path) ~= "string" then return end
	path = path:gsub("\\", "/"):gsub("/+", "/"):gsub("^%s+", ""):gsub("%s+$", "")
	if path == "" then return end
	SaveManager.Folder = path
end

function SaveManager:GetStorage()
	return SaveManager_Internal.FileApi and "Files" or "Memory"
end

function SaveManager.QueueSave()
	if not Initialized then return end
	SaveManager_Internal.DebounceToken = SaveManager_Internal.DebounceToken + 1
	local token = SaveManager_Internal.DebounceToken
	task.delay(SaveManager.DebounceDelay, function()
		if token ~= SaveManager_Internal.DebounceToken then return end
		if not (Fancy and Fancy.MainUI and Fancy.MainUI.Parent) then return end
		if next(SaveManager_Internal.Registry) == nil then return end
		SaveManager:Save(SaveManager.DefaultName, true)
	end)
end

function SaveManager:EnableAutoSave(interval)
	SaveManager:DisableAutoSave()
	interval = math.max(tonumber(interval) or SaveManager.AutoSaveInterval, 10)
	SaveManager_Internal.AutoSaveToken = SaveManager_Internal.AutoSaveToken + 1
	local token = SaveManager_Internal.AutoSaveToken
	task.spawn(function()
		while token == SaveManager_Internal.AutoSaveToken do
			task.wait(interval)
			if token ~= SaveManager_Internal.AutoSaveToken then break end
			if not (Fancy and Fancy.MainUI and Fancy.MainUI.Parent) then break end
			if next(SaveManager_Internal.Registry) ~= nil then
				SaveManager:Save(SaveManager.DefaultName, true)
			end
		end
	end)
end

function SaveManager:DisableAutoSave()
	SaveManager_Internal.AutoSaveToken = SaveManager_Internal.AutoSaveToken + 1
end

function SaveManager:CreateConfigSection(container)
	local host = nil
	if typeof(container) == "table" then
		if container.Container then
			host = container
		elseif typeof(container.NewSection) == "function" then
			host = container:NewSection({ Name = "Configs" })
		end
	end
	if not host or not Fancy then
		warn("[Fancy] SaveManager:CreateConfigSection expects a Tab or Section")
		return nil
	end

	host:NewParagraph({
		Title = "Storage",
		Text = ("Mode: %s\nFolder: %s\nDefault slot: %s"):format(
			SaveManager:GetStorage(), SaveManager.Folder, SaveManager.DefaultName),
	})

	local nameInput = host:NewInput({
		Name = "Config name",
		Description = "Empty = the default slot ('" .. SaveManager.DefaultName .. "')",
		Placeholder = "my-config",
	})

	local configDropdown = host:NewDropdown({
		Name = "Saved configs",
		Description = "Picking one fills the name box",
		Options = SaveManager:GetConfigs(),
		Callback = function(name)
			nameInput:Set(name)
		end,
	})

	local function currentName()
		local text = nameInput:Get():gsub("^%s+", ""):gsub("%s+$", "")
		return text ~= "" and text or nil
	end

	local function refresh()
		configDropdown:SetOptions(SaveManager:GetConfigs())
	end

	host:NewButton({
		Name = "Save config",
		Description = "Writes every flagged element + the active theme",
		Callback = function()
			if SaveManager:Save(currentName()) then
				refresh()
			end
		end,
	})

	host:NewButton({
		Name = "Load config",
		Callback = function()
			SaveManager:Load(currentName())
		end,
	})

	host:NewButton({
		Name = "Delete config",
		Callback = function()
			if SaveManager:Delete(currentName()) then
				refresh()
			end
		end,
	})

	host:NewButton({
		Name = "Refresh list",
		Callback = refresh,
	})

	return host
end

function Elements.Button:Create(container, settings)
	local Card, Label, Description, settings, Hover = Utility.ElementBase(container, settings)

	local Icon
	if settings.Icon then
		Icon = InstanceModule:Create("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Image = Icons.Get(settings.Icon),
			ImageColor3 = Fancy.Theme.SubText,
			Parent = Card,
		})
		Icon:SetAttribute("FancyImage", "SubText")
		if Description then
			Description.Size = UDim2.new(1, -34, 0, 14)
		end
	end

	local Click = InstanceModule:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	Click.MouseEnter:Connect(function()
		Utility.Tween(Card, 0.15, { BackgroundTransparency = 0.15 })
		if Icon then
			Utility.Tween(Icon, 0.15, { ImageColor3 = Fancy.Theme.Text })
		end
	end)

	Click.MouseLeave:Connect(function()
		Utility.Tween(Card, 0.2, { BackgroundTransparency = 0.35 })
		if Icon then
			Utility.Tween(Icon, 0.2, { ImageColor3 = Fancy.Theme.SubText })
		end
	end)

	Click.MouseButton1Down:Connect(function()
		Utility.Tween(Hover, 0.06, { BackgroundTransparency = 0.93 })
	end)

	Click.MouseButton1Up:Connect(function()
		Utility.Tween(Hover, 0.12, { BackgroundTransparency = 0.965 })
	end)

	Click.Activated:Connect(function()
		Utility.SafeCallback(settings.Callback)
	end)

	local Button = {}

	function Button:SetText(text)
		Label.Text = tostring(text or "")
	end

	function Button:SetIcon(name)
		if Icon then Icon.Image = Icons.Get(name) end
	end

	function Button:SetDescription(text)
		if Description then Description.Text = tostring(text or "") end
	end

	function Button:SetCallback(callback)
		settings.Callback = callback
	end

	function Button:Fire()
		Utility.SafeCallback(settings.Callback)
	end

	Button.Instance = Card
	return Button
end

function Elements.Dropdown:Create(container, settings)
	local Card, Label, Description, settings = Utility.ElementBase(container, settings)
	Card.ClipsDescendants = true
	local baseHeight = Card.Size.Y.Offset

	Label.Size = UDim2.new(1, -140, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(1, -140, 0, 14)
	end

	local options = (typeof(settings.Options) == "table" and settings.Options) or {}
	local selected = settings.Default or settings.Value
	local expanded = false

	local Chip = InstanceModule:Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0, baseHeight / 2),
		Size = UDim2.fromOffset(124, 24),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Chip:SetAttribute("FancyBackground", "Secondary.1")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Chip })

	local ValueLabel = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -28, 1, 0),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = selected ~= nil and tostring(selected) or "Select...",
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Chip,
	})
	ValueLabel:SetAttribute("FancyText", "SubText")

	local Chevron = InstanceModule:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Image = Icons.Get("chevron-down"),
		ImageColor3 = Fancy.Theme.SubText,
		Parent = Chip,
	})
	Chevron:SetAttribute("FancyImage", "SubText")

	local List = InstanceModule:Create("ScrollingFrame", {
		Position = UDim2.new(0, 6, 0, baseHeight),
		Size = UDim2.new(1, -12, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Fancy.Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = Card,
	})
	List:SetAttribute("FancyScrollBar", "Accent")
	InstanceModule:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = List,
	})

	local Dropdown = {}

	local function rebuild()
		for _, child in List:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for index, option in options do
			local Option = InstanceModule:Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = Fancy.Theme.Secondary[1],
				BackgroundTransparency = option == selected and 0.75 or 1,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				LayoutOrder = index,
				Parent = List,
			})
			Option:SetAttribute("FancyBackground", "Secondary.1")
			InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Option })

			InstanceModule:Create("TextLabel", {
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(1, -30, 1, 0),
				BackgroundTransparency = 1,
				Font = Fancy.Theme.Font,
				Text = tostring(option),
				TextSize = 12,
				TextColor3 = option == selected and Fancy.Theme.Text or Fancy.Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = Option,
			}):SetAttribute("FancyText", option == selected and "Text" or "SubText")

			if option == selected then
				local Check = InstanceModule:Create("ImageLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),
					BackgroundTransparency = 1,
					Image = Icons.Get("check"),
					ImageColor3 = Fancy.Theme.Accent,
					Parent = Option,
				})
				Check:SetAttribute("FancyImage", "Accent")
			end

			Option.MouseEnter:Connect(function()
				if option ~= selected then
					Utility.Tween(Option, 0.15, { BackgroundTransparency = 0.5 })
				end
			end)
			Option.MouseLeave:Connect(function()
				if option ~= selected then
					Utility.Tween(Option, 0.2, { BackgroundTransparency = 1 })
				end
			end)
			Option.Activated:Connect(function()
				Dropdown:Set(option)
				Dropdown:SetExpanded(false)
			end)
		end
	end

	function Dropdown:SetExpanded(state)
		expanded = state == true
		local visibleCount = math.clamp(#options, 0, 6)
		local listHeight = math.max(visibleCount * 24 + math.max(visibleCount - 1, 0) * 2, 0)

		if expanded then
			List.Size = UDim2.new(1, -12, 0, listHeight)
			rebuild()
			List.Visible = true
			Utility.Tween(Card, 0.25, { Size = UDim2.new(1, 0, 0, baseHeight + 6 + listHeight + 4) })
			Utility.Tween(Chevron, 0.25, { Rotation = 180 })
		else
			Utility.Tween(Chevron, 0.25, { Rotation = 0 })
			Utility.Tween(Card, 0.25, { Size = UDim2.new(1, 0, 0, baseHeight) })
			task.delay(0.25, function()
				if not expanded then
					List.Visible = false
				end
			end)
		end
	end

	function Dropdown:Set(option, silent)
		selected = option
		ValueLabel.Text = selected ~= nil and tostring(selected) or "Select..."
		if expanded then
			rebuild()
		end
		if not silent then
			Utility.SafeCallback(settings.Callback, selected)
		end
	end

	function Dropdown:Get()
		return selected
	end

	function Dropdown:SetOptions(newOptions)
		options = (typeof(newOptions) == "table" and newOptions) or {}
		if selected ~= nil then
			local found = false
			for _, option in options do
				if option == selected then
					found = true
					break
				end
			end
			if not found then
				selected = nil
				ValueLabel.Text = "Select..."
			end
		end
		if expanded then
			rebuild()
		end
	end

	function Dropdown:SetCallback(callback)
		settings.Callback = callback
	end

	Chip.Activated:Connect(function()
		Dropdown:SetExpanded(not expanded)
	end)

	if settings.Flag then
		SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Dropdown:Get()
			end,
			Set = function(value)
				Dropdown:Set(value)
			end
		})
	end

	Dropdown.Instance = Card
	return Dropdown
end

function Elements.Input:Create(container, settings)
	local Card, Label, Description, settings = Utility.ElementBase(container, settings)

	Label.Size = UDim2.new(0.5, -10, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(0.5, -10, 0, 14)
	end

	local Box = InstanceModule:Create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.45, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = tostring(settings.Default or settings.Value or ""),
		PlaceholderText = settings.Placeholder or "Type here...",
		TextColor3 = Fancy.Theme.Text,
		PlaceholderColor3 = Fancy.Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = settings.ClearOnFocus == true,
		Parent = Card,
	})
	Box:SetAttribute("FancyText", "Text")

	local Underline = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Fancy.Theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Box,
	})
	Underline:SetAttribute("FancyBackground", "Accent")

	Box.Focused:Connect(function()
		Utility.Tween(Underline, 0.2, { BackgroundTransparency = 0 })
	end)

	Box.FocusLost:Connect(function(enterPressed)
		Utility.Tween(Underline, 0.2, { BackgroundTransparency = 1 })
		if enterPressed or not settings.EnterOnly then
			Utility.SafeCallback(settings.Callback, Box.Text)
		end
	end)

	local Input = {}

	function Input:Set(text)
		Box.Text = tostring(text or "")
	end

	function Input:Get()
		return Box.Text
	end

	function Input:SetPlaceholder(text)
		Box.PlaceholderText = tostring(text or "")
	end

	function Input:SetCallback(callback)
		settings.Callback = callback
	end

	if settings.Flag then
		SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Input:Get()
			end,
			Set = function(value)
				Input:Set(value)
			end
		})
	end

	Input.Instance = Card
	Input.Box = Box
	return Input
end

function Elements.Keybind:Create(container, settings)
	local Card, Label, Description, settings = Utility.ElementBase(container, settings)
	if Description then
		Description.Size = UDim2.new(1, -80, 0, 14)
	end

	local key = settings.Default
	if typeof(key) == "string" then
		key = Enum.KeyCode[key]
	end

	local Chip = InstanceModule:Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(64, 24),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		Font = Fancy.Theme.Font,
		Text = key and key.Name or "None",
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Chip:SetAttribute("FancyBackground", "Secondary.1")
	Chip:SetAttribute("FancyText", "SubText")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Chip })

	local Keybind = {}
	local listening = false
	local held = {}

	local function setListening(state)
		listening = state
		if state then
			Chip.Text = "..."
			Chip.TextColor3 = Fancy.Theme.Accent
		else
			Chip.Text = key and key.Name or "None"
			Chip.TextColor3 = Fancy.Theme.SubText
		end
	end

	local beganConnection
	local endedConnection

	local function disconnect()
		beganConnection:Disconnect()
		endedConnection:Disconnect()
	end

	beganConnection = Services.UserInputService.InputBegan:Connect(function(input, processed)
		if not Card.Parent then
			disconnect()
			return
		end

		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					Keybind:Set(input.KeyCode)
				end
				setListening(false)
			end
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if held[input.KeyCode] then
				return
			end
			held[input.KeyCode] = true
		end

		if processed then return end
		if key and input.KeyCode == key then
			Utility.SafeCallback(settings.OnPressed, key)
		end
	end)

	endedConnection = Services.UserInputService.InputEnded:Connect(function(input)
		if not Card.Parent then
			disconnect()
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			held[input.KeyCode] = nil
		end
	end)

	Chip.MouseButton1Click:Connect(function()
		setListening(not listening)
	end)

	function Keybind:Set(keyCode, silent)
		if typeof(keyCode) == "string" then
			keyCode = Enum.KeyCode[keyCode]
		end
		if keyCode ~= nil and (typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode) then
			warn("[Fancy] Keybind:Set expects an Enum.KeyCode (or its name)")
			return
		end
		key = keyCode
		if not listening then
			Chip.Text = key and key.Name or "None"
		end
		if not silent then
			Utility.SafeCallback(settings.Callback, key)
		end
	end

	function Keybind:Get()
		return key
	end

	function Keybind:SetCallback(callback)
		settings.Callback = callback
	end

	function Keybind:SetOnPressed(callback)
		settings.OnPressed = callback
	end

	if settings.Flag then
		SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				local bound = Keybind:Get()
				return bound and bound.Name or nil
			end,
			Set = function(value, silent)
				Keybind:Set(value, silent)
			end
		})
	end

	Keybind.Instance = Card
	return Keybind
end

function Elements.Paragraph:Create(container, settings)
	settings = typeof(settings) == "table" and settings or {}

	local Card = InstanceModule:Create("Frame", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Fancy.Theme.Secondary[2],
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = container,
	})
	Card:SetAttribute("FancyBackground", "Secondary.2")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Card })

	local stroke = InstanceModule:Create("UIStroke", {
		Color = Fancy.Theme.Stroke,
		Transparency = Fancy.Theme.StrokeTransparency or 0.92,
		Parent = Card,
	})
	stroke:SetAttribute("FancyStroke", "Stroke")

	InstanceModule:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Card,
	})
	InstanceModule:Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = Card,
	})

	local Title = InstanceModule:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.TitleFont,
		Text = tostring(settings.Title or settings.Name or "Paragraph"),
		TextSize = 13,
		TextColor3 = Fancy.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Card,
	})
	Title:SetAttribute("FancyText", "Text")

	local Text = InstanceModule:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Fancy.Theme.Font,
		Text = tostring(settings.Text or settings.Content or ""),
		TextSize = 12,
		TextColor3 = Fancy.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = Card,
	})
	Text:SetAttribute("FancyText", "SubText")

	local Paragraph = {}

	function Paragraph:Set(title, body)
		if title ~= nil then Title.Text = tostring(title) end
		if body ~= nil then Text.Text = tostring(body) end
	end

	Paragraph.Instance = Card
	return Paragraph
end

function Elements.Section:Create(container, settings)
	settings = typeof(settings) == "table" and settings or {}

	local Theme = Fancy.Theme
	local Section = {}

	local Frame = InstanceModule:Create("Frame", {
		Name = "Section_" .. tostring(settings.Name or "Section"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = container,
	})

	local Bar = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 5),
		Size = UDim2.new(0, 2, 0, 11),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = Frame,
	})
	Bar:SetAttribute("FancyBackground", "Accent")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })

	local Header = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 9, 0, 2),
		Size = UDim2.new(1, -9, 0, 16),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = string.upper(tostring(settings.Name or "Section")),
		TextSize = 11,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Frame,
	})
	Header:SetAttribute("FancyText", "SubText")

	local Container = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Frame,
	})
	InstanceModule:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Container,
	})

	function Section:NewSection(props)
		return Elements.Section:Create(Container, props)
	end

	local elements = {
		NewButton = "Button",
		NewToggle = "Toggle",
		NewSlider = "Slider",
		NewInput = "Input",
		NewParagraph = "Paragraph",
		NewKeybind = "Keybind",
		NewDropdown = "Dropdown",
	}

	for methodName, elementName in elements do
		Section[methodName] = function(_, props)
			return Elements[elementName]:Create(Container, props)
		end
	end

	function Section:SetTitle(text)
		Header.Text = string.upper(tostring(text or "Section"))
	end

	Section.Instance = Frame
	Section.Container = Container
	return Section
end

function Elements.Slider:Create(container, settings)
	settings = typeof(settings) == "table" and settings or {}

	local hasDescription = typeof(settings.Description) == "string" and settings.Description ~= ""
	settings.Height = hasDescription and 74 or 58

	local Step = tonumber(settings.Step)
	if Step and Step <= 0 then
		Step = nil
	end

	local Card, Label, Description, settings = Utility.ElementBase(container, settings)
	Label.Size = UDim2.new(1, -100, 0, Label.Size.Y.Offset)
	if Description then
		Description.Size = UDim2.new(1, -100, 0, 14)
	end

	local Min = tonumber(settings.Min) or 0
	local Max = tonumber(settings.Max) or 100
	local Precision = math.clamp(tonumber(settings.Precision or settings.Decimals) or 0, 0, 4)
	local Suffix = typeof(settings.Suffix) == "string" and settings.Suffix or ""

	local ValueLabel = InstanceModule:Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, hasDescription and 8 or 0),
		Size = UDim2.new(0, 90, 0, hasDescription and 14 or 34),
		BackgroundTransparency = 1,
		Font = Fancy.Theme.TitleFont,
		Text = "0",
		TextSize = 13,
		TextColor3 = Fancy.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = Card,
	})
	ValueLabel:SetAttribute("FancyText", "Text")

	local Track = InstanceModule:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -12),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = Card,
	})
	Track:SetAttribute("FancyBackground", "Secondary.1")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

	local Fill = InstanceModule:Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Fancy.Theme.Accent,
		BorderSizePixel = 0,
		Parent = Track,
	})
	Fill:SetAttribute("FancyBackground", "Accent")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

	local Knob = InstanceModule:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = Track,
	})
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
	local KnobScale = InstanceModule:Create("UIScale", { Parent = Knob })

	local Slider = {}
	local value = Min
	local dragging = false

	local function formatNumber(v)
		local text
		if Precision <= 0 then
			text = Utility.Comma(math.floor(v + 0.5))
		else
			text = string.format("%." .. Precision .. "f", v)
		end
		return text .. Suffix
	end

	local function render(instant)
		local percent = (Max == Min) and 0 or (value - Min) / (Max - Min)
		if instant or dragging then
			Fill.Size = UDim2.fromScale(percent, 1)
			Knob.Position = UDim2.new(percent, 0, 0.5, 0)
		else
			Utility.Tween(Fill, 0.08, { Size = UDim2.fromScale(percent, 1) })
			Utility.Tween(Knob, 0.08, { Position = UDim2.new(percent, 0, 0.5, 0) })
		end
		ValueLabel.Text = formatNumber(value)
	end

	function Slider:Set(newValue, silent)
		newValue = tonumber(newValue) or value
		if Step then
			newValue = Min + math.floor((newValue - Min) / Step + 0.5) * Step
		end
		newValue = math.clamp(newValue, Min, Max)
		if Precision <= 0 then
			newValue = math.floor(newValue + 0.5)
		else
			local factor = 10 ^ Precision
			newValue = math.floor(newValue * factor + 0.5) / factor
		end
		value = newValue
		render()
		if not silent then
			Utility.SafeCallback(settings.Callback, value)
		end
	end

	function Slider:Get()
		return value
	end

	function Slider:SetCallback(callback)
		settings.Callback = callback
	end

	function Slider:SetRange(min, max, silent)
		Min = tonumber(min) or Min
		Max = tonumber(max) or Max
		Slider:Set(value, silent)
	end

	local Hitbox = InstanceModule:Create("TextButton", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -4),
		Size = UDim2.new(1, -20, 0, 24),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	local function updateFromX(x)
		local relative = math.clamp((x - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
		Slider:Set(Min + (Max - Min) * relative)
	end

	Hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			ValueLabel.TextColor3 = Fancy.Theme.Accent
			Utility.Tween(KnobScale, 0.1, { Scale = 1.3 })
			updateFromX(input.Position.X)
		end
	end)

	local endedConnection
	local changedConnection

	local function disconnect()
		endedConnection:Disconnect()
		changedConnection:Disconnect()
	end

	endedConnection = Services.UserInputService.InputEnded:Connect(function(input)
		if not Card.Parent then disconnect() return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			ValueLabel.TextColor3 = Fancy.Theme.Text
			Utility.Tween(KnobScale, 0.18, { Scale = 1 })
		end
	end)

	changedConnection = Services.UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if not Card.Parent then disconnect() return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromX(input.Position.X)
		end
	end)

	if settings.Flag then
		SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Slider:Get()
			end,
			Set = function(value)
				Slider:Set(value)
			end
		})
	end

	Slider:Set(settings.Default or settings.Value or Min, true)
	Slider.Instance = Card
	return Slider
end

function Elements.Tab:Create(settings)
	if not Fancy.Window or not Fancy.Refs then return nil end
	settings = typeof(settings) == "table" and settings or {}

	local Theme = Fancy.Theme
	local Refs = Fancy.Refs

	local Tab = {}
	Tab.Settings = settings

	local Button = InstanceModule:Create("TextButton", {
		Name = "Tab_" .. tostring(settings.Name or "Tab"),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = #Fancy.Tabs + 1,
		Parent = Refs.TabList,
	})

	local Fill = InstanceModule:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Secondary[2],
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = Button,
	})
	Fill:SetAttribute("FancyBackground", "Secondary.2")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Fill })

	local Icon = InstanceModule:Create("ImageLabel", {
		Position = UDim2.new(0, 14, 0.5, -8),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		Image = Icons.Get(settings.Icon),
		ImageColor3 = Theme.SubText,
		Parent = Button,
	})
	Icon:SetAttribute("FancyImage", "SubText")

	local Label = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(1, -46, 1, 0),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = tostring(settings.Name or "Tab"),
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Button,
	})
	Label:SetAttribute("FancyText", "SubText")

	local Indicator
	if Refs.TabIndicator then
		Indicator = Refs.TabIndicator
	else
		Indicator = InstanceModule:Create("Frame", {
			Name = "TabIndicator",
			Position = UDim2.new(0, 4, 0.5, -8),
			Size = UDim2.new(0, 3, 0, 16),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = Button,
		})
		Indicator:SetAttribute("FancyBackground", "Accent")
		InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Indicator })
		Refs.TabIndicator = Indicator
	end

	local Page = InstanceModule:Create("ScrollingFrame", {
		Name = "Page",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = Refs.PageHolder,
	})
	Page:SetAttribute("FancyScrollBar", "Accent")
	InstanceModule:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Page,
	})
	InstanceModule:Create("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 4),
		Parent = Page,
	})

	function Tab:Select()
		if Fancy.SelectedTab == Tab then return end
		local previous = Fancy.SelectedTab
		Fancy.SelectedTab = Tab
		if previous then previous:Deselect() end

		local theme = Fancy.Theme

		if Indicator.Parent ~= Button then
			local old = Indicator.AbsolutePosition
			Indicator.Parent = Button
			Indicator.Position = UDim2.fromOffset(
				old.X - Button.AbsolutePosition.X,
				old.Y - Button.AbsolutePosition.Y
			)
		end
		Indicator.BackgroundTransparency = 0
		Utility.Tween(Indicator, 0.28, { Position = UDim2.new(0, 4, 0.5, -8) }, Enum.EasingStyle.Quart)

		Utility.Tween(Fill, 0.25, { BackgroundTransparency = 0.72 })
		Utility.Tween(Icon, 0.22, { ImageColor3 = theme.Text, Position = UDim2.new(0, 16, 0.5, -8) })
		Utility.Tween(Label, 0.22, { TextColor3 = theme.Text, Position = UDim2.new(0, 40, 0, 0) })

		Page.Visible = true
		Page.Position = UDim2.new(0, 10, 0, 0)
		Utility.Tween(Page, 0.22, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quart)

		Utility.Tween(Refs.PageTitle, 0.09, { TextTransparency = 1 })
		task.delay(0.1, function()
			if Fancy.SelectedTab == Tab and Refs.PageTitle and Refs.PageTitle.Parent then
				Refs.PageTitle.Text = tostring(settings.Name or "Tab")
				Utility.Tween(Refs.PageTitle, 0.14, { TextTransparency = 0 })
			end
		end)
	end

	function Tab:Deselect()
		local theme = Fancy.Theme
		Utility.Tween(Fill, 0.25, { BackgroundTransparency = 1 })
		Utility.Tween(Icon, 0.22, { ImageColor3 = theme.SubText, Position = UDim2.new(0, 14, 0.5, -8) })
		Utility.Tween(Label, 0.22, { TextColor3 = theme.SubText, Position = UDim2.new(0, 38, 0, 0) })
		Page.Visible = false
	end

	function Tab:SetTitle(text)
		local value = tostring(text or "Tab")
		settings.Name = value
		Label.Text = value
		if Fancy.SelectedTab == Tab then
			Refs.PageTitle.Text = value
		end
	end

	Button.MouseButton1Click:Connect(function()
		Tab:Select()
	end)

	Button.MouseEnter:Connect(function()
		if Fancy.SelectedTab ~= Tab then
			Utility.Tween(Fill, 0.15, { BackgroundTransparency = 0.9 })
		end
	end)

	Button.MouseLeave:Connect(function()
		if Fancy.SelectedTab ~= Tab then
			Utility.Tween(Fill, 0.2, { BackgroundTransparency = 1 })
		end
	end)

	function Tab:NewSection(props)
		return Elements.Section:Create(Page, props)
	end

	local elements = {
		NewButton = "Button",
		NewToggle = "Toggle",
		NewSlider = "Slider",
		NewInput = "Input",
		NewParagraph = "Paragraph",
		NewKeybind = "Keybind",
		NewDropdown = "Dropdown",
	}

	for methodName, elementName in elements do
		Tab[methodName] = function(_, props)
			return Elements[elementName]:Create(Page, props)
		end
	end

	Tab.Button = Button
	Tab.Page = Page

	table.insert(Fancy.Tabs, Tab)
	if #Fancy.Tabs == 1 then
		Tab:Select()
	end

	return Tab
end

function Elements.Toggle:Create(container, settings)
	local Card, Label, Description, settings = Utility.ElementBase(container, settings)
	if Description then
		Description.Size = UDim2.new(1, -60, 0, 14)
	end

	local Click = InstanceModule:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = Card,
	})

	local Track = InstanceModule:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(36, 18),
		BackgroundColor3 = Fancy.Theme.Secondary[1],
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = Card,
	})
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

	local Knob = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 2, 0.5, -7),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = Track,
	})
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

	local KnobScale = InstanceModule:Create("UIScale", { Parent = Knob })

	local Toggle = {}
	local state = settings.Default or settings.Value or false

	local function render(instant)
		local time = instant and 0 or 0.25
		local theme = Fancy.Theme
		Track:SetAttribute("FancyBackground", state and "Accent" or "Secondary.1")
		Utility.Tween(Track, time, {
			BackgroundColor3 = state and theme.Accent or theme.Secondary[1],
		})
		Utility.Tween(Knob, time, {
			Position = UDim2.new(0, state and 20 or 2, 0.5, -7),
		})
	end

	function Toggle:Set(value, silent)
		state = value == true
		render()
		if not silent then
			Utility.SafeCallback(settings.Callback, state)
		end
	end

	function Toggle:Get()
		return state
	end

	function Toggle:SetCallback(callback)
		settings.Callback = callback
	end

	Click.MouseEnter:Connect(function()
		Utility.Tween(Card, 0.15, { BackgroundTransparency = 0.22 })
	end)
	Click.MouseLeave:Connect(function()
		Utility.Tween(Card, 0.2, { BackgroundTransparency = 0.35 })
	end)

	Click.Activated:Connect(function()
		Toggle:Set(not state)
		Utility.Tween(KnobScale, 0.07, { Scale = 1.2 })
		task.delay(0.1, function()
			Utility.Tween(KnobScale, 0.2, { Scale = 1 })
		end)
	end)

	if settings.Flag then
		SaveManager.Register(settings.Flag, {
			Instance = Card,
			Get = function()
				return Toggle:Get()
			end,
			Set = function(value)
				Toggle:Set(value)
			end
		})
	end

	render(true)
	Toggle.Instance = Card
	return Toggle
end

local function Reflow()
	local y = 14
	for _, bar in Fancy.Topbars do
		if bar.Instance and bar.Instance.Parent and not bar.Dragged then
			bar.Instance.Position = UDim2.new(0.5, 0, 0, y)
			y = y + (bar.Height or 28) + 6
		end
	end
end

function Elements.Topbar:Create(settings)
	local Host = Fancy.TopbarUI or Fancy.MainUI
	if not Host then return nil end
	settings = typeof(settings) == "table" and settings or {}

	local Theme = Fancy.Theme or Themes.Default
	Fancy.Topbars = Fancy.Topbars or {}

	local TextSize = math.clamp(tonumber(settings.TextSize) or 12, 8, 20)
	local Height = TextSize + 16

	local Pill = InstanceModule:Create("Frame", {
		Name = "Topbar_" .. tostring(settings.Name or #Fancy.Topbars + 1),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(0, Height),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Primary,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = Host
	})
	Pill:SetAttribute("FancyBackground", "Primary")

	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pill })

	do
		local stroke = InstanceModule:Create("UIStroke", {
			Color = Theme.Stroke,
			Transparency = Theme.StrokeTransparency or 0.92,
			Parent = Pill,
		})
		stroke:SetAttribute("FancyStroke", "Stroke")
	end

	InstanceModule:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Pill,
	})

	InstanceModule:Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = Pill,
	})

	local Dot = InstanceModule:Create("Frame", {
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = settings.Color or Theme.Accent,
		BorderSizePixel = 0,
		Visible = not settings.Icon,
		LayoutOrder = 1,
		Parent = Pill,
	})
	if not settings.Color then
		Dot:SetAttribute("FancyBackground", "Accent")
	end
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

	local Icon = InstanceModule:Create("ImageLabel", {
		Size = UDim2.fromOffset(TextSize + 2, TextSize + 2),
		BackgroundTransparency = 1,
		Image = Icons.Get(settings.Icon),
		ImageColor3 = settings.Color or Theme.Accent,
		Visible = settings.Icon ~= nil,
		LayoutOrder = 1,
		Parent = Pill,
	})
	if not settings.Color then
		Icon:SetAttribute("FancyImage", "Accent")
	end

	local Label = InstanceModule:Create("TextLabel", {
		Size = UDim2.fromOffset(0, TextSize + 4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = settings.Font or Theme.Font,
		Text = tostring(settings.Text or settings.Default or "Topbar"),
		TextSize = TextSize,
		TextColor3 = Theme.Text,
		RichText = settings.RichText == true,
		LayoutOrder = 2,
		Parent = Pill,
	})
	Label:SetAttribute("FancyText", "Text")

	local Topbar = {}
	Topbar.Instance = Pill
	Topbar.Height = Height
	Topbar.Dragged = false
	Topbar.Persistent = settings.Persistent == false

	local connections = {}
	local dragging = false
	local dragStart, startPos

	Pill.InputBegan:Connect(function(input)
		if not Pill.Parent then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Pill.Position
		end
	end)

	table.insert(connections, Services.UserInputService.InputEnded:Connect(function(input)
		if not Pill.Parent then
			for _, connection in connections do
				connection:Disconnect()
			end
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	table.insert(connections, Services.UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if not Pill.Parent then
			for _, connection in connections do
				connection:Disconnect()
			end
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if not Topbar.Dragged and (math.abs(delta.X) > 3 or math.abs(delta.Y) > 3) then
				Topbar.Dragged = true
				Pill.ZIndex = 12
			end
			if Topbar.Dragged then
				Pill.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end))

	Pill.MouseEnter:Connect(function()
		Utility.Tween(Pill, 0.15, { BackgroundTransparency = 0 })
	end)
	Pill.MouseLeave:Connect(function()
		Utility.Tween(Pill, 0.2, { BackgroundTransparency = 0.08 })
	end)

	function Topbar:SetText(text)
		Label.Text = tostring(text or "")
	end

	function Topbar:GetText()
		return Label.Text
	end

	function Topbar:SetIcon(name)
		Icon.Image = Icons.Get(name)
		Icon.Visible = true
		Dot.Visible = false
	end

	function Topbar:SetColor(color)
		if typeof(color) ~= "Color3" then return end
		Dot:SetAttribute("FancyBackground", nil)
		Icon:SetAttribute("FancyImage", nil)
		Dot.BackgroundColor3 = color
		Icon.ImageColor3 = color
	end

	function Topbar:Reset()
		Topbar.Dragged = false
		Pill.ZIndex = 10
		Reflow()
	end

	function Topbar:Destroy()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)

		local index = table.find(Fancy.Topbars, Topbar)
		if index then
			table.remove(Fancy.Topbars, index)
		end

		Pill:Destroy()
		Reflow()
	end

	table.insert(Fancy.Topbars, Topbar)
	Reflow()

	do
		local target = Pill.Position
		Pill.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset - 8)
		Utility.Tween(Pill, 0.25, { Position = target }, Enum.EasingStyle.Quart)
	end

	return Topbar
end

function Elements.Window:Create(default)
	if not Fancy.MainUI or Fancy.Window then return nil end

	local ThemeName = Fancy.WindowSettings.Theme or default.Theme or "Default"
	local Theme = Themes[ThemeName] or Themes.Default
	Fancy.Theme = Theme
	Fancy.ThemeName = ThemeName

	local function measureTitle(text)
		return Services.TextService:GetTextSize(tostring(text or ""), 14, Theme.TitleFont, Vector2.new(1000, 100)).X
	end

	local Center = Fancy.WindowSettings.Center
	if Center == nil then
		Center = default.Center
	end
	if Center == nil then
		Center = true
	end

	local Resizeable = Fancy.WindowSettings.Resizeable
	if Resizeable == nil then
		Resizeable = default.Resizeable
	end
	if Resizeable == nil then
		Resizeable = true
	end

	local UserInputService = Services.UserInputService
	local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled

	local function getViewport()
		local camera = Services.Workspace.CurrentCamera
		return camera and camera.ViewportSize or Vector2.new(1920, 1080)
	end

	local MARGIN = isMobile and 8 or 24
	local SidebarWidth = isMobile and 148 or 178

	local viewport = getViewport()
	local availX = math.max(viewport.X - MARGIN * 2, 200)
	local availY = math.max(viewport.Y - MARGIN * 2, 150)

	local Size = Utility.ResolveSize(Fancy.WindowSettings.Size or default.Size, 691, 457)
	if isMobile and Fancy.WindowSettings.Size == nil then
		Size = UDim2.fromOffset(math.floor(availX * 0.96), math.floor(availY * 0.92))
	end

	local width = math.min(Size.X.Offset, availX)
	local height = math.min(Size.Y.Offset, availY)
	Size = UDim2.fromOffset(width, height)

	local MinSize = Fancy.WindowSettings.MinSize or default.MinSize or Vector2.new(540, 350)
	local effMinX = math.min(MinSize.X, availX)
	local effMinY = math.min(MinSize.Y, availY)

	local Main = InstanceModule:Create("Frame", {
		Name = "Window",
		AnchorPoint = Center and Vector2.new(0.5, 0.5) or Vector2.zero,
		Position = Center and UDim2.fromScale(0.5, 0.5) or (Fancy.WindowSettings.Position or default.Position or UDim2.fromOffset(60, 60)),
		Size = Size,
		BackgroundColor3 = Theme.Primary,
		BorderSizePixel = 0,
		Parent = Fancy.MainUI,
	})
	Main:SetAttribute("FancyBackground", "Primary")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })

	do
		local stroke = InstanceModule:Create("UIStroke", {
			Color = Theme.Stroke,
			Transparency = Theme.StrokeTransparency or 0.92,
			Parent = Main,
		})
		stroke:SetAttribute("FancyStroke", "Stroke")
	end

	local Scale = InstanceModule:Create("UIScale", { Scale = 0.97, Parent = Main })
	local Shadow = nil
	if Fancy.WindowSettings.Shadow then
		Shadow = InstanceModule:Create("ImageLabel", {
			Name = "Shadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 60, 1, 60),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6014261993",
			ImageColor3 = Theme.Shadow or Color3.new(0, 0, 0),
			ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			ZIndex = 0,
			Parent = Main,
		})
	end

	local Sheen = InstanceModule:Create("Frame", {
		Name = "Sheen",
		Size = UDim2.new(1, 0, 0, 90),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = Main,
	})
	InstanceModule:Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.955),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 90,
		Parent = Sheen,
	})

	local Topbar = InstanceModule:Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Active = true,
		Parent = Main,
	})

	local Window = {}
	local collapsed = false
	local maximized = false
	local savedBounds = nil
	local fullSize = Vector2.new(Size.X.Offset, Size.Y.Offset)
	local connections = {}
	local Grip

	local LIGHT_SIZE = 12
	local LIGHT_PITCH = 20
	local LIGHTS_X = 14
	local LIGHTS_IDLE = Color3.fromRGB(72, 74, 78)
	local GLYPH_COLOR = Color3.fromRGB(43, 43, 46)

	local lights = {}
	local deactivateToken = 0

	local function setLightsActive(active)
		for _, light in lights do
			Utility.Tween(light.Button, 0.15, {
				BackgroundColor3 = active and light.Color or LIGHTS_IDLE,
			})
			for _, bar in light.Bars do
				Utility.Tween(bar, 0.15, { BackgroundTransparency = active and 0 or 1 })
			end
		end
	end

	local function addBar(parent, size, rotation)
		return InstanceModule:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = size,
			Rotation = rotation or 0,
			BackgroundColor3 = GLYPH_COLOR,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = parent,
		})
	end

	local function TrafficLight(name, color, order, onClick)
		local Button = InstanceModule:Create("TextButton", {
			Name = name,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, LIGHTS_X + (order - 1) * LIGHT_PITCH, 0.5, 0),
			Size = UDim2.fromOffset(LIGHT_SIZE, LIGHT_SIZE),
			BackgroundColor3 = LIGHTS_IDLE,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = Topbar,
		})
		InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Button })

		local bars = {}
		if name == "Close" then
			table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 45))
			table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), -45))
		elseif name == "Minimize" then
			table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 0))
		elseif name == "Zoom" then
			table.insert(bars, addBar(Button, UDim2.fromOffset(7, 2), 0))
			table.insert(bars, addBar(Button, UDim2.fromOffset(2, 7), 0))
		end

		table.insert(lights, { Button = Button, Bars = bars, Color = color })

		Button.MouseEnter:Connect(function()
			deactivateToken = deactivateToken + 1
			setLightsActive(true)
		end)
		Button.MouseLeave:Connect(function()
			deactivateToken = deactivateToken + 1
			local token = deactivateToken
			task.delay(0.08, function()
				if token == deactivateToken then
					setLightsActive(false)
				end
			end)
		end)
		Button.Activated:Connect(onClick)

		return Button
	end

	TrafficLight("Close", Theme.Danger, 1, function()
		Window:Destroy()
	end)
	
	TrafficLight("Minimize", Theme.Warning, 2, function()
		Window:Collapse()
	end)
	
	TrafficLight("Zoom", Theme.Success, 3, function()
		Window:ToggleMaximize()
	end)

	local hasIcon = typeof(Fancy.WindowSettings.Icon) == "string" and #Fancy.WindowSettings.Icon > 0
	local Logo = InstanceModule:Create("ImageLabel", {
		Name = "Logo",
		Position = UDim2.new(0, 78, 0.5, -9),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Image = Icons.Get(Fancy.WindowSettings.Icon or "sparkles"),
		ImageColor3 = Theme.Accent,
		Visible = hasIcon,
		Parent = Topbar,
	})
	Logo:SetAttribute("FancyImage", "Accent")

	local Title = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, hasIcon and 104 or 78, 0.5, -9),
		Size = UDim2.new(0, hasIcon and 240 or 266, 0, 18),
		BackgroundTransparency = 1,
		Font = Theme.TitleFont,
		Text = Fancy.WindowSettings.Title or default.Title or "Fancy UI",
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Topbar,
	})
	Title:SetAttribute("FancyText", "Text")

	local PageTitle = InstanceModule:Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.new(0, 160, 0, 16),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "",
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Topbar,
	})
	PageTitle:SetAttribute("FancyText", "SubText")

	local Version = typeof(Fancy.WindowSettings.Version) == "string" and Fancy.WindowSettings.Version or ""
	local VersionLabel = nil
	if #Version > 0 then
		VersionLabel = InstanceModule:Create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 27),
			Size = UDim2.new(0, 160, 0, 12),
			BackgroundTransparency = 1,
			Font = Theme.Font,
			Text = Version,
			TextSize = 10,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Topbar,
		})
		VersionLabel:SetAttribute("FancyText", "SubText")
	end

	local function setChromeVisible(state)
		for _, light in lights do
			light.Button.Visible = state
		end
		PageTitle.Visible = state
		if VersionLabel then
			VersionLabel.Visible = state
		end
	end

	local Body = InstanceModule:Create("Frame", {
		Name = "Body",
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Main,
	})

	local Sidebar = InstanceModule:Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, SidebarWidth, 1, 0),
		BackgroundColor3 = Theme.Secondary[1],
		BorderSizePixel = 0,
		Parent = Body,
	})
	Sidebar:SetAttribute("FancyBackground", "Secondary.1")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Sidebar })

	local Divider = InstanceModule:Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.93,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = Body,
	})
	Divider:SetAttribute("FancyBackground", "Stroke")

	local Search = InstanceModule:Create("TextBox", {
		Name = "Search",
		Position = UDim2.new(0, 8, 0, 10),
		Size = UDim2.new(1, -16, 0, 30),
		BackgroundColor3 = Theme.Secondary[2],
		BackgroundTransparency = 0.5,
		Font = Theme.Font,
		PlaceholderText = "Search tabs...",
		Text = "",
		TextSize = 12,
		TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
		Parent = Sidebar,
	})
	Search:SetAttribute("FancyBackground", "Secondary.2")
	Search:SetAttribute("FancyText", "Text")
	do
		InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Search })
		local searchStroke = InstanceModule:Create("UIStroke", {
			Color = Theme.Stroke,
			Transparency = 0.94,
			Parent = Search,
		})
		searchStroke:SetAttribute("FancyStroke", "Stroke")
		InstanceModule:Create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			Parent = Search,
		})
	end

	local NoResults = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 8, 0, 50),
		Size = UDim2.new(1, -16, 0, 16),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "No matching tabs",
		TextSize = 11,
		TextColor3 = Theme.SubText,
		Visible = false,
		Parent = Sidebar,
	})
	NoResults:SetAttribute("FancyText", "SubText")

	Search:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(tostring(Search.Text))
		local visible = 0
		for _, tab in Fancy.Tabs do
			if tab.Button and tab.Button.Parent then
				local match = query == "" or string.find(string.lower(tostring(tab.Settings.Name or "Tab")), query, 1, true) ~= nil
				tab.Button.Visible = match
				if match then
					visible = visible + 1
				end
			end
		end
		NoResults.Visible = query ~= "" and visible == 0
	end)

	local TabList = InstanceModule:Create("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.new(0, 8, 0, 48),
		Size = UDim2.new(1, -16, 1, -116),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = Sidebar,
	})
	TabList:SetAttribute("FancyScrollBar", "Accent")
	InstanceModule:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabList,
	})

	local Footer = InstanceModule:Create("Frame", {
		Name = "User",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 54),
		BackgroundColor3 = Theme.Secondary[2],
		BorderSizePixel = 0,
		Parent = Sidebar,
	})
	Footer:SetAttribute("FancyBackground", "Secondary.2")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Footer })

	local Avatar = InstanceModule:Create("ImageLabel", {
		Position = UDim2.new(0, 10, 0.5, -15),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Secondary[1],
		BorderSizePixel = 0,
		Parent = Footer,
	})
	Avatar:SetAttribute("FancyBackground", "Secondary.1")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
	do
		local ring = InstanceModule:Create("UIStroke", {
			Color = Theme.Accent,
			Transparency = 0.45,
			Thickness = 1,
			Parent = Avatar,
		})
		ring:SetAttribute("FancyStroke", "Accent")
	end

	local Pulse = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 31, 0, 33),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Theme.Success,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Parent = Footer,
	})
	Pulse:SetAttribute("FancyBackground", "Success")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Pulse })

	local Dot = InstanceModule:Create("Frame", {
		Position = UDim2.new(0, 33, 0, 35),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.Success,
		BorderSizePixel = 0,
		Parent = Footer,
	})
	Dot:SetAttribute("FancyBackground", "Success")
	InstanceModule:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })

	task.spawn(function()
		while Dot.Parent do
			Utility.Tween(Pulse, 0.9, { BackgroundTransparency = 0.85 })
			task.wait(0.9)
			if not Dot.Parent then break end
			Utility.Tween(Pulse, 0.9, { BackgroundTransparency = 0.45 })
			task.wait(0.9)
		end
	end)

	local Username = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 50, 0, 12),
		Size = UDim2.new(1, -58, 0, 14),
		BackgroundTransparency = 1,
		Font = Theme.TitleFont,
		Text = "Guest",
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Footer,
	})
	Username:SetAttribute("FancyText", "Text")

	local Subname = InstanceModule:Create("TextLabel", {
		Position = UDim2.new(0, 50, 1, -24),
		Size = UDim2.new(1, -58, 0, 12),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "@guest",
		TextSize = 10.5,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Footer,
	})
	Subname:SetAttribute("FancyText", "SubText")

	local LocalPlayer = Services.Players.LocalPlayer
	if LocalPlayer then
		Username.Text = LocalPlayer.DisplayName
		Subname.Text = "@" .. LocalPlayer.Name
		task.spawn(function()
			local ok, content = pcall(
				Services.Players.GetUserThumbnailAsync, Services.Players,
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
			if ok and Avatar.Parent then
				Avatar.Image = content
			end
		end)
	end

	local Content = InstanceModule:Create("Frame", {
		Name = "Content",
		Position = UDim2.new(0, SidebarWidth, 0, 0),
		Size = UDim2.new(1, -SidebarWidth, 1, 0),
		BackgroundTransparency = 1,
		Parent = Body,
	})

	local PageHolder = InstanceModule:Create("Frame", {
		Name = "Pages",
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		Parent = Content,
	})

	Fancy.Refs = {
		Topbar = Topbar,
		Title = Title,
		PageTitle = PageTitle,
		TabList = TabList,
		PageHolder = PageHolder,
		Sidebar = Sidebar,
		Content = Content,
		Body = Body,
	}
	Fancy.Window = Main

	local VISIBLE = isMobile and 0 or 60

	local function keepInBounds()
		local vp = getViewport()
		local size = Main.AbsoluteSize
		local pos = Main.AbsolutePosition

		local minX, maxX
		if size.X >= vp.X then
			minX = (vp.X - size.X) / 2
			maxX = minX
		else
			minX = isMobile and 0 or -(size.X - VISIBLE)
			maxX = isMobile and (vp.X - size.X) or (vp.X - VISIBLE)
		end

		local minY, maxY
		if size.Y >= vp.Y then
			minY = (vp.Y - size.Y) / 2
			maxY = minY
		else
			minY = isMobile and 0 or -(size.Y - VISIBLE)
			maxY = isMobile and (vp.Y - size.Y) or (vp.Y - VISIBLE)
		end

		local ox = 0
		if pos.X < minX then
			ox = minX - pos.X
		elseif pos.X > maxX then
			ox = maxX - pos.X
		end

		local oy = 0
		if pos.Y < minY then
			oy = minY - pos.Y
		elseif pos.Y > maxY then
			oy = maxY - pos.Y
		end

		if ox ~= 0 or oy ~= 0 then
			Main.Position = Main.Position + UDim2.fromOffset(ox, oy)
		end
	end

	Utility.MakeDraggable(Topbar, Main, function()
		return not maximized
	end, keepInBounds)

	local restorePress = nil
	Topbar.InputBegan:Connect(function(input)
		if collapsed
			and (input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch) then
			restorePress = input.Position
		end
	end)

	Topbar.InputEnded:Connect(function(input)
		if restorePress
			and (input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - restorePress
			restorePress = nil
			if math.abs(delta.X) < 6 and math.abs(delta.Y) < 6 then
				Window:Collapse(false)
			end
		end
	end)

	Utility.Tween(Scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Quart)
	if Shadow then
		Utility.Tween(Shadow, 0.35, { ImageTransparency = Theme.ShadowTransparency or 0.5 })
	end
	task.delay(0.3, keepInBounds)

	local COMPACT_START = 16
	local COMPACT_ICON_GAP = 26

	function Window:Collapse(state)
		local nextState = (state == nil) and not collapsed or state == true
		if nextState == collapsed then return end
		collapsed = nextState

		if collapsed then
			fullSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
			setChromeVisible(false)

			local iconShown = Logo.Visible
			local contentStart = iconShown and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
			local barWidth = contentStart + measureTitle(Title.Text) + COMPACT_START

			barWidth = math.max(barWidth, 90)
			barWidth = math.min(barWidth, fullSize.X)

			Logo.Position = UDim2.new(0, COMPACT_START, 0.5, -9)
			Title.Position = UDim2.new(0, contentStart, 0.5, -9)

			Utility.Tween(Main, 0.32, {
				Size = UDim2.fromOffset(barWidth, 44),
			}, Enum.EasingStyle.Quart)
		else
			setChromeVisible(true)

			Logo.Position = UDim2.new(0, 78, 0.5, -9)
			Title.Position = UDim2.new(0, Logo.Visible and 104 or 78, 0.5, -9)

			Utility.Tween(Main, 0.32, {
				Size = UDim2.fromOffset(fullSize.X, fullSize.Y),
			}, Enum.EasingStyle.Quart)
			task.delay(0.33, keepInBounds)
		end

		if Grip then
			Grip.Visible = not collapsed and not maximized
		end
	end

	function Window:IsCollapsed()
		return collapsed
	end

	function Window:ToggleMaximize(state)
		local nextState = (state == nil) and not maximized or state == true
		if nextState == maximized then return end
		maximized = nextState

		local vp = getViewport()
		local margin = MARGIN

		if collapsed then
			Window:Collapse(false)
		end

		if nextState then
			savedBounds = {
				Position = Main.Position,
				Size = UDim2.fromOffset(fullSize.X, fullSize.Y),
			}
			Utility.Tween(Main, 0.32, {
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(vp.X - margin * 2, vp.Y - margin * 2),
			}, Enum.EasingStyle.Quart)
		elseif savedBounds then
			Utility.Tween(Main, 0.32, savedBounds, Enum.EasingStyle.Quart)
			task.delay(0.33, keepInBounds)
		end

		if Grip then
			Grip.Visible = not maximized and not collapsed
		end
	end

	function Window:SetTitle(text)
		if typeof(text) ~= "string" then
			warn("[Fancy] SetTitle requires a string")
			return
		end
		Title.Text = text
		if collapsed then
			local contentStart = Logo.Visible and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
			local barWidth = math.max(contentStart + measureTitle(text) + COMPACT_START, 90)
			Utility.Tween(Main, 0.2, {
				Size = UDim2.fromOffset(math.min(barWidth, fullSize.X), Main.AbsoluteSize.Y),
			}, Enum.EasingStyle.Quart)
		end
	end

	function Window:SetIcon(name)
		if typeof(name) == "string" and #name > 0 then
			Logo.Image = Icons.Get(name)
			Logo.Visible = true
		else
			Logo.Visible = false
		end

		if collapsed then
			local contentStart = Logo.Visible and (COMPACT_START + COMPACT_ICON_GAP) or COMPACT_START
			Logo.Position = UDim2.new(0, COMPACT_START, 0.5, -9)
			Title.Position = UDim2.new(0, contentStart, 0.5, -9)

			local barWidth = math.max(contentStart + measureTitle(Title.Text) + COMPACT_START, 90)
			Utility.Tween(Main, 0.2, {
				Size = UDim2.fromOffset(math.min(barWidth, fullSize.X), Main.AbsoluteSize.Y),
			}, Enum.EasingStyle.Quart)
		else
			Utility.Tween(Title, 0.15, {
				Position = UDim2.new(0, Logo.Visible and 104 or 78, 0.5, -9),
			})
		end
	end

	function Window:NewTab(settings)
		return Elements.Tab:Create(settings)
	end

	function Window:NewTopbar(settings)
		return Elements.Topbar:Create(settings)
	end

	function Window:SelectTab(reference)
		local target = nil
		if typeof(reference) == "number" then
			target = Fancy.Tabs[reference]
		else
			for _, tab in Fancy.Tabs do
				if tab == reference or tab.Settings.Name == tostring(reference) then
					target = tab
					break
				end
			end
		end
		if target then
			target:Select()
		else
			warn(("[Fancy] Tab '%s' was not found"):format(tostring(reference)))
		end
		return target
	end

	local forwardMethods = {
		NewSection = true,
		NewButton = true,
		NewToggle = true,
		NewSlider = true,
		NewInput = true,
		NewParagraph = true,
		NewKeybind = true,
		NewDropdown = true,
	}

	for methodName in forwardMethods do
		Window[methodName] = function(_, settings)
			local tab = Fancy.SelectedTab or Window:NewTab({ Name = "Main", Icon = "home" })
			return tab[methodName](tab, settings)
		end
	end

	function Window:Toggle(visible)
		if not Fancy.MainUI then return end
		if typeof(visible) == "boolean" then
			Fancy.MainUI.Enabled = visible
		else
			Fancy.MainUI.Enabled = not Fancy.MainUI.Enabled
		end
	end

	function Window:Notify(props)
		Notifications.Send(props)
	end

	function Window:SetTheme(name)
		local theme = typeof(name) == "string" and Themes[name] or nil
		if not theme then
			warn(("[Fancy] Theme '%s' does not exist"):format(tostring(name)))
			return
		end
		Fancy.Theme = theme
		Fancy.ThemeName = name
		Utility.ApplyTheme(Main, theme)
	end

	local unloadHandlers = {}

	function Window:OnUnload(callback)
		if typeof(callback) ~= "function" then
			warn("[Fancy] OnUnload requires a function")
			return nil
		end
		table.insert(unloadHandlers, callback)
		return function()
			local index = table.find(unloadHandlers, callback)
			if index then
				table.remove(unloadHandlers, index)
			end
		end
	end

	local function fireUnload()
		if #unloadHandlers == 0 then return end
		local handlers = table.clone(unloadHandlers)
		table.clear(unloadHandlers)
		for _, handler in handlers do
			local ok, err = pcall(handler)
			if not ok then
				warn("[Fancy] OnUnload handler error: " .. tostring(err))
			end
		end
	end

	function Window:Destroy()
		fireUnload()

		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)

		if Fancy.Topbars then
			for i = #Fancy.Topbars, 1, -1 do
				local bar = Fancy.Topbars[i]
				if bar.Persistent ~= true then
					pcall(function()
						bar:Destroy()
					end)
				end
			end
		end

		Utility.Tween(Scale, 0.15, { Scale = 0.97 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		if Shadow then
			Utility.Tween(Shadow, 0.15, { ImageTransparency = 1 })
		end

		task.delay(0.16, function()
			Main:Destroy()
		end)

		Fancy.Window = nil
		Fancy.WindowAPI = nil
		Fancy.Refs = nil
		Fancy.Tabs = {}
		Fancy.SelectedTab = nil
	end

	if Resizeable then
		Grip = InstanceModule:Create("TextButton", {
			Name = "ResizeGrip",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -3, 1, -3),
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = Main,
		})

		local GripIcon = InstanceModule:Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Image = Icons.Get("a-large-small"),
			ImageColor3 = Theme.SubText,
			ImageTransparency = 0.45,
			Rotation = 180,
			Parent = Grip,
		})
		GripIcon:SetAttribute("FancyImage", "SubText")

		Grip.MouseEnter:Connect(function()
			Utility.Tween(GripIcon, 0.15, { ImageTransparency = 0 })
		end)
		Grip.MouseLeave:Connect(function()
			Utility.Tween(GripIcon, 0.2, { ImageTransparency = 0.45 })
		end)

		local resizing = false
		local startInput, startSize

		Grip.InputBegan:Connect(function(input)
			if collapsed or maximized then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startInput = input.Position
				startSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
			end
		end)

		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end))

		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if not resizing or collapsed or maximized then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local vp = getViewport()
				local availW = math.max(vp.X - MARGIN * 2, effMinX)
				local availH = math.max(vp.Y - MARGIN * 2, effMinY)
				local delta = input.Position - startInput

				local newW, newH
				if isMobile then
					local ratio = startSize.Y / math.max(startSize.X, 1)
					local growth = math.max(delta.X, delta.Y / ratio)
					newW = math.clamp(startSize.X + growth, effMinX, availW)
					newH = math.clamp(newW * ratio, effMinY, availH)
					newW = newH / ratio
				else
					newW = math.clamp(startSize.X + delta.X, effMinX, availW)
					newH = math.clamp(startSize.Y + delta.Y, effMinY, availH)
				end

				newW = math.floor(newW + 0.5)
				newH = math.floor(newH + 0.5)

				Main.Size = UDim2.fromOffset(newW, newH)
				fullSize = Vector2.new(newW, newH)
				keepInBounds()
			end
		end))

		do
			local camera = Services.Workspace.CurrentCamera
			if camera then
				table.insert(connections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					if collapsed then return end
					local vp = getViewport()
					local maxW = math.max(vp.X - MARGIN * 2, effMinX)
					local maxH = math.max(vp.Y - MARGIN * 2, effMinY)
					local newW = math.min(Main.AbsoluteSize.X, maxW)
					local newH = math.min(Main.AbsoluteSize.Y, maxH)
					if newW ~= Main.AbsoluteSize.X or newH ~= Main.AbsoluteSize.Y then
						Main.Size = UDim2.fromOffset(newW, newH)
						fullSize = Vector2.new(newW, newH)
					end
					keepInBounds()
				end))
			end
		end
	end

	if Fancy.WindowSettings.ToggleKey then
		table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == Fancy.WindowSettings.ToggleKey then
				Window:Toggle()
			end
		end))
	end

	return Window
end

local Main = {}
function Main:CreateWindow(properties)
	if not Fancy.MainUI then
		warn("[Fancy] CreateWindow failed: MainUI is nil")
		return nil
	end

	if Fancy.Window then
		warn("[Fancy] CreateWindow failed: a window already exists")
		return Fancy.WindowAPI
	end

	if typeof(properties) ~= "table" then
		properties = {}
	end

	local merged = {}
	for key, value in properties do
		merged[key] = value
	end

	if typeof(properties.Window) == "table" then
		for key, value in properties.Window do
			merged[key] = value
		end
	end

	Fancy.WindowSettings = merged

	local window = Elements.Window:Create(WindowDefaults)
	if not window then
		warn("[Fancy] Elements/Window.lua returned nil")
		return nil
	end
	
	SaveManager:Initialize()
	Fancy.WindowAPI = window
	return window
end

function Main:Destroy()
	if Fancy.WindowAPI then
		pcall(function()
			Fancy.WindowAPI:Destroy()
		end)
	end
	for _, gui in { Fancy.MainUI, Fancy.TopbarUI } do
		if gui then
			pcall(function()
				gui:Destroy()
			end)
		end
	end
	Fancy.MainUI = nil
	Fancy.TopbarUI = nil
	Fancy.Window = nil
	Fancy.WindowAPI = nil
	Fancy.Refs = nil
	Fancy.Tabs = {}
	Fancy.SelectedTab = nil
	Fancy.Topbars = {}
end

function Main:Toggle(visible)
	if not Fancy.MainUI then return end
	if typeof(visible) == "boolean" then
		Fancy.MainUI.Enabled = visible
	else
		Fancy.MainUI.Enabled = not Fancy.MainUI.Enabled
	end
end

function Main:SetTheme(name)
	if typeof(name) ~= "string" or not Themes[name] then
		warn(("[Fancy] Theme '%s' does not exist"):format(tostring(name)))
		return
	end
	Fancy.Theme = Themes[name]
	Fancy.ThemeName = name
	if Fancy.MainUI then
		Utility.ApplyTheme(Fancy.MainUI, Fancy.Theme)
	end
end

function Main:Notify(props)
	if not Fancy.MainUI then return end
	Notifications.Send(props)
end

Main.Themes = Themes
Main.Icons = Icons
Main.Utility = Utility
Main.SaveManager = SaveManager
return Main
