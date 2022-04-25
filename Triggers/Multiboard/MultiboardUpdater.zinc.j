//! zinc

library MultiboardUpdater requires MultiboardManager {
    public struct MultiboardUpdater {
        private static GameTimer updateTimer = 0;

        public static method initialize() -> boolean {
            MultiboardManager.initialize();

            thistype.updateTimer = GameTimer.newNamedPeriodic(function(GameTimer t){
                thistype.update();
            }, "MultiboardUpdater").start(0.4); // 03125
            
            return true;
        }
        
        public static method update(){
            MultiboardManager.update();
        }
        
        public static method terminate(){
            MultiboardManager.terminate();
            thistype.updateTimer.destroy();
            thistype.updateTimer = 0;
        }
    }
}

//! endzinc
