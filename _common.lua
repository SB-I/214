--[[
TBS - General Use "Common"
]]

--General Stuff;
TBS.debug = false;
TBS.Version = "0.2.5";
TBS.IsInitialised = false

-- Hex color codes "\127RRGGBB" format
TBS.colors = {};
TBS.colors.TBS = "\12700b3b3";
TBS.colors.combat = "\127CD5C5C";
TBS.colors.green = "\127008800";
TBS.colors.indianRed = "\127CD5C5C";
TBS.colors.white = "\127FFFFFF";
TBS.colors.yellow = "\127FFFF00";



TBS.colors.RED = "\127FF0000";
TBS.colors.green2 = "\12733CC33";
TBS.colors.lime = "\12788FF88";
TBS.colors.CHAT_BLUE = "\12728B4F0";
TBS.colors.normal = "\127DDDDDD";
TBS.colors.ORANGE = "\127AAAA00";
TBS.colors.guildOrange = "\127ffb935";
TBS.colors.BLUE = "\1270000FF";
TBS.colors.darkGreen = "\127888800";


TBS.colors.faction = {};
TBS.colors.faction[0] = "\127808080"; --Grey
TBS.colors.faction[1] = "\1276080FF"; --Itani
TBS.colors.faction[2] = "\127FF2020"; --Serco
TBS.colors.faction[3] = "\127C0C000"; --UIT

TBS.channels = {};
TBS.channels[0] = "";
TBS.channels[1] = "(Council) ";
TBS.channels[2] = "(Officer) ";

TBS.colors.channels = {};
TBS.colors.channels[0] = TBS.colors.TBS;
TBS.colors.channels[1] = TBS.colors.TBS;
TBS.colors.channels[2] = TBS.colors.TBS;

TBS.standings = {};
TBS.colors.radar = {};
TBS.colors.standings = {};
--Standing Radarlock Colors
TBS.colors.radar[4] = {0, 179, 179}; 	--TBS
TBS.colors.radar[3] = {0, 136, 0}; 		--green
TBS.colors.radar[2] = {0, 179, 179}; 	--TBS
TBS.colors.radar[1] = {0, 136, 0}; 		--green
TBS.colors.radar[0] = {255, 255, 255}; 	--white
TBS.colors.radar[-1] = {205, 92, 91}; 	--indianRed
TBS.colors.radar[-2] = {255, 0, 0}; 	--combat
TBS.colors.radar[-5] = {255, 255, 255}; --white

--Standing Colors
TBS.colors.standings[4] = TBS.colors.TBS;
TBS.colors.standings[3] = TBS.colors.green;
TBS.colors.standings[2] = TBS.colors.TBS;
TBS.colors.standings[1] = TBS.colors.green;
TBS.colors.standings[0] = TBS.colors.white;
TBS.colors.standings[-1] = TBS.colors.indianRed;
TBS.colors.standings[-2] = TBS.colors.combat;
TBS.colors.standings[-5] = TBS.colors.white;

--Standing Titles
TBS.standings[4] = "Guildie";
TBS.standings[3] = "Respected";
TBS.standings[2] = "Ally";
TBS.standings[1] = "Friendly";
TBS.standings[0] = "Neutral";
TBS.standings[-1] = "Caution";
TBS.standings[-2] = "KoS";
TBS.standings[-5] = "Bot";


local colour_delimiter = "@"
TBS.colour_codes = {}
for k,v in pairs(TBS.colors) do
    TBS.colour_codes[colour_delimiter..k..colour_delimiter] = v
end


TBS.SystemNames_ = {
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
	{33,"Infernus",0}
};

TBS.Roles = ""; --Roles given by server.

TBS.__PlayersInSector = TBS.__PlayersInSector or {};
