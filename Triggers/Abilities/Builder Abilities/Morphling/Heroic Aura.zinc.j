//! zinc

library HeroicAura requires TrollVoodoo {
    private constant integer ABILITY_ID = 'A06L';
    private constant integer BUFF_ID = 'B02R';
	
	function WasUnOrder() -> boolean {
		return (OrderId2String(GetIssuedOrderId()) == "undefend" ||
			    OrderId2String(GetIssuedOrderId()) == "magicundefend" ||
			    OrderId2String(GetIssuedOrderId()) == "unmanashield" ||
			    OrderId2String(GetIssuedOrderId()) == "unimmolation" ||
			    OrderId2String(GetIssuedOrderId()) == "undivineshield");
	}
    
    private function onInit(){
        trigger t = CreateTrigger();
        Damage_RegisterEvent(t);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
			player p = GetOwningPlayer(u);
            unit v = null;
            unit a = GetEventDamageSource();
            group g = null;
            filterfunc f = null;
            real halfDamage = (GetEventDamage() / 2.0);
            if (GetUnitAbilityLevel(u, BUFF_ID) > 0 && IsUnitEnemy(u, GetOwningPlayer(a))) {
                // Check for the source of the Aura
                g = CreateGroup();
                f = Filter(function() -> boolean {
                    return GetUnitAbilityLevel(GetFilterUnit(), ABILITY_ID) > 0 && UnitAlive(GetFilterUnit());
                });
                GroupEnumUnitsInRange(g, GetUnitX(u), GetUnitY(u), 800.0, f);
                
                v = FirstOfGroup(g);
                while (v != null) {
					// Found a unit with the aura!
					if (IsUnitAlly(v, p)) {
						// Deal half damage
						DamageLater.create(a, v, halfDamage, Damage_GetType());
						Damage_Block(halfDamage);
						break;
					}
					GroupRemoveUnit(g, v);
					v = FirstOfGroup(g);
                }
                
                DestroyGroup(g);
                DestroyFilter(f);
                f = null;
                g = null;
            }
            a = null;
            u = null;
            return false;
        }));
		
		// Morphling Part
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER);
		TriggerAddCondition(t, Condition(function() -> boolean {
			return GetTriggerEventId() != EVENT_PLAYER_UNIT_ISSUED_ORDER || 
				   ((OrderId2String(GetIssuedOrderId()) == "immolation" || OrderId2String(GetIssuedOrderId()) == "unimmolation") &&
				    GetUnitAbilityLevel(GetOrderedUnit(), 'A06M') > 0 && GetUnitState(GetOrderedUnit(), UNIT_STATE_LIFE) > 0);
		}));
		TriggerAddAction(t, function() {
			unit u = GetOrderedUnit();
			if (WasUnOrder()) UnitRemoveAbility(u, ABILITY_ID);
			else UnitAddAbility(u, ABILITY_ID);
			u = null;
		});
		
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc