//! zinc

library PlayerTweak requires TweakManager, PlayerDataPick {
    public struct PlayerTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Player";
        }
        public method shortName() -> string {
            return "PLAYER";
        }
        public method description() -> string {
            return "Gives you details about yourself, or the specified player if in debug mode.";
        }
        public method command() -> string {
            return ":/player";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public static method B2S(boolean b) -> string {
            if (b) return "true";
            return "false";
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            string s = "";
            boolean more = false;
            
            if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
            
            if (args.size() > 0 && args[0].isPlayer()){
                q = PlayerData.get(args[0].getPlayer());
                if (args.size() > 1 && args[1].isBool()) {
                    more = args[1].getBool();
                }
            }
            if (q == 0){
                p.say("Invalid player specified.");
                return;
            }
        
            s = I2S(q.id()) + " {Name=" + q.name() + ", Gold=" + I2S(q.gold()) + ", Wood=" + I2S(q.wood());
            s = s + ", isLeaving=" + thistype.B2S(q.isLeaving());
            s = s + ", hasLeft=" + thistype.B2S(q.hasLeft());
            if (q.hasLeft()){
                s = s + ", leftGameState=" + Game.stateString(q.leftGameState());
                s = s + ", leftGameId=" + I2S(q.leftGameId());
                s = s + ", leftClass=" + PlayerData.classToString(q.leftClass());
            }
            s = s + ", class=" + PlayerData.classToString(q.class());
            s = s + ", initialClass=" + PlayerData.classToString(q.initialClass());
            s = s + ", isFake=" + thistype.B2S(q.isFake());
            s = s + "}";
            p.say(s);
            
            if (!more) return;
            
            if (q.race() != 0){
                p.say("race().class() " + I2S(q.race().class()));
                p.say("race().toString() " + q.race().toString());
                //p.say("race().widgetId() " + ID2S(q.race().widgetId()));
                //p.say("race().itemId() " + ID2S(q.race().itemId()));
                p.say("race().itemOrder() " + I2S(q.race().itemOrder()));
                p.say("race().icon() " + q.race().icon());
                
                //p.say("race().childId() " + ID2S(q.race().childId()));
                p.say("race().childIcon() " + q.race().childIcon());
                //p.say("race().childItemId() " + ID2S(q.race().childItemId()));
                
                p.say("race().difficulty() " + R2S(q.race().difficulty()));
            }
            else {
                p.say("race() 0");
            }
            if (q.unit() != 0){
                p.say("PlayerData.unit().unit() " + GetUnitName(q.unit().unit()));
                p.say("PlayerData.unit().class() " + PlayerData.classToString(q.unit().class()));
                p.say("PlayerData.unit().race().toString() " + q.unit().race().toString());
                p.say("PlayerData.unit().owner().name() " + q.unit().owner().name());
            }
            if (PlayerDataPick.initialized()){
                p.say("PlayerDataPick.hasMoved() " + thistype.B2S(PlayerDataPick[q].hasMoved()));
                p.say("PlayerDataPick.hasPicked() " + thistype.B2S(PlayerDataPick[q].hasPicked()));
                p.say("PlayerDataPick.canPick() " + thistype.B2S(PlayerDataPick[q].canPick()));
                p.say("PlayerDataPick.isRandoming() " + thistype.B2S(PlayerDataPick[q].isRandoming()));
            }
            if (PlayerDataCamera.initialized()){
                p.say("PlayerDataCamera.distance() " + I2S(PlayerDataCamera[q].distance()));
                p.say("PlayerDataCamera.locked() " + thistype.B2S(PlayerDataCamera[q].locked()));
                p.say("PlayerDataCamera.smooth() " + thistype.B2S(PlayerDataCamera[q].smooth()));
            }
            if (PlayerDataFed.initialized()){
                p.say("PlayerDataFed.rate() " + R2S(PlayerDataFed[q].rate()));
                p.say("PlayerDataFed.factor() " + R2S(PlayerDataFed[q].factor()));
                p.say("PlayerDataFed.fed() " + I2S(PlayerDataFed[q].fed()));
            }
            if (PlayerDataSpeech.initialized()){
                p.say("PlayerDataSpeech.coolingDown() " + thistype.B2S(PlayerDataSpeech[q].coolingDown()));
                p.say("PlayerDataSpeech.wantsSilence() " + thistype.B2S(PlayerDataSpeech[q].wantsSilence()));
            }
            if (PlayerDataMultiboard.initialized()){
                p.say("PlayerDataMultiboard.isVoting() " + thistype.B2S(PlayerDataMultiboard[q].isVoting()));
                p.say("PlayerDataMultiboard.isVotingEnabled() " + thistype.B2S(PlayerDataMultiboard[q].isVotingEnabled()));
                if (PlayerDataMultiboard[q].current() != 0){
                    p.say("PlayerDataMultiboard.current().name() " + PlayerDataMultiboard[q].current().name());
                }
                else {
                    p.say("PlayerDataMultiboard.current() 0");
                }
            }
        }
    }
}
//! endzinc