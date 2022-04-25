//! zinc

library DisableAttack requires UnitManager, AIDS, Table {
    private Table ranges = 0;
    
    private function onInit() {
        trigger t = CreateTrigger();
        ranges = Table.create();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ATTACKED );
        //Damage_RegisterEvent(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            unit a = GetAttacker();
            PlayerData p = PlayerData.get(GetOwningPlayer(u));
            PlayerData q = PlayerData.get(GetOwningPlayer(a));
            
            // If the attacking player is a defender
            if (q.class() == PlayerData.CLASS_DEFENDER){
                // Attacking spell well
                if (u == UnitManager.TITAN_SPELL_WELL){
                    return true;
                }
                
                // Attacking another defender
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    // Attacking their builder
                    if (UnitManager.isDefender(u)){
                        return true;
                    }
                }
            }
            // Otherwise a titan
            else if (q.class() == PlayerData.CLASS_TITAN ||
                     q.class() == PlayerData.CLASS_MINION){
                // Against another titan
                if (p.class() == PlayerData.CLASS_TITAN ||
                    p.class() == PlayerData.CLASS_MINION){
                    // which is a titan unit
                    if (UnitManager.isTitan(u) ||
                        UnitManager.isMinion(u)){
                        return true;
                    }
                    
                    // which is the mound
                    if (u == UnitManager.TITAN_SPELL_WELL){
                        return true;
                    }
                }
            }
            return false;
        });
        TriggerAddAction( t, function(){
            unit u = GetTriggerUnit();
            unit a = GetAttacker();
            
            IssueImmediateOrder(a, "stop");
            
            u = null;
            a = null;
        });
        // If attacked from a distance, make the builder move over there!
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return (GetOrderTargetUnit() == UnitManager.TITAN_SPELL_WELL) &&
                   (GetUnitAbilityLevel(GetOrderedUnit(), 'A041') > 0) &&
                   (OrderId2String(GetIssuedOrderId()) == "smart" ||
                    OrderId2String(GetIssuedOrderId()) == "attack"); 
        }));
        TriggerAddAction(t, function(){
            unit u = GetOrderedUnit();
            real x = GetUnitX(UnitManager.TITAN_SPELL_WELL);
            real y = GetUnitY(UnitManager.TITAN_SPELL_WELL);
            real angle = (bj_RADTODEG * Atan2(GetUnitY(u) - y, GetUnitX(u) - x));
            x = x + 95 * Cos(angle * bj_DEGTORAD);
            y = y + 95 * Sin(angle * bj_DEGTORAD);
            IssuePointOrder(u, "restoration", x, y);
            u = null;
        });
        t = null;
    }
}

//! endzinc