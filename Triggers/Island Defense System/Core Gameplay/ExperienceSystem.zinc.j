//! zinc
library ExperienceSystem requires ShowTagFromUnit, IsUnitWard {
    public struct PlayerDataFed extends PlayerDataExtension {
        module PlayerDataWrappings;
        
        private real mRate = 0.0;
        private integer mFed = 0;

        public method onSetup(){
            this.mFed = 0;
            GameSettings.setInt("KILLED_DEFENDERS_COUNT", 0);
        }
        
        private method setRate(real rate){
            this.mRate = rate;
        }
        
        public method rate() -> real {
            return this.mRate;
        }
        
        public method factor() -> real {
            // Difficulty = 1.0, factor = 100% (1.00)
            // Difficulty = 2.0, factor = 105% (1.05)
            // Difficulty = 3.0, factor = 110% (1.10)
            if (this.race().difficulty() == 0.0) return 0.0;
            return (0.95 + (this.race().difficulty() * .05));
        }
        
        public method fed() -> integer {
            return this.mFed;
        }
        
        public method add(integer feed){
            this.mFed = this.mFed + feed;
        }
		
		public method setFed(integer i) {
			this.mFed = i;
		}
        
        public method reset(){
            this.onSetup();
        }
        
        private static method getKilledDefendersCount() -> integer {
            return GameSettings.getInt("KILLED_DEFENDERS_COUNT");
        }
        
        public method updateRate(){
            real rate = this.factor();
			real time = (Game.currentGameElapsed() / (60.0 * 60.0));
            integer i = 0;
			
            if (GameSettings.getBool("TITAN_EXP_REDUCTION_ENABLED")){
				if (time >= 1.0) {
					time = 0.0;
					GameSettings.setBool("TITAN_EXP_REDUCTION_ENABLED", false);
                    Game.say("|cff87cefaThe Feed Reduction System has been disabled.|r");
				}
                rate = (this.factor() * ((((-this.fed() * 0.05) / 100) * (1.0 - time)) + 1));
                
                if (rate <= 0.0) {
                    rate = 0.0;
                }
            }
            
            // Global Factor
            rate = rate * GameSettings.getReal("TITAN_EXP_GLOBAL_FACTOR");
            
            // Defender player factor.
            // For this we need to calculate the amount of defenders alive + the amount killed.
            i = PlayerData.countClass(PlayerData.CLASS_DEFENDER) + thistype.getKilledDefendersCount();
            rate = rate * ( 1 + ((10 - i) * GameSettings.getReal("TITAN_EXP_MISSING_PLAYER_FACTOR")));
            
            if (GameSettings.getBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED")){
                rate = rate * 2.0;
            }
            
            this.mRate = rate;
        }
        
        public static method updateRates(){
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            thistype p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = thistype[list.at(i)];
                p.updateRate();
            }
            list.destroy();
        }
    }

    public struct FeedReduction {
        public static method reduceFeed(PlayerDataFed p, integer feed) -> integer {
            return R2I(feed * p.rate());
        }
    }
    
    private struct SharedExperienceUnit {
        public unit u;
        public real factor;
    }
    
    public struct ExperienceSystem {
        private static GameTimer rateUpdater = 0;
        public static method initialize(){
            PlayerDataFed.initialize();
            thistype.rateUpdater = GameTimer.newPeriodic(function(GameTimer t){
                if (PlayerDataFed.initialized()){
                    PlayerDataFed.updateRates();
                }
            });
            
            thistype.rateUpdater.start(GameSettings.getReal("DEFENDER_EXP_RATE_TIME"));
        }
        
        public static method terminate(){
            thistype.rateUpdater.destroy();
            thistype.rateUpdater = 0;
            PlayerDataFed.terminate();
        }
        
        public static method calculateFeed(PlayerDataFed p, unit u) -> integer {
            integer result = GetUnitPointValue(u);
			
            // Feed reduction
			if (p != 0) {
				result = FeedReduction.reduceFeed(p, result);
			}
			else {
				result = R2I(result * GameSettings.getReal("TITAN_EXP_NEUTRAL_FACTOR"));
			}

            return result;
        }
        
        public static method giveExperienceAsFeed(PlayerDataFed feeder, unit fed, integer experience) {
            if (feeder != 0) {
                feeder.add(experience);
            }
            thistype.giveExperience(fed, experience);
        }
        
        public static method giveExperience(unit u, integer experience){
            integer level = GetHeroLevel(u);
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            if (experience == 0) return;
            
            if (level >= 20) {
                p.setWood(p.wood() + experience);
                //ShowTagFromUnit("|ccf01bf4d+" + I2S(experience) + "|r", u);
            }
            else {
                SuspendHeroXP(u, false);
                AddHeroXP(u, experience, true);
                SuspendHeroXP(u, true);
                
                //ShowTagFromUnit("|cff0060ff+" + I2S(experience) + "|r", u);
            }
        }
        
        public static method shareExperienceFromPoint(real x, real y, integer feed, boolexpr b) {
            thistype.shareExperienceAsFeedFromPoint(0, x, y, feed, b);
        }
        
        private static unit lastKiller = null;
        public static method shareExperienceAsFeedFromPoint(PlayerDataFed feeder, real x, real y, integer feed, boolexpr b){
            group g = CreateGroup();
            real factor = 0.0;
            real total = 0.0;
            integer final = 0;
            unit u = null;
            integer i = 0;
            SharedExperienceUnit units[];
            integer unitsCount = 0;

            GroupEnumUnitsInRange(g, x, y, 4000.0, b);
            
            u = FirstOfGroup(g);
            while (u != null){
                factor = SquareRoot((x - GetUnitX(u)) * (x - GetUnitX(u)) + (y - GetUnitY(u)) * (y - GetUnitY(u)));
                factor = 1.0 - (((factor - 400.0) / 400.0) * 0.10);
                if (factor < 0.0) factor = 0.0; // Clamp negative
                if (factor > 1.0) factor = 1.0; // Clamp positive
				
				
                
                units[unitsCount] = SharedExperienceUnit.create();
                units[unitsCount].u = u;
                units[unitsCount].factor = factor;
                total = total + factor;
                unitsCount = unitsCount + 1;
                
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
            
            for (0 <= i < unitsCount) {
                u = units[i].u;
                factor = units[i].factor;
                final = R2I((feed * (factor / total)) * GameSettings.getReal("TITAN_EXP_SHARE_FACTOR"));
                thistype.giveExperienceAsFeed(feeder, u, final);
                units[i].destroy();
                units[i] = 0;
            }
            
            unitsCount = 0;            
            g = null;
            u = null;
        }
        
        public static method onDeathForTitan(){
            unit u = GetKillingUnit();
            unit v = GetDyingUnit();
            PlayerDataFed feeder = PlayerDataFed[PlayerData.get(GetOwningPlayer(v))];
            player k = GetOwningPlayer(u);
            integer feed = thistype.calculateFeed(feeder, v);
            boolexpr b = Filter(function() -> boolean {
                unit u = GetFilterUnit();
                boolean b = !IsUnit(u, thistype.lastKiller) &&
                            (UnitManager.isTitan(u) ||
                             UnitManager.isMinion(u));
                u = null;
                return b;
            });
            
            // Add to killing unit if it is a hero
            if (IsUnitType(u, UNIT_TYPE_HERO)){
                thistype.giveExperienceAsFeed(feeder, u, feed);
            }
            
            // Share bonus experience with others nearby
            thistype.lastKiller = u;
            thistype.shareExperienceAsFeedFromPoint(feeder, GetUnitX(v), GetUnitY(v), feed, b);
            thistype.lastKiller = null;
            
            DestroyBoolExpr(b);
            b = null;
            u = null;
            v = null;
            k = null;
        }
        
        public static method onInit(){
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
            TriggerAddCondition(t, Condition(function() -> boolean{
                unit u = GetKillingUnit();
                unit v = GetDyingUnit();
                PlayerData p = 0;
                PlayerData q = 0;
                boolean b = false;
                if (u == null || v == null) return false; // Ignore
                
                p = PlayerData.get(GetOwningPlayer(u));
                q = PlayerData.get(GetOwningPlayer(v));
				
				if (q == 0 && GetOwningPlayer(v) == Player(PLAYER_NEUTRAL_AGGRESSIVE)) {
					b = true;
				}
                
                b = (p.class() == PlayerData.CLASS_TITAN ||
                     p.class() == PlayerData.CLASS_MINION) &&
                    (b || q.class() == PlayerData.CLASS_DEFENDER);
				
				// Only ensure it's not summoned if we have a player (weird wc3 bug)
				if (q != 0)
					b = b && !(IsUnitType(v, UNIT_TYPE_SUMMONED) == true);
					
				b = b && !IsUnitWard(v);
				b = b && !IsUnitIllusion(v);
                    
                u = null;
                v = null;
                return b;
            }));
            TriggerAddAction(t, function(){
                thistype.onDeathForTitan();
            });
			
			t = CreateTrigger();
			TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_LEVEL);
			TriggerAddCondition(t, Condition(function() -> boolean {
				unit u = GetLevelingUnit();
				if (UnitManager.isDefender(u)) {
					MetaData.onLevel("defender", u);
				}
				else if (UnitManager.isMinion(u)) {
					MetaData.onLevel("minion", u);
				}
				else if (UnitManager.isTitan(u)) {
					MetaData.onLevel("titan", u);
				}
				return false;
			}));
            
            // Suspend all hero's experience
            t = CreateTrigger();
            TriggerRegisterEnterRectSimple(t, GetWorldBounds());
            TriggerAddAction(t, function(){
                unit u = GetEnteringUnit();
                if (IsUnitType(u, UNIT_TYPE_HERO)){
                    SuspendHeroXP(u, true);
                }
                u = null;
            });
            t = null;
        }
    }
}
//! endzinc