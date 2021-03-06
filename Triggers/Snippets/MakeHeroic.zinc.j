//! zinc
library HeroicUnit
{

// Note: Does not work on Morphing units

//! textmacro CreateObjects takes HERO, SPELL, ITEM
///! external ObjectMerger w3u nech $HERO$ uabi "AInv" uhhb 1 ustr 1
///! external ObjectMerger w3a Amrf $SPELL$ Emeu 1 "$HERO$"
///! external ObjectMerger w3t tkno $ITEM$ iabi "$SPELL$"

constant integer HERO_ID = '$HERO$'; //Hero type into which the unit morphs.
constant integer SPELL_ID = '$SPELL$'; //Spell that morphs the unit into a hero temporarily.
constant integer ITEM_ID = '$ITEM$'; //Powerup that holds the morphing spell
constant integer BONUS_ID = 'AIs1'; //Stat bonus ability. Must provide exactly the same stats of the hero.
constant integer DETECTOR = 'Adef'; //Used to detect morphing. Immolation could be used too
constant integer ORDER = 852056; //Order Id for "undefend". Should be 852178 for "unimmolation"

//! endtextmacro
//! runtextmacro CreateObjects("NUMH", "AUMH", "IUMH")

function OnMorph() -> boolean
{
    unit u = GetTriggerUnit();
    trigger t = GetTriggeringTrigger();
    if (GetTriggerEventId() == EVENT_UNIT_STATE_LIMIT)
    {
        DisableTrigger(t);
        UnitRemoveAbility(u, SPELL_ID);
    }
    else if (GetUnitTypeId(u) != HERO_ID)
    {
        UnitAddAbility(u, SPELL_ID);
        UnitAddAbility(u, BONUS_ID);
        UnitMakeAbilityPermanent(u, true, BONUS_ID);
        TriggerRegisterUnitStateEvent(t, u, UNIT_STATE_LIFE, GREATER_THAN, GetWidgetLife(u)+1.);
        RemoveItem(UnitAddItemById(u, ITEM_ID));
    }
    else
    {
        UnitAddAbility(u, DETECTOR);
    }
    t = null;
    u = null;
    return false;
}

public function UnitMakeHeroic (unit u) -> boolean
{
    trigger t = CreateTrigger();
    real hp = GetWidgetLife(u);
    real mp = GetUnitState(u, UNIT_STATE_MANA);
    SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE));
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_ISSUED_ORDER);
    TriggerAddCondition(t, Condition(function OnMorph));
    UnitAddAbility(u, 'AInv');
    UnitAddAbility(u, DETECTOR);
    UnitAddAbility(u, BONUS_ID);
    RemoveItem(UnitAddItemById(u, ITEM_ID));
    UnitRemoveAbility(u, BONUS_ID);
    SetWidgetLife(u, hp);
    SetUnitState(u, UNIT_STATE_MANA, mp);
    SetUnitAnimation(u, "stand");
    DestroyTrigger(t);
    t = null;
	UnitMakeAbilityPermanent(u, true, 'AHer');
    return GetUnitAbilityLevel(u, 'AHer') > 0;
}

}

//! endzinc