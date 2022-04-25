//! zinc
library FossuriousPassive requires GenericTitanTargets {
	private constant integer damageAmount = 100;
	private constant integer damageArea = 250;
    private constant real CoolDownTime = 3.0;
    private boolean CoolDown = false;

	private function SpellQualifies(integer SpellId) -> boolean {
		//The ability must be one of Fossurious' abilities:
		if(SpellId == 'A0PW' || SpellId == 'A0PZ'|| SpellId == 'A0PY' || SpellId == 'A0Q0' || SpellId == 'A0Q3') return true;
        //Nuke, Stealth, Heal, Unique, Scout - still need to add other ability IDs
		return false;
	}

    private function checkTarget(unit u, unit caster) -> boolean {
        return !IsUnit(u, caster) && IsUnitNukable(u, caster);
    }

	private function ResetCoolDown() {
		timer tCoolDown = GetExpiredTimer();
        CoolDown = false;
		DestroyTimer(tCoolDown);
		tCoolDown = null;
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Caster = GetTriggerUnit();
			integer SpellId = GetSpellAbilityId();
			real XLoc;
			real YLoc;
            unit ue = null;
            group g = CreateGroup();
            timer tInterval;


			if(SpellQualifies(SpellId)) {
                if (!CoolDown) {
                    CoolDown = true;
                    XLoc = GetUnitX(Caster);
                    YLoc = GetUnitY(Caster);
                    //Damage things:

                    GroupEnumUnitsInRange(g, XLoc, YLoc, damageArea, null);
                    ue = FirstOfGroup(g); 

                    while (ue != null) {
                        if (checkTarget(ue, Caster)) {
                            UnitDamageTarget(Caster, ue, damageAmount, true, false, null, DAMAGE_TYPE_MAGIC, null);
                        }
                        GroupRemoveUnit(g, ue);
                        ue = FirstOfGroup(g);
                    }
                    tInterval = CreateTimer();
                    TimerStart(tInterval, CoolDownTime, false, function ResetCoolDown);
                    GroupClear(g);
                    DestroyGroup(g);
                    ue = null;
                    g = null;
                }
			}
		Caster = null;
        tInterval = null;
		});
		t = null;

	}
}
//! endzinc