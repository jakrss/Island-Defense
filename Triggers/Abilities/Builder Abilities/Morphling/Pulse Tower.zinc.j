//! zinc

library MorphlingPulseTower requires Table, AIDS, Transport {
    public struct MorphlingPulseTower {
        private static method onInit() {
            trigger t = CreateTrigger();
            Transport_RegisterLoadEvent(t);
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit t = GetTransportUnit();
                if (t == null) t = GetTriggerUnit();
                if (GetUnitAbilityLevel(t, 'A075') > 0
                    && Transport_CountPassengers(t) > 0) {
                    // Has Morphling Cargo Hold
                    // Set color
                    SetUnitVertexColor(t, 255, 125, 125, 255);
                }
                t = null;
                return false;
            }));
            
            t = CreateTrigger();
            Transport_RegisterUnloadEvent(t);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit t = GetUnloadingTransport();
                
                if (GetUnitAbilityLevel(t, 'A075') > 0) {
                    // Has Morphling Cargo Hold
                    // Reset color
                    SetUnitVertexColor(t, 255, 255, 255, 255);
                }
                t = null;
                return false;
            }));
            t = null;
            /*t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
            TriggerAddCondition(t, function() -> boolean {
                
                return false;
            });*/
        }
    }
}

//! endzinc