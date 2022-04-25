//! zinc

library UnitManager requires UnitSpawner, RegisterPlayerUnitEvent {   
    
    public struct UnitManager {
        public static UnitList titans = 0;
        public static UnitList minions = 0;
        public static UnitList defenders = 0;
        public static UnitList hunters = 0;
            
        module UnitSpawner;
        
        public static method onDeath(unit u, unit v){
            Unit un = 0;

            if (thistype.isTitan(u)){
                un = thistype.titans.get(u);
                thistype.titans.remove(un);
                TitanDeath.onDeath(un, v);
            }
            if (thistype.isDefender(u)){
                un = thistype.defenders.get(u);
                thistype.defenders.remove(un);
                DefenderDeath.onDeath(un, v);
            }
            if (thistype.isMinion(u)){
                un = thistype.minions.get(u);
                thistype.minions.remove(un);
                MinionDeath.onDeath(un, v);
            }
            if (thistype.isHunter(u)){
                un = thistype.hunters.get(u);
                thistype.hunters.remove(un);
                HunterDeath.onDeath(un, v);
            }
            // We're not interested... bye!
            u = null;
			v = null;
            un = 0;
        }
        
        public static method isDefender(unit u) -> boolean {
            return thistype.defenders.indexOfUnit(u) != -1;
        }
        
        public static method isTitan(unit u) -> boolean {
            return thistype.titans.indexOfUnit(u) != -1;
        }
        
        public static method isMinion(unit u) -> boolean {
            return thistype.minions.indexOfUnit(u) != -1;
        }
        
        public static method isHunter(unit u) -> boolean {
            return thistype.hunters.indexOfUnit(u) != -1;
        }
        
        public static method getDefender(unit u) -> DefenderUnit {
            DefenderUnit d = 0;
            integer i = thistype.defenders.indexOfUnit(u);
            if (i != -1)
                d = thistype.defenders.at(i);
            return d;
        }
        
        public static method getHunter(unit u) -> HunterUnit {
            HunterUnit d = 0;
            integer i = thistype.hunters.indexOfUnit(u);
            if (i != -1)
                d = thistype.hunters.at(i);
            return d;
        }
        
        public static method getPlayerHunter(PlayerData p) -> HunterUnit {
            HunterUnit d = 0;
            integer i = 0;
            for (0 <= i < thistype.hunters.size()){
                d = thistype.hunters[i];
                if (d.owner() == p){
                    return d;
                }
            }
            return 0;
        }
        
        public static method countTitans() -> integer {
            UnitList l = thistype.getTitans();
            integer i = l.size();
            l.destroy();
            return i;
        }
        
        public static method countMinions() -> integer {
            UnitList l = thistype.getMinions();
            integer i = l.size();
            l.destroy();
            return i;
        }
        
        public static method getTitans() -> UnitList {
            UnitList list = 0;
            //Game.say("getTitans() start " + I2S(thistype.titans.size()) + " | " + I2S(0));
            list = UnitList.copy(thistype.titans);
            //Game.say("getTitans() end " + I2S(thistype.titans.size()) + " | " + I2S(list.size()));
            return list;
        }
        
        public static method getMinions() -> UnitList {
            return UnitList.copy(thistype.minions);
        }
        
        public static method getDefenders() -> UnitList {
            return UnitList.copy(thistype.defenders);
        }
        
        public static method getHunters() -> UnitList {
            return UnitList.copy(thistype.hunters);
        }
        
		private static trigger damageTrigger = null;
        public static method initialize(){
            titans = UnitList.create();
            minions = UnitList.create();
            defenders = UnitList.create();
            hunters = UnitList.create();
			
			if (thistype.damageTrigger == null) {
				thistype.damageTrigger = CreateTrigger();
				TriggerAddCondition(thistype.damageTrigger , Condition(function() -> boolean {
					unit u = GetTriggerUnit();
					unit a = GetEventDamageSource();
					real damage = GetEventDamage();
					if (thistype.isDefender(u)) {
						if (GetUnitState(u, UNIT_STATE_LIFE) - damage <= 0.125) {
							// Technically a death :O
							thistype.onDeath(u, a);
						}
					}
					a = null;
					u = null;
					return false;
				}));
			}
			if (Game.isMode("IDT")){	
				Damage_RegisterEvent(thistype.damageTrigger);
			}
        }
        
        public static method givePlayerUnitsTo(PlayerData from, PlayerData new){
            group g = CreateGroup();
            unit u = null;
            
            GroupEnumUnitsOfPlayer(g, from.player(), null);
            u = FirstOfGroup(g);
            while (u != null){
                SetUnitOwner(u, new.player(), true);
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        public static method swapPlayerUnits(PlayerData firstPlayer, PlayerData secondPlayer){
            group firstPlayerUnits = CreateGroup();
            group secondPlayerUnits = CreateGroup();
            unit u = null;

            GroupEnumUnitsOfPlayer(firstPlayerUnits, firstPlayer.player(), null);
            GroupEnumUnitsOfPlayer(secondPlayerUnits, secondPlayer.player(), null);
            
            u = FirstOfGroup(firstPlayerUnits);
            while (u != null){
                SetUnitOwner(u, secondPlayer.player(), true);
            
                GroupRemoveUnit(firstPlayerUnits, u);
                u = FirstOfGroup(firstPlayerUnits);
            }
            DestroyGroup(firstPlayerUnits);
            
            u = FirstOfGroup(secondPlayerUnits);
            while (u != null){
                SetUnitOwner(u, firstPlayer.player(), true);
            
                GroupRemoveUnit(secondPlayerUnits, u);
                u = FirstOfGroup(secondPlayerUnits);
            }
            DestroyGroup(secondPlayerUnits);
            
            firstPlayerUnits = null;
            secondPlayerUnits = null;
            u = null;
        }
        
        
        
        public static method removeUnit(unit u){
            if (thistype.isDefender(u)){
                thistype.defenders.remove(thistype.defenders.get(u));
            }
            else if (thistype.isHunter(u)){
                thistype.hunters.remove(thistype.hunters.get(u));
            }
        }
        
        public static method removePlayerUnits(PlayerData p){
            group g = CreateGroup();
            unit u = null;
            
            GroupEnumUnitsOfPlayer(g, p.player(), null);
            u = FirstOfGroup(g);
            while (u != null){
                thistype.removeUnit(u);
                RemoveUnit(u);
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }
		
		public static method neutralizePlayerUnits(PlayerData p){
            group g = null;
            unit u = null;
			boolean decay = GameSettings.getBool("NEUTRALIZE_STRUCTURES_DECAY");
			real duration = GameSettings.getReal("NEUTRALIZE_STRUCTURES_DECAY_TIME");
			
			if (!GameSettings.getBool("NEUTRALIZE_STRUCTURES")) {
				thistype.removePlayerUnits(p);
				return;
			}
			
			g = CreateGroup();
            
            GroupEnumUnitsOfPlayer(g, p.player(), null);
            u = FirstOfGroup(g);
            while (u != null){
				if (IsUnitType(u, UNIT_TYPE_STRUCTURE)) {
					SetUnitOwner(u, Player(PLAYER_NEUTRAL_AGGRESSIVE), true);
					UnitAddAbility(u, 'Abun');
					SetUnitVertexColor(u, 50, 50, 50, 130);
					if (decay) {
						UnitApplyTimedLife(u, 'BTLF', duration);
					}
				}
				else {
					thistype.removeUnit(u);
					RemoveUnit(u);
				}
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
        }

        public static method terminate(){
            Unit u = 0;
            while(titans.size() > 0){
                u = titans.takeAt(0); if (u != 0) u.destroy();
            }
            titans.destroy();
            
            while(minions.size() > 0){
                u = minions.takeAt(0); if (u != 0) u.destroy();
            }
            minions.destroy();
            
            while(defenders.size() > 0){
                u = defenders.takeAt(0); if (u != 0) u.destroy();
            }
            defenders.destroy();
            
            while(hunters.size() > 0){
                u = hunters.takeAt(0); if (u != 0) u.destroy();
            }
            hunters.destroy();
			
			Damage_UnregisterEvent(thistype.damageTrigger);
        }
        
        public static method onInit(){
            PunishmentCentre.initialize();
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function(){
				unit u = GetTriggerUnit();
				unit v = GetKillingUnit();
				
				if (!(thistype.isDefender(u) && Game.isMode("IDT"))) {
					thistype.onDeath(u, v);
				}
				
				u = null;
				v = null;
            });
        }
    }
   
}

//! endzinc