//! zinc
library AnkhAbsolution {
    //Ability ID for the Ankh of Absolution
    private constant integer ABILITY_ID = 'A0KG';
    //Special Effect Played
    private constant string EFFECT = "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl";
    //Abilities Added
    private constant integer DMG_ABILITY = 'A0KD';
    private constant integer AURA_ABILITY = 'A0KE';
    private constant integer HP_ABILITY = 'A0KA';
    private constant integer REGEN_ABILITY = 'A0KB';
    private constant integer REVIVE_ABILITY = 'A0KF';
    //How long it takes the REVIVE_ABILITY to work just so we don't remove it before it works on accident
    private constant real REVIVE_TIME = 10;
    
    //Hashtable ugh
    private hashtable ankhTable = InitHashtable();
    
    function ConsumeAnkh() {
        unit t = GetTriggerUnit();
        
        UnitAddAbility(t, DMG_ABILITY);
        UnitMakeAbilityPermanent(t, true, DMG_ABILITY);
        UnitAddAbility(t, AURA_ABILITY);
        UnitMakeAbilityPermanent(t, true, AURA_ABILITY);
        UnitAddAbility(t, HP_ABILITY);
        UnitMakeAbilityPermanent(t, true, HP_ABILITY);
        UnitAddAbility(t, REGEN_ABILITY);
        UnitMakeAbilityPermanent(t, true, REGEN_ABILITY);
        UnitAddAbility(t, REVIVE_ABILITY);
        DestroyEffect(AddSpecialEffectTarget(EFFECT, t, "overhead"));
        
        t = null;
    }
    
    function RemoveRevive() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        
        unit ankhUnit = LoadUnitHandle(ankhTable, 0, th);
        UnitRemoveAbility(ankhUnit, REVIVE_ABILITY);
        
        FlushChildHashtable(ankhTable, th);
        DestroyTimer(t);
        t = null;
        ankhUnit = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, Condition(function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                ConsumeAnkh();
            } else if(GetSpellAbilityId() == REVIVE_ABILITY) {
                BJDebugMsg("Hey Ankh Counts as a Spell!");
            }
            return false;
        }));
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            timer t;
            if(GetUnitAbilityLevel(u, REVIVE_ABILITY) > 0) {
                t = CreateTimer();
                SaveUnitHandle(ankhTable, 0, GetHandleId(t), u);
                TimerStart(t, REVIVE_TIME, false, function RemoveRevive);
                t = null;
            }
            u = null;
            return false;
        }));
        t = null;
    }
}
//! endzinc