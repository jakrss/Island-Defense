//! zinc
library DemonicLifeforce requires Damage, xedamage {
    //As the Demonologist summons more walls from the underworld they take more damage
    //and lose effectiveness -- DISABLED FOR NOW
    private struct DemonicLifeforce {
        private constant integer WALL_ID = 'h02A';
        //How much damage each wall amplifies the others by (in a percentage)
        private constant real damageAmp = '.025';
        
        private static method onInit() {
            trigger t = CreateTrigger();
            Damage_RegisterEvent(t);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit attacker = GetEventDamageSource();
                unit attacked = GetTriggerUnit();
                return false;
            }));
            t=null;
        }
    }
}
//! endzinc