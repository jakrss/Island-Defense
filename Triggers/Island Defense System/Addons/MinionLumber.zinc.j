//! zinc

library MinionLumber requires GameTimer {
    public struct MinionLumber {
        private static GameTimer tickTimer = 0;
        
        static method initialize() {
            thistype.tickTimer = GameTimer.newNamedPeriodic(function(GameTimer t) {
                PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_MINION);
                PlayerData p = 0;
                integer i = 0;
                integer lumber = 0;
                for (0 <= i < list.size()){
                    p = list.at(i);
                    if (p.wood() > 0) {
                        lumber = lumber + p.wood();
                        p.say("|cfff0bfffYour lumber has been distributed to the Titan.|r");
                        p.setWood(0);
                    }
                }
                list.destroy();
                
                lumber = (lumber / PlayerData.countClass(PlayerData.CLASS_TITAN));
                
                if (lumber == 0) return;
                
                // Now distribute between all titans
                list = PlayerData.withClass(PlayerData.CLASS_TITAN);
                for (0 <= i < list.size()){
                    p = list.at(i);
                    p.say("|cfff0bfffYou have gained |cffffff00" + I2S(lumber) + "|r|cfff0bfff lumber from your Minions.|r");
                    p.setWood(p.wood() + lumber);
                }
                list.destroy();
                list = 0;
            }, "MinionLumber");
            
            thistype.tickTimer.start(60.0);
        }
        
        static method terminate(){
            thistype.tickTimer.destroy();
            thistype.tickTimer = 0;
        }
    }
}

//! endzinc