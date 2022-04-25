//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library GiveTweak requires TweakManager {
    public struct GiveTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Give";
        }
        public method shortName() -> string {
            return "GIVE";
        }
        public method description() -> string {
            return "Gives the specified Titan or Minion an amount of your gold.";
        }
        public method command() -> string {
            return "-give";
        }
        
        public method activate(Args args){
            // -give Neco 1 
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            integer amount = 0;
            
            if (p.class() != PlayerData.CLASS_TITAN &&
                p.class() != PlayerData.CLASS_MINION) return;
            
            if (args.size() > 0){
                if (args[0].isPlayer()){
                    q = PlayerData.get(args[0].getPlayer());
                    if (q == 0 || (q.class() != PlayerData.CLASS_TITAN &&
                                   q.class() != PlayerData.CLASS_MINION)){
                        p.say("|cffff0000Please specify a valid player.|r");
                        return;
                    }
                    
                    amount = 0;
                    
                    if (args.size() > 1){
                        // -give Neco 20
                        if (args[1].isInt()){
                            amount = args[1].getInt();

                            if (p.gold() < amount){
                                amount = p.gold();
                            }
                        }
                    }
                    else {
                        // -give Neco
                        amount = p.gold();
                        
                    }
                    
                    if (amount > 0) {
                        if (amount == p.gold()) {
                            p.say("|cff00bfffYou have given|r " + q.nameColored() + " |cff00bfffall of your gold.|r");
                        }
                        else {
                            p.say("|cff00bfffYou have given|r " + q.nameColored() + " |cffffff00" + I2S(amount) +
                                  " |r|cff00bfffgold|r.");
                        }
                        p.setGold(p.gold() - amount);
                        q.setGold(q.gold() + amount);
                        q.say("|cff00bfffYou have recieved|r |cffffff00" + I2S(amount) + " |r|cff00bfffgold from |r" +
                              p.nameColored() + "|cff00bfff.|r");
                        return;
                    }
                }
            }
            p.say("|cff00bfffCommand Usage: -give <player> [amount]|r");
        }
    }
}
//! endzinc