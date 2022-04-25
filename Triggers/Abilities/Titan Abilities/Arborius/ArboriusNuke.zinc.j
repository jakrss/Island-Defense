//! zinc
library ArboriusNuke requires xecast {
	private constant integer ANuke = 'TAAQ';	//Nuke ID
	private constant integer APol = 'A0O1';		//Pollen Mark dummy ability
	private constant integer ASlow = 'A0OB';		//Slow dummy ability
	private constant integer PollenMark = 'B07A';
	private constant real AoE_Radius = 375;
	private constant real AoE_Detonation = 950;
	private constant real SlowDelay = 8.00;
	//Effects
	private constant string EffectExplosion = "ConflagrateGreen.mdx";
	private constant string EffectDetonation = "ArboriusNukeBlast.mdx";
	//Send Debug
	private constant boolean SD = false;
	//Hashtable
	private hashtable HashPollen = InitHashtable();
	
	private function TargetQualify(unit Target, unit Caster) -> boolean {
		//The target must not be 1) Structure 2) Already dead 3) Allied 4) Magic Immune/Invulnerable
		if(!IsUnitType(Target, UNIT_TYPE_STRUCTURE) && IsUnitAliveBJ(Target) && IsUnitEnemy(Target, GetOwningPlayer(Caster)) && !IsUnitType(Target, UNIT_TYPE_MAGIC_IMMUNE)) {
			return true;
		} else return false;
	}
	
	private function TriggerSlow() {
		timer SlowTimer = GetExpiredTimer();
		group SlowGroup = LoadGroupHandle(HashPollen, GetHandleId(SlowTimer), 0);
		player p = LoadPlayerHandle(HashPollen, GetHandleId(SlowTimer), 1);
		unit Caster = LoadUnitHandle(HashPollen, GetHandleId(SlowTimer), 2);
		integer nukeLvl = GetUnitAbilityLevel(Caster, ANuke);
		xecast dummyCast;
		unit u = FirstOfGroup(SlowGroup);
		if(nukeLvl > 3) { 
			SetUnitAbilityLevel(Caster, ANuke, nukeLvl - 3);
			BlzStartUnitAbilityCooldown(Caster, ANuke, 6.00 );
		}
		if(SD) BJDebugMsg("Timer out");
			while(u != null) {
				//Slow units that still have pollen mark.
				if(GetUnitAbilityLevel(u, PollenMark) > 0) {
					dummyCast = xecast.createBasicA(ASlow, 852075, p);
					dummyCast.castOnTarget(u);
					if(SD) BJDebugMsg("Slow cast");
				}
				GroupRemoveUnit(SlowGroup, u);
				u = FirstOfGroup(SlowGroup);
			}
		FlushChildHashtable(HashPollen, GetHandleId(SlowTimer));
		u = null;
		DestroyGroup(SlowGroup);
		DestroyTimer(SlowTimer);
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Caster = GetTriggerUnit();
			unit Target;
			integer NukeId = GetSpellAbilityId();
			integer NukeLvl = GetUnitAbilityLevel(Caster, NukeId);
			unit Dummy;
			real XLoc;
			real YLoc;
			real XTar;
			real YTar;
			group GPol;
			group GSlow;
			effect e;
			timer SlowTimer;
			xecast dummyCast;
			if(NukeId == ANuke) {
				//Second Cast:
				if(NukeLvl > 3) {
					XLoc = GetUnitX(Caster);
					YLoc = GetUnitY(Caster);
					if(SD) BJDebugMsg("Nuke secondary cast");
					GPol = CreateGroup();
					GroupEnumUnitsInRange(GPol, XLoc, YLoc, AoE_Detonation, null);
					Target = FirstOfGroup(GPol);
						while(Target != null) {
							//Damage units with a pollen mark:
							if(GetUnitAbilityLevel(Target, PollenMark) > 0) {
								UnitDamageTarget(Caster, Target, 105 + 25 * (NukeLvl - 3), true, false, null, DAMAGE_TYPE_MAGIC, null);
								UnitRemoveAbility(Target, PollenMark);
								//Effects:
								XTar = GetUnitX(Target);
								YTar = GetUnitY(Target);
								e = AddSpecialEffect(EffectDetonation,XTar, YTar);
								BlzSetSpecialEffectScale(e, 1.65);
								DestroyEffect(e);
								//--------
							}
							GroupRemoveUnit(GPol, Target);
							Target = FirstOfGroup(GPol);
						}
					SetUnitAbilityLevel(Caster, NukeId, NukeLvl - 3);
				} else if(NukeLvl <= 3) {
				//First Cast:
					XLoc = GetSpellTargetX();
					YLoc = GetSpellTargetY();
					if(SD) BJDebugMsg("Nuke cast");
					GPol = CreateGroup();
					GSlow = CreateGroup();
					SlowTimer = CreateTimer();
					TimerStart(SlowTimer, SlowDelay, false, function TriggerSlow);
					GroupEnumUnitsInRange(GPol, XLoc, YLoc, AoE_Radius, null);
					SavePlayerHandle(HashPollen, GetHandleId(SlowTimer), 1, GetOwningPlayer(Caster));
					Target = FirstOfGroup(GPol);
					while(Target != null) {
						if(TargetQualify(Target, Caster)) {
							dummyCast = xecast.createBasicA(APol, 852190, GetOwningPlayer(Caster));
							dummyCast.castOnTarget(Target);
							if(SD) BJDebugMsg("Pollen Mark cast");
							Dummy = null;
							GroupAddUnit(GSlow, Target);
						}
						GroupRemoveUnit(GPol, Target);
						Target = FirstOfGroup(GPol);
					}
					SaveGroupHandle(HashPollen, GetHandleId(SlowTimer), 0, GSlow);
					SaveUnitHandle(HashPollen, GetHandleId(SlowTimer), 2, Caster);
					//Effects:
					e = AddSpecialEffect(EffectExplosion,XLoc, YLoc);
					DestroyEffect(e);
					//--------
				SetUnitAbilityLevel(Caster, NukeId, NukeLvl + 3);
				}
			}
			SlowTimer = null;
			GSlow = null;
			Caster = null;
			Target = null;
			Dummy = null;
			DestroyGroup(GPol);
			GPol = null;
			e = null;
		});
		t = null;

	}
}
//! endzinc