//! zinc
library CloudReflection requires xepreload, xebasic, xecast {
    private struct CloudReflection {
        private static real distanceOfLine = 9000;
        private static real pearlAOE = 850;
        private static real distanceDivider = 1;
        private xecast dummyCaster;
        private static integer abilityId = 'A095';
        private static integer dummyAbilityId = 'TLAD';
        
        private static method begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            real casterX = GetUnitX(caster);
            real casterY = GetUnitY(caster);
            real targetX = GetSpellTargetX();
            real targetY = GetSpellTargetY();
            real angle = bj_RADTODEG * Atan2(targetY - casterY, targetX - casterX);
            real distanceFromCaster = SquareRoot((targetX - casterX) * (targetX - casterX) + (targetY - casterY) * (targetY - casterY));
            real distance = this.pearlAOE/this.distanceDivider;
            if(distanceFromCaster > distanceOfLine) {
                distance = distance + (distanceFromCaster - distanceOfLine);
            }
            while(distance < distanceOfLine) {
                this.dummyCaster = xecast.createBasicA(this.dummyAbilityId, 852122, GetOwningPlayer(caster));
                this.dummyCaster.castOnPoint(casterX + distance * Cos(bj_DEGTORAD * angle), casterY + distance * Sin(bj_DEGTORAD * angle));
                distance += this.pearlAOE/this.distanceDivider;
            }
            this.destroy();
            return this;
        }
        
        private static method onCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.begin(caster);
        }
        
        private static method onSetup() {
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId;
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
        
        private static method onInit() {
            thistype.onSetup();
        }
    }
}
//! endzinc