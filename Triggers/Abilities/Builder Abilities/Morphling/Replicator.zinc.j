//! zinc
library MorphlingReplicator requires ABMA {
	//Generic:
	private constant boolean SendDebug = true;
	private constant integer aReplicate = 'A0QT';

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, Condition(function() -> boolean {
			unit uCaster = GetTriggerUnit();
			unit uNewUnit;
			unit uTarget = GetSpellTargetUnit();
			player pPlayer;
			integer i = GetUnitTypeId(uTarget);
			real rRatio;
			item iItem;
			//If it is Replicate being cast:
			if(GetSpellAbilityId() == aReplicate) {
				//If the target is viable (it is an Ultimate Tower, but not another Replicator):
				if(IsUnitUltimateTower(uTarget) && i != 'o01V') {
					rRatio = (GetUnitState(uCaster, UNIT_STATE_LIFE) / GetUnitState(uCaster, UNIT_STATE_MAX_LIFE));
					ShowUnit(uCaster, false);
					pPlayer = GetOwningPlayer(uCaster);
					uNewUnit = CreateUnit(pPlayer, i, GetUnitX(uCaster), GetUnitY(uCaster), GetUnitFacing(uTarget));
					KillUnit(uCaster);
					RemoveUnit(uCaster);
					SetUnitState(uNewUnit, UNIT_STATE_LIFE, (rRatio * (GetUnitState(uNewUnit, UNIT_STATE_MAX_LIFE))));
					UnitAddAbility(uNewUnit, aReplicate);
					DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", uNewUnit, "origin"));
					ABMAStartAbilityCooldown(uNewUnit, aReplicate, 180);
					SelectUnitAddForPlayer(uNewUnit, pPlayer);
				} else {
					ABMAStartAbilityCooldown(uCaster, aReplicate, 0.5);
				}
			}
			pPlayer = null;
			uCaster = null;
			uNewUnit = null;
			uTarget = null;
		return false;
		}));
		t = null;
	}
}
//! endzinc