//! zinc

library PenaltyTimer requires GameTimer {
    public struct PenaltyTimer {
        private static integer PENALTY_30 = 1;
        private static integer PENALTY_10 = 2;
        
        private static real factor = 1.0;
        
        private static timerdialog td = null;
        private static GameTimer time = 0;
        
        static method newTimer(timer t) -> timerdialog {
            if (thistype.td != null) DestroyTimerDialog(thistype.td);
            thistype.td = CreateTimerDialog(t);
            return thistype.td;
        }
        static method timerDialog() -> timerdialog {
            return thistype.td;
        }
        static method initialize(){
            thistype.time = GameTimer.new(function(GameTimer t){
                integer penalty = t.data();
                PlayerDataArray list = 0;
                PlayerData p = 0;
                integer i = 0;
                if (penalty == PENALTY_30){
                    Game.say("|cff87cefaThe 30 minute penalty has been enforced.\n" +
                             "All remaining Defenders have now gained |r|cffffd70090|r|cff87cefa |r|cffffff00Gold|r|cff87cefa.|r");

                    list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
                    for (0 <= i < list.size()){
                        p = list.at(i);
                        p.setGold(p.gold() + 90);
                    }
                    list.destroy();
                    
                    //if (GameSettings.getBool("TITAN_EXP_REDUCTION_ENABLED")) {
                    //    Game.say("|cff87cefaThe Feed Reduction System has also been disabled.|r");
                    //    GameSettings.setBool("TITAN_EXP_REDUCTION_ENABLED", false);
                    //}
                }
                else {
                    Game.say("|cff87cefaThe 10 minute penalty has been enforced.\n" +
                             "All remaining Defenders have now gained |r|cffffd70030|r|cff87cefa |r|cffffff00Gold|r|cff87cefa.|r");
                    
                    // TODO: Give 30 gold
                    list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
                    for (0 <= i < list.size()){
                        p = list.at(i);
                        p.setGold(p.gold() + 30);
                    }
                    list.destroy();
                }

                GameTimer.new(function(GameTimer t){
                    Game.say("|cffffd7005|r|cff87cefa minutes until the 10 minute penalty will be enforced.\n" +
                             "All remaining Defenders will gain |r|cffffd70030|r|cff87cefa |r|cffffff00Gold|r|cff87cefa.|r");
                    TimerDialogSetTimeColor(thistype.timerDialog(), 255, 0, 0, 100);
                }).start(300.0 * thistype.factor);
                
                t.setData(PENALTY_10);
                t.start(600.0 * thistype.factor);
            });
            
            thistype.time.setData(PENALTY_30);
            
            thistype.newTimer(time.timer());
            TimerDialogSetTitle(thistype.timerDialog(), "|cffffff00Gold Penalty|r");
            TimerDialogSetTimeColor(thistype.timerDialog(), 255, 215, 0, 100);
            
            thistype.time.start(1800.0 * thistype.factor);
            
            // 0098e change: Disable display.
            TimerDialogDisplay(thistype.timerDialog(), false);
            
            GameTimer.newPeriodic(function(GameTimer t){
                integer remaining = t.data();
                if (remaining == 20){
                    TimerDialogSetTimeColor(thistype.timerDialog(), 255, 165, 0, 100);
                    Game.say("|cffffd70020|r|cff87cefa minutes until the 30 minute gold penalty will be enforced.\n" +
                             "All remaining Defenders will gain |r|cffffd70090|r|cff87cefa |r|cffffff00Gold|r|cff87cefa.|r");
                    t.setData(10);
                }
                else if (remaining == 10){
                    TimerDialogSetTimeColor(thistype.timerDialog(), 255, 0, 0, 100);
                    Game.say("|cffffd70010|r|cff87cefa minutes until the 30 minute gold penalty will be enforced.\n" +
                             "All remaining Defenders will gain |r|cffffd70090|r|cff87cefa |r|cffffff00Gold|r|cff87cefa.|r");
                    t.deleteLater();
                }
                else {
                    t.deleteLater();
                }
            }).start(600.0 * thistype.factor).setData(20);
        }
        static method terminate(){
            if (thistype.td != null)
                DestroyTimerDialog(thistype.td);
            if (thistype.time != 0)
                thistype.time.destroy();
            thistype.td = null;
            thistype.time = 0;
        }
    }
}

//! endzinc