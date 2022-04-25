//! zinc

library MultiboardManager requires PlayerDataMultiboard {
    public struct MultiboardManager {
        private static ClassBoard classBoards[];
        private static integer index = 0;
        
        public static method register(ClassBoard b){
            thistype.classBoards[thistype.index] = b;
            thistype.index = thistype.index + 1;
        }
        
        public static method classBoard(integer class) -> ClassBoard {
            integer i = 0;
            for (0 <= i < thistype.index){
                if (thistype.classBoards[i].forClass(class)){
                    //Game.say("ClassBoard for (" + PlayerData.classToString(class) + ") is " + thistype.classBoards[i].name());
                    return thistype.classBoards[i];
                }
            }
            return 0;
        }
        
        public static method initialize(){
            integer i = 0;

            //Game.say("MultiboardManager initializing with " + I2S(thistype.index) + " boards");
            for (0 <= i < thistype.index){
                thistype.classBoards[i].initialize();
            }
            
            PlayerDataMultiboard.initialize();
        }
        
        public static method terminate(){
            integer i = 0;
            
            PlayerDataMultiboard.terminate();

            for (0 <= i < thistype.index){
                thistype.classBoards[i].terminate();
            }
            
            VoteBoardGeneric.instance().terminate();
        }
        
        public static method update(){
            integer i = 0;

            // Update players
            PlayerDataMultiboard.updateAll();
            // Update boards
            for (0 <= i < thistype.index){
                thistype.classBoards[i].update();
            }
            // Update vote board
            VoteBoardGeneric.instance().update();
        }
    }
}

//! endzinc
