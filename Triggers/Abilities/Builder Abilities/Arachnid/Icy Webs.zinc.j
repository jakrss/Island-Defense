//! zinc
library IcyWebs requires MathLibs {
	//Unit ID codes
	private constant unittype PoisonSpitter1 = ConvertUnitType('h04U');
	private constant integer IcywebsInfo = 'A0LS';
	private constant integer IcywebsActive = 'A0LX';
	private constant integer PoisonSpitInfo = 'A0M9';
	private constant integer PoisonSpitterCurse = 'A0M7';
	//private constant integer BlindChance = 1;	//Currently each Blinding Spit ability level gives 1% chance to blind.
	
	private function PoisonSpitter() {
		unit t = GetTriggerUnit();
		unit a = GetEventDamageSource();
		unit d;
		real tX = GetUnitX(t);
		real tY = GetUnitY(t);
		real aX = GetUnitX(a);
		real aY = GetUnitY(a);
		real angle = getAngle(aX, aY, tX, tY);
		d = CreateUnit(GetOwningPlayer(a), 'e01B', aX, aY, angle);
		UnitAddAbility(d, PoisonSpitterCurse);
		IssueTargetOrderById(d, 852190, t);
		RemoveUnit(d);
		t = null;
		a = null;
		d = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			real r;
			if(GetUnitAbilityLevel(GetTriggerUnit(), IcywebsInfo) > 0 && IsUnitEnemy(GetTriggerUnit(), GetOwningPlayer(GetEventDamageSource())) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
				UnitAddAbility(GetTriggerUnit(), IcywebsActive);
				SetUnitAbilityLevel(GetTriggerUnit(), IcywebsActive, GetUnitAbilityLevel(GetTriggerUnit(), IcywebsInfo));
				IssueTargetOrderById(GetTriggerUnit(), 852075, GetEventDamageSource());
				UnitRemoveAbility(GetTriggerUnit(), IcywebsActive);
			}
			if(GetUnitAbilityLevel(GetEventDamageSource(), PoisonSpitInfo) > 0 && IsUnitEnemy(GetTriggerUnit(), GetOwningPlayer(GetEventDamageSource())) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
				r = GetRandomReal(0,100);
				//Level 1 Spit
				if(r <= 1.75 * GetUnitAbilityLevel(GetEventDamageSource(), PoisonSpitInfo)) {
					PoisonSpitter();
				}
				//The multishot of Webweavers (we already know they have Poison Spit, so they must be Webweavers):
				if(GetPlayerTechCount(GetOwningPlayer(GetEventDamageSource()), 'R04S', true) > 0) {
					if(GetUnitAbilityLevel(GetEventDamageSource(), 'A03A') >= 5) {
						SetUnitAbilityLevel(GetEventDamageSource(), 'A03A', 1);
					} else if(GetUnitAbilityLevel(GetEventDamageSource(), 'A03A') < 12) {
						IncUnitAbilityLevel(GetEventDamageSource(), 'A03A');
					}
				}
			}
		});
		t = null;
	}
}
//! endzinc