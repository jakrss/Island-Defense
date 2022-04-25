//! zinc

library PlayerDataPick requires Players, PlayerDataPickRandoming {
    /*
     *  A wrapper around PlayerData which is used in this system to track properties for the
     *  picking system, such as if the player has chosen yet etc.
     *
     */
    public struct PlayerDataPick {
        module PlayerDataWrappings;
        module PlayerDataPickRandoming;
        
        public method onSetup(){
            this.mPicked = false;
            this.freeCamera();
        }
        
        public method onTerminate(){
            this.removePicker();
        }
        
        private real mInitialX = 0;
        private real mInitialY = 0;
        
        public method setInitialPosition(real x, real y){
            this.mInitialX = x;
            this.mInitialY = y;
        }
        
        public method hasMoved() -> boolean {
            unit u = null;
            if (this.unit() != 0){
                u = this.unit().unit();
                return (GetUnitX(u) != this.mInitialX || GetUnitY(u) != this.mInitialY);
            }
            return false;
        }
        
        private boolean mRandoming = false;
        private boolean mCanPick = false;
        private boolean mPicked = false;
        
        private static integer PICKER_UNIT_ID = 'n00K';
        private unit mPickerUnit = null;
        
        public method createPicker(){
            if (playerData.class() == PlayerData.CLASS_TITAN){
                mPickerUnit = CreateUnit(playerData.player(), PICKER_UNIT_ID, -9952, 10304, 270);
            }
            else {
                mPickerUnit = CreateUnit(playerData.player(), PICKER_UNIT_ID, -10752, 8704, 0);
            }
        }
        
        public method picker() -> unit {
            return mPickerUnit;
        }
        
        public method removePicker(){
            RemoveUnit(mPickerUnit);
            mPickerUnit = null;
        }
        
        public method setPicked(boolean b){
            this.mPicked = b;
        }
        
        public method hasPicked() -> boolean {
            return this.mPicked;
        }
        
        private Race bannedRaces[100]; // Hard limit
        private integer bannedCount = 0;
        
        public method hasRandomBans() -> boolean {
            return this.bannedCount > 0;
        }
        
        public method addRaceRandomBan(Race r) -> boolean {
            this.bannedRaces[this.bannedCount] = r;
            this.bannedCount = this.bannedCount + 1;
            return true;
        }
        
        public method isRaceBanned(Race r) -> boolean {
            integer i = 0;
            if (!this.hasRandomBans()) return false;
            for (0 <= i < this.bannedCount) {
                if (this.bannedRaces[i] == r) {
                    return true;
                }
            }
            return false;
        }
        
        public method clearRaceRandomBans() {
            integer i = 0;
            for (0 <= i < this.bannedCount) {
                this.bannedRaces[i] = 0;
            }
            this.bannedCount = 0;
        }
		
		public method setAsRandomRace() -> Race {
			this.setRandoming(true);
			return thistype.setPlayerDataPickRandomRaceUniqueWithBans(this);
		}
		
        public method pick(Race r){
            if (r == NullRace.instance() || r == 0){
				r = this.setAsRandomRace();
            }
            
            this.playerData.setChosenRace(r, this.isRandoming());
            if (this.gold() <= 2) {
                this.setGold(0); // Set back down to 0
            }
            this.mPicked = true;
            RacePicker.picked(this);
        }
        
        public method canPick() -> boolean {
            return mCanPick;
        }
        
        public method setCanPick(boolean flag){
            mCanPick = flag;
            if (this.canPick()){
                if (this.isRandoming()){
                    this.pick(NullRace.instance());
                }
                else {
                    if (this.class() == PlayerData.CLASS_TITAN) 
                        this.say("|cff99b4d1You may now choose the titan of your choice and wreak havok upon the defenders.|r");
                    else 
                        this.say("|cff99b4d1You may now choose your Defender.|r");
                        
                    // 2g for Alpha Testers
                    if (PlayerDataPerks[this.playerData].perkByName("AlphaTesterPerk") != 0){
                        this.setGold(this.gold() + 1);
                    }
                    this.setGold(this.gold() + 1);
                    
                    
                    if (this.player() == GetLocalPlayer())
                        PlaySoundBJ(gg_snd_Ready);
                }
            }
            else {
                this.setGold(0);
            }
        }
        
        public method setRandoming(boolean flag){
            if (this.hasPicked()) return;
            mRandoming = flag;
        }
        
        public method isRandoming() -> boolean {
            return mRandoming;
        }
        
        public method restrictCamera(rect r){
            if (GetLocalPlayer() == playerData.player()){
                if (GameSettings.getBool("RESTRICT_CAMERA_BOUNDS")) {
                    SetCameraBoundsToRect(r);
                }
                else {
                    SetCameraBoundsToRect(bj_mapInitialCameraBounds);
                }
                
                PanCameraToTimed(GetRectCenterX(r), GetRectCenterY(r), 0.0);
            }
        }
        
        public method freeCamera(){
            if (GetLocalPlayer() == playerData.player()){
                SetCameraBoundsToRect(bj_mapInitialCameraBounds);
            }
        }
    }
}

//! endzinc