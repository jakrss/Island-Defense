//! zinc

library TrollVoodoo requires Damage, GameTimer {
    private constant integer ABILITY_ID = 'A02F';
    private constant integer BUFF_ID = 'B013';
    
    public struct DamageLater {
        private unit u = null;
        private unit a = null;
        private real damage = 0.0;
        private damagetype t = DAMAGE_TYPE_NORMAL;
        
        public static method create(unit attacker, unit toAttack, real damage, damagetype t) -> thistype {
            thistype this = thistype.allocate();
            this.u = toAttack;
            this.a = attacker;
            this.damage = damage;
            this.t = t;
            
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                if (this != 0){
                    if (this.t == DAMAGE_TYPE_MAGIC) {
                        Damage_Spell(this.a, this.u, this.damage);
                    }
                    else {
                        // Assume Damage_IsAttack()
                        Damage_Physical(this.a, this.u, this.damage, ATTACK_TYPE_NORMAL, true, false);
                    }
                    this.destroy();
                    this = 0;
                }
            }).start(0.1).setData(this);
            
            return this;
        }
        
        private method onDestroy() {
            this.u = null;
            this.a = null;
        }
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit v = null;
            unit a = GetEventDamageSource();
            group g = null;
            filterfunc f = null;
            real damage = GetEventDamage();
            if (GetUnitAbilityLevel(u, ABILITY_ID) > 0) {
                // Check for any units with the Voodoo buff
                g = CreateGroup();
                f = Filter(function() -> boolean {
                    return GetUnitAbilityLevel(GetFilterUnit(), BUFF_ID) > 0 && UnitAlive(GetFilterUnit());
                });
                GroupEnumUnitsOfPlayer(g, GetOwningPlayer(u), f);
                
                v = FirstOfGroup(g);
                if (v != null) {
                    DamageLater.create(a, v, damage, Damage_GetType());
                    Damage_BlockAll();
                    v = null;
                }
                
                DestroyGroup(g);
                DestroyFilter(f);
                f = null;
                g = null;
            }
            a = null;
            u = null;
            return false;
        }));
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc