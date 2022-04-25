//! zinc

// Data for Races

library Races requires StringLib {
    ///! import "defenders/defenders.zn"
    ///! import "titans/titans.zn"

    public module RegisterFunctions {
        private static method create() -> thistype {
            return thistype.allocate();
        }
        
        private static method onInit(){
            super.register(thistype.create());
        }
    }
    
    public module RaceFunctions {
        private static thistype races[100];
        private static integer index = 0;
        
        public static method operator [](integer i) -> thistype {
            return races[i];
        }
        
        public static method fromNamePartial(string s, boolean unique) -> thistype {
            integer i = 0;
            thistype found = NullRace.instance();
            while (i < thistype.count()){
                if (StringIndexOf(thistype[i].toString(), s, false) == 0){
                    if (found == NullRace.instance()) {
                        if (unique) {
                            found = thistype[i];
                        }
                        else {
                            return thistype[i];
                        }
                    }
                    else {
                        return NullRace.instance();
                    }
                }
                i = i + 1;
            }
            return found;
        }

        public static method fromName(string s) -> thistype {
            integer i = 0;
            while (i < thistype.count()){
                if (StringCase(thistype[i].toString(), false) == StringCase(s, false)){
                    return thistype[i];
                }
                i = i + 1;
            }
            return NullRace.instance();
        }
        public static method fromItemId(integer id) -> thistype {
            integer i = 0;
            while (i < thistype.count()){
                if (thistype[i].itemId() == id){
                    return thistype[i];
                }
                i = i + 1;
            }
            return NullRace.instance();
        }
        public static method fromWidgetId(integer id) -> thistype {
            integer i = 0;
            while (i < thistype.count()){
                if (thistype[i].widgetId() == id){
                    return thistype[i];
                }
                i = i + 1;
            }
            return NullRace.instance();
        }
        public static method indexOf(thistype this) -> thistype {
            integer i = 0;
            for (0 <= i < thistype.count()){
                if (thistype[i] == this){
                    return i;
                }
            }
            return -1;
        }
        
        public static method random() -> thistype {
            thistype this = 0;
            if (thistype.count() == 0) return 0;
            while(this == 0 || !this.inRandomPool()) {
                this = thistype[GetRandomInt(0, thistype.count() - 1)];
            }
            return this;
        }
        
        public static method count() -> integer {
            return index;
        }
        
        public static method register(thistype this){
            thistype.races[thistype.index] = this;
            index = index + 1;
        }
		
		method isWidgetId(integer id) -> boolean {return id == this.widgetId();}
		method isChildId(integer id) -> boolean {return id == this.childId();}
    }
    
    public struct DefenderRace extends Race {
        method toString() -> string {return "_Defender";}
        method class() -> integer {return CLASS_DEFENDER;}

        module RaceFunctions;
    }
    
    public struct TitanRace extends Race {
        method toString() -> string {return "_Titan";}
        method class() -> integer {return CLASS_TITAN;}

        module RaceFunctions;
    }
    
    public struct NullRace extends Race {
        private static thistype single_instance = 0;
        public static method instance() -> thistype {
            if (single_instance == 0)
                single_instance = thistype.create();
            return single_instance;
        }
        private static method create() -> thistype {
            return thistype.allocate();
        }
		
		method isWidgetId(integer id) -> boolean {return false;}
		method isChildId(integer id) -> boolean {return false;}
    }
    
	// Used with CustomTitanRace
    public module TitanRaceModule {
        public Table abilityTable = 0;
        public method abilities() -> Table {
            return this.abilityTable;
        }
        
        private static method create() -> thistype {
            thistype this = thistype.allocate();
            this.abilityTable = Table.create();
            return this;
        }
        
        private static method onInit(){
            thistype this = thistype.create();
            TitanRace.register.evaluate(this);
            this.onLoad();
        }
    }
    
    public interface Race {
        static integer CLASS_NONE = 0;
        static integer CLASS_TITAN = 10;
        static integer CLASS_DEFENDER = 11;
        method class() -> integer = 0; // CLASS_NONE
        
        // Generic
        method toString() -> string = "_NULL";
        method widgetId() -> integer = 0;
		method isWidgetId(integer id) -> boolean;
        method itemId() -> integer = 0;
        method itemOrder() -> integer = 0;
        method icon() -> string = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp";

        method onSpawn(unit u) = null;
		method setupTech(player p) = null;
        
        method childId() -> integer = 0;
		method isChildId(integer id) -> boolean;
        method childIcon() -> string = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp";
        method childItemId() -> integer = 0;
        
        method inRandomPool() -> boolean = true;
        method isPickable() -> boolean = true;
        
        method onLoad() = null;

        // Defender
        method difficulty() -> real = 0.0;
    }
}

//! endzinc