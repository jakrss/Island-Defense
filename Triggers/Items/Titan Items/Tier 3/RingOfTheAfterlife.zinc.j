//! zinc
library RingOfTheAfterlife {
	private constant integer ItemID = 'I07Q';				//Ring of the Afterlife item ID.
	private constant integer DamageBonusID = 'A0MF';		//Goes up to 299% damage bonus.
	//private constant integer LostSoulBonus = 1; 		//Can't have enough levels on the ability, scrapped this.
	private constant real LostSoulDuration = 20;			//How long should Lost Souls live?
	private constant integer LostSoulUnitType = 'u013';	 //Unit ID of the Lost Soul.
	private constant boolean SendDebug = false;			//Defines whether this code sends debug or not.
	private constant string Effect = "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl";
	private integer NLS = 0;

	private function CheckForRing() -> boolean {
		return UnitHasItemOfTypeBJ(GetFilterUnit(), ItemID);
	}
	
	private function IsLostSoul() -> boolean {
		return IsUnitType(GetEnumUnit(), ConvertUnitType(LostSoulUnitType)) == true;
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
		TriggerAddCondition(t, function() {
			unit Killer = GetKillingUnit();
			real x;
			real y;
			unit LostSoul;
			group GroupLostSouls = CreateGroup();
			unit CurrentUnit;
			if(GetUnitAbilityLevel(GetTriggerUnit(), 'CRIT') == 1 && UnitHasBuffBJ(Killer, 'B06W') == true) {
				if(SendDebug) { BJDebugMsg(I2S(NLS) + " Lost Souls."); }
				LostSoul = GetTriggerUnit();
				x = GetUnitX(LostSoul);
				y = GetUnitY(LostSoul);
				LostSoul = CreateUnit(GetOwningPlayer(Killer), LostSoulUnitType, x, y, GetRandomReal(0, 360));
				UnitApplyTimedLife(LostSoul, 'B061', LostSoulDuration);
				NLS = NLS + 1;
				GroupEnumUnitsInRect(GroupLostSouls, GetPlayableMapRect(), function CheckForRing);
				CurrentUnit = FirstOfGroup(GroupLostSouls);
				while(CurrentUnit != null) {
					if(GetUnitAbilityLevel(CurrentUnit, DamageBonusID) != NLS + 1) {
						DestroyEffect(AddSpecialEffectTarget(Effect, CurrentUnit, "chest"));
					}
					IncUnitAbilityLevel(CurrentUnit, DamageBonusID);
					GroupRemoveUnit(GroupLostSouls, CurrentUnit);
					CurrentUnit = FirstOfGroup(GroupLostSouls);
				}
			DestroyGroup(GroupLostSouls);
			} if(GetUnitTypeId(GetTriggerUnit()) == LostSoulUnitType) {
				NLS = NLS - 1;
				if(SendDebug) { BJDebugMsg("Lost Soul death. " + I2S(NLS) + " remain."); }
				GroupEnumUnitsInRect(GroupLostSouls, GetPlayableMapRect(), function CheckForRing);
				CurrentUnit = FirstOfGroup(GroupLostSouls);
				while(CurrentUnit != null) {
					DecUnitAbilityLevel(CurrentUnit, DamageBonusID);
					GroupRemoveUnit(GroupLostSouls, CurrentUnit);
					CurrentUnit = FirstOfGroup(GroupLostSouls);
				}
			DestroyGroup(GroupLostSouls);
			if(SendDebug) { BJDebugMsg(I2S(NLS) + " Lost Souls."); }
			}
			
			CurrentUnit = null;
			GroupLostSouls = null;
			Killer = null;
			LostSoul = null;
		});
	}

}
//! endzinc