//! zinc
library NestBuilder {
	private constant unittype ut = ConvertUnitType('h04P');

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_START);
		TriggerAddCondition(t, function() {
		//Let's check if its Spider Nest Builder
	    if(IsUnitType(GetTriggerUnit(), ut)) {
			RemoveUnit(GetTriggerUnit());
		}
        });
        t = null;
    }
}
//! endzinc