//! zinc
library VoidGate requires GameTimer, GT, xecast, UnitStatus {
    private struct VoidGate {
        private static constant integer ABILITY_ID = 'A0DY';
        private static constant real CAST_DELAY = 1.0;
        private static constant string TELEPORT_EFFECT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl";
        
        private static method findPlayerVoidGate(player p) -> unit {
            group g = CreateGroup();
            boolexpr b = Filter(function() -> boolean {
                return GetUnitTypeId(GetFilterUnit()) == 'e013';
            });
            unit u = null;
            GroupEnumUnitsOfPlayer(g, p, b);
            DestroyBoolExpr(b);
            
            u = GroupPickRandomUnit(g);
            
            DestroyGroup(g);
            g = null;
            b = null;
            return u;
        }
        
        private static Table instances = 0;
        private integer index = 0;
        private unit caster = null;
        private GameTimer castTimer = 0;
        private real mana = 0.0;
        
        private method finish(){
            // Hmm, I suppose it should be to the new players owner
            player p = GetOwningPlayer(this.caster);
            unit u = null;
            
            if (GetUnitState(this.caster, UNIT_STATE_LIFE) <= 0.405){
                // Dead. We don't want to TP.
                
            }
            else {
                u = thistype.findPlayerVoidGate(p);
                if (u != null){
                    DestroyEffect(AddSpecialEffect(thistype.TELEPORT_EFFECT, GetUnitX(this.caster), GetUnitY(this.caster)));
                    SetUnitPosition(this.caster, GetUnitX(u), GetUnitY(u));
                    DestroyEffect(AddSpecialEffect(thistype.TELEPORT_EFFECT, GetUnitX(this.caster), GetUnitY(this.caster)));
                }
            }
            
            UnitRemoveAbility(this.caster, 'B05E'); // Remove portal buff (stop movement)
            SetUnitVertexColor(this.caster, 255, 255, 255, 255);
            DisableUnit(this.caster, false);
            SetUnitState(this.caster, UNIT_STATE_MANA, this.mana);
	    UnitRemoveAbility(this.caster, 'INVU');
            //SetUnitInvulnerable(this.caster, false);	//Making unit invulnerable causes bugs with other stuff.
            u = null;
            p = null;
            
            this.castTimer.deleteLater();
            this.castTimer = 0;
            
            this.destroy();
        }
        
        public method onDamageBlocked() {
            SetUnitState(this.caster, UNIT_STATE_MANA, this.mana);
        }
        
        private method onDestroy(){
            this.caster = null;
            if (thistype.instances.has(this.index)) {
                thistype.instances.remove(this.index);
            }
            this.index = 0;
            
            if (this.castTimer != 0) {
                this.castTimer.deleteNow();
                this.castTimer = 0;
            }
        }
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.create();
            integer index = GetUnitIndex(caster);
            xecast cast = xecast.createBasicA('A0AM', OrderId("cripple"), GetOwningPlayer(caster));
            this.caster = caster;
			UnitAddAbility(this.caster, 'INVU');
            //SetUnitInvulnerable(this.caster, true);	//Making unit invulnerable causes bugs with other stuff.
            this.index = index;
            // Ensure no damage
            thistype.instances[this.index] = this;
            this.mana = GetUnitState(this.caster, UNIT_STATE_MANA);
            
            // Setup
            SetUnitVertexColor(this.caster, 255, 255, 255, 'd'); // Transparency
            DisableUnit(this.caster, true);
            
            // Cast
            cast.recycledelay = 1.0;
            cast.castOnTarget(this.caster);
            cast = 0;

            this.castTimer = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                this.finish();
            });
            this.castTimer.setData(this);
            this.castTimer.start(thistype.CAST_DELAY);
            
            return this;
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
				unit caster = GetSpellAbilityUnit();
                thistype.begin(caster);
				caster = null;
                return false;
            }));
            
            t = CreateTrigger();
            Damage_RegisterEvent(t);
            TriggerAddCondition(t , Condition(function() -> boolean {
                unit u = GetTriggerUnit();
                integer index = GetUnitId(u);
                thistype this = 0;
                if (index != 0 && thistype.instances.has(index)) {
                    this = thistype.instances[index];
                    if (this != 0) {
						Damage_BlockAll();
                        this.onDamageBlocked();
                    }
                }
                
                u = null;
                return false;
            }));
            
            XE_PreloadAbility(thistype.ABILITY_ID);
            XE_PreloadAbility('A0AM');
            thistype.instances = Table.create();
            t = null;
        }
    }
    
    private function onInit(){
        VoidGate.onSetup.evaluate();
    }
}

//! endzinc