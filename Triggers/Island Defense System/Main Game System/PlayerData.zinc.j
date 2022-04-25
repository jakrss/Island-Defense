//! zinc

library Players requires Races, GetPlayerColored {
    /*
     *  A wrapper around the "player" type
     *  Provides OOP to player objects and specific classes to Island Defense
     *
     *
     *
     *
     */
     
    public module PlayerFunctions {
		public static constant integer MaxPlayers = bj_MAX_PLAYER_SLOTS;
        private static PlayerData players[];
        private static PlayerData lastPlayers[];
        public static method operator [](integer i) -> thistype {
            return thistype.players[i];
        }
        public static method get(player p) -> thistype {
            return thistype.players[GetPlayerId(p)];
        }
        public static method has(player p) -> boolean {
            return (thistype.get(p) != 0);
        }
        public static method hasById(integer i) -> boolean {
            return (thistype.players[i] != 0);
        }
        public static method remove(player p){
            if (thistype.has(p)){
                thistype.players[GetPlayerId(p)].destroy();
            }
            thistype.players[GetPlayerId(p)] = 0;
        }
        public static method count() -> integer {
            integer i = 0;
            integer count = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i))){
                    count = count + 1;
                }
            }
            return count;
        }

        public static method countReal() -> integer {
            PlayerDataArray list = thistype.allReal();
            integer i = list.size();
            list.destroy();
            return i;
        }
        public static method allReal() -> PlayerDataArray {
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerDataArray.create();
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i)) &&
					!thistype.players[i].isLeaving() &&
                    !thistype.players[i].hasLeft() &&
                    !thistype.players[i].isFake()){
                    list.append(thistype.players[i]);
                }
            }
            return list;
        }

        public static method countClass(integer class) -> integer {
            PlayerDataArray list = thistype.withClass(class);
            integer i = list.size();
            list.destroy();
            return i;
        }
        public static method withClass(integer class) -> PlayerDataArray {
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerDataArray.create();
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i)) &&
                    !thistype.players[i].hasLeft() &&
                    thistype.players[i].class() == class){
                    list.append(thistype.players[i]);
                }
            }
            return list;
        }
        public static method countRace(Race r) -> integer {
            PlayerDataArray list = thistype.withRace(r);
            integer i = list.size();
            list.destroy();
            return i;
        }
        public static method withRace(Race r) -> PlayerDataArray {
            PlayerDataArray list = PlayerDataArray.create();
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i)) &&
                    !thistype.players[i].hasLeft() &&
                    thistype.players[i].race() == r){
                    list.append(thistype.players[i]);
                }
            }
            return list;
        }
        public static method classToString(integer c) -> string {
            string s = "";
            if (c == CLASS_NONE)
                s = "";
            else if (c == CLASS_MINION)
                s = "Minion";
            else if (c == CLASS_TITAN)
                s = "Titan";
            else if (c == CLASS_DEFENDER)
                s = "Defender";
            else if (c == CLASS_OBSERVER)
                s = "Observer";
            else
                s = "Unknown #" + I2S(c);
            return s;
        }
        public static method all() -> PlayerDataArray {
            PlayerDataArray list = PlayerDataArray.create();
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i))){
                    if (!thistype.players[i].hasLeft())
                        list.append(thistype.players[i]);
                }
            }
            return list;
        }

        public static method countLeavers() -> integer {
            PlayerDataArray list = thistype.leavers();
            integer i = list.size();
            list.destroy();
            return i;
        }

        public static method leavers() -> PlayerDataArray {
            PlayerDataArray list = PlayerDataArray.create();
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i))){
                    if (thistype.players[i].hasLeft())
                        list.append(thistype.players[i]);
                }
            }
            return list;
        }

        public static method classLikes(integer class, integer likes) -> boolean {
            if (class == thistype.CLASS_TITAN){
                return (likes == CLASS_TITAN || likes == CLASS_MINION);
            }
            if (class == thistype.CLASS_MINION){
                return (likes == CLASS_TITAN || likes == CLASS_MINION);
            }
            if (class == thistype.CLASS_DEFENDER){
                return (likes == CLASS_OBSERVER || likes == CLASS_DEFENDER);
            }
            if (class == thistype.CLASS_OBSERVER){
                return (likes == CLASS_OBSERVER || likes == CLASS_DEFENDER);
            }
            return false;
        }

        public static method forceAlliances(){
            PlayerDataArray list = 0;
            integer i = 0;
            integer j = 0;
            PlayerData p = 0;
            PlayerData q = 0;

            list = thistype.all();
            for (0 <= i < list.size()){
                p = list[i];
                for (0 <= j < list.size()){
                    q = list[j];
                    if (p != q){
                        if (thistype.classLikes(p.class(), q.class())){
                            if (!IsPlayerAlly(p.player(), q.player()) ||
                                !GetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_VISION)) {
				//if(p.id() > 10) BJDebugMsg("Set shared vision to true from P" + I2S(p.id()) + " to P" + I2S(q.id()));
                                SetPlayerAllianceStateAllyBJ(p.player(), q.player(), true);
                                SetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_VISION, true);
                            }
                            if ((p.isLeaving() && !p.hasLeft()) &&
                                !GetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_CONTROL)){
                                SetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_CONTROL, true);
                            }
                            if (p.hasLeft() && GetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_CONTROL)) {
                                SetPlayerAlliance(p.player(), q.player(), ALLIANCE_SHARED_CONTROL, false);
                            }
                        }
                        else {
                            if (!IsPlayerEnemy(p.player(), q.player())) {
                                SetPlayerAllianceStateBJ(p.player(), q.player(), bj_ALLIANCE_UNALLIED);
                            }
                        }
                    }
                }

                if (p.class() == PlayerData.CLASS_DEFENDER ||
                    p.class() == PlayerData.CLASS_OBSERVER){
                    SetPlayerAllianceStateBJ(Player(PLAYER_NEUTRAL_PASSIVE), p.player(), bj_ALLIANCE_ALLIED);
                    SetPlayerAllianceStateBJ(Player(PLAYER_NEUTRAL_AGGRESSIVE), p.player(), bj_ALLIANCE_NEUTRAL);
                    SetPlayerAllianceStateBJ(p.player(), Player(PLAYER_NEUTRAL_AGGRESSIVE), bj_ALLIANCE_NEUTRAL);
                }
                else {
                    SetPlayerAllianceStateBJ(Player(PLAYER_NEUTRAL_PASSIVE), p.player(), bj_ALLIANCE_NEUTRAL);
                    SetPlayerAllianceStateBJ(Player(PLAYER_NEUTRAL_AGGRESSIVE), p.player(), bj_ALLIANCE_UNALLIED);
                    SetPlayerAllianceStateBJ(p.player(), Player(PLAYER_NEUTRAL_AGGRESSIVE), bj_ALLIANCE_UNALLIED);
					SetPlayerAlliance(Player(PLAYER_NEUTRAL_AGGRESSIVE), p.player(), ALLIANCE_PASSIVE, false);
					SetPlayerAlliance(p.player(), Player(PLAYER_NEUTRAL_AGGRESSIVE), ALLIANCE_PASSIVE, false);
                }
            }
            PunishmentCentre.update();

            list.destroy();
        }
		
		public static method findTitanPlayer() -> thistype {
            PlayerDataArray list = thistype.withClass(thistype.CLASS_TITAN);
            thistype p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = list[i];
                // Found one...
                break;
            }
            list.destroy();
            return p;
        }
        public static method findMinionPlayer() -> thistype {
            PlayerDataArray list = thistype.withClass(thistype.CLASS_MINION);
            thistype p = 0;
            integer i = 0;
            for (0 <= i < list.size()){
                p = list[i];
                // Found one...
                break;
            }
            list.destroy();
            return p;
        }

        public static method clear(){
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.has(Player(i))){
                    thistype.players[i].destroy();
                }
                thistype.players[i] = 0;
            }
        }
        public static method new(){
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.lastPlayers[i] != 0){
                    thistype.lastPlayers[i].destroy();
                }
                if (thistype.has(Player(i))){
                    thistype.lastPlayers[i] = thistype.players[i];
                }
                thistype.players[i] = 0;
            }
        }
        public static method old() -> PlayerDataArray {
            PlayerDataArray list = PlayerDataArray.create();
            integer i = 0;
            for (0 <= i < thistype.MaxPlayers){
                if (thistype.lastPlayers[i] != 0){
                    list.append(thistype.lastPlayers[i]);
                }
            }
            return list;
        }
        private static method create(player p) -> thistype {
            thistype this = thistype.allocate();
            this.mPlayer = p;
            this.mRace = NullRace.instance();
            this.mFake = false;
            return this;
        }
        public static method register(player p) -> thistype {
            thistype this = thistype.create(p);
            integer id = GetPlayerId(p);
            thistype.players[id] = this;
            return this;
        }
        private static method onInit(){
            thistype.clear();
        }
    }
    public struct PlayerDataArray {
        private PlayerData mPlayers[100];
        private integer mSize;
        
        public static method create() -> thistype {
            thistype this = thistype.allocate();
            return this;
        }
        
        public method onDestroy(){
            this.clear();
        }
        
        private method squeeze(){
            PlayerData newPlayers[];
            integer i = 0;
            integer count = 0;
            for (0 <= i < this.mPlayers.size){
                if (mPlayers[i] != 0){
                    newPlayers[count] = mPlayers[i];
                    count = count + 1;
                }
            }
            this.clear();
            for (0 <= i < count){
                this.mPlayers[i] = newPlayers[i];
            }
            this.mSize = count;
        }
        
        public method size() -> integer {
            return this.mSize;
        }
        
        public method append(PlayerData data){
            this.mPlayers[this.size()] = data;
            this.mSize = this.mSize + 1;
        }

        public method merge(thistype other) -> thistype {
            while (other.size() > 0){
                this.append(other.takeAt(0));
            }
            other.destroy();
            return this;
        }
        
        public method takeAt(integer i) -> PlayerData {
            if (i >= this.mPlayers.size || i < 0) {
                return 0;
            }
            return this.take(this.at(i));
        }
        
        public method take(PlayerData data) -> PlayerData {
            integer size = this.size();
            this.remove(data);
            if (size != this.size()){
                return data;
            }
            return 0;
        }

        public method has(PlayerData data) -> boolean {
            return (this.indexOf(data) != -1);
        }
        
        public method indexOf(PlayerData data) -> integer {
            integer i = 0;
            for (0 <= i < this.mPlayers.size){
                if (data == this.mPlayers[i]){
                    return i;
                }
            }
            return -1;
        }
		
		public method first() -> PlayerData {
			return this.at(0);
		}
		
		public method last() -> PlayerData {
			return this.at(this.size() - 1);
		}
        
        public method at(integer i) -> PlayerData {
            if (i >= this.mPlayers.size || i < 0){
                return 0;
            }
            return this.mPlayers[i];
        }
        
        public method clear(){
            integer i = 0;
            for (0 <= i < this.mPlayers.size){
                this.mPlayers[i] = 0;
            }
            this.mSize = 0;
        }
        
        public method removeAt(integer i){
            if (i >= this.mPlayers.size || i < 0){
                return;
            }
            this.mPlayers[i] = 0;
            if (i < (this.size() - 1)){
                this.squeeze();
            }
            else {
                this.mSize = this.mSize - 1;
            }
        }
        
        public method remove(PlayerData data){
            this.removeAt(this.indexOf(data));
        }
        
        public method operator [] (integer i) -> PlayerData {
            return this.at(i);
        }
        
    }

    public struct PlayerData {
        private player mPlayer = null;
        private Race mChosenRace = 0;
        private boolean mRandomRace = false;
        private Race mRace = 0;
        private Unit mUnit = 0;
        
        public static constant integer CLASS_NONE = 0;
        public static constant integer CLASS_MINION = 1;
        public static constant integer CLASS_TITAN = 2;
        public static constant integer CLASS_DEFENDER = 3;
        public static constant integer CLASS_OBSERVER = 4;
        private integer mClass = CLASS_NONE;
        private integer mInitialClass = CLASS_NONE;

        private boolean mFake = false;

        method setFake(boolean fake){
            this.mFake = fake;
        }

        method isFake() -> boolean {
            return this.mFake;
        }
        
        method setUnit(Unit u){
            mUnit = u;
        }

        method unit() -> Unit {
            return mUnit;
        }

        method say(string s){
            if (GetLocalPlayer() == this.player()){
                DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15, s);
            }
        }

        method setChosenRace(Race r, boolean random){
            this.mChosenRace = r;
            this.mRandomRace = random;
            this.setRace(r);
        }

        method chosenRace() -> Race {
            if (this.mChosenRace == 0){
                return NullRace.instance();
            }
            return this.mChosenRace;
        }

        method wasRaceRandom() -> boolean {
            return this.mRandomRace;
        }

        method isClass(integer class) -> boolean {
            return this.class() == class;
        }
        
        method resetClass() {
            integer oldClass = mClass;
            this.mClass = thistype.CLASS_NONE;
            if (LIBRARY_ClassTweak){
                PlayerDataName.update(); // Force class update
            }
            if (this.mClass != oldClass) {
                Game.onPlayerClassChange.execute(this);
            }
        }
		
		method setClassEx(integer class, boolean forceAlliances) {
			integer oldClass = mClass;
            mClass = class;
			if (forceAlliances)
				thistype.forceAlliances();
				
            if (LIBRARY_ClassTweak){
                PlayerDataName.update(); // Force class update
            }
            if (class != oldClass) {
                Game.onPlayerClassChange.execute(this);
            }
		}
        
        method setClass(integer class){
            this.setClassEx(class, true);
        }

        method setInitialClass(integer class){
            this.mInitialClass = class;
            this.setClass(class);
        }

        method initialClass() -> integer {
            return this.mInitialClass;
        }
        
        method class() -> integer {
            return mClass;
        }
        
        method setRace(Race r){
            this.mRace = r;
            if (LIBRARY_ClassTweak){
                PlayerDataName.update(); // Force class update
            }
        }
        
        method race() -> Race {
            return this.mRace;
        }
        
        method player() -> player {
            return this.mPlayer;
        }
        
        method name() -> string {
            string s = "";
            if (this.isFake()) s = " (Fake)";
            return GetPlayerActualName(this.mPlayer) + s;
        }

        method nameColored() -> string {
            string s = "";
            if (this.isFake()) s = " (Fake)";
            return GetPlayerNameColored(this.mPlayer) + s;
        }

        method nameRace() -> string {
            string decal = this.race().toString();
            if (this.race() == NullRace.instance() ||
                this.class() == thistype.CLASS_MINION){
                decal = this.classString();
            }
            return this.name() + " (" + decal + ")";
        }

        method nameClass() -> string {
            return this.name() + " (" + this.classString() + ")";
        }

        method nameClassColored() -> string {
            return this.nameColored() + "|r|cff00bfff (" + GetPlayerTextColor(this.mPlayer) + this.classString() + "|r|cff00bfff)|r";
        }
		
		method sId() -> string {
			// Like an ID, only a string!
			return I2S(this.id());
		}

        method id() -> integer {
            return GetPlayerId(this.mPlayer);
        }
        
        method state(playerstate s) -> integer {
            return GetPlayerState(this.player(), s);
        }
        
        method setState(playerstate s, integer value) {
            SetPlayerState(this.player(), s, value);
        }
        
        method gold() -> integer {
            return this.state(PLAYER_STATE_RESOURCE_GOLD);
        }
        
        method setGold(integer i){
            this.setState(PLAYER_STATE_RESOURCE_GOLD, i);
        }
        
        method wood() -> integer {
            return this.state(PLAYER_STATE_RESOURCE_LUMBER);
        }
        
        method setWood(integer i){
            this.setState(PLAYER_STATE_RESOURCE_LUMBER, i);
        }

        private boolean mLeaving = false;
        private boolean mLeft = false;

        method isLeaving() -> boolean {
            return this.mLeaving;
        }

        method hasLeft() -> boolean {
            return this.mLeft;
        }

        method leaving(){
            this.mLeaving = true;
        }
		
		private boolean mTips = true;
		method disableTips() {
			this.mTips = false;
		}
		
		method tips() -> boolean {
			return this.mTips;
		}

        private integer mLeftGameState = -1;
        private integer mLeftGameId = -1;
        private integer mLeftClass = -1;
        method left(){
            this.mLeftGameState = Game.state();
            if (this.mLeftGameState == Game.STATE_PAUSED){
                this.mLeftGameState = Game.pausedState();
            }
            this.mLeftGameId = Game.id();
            this.mLeftClass = this.class();
            this.mLeaving = false;
            this.mLeft = true;
            this.mClass = thistype.CLASS_NONE;
            thistype.forceAlliances();
            Game.checkVictory();
            Game.onPlayerLeft.execute(this);
        }

        method leftGameState() -> integer {
            return this.mLeftGameState;
        }

        method leftGameId() -> integer {
            return this.mLeftGameId;
        }

        method leftDuringGameState(integer state) -> boolean {
            return this.leftGameState() == state;
        }

        method leftClass() -> integer {
            return this.mLeftClass;
        }
        
        method classString() -> string {
            return thistype.classToString(this.class());
        }
        
        // Static Functions
        module PlayerFunctions;
    }

    public interface PlayerDataExtension {
        public method onSetup() = null;
        public method onTerminate() = null;
    }

    public module PlayerDataWrappings {
        delegate PlayerData playerData;
		private static constant integer MaxPlayers = 16;
        
        private static thistype players[];
        public static method operator [](PlayerData data) -> thistype {
			if (data == 0) return 0;
            return players[data.id()];
        }
        
        private static method create(PlayerData data) -> thistype {
            thistype this = thistype.allocate();
            this.playerData = data;
            return this;
        }

        private method onDestroy(){
            this.playerData = 0;
        }

        private static boolean mInitialized = false;
        public static method initialized() -> boolean {
            return thistype.mInitialized;
        }
        
        public static method initialize(){
            PlayerDataArray list = 0;
			PlayerData p = 0;
            thistype this = 0;
            integer i = 0;
			
			if (this.mInitialized) {
				BJDebugMsg("WARNING - PlayerDataWrappings module was re-initialized without termination.");
				thistype.terminate();
			}
			
            for (0 <= i < thistype.MaxPlayers){
                thistype.players[i] = 0;
            }
            list = PlayerData.all();
            for (0 <= i < list.size()){
				p = list.at(i);
                this = thistype.create(p);
                thistype.players[p.id()] = this;
                this.onSetup();
            }
            list.destroy();
            list = 0;

            thistype.mInitialized = true;
        }
        
        public static method terminate(){
            integer i = 0;

            thistype.mInitialized = false;

            for (0 <= i < thistype.MaxPlayers){
                if (thistype.players[i] != 0){
                    thistype.players[i].onTerminate();
                    thistype.players[i].destroy();
                }
                thistype.players[i] = 0;
            }
        }
    }
}

//! endzinc