//! zinc

library Unit requires PlayerDataPick, Table {
    public interface Unit {
        public method unit() -> unit;
        public method class() -> integer;       // CLASS_DEFENDER
        public method race() -> Race;           // MurlocRace
        public method owner() -> PlayerData;    // CURRENT Owning Player
		public method spawn(real x, real y, real r) -> unit;
    }
    
    public struct UnitList {
        private Table units = 0;
        public integer length = 0;
        
        public static method create() -> thistype {
            thistype this = thistype.allocate();
            this.units = Table.create();
            return this;
        }
        
        public static method copy(thistype that) -> thistype {
            thistype this = thistype.create();
            integer i = 0;
            
            for (0 <= i < that.size()){
                this.append(that.at(i));
            }
            return this;
        }
        
        public method print(){
            Unit u = 0;
            integer i = 0;
            for (0 <= i < this.size()){
                u = this.at(i);
                Game.say("Has " + GetUnitName(u.unit()) 
                     + " owned by " + u.owner().nameColored()
                     + " (" + u.race().toString() + ")");
            }
        }
        
        public method onDestroy(){
            this.clear();
            this.units.destroy();
            this.units = 0;
        }
        
        private method squeeze(){
            Unit newUnits[];
            integer i = 0;
            integer count = 0;
            // Currently old size, one value is maybe 0
            for (0 <= i < this.size()){
                if (this.units[i] != 0){
                    newUnits[count] = this.units[i];
                    count = count + 1;
                }
            }
            this.clear();
            for (0 <= i < count){
                this.units[i] = newUnits[i];
            }
            this.length = count;
        }
        
        public method size() -> integer {
            return this.length;
        }
        
        public method append(Unit data){
            this.units[this.length] = data;
            this.length = this.length + 1;
        }
        
        public method takeAt(integer i) -> Unit {
            if (i >= this.size() || i < 0) {
                return 0;
            }
            return this.take(this.at(i));
        }
        
        public method take(Unit data) -> Unit {
            integer size = this.size();
            this.remove(data);
            if (size == this.size()){
                return data;
            }
            return 0;
        }
        
        public method indexOf(Unit data) -> integer {
            integer i = 0;
            for (0 <= i < this.size()){
                if (data == this.units[i]){
                    return i;
                }
            }
            return -1;
        }
        
        public method indexOfUnit(unit v) -> integer {
            integer i = 0;
            Unit u = 0;
            for (0 <= i < this.size()){
                u = this.units[i];
                if (u.unit() == v){
                    return i;
                }
            }
            return -1;
        }
        
        public method at(integer i) -> Unit {
            if (i >= this.size() || i < 0){
                return 0;
            }
            return this.units[i];
        }
        
        public method get(unit u) -> Unit {
            integer i = this.indexOfUnit(u);
            if (i == -1) return 0;
            return this.at(i);
        }
        
        public method clear(){
            this.units.reset();
        }
        
        public method removeAt(integer i){
            if (i >= this.size() || i < 0){
                return;
            }
            this.units.remove(i);
            if (i < (this.size() - 1)){
                this.squeeze();
            }
            else {
                this.length = this.length - 1;
            }
        }
        
        public method remove(Unit data){
            this.removeAt(this.indexOf(data));
        }
        
        public method operator [] (integer i) -> Unit {
            return this.at(i);
        }
    }
}

//! endzinc