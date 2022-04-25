//! zinc
library ArcaneAura requires ItemExtras, BUM {
	//Time to kill ourselves as maximum mana HAS to be coded, no way to manipulate it via objects.
	private constant real ManaBonus = 180;
	private constant integer AbilityCode = 'A0N5';	//Draenei's arcane aura
	private constant integer WellOfPowerItem = 'I056';
	
	private function onInit() {
		trigger t = CreateTrigger();
		//When the item is acquired we should add mana.
		onAcquireItem(t);
		TriggerAddCondition(t, function() {
			unit u = GetTriggerUnit();
			item i = GetManipulatedItem();
			integer n = GetItemCountFromUnitById(u, WellOfPowerItem);
			//Check that it is Well of Power and that the unit has only 1 (or less), oh and that the unit has Arcane Aura.
			if(GetItemTypeId(i) == WellOfPowerItem && n <= 1 && GetUnitAbilityLevel(u, AbilityCode) > 0 ) {
				addMaxMana(u, ManaBonus);
				IncUnitAbilityLevel(u, AbilityCode);	//Let's increase the mana regen a tenfold.
			}
		});
		t = null;
		t = CreateTrigger();
		//When the item is lost we should take the mana from him.
		onLoseItem(t);
		TriggerAddCondition(t, function() {
			unit u = GetTriggerUnit();
			item i = GetManipulatedItem();
			integer n = GetItemCountFromUnitById(u, WellOfPowerItem);
			//Check that it is Well of Power and that the unit has only 1 (or less), oh and that the unit has Arcane Aura.
			if(GetItemTypeId(i) == WellOfPowerItem && n <= 1 && GetUnitAbilityLevel(u, AbilityCode) > 0 ) {
				addMaxMana(u, -ManaBonus);
				DecUnitAbilityLevel(u, AbilityCode);
			}
		});
		t = null;
		t = CreateTrigger();
		//Let's see if Draenei has Well of Power as a structure.
	}
}
//! endzinc