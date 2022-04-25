//! zinc

library CameraTweak requires TweakManager, GameTimer {
    public struct PlayerDataCamera extends PlayerDataExtension {
        module PlayerDataWrappings;
        
        private integer mDistance = 100;
        private boolean mLocked = false;
        private boolean mSmooth = false;
        
        public method onSetup(){
        }
        
        public method locked() -> boolean {
            return this.mLocked;
        }
        
        public method distance() -> integer {
            return this.mDistance;
        }
        
        public method reset(){
            this.mDistance = 100;
            this.mLocked = false;
            this.setDistance(this.mDistance, 0.0);
            this.setSmooth(false);
            this.say("|cff00bfffYour camera has been reset.|r");
        }
        
        public method setDistance(integer i, real time){
            integer result = 0;
            string s = "";
            this.mDistance = i;
            if (i < 50) i = 50;
            if (i > 400) i = 400;
            s = "|cff00bfffYour camera's zoom level has now been set to " + I2S(i) + "%";
            if (i == 400) s = s + " (max distance)";
            if (i == 50) s = s + " (min distance)";
            s = s + "|r";
            
            result = R2I(i * (bj_CAMERA_DEFAULT_DISTANCE / 100) + 50);
            if (GetLocalPlayer() == this.player()){
                if (GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) != result){
                    SetCameraField(CAMERA_FIELD_FARZ, bj_CAMERA_DEFAULT_FARZ + (result - bj_CAMERA_DEFAULT_DISTANCE), 0);
                    SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, result, time);
                    if (!this.mLocked)
                        this.say(s);
                }
            }
        }
        
        public method smooth() -> boolean {
            return this.mSmooth;
        }
        
        public method setSmooth(boolean b){
            string s = "";
            if (b)
                s = "|cff00bfffCamera smoothing has been |r|cffff0000enabled.|r";
            else
                s = "|cff00bfffCamera smoothing has been |r|cffff0000disabled.|r";
            this.mSmooth = b;
            if (GetLocalPlayer() == this.player()){
                if (b){
                    CameraSetSmoothingFactor(5.0);
                }
                else {
                    CameraSetSmoothingFactor(0.0);
                }
                this.say(s);
            }
        }
        
        public method lock(){
            this.say("|cff00bfffYour camera's distance has been locked in position.|r");
            this.mLocked = true;
        }
        
        public method lockDistance(integer i){
            this.setDistance(i, 0.0);
            this.lock();
        }
        
        public method unlock(){
            this.say("|cff00bfffYour camera's distance has been unlocked.|r");
            this.mLocked = false;
            this.mDistance = 100;
        }
        
        public method update(){
            if (this.mLocked){
                this.setDistance(this.mDistance, 0.0);
            }
        }
        
        public static method updateAll(){
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                if (thistype[list.at(i)] != 0){
                    thistype[list.at(i)].update();
                }
            }
            list.destroy();
        }
    }
    
    public struct CameraTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Cam";
        }
        public method shortName() -> string {
            return "CAMERA";
        }
        public method description() -> string {
            return "Allows you to control your game camera.";
        }
        public method command() -> string {
            return "-c,-cam,-camera,-zoom";
        }
        
        public method initialize(){
            PlayerDataCamera.initialize();
            GameTimer.newNamedPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (PlayerDataCamera.initialized()){
                    PlayerDataCamera.updateAll();
                }
                else {
                    t.deleteLater();
                }
            }, "CameraLockTimer").start(0.5).setData(this);
        }
        
        public method terminate(){
            PlayerDataCamera.terminate();
        }
        
        public method activate(Args args){
            PlayerDataCamera p = PlayerDataCamera[PlayerData.get(GetTriggerPlayer())];
            string arg = "";
            integer index = 0;
			
			// 0104 - Idea from RipDog to disable tip messages if you use the -cam command!
			p.playerData.disableTips();
			
            if (args.size() == 0){
                p.reset();
                return;
            }
            while (index < args.size()){
                // -cam [dist]
                if (args[index].isInt()){
                    p.setDistance(args[index].getInt(), 1.0);
                }
                else {
                    arg = StringCase(args[index].getStr(), false);
                    // -cam scroll [on/off]
                    if (arg == "scroll" || arg == "s"){
                        if ((args.size() - index) > 1){
                            index = index + 1;
                            arg = StringCase(args[index].getStr(), false);
                            if (arg == "on"){
                                p.setSmooth(true);
                            }
                            else if (arg == "off"){
                                p.setSmooth(false);
                            }
                            else {
                                index = index - 1;
                                // Toggle
                                p.setSmooth(!p.smooth());
                            }
                        }
                        else {
                            // Toggle
                            p.setSmooth(!p.smooth());
                        }
                    }
                    // -cam lock [dist/on/off]
                    else if (arg == "lock" || arg == "l"){
                        if ((args.size() - index) > 1){
                            index = index + 1;
                            if (args[index].isInt()){
                                p.lockDistance(args[index].getInt());
                            }
                            else {
                                arg = StringCase(args[index].getStr(), false);
                                if (arg == "on"){
                                    p.lock();
                                }
                                else if (arg == "off") {
                                    p.unlock();
                                }
                                else {
                                    index = index - 1;
                                    // Default
                                    p.lock();
                                }
                            }
                        }
                        else {
                            p.lock();
                        }
                    }
                    // -cam unlock
                    else if (arg == "unlock" || arg == "u"){
                        p.unlock();
                    }
                    // -cam reset
                    else if (arg == "reset" || arg == "r"){
                        p.reset();
                    }
                    else {
                        p.say("|cffff0000Unknown request: |r" + arg + "|cffff0000.|r");
                    }
                }
                index = index + 1;
            }
        }
    }
}
//! endzinc