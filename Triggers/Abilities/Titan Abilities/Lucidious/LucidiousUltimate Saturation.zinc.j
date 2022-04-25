//! zinc

// TLAF
library LucidiousUltimate requires GT, xebasic, xepreload, Table, AIDS, IsUnitWall {
    private struct LucidiousUltimate {
        private static constant integer ABILITY_ID = 'TLAF';
        private static constant string TARGET_EFFECT = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl";
        private static constant real TIMER_INTERVAL = .5;
        private static constant real DMG_PER_SECOND = 60;
        private static constant real DAMAGE_AREA = 250;
        
        private unit caster = null;
        private player castingPlayer = null;
        private GameTimer tickTimer = 0;
        private xedamage damage = 0;
        
        public method checkTarget(unit u) -> boolean {
            //if (GetTerrainCliffLevel(GetUnitX(u), GetUnitY(u)) != 
            //    GetTerrainCliffLevel(GetUnitX(this.caster), GetUnitY(this.caster))) {
            //    return false;
            //}
            
            return (!IsUnitAlly(u, this.castingPlayer) ||
                    GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
                   (IsUnitType(u, UNIT_TYPE_STRUCTURE) ||
                    IsUnitType(u, UNIT_TYPE_MECHANICAL) || IsUnitWall(u)) &&
                    UnitAlive(u);
        }
        
        private method tick(){
            group g = CreateGroup();
            unit u = null;
            real x = GetUnitX(this.caster);
            real y = GetUnitY(this.caster);
            
            // Windwalked
            if (GetUnitAbilityLevel(this.caster, 'B006') > 0 || GetUnitAbilityLevel(this.caster, 'BHbn') > 0) {
                // Ignore this tick, as we are windwalked
            }
            else {
                GroupEnumUnitsInRange(g, x, y, this.DAMAGE_AREA, null);
                
                u = FirstOfGroup(g);
                while (u != null){
                    if (this.checkTarget(u)){
                        this.damage.damageTarget(this.caster, u, thistype.DMG_PER_SECOND * thistype.TIMER_INTERVAL);
                    }
                    GroupRemoveUnit(g, u);
                    u = FirstOfGroup(g);
                }
            }
            
            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.damage = xedamage.create();
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.required = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "head");
            this.damage.forceEffect = true;
            
            this.tickTimer = GameTimer.newNamedPeriodic(function(GameTimer t){
                thistype this = t.data();
                if (this.caster != null
                    && UnitAlive(this.caster) 
                    && GetUnitAbilityLevel(this.caster, 'B004') > 0) {
                    this.tick();
                }
                else {
                    this.destroy();
                }
            }, "LucidSaturation");
            
            this.tickTimer.setData(this);
            this.tickTimer.start(thistype.TIMER_INTERVAL);
            
            return this;
        }
        
        private method onDestroy(){
            this.caster = null;
            this.castingPlayer = null;
            if (this.tickTimer != 0) {
                this.tickTimer.deleteNow();
                this.tickTimer = 0;
            }
            this.damage.destroy();
            this.damage = 0;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        LucidiousUltimate.onSetup.execute();
    }
}


//! endzinc