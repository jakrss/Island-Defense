//! zinc
library DamageTomeFix requires GT, AIDS, Table, UnitAlive {
    private struct DamageTomeData {
        private unit u = null;
        private integer tomes = 0;
        private real mana = 0;
        private integer index = 0;
        private static Table collection = 0;
        
        public static method operator[] (unit u) -> thistype {
            integer i = GetUnitIndex(u);
            if (i == 0) return 0;
            return thistype.collection[i];
        }
        
        public method addTome() {
            debug {BJDebugMsg("Add: " + GetUnitName(this.u));}
            this.tomes = this.tomes + 1;
            debug {BJDebugMsg("Tomes: " + I2S(this.tomes));}
        }
        
        public method applyDelayed() {
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.apply();
            }).start(0.00).setData(this);
        }
        
        public method apply() {
            integer i = 0;
            if (this.u == null || !UnitAlive(this.u)) return;
            
            debug {BJDebugMsg("Apply: " + GetUnitName(this.u) + " + " + I2S(this.tomes));}
            
            for (0 <= i < this.tomes) {
                UnitAddItemById(this.u, 'I03I');
            }
            
            // Set mana?
            debug {BJDebugMsg("Set Mana: " + GetUnitName(this.u) + " = " + R2S(this.mana));}
            SetUnitState(this.u, UNIT_STATE_MANA, this.mana);
        }
        
        public static method create(unit u, integer tomes) -> thistype {
            thistype this = thistype.allocate();
            integer i = GetUnitIndex(u);
            
            this.u = u;
            this.tomes = tomes;
            this.index = i;
			
            debug {BJDebugMsg("Create: " + GetUnitName(this.u));}
            
            thistype.collection[i] = this;
            return this;
        }
        
        private method onDestroy(){
            thistype.collection.remove(this.index);
            this.u = null;
            this.tomes = 0;
            this.index = 0;
        }
        
        public static method onAcquire(unit u) {
            thistype this = thistype[u];
            if (this == 0) {
                this = thistype.create(u, 1);
            }
            else {
                this.addTome();
            }
        }
        
        public static method onMorph(unit u) {
            thistype this = thistype[u];
            if (this == 0) {
                this = thistype.create(u, 0);
            }
            else {
                this.mana = GetUnitState(u, UNIT_STATE_MANA);
                this.applyDelayed();
                
                if (GetSpellAbilityId() == 'A0AD') {
                    debug {BJDebugMsg("Is Ancestral");}
                }
            }
        }
        
        public static method setup() {
            thistype.collection = Table.create();
        }
    }
    
    function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemAcquiredEvent(t, 'I008');
        TriggerAddCondition(t, function() -> boolean {
            DamageTomeData.onAcquire(GetTriggerUnit());
            return false;
        });
        t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0AD');
        GT_RegisterFinishesCastingEvent(t, 'A07E');
        GT_RegisterFinishesCastingEvent(t, 'A07G'); // Morphling Warrior
        TriggerAddCondition(t, function() -> boolean {
            DamageTomeData.onMorph(GetTriggerUnit());
            return false;
        });
        t = null;
        
        DamageTomeData.setup();
    }
}
//! endzinc