//! zinc

library ObserverTweak requires TweakManager {
    public struct ObserverTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Obs";
        }
        public method shortName() -> string {
            return "OBS";
        }
        public method description() -> string {
            return "Allows you to move yourself to an Observer slot.";
        }
        public method command() -> string {
            return "-obs,-observer,-spec,-spectate";
        }
        
        public method moveToObserver(PlayerData p, PlayerData q){
            // p = Titan
            // q = Minion (moving themselves)
			if (p != 0) {
				UnitManager.givePlayerUnitsTo(q, p);
				p.setGold(p.gold() + q.gold());
				p.setWood(p.wood() + q.wood());
				PunishmentCentre.update();
				Game.say(q.nameColored() + "|cff00bfff has moved themselves from being a minion and now is an observer of the defenders. " +
                                       "Should this player become an annoyance you can remove them by using the -boot command.");
			}
			else {
				UnitManager.removePlayerUnits(q);
				Game.say(q.nameColored() + "|cff00bfff has moved themselves from being a defender and now is an observer of the defenders. " +
                                       "Should this player become an annoyance you can remove them by using the -boot command.");
			}
            
            
            q.setClass(PlayerData.CLASS_OBSERVER);
            q.setRace(NullRace.instance());
            q.setGold(0);
            q.setWood(0);
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            
            if (p.class() == PlayerData.CLASS_MINION){
            
				list = PlayerData.withClass(PlayerData.CLASS_TITAN);
				for (0 <= i < list.size()){
					q = list.at(i);
					if (q.race() == p.race()){
						break;
					}
				}
				list.destroy();
				this.moveToObserver(q, p);
			}
			else if (p.class() == PlayerData.CLASS_DEFENDER && GameSettings.getBool("DEBUG")) {
				this.moveToObserver(0, p);
			}
        }
    }
}
//! endzinc