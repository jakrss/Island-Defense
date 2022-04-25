//! zinc

library MinionUnit requires Unit, UnitStatus {
    public struct MinionUnit extends Unit {
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
        
        public static method grace(Unit u){
            unit v = u.unit();
            real time = GameSettings.getReal("MINION_GRACE_TIME");
            if (v == null) return; // Sanity check
            SilenceUnitTimed(v, time);
            SetUnitInvulnerable(v, true);
            UnitAddAbility(v, '&noa'); // Disable attack
            
            GameTimer.newNamed(function(GameTimer t){
                Unit u = t.data();
                // Check to make sure it hasn't already been removed via punishing
				if (GetUnitAbilityLevel(u.unit(), '&noa') > 0) {
					SetUnitInvulnerable(u.unit(), false);
					UnitRemoveAbility(u.unit(), '&noa');
				}
            }, "MinionGrace").start(time).setData(u);
        }
        
        public static method create(PlayerData p) -> thistype {
            thistype this = 0;
            if (p.class() != PlayerData.CLASS_MINION &&
                p.class() != PlayerData.CLASS_TITAN){
                Game.say("WARNING - " + p.nameClass() + " tried to create MinionUnit but isn't CLASS_MINION/TITAN");
            }
            this = thistype.allocate();
            this.mClass = p.class();
            this.mRace = PlayerData.CLASS_MINION; //p.race();
            this.mOwner = p;
            
            return this;
        }
		
		public method spawn(real x, real y, real rotation) -> unit {
            this.mUnit = CreateUnit(this.mOwner.player(), this.mOwner.race().childId(), x, y, rotation);
			
			// Grace time
            if (GameSettings.getBool("MINION_ALLOW_GRACE")){
                GameTimer.newNamed(function(GameTimer t){
                    thistype.grace(t.data());
                }, "MinionGraceStartDelay").start(0.25).setData(this);
            }
			return this.mUnit;
		}
    }
    
    public struct MinionDeath {
        public static method baseExperience() -> real {
            return 0.5; // * minion level
        }

        public static method onDeath(MinionUnit u, unit killer){
            PlayerData p = u.owner();
            PlayerData k = PlayerData.get(GetOwningPlayer(killer));
            real x=GetUnitX(u.unit());
            real y=GetUnitY(u.unit());
            integer level = 0;
            boolexpr b = null;
            
            if (k.class() != PlayerData.CLASS_DEFENDER){
                // Something went wrong, they were killed by something other than a titan
                Game.error("The player registered as the killer of the minion was not of type CLASS_DEFENDER.");
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
            CreateItemEx('MBOH', x, y);
                
            // Announce death
            PlaySoundBJ(gg_snd_Minion_Death);
            Game.say(p.nameColored() + "|cff00bfff (Titanous Minion) has been slain by |r" + k.nameColored());
            
			MetaData.onDeath("minion", u.unit());
			
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
            
            // Check if that was the last minion alive
            Game.checkVictory();
        }
    }
}

//! endzinc