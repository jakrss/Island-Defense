//! zinc

library UnitSpawner requires Unit, Players {    
    public module UnitSpawner {
        // This should go somewhere else...?!
        public static integer minionLevel = 2;
        // Player
        public static player PASSIVE_PLAYER = Player(PLAYER_NEUTRAL_PASSIVE);
        // Units
        public static unit TITAN_SPELL_WELL = null;
        public static unit DEFENDER_PICK_EASY = null;
        public static unit DEFENDER_PICK_MEDIUM = null;
        public static unit DEFENDER_PICK_HARD = null;
        public static unit TITAN_PICK_EASY = null;
        public static unit TITAN_PICK_HARD = null;
        public static unit ARTIFACTS_PAGE_ONE = null;
        public static unit ARTIFACTS_PAGE_TWO = null;
        public static unit CONSUMABLES_PAGE_ONE = null;
        public static unit CONSUMABLES_PAGE_TWO = null;
        public static unit RECIPES_PAGE_ONE = null;
        public static unit RECIPES_PAGE_TWO = null;
	public static unit RECIPES_PAGE_THREE = null;
	public static unit RECIPES_PAGE_ONE_TIER3 = null;
	public static unit RECIPES_PAGE_TWO_TIER3= null;
	public static unit RECIPES_PAGE_THREE_TIER3 = null;
        public static unit TITAN_PUNISH_CAGE = null;
        
        // Object IDs
        public static integer DEFENDER_PICK_EASY_ID       = 'n00W';
        public static integer DEFENDER_PICK_MEDIUM_ID     = 'n01G';
        public static integer DEFENDER_PICK_HARD_ID       = 'n00X';
        public static integer TITAN_PICK_EASY_ID          = 'n00M';
        public static integer TITAN_PICK_HARD_ID          = 'n00Z';
        public static integer ARTIFACTS_PAGE_ONE_ID       = 'n01W';
        public static integer ARTIFACTS_PAGE_TWO_ID       = 'n01X';
        public static integer CONSUMABLES_PAGE_ONE_ID     = 'n01U';
        public static integer CONSUMABLES_PAGE_TWO_ID     = 'n01V';
        public static integer RECIPES_PAGE_ONE_ID         = 'n01A';
        public static integer RECIPES_PAGE_TWO_ID         = 'n01B';
	public static integer RECIPES_PAGE_THREE_ID	  = 'n02E';
	public static integer RECIPES_PAGE_ONE_TIER3_ID	  = 'n01M';
	public static integer RECIPES_PAGE_TWO_TIER3_ID	  = 'n01N';
	public static integer RECIPES_PAGE_THREE_TIER3_ID = 'n01O';
        
        public static method spawnSpellWell(){
            thistype.TITAN_SPELL_WELL = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'h001', -384, -512, 270.0);
            SetUnitState(thistype.TITAN_SPELL_WELL, UNIT_STATE_LIFE, GetUnitState(thistype.TITAN_SPELL_WELL, UNIT_STATE_LIFE) / 4);
			
			// This should remove the health bar
			// Unfortunately has the side effect of making it almost unclickable (have to drag select)
			// UnitAddAbility(thistype.TITAN_SPELL_WELL, 'Aloc');
			// ShowUnit(thistype.TITAN_SPELL_WELL, false);
			// UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Aloc');
			// ShowUnit(thistype.TITAN_SPELL_WELL, true);
			
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'ARal'); // Rally
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Afih'); // Fire
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Afin');
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Afio');
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Afir');
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Afiu');
            UnitAddAbility(thistype.TITAN_SPELL_WELL, 'Avul');
            thistype.TITAN_PUNISH_CAGE = thistype.TITAN_SPELL_WELL;
        }
        
        public static method spawnShops(){
            thistype.ARTIFACTS_PAGE_ONE     = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), ARTIFACTS_PAGE_ONE_ID  ,     128.0,  -384.0, 270);
            thistype.ARTIFACTS_PAGE_TWO     = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), ARTIFACTS_PAGE_TWO_ID  ,     128.0,  -384.0, 270);
            thistype.CONSUMABLES_PAGE_ONE   = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CONSUMABLES_PAGE_ONE_ID,   -128, -1024, 270);
            thistype.CONSUMABLES_PAGE_TWO   = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CONSUMABLES_PAGE_TWO_ID,   -128, -1025, 270);
			thistype.RECIPES_PAGE_ONE     = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_ONE_ID    ,   -898.5,  -444.0, 270);
			thistype.RECIPES_PAGE_TWO     = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_TWO_ID    ,   -898.0,  -388.5, 270);
			thistype.RECIPES_PAGE_THREE   = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_THREE_ID  ,   -897.5,  -388.5, 270);
			thistype.RECIPES_PAGE_ONE_TIER3	    = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_ONE_TIER3_ID  ,   -448.5,  128, 270);
			thistype.RECIPES_PAGE_TWO_TIER3	    = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_TWO_TIER3_ID  ,   -447.5,  128, 270);
			thistype.RECIPES_PAGE_THREE_TIER3   = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), RECIPES_PAGE_THREE_TIER3_ID  ,   -447.6,  127.8, 270);
        }
        
        public static method setWellOwner(player p){
            SetUnitOwner(thistype.ARTIFACTS_PAGE_ONE  , p, true); // Changes ownership
            SetUnitOwner(thistype.ARTIFACTS_PAGE_TWO  , p, true); // Changes ownership
            SetUnitOwner(thistype.CONSUMABLES_PAGE_ONE, p, true); // Changes ownership
            SetUnitOwner(thistype.CONSUMABLES_PAGE_TWO, p, true); // Changes ownership
            SetUnitOwner(thistype.RECIPES_PAGE_ONE    , p, true); // Changes ownership
            SetUnitOwner(thistype.RECIPES_PAGE_TWO    , p, true); // Changes ownership
	    SetUnitOwner(thistype.RECIPES_PAGE_THREE  , p, true); // Changes ownership
	    SetUnitOwner(thistype.RECIPES_PAGE_ONE_TIER3  , p, true); // Changes ownership
	    SetUnitOwner(thistype.RECIPES_PAGE_TWO_TIER3  , p, true); // Changes ownership
	    SetUnitOwner(thistype.RECIPES_PAGE_THREE_TIER3  , p, true); // Changes ownership
            SetUnitOwner(thistype.TITAN_PUNISH_CAGE   , p, true); // Changes ownership
            SetUnitOwner(thistype.TITAN_SPELL_WELL    , p, true); // Changes ownership
        }
        
        public static method spawnPickShops(){
            if (GameSettings.getBool("PICKMODE_UNIQUE")){
                thistype.DEFENDER_PICK_EASY_ID = 'n00B';
            }
            else {
                thistype.DEFENDER_PICK_EASY_ID = 'n00W';
            }
            //thistype.DEFENDER_PICK_EASY      = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_EASY_ID, -3200, 9800, 270);
            //thistype.DEFENDER_PICK_MEDIUM    = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_MEDIUM_ID, -2900, 9800, 270);
            //thistype.DEFENDER_PICK_HARD      = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_HARD_ID, -2600, 9800, 270);
            //thistype.TITAN_PICK_EASY         = CreateUnit(PASSIVE_PLAYER, TITAN_PICK_EASY_ID, -3392, 3520, 270);
            //thistype.TITAN_PICK_HARD         = CreateUnit(PASSIVE_PLAYER, TITAN_PICK_HARD_ID, -3200, 3392, 270);
	    thistype.DEFENDER_PICK_EASY      = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_EASY_ID, -10752, 8960, 0);
            thistype.DEFENDER_PICK_MEDIUM    = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_MEDIUM_ID, -10752, 8704, 0);
            thistype.DEFENDER_PICK_HARD      = CreateUnit(PASSIVE_PLAYER, DEFENDER_PICK_HARD_ID, -10752, 8448, 0);
	    UnitRemoveAbility(thistype.DEFENDER_PICK_EASY, 'Adef');
            UnitRemoveAbility(thistype.DEFENDER_PICK_MEDIUM, 'Adef');
            UnitRemoveAbility(thistype.DEFENDER_PICK_HARD, 'Adef');
            thistype.TITAN_PICK_EASY         = CreateUnit(PASSIVE_PLAYER, TITAN_PICK_EASY_ID, -10048, 10304, 270);
            thistype.TITAN_PICK_HARD         = CreateUnit(PASSIVE_PLAYER, TITAN_PICK_HARD_ID, -9856, 10304, 270);
            
            //thistype.populatePickShops();
        }
        
        // Bugged, hotkeys don't work! D:
        public static method populatePickShops(){
            integer i = 0;
            Race r = 0;
            for (0 <= i < DefenderRace.count()){
                r = DefenderRace[i];
                Game.say("Now adding " + r.toString() + " to the pickshops...");
                if (r.difficulty() == 1.0){
                    AddItemToStock(thistype.DEFENDER_PICK_EASY, r.itemId(), 1, 1);
                }
                else if (r.difficulty() == 2.0){
                    AddItemToStock(thistype.DEFENDER_PICK_MEDIUM, r.itemId(), 1, 1);
                }
                else {
                    AddItemToStock(thistype.DEFENDER_PICK_HARD, r.itemId(), 1, 1);
                }
            }
            
            for (0 <= i < TitanRace.count()){
                r = TitanRace[i];
                Game.say("Now adding " + r.toString() + " to the pickshops...");
                if (r.difficulty() == 1.0){
                    AddItemToStock(thistype.TITAN_PICK_EASY, r.itemId(), 1, 1);
                }
                else {
                    AddItemToStock(thistype.TITAN_PICK_HARD, r.itemId(), 1, 1);
                }
            }
        }
        
        public static method despawnPickShops(){
            RemoveUnit(thistype.DEFENDER_PICK_EASY);
            RemoveUnit(thistype.DEFENDER_PICK_MEDIUM);
            RemoveUnit(thistype.DEFENDER_PICK_HARD);
            RemoveUnit(thistype.TITAN_PICK_EASY);
            RemoveUnit(thistype.TITAN_PICK_HARD);
        }
        
        public static method spawnTitans(){
            PlayerDataArray list = 0;
            integer i = 0;

            list = PlayerData.withClass(PlayerData.CLASS_TITAN);
            for (0 <= i < list.size()){
                thistype.spawnTitan(list[i]);
            }
            list.destroy();
            list = 0;
            
            Game.say("|cff00bfffThe titan has spawned, it's time to build up your defenses against his wrath.|r");
            StartSound(gg_snd_Titan_Ready);
            
            UnitRemoveAbility(thistype.TITAN_SPELL_WELL, 'Avul'); // Removes invunerability from the mound
        }
        
        public static method spawnDefender(PlayerData p) -> Unit {
            DefenderUnit defender = 0;
            real delta = 360.0 / PlayerData.countClass(PlayerData.CLASS_DEFENDER);
            real offset = 0.0; //GetRandomReal(0.0, 360.0);
            real startX = GetUnitX(thistype.TITAN_SPELL_WELL); 
            real startY = GetUnitY(thistype.TITAN_SPELL_WELL);
            real x = 0.0;
            real y = 0.0;
            PlayerDataArray list = 0;
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            
            delta = offset + (delta * list.indexOf(p));
            x = startX + (200 * (Cos(delta * bj_DEGTORAD)));
            y = startY + (200 * (Sin(delta * bj_DEGTORAD)));
            list.destroy();
            
            defender = DefenderUnit.create(p);
            p.setUnit(defender);
            thistype.defenders.append(defender);
			defender.spawn(x, y, bj_RADTODEG * Atan2(y - startY, x - startX));
            
            RacePicker.onUnitCreation.execute(p);
            return defender;
        }
        
        public static method hunterRespawn(unit u) -> Unit {
            HunterUnit hunter = 0;
            hunter = HunterUnit.fromUnit(u);
            thistype.hunters.append(hunter);
            
            if (PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_TITAN) ||
                PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_MINION)){
                Game.say("|cffffd700A Titan hunter has been revived. " +
                        "Kill it to gain additional resources before it gets too strong.|r");
            }
            else {
                Game.say("|cffffd700A Titan hunter has been revived! " + 
                         "Use it to kill the titan and his minions to gain experience and gold.|r");
            }
			
			// Balth doesn't want this (OP)
			// This duplicates some effects (such as HP bonuses)
			// HUNTERS, AS IT TURNS OUT, ARE STILL TECHNICALLY ON THE MAP. INTERESTERING
			// Upgrades.applyUpgrades(u);
            
            return hunter;
        }
        
        public static method spawnHunter(PlayerData p, real x, real y) -> Unit {
            HunterUnit hunter = 0;
            hunter = HunterUnit.create(p);
            thistype.hunters.append(hunter);
			hunter.spawn(x, y, 270);
            
            if (PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_TITAN) ||
                PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_MINION)){
                Game.say("|cffffd700A Titan hunter has been spawned. " +
                        "Kill it to gain additional resources before it gets too strong.|r");
            }
            else {
                Game.say("|cffffd700A Titan hunter has been spawned! " + 
                         "Use it to kill the titan and his minions to gain experience and gold.|r");
            }
            
            return hunter;
        }
        
        public static method spawnTitan(PlayerData p) -> Unit {
            TitanUnit titan = 0;
            real delta = 360.0 / PlayerData.countClass(PlayerData.CLASS_TITAN);
            real offset = GetRandomReal(0.0, 360.0);
            real startX = GetUnitX(thistype.TITAN_SPELL_WELL); 
            real startY = GetUnitY(thistype.TITAN_SPELL_WELL);
            real x = 0.0;
            real y = 0.0;
            PlayerDataArray list = 0;
            list = PlayerData.withClass(PlayerData.CLASS_TITAN);
            
            delta = offset + (delta * list.indexOf(p));
            x = startX + (200 * (Cos(delta * bj_DEGTORAD)));
            y = startY + (200 * (Sin(delta * bj_DEGTORAD)));
            list.destroy();
            
            titan = TitanUnit.create(p);
            p.setUnit(titan);
            thistype.titans.append(titan);
			titan.spawn(x, y, bj_RADTODEG * Atan2(startY - y, startX - x));
            
            SetHeroLevel(titan.unit(), GameSettings.getInt("TITAN_START_LEVEL"), false); // Sets level to default
            UnitManager.setWellOwner(p.player());
            
            RacePicker.onUnitCreation.execute(p);
            return titan;
        }
        
        public static method spawnMinion(PlayerData p, real x, real y, integer level) -> Unit {
            PlayerDataArray list = 0;
            PlayerData q = 0;
            MinionUnit minion = 0;
            integer i = 0;
            minion = MinionUnit.create(p);
            thistype.minions.append(minion);
			if (p.class() == PlayerData.CLASS_MINION){
                p.setUnit(minion);
            }
			minion.spawn(x, y, 270.0);
            
            SuspendHeroXP(minion.unit(), false);
            SetHeroLevel(minion.unit(), level, false);
            SuspendHeroXP(minion.unit(), true);
            
            return minion;
        }
    }
}

//! endzinc