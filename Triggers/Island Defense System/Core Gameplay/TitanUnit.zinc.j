//! zinc

library TitanUnit requires Unit, CreateItemEx {
    public struct TitanUnit extends Unit {
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
        
        public static method create(PlayerData p) -> thistype {
            thistype this = 0;
            if (p.class() != PlayerData.CLASS_TITAN){
                Game.say("WARNING - " + p.nameColored() + " tried to create TitanUnit but isn't CLASS_TITAN");
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = PlayerData.CLASS_TITAN;
            this.mOwner = p;
			
            return this;
        }
		
		public method spawn(real x, real y, real rotation) -> unit {
            this.mUnit = CreateUnit(this.mOwner.player(), this.mOwner.race().widgetId(), x, y, rotation);
			return this.mUnit;
		}
    }
    
    public struct TitanDeath {
        public static method baseExperience() -> real {
            return 0.3;
        }
        public static method onDeath(TitanUnit u, unit killer){
            PlayerData p = u.owner();
            PlayerData k = PlayerData.get(GetOwningPlayer(killer));
            real x=GetUnitX(u.unit());
            real y=GetUnitY(u.unit());
            integer level = 0;
            boolexpr b = null;
            
            if (k.class() != PlayerData.CLASS_DEFENDER){
                // Something went wrong, they were killed by something other than a titan
                Game.error("The player registered as the killer of the Titan was not of type CLASS_DEFENDER.");
            }
            
            // First up, ping the minimap to show everyone where the minion died.
            if (PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_TITAN) ||
                PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_MINION)){
                PingMinimapEx(x, y, 10.00, 254, 0, 0, true);
            }
            else {
                PingMinimapEx(x, y, 10.00, 0, 255, 0, true);
            }
            
            // Create chickens
            level = GetHeroLevel(u.unit());
            if (level < 3)
                CreateUnit(p.player(), 'n00C', x, y, 270);
            else if (level < 6)
                CreateUnit(p.player(), 'n018', x, y, 270);
            else
                CreateUnit(p.player(), 'n019', x, y, 270);
                
            // Create bones
            CreateItemEx('TBOH', x, y);
                
            // Announce death
            PlaySoundBJ(gg_snd_Titan_Death);
            Game.say(p.nameColored() + "|cff00bfff (Titan) has been vanquished by |r" + k.nameColored());
			
			MetaData.onDeath("titan", u.unit());
            
            // Remove corpse after 3 seconds
            GameTimer.new(function(GameTimer t){
                Unit u = t.data();
                RemoveUnit(u.unit());
            }).start(3.00).setData(u);
            
            // Experience
            b = Filter(function() -> boolean {
                unit u = GetFilterUnit();
                return UnitManager.isHunter(u);
            });
            
            ExperienceSystem.shareExperienceFromPoint(x, y, R2I(thistype.baseExperience() * GetHeroXP(u.unit())), b);
            DestroyBoolExpr(b);
            b = null;
            
            // Check if that was the last titan alive
            Game.checkVictory();
        }
    }
}

//! endzinc