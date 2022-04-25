//! zinc

// TSAF
library SypheriousUltimate requires GT, xebasic, xepreload, UnitStatus, IsUnitWall {
    private struct SypheriousUltimate {
        private static constant integer ABILITY_ID = 'TSAF';
        private static constant integer dummyAbilityId = 'A08R';
        private static constant integer dummyId = 'e01B';
        private static constant string TARGET_EFFECT = "Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdl";
        
        private static unit caster = null;
        private static unit dummyUnit = null;
        private player castingPlayer = null;
        private static real targetX;
        private static real targetY;
        private static real disableRange;
        private static real disableTime;
        private static real armorReduction;
		
		// Workaround for filters
		private static thistype curr = 0;
        
        private method setup(integer level) {
            this.disableRange = 250 + (level * 100);
            this.disableTime = 4*level;
            this.armorReduction = 4*level;
        }
        
        public method checkTarget(unit u) -> boolean {
            return (!IsUnitAlly(u, this.castingPlayer) ||
                    GetOwningPlayer(u) == Player(PLAYER_NEUTRAL_PASSIVE)) &&
                   (IsUnitType(u, UNIT_TYPE_STRUCTURE) ||
                    IsUnitType(u, UNIT_TYPE_MECHANICAL)) &&
                    UnitAlive(u);
        }
        
        private method disableArea(real x, real y){
            group g = CreateGroup();
			boolexpr b = null;
			
			thistype.curr = this;
			b = Filter(function() -> boolean {
				// How to pass "this" in?
				return thistype.curr.checkTarget(GetFilterUnit());
			});
            GroupEnumUnitsInRange(g, x, y, thistype.disableRange, b);
			thistype.curr = 0;
            thistype.targetX = x;
            thistype.targetY = y;
			
			ForGroup(g, function() {
				unit u = GetEnumUnit();
				xecollider xe = 0;
				xe = xecollider.create(GetUnitX(u), GetUnitY(u), 0.0);
				xe.expirationTime = thistype.disableTime;
				xe.fxpath = thistype.TARGET_EFFECT;
				xe.scale = 1.0;
				xe.z = 80;
                if(IsUnitWall(GetEnumUnit())) {
                    DisableUnitTimed(u, thistype.disableTime * 2);
                    thistype.dummyUnit = CreateUnit(GetOwningPlayer(thistype.caster), thistype.dummyId, thistype.targetX, thistype.targetY, bj_UNIT_FACING);
                    UnitAddAbility(thistype.dummyUnit, thistype.dummyAbilityId);
                    SetUnitAbilityLevel(thistype.dummyUnit, thistype.dummyAbilityId, GetUnitAbilityLevel(thistype.caster, thistype.ABILITY_ID));
                    UnitApplyTimedLife(thistype.dummyUnit, 'BTLF', thistype.disableTime * 2);
                } else {
                    DisableUnitTimed(u, thistype.disableTime);
                    thistype.dummyUnit = CreateUnit(GetOwningPlayer(thistype.caster), thistype.dummyId, thistype.targetX, thistype.targetY, bj_UNIT_FACING);
                    UnitAddAbility(thistype.dummyUnit, thistype.dummyAbilityId);
                    SetUnitAbilityLevel(thistype.dummyUnit, thistype.dummyAbilityId, GetUnitAbilityLevel(thistype.caster, thistype.ABILITY_ID));
                    UnitApplyTimedLife(thistype.dummyUnit, 'BTLF', thistype.disableTime);
                }
                thistype.dummyUnit = null;
				u = null;
			});
			
            DestroyBoolExpr(b);
            DestroyGroup(g);
            g = null;
			b = null;
        }
        
        private static method begin(unit caster, real x, real y) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.setup(GetUnitAbilityLevel(this.caster, this.ABILITY_ID));
            this.castingPlayer = GetOwningPlayer(this.caster);

            this.disableArea(x, y);
            
            return this;
        }
        
        private method onDestroy(){
            this.caster = null;
            this.castingPlayer = null;
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            thistype.begin(caster, x, y);
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(thistype.ABILITY_ID);
        }
    }
    
    private function onInit(){
        SypheriousUltimate.onSetup.execute();
    }
}


//! endzinc