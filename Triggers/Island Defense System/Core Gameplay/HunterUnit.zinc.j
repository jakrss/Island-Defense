//! zinc

library HunterUnit requires Unit {
    public struct HunterUnit extends Unit {
        private unit mUnit = null;
        private integer mClass = 0;
        private Race mRace = 0;
        private PlayerData mOwner = 0;
        
        public method unit() -> unit {
            return this.mUnit;
        }
        public method class() -> integer {
            return this.mClass;
        }
        public method race() -> Race {
            return this.mRace;
        }
        public method owner() -> PlayerData {
            PlayerData data = 0;
            if (this.mUnit != null){
                data = PlayerData.get(GetOwningPlayer(this.mUnit));
                return data;
            }
            return this.mOwner;
        }
        
        public static method fromUnit(unit u) -> thistype {
            thistype this = 0;
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            if (p.class() != PlayerData.CLASS_DEFENDER){
                Game.say("ERROR - " + p.nameColored() + " tried to respawn HunterUnit but isn't a CLASS_DEFENDER");
                return this;
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = PlayerData.CLASS_DEFENDER;
            this.mOwner = p;
            
            this.mUnit = u;
            
            return this;
        }
        
        public static method create(PlayerData p) -> thistype {
            thistype this = 0;
            if (p.class() != PlayerData.CLASS_DEFENDER){
                Game.say("ERROR - " + p.nameColored() + " tried to create HunterUnit but isn't a CLASS_DEFENDER");
                return this;
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = p.race();
            this.mOwner = p;
            
            return this;
        }
		
		public method onDestroy() {
			this.mUnit = null;
		}
		
		public method spawn(real x, real y, real rotation) -> unit {
            // We want the child (hunter)
		BJDebugMsg("Hunter Spawned");
            this.mUnit = CreateUnit(this.mOwner.player(), this.mOwner.race().childId(), x, y, rotation);
			return this.mUnit;
		}
    }
    
    public struct HunterDeath {
        public static method onDeath(HunterUnit u, unit killer){
            PlayerData p = 0;
            PlayerData k = 0;
            real x = 0.0;
            real y = 0.0;
            unit v = null;
            
            if (killer == null) return; // Balth or Sui or something...
            
            p = u.owner();
            k = PlayerData.get(GetOwningPlayer(killer));
            x = GetUnitX(u.unit());
            y = GetUnitY(u.unit());
            v = p.unit().unit();
            
            if (IsUnitLoaded(v) &&
                IsUnitInTransport(v, u.unit())) {
            }
            
            if (k.class() == PlayerData.CLASS_TITAN ||
                k.class() == PlayerData.CLASS_MINION){
                PlaySoundBJ(gg_snd_Titan_HunterKill);
                Game.say(p.nameColored() + "|cff00bfff's |r|cff00ff00Titan Hunter|r|cff00bfff has been slain by |r" + 
                         k.nameColored() + "|cff00bfff!|r");
            }
            else {
                Game.say(p.nameColored() + "|cff00bfff's |r|cff00ff00Titan Hunter|r|cff00bfff has been denied by |r" +
                         k.nameColored() + "|cff00bfff!|r");
            }
        }
    }
    
    public function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_REVIVE_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetRevivingUnit();
            integer i = GetUnitTypeId(u);
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            
            if (i == p.race().childId()){
                UnitManager.hunterRespawn(u);
            }
            
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc