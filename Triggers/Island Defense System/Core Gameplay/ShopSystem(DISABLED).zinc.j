/*


        public static integer RECIPES_PAGE_ONE_ID         = 'n01A';
        public static integer RECIPES_PAGE_TWO_ID         = 'n01B';
	public static integer RECIPES_PAGE_THREE_ID	  = 'n02E';
	public static integer RECIPES_PAGE_ONE_TIER3_ID	  = 'n01M';
	public static integer RECIPES_PAGE_TWO_TIER3_ID	  = 'n01N';
	public static integer RECIPES_PAGE_THREE_TIER3_ID = 'n01O';

HASHTABLE LAYOUT
-1 in Handle of Shop Unit is the Previous Shop Unit
0 in Handle of Shop Unit is the current shop unit
1 in Handle of Shop Unit is the next unit

110 is the index that createShop needs to return
111 is the index (page num)

0 is the first page in the shopIndex child key
1 is the max number of pages in the shopIndex integer
7 is the current index in the shopIndex integer (110)
10 -> (9 + max number of pages) are the individual pages

*/



//! zinc

library ShopSystem requires UnitManager {
    //Page Forward Item ID
    private constant integer PAGE_FORWARD_ID = 'I051';
    //Page Backward Item ID
    private constant integer PAGE_BACKWARD_ID = 'I050';
    //Switch Tier Item ID
    private integer SWITCH_TIER_ID = 'I07O';
    //Current index of shopHandle - incremented by 1 each time to give each shop a unique value
    private integer SHOP_INDEX = 0;
    //Max number of pages for any given shop
    private integer maxPages = 0;
    //Current index of shop
    private integer index = 0;
    //Time in between when the shops will reset for each player
    private constant real SELECT_CD_RESET = 30.0;
    private trigger selectTrigger = CreateTrigger();
    //Storing data because screw libraries
    private hashtable shopTable = InitHashtable();
    
    //Legit just gets us an integer for the shop index and increments the global
    public function createShop() -> integer {
        integer toReturn = SHOP_INDEX;
        SHOP_INDEX = SHOP_INDEX + 1;
        return toReturn;
    }
    
    //Adds a page
    public function addPage(integer shopIndex, unit u) -> boolean {
        unit shop = LoadUnitHandle(shopTable, 0, shopIndex);
        unit prevShopPage;
        unit shopPage;
        unit nextShopPage;
        unit tempUnit;
        integer sh = GetHandleId(shop);
        integer uh = GetHandleId(u);
        integer prevPageHandle;
        integer pageHandle;
        integer nextPageHandle;
        
        integer maxPages = LoadInteger(shopTable, 1, shopIndex);
        player p = GetOwningPlayer(shop);
        integer index = LoadInteger(shopTable, 0, GetHandleId(p));
        integer i = 0;
        integer z = 10;
        integer curPage;
        
        //No pages exist in this shop
        if(shop == null) {
            maxPages = 1;
            index = 10;
            shop = u;
            sh = GetHandleId(u);
            
            //Save the current unit as 0 in his handle
            //No other units so no previous or next units
            SaveUnitHandle(shopTable, 0, sh, shop);
            
            //Save the first page to the shop unit in the shopIndex integer
            SaveUnitHandle(shopTable, 0, shopIndex, shop);
            //Save max pages to table  && index too
            SaveInteger(shopTable, 1, shopIndex, maxPages);
            //Also save all the pages to it in order
            SaveUnitHandle(shopTable, 10, shopIndex, shop);
            
            SaveInteger(shopTable, 110, sh, shopIndex);
            
            p = GetOwningPlayer(shop);
            SaveInteger(shopTable, 0, GetHandleId(p), index);
            p = null;
            shop = null;
            u = null;
            
            return true;
            //We have a default shop, let's add it
        } else if(shop != null) {
            //Shop isn't null - there's a base unit for the shop so let's check the pages
            //and increase the maximum pages for this one to add (unit u)
            maxPages = maxPages + 1;
            
            //curPage is 9 + maxPages
            curPage = 9 + maxPages;
            prevShopPage = LoadUnitHandle(shopTable, curPage - 1, shopIndex);
            nextShopPage = LoadUnitHandle(shopTable, 10, shopIndex);
            
            prevPageHandle = GetHandleId(prevShopPage);
            nextPageHandle = GetHandleId(nextShopPage);
            
            //Update the previous page to point to this one now / add this as a page
            SaveUnitHandle(shopTable, 1, prevPageHandle, u);
            
            //And point the next one's previous to this one / add this as a page
            SaveUnitHandle(shopTable, -1, nextPageHandle, u);
            
            //Save the previous unit
            SaveUnitHandle(shopTable, -1, uh, prevShopPage);
            //Save the shop unit as it's own handle
            SaveUnitHandle(shopTable, 0, uh, u);
            //Save the next unit (AKA the first unit)
            SaveUnitHandle(shopTable, 1, uh, nextShopPage);
            
            //Save index of shop
            SaveInteger(shopTable, 110, uh, shopIndex);
            
            //Save maxPages
            SaveInteger(shopTable, 1, shopIndex, maxPages);
            SaveUnitHandle(shopTable, 9 + maxPages, shopIndex, u);
            
            p = null;
            prevShopPage = null;
            nextShopPage = null;
            shop = null;
            
            return true;
        }
        return false;
    }
    
    function getPages(unit u) -> integer {
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        integer maxPages = LoadInteger(shopTable, 1, shopIndex);
        
        return maxPages;
    }
    
    function setIndex(integer i, integer playerHandle, integer shopIndex) -> integer {
        integer toSet = i;
        integer maxPages = LoadInteger(shopTable, 1, shopIndex);
        
        SaveInteger(shopTable, 0, playerHandle, toSet);
        return toSet;
    }
    
    function switchTier(unit u) -> unit {
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        player p = GetOwningPlayer(u);
        integer index = LoadInteger(shopTable, 0, GetHandleId(p));
        
        if(index < 13) {
            index = setIndex(13, GetHandleId(p), shopIndex);
        } else if(index >= 13) {
            index = setIndex(10, GetHandleId(p), shopIndex);
        }
        
        p = null;
        return LoadUnitHandle(shopTable, index, shopIndex);
    }
    
    function nextPage(unit u) -> unit {
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        player p = GetOwningPlayer(u);
        integer index = LoadInteger(shopTable, 0, GetHandleId(p));
        integer maxPages = LoadInteger(shopTable, 1, shopIndex);
        if(index + 1 > 9 + maxPages) {
            index = 9;
        } else if(index == 0) {
            index = 10;
        } else if(index < 9) {
            index = 9;
        }
        
        index = setIndex(index + 1, GetHandleId(p), shopIndex);
        
        p = null;
        return LoadUnitHandle(shopTable, index, shopIndex);
    }
    
    function previousPage(unit u) -> unit {
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        player p = GetOwningPlayer(u);
        integer index = LoadInteger(shopTable, 0, GetHandleId(p));
        unit prev = LoadUnitHandle(shopTable, -1, uh);
        
        setIndex(index - 1, GetHandleId(p), shopIndex);
        
        p = null;
        return prev;
    }
    
    function getIndex(unit u) -> integer {
        return LoadInteger(shopTable, 0, GetHandleId(GetOwningPlayer(u)));
    }
    
    function indexOf(unit u) -> integer {
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        integer maxPages = 10 + LoadInteger(shopTable, 1, shopIndex);
        integer i = 10;
        unit tempPage;
        
        for(10 <= i < maxPages) {
            tempPage = LoadUnitHandle(shopTable, i, shopIndex);
            if(tempPage == u) return i - 10; //Index starts from 0
            tempPage = null;
        }
        return -1;
    }
    
    public function shopSystemInit() {
        integer consumablesShop;
        integer recipesShop;
        integer artifactsShop;
        timer t = GetExpiredTimer();
        player p = GetOwningPlayer(UnitManager.ARTIFACTS_PAGE_ONE);
        DestroyTimer(t);
        
        artifactsShop = createShop();
        addPage(artifactsShop, UnitManager.ARTIFACTS_PAGE_ONE);
        addPage(artifactsShop, UnitManager.ARTIFACTS_PAGE_TWO);
        
        consumablesShop = createShop();
        addPage(consumablesShop, UnitManager.CONSUMABLES_PAGE_ONE);
        addPage(consumablesShop, UnitManager.CONSUMABLES_PAGE_TWO);
        
        recipesShop = createShop();
        addPage(recipesShop, UnitManager.RECIPES_PAGE_ONE);
        addPage(recipesShop, UnitManager.RECIPES_PAGE_TWO);
	addPage(recipesShop, UnitManager.RECIPES_PAGE_THREE);
        addPage(recipesShop, UnitManager.RECIPES_PAGE_ONE_TIER3);
        addPage(recipesShop, UnitManager.RECIPES_PAGE_TWO_TIER3);
        addPage(recipesShop, UnitManager.RECIPES_PAGE_THREE_TIER3);
        p = null;
    }
    
    //Resets the shop and all other shop units (pages) that are associated with it
    public function resetShop(integer shopIndex) {
        unit prevShop;
        unit shop = LoadUnitHandle(shopTable, 0, shopIndex);
        unit nextShop;
        integer tempHandle = GetHandleId(shop);
        
        //While the shop is not equal to null so we have a current shop unit
        while(shop != null) {
            
            //Load the previous shop to remove it's 1 association with this unit
            prevShop = LoadUnitHandle(shopTable, -1, tempHandle);
            
            if(prevShop != null) {
                RemoveSavedHandle(shopTable, 1, GetHandleId(prevShop));
            }
            
            //Makes it look prettier this way
            //shop = LoadUnitHandle(shopTable, 0, tempHandle);
            
            //Load the next shop unit to remove it's -1 association with this unit
            nextShop = LoadUnitHandle(shopTable, 1, tempHandle);
            if(nextShop != null) {
                RemoveSavedHandle(shopTable, -1, GetHandleId(nextShop));
            }
            
            shop = null;
            shop = nextShop;
            FlushChildHashtable(shopTable, tempHandle);
            tempHandle = GetHandleId(shop);
        }
        prevShop = null;
        shop = null;
        nextShop = null;
    }
    
    public function shopSystemTerminate(){
        integer i = 0;
        
        for(0 <= i < SHOP_INDEX) {
            resetShop(i);
        }
    }
    
    public function onAct(){
        item i = GetSoldItem();
        integer id = GetItemTypeId(i);
        unit u = GetSellingUnit();
        unit v = GetBuyingUnit();
        player p = GetOwningPlayer(v);
        integer uh = GetHandleId(u);
        integer shopIndex = LoadInteger(shopTable, 110, uh);
        integer maxPages = LoadInteger(shopTable, 1, shopIndex);
        
        
        if (maxPages > 0){                
            if (id == PAGE_FORWARD_ID){
                u = nextPage(u);
                
                if (p == GetLocalPlayer()){
                    //DisableTrigger(selectTrigger);
                    ClearSelection();
                    SelectUnit(u, true);
                    //EnableTrigger(selectTrigger);
                }
                RemoveItem(i);
            }
            else if (id == SWITCH_TIER_ID){
                u = switchTier(u);
                
                if (p == GetLocalPlayer()){
                    //DisableTrigger(selectTrigger);
                    ClearSelection();
                    SelectUnit(u, true);
                    //EnableTrigger(selectTrigger);
                }
                RemoveItem(i);
            }
        }
        i = null;
        p = null;
        u = null;
        v = null;
    }
    
    //To reset the CD of the selection
    function cdReset() {
        timer t = GetExpiredTimer();
        player p = LoadPlayerHandle(shopTable, 0, GetHandleId(t));
        integer curIndex = LoadInteger(shopTable, 0, GetHandleId(p));
        integer shopIndex = LoadInteger(shopTable, 1, GetHandleId(t));
        integer startIndex = LoadInteger(shopTable, 2, GetHandleId(t)); //Starting index so we don't glitch people back to the first screen
        unit shop = LoadUnitHandle(shopTable, curIndex, shopIndex);
        boolean boo = LoadBoolean(shopTable, 5, GetHandleId(t));
        
        if(curIndex != startIndex && curIndex != 10 && !IsUnitSelected(shop, p) && !boo) {
            setIndex(10, GetHandleId(p), shopIndex);
        }
        FlushChildHashtable(shopTable, GetHandleId(t));
        DestroyTimer(t);
        t = null;
        p = null;
    }
    
    //On select we load their previous index in the shop then clear and select that for em
    //We also start a timer for 30 seconds to reset this
    function onSelect(unit shop) {
        player p = GetOwningPlayer(shop);
        integer curIndex = LoadInteger(shopTable, 0, GetHandleId(p));
        timer t = LoadTimerHandle(shopTable, 1, GetHandleId(p));
        
        //Shop handle and shop index to load stuff
        integer shopHandle = GetHandleId(shop);
        integer shopIndex = LoadInteger(shopTable, 110, shopHandle);
        integer prevIndex = LoadInteger(shopTable, 115, shopHandle);
        unit loadedPage = LoadUnitHandle(shopTable, curIndex, shopIndex);
        BJDebugMsg("Selected curIndex: " + I2S(curIndex));
        
        if(p == GetLocalPlayer() && prevIndex != curIndex) {
            DisableTrigger(selectTrigger);
            ClearSelection();
            SelectUnit(loadedPage, true);
            EnableTrigger(selectTrigger);
        }
        SaveInteger(shopTable, 115, shopHandle, curIndex);
        //If there's a timer we needa nuke everything about it so yeah
        if(t != null) {
            SaveBoolean(shopTable, 5, GetHandleId(t), true);
            t = null;
        }
        //Create a timer and save it in the players ID
        t = CreateTimer();
        SaveTimerHandle(shopTable, 1, GetHandleId(p), t);
        //Save the player handle in the timer
        SavePlayerHandle(shopTable, 0, GetHandleId(t), p);
        SaveInteger(shopTable, 1, GetHandleId(t), shopIndex);
        SaveInteger(shopTable, 2, GetHandleId(t), curIndex);
        TimerStart(t, SELECT_CD_RESET, false, function cdReset);
        t = null;
    }
    
    private function onInit() {          
        trigger t = CreateTrigger();
        timer ti = CreateTimer();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM);
        TriggerAddCondition(t, Condition(function() -> boolean {
            onAct();
            return false;
        }));
        t = null;
        /*TriggerRegisterAnyUnitEventBJ(selectTrigger, EVENT_PLAYER_UNIT_SELECTED);
        TriggerAddCondition(selectTrigger, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            unit shop = LoadUnitHandle(shopTable, 0, GetHandleId(u));
            integer shopIndex = LoadInteger(shopTable, 110, GetHandleId(u));
            integer prevIndex = LoadInteger(shopTable, 115, GetHandleId(u));
            integer curIndex = LoadInteger(shopTable, 0, GetHandleId(p));
            if(shop != null && curIndex != prevIndex) {
                DisableTrigger(selectTrigger);
                onSelect(shop);
                EnableTrigger(selectTrigger);
            }
            SaveInteger(shopTable, 115, GetHandleId(u), curIndex);
            shop = null;
            u = null;
            return false;
        }));*/
        TimerStart(ti, 10, false, function shopSystemInit);
        ti = null;
    }
}
//! endzinc