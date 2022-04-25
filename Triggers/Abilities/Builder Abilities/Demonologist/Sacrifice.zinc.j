//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library Sacrifice requires GT, UnitManager {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A05P');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetSpellTargetUnit();
			unit s;
			player p = GetOwningPlayer(GetTriggerUnit());
            real x = GetUnitX(u);
            real y = GetUnitY(u);
            
            if (!UnitManager.isDefender(u)){
                //UnitAddAbility(u, 'S00F');	//Using Chaos to transform does not get rid of previous Timed Life.
                s = ReplaceUnitBJ(u, 'u00K', bj_UNIT_STATE_METHOD_MAXIMUM);
                UnitRemoveBuffsEx(s, false, false, false, false, true, false, false);
                UnitApplyTimedLife(s, 'BTLF', 15.0);
				SetUnitOwner(s, p, true);
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", s, "origin"));
				if(IsUnitSelected(u, p)) SelectUnitAddForPlayer(s, p);
            }
            u = null;
			s = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc