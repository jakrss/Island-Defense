//! zinc
library ThievesEdge requires BonusMod, ItemExtras, BUM {
    //Item ID for Thieves Edge
    private constant integer ITEM_ID = 'I07D';
    //Ability ID for Thieves Edge active
    private constant integer ABILITY_ID = 'A0JC';
    //Effect for item teleport
    private constant string TELEPORT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl";
    //Effect for item sell
    private constant string SELL = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl";
    //ID of one of the item shops
    private constant integer ITEM_SHOP = 'n01W';
    //ID of the second page of the above
    private constant integer ITEM_SHOP_S = 'n01X';
    
    function iFilter() -> boolean {
        return GetUnitTypeId(GetFilterUnit()) == ITEM_SHOP ||
                GetUnitTypeId(GetFilterUnit()) == ITEM_SHOP_S;
    }
    
    function onCast() {
        unit caster = GetTriggerUnit();
        item target = GetSpellTargetItem();
        item lastSlot;
        unit goldMine;
        unit itemShop;
        group g;
        
        goldMine = getGoldMine();
        
        if(GetFreeSlots(goldMine) == 0) {
            BJDebugMsg("No free slots available on gold mine.");
            //Play SELL effect and sell item
            DestroyEffect(AddSpecialEffect(SELL, GetItemX(target), GetItemY(target)));
            //Drop last slot, add effected item, sell item, pickup dropped item
            lastSlot = UnitItemInSlot(goldMine, 5);
            
            //We need an item shop
            g = CreateGroup();
            GroupEnumUnitsInRectCounted(g, bj_mapInitialPlayableArea, Condition(function iFilter), 1);
            itemShop = FirstOfGroup(g);
            DestroyGroup(g);
            
            //Finally order to drop, add item, sell, add dropped item
            UnitDropItemPoint(goldMine, lastSlot, GetUnitX(goldMine), GetUnitY(goldMine));
            UnitAddItem(goldMine, target);
            UnitDropItemTarget(goldMine, target, itemShop);
            UnitAddItem(goldMine, lastSlot);
        } else {
            //Play teleport effect and add item to inventory
            DestroyEffect(AddSpecialEffect(TELEPORT, GetItemX(target), GetItemY(target)));
            UnitAddItem(goldMine, target);
            BJDebugMsg("Target Item ID: " + I2S(GetItemTypeId(target)));
        }
        g = null;
        goldMine = null;
        itemShop = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            return false;
        });
        t=null;
    }
	
}
//! endzinc