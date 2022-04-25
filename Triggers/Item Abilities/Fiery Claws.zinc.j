//! zinc

library FieryClawsItem requires Damage, GameTimer, DestroyEffectTimed {
    private function onInit(){
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            xefx e = 0;
            if (Damage_IsAttack() && 
                (GetUnitAbilityLevel(u, 'B00N') > 0 ||
                 GetUnitAbilityLevel(u, 'B00O') > 0)) { 
                if (GetUnitState(u, UNIT_STATE_LIFE) - GetEventDamage() > 0) {
                    e = xefx.create(GetUnitX(u), GetUnitY(u), 0.0);
                    e.fxpath = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl";
                    e.scale = 2.0;
                    GameTimer.new(function(GameTimer t) {
                        xefx e = t.data();
                        e.destroy();
                    }).start(5.0).setData(e);
                }
                else {
                    DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl",
                                                          GetUnitX(u), GetUnitY(u)));
                }
            }
            u = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc