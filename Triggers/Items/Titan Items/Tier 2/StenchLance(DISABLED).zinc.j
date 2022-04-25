//! zinc
library StenchLance requires xebasic, xefx, xemissile, GameTimer {
    //Item ID for Stench Lance
    private constant integer ITEM_ID = 'I071';
    //Ability ID of the active ability
    private constant integer ABILITY_ID = 'A0IO';
    //Damage to do over the duration
    private constant real DAMAGE = 20;
    //Time to do the damage (duration of the ability)
    private constant real DURATION = 2.5;
    //Timer speed to do the damage
    private constant real TIMER_SPEED = 0.50;
    //Move-slow over the duration
    private constant real MOVE_SLOW = 0.40;
    //Hashtable (lol)
    private hashtable stenchTable = InitHashtable();
    //Attack type
    private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL;
    //Damage type
    private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL;
    //Weapon type (lol)
    private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS;
    //Missile model
    private constant string MISSILE = "Abilities\\Weapons\\Dyadmissile\\Dryadmissile.mdl";
    private constant real MISSILE_SPEED = 1200;
    private constant real MISSILE_ARC = .15;
    //On hit effect
    private constant string EFFECT = "war3mapImported\\DebuffPoisoned.mdx";
    
    struct lance extends xehomingmissile {
        
        
        method onHit() {
            //damage over time
            GameTimer t = GameTimer.newPeriodic(function(GameTimer t) {
                thistype this = t.data();
                UnitDamageTarget(this.caster, this.targetUnit, 
            start(TIMER_SPEED));
            GameTimer.setData(this);
    }
    
    function tick() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit caster = LoadUnitHandle(stenchTable, 0, th);
        unit target = LoadUnitHandle(stenchTable, 1, th);
        real originalMs = LoadReal(stenchTable, 2, th);
        real tickCount = LoadReal(stenchTable, 3, th);
        
        UnitDamageTarget(caster, target, DAMAGE / (DURATION / TIMER_SPEED), false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
        
        DestroyEffect(AddSpecialEffectTarget(EFFECT, target, "origin"));
        
        if(tickCount * TIMER_SPEED >= DURATION) {
            SetUnitMoveSpeed(target, originalMs);
            FlushChildHashtable(stenchTable, th);
            DestroyTimer(t);
        }
        t = null;
        caster = null;
        target = null;
    }
    
    function checkTimer() {
        if(timerToStart != null) {
            TimerStart(timerToStart, TIMER_SPEED, true, function tick);
            timerToStart = null;
        }
    }
    
    function updateDummy() {
        
    }
    
    function onCast() {
        unit caster = GetTriggerUnit();
        unit target = GetSpellTargetUnit();
        real targetMs = GetUnitMoveSpeed(target);
        timer t = CreateTimer(); // StenchTimer to track duration
        timer m = CreateTimer(); // Timer to move dummy (t gets started when it hits)
        integer timerHandle = GetHandleId(t);
        real tickCount = 0;
        lance missile;
        
        //Save variables to use later
        SaveUnitHandle(stenchTable, 0, timerHandle, caster);
        SaveUnitHandle(stenchTable, 1, timerHandle, target);
        SaveReal(stenchTable, 2, timerHandle, targetMs);
        SaveReal(stenchTable, 3, timerHandle, tickCount);
        
        //Save timer to the caster
        SaveTimerHandle(stenchTable, 0, GetHandleId(caster), t);
        
        //Set the unit new movespeed
        SetUnitMoveSpeed(target, targetMs * (1 - MOVE_SLOW));
        
        //Create the missile (which starts the timer when it hits)
        missile = xehomingmissile.create(GetUnitX(caster), GetUnitY(caster), 100, target, 20);
        missile.fxpath = MISSILE;
        missile.caster = caster;
        missile.poisonTimer = t;
        missile.launch(MISSILE_SPEED, MISSILE_ARC);
        
        t = null;
        target = null;
        caster = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            timer t = CreateTimer();
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            
            //Start a timer to create new timers
            TimerStart(t, .01, true, function checkTimer);
            
            t = null;
            return false;
        });
        t=null;
    }
	
}
//! endzinc