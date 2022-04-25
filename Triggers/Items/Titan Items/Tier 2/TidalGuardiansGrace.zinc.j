//! zinc
library TidalGuardiansGrace requires ItemExtras, BUM {
    //Item ID for Tidal Guardians Grace
    private constant integer ITEM_ID = 'I075';
    //ID of spawned minion thing
    private constant integer DUMMY_ID = 'n01F';
    //How long the spawn lasts
    private constant real DURATION = 45;
    //Spawn effect
    private constant string EFFECT = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl";
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function() -> boolean {
            unit killer = GetKillingUnit();
            unit dyer = GetTriggerUnit(); //lol
            unit shallowSpawn;
            if(UnitHasItemById(killer, ITEM_ID) && GetOwningPlayer(dyer) == Player(PLAYER_NEUTRAL_PASSIVE)) {
                shallowSpawn = CreateUnit(GetOwningPlayer(killer), DUMMY_ID, GetUnitX(dyer), GetUnitY(dyer), bj_UNIT_FACING);
                UnitApplyTimedLife(shallowSpawn, 'BTLF', DURATION);
                shallowSpawn = null;
            }
            killer = null;
            dyer = null;
            return false;
        });
        t=null;
	t = CreateTrigger();
	TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
	TriggerAddCondition(t, function() {
		if(GetUnitAbilityLevel(GetEventDamageSource(), 'A0BA') >= 1 && getRatioHealth(GetTriggerUnit()) <= 0.25 && IsUnitType(GetTriggerUnit(), UNIT_TYPE_STRUCTURE) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
			BlzSetEventDamage(GetEventDamage() * 2.5);
		}
	});
	t = null;
    }
    
}
//! endzinc