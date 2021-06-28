--[[
SBCI - General Use "Common"
]]

--General Stuff;
SBCI.debug = true;
SBCI.Version = "0.2.0";
SBCI.IsInitialised = false

-- Hex color codes "\127RRGGBB" format
SBCI.colors = {};
SBCI.colors.SBCI = "\12700b3b3";
SBCI.colors.combat = "\127CD5C5C";
SBCI.colors.yellow = "\127FFFF00";
SBCI.colors.white = "\127FFFFFF";
SBCI.colors.RED = "\127FF0000";

SBCI.colors.GREEN = "\127008800";
SBCI.colors.GREEN2 = "\12733CC33";
SBCI.colors.CHAT_BLUE = "\12728B4F0";
SBCI.colors.NORMAL = "\127DDDDDD";
SBCI.colors.ORANGE = "\127AAAA00";
SBCI.colors.guildOrange = "\127ffb935";
SBCI.colors.indianRed = "\127CD5C5C";
SBCI.colors.BLUE = "\1270000FF";
SBCI.colors.darkGreen = "\127888800";


SBCI.colors.faction = {};
SBCI.colors.faction[0] = "\127808080"; --Grey
SBCI.colors.faction[1] = "\1276080FF"; --Itani
SBCI.colors.faction[2] = "\127FF2020"; --Serco
SBCI.colors.faction[3] = "\127C0C000"; --UIT

SBCI.channels = {};
SBCI.channels[0] = "";
SBCI.channels[1] = "(Council) ";
SBCI.channels[2] = "(Officer) ";

SBCI.colors.channels = {};
SBCI.colors.channels[0] = SBCI.colors.SBCI;
SBCI.colors.channels[1] = SBCI.colors.SBCI;
SBCI.colors.channels[2] = SBCI.colors.SBCI;



local colour_delimiter = "@"
SBCI.colour_codes = {}
for k,v in pairs(SBCI.colors) do
    SBCI.colour_codes[colour_delimiter..k..colour_delimiter] = v
end


SBCI.SystemNames_ = {
	{1,"Sol II",2},
	{2,"Betheshee",2},
	{3,"Geira Rutilus",2},
	{4,"Deneb",0},
	{5,"Eo",1},
	{6,"Cantus",1},
	{7,"Metana",1},
	{8,"Setalli Shinas",1},
	{9,"Itan",1},
	{10,"Pherona",1},
	{11,"Artana Aquilus",1},
	{12,"Divinia",1},
	{13,"Jallik",1},
	{14,"Edras",0},
	{15,"Verasi",3},
	{16,"Pelatus",0},
	{17,"Bractus",0},
	{18,"Nyrius",3},
	{19,"Dau",3},
	{20,"Sedina",0},
	{21,"Azek",3},
	{22,"Odia",0},
	{23,"Latos",0},
	{24,"Arta Caelestis",3},
	{25,"Ukari",0},
	{26,"Helios",0},
	{27,"Initros",2},
	{28,"Pyronis",2},
	{29,"Rhamus",2},
	{30,"Dantia",2},
	{31,"Devlopia",0},
	{32,"nil",0},
	{33,"Infernus",0},
	{34,"Devlopia",0},
	{35,"NilSystem",0},
	{36,"Unknown System",0},
};

SBCI.Roles = ""; --Roles given by server.
