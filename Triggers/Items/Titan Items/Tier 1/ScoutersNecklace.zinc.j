//! zinc
library ScoutersNecklace requires xecast, Homecall, ItemExtras, Scouting, BUM {
    //Item ID of Scouters Necklace
    private constant integer ITEM_ID = 'I05O';
    //Item ID of the charged Scouters Necklace
    private constant integer C_ITEM_ID = 'I067';
    //Teleport ID
    private constant integer TELE_ID = 'A0DL';
    //Slow Ability
    private constant integer SLOW_ID = 'A0EN';
    //Order ID of the slow ability
    private constant integer ORDER_ID = 852096;
    //% MANA RETURNED
    private constant real MANA_RETURN = .25;
    //Kills to reset CD
    private constant integer MAX_KILLS = 15;
    //Hashtable
    private hashtable sTable = InitHashtable();
    
    function onKill() {
        unit u = GetKillingUnit();
        integer numKills = getHomecallKills(u);
        integer maxKills = getHomecallMaxKills(u);
        if(maxKills == 0) {
            setHomecallMaxKills(u, MAX_KILLS);
        }
        numKills = numKills + 1;
        addHomecallKill(u);
        SetItemCharges(GetItemFromUnitById(u, ITEM_ID), (15 - getHomecallKills(u)));
        if(numKills == maxKills && !UnitHasItemById(u, C_ITEM_ID)) {	
			RemoveItem(GetItemOfTypeFromUnitBJ(u, ITEM_ID));
			UnitAddItemById(u,C_ITEM_ID);
        }
    }
    
    function onTeleport() {
        unit u = GetTriggerUnit();
        player p = GetOwningPlayer(u);
        unit goldMine = getGoldMine();
        xecast dummyCast = xecast.createBasicA(SLOW_ID, ORDER_ID, p);
        dummyCast.castInPoint(GetUnitX(goldMine), GetUnitY(goldMine));
        setHomecallKills(u, 0);
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetKillingUnit();
			unit t = GetTriggerUnit();
            if(UnitHasItemById(u, ITEM_ID) && IsUnitType(t, UNIT_TYPE_STRUCTURE)) {
                onKill();
            }
            u=null;
            return false;
        });
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(UnitHasItemById(u, C_ITEM_ID) && GetSpellAbilityId() == TELE_ID) {
                onTeleport();
            }
            u=null;
            return false;
        });
        t = null;
    }
}
//! endzinc