//! zinc

library DemonologistBalthasar requires GT, UnitManager {
    private struct BalthOwner {
        private static constant integer BALTH_ID = 'U00S';
        private static constant real BALTH_LIFETIME = 45.0;
        private static Table owners = 0; 
        unit balth = null;
        PlayerData owner = 0;
        
        public static method create(unit caster) -> thistype {
            thistype this = thistype.allocate();
            player p = GetOwningPlayer(caster);
            real r = GetUnitFacing(caster);
            real dist = 150.0;
            real x = GetUnitX(caster) + dist * Cos(bj_DEGTORAD * r);
            real y = GetUnitY(caster) + dist * Sin(bj_DEGTORAD * r);
            this.owner = PlayerData.get(p);
            this.balth = CreateUnit(p, thistype.BALTH_ID, x, y, r);
            this.onSpawn();
            owners[GetPlayerId(p)] = this;
            return this;
        }
        
        public method onSpawn() {
            UnitManager.hunterRespawn(this.balth);
            UnitApplyTimedLife(this.balth, 'BTLF', thistype.BALTH_LIFETIME);
        }
        
        public method respawn(unit caster) {
            real r = GetUnitFacing(caster);
            real dist = 150.0;
            real x = GetUnitX(caster) + dist * Cos(bj_DEGTORAD * r);
            real y = GetUnitY(caster) + dist * Sin(bj_DEGTORAD * r);
            integer i = 0;
            item it = null;
            
            if (UnitAlive(this.balth)) {
                KillUnit(this.balth);
            }
            ReviveHero(this.balth, x, y, false);
            
            SetUnitFacing(this.balth, r);
            this.onSpawn();
            
            it = null;
        }
        
        public static method operator[] (integer i) -> thistype {
            return owners[i];
        }
        
        public static method setup() {
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, 'A02N');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetTriggerUnit();
                integer i = GetPlayerId(GetOwningPlayer(u));
                if (thistype[i] == 0) {
                    thistype.create(u);
                }
                else {
                    thistype[i].respawn(u);
                }
                
                return false;
            }));
            t = null;
        
            owners = Table.create();
        }
    }

    private function onInit(){
        BalthOwner.setup();
    }
}

//! endzinc