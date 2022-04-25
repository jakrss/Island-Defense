//! zinc
library HeartOfTheSea requires BonusMod {
	//Item ID for Charge of Valor
	private constant integer ITEM_ID = 'I06Z';
	//Armor bonus given
	private constant integer ARMOR_BONUS = 4;
	//HP Bonus given
	private constant integer HP_BONUS = 300;
	//Duration for the active ability (selected unit shares 50% of the damage they take and their armor is increased by 3)
	private constant real DURATION = 30.0;
	//Armor increase for the shared duration
	private constant real ACTIVE_DURATION = 10.0;
	//Damage shared
	private constant real DAMAGE_SHARED = .50;
	//Armor increase for the duration
	private constant integer ACTIVE_ARMOR = 3;

	private function onInit() {
		trigger t = CreateTrigger();
		t=null;
	}
	
}
//! endzinc