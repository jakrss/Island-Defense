//! zinc
library ItemCast {
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST);
        TriggerAddCondition(t, Condition( function() -> boolean {
            return (GetSpellTargetItem() != null);
        }));
        TriggerAddAction(t, function(){
            IssueImmediateOrder(GetSpellAbilityUnit(), "stop");
        });
    }
}
//! endzinc