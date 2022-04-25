//! zinc
library Dawnkeeper requires BonusMod, Damage {
    //Item IDs
	private constant integer WatchersNecklace = 'I06N';	//Watcher's Necklace
    private constant integer ITEM_ID = 'I069';				//Dawnkeeper
    private constant integer RobeOfLies = 'I07K';			//Robe of Lies
    //Ability ID for Dawnkeeper
    private constant integer ACTIVE_ID = 'A04P';
	private constant integer DUMMY_ID = 'A0MN';				//Dummy ability to add buff to the target and caster.
    //Duration for the active ability (selected unit shares 50% of the damage they take and their armor is increased by 6)
    private constant real DURATION = 10.0;
    //Effect overhead of both units
    private constant string EFFECT = "Abilities\\Spells\\Items\\Alda\\AldaTarget.mdl";
    //Damage shared
    private constant real DAMAGE_SHARED = .30;
    //Armor increase for the duration
    private constant integer ACTIVE_ARMOR = 6;
    //Percentage of health healed on scouting ability
	private constant real HEAL_BONUS = 0.05;
    //The attack type when shared
    private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL;
    //The damage type when shared
    private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL;
    //The weapon type when shared
    private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS;
    //Lightning code
    private constant string L_CODE = "AFOD";
    //Hashtable to store the caster and target for damage taken events
    hashtable dawnTable = InitHashtable();
    
    function onExpire() {
        timer durationTimer = GetExpiredTimer();
        integer timerHandle = GetHandleId(durationTimer);
        unit caster = LoadUnitHandle(dawnTable, 0, timerHandle);
        unit target = LoadUnitHandle(dawnTable, 1, timerHandle);
        effect e = LoadEffectHandle(dawnTable, 2, GetHandleId(caster));
        effect te = LoadEffectHandle(dawnTable, 3, GetHandleId(caster));
        //Reset their armor bonus
        AddUnitBonus(caster, BONUS_ARMOR, ACTIVE_ARMOR * -1);
        AddUnitBonus(target, BONUS_ARMOR, ACTIVE_ARMOR * -1);
        DestroyEffect(e);
        DestroyEffect(te);
        
        //Clean up hashtable and timer
        RemoveSavedHandle(dawnTable, 0, timerHandle);
	RemoveSavedHandle(dawnTable, 1, timerHandle);
	RemoveSavedHandle(dawnTable, 0, GetHandleId(caster));
	RemoveSavedHandle(dawnTable, 1, GetHandleId(caster));
	RemoveSavedHandle(dawnTable, 0, GetHandleId(target));
	RemoveSavedHandle(dawnTable, 1, GetHandleId(target));
        DestroyTimer(durationTimer);
        durationTimer = null;
        e = null;
        te = null;
        caster = null;
        target = null;
    }

    function onCast() -> boolean {
        unit caster = GetTriggerUnit();
        unit target = GetSpellTargetUnit();
	unit dummy;
        timer durationTimer = CreateTimer();
        integer timerHandle = GetHandleId(durationTimer);
        integer casterHandle = GetHandleId(caster);
        integer targetHandle = GetHandleId(target);
        real casterX = GetUnitX(caster);
        real casterY = GetUnitY(caster);
        real targetX = GetUnitX(target);
        real targetY = GetUnitY(target);
        effect e;
        effect tE;
        if(IsUnitEnemy(target, GetOwningPlayer(caster))) {
            caster = null;
            target = null;
            DestroyTimer(durationTimer);
            return false;
        }
        e = AddSpecialEffectTarget(EFFECT, caster, "overhead");
        tE = AddSpecialEffectTarget(EFFECT, target, "overhead");
	dummy = CreateUnit(GetOwningPlayer(caster), 'e01B', casterX, casterY, 0);
	UnitAddAbility(dummy, DUMMY_ID);
	IssueImmediateOrderById(dummy, 852164);
	RemoveUnit(dummy);
	dummy = null;
	dummy = CreateUnit(GetOwningPlayer(target), 'e01B', targetX, targetY, 0);
	UnitAddAbility(dummy, DUMMY_ID);
	IssueImmediateOrderById(dummy, 852164);
	RemoveUnit(dummy);
	dummy = null;
        //Save the Caster
        SaveUnitHandle(dawnTable, 0, timerHandle, caster);
        
        //Save the target
        SaveUnitHandle(dawnTable, 1, timerHandle, target);
        
        //Increment the two units armor
        AddUnitBonus(caster, BONUS_ARMOR, ACTIVE_ARMOR);
        AddUnitBonus(target, BONUS_ARMOR, ACTIVE_ARMOR);
        
        //Start the timer
        TimerStart(durationTimer, DURATION, false, function onExpire);
        
        //Save the caster / target to the caster / target
        SaveUnitHandle(dawnTable, 0, casterHandle, caster);
        SaveUnitHandle(dawnTable, 1, casterHandle, target);
        
        SaveUnitHandle(dawnTable, 0, targetHandle, caster);
        SaveUnitHandle(dawnTable, 1, targetHandle, target);
        	
        //Save the Timer handle
        SaveTimerHandle(dawnTable, 2, casterHandle, durationTimer);
        SaveTimerHandle(dawnTable, 2, targetHandle, durationTimer);
        
        //Save the effects
        SaveEffectHandle(dawnTable, 3, casterHandle, e);
        SaveEffectHandle(dawnTable, 4, casterHandle, tE);
        
        e = null;
        tE = null;
        caster = null;
        target = null;
        durationTimer = null;
        return true;
    }

    function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            integer spellCast = GetSpellAbilityId();
            unit tempUnit = GetTriggerUnit();
            unit caster = LoadUnitHandle(dawnTable, 0, GetHandleId(tempUnit));
            //If the spell is correct AND the caster does not have another instance
            if(spellCast == ACTIVE_ID && caster == null) {
                onCast();
            }
	    if(isScout(GetSpellAbilityId()) && UnitHasItemById(tempUnit, ITEM_ID) && !UnitHasItemById(tempUnit, RobeOfLies)) {
		addHealth(tempUnit, getMaxHealth(tempUnit) * HEAL_BONUS);
		DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", tempUnit, "origin"));
	    }
	    caster = null;
            tempUnit = null;
            return false;
        });
        t=null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit d = GetTriggerUnit();
            integer dh = GetHandleId(d);
            unit lC = LoadUnitHandle(dawnTable, 0, dh); // Loaded Caster
            unit lT = LoadUnitHandle(dawnTable, 1, dh); // Loaded Target
            timer t = LoadTimerHandle(dawnTable, 2, dh); // loaded timer
            integer tempHandle;
            trigger tr = GetTriggeringTrigger();
			real dmgamount = GetEventDamage();
            //If we have a loaded caster / target pair
            if(lC != null && lT != null) {
                DisableTrigger(tr);
			BlzSetEventDamage(dmgamount * (1 - DAMAGE_SHARED));
			//Caster takes damage, so we deal 30% damage to lT (target):
			if(lC == d) {
				UnitDamageTarget(lC, lT, dmgamount * DAMAGE_SHARED, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
			//Target takes damage, so we deal 30% damage to lC (caster):
			} else if(lT == d) {
				UnitDamageTarget(lT, lC, dmgamount * DAMAGE_SHARED, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
			}
                EnableTrigger(tr);
            } else if((lC == null && lT != null) || (lC != null && lT == null) || (GetWidgetLife(lC) < .405 || GetWidgetLife(lT) < .405)) {
                //Caster or target is missing or dead
                //Caster is not null, flush table
                if(lC != null) {
                    tempHandle = GetHandleId(lC);
                    FlushChildHashtable(dawnTable, tempHandle);
                }
                //Target is not null, flush table
                if(lT != null) {
                    tempHandle = GetHandleId(lT);
                    FlushChildHashtable(dawnTable, tempHandle);
                }
                //Timer is not null, flush table
                if(t != null) {
                    tempHandle = GetHandleId(t);
                    FlushChildHashtable(dawnTable, tempHandle);
                    DestroyTimer(t);
                    t = null;
                }
            }
            t = null;
            d = null;
            lC = null;
            lT = null;
            tr = null;
            return false;
        });
        t = null;
    }
}
//! endzinc