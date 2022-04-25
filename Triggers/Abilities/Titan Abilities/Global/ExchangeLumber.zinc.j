//! zinc

library ExchangeLumber requires GT {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_TRAIN_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit v = GetTrainedUnit();
            player p = GetOwningPlayer(u);

            if (GetUnitTypeId(v) == 'n00A'){ // Dummy Unit
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", GetUnitX(u), GetUnitY(u)));
                SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + 50);
                RemoveUnit(v);
            }

            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc