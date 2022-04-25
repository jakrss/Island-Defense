//! zinc

library KickTweak requires TweakManager {
    public struct KickTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Kick";
        }
        public method shortName() -> string {
            return "KICK";
        }
        public method description() -> string {
            return "Kicks the specified minion player and moves them to an Observer slot. Only usable by the Titan.";
        }
        public method command() -> string {
            return "-kick";
        }
        
        public method moveToObserver(PlayerData p, PlayerData q){
            // p = Titan
            // q = Minion (being kicked)
            UnitManager.givePlayerUnitsTo(q, p);
            
            p.setGold(p.gold() + q.gold());
            p.setWood(p.wood() + q.wood());
            
            q.setClass(PlayerData.CLASS_OBSERVER);
            q.setRace(NullRace.instance());
            q.setGold(0);
            q.setWood(0);
            PunishmentCentre.update();
            
            Game.say(q.nameColored() + "|cff00bfff is now is an observer of the defenders. " +
                                       "Should this player become an annoyance you can remove them by using the -boot command.");
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            PlayerDataArray list = 0;
            if (p == 0 || p.class() != PlayerData.CLASS_TITAN) return;
            if (args.size() > 0){
                if (args[0].isPlayer()){
                    q = PlayerData.get(args[0].getPlayer());
                    if (q == 0 || q.class() != PlayerData.CLASS_MINION){
                        p.say("|cffff0000The player you specified was not a minion player.|r");
                    }
                    else {
                        this.moveToObserver(p, q);
                    }
                }
                else {
                    p.say("|cffff0000Sorry, the player you specified could not be found.|r");
                }
            }
            else {
                list = PlayerData.withClass(PlayerData.CLASS_MINION);
                if (list.size() == 1){
                    this.moveToObserver(p, list.at(0));
                }
                else {
                    p.say("|cffff0000You must provide a minion player to kick.|r");
                }
                list.destroy();
            }
        }
    }
}
//! endzinc