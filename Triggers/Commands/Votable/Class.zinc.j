//! zinc

library ClassTweak requires TweakManager, Players, GameTimer {
    public struct PlayerDataName extends PlayerDataExtension {
        module PlayerDataWrappings;
        
        private boolean mShowClass = true;
        public method showClass() -> boolean {
            return this.mShowClass;
        }
        
        public method setShowClass(boolean b){
            this.mShowClass = b;
        }
        
        private static method setPlayerNameForPlayer(PlayerData p, PlayerData q, string name){
            // p = for Player
            // q = other Player (with the name we want to set)
            // name = name
            if (GetLocalPlayer() == p.player()){
                SetPlayerName(q.player(), name);
            }
        }
        
        private static method setPlayerNameSmart(PlayerData p, PlayerData q){
            // Doesn't show class
            if (!PlayerDataName.initialized() ||
                !PlayerDataName[p].showClass()){
                thistype.setPlayerNameForPlayer(p, q, q.name());
                return;
            }
            // Do show class
            if (p.class() == PlayerData.CLASS_DEFENDER || // From a defenders perspective
                p.class() == PlayerData.CLASS_OBSERVER){
                
                if (q.class() == PlayerData.CLASS_DEFENDER){
                    if (PlayerDataPick.initialized() &&
                        PlayerDataPick[q].hasPicked() == false) {
                        thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                    }
                    else {
                        thistype.setPlayerNameForPlayer(p, q, q.nameRace());
                    }
                }
                else if (q.class() == PlayerData.CLASS_OBSERVER){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
                else if (q.class() == PlayerData.CLASS_TITAN){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
                else if (q.class() == PlayerData.CLASS_MINION){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
                
            }
            else { // From a titans perspective
                if (q.class() == PlayerData.CLASS_DEFENDER){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
                else if (q.class() == PlayerData.CLASS_OBSERVER){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
                else if (q.class() == PlayerData.CLASS_TITAN){
                    if (PlayerDataPick.initialized() &&
                        PlayerDataPick[q].hasPicked() == false) {
                        thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                    }
                    else {
                        thistype.setPlayerNameForPlayer(p, q, q.nameRace());
                    }
                }
                else if (q.class() == PlayerData.CLASS_MINION){
                    thistype.setPlayerNameForPlayer(p, q, q.nameClass());
                }
            }
        }
        
        public static method updateForPlayer(PlayerData p) {
            PlayerDataArray list = PlayerData.all();
            PlayerData q = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                q = list[i];
                thistype.setPlayerNameSmart(p, q);
            }
            list.destroy();
        }
        
        public static method update(){
            PlayerDataArray list = PlayerData.all();
            PlayerData p = 0;
            PlayerData q = 0;
            integer i = 0;
            integer j = 0;
            for (0 <= i < list.size()){
                p = list[i];
                for (0 <= j < list.size()){
                    q = list[j];
                    thistype.setPlayerNameSmart(p, q);
                }
            }
            list.destroy();
        }
    }
    public struct ClassTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Class";
        }
        public method shortName() -> string {
            return "CLASS";
        }
        public method description() -> string {
            return "Toggles showing the players class after their name.";
        }
        public method command() -> string {
            return "-class"; // on/off
        }
        
        private GameTimer ticker = 0;
        
        public method initialize(){
            PlayerDataName.initialize();
            PlayerDataName.update();
        }
        
        public method terminate(){
            PlayerDataName.terminate();
            this.ticker.destroy();
            this.ticker = 0;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            string arg = "";
            
            if (!PlayerDataName.initialized()) {
                // System not ready yet
                return;
            }
            
            if (args.size() > 0){
                arg = StringCase(args[0].getStr(), false);
                if (arg == "on"){
                    PlayerDataName[p].setShowClass(true);
                    PlayerDataName.updateForPlayer(p);
                    p.say("|cff00bfffPlayer class information has been turned |r|cffff0000on|r|cff00bfff.|r");
                }
                else {
                    PlayerDataName[p].setShowClass(false);
                    PlayerDataName.updateForPlayer(p);
                    p.say("|cff00bfffPlayer class information has been turned |r|cffff0000off|r|cff00bfff.|r");
                }
            }
            else {
                p.say("|cff00bfffCommand usage: |r-class|cff00bfff <|r|cffff0000on|r|cff00bfff/|r|cffff0000off|r|cff00bfff>|r");
            }
        }
    }
}
//! endzinc