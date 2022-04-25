//! zinc

library TimerTweak requires TweakManager, GameTimer {
    public struct TimerTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Timer";
        }
        public method shortName() -> string {
            return "TIMER";
        }
        public method description() -> string {
            return "Prints out the list of currently running timers.";
        }
        public method command() -> string {
            return ":/timers";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            PlayerData q = 0;
            
            if (!GameSettings.getBool("DEBUG") && p.name() != GameSettings.getStr("EDITOR")) return;
            
            if (IsGameTimerRunning()) {
                Game.say("Game Timer is currently: running for " + ElapsedGameTime.getTimeString());
            }
            GameTimer.printList();
        }
    }
}
//! endzinc