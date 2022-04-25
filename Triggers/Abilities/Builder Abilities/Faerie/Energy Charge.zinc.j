//! zinc

library EnergyCharge {
    private constant integer ENERGY_CHARGE_BURN = 'A0BF';
    private constant integer ENERGY_CHARGE_BUFF = 'Blsh';
    
    private function act(){
        group g = CreateGroup();
        boolexpr b = Filter(function () -> boolean {
            return (IsUnitType(GetFilterUnit(), UNIT_TYPE_GROUND) == true) &&
                   (GetUnitAbilityLevel(GetFilterUnit(), ENERGY_CHARGE_BURN) > 0 ||
                    GetUnitAbilityLevel(GetFilterUnit(), ENERGY_CHARGE_BUFF) > 0);
        });
        unit u = null;
        
        GroupEnumUnitsInRect(g, GetWorldBounds(), b);
        
        u = FirstOfGroup(g);
        while(u != null){
            if ((GetUnitAbilityLevel(u, ENERGY_CHARGE_BUFF) > 0) &&
                (GetUnitAbilityLevel(u, ENERGY_CHARGE_BURN) == 0)){
                UnitAddAbility(u, ENERGY_CHARGE_BURN);
            }
            else if ((GetUnitAbilityLevel(u, ENERGY_CHARGE_BUFF) == 0) &&
                     (GetUnitAbilityLevel(u, ENERGY_CHARGE_BURN) > 0)){
                UnitRemoveAbility(u,ENERGY_CHARGE_BURN);
            }
            
            GroupRemoveUnit(g, u);
            u = FirstOfGroup(g);
        }
        DestroyGroup(g);
        DestroyBoolExpr(b);
        u = null;
        g = null;
        b = null;
    }

    private function onInit(){
        trigger t = CreateTrigger();
        integer i = 0;
        TriggerRegisterTimerEvent(t, 1.00, true);
        TriggerAddAction(t, function act);
        
        }
    }

//! endzinc