//! zinc
library GlaciousUltimate requires xepreload, BUM, ABMA {
	private constant integer aIceShield = 'A0QV'; //TGAF
    private constant integer uGlaciousID = 'E00J';
    private constant real TICK_DURATION = 0.5; //how often to tick
    private constant real MANA_DRAIN = 10.0; //MP to drain per second active
    private constant real MANA_DRAIN_PER_DAMAGE = 3.0; //MP to drain per 1 damage absorbed
    private constant real MANA_PER_ATTACK = 250.0; //MP to give per attack
    private constant real ABILITY_COOLDOWN = 5.0; //Cooldown when glac goes OOM
    private constant real ABILITY_COOLDOWN_OOM = 120.0; //Cooldown when glac goes OOM



    private boolean activeIceShield = false;
    private timer tickTimer;
    private real mpDrainTick = MANA_DRAIN * TICK_DURATION; //how much mana to drain per tick
    private unit uGlacious;

    private function onDestroy() {
        //TODO: reset everything back to normal
        DestroyTimer(tickTimer);
        activeIceShield = false;
        uGlacious = null;
    }

    private function onEnd() {
        ABMAStartAbilityCooldown(uGlacious, aIceShield, ABILITY_COOLDOWN);
        onDestroy();
    }

    private function tickTimerTick() {
        real curMP = getMana(uGlacious);
        addMana(uGlacious, -mpDrainTick); //add negative mana to reduce by tick amount
        if (curMP < 50) { //check mana, if less than 50
            activeIceShield = false;
            UnitRemoveAbility(uGlacious, aIceShield);
            UnitAddAbility(uGlacious, aIceShield);
            ABMAStartAbilityCooldown(uGlacious, aIceShield, ABILITY_COOLDOWN_OOM); //Glac ran out of mana, put ult on CD
            onDestroy();
        }
    }
	
	private function onCast(unit caster) {
        activeIceShield = true;
        uGlacious = caster;
        ABMASetUnitAbilityCooldown(uGlacious, aIceShield, 0); //set ability cooldown to none (if OOM from last cast it will have a CD)

        tickTimer = CreateTimer();
        TimerStart(tickTimer, TICK_DURATION, true, function tickTimerTick);
	}

    private function onAttack(unit uAttacker) {
        addMana(uAttacker, MANA_PER_ATTACK); //give glac mana by MANA_PER_ATTACK
    }

    private function reduceDamage(unit uTarget, real incomingDamage) {
        real curMP = getMana(uTarget);
        real maxMP = getMaxMana(uTarget);
        real percMP = curMP / maxMP;
        real damageReduce;
        real drainMP;

        if (percMP < 0.3) percMP = 0.3;

        damageReduce = incomingDamage * percMP;
        drainMP = damageReduce * MANA_DRAIN_PER_DAMAGE;

        healUnit(uTarget, damageReduce); //heal glacious for the exact amount of damage to reduce
        addMana(uTarget, -drainMP); //add "negative" mana to reduce mana by drainMP
    }

	private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER);
        TriggerAddCondition(t, function() -> boolean {
            integer i = GetIssuedOrderId();
            unit caster = GetOrderedUnit();

            if (GetUnitTypeId(caster) == uGlaciousID) {
                if (i == OrderId("manashieldon")){
                    onCast(caster);
                }
                else if (i == OrderId("manashieldoff")){
                    onEnd();
                }
            }

            caster = null;
            return false;
        });
        t=null;
        XE_PreloadAbility(aIceShield);

        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function () -> boolean {
            unit attacker = GetEventDamageSource();
            unit target = GetTriggerUnit();
            real damage = GetEventDamage();
			            
            if (attacker != target) {
                if (activeIceShield) { //no point processing anything unless ult is active
                    if(GetUnitAbilityLevel(attacker, aIceShield) > 0) { //attacker is titan & has learnt ult
                        if( IsUnitEnemy(target, GetOwningPlayer(attacker)) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) onAttack(attacker);
                    }

                    if(GetUnitAbilityLevel(target, aIceShield) > 0) { //target is titan & has learnt ult
                        if (damage > 0) reduceDamage(target, damage);
                    }
                }
            }
            
            damage = 0.0;
            attacker = null;
            target = null;
            return false;
        });
        t=null;
	}
}
//! endzinc