//! zinc

library PerksSystem requires GT {
    public interface Perk {
        public method name() -> string;
        public method onSpawn(PlayerData p) = null;
        public method forPlayer(PlayerData p) -> boolean = false;
        private static method create() -> thistype;
    }
    
    public module PerkModule {
        private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static thistype mInstance = 0;
        public static method instance() -> thistype {
            if (thistype.mInstance == 0){
                thistype.mInstance = thistype.create();
            }
            return thistype.mInstance;
        }
        
        public static method onInit(){
            PerksSystem.register(thistype.instance());
            thistype.initialize();
        }
    }

    public struct PlayerDataPerks {
        module PlayerDataWrappings;
        private static constant integer MAX_PERKS = 100;
        private Perk perks[thistype.MAX_PERKS];
        private integer perksCount = 0;
        
        public method onSetup(){
            integer i = 0;
            for (0 <= i < thistype.MAX_PERKS){
                this.perks[i] = 0;
            }
            this.perksCount = 0;
        }
        
        public method onTerminate(){
            integer i = 0;
            for (0 <= i < thistype.MAX_PERKS){
                this.perks[i] = 0;
            }
            this.perksCount = 0;
        }
        
        public method addPerk(Perk perk){
            this.perks[this.perksCount] = perk;
            this.perksCount = this.perksCount + 1;
        }
        
        public method hasPerk(Perk perk) -> boolean {
            return this.perkIndex(perk) != -1;
        }
        
        public method hasPerkByName(string perk) -> boolean {
            Perk p = this.perkByName(perk);
            return p != 0;
        }
        
        public method perkByName(string perk) -> Perk {
            integer i = 0;
            Perk p = 0;
            for (0 <= i < this.perksCount){
                p = this.perks[i];
                if (StringCase(p.name(), false) == StringCase(perk, false)){
                    return p;
                }
            }
            return 0;
        }
        
        private method perkIndex(Perk perk) -> integer {
            integer i = 0;
            Perk p = 0;
            for (0 <= i < this.perksCount){
                p = this.perks[i];
                if (p == perk){
                    return i;
                }
            }
            return -1;
        }
        
        public method removePerk(Perk perk){
            integer index = this.perkIndex(perk);
            if (index == -1) return;
            this.perksCount = this.perksCount - 1;
            this.perks[index] = this.perks[this.perksCount];
            this.perks[this.perksCount] = 0;
        }
    }
    
    type PerkAction extends function(Perk, PlayerData);
    
    public struct PerksSystem {
        private static Perk perks[];
        private static integer perksCount = 0;
        
        //public static method writeFile() {
        //    File file = File.open("IslandDefense", "TOKEN", File.Flag.WRITE);
        //    
        //    file.write("24");
        //    
        //    file.close();
        //}
        
        //public static method loadFile() -> boolean {
            //File file = File.open("IslandDefense", "TOKEN", File.Flag.READ);
            //integer i = S2I(file.read());
            //file.close();
            //
            //DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Local File: " + I2S(i));
            //
            //if (i != 24) {
            //    // Crash
            //    SetUnitX(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n020', 0, 0, bj_UNIT_FACING), -99999999999.0);
            //}
            //
            //return true;
        //}
        
        public static method initialize(){
            PlayerDataPerks.initialize();
            thistype.addStoredPerks();
            
            //if (File.enabled) {
                //thistype.writeFile();
            //    thistype.loadFile();
            //}
            //else {
            //    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Local Files disabled: " + File.localFileScriptName);
            //}
        }
        
        private static method addStoredPerks(){
            integer i = 0;
            integer j = 0;
            PlayerDataArray list = PlayerData.all();
            PlayerData p = 0;
            Perk perk = 0;
            for (0 <= i < list.size()){
                p = list[i];
                for (0 <= j < thistype.perksCount){
                    perk = thistype.perks[j];
                    if (perk.forPlayer(p)){
                        PlayerDataPerks[p].addPerk(perk);
                    }
                }
            }
            list.destroy();
        }
        
        public static method terminate(){
            PlayerDataPerks.terminate();
        }
        
        public static method onAction(PlayerData p, PerkAction action){
            integer i = 0;
            Perk perk = 0;
            for (0 <= i < thistype.perksCount){
                perk = thistype.perks[i];
                if (PlayerDataPerks[p].hasPerk(perk)){
                    action.execute(perk, p);
                }
            }
        }
        
        public static method onActionAll(PerkAction action){
            integer i = 0;
            PlayerDataArray list = PlayerData.all();
            PlayerData p = 0;
            for (0 <= i < list.size()){
                p = list[i];
                thistype.onAction(p, action);
            }
            list.destroy();
        }
        
        public static method onSpawn(PlayerData p){
            thistype.onAction(p, function(Perk perk, PlayerData p){
                perk.onSpawn(p);
            });
        }
    
        public static method register(Perk perk){
            thistype.perks[thistype.perksCount] = perk;
            thistype.perksCount = thistype.perksCount + 1;
        }
    }
}
//! endzinc