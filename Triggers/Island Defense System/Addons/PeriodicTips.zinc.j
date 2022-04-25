//! zinc

library PeriodicTips requires GameTimer {
    public struct PeriodicTips {
        private static string tips[];
        private static integer index = 0;
        
        public static method newTip(string s){
            thistype.tips[thistype.index] = s;
            thistype.index += 1;
        }
        
        private static integer lastIndex = 0;
        private static method getTip() -> string {
            integer i = GetRandomInt(0, thistype.index - 1);
            while (i == thistype.lastIndex){
                i = GetRandomInt(0, thistype.index - 1);
            }
            lastIndex = i;
            return thistype.tips[i];
        }
        
        private static method tick(){
			PlayerDataArray list = 0;
			integer i = 0;
			PlayerData p = 0;
            if (GetRandomInt(0, 1) == 0) return;
			list = PlayerData.all();
			for (0 <= i < list.size()) {
				p = list[i];
				if (p.tips()) {
					p.say(thistype.getTip());
				}
			}
			list.destroy();
        }
        
        private static GameTimer tipsTimer = 0;
        public static method initialize(){
            thistype.tipsTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype.tick();
            });
            thistype.tipsTimer.start(120.0);
        }
        public static method terminate(){
            thistype.tipsTimer.destroy();
        }
        
        private static method onInit(){
            thistype.newTip("|cff00bfffFirst time playing? Confused about how to get |r|cffffff00Gold|r|cff00bfff?\n" + 
                            "Check the Guide (F9) for more information.|r");
            thistype.newTip("|cff00bfffThe Titan can now use lumber to upgrade his defenses! Check out the Gold Mound.|r");
            thistype.newTip("|cff00bfffUnsure of what a command does? Use -help to find out!|r");
            thistype.newTip("|cff00bfffInterested in discussing Island Defense online? Check out our forums at entgaming.net.|r");
            thistype.newTip("|cff00bfffHave an idea, or a bug to submit? Post it on our forums at entgaming.net.|r");
        }
    }
}

//! endzinc