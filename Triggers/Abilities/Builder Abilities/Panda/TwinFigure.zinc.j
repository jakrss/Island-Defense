//! zinc
library TwinFigure requires MathLibs, xecast {
	private constant integer ATwinFigure = 'A0O2';		//Wind Walk triggering ability.
	private constant integer ATwinIllusion = 'A0H8';	//Illusion dummyx ability.
	private constant integer iFire = 'h02N';			//Unitype ID for Fire Form.
	private constant integer AInvis = 'A03H';
	private hashtable TwinHash = InitHashtable();
	
	//function isPointOrder(unit Panda) -> boolean {
	//	if(GetUnitCurrentOrder(Panda) == 
	//}
	
	function isPointOrder(unit Panda) -> boolean {
		//Is the current order smart, patrol or move.
		if(GetUnitCurrentOrder(Panda) == 851971 || GetUnitCurrentOrder(Panda) == 851991 || GetUnitCurrentOrder(Panda) == 851986) {
			return true ;
		}
		return false ;
	}
	
    private function onInit() {
        trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Panda = GetTriggerUnit();
			unit dummyUnit;
			real x;
			real y;
			boolean isActive = false;
			//We know it is Twin Figure cast:
			if(GetSpellAbilityId() == ATwinFigure && !IsUnitIllusion(Panda)) {
				x = GetUnitX(Panda);
				y = GetUnitY(Panda);
				UnitAddAbility(Panda, 'AGho');
				dummyUnit = CreateUnit(GetOwningPlayer(Panda), 'e01B', x, y, 90);
				UnitAddAbility(dummyUnit, 'A0H8');
				IssueTargetOrderById(dummyUnit, 852274, Panda);
				SaveUnitHandle(TwinHash, GetHandleId(dummyUnit), 0, Panda);
				isActive = true;
				SaveBoolean(TwinHash, GetHandleId(dummyUnit), 1, isActive);
			}
			Panda = null;
			});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SUMMON);
		TriggerAddCondition(t, function() {
			unit dummyUnit = GetSummoningUnit();
			unit Panda = LoadUnitHandle(TwinHash, GetHandleId(dummyUnit), 0);
			unit TwinFigure = GetSummonedUnit();
			boolean isActive = LoadBoolean(TwinHash, GetHandleId(dummyUnit), 1);
			location pointT;
			xecast dummyCast;
			real x;
			real y;
			real facing;
			real tx;
			real ty;
			//Here we check if this dummyx unit is casting illusion on Panda:
			if(isActive && GetUnitTypeId(dummyUnit) == 'e01B' && GetUnitTypeId(TwinFigure) == 'h02D') {
				BlzSetUnitSkin(TwinFigure, iFire);
				isActive = false;
				SaveBoolean(TwinHash, GetHandleId(dummyUnit), 1, isActive);
				x = GetUnitX(Panda);
				y = GetUnitY(Panda);

				UnitRemoveAbility(Panda, 'AGho');
				if(isPointOrder(Panda)) {
					x = GetUnitX(Panda);
					y = GetUnitY(Panda);
					facing = GetUnitFacing(Panda);
					tx = offsetXTowardsAngle(x, y, facing, 650);
					ty = offsetYTowardsAngle(x, y, facing, 650);
					IssuePointOrderById(TwinFigure, GetUnitCurrentOrder(Panda), tx, ty);
				}
				
			} else {
			
				BJDebugMsg("|cffff0000Error found in TwinFigure: Cannot detect cast conditions!");
			}
			dummyCast = xecast.createBasicA(ATwinIllusion, 852069, GetOwningPlayer(TwinFigure));
			dummyCast.castOnTarget(TwinFigure);
			Panda = null;
			TwinFigure = null;
			dummyUnit = null;
			});

    }
}
//! endzinc