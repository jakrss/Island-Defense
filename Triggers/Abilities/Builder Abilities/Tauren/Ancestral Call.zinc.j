//! zinc
library AncestralCall requires xemissile {
    //Ability ID of Ancestral Call
    private constant integer ABILITY_ID = 'A061';
    //Duration of damage split
    private constant real DURATION = 10.0;
    //Area of effect to find the towers
    private constant real AOE = 1000;
    //Damage split between all of the towers in range
    private constant real DMG_REDUCED = .90;
    //Model of the Missile
    private constant string MISSILE_EFFECT = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl";
    //Model to play on hit
    private constant string HIT_EFFECT = "Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl";
    //Hashtable
    private hashtable CALL_TABLE = InitHashtable();
    
    
    //No need to increase health or anything in this trigger, that's taken care of in Tauren EXP above
    struct angryAncestor extends xehomingmissile {
	real damage = 0;
	unit attacker;
	
	private method onHit() {
	    UnitDamageTarget(attacker, this.targetUnit, this.damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS);
	}
    }
    
    function resetUnit() {
	timer t = GetExpiredTimer();
	unit caster = LoadUnitHandle(CALL_TABLE, 0, GetHandleId(t));
	
	FlushChildHashtable(CALL_TABLE, GetHandleId(t));
	FlushChildHashtable(CALL_TABLE, GetHandleId(caster));
	DestroyTimer(t);
	caster = null;
	t = null;
    }
    
    function onCallCast(unit caster) {
	integer casterId = GetHandleId(caster);
	timer t = CreateTimer();
	
	//Save the unit handle so we can reset it to 0 after
	SaveUnitHandle(CALL_TABLE, 0, GetHandleId(t), caster);
	
	TimerStart(t, DURATION, false, function resetUnit);
	
	//Save the Timer to the Caster so we know if he has an active spell goin
	SaveTimerHandle(CALL_TABLE, 10, casterId, t);
	caster = null;
	t = null;
    }
    
    function countTotemTowers(unit tauren) -> integer {
	group towers = CreateGroup();
	real tX = GetUnitX(tauren);
	real tY = GetUnitY(tauren);
	unit u;
	integer numTowers = 0;
	filterfunc f = Filter(function() -> boolean {
            integer mUnitId = GetUnitTypeId(GetFilterUnit());
	    //Returns true if it's a totem tower
	    return mUnitId == 'e00Q' || mUnitId == 'e00S' || 
	    	   mUnitId == 'e00T' || mUnitId == 'e00U';
        });
	GroupEnumUnitsInRange(towers, tX, tY, AOE, f);
	u = FirstOfGroup(towers);
	while (u != null) {
	    numTowers = numTowers + 1;
	    GroupRemoveUnit(towers, u);
	    u = null;
	    u = FirstOfGroup(towers);
	}
	DestroyGroup(towers);
	tauren = null;
	DestroyFilter(f);
	return numTowers;
    }
    
    function onTakeDamage(unit tauren, unit attacker, real damageReduced) {
	group towers = CreateGroup();
	angryAncestor karen;
	integer numTowers = 0;
	real tX = GetUnitX(tauren);
	real tY = GetUnitY(tauren);
	unit u;
	filterfunc f = Filter(function() -> boolean {
            integer mUnitId = GetUnitTypeId(GetFilterUnit());
	    //Returns true if it's a totem tower
	    return mUnitId == 'e00Q' || mUnitId == 'e00S' || 
	    mUnitId == 'e00T' || mUnitId == 'e00U';
        });
	DestroyEffect(AddSpecialEffectTarget(HIT_EFFECT, tauren, "origin"));
	
	GroupEnumUnitsInRange(towers, tX, tY, AOE, f);
	numTowers = CountUnitsInGroup(towers);
	u = FirstOfGroup(towers);
	while(u != null) {
            karen = angryAncestor.create(tX, tY, 100, u, 20);
            karen.fxpath = MISSILE_EFFECT;
            karen.damage = damageReduced / numTowers;
            karen.attacker = attacker;
            karen.launch(800, .1);
	    GroupRemoveUnit(towers, u);
	    u = null;
	    u = FirstOfGroup(towers);
	}
	DestroyGroup(towers);
	u = null;
	attacker = null;
	tauren = null;
	DestroyFilter(f);
    }
    
    private function onInit() {
	trigger t = CreateTrigger();
	TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
	TriggerAddCondition(t, Condition(function() -> boolean {
	    unit caster = GetTriggerUnit();
	    integer casterId = GetHandleId(caster);
	    timer t = LoadTimerHandle(CALL_TABLE, 10, GetHandleId(caster));
	    //Check for the integer that we store at 10 in the CALL_TABLE that basically says whether an instance is currently happening right now or not
	    if(GetSpellAbilityId() == ABILITY_ID && t == null) {
		onCallCast(caster);
	    }
	    t = null;
	    caster = null;
	    return false;
	}));
	t = null;
	t = CreateTrigger();
	TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
	TriggerAddCondition(t, Condition(function() -> boolean {
	    unit attacked = GetTriggerUnit();
	    unit attacker = GetEventDamageSource();
	    integer attackedId = GetHandleId(attacked);
	    real damage = GetEventDamage();
	    timer t = LoadTimerHandle(CALL_TABLE, 10, GetHandleId(attacked));
	    if(t != null && countTotemTowers(attacked) > 0) {
                BlzSetEventDamage(damage * (1-DMG_REDUCED));
		//1 - DMG_REDUCED is the amount of damage reduced
		onTakeDamage(attacked, attacker, damage * DMG_REDUCED);
	    }
	    t = null;
	    attacked = null;
	    attacker = null;
	    return false;
	}));
	t = null;
    }
}
//! endzinc