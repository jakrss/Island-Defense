//! zinc
library VoodooWardsHandling requires BUM, ItemExtras {
	private constant integer Item_VoodooIdol = 'I05Y';
	private constant integer Item_PendantOfDarkArts = 'I06L';
	private constant integer Item_CryptomancersUrn = 'I03E';
	private constant integer Item_GrimSpear = 'I080';
	private constant string UnitType_VoodooWard = UnitId2String('o03H');
	private constant integer VoodooWardActive = 'A0K5';
	private constant integer VoodooWardPassive = 'A0IT';
	private constant string LifeStealEffect = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl";
	private constant string VoodooWardEffect = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl";
	private constant boolean SendDebug = false;
	private constant integer CryptomancersAura = 'A0FI';
	private constant integer HealingWardAura = 'Aoar';
	private constant integer Buff_Cryptomancer = 'B06D';
	private constant real LifeSteal_GrimSpear = 0.06;		//How much of wall maxHP should heal?
	private constant real CryptomancersAura_LifeStealBonus = 0.06;
	private constant real LifeSteal_CryptomancersUrn = 0.06;
	private constant real LifeSteal_PendantOfDarkArts = 0.04;
	private constant real LifeSteal_VoodooIdol = 0.02;
	private group Group_VoodooUnits = CreateGroup();
	private integer nVoodooWards = 0;
	private hashtable VoodooWardsHash = InitHashtable();

	function VoodooDamageLevel() {
		unit u = GetEnumUnit();
		SetUnitAbilityLevel(u, VoodooWardPassive, nVoodooWards + 1);
		if(SendDebug == true) { BJDebugMsg("Checking level for " + I2S(CountUnitsInGroup(Group_VoodooUnits))); }
		u = null;
	}

	//This function runs when a new ward is placed and when a ward dies, also takes care of the passive damage bonus:
	private function VoodooWardsReorder() {
		integer WardIndex = 0;
		integer CurrentSlot = 0;
		unit CurrentWard = null;
		while(WardIndex <= nVoodooWards) {
			CurrentWard = LoadUnitHandle(VoodooWardsHash, 0, WardIndex);
			if(CurrentWard != null) { WardIndex = WardIndex + 1; } 
				else { while(CurrentWard == null && WardIndex <= nVoodooWards) {
						CurrentWard = LoadUnitHandle(VoodooWardsHash, 0, WardIndex);
						WardIndex = WardIndex + 1;
					}
				}
			if(SendDebug == true) {
				if(CurrentWard != null) { BJDebugMsg("|cffffff00Found a ward from slot " + I2S(WardIndex)); }
				if(CurrentWard != null) { BJDebugMsg("|cffffff00Saving the ward found to slot " + I2S(CurrentSlot)); }
				if(CurrentWard != null && IsUnitAliveBJ(CurrentWard) == false) { BJDebugMsg("|cffff0000The ward is not alive, you dummy!"); }
				if(CurrentWard == null) { BJDebugMsg("|cffff0000Couldn't re-organize Voodoo Wards properly!"); }
			}
			SaveUnitHandle(VoodooWardsHash, 0, CurrentSlot, CurrentWard);
			//ShowTextTagForceBJ(true, CreateTextTagLocBJ("Saved to " + I2S(CurrentSlot), GetUnitLoc(CurrentWard), 0, 12, 200, 200, 200, 100), GetPlayersAll());		
			CurrentSlot = CurrentSlot + 1;
			CurrentWard = null;
		}
		if(SendDebug == true) { BJDebugMsg("|cff00ff00Ward re-organizing completed."); }
	}

	private function onInit() {
		//Registering a ward death, triggering a re-sorting of the wards and managing ward count.
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
		TriggerAddCondition(t, function() {
			unit DyingUnit = GetTriggerUnit();
			if(GetUnitTypeId(GetTriggerUnit()) == 'o03H') {
				if(SendDebug == true) { BJDebugMsg("|cff00ff00Registering a ward death."); }
				RemoveUnit(GetTriggerUnit());
				VoodooWardsReorder();
				nVoodooWards = nVoodooWards - 1;
				ForGroup(Group_VoodooUnits, function VoodooDamageLevel);
				if(SendDebug == true) { BJDebugMsg(I2S(nVoodooWards) + "|cff00ff00Voodoo Wards on the map."); }
			}
		DyingUnit = null;
		});
		t = null;
		t = CreateTrigger();
		onAcquireItem(t);
		TriggerAddCondition(t, function() {
			item Item = GetManipulatedItem();
			integer ItemType = GetItemTypeId(Item);
			unit Holder;
			if(ItemType == Item_CryptomancersUrn || ItemType == Item_PendantOfDarkArts || ItemType == Item_VoodooIdol) {
				Holder = GetTriggerUnit();
				if(nVoodooWards > 0) { DestroyEffect(AddSpecialEffectTarget(VoodooWardEffect, Holder, "chest")); }
				if(SendDebug == true) { BJDebugMsg("Joined group"); }
				if(IsUnitInGroup(Holder, Group_VoodooUnits) == false) { GroupAddUnit(Group_VoodooUnits, Holder); }
				SetUnitAbilityLevel(Holder, VoodooWardPassive, nVoodooWards + 1);
			}
			Holder = null;
			Item = null;
		});
		t = null;
		t = CreateTrigger();
		onLoseItem(t);
		TriggerAddCondition(t, function() {
			item Item = GetManipulatedItem();
			integer ItemType = GetItemTypeId(Item);
			unit Holder;
			if(ItemType == Item_CryptomancersUrn || ItemType == Item_PendantOfDarkArts || ItemType == Item_VoodooIdol) {
				Holder = GetTriggerUnit();
				GroupRemoveUnit(Group_VoodooUnits, Holder);
				if(nVoodooWards > 0) { DestroyEffect(AddSpecialEffectTarget(VoodooWardEffect, Holder, "chest")); }
				if(SendDebug == true) { BJDebugMsg("Left group"); }
			}
			Holder = null;
			Item = null;
		});
		t = null;
		//Registering when a Voodoo Ward is cast, re-sorts previously existing wards, keeps the count and creates new wards.
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Caster;
			unit VoodooWard;
			real WardDuration;
			real TargetX;
			real TargetY;
			real CasterX;
			real CasterY;
			integer WardIndex;
			integer WardLimit;
			boolean AddAuras;
			real Distance;
			if(GetSpellAbilityId() == VoodooWardActive) {
				Caster = GetTriggerUnit();
				TargetX = GetSpellTargetX();
				TargetY = GetSpellTargetY();
				CasterX = GetUnitX(Caster);
				CasterY = GetUnitY(Caster);
				Distance = SquareRoot((TargetX - CasterX) * (TargetX - CasterX) + (TargetY - CasterY) * (TargetY - CasterY));
				WardDuration = 150;
				WardLimit = 2;
				AddAuras = false;
				//Cryptomancer's Urn settings:
				if(UnitHasItemById(Caster, Item_CryptomancersUrn)) {
					WardLimit = 4;
					//Let's only shorten the duration (and add auras) if the player is not attempting to scout:
					if(Distance < 1000 || IsVisibleToPlayer(TargetX, TargetY, GetOwningPlayer(Caster)) == true) {
						AddAuras = true;
						WardDuration = 20;
					}
					if(SendDebug == true) { BJDebugMsg("|cff00ff00Registering a Cryptomancer's Urn."); }
				//Grim Spear
				} else if(UnitHasItemById(Caster, Item_GrimSpear)) {
					WardLimit = 2;
					if(SendDebug == true) { BJDebugMsg("|cff00ff00Registering a Grim Spear."); }
				//Pendant of Dark Arts settings:
				} else if (UnitHasItemById(Caster, Item_PendantOfDarkArts)) { 
					WardLimit = 3; 
					if(SendDebug == true) { BJDebugMsg("|cff00ff00Registering a Pendant of Dark Arts."); }
					} else if(SendDebug == true) { BJDebugMsg("|cff00ff00Registering a Voodooo Idol."); }
				//Apply the settings, and continue:
				if(nVoodooWards >= WardLimit) { //Let's kill a ward:
					VoodooWardsReorder();
					VoodooWard = LoadUnitHandle(VoodooWardsHash, 0, 0);
					if(VoodooWard == null) { BJDebugMsg("|cffff0000Error: failed to retrieve a ward!"); }
					RemoveUnit(VoodooWard);
					nVoodooWards = nVoodooWards - 1;
				}
				VoodooWard = CreateUnit(GetOwningPlayer(Caster), 'o03H', TargetX, TargetY, GetRandomReal(0, 360));
				nVoodooWards = nVoodooWards + 1;
				ForGroup(Group_VoodooUnits, function VoodooDamageLevel);
				SaveUnitHandle(VoodooWardsHash, 0, nVoodooWards, VoodooWard);
				if(SendDebug == true) {
					BJDebugMsg("|cffff0000Saving the new ward to slot " + I2S(nVoodooWards));
					BJDebugMsg(I2S(nVoodooWards) + "|cff00ff00Voodoo Wards on the map.");
				}
				DestroyEffect(AddSpecialEffectTarget(VoodooWardEffect, Caster, "chest"));
				UnitApplyTimedLife(VoodooWard, 'B061', WardDuration);
				if(AddAuras == true) {
					UnitAddAbility(VoodooWard, CryptomancersAura);
					UnitAddAbility(VoodooWard, HealingWardAura);
					if(SendDebug == true) { BJDebugMsg("Adding auras"); }
				}
				
			}
		VoodooWard = null;
		Caster = null;
		});
		t = null;
		//Let's detect attacks and see if we should heal the unit:
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Attacker = GetEventDamageSource();
			unit Target;
			real Damage;
			real LifeStealPercentage;
			real Heal;
			//Check if attacker carries a Voodoo item - or has Cryptomancer's Aura:
			if(UnitHasItemById(Attacker, Item_VoodooIdol) || UnitHasItemById(Attacker, Item_PendantOfDarkArts) || UnitHasItemById(Attacker, Item_CryptomancersUrn) || UnitHasItemById(Attacker, Item_GrimSpear) || UnitHasBuffBJ(Attacker, Buff_Cryptomancer) == true) {
				Target = GetTriggerUnit();
				if(GetUnitLifePercent(Attacker) < 100 && IsUnitEnemy(Target, GetOwningPlayer(Attacker)) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
					LifeStealPercentage = 0;
					Damage = GetEventDamage();
					//Let's grant the best possible lifesteal from the items:
					if(UnitHasItemById(Attacker, Item_CryptomancersUrn)) {
						LifeStealPercentage = LifeSteal_CryptomancersUrn;
						} else if(UnitHasItemById(Attacker, Item_PendantOfDarkArts)) {
							LifeStealPercentage = LifeSteal_PendantOfDarkArts;
							} else if(UnitHasItemById(Attacker, Item_VoodooIdol)) {
								LifeStealPercentage = LifeSteal_VoodooIdol;
								}
					//And then see if it has Cryptomancer's Aura buff:
					if(UnitHasBuffBJ(Attacker, Buff_Cryptomancer) == true) { LifeStealPercentage = LifeStealPercentage + CryptomancersAura_LifeStealBonus; }
					Heal = Damage * (nVoodooWards * LifeStealPercentage);
					if(UnitHasItemById(Attacker, Item_GrimSpear) && GetUnitAbilityLevel(Target, 'WALL') > 0) Heal = GetUnitState(Target, UNIT_STATE_MAX_LIFE) * LifeSteal_GrimSpear;
					if(Heal > 0) {
						DestroyEffect(AddSpecialEffectTarget(LifeStealEffect, Attacker, "origin"));
						addHealth(Attacker, Heal);
					}
				}
			}
			Attacker = null;
			Target = null;
		});
		t = null;
	}
}
//! endzinc