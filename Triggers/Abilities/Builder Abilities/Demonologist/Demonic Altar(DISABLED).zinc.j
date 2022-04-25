//! zinc
library DemonicAltar {
	private constant integer DemonicShock = 'A0N8';		//Demonic Shock ability ID
	private constant integer UnitType = 'o03S';						//Demonic Altar

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Target = GetTriggerUnit();
			unit Altar = GetEventDamageSource();
			real roll;
			if(GetUnitTypeId(Altar) == UnitType) {
				roll = GetRandomReal(0, 1);
				if(roll <= 0.2) {
				IssueTargetOrderById(Altar, "forkedlightning", Target);
				}
			}
			Target = null;
			Altar = null;
		});
		t = null;
	}
}
//! endzinc