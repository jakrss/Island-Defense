//! zinc

library DefenderTweak requires TweakManager, UpgradeSystem {
    public struct DefenderTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Defender";
        }
        public method shortName() -> string {
            return "DEFENDER";
        }
        public method description() -> string {
            return "Takes over for a defender that has left the game.";
        }
        public method command() -> string {
            return "-defender,-builder";
        }
        
        public method takeOverLeaver(PlayerData p, PlayerData q){
			p.setClass(PlayerData.CLASS_DEFENDER);
			p.setGold(q.gold());
			p.setWood(q.wood());
			p.setRace(q.race());
			p.setUnit(q.unit());
			
			DefenderUnit.prepare(p); // Prepare the new Player (in case they are an Observer or something).
            UnitManager.givePlayerUnitsTo(q, p);
            SwapUpgrades(GetPlayerId(p.player()), GetPlayerId(q.player()));
			
			if (PlayerDataFed.initialized()) {
				PlayerDataFed[p].setFed(PlayerDataFed[q].fed());
			}
			
			q.setClass(PlayerData.CLASS_OBSERVER);
			q.left();
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            PlayerDataArray list = 0;
            integer i = 0;
			PlayerData r = 0;
            if (p.class() != PlayerData.CLASS_OBSERVER) return;
			if (args.size() > 0 && args[0].isPlayer()) {
				r = PlayerData.get(args[0].getPlayer());
			}
			
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
            for (0 <= i < list.size()){
                q = list.at(i);
                if (q.isLeaving() && !q.hasLeft()){
					if (r == 0 || q == r) {
						// We found a -defenderable player!
						Game.say(p.nameColored() + "|cff00bfff is taking over |r" + q.nameColored() + "|cff00bfff's units!|r");
						this.takeOverLeaver(p, q);
						break;
					}
                }
            }
            list.destroy();
        }
    }
}
//! endzinc