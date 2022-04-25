//! zinc

library OldKeys requires TweakManager {
    public struct OldKeys extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Old Keys";
        }
        public method shortName() -> string {
            return "OLDKEYS";
        }
        public method description() -> string {
            return "Toggles the hotkeys in the your Punishment Centre from the new layout to the old layout.";
        }
        public method command() -> string {
            return "-oldkeys";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
            
            if (p.class() != PlayerData.CLASS_TITAN) return;
            
            if (GetUnitAbilityLevel(UnitManager.TITAN_PUNISH_CAGE, '&PUN') > 0) {
                // Has new, wants old
                UnitRemoveAbility(UnitManager.TITAN_PUNISH_CAGE, '&PUN');
                UnitAddAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU2');
                p.say("|cff00bfffNow using old hotkeys in the Punishment Centre.|r");
            }
            else {
                // Has old, wants new
                UnitRemoveAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU2');
                UnitAddAbility(UnitManager.TITAN_PUNISH_CAGE, '&PUN');
                p.say("|cff00bfffNow using new hotkeys in the Punishment Centre.|r");
            }
        }
    }
}
//! endzinc