//! zinc
    library SKOD {
	//SKOD for short because we aren't animals
	private struct SKOD {
	    private static constant integer abilityId = 'A0KY';
	    private static constant integer transformId = 'S00N';
	    private static constant integer barrelId = 'u011';
	    
	    private static method onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, Condition(function() -> boolean {
		    unit u = GetSpellTargetUnit();
		    unit tU = GetTriggerUnit();
		    if(GetSpellAbilityId() == thistype.abilityId && GetUnitTypeId(u) == thistype.barrelId) {
			UnitAddAbility(u, thistype.transformId);
		    } else if(GetSpellAbilityId() == thistype.abilityId) {
			SetUnitManaPercentBJ(tU, GetUnitManaPercent(tU) + 20);
		    }
		    u=null;
		    return false;
		}));
		t = null;
	    }
	}
    }
//! endzinc