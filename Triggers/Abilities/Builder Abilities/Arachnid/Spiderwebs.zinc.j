//! zinc
library Spiderwebs {
	private constant string Effect_Web = "Abilities\\Spells\\Undead\\Web\\WebTarget.mdl";

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit u;
			unit d;
			unit e;
			group g;
		//Let's check if its Arachnid level 2 panic:
	    if(GetSpellAbilityId() == 'A0M2' && GetUnitAbilityLevel(GetTriggerUnit(), 'A0M2') == 2) {
			u = GetTriggerUnit();
			g = CreateGroup();
			GroupEnumUnitsInRange(g, GetUnitX(u), GetUnitY(u), 400, null);
			e = FirstOfGroup(g);
			while(e != null) {
				if(IsUnitEnemy(e, GetOwningPlayer(u))) {
					d = CreateUnit(GetOwningPlayer(u), 'e01B', GetUnitX(e), GetUnitY(e), 0);
				UnitAddAbility(d, 'A0M4');
				SetUnitFacingToFaceLocTimed(d, Location(GetUnitX(e), GetUnitY(e)), 0);
				IssueTargetOrder(d, "slow", e);
				
				}
			GroupRemoveUnit(g, e);
			e = null;
			}
			DestroyGroup(g);
			DestroyEffect(AddSpecialEffectTarget(Effect_Web, u, "origin"));
		}
		u = null;
		g = null;
		d = null;
        });
        t = null;
    }
}
//! endzinc