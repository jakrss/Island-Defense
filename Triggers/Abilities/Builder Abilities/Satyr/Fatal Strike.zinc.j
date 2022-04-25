//! zinc
library FatalStrike requires BUM {
	private constant integer ResearchFatalStrike = 'R00N';		//Fatal Strike research.
	private constant integer UnitType = 'h035';						//Satyr unit type.
	private constant string SpecialEffect = "Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl";
	private constant real StackDuration = 6;						//How long should the stacks last?
	private hashtable FatalStrikeHash = InitHashtable();

	private function ResetStacks() {
		timer ResetTimer = GetExpiredTimer();
		unit Satyr = LoadUnitHandle(FatalStrikeHash, GetHandleId(ResetTimer), 0);
		integer FatalStrikeStack = LoadInteger(FatalStrikeHash, GetHandleId(Satyr), 0);
		FatalStrikeStack = 0;
		FlushChildHashtable(FatalStrikeHash, GetHandleId(Satyr));
		FlushChildHashtable(FatalStrikeHash, GetHandleId(ResetTimer));
		AddSpecialEffectTargetUnitBJ("chest", Satyr, SpecialEffect);
		DestroyEffect(GetLastCreatedEffectBJ());
		//BJDebugMsg("Stacks reset, time ran out.");
		Satyr = null;
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Target = GetTriggerUnit();
			unit Satyr = GetEventDamageSource();
			real DamageDealt = GetEventDamage();
			integer FatalStrikeStack;
			timer ResetTimer;
			//Let's see that it is Satyr basic attacking and enemy unit and that he has Fatal Strike.
			if(GetUnitTypeId(Satyr) == UnitType && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL && IsUnitEnemy(Target, GetOwningPlayer(Satyr)) && GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchFatalStrike, true) > 0) {
				FatalStrikeStack = LoadInteger(FatalStrikeHash, GetHandleId(Satyr), 0);
				//If Satyr already has a target, lets see if this one is the target:
				if(FatalStrikeStack > 0 && Target == LoadUnitHandle(FatalStrikeHash, GetHandleId(Satyr), 1)) {
					FatalStrikeStack = FatalStrikeStack + 1;
					SaveInteger(FatalStrikeHash, GetHandleId(Satyr), 0, FatalStrikeStack);
					if(GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchFatalStrike, true) == 1) {
					DamageDealt = getHealth(Target) * 0.02 * FatalStrikeStack; }
					else if(GetPlayerTechCount(GetOwningPlayer(Satyr), ResearchFatalStrike, true) == 2) {
					DamageDealt = getMaxHealth(Target) * 0.02 * FatalStrikeStack; }
					UnitDamageTarget(Satyr, Target, DamageDealt, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_FORCE, WEAPON_TYPE_WHOKNOWS);
					ResetTimer = LoadTimerHandle(FatalStrikeHash, GetHandleId(Satyr), 2);
					AddSpecialEffectTargetUnitBJ("chest", Satyr, SpecialEffect);
					DestroyEffect(GetLastCreatedEffectBJ());
					//BJDebugMsg(I2S(FatalStrikeStack));
	
				//If it is not the target, let's flush the tables:
				} else if(FatalStrikeStack == 0) {
					FatalStrikeStack = 1;
					SaveInteger(FatalStrikeHash, GetHandleId(Satyr), 0, FatalStrikeStack);
					SaveUnitHandle(FatalStrikeHash, GetHandleId(Satyr), 1, Target);
					//BJDebugMsg("New target found.");
				}
				else { 
					FlushChildHashtable(FatalStrikeHash, GetHandleId(Satyr));
					FatalStrikeStack = 1;
					SaveInteger(FatalStrikeHash, GetHandleId(Satyr), 0, FatalStrikeStack);
					SaveUnitHandle(FatalStrikeHash, GetHandleId(Satyr), 1, Target);
					ResetTimer = LoadTimerHandle(FatalStrikeHash, GetHandleId(Satyr), 2);
					//BJDebugMsg("Target reset, new target found.");
				}
				//If Satyr has no previous targets, let's make this one a new target:
				
				
				DestroyTimer(ResetTimer);
				ResetTimer = CreateTimer();
				SaveTimerHandle(FatalStrikeHash, GetHandleId(Satyr), 2, ResetTimer);
				SaveUnitHandle(FatalStrikeHash, GetHandleId(ResetTimer), 0, Satyr);
				TimerStart(ResetTimer, StackDuration, false, function ResetStacks);
			}
		Satyr = null;	
		});
	}
}
//! endzinc