//! zinc
library FossuriousScout requires xecast, ABMA {
    private constant integer aCryptSwarmers = 'A0Q3'; //Crypt Swarmer ability
    private constant integer uCryptSwarmers = 'u019'; //Crypt Swarmer unit
	private constant integer orderid = 852066;
    private group swarmGroup;
    private unit uFossurious;

    //Ability ID of the dummy ability:
    private constant integer aScoutDummy = 'A0C6'; //Dummy Ability
    private constant integer bScoutDummy = 'B088'; //Dummy Buff



    private function summonSwarm(integer numSwarm) {
        real XLoc = GetUnitX(uFossurious);
        real YLoc = GetUnitY(uFossurious);
        real angle = 360 / numSwarm;
        real count = 0;
        unit u;
        real newX;
        real newY;

        for(0 <= count < numSwarm) {
            u=CreateUnit(GetOwningPlayer(uFossurious), uCryptSwarmers, XLoc, YLoc, bj_DEGTORAD * (angle * count));
            UnitApplyTimedLife(u, 'BTLF', numSwarm * 15);
            UnitAddAbility(u, 'A0MF');
            newX = XLoc + 450 * Cos(bj_DEGTORAD * (angle * count));
            newY = YLoc + 450 * Sin(bj_DEGTORAD * (angle * count));
            IssuePointOrder(u, "move", newX, newY);
            GroupAddUnit(swarmGroup, u);
        }
    }

    private function enhanceSwarm() {
        unit u;

        GroupAddUnit(swarmGroup, uFossurious);
        u=FirstOfGroup(swarmGroup);
        while(u!=null) {
            //enhance swarm units
            ABMAMovespeedIncreasePercent(u, 5, 25);
            GroupRemoveUnit(swarmGroup, u);
            u=null;
            u=FirstOfGroup(swarmGroup);
        }
        DestroyGroup(swarmGroup);
    }

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            if(GetSpellAbilityId() == aCryptSwarmers) {
                uFossurious = GetTriggerUnit();
                swarmGroup = CreateGroup();
                if (UnitHasBuffBJ(uFossurious, bScoutDummy)) {
                    //Do super scout
                    summonSwarm(3);
                    enhanceSwarm();
                } else {
                    // normal scout
                    summonSwarm(1);
                }
            }
            return false;
        });
        t=null;

        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function () -> boolean {
            unit killer = GetKillingUnit();
            xecast dummyCast;
            if(GetUnitAbilityLevel(killer, aCryptSwarmers) > 0) { //Unit is titan
                if (BlzGetUnitAbilityCooldownRemaining(killer, aCryptSwarmers) < 1) { // Ability is off cooldown, apply dummy buff
                    dummyCast = xecast.createBasicA(aScoutDummy, orderid, GetOwningPlayer(killer));
                    dummyCast.castOnTarget(killer);
                }
            }
            killer = null;
            return false;
        });
        t=null;
    }
    
}
//! endzinc