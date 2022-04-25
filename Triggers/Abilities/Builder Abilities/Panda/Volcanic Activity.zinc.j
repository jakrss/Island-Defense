//! zinc
library VolcanicActivity {
    private constant integer ABILITY_ID = 'A0HB';
    private constant abilityintegerfield AIF = ABILITY_IF_LEVELS;
    private hashtable vTable = InitHashtable();

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetEventDamageSource();
            integer aLvl = GetUnitAbilityLevel(u, ABILITY_ID);
            ability a = BlzGetUnitAbility(u, ABILITY_ID);
            integer numLevels;
            if(aLvl > 0) {
                numLevels = BlzGetAbilityIntegerField(a, AIF);
                if(aLvl < numLevels) {
                    SetUnitAbilityLevel(u, ABILITY_ID, aLvl + 1);
                } else {
                    SetUnitAbilityLevel(u, ABILITY_ID, 1);
                }
            }
            u = null;
            return false;
        });
        t = null;
    }
}
//! endzinc

