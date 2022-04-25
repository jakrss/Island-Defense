//! zinc
library LushMeadow requires BUM, MathLibs {
	//Arborius codes:
	private constant integer Healing = 'TAAE';			//Healing ability
	private constant integer AreaBuff = 'TAAI';			//Units inside Lush Meadow have this ability
	//Static stats:
	private constant integer Enemy_Info = 'A0KQ';
	private constant string ExpirationEffect = "ArboriusHealGreen.mdx";
	private constant real LushMeadowDuration = 9.00;
	private constant real TimerInterval = 0.50;
	private constant real LushRange = 350;
	private constant integer NumberOfEffects = 45;
	//Hashtable
	hashtable Hash = InitHashtable();
	//---------------------------------------------
	
	public function IsUnitInMeadow(unit Caster) {
    //This X & Y are the original cast point most recently saved
    real LushMeadowX = LoadReal(Hash, GetHandleId(Caster), 0);
    real LushMeadowY = LoadReal(Hash, GetHandleId(Caster), 1);
    //Caster X & Y to check distance
    real CasterX = GetUnitX(Caster);
    real CasterY = GetUnitY(Caster);
	if(LoadBoolean(Hash, GetHandleId(Caster), 2) == true) {
		getDistance(CasterX, CasterY, LushMeadowX, LushMeadowY);
		} else return;
	}
	
	private function CheckForUnits() {
		timer Timer = GetExpiredTimer();
		group GroupLushMeadow = CreateGroup();
		unit Caster = LoadUnitHandle(Hash, GetHandleId(Timer), 0);
		unit Target;
		real LushMeadowX = LoadReal(Hash, GetHandleId(Caster), 0);
		real LushMeadowY = LoadReal(Hash, GetHandleId(Caster), 1);
		integer IntegerTimerLoop = LoadInteger(Hash, GetHandleId(Timer), NumberOfEffects + 2) + 1;
		integer N = 0;
		boolean LushMeadowExist;
		//Let's group all units inside the Lush Meadow and heal them.
		//BJDebugMsg(I2S(IntegerTimerLoop));
		SaveInteger(Hash, GetHandleId(Timer), NumberOfEffects + 2, IntegerTimerLoop);
		GroupEnumUnitsInRange(GroupLushMeadow, LushMeadowX, LushMeadowY, LushRange, null);
		Target = FirstOfGroup(GroupLushMeadow);
		while( Target != null) {
			if(!IsUnitEnemy(Target, GetOwningPlayer(Caster)) && GetWidgetLife(Target) > .45) {
				addHealth(Target, 100);
			}
			GroupRemoveUnit(GroupLushMeadow, Target);
			Target = null;
			Target = FirstOfGroup(GroupLushMeadow);	
		}
		DestroyGroup(GroupLushMeadow);
		if(IntegerTimerLoop * TimerInterval >= LushMeadowDuration) {
			//BJDebugMsg("Calling down");
			FlushChildHashtable(Hash, GetHandleId(Timer));
			FlushChildHashtable(Hash, GetHandleId(Caster));
			DestroyEffect(LoadEffectHandle(Hash, GetHandleId(Timer), 1));
			DestroyTimer(Timer);
			LushMeadowExist = false;
		}
		Timer = null;
	}
	
	private function CreateLushMeadow(unit Caster, real CaX, real CaY) {
		integer IntegerTimerLoop = 0;
		effect Effect;
		timer Timer = CreateTimer();
		boolean LushMeadowExist = true;
		Effect = AddSpecialEffect(ExpirationEffect, CaX, CaY);
		BlzSetSpecialEffectTimeScale(Effect, 0.1);
		BlzSetSpecialEffectScale(Effect, 2.35 );
		SaveUnitHandle(Hash, GetHandleId(Timer), 0, Caster);
		SaveEffectHandle(Hash, GetHandleId(Timer), 1, Effect);
		SaveReal(Hash, GetHandleId(Caster), 0, CaX);
		SaveReal(Hash, GetHandleId(Caster), 1, CaY);
		SaveBoolean(Hash, GetHandleId(Caster), 2, LushMeadowExist);
		TimerStart(Timer, TimerInterval, true, function CheckForUnits);
		Caster = null;
		Timer = null;
		Effect = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Caster = GetTriggerUnit();
			real CaX = GetUnitX(Caster);
			real CaY = GetUnitY(Caster);
			if(GetSpellAbilityId() == Healing) {
				CreateLushMeadow(Caster, CaX, CaY);
			}
			Caster = null;
		});
		t = null;

	}
}
//! endzinc