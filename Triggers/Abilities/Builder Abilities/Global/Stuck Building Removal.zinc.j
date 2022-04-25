//! zinc

library StuckBuildingRemoval requires GameTimer {
    private constant string DEATH_EFFECT = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl";
    private constant real REMOVE_DELAY = 1.0;
    
    private struct dyingUnitData {
        unit u = null;
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return IsUnitType(GetDyingUnit(), UNIT_TYPE_STRUCTURE);
        }));
        TriggerAddAction(t, function(){
            unit u = GetDyingUnit();
            integer id = GetUnitTypeId(u);
            dyingUnitData d = dyingUnitData.create();
            if (id == 'h02A' ||
                id == 'h03V' ||
                id == 'o02B' ||
                id == 'o02D' ||
                id == 'o02C'){
                DestroyEffect(AddSpecialEffect(DEATH_EFFECT, GetUnitX(u), GetUnitY(u)));
            }
            
            d.u = u;
            
            GameTimer.new(function(GameTimer t){
                dyingUnitData d = t.data();
                unit u = d.u;
                RemoveUnit(u);
                u = null;
                d.destroy();
            }).start(REMOVE_DELAY).setData(d);
            d = 0;
            u = null;
        });
        t = null;
    }
}

//! endzinc