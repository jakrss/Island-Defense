//! zinc
library GlaciousUltimate requires GT, xepreload, BUM, ABMA {
	private constant integer aIceShield = 'A0Q1'; //TGAF
    private constant real TICK_DURATION = 0.5; //how often to tick
    private constant real MANA_DRAIN = 10.0; //MP to drain per second active
    private constant real MANA_DRAIN_PER_DAMAGE = 3.0; //MP to drain per 1 damage absorbed
    private constant real MANA_PER_ATTACK = 250.0; //MP to give per attack
    private constant real ABILITY_COOLDOWN = 120.0; //Cooldown when glac goes OOM


    private boolean activeIceShield;
    private timer tickTimer;
    private real mpDrainTick = MANA_DRAIN * TICK_DURATION; //how much mana to drain per tick
    private unit uGlacious;

    private function onEnd() {
        //TODO: reset everything back to normal
        DestroyTimer(tickTimer);
        activeIceShield = false;
        uGlacious = null;
    }

    private function tickTimerTick() {
        real curMP = getMana(uGlacious);
        addMana(uGlacious, -mpDrainTick); //add negative mana to reduce by tick amount

        if (curMP < 50) { //check mana, if less than 50
            activeIceShield = false;
            ABMAStartAbilityCooldown(uGlacious, aIceShield, ABILITY_COOLDOWN); //Glac ran out of mana, put ult on CD
            onEnd();
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

        real damageReduce = incomingDamage * percMP;
        real drainMP = damageReduce * MANA_DRAIN_PER_DAMAGE;

        healUnit(uTarget, damageReduce); //heal glacious for the exact amount of damage to reduce
        addMana(uTarget, -drainMP); //add "negative" mana to reduce mana by drainMP
    }

	private function onInit() {
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, aIceShield);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit caster = GetSpellAbilityUnit();
            if (!activeIceShield) {
                onCast(caster); //ice shield is not active, lets activate it
            } else {
                onEnd();
            }
            caster = null;
            return false;
        }));
        XE_PreloadAbility(aIceShield);
		t = null;

        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function () -> boolean {
            unit attacker = GetEventDamageSource();
            unit target = GetTriggerUnit();
            
            if (activeIceShield) { //no point processing anything unless ult is active
                if(GetUnitAbilityLevel(attacker, aIceShield) > 0) { //attacker is titan & has learnt ult
                    onAttack(attacker);
                }

                if(GetUnitAbilityLevel(target, aIceShield) > 0) { //target is titan & has learnt ult
                    reduceDamage(target, GetEventDamage());
                }
            }
            attacker = null;
            target = null;
            return false;
        });
        t=null;
	}
}
//! endzinc