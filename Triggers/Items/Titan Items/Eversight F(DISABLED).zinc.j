//! zinc
library Eversight requires ItemExtras {
    //Whether the items stack
    private constant boolean CD_REDUCE_STACK = false;
    //If they do stack, what's the max CD reduction?
    private constant real MAX_CD_REDUCE = .8;
    //Voltrons is special I guess
    private constant integer VOLT_SCOUT = 'TVAD';
    private constant real TIMER_SPEED = .50;
    //hashtable
    private hashtable eversightTable = InitHashtable();
    
    
    function getLevelIncrease(integer itemId) -> integer {
        if(itemId == 'I05O') {
            return 1;
        } else if(itemId ==  'I06G') {
            return 2;
        } else if (itemId == 'I06N') {
            return 2;
        } else if (itemId == 'I04P') {
            return 2;
        } else if (itemId == 'I069') {
            return 3;
        } else if (itemId == 'I07U') {
            return 2;
        } else if (itemId == 'I07K') {
            return 2;
        }
        return 0;
    }
    
    function getMpRestore(integer itemId) -> real {
        if(itemId == 'I05O') {
            return .25;
        } else if(itemId ==  'I06G') {
            return .5;
        } else if (itemId == 'I06N') {
            return .5;
        } else if (itemId == 'I04P') {
            return .5;
        } else if (itemId == 'I069') {
            return .5;
        } else if (itemId == 'I07U') {
            return .5;
        } else if (itemId == 'I07K') {
            return .5;
        }
        return 0.0;
    }
    //Gets the item that provides the max benefit in CD reduction
    function getCdReduceItem(unit u) -> item {
        real cdReduce = 0;
        item reduceItem;
        item tempItem;
        integer slot = 0;
        real cdReduction;
        for(0 <= slot <= 5) {
            tempItem = UnitItemInSlot(u, slot);
            cdReduction = getLevelIncrease(GetItemTypeId(tempItem));
            if(cdReduction > 0) {
                if(cdReduce < cdReduction) {
                    reduceItem = tempItem;
                    cdReduce = cdReduction;
                }
            }
        }
        return reduceItem;
    }
    //Gets the item that provides the max benefit in MP restore
    function getMpRestoreItem(unit u) -> item {
        real mpRestore = 0;
        item reduceItem;
        item tempItem;
        integer slot = 0;
        real mpRestoration;
        for(0 <= slot <= 5) {
            tempItem = UnitItemInSlot(u, slot);
            mpRestoration = getMpRestore(GetItemTypeId(tempItem));
            if(mpRestoration > 0) {
                if(mpRestore < mpRestoration) {
                    reduceItem = tempItem;
                    mpRestore = mpRestoration;
                }
            }
        }
        return reduceItem;
    }
    
    public function eversightRestore(integer scoutId, unit u, real mpPercent) {
        real curMp = GetUnitState(u, UNIT_STATE_MANA);
        integer aLvl = GetUnitAbilityLevel(u, scoutId);
        real scoutCost = BlzGetUnitAbilityManaCost(u, scoutId, aLvl);
        real toRestore = scoutCost * mpPercent;
        real cdRemain = BlzGetUnitAbilityCooldown(u, scoutId, aLvl);
	//BJDebugMsg("RestoreActivated");							///SSSDASDA
        
        SetUnitState(u, UNIT_STATE_MANA, curMp + toRestore);
    }
    
    function checkForItem() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(eversightTable, 0, th);
        item i = getCdReduceItem(u);
        integer scoutAbility = getScout(u);
        integer aLvl = GetUnitAbilityLevel(u, scoutAbility);
        
        SetUnitAbilityLevel(u, scoutAbility, 1);
        if(getLevelIncrease(GetItemTypeId(i)) > 0) { 
            SetUnitAbilityLevel(u, scoutAbility, 1 + getLevelIncrease(GetItemTypeId(i)));
	    BJDebugMsg(I2S(getLevelIncrease));
        }
	if (!UnitHasItemOfTypeBJ(u,'I05O')) {
	    SetUnitAbilityLevel(u, scoutAbility, 1 );
	    BJDebugMsg("NoItemDetect");
	    BJDebugMsg(I2S(getLevelIncrease));
	}
        i = null;
    }
    
    public function onPickup() {
        item tempItem = GetManipulatedItem();
        integer itemId = GetItemTypeId(tempItem);
        real lvlIncrease = getLevelIncrease(itemId);	//Checks if the scouting ability level should be increased by 1, 2 or 3
        unit u = GetTriggerUnit();
        integer scoutAbility = getScout(u);		//Checks if the ability is a scouting ability, and which one
        real tempReal = 0;
        integer aLvl = GetUnitAbilityLevel(u, scoutAbility);
        timer t;
        
        if(UnitHasItemById(u, itemId)) {
            SetUnitAbilityLevel(u, scoutAbility, 1 + getLevelIncrease(itemId));	//Changes the scouting ability level according to item
            t = CreateTimer();								//But somehow the effect is looped? Elsewhere?
            
            SaveUnitHandle(eversightTable, 0, GetHandleId(t), u);
            
            TimerStart(t, TIMER_SPEED, true, function checkForItem);
        } else if(!UnitHasItemById(u, itemId)) {
            SetUnitAbilityLevel(u, scoutAbility, 1);
        }
        t = null;
        u = null;
        tempItem = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        onAcquireItem(t);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(getLevelIncrease(GetItemTypeId(GetManipulatedItem())) > 0) {
                onPickup();
            }
            return false;
        });
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u;
            real mpRestore;
            item mpItem;
            if(isScout(GetSpellAbilityId())) {
                u = GetTriggerUnit();
                mpItem = getMpRestoreItem(u);
                mpRestore = getMpRestore(GetItemTypeId(mpItem));
                eversightRestore(GetSpellAbilityId(), u, mpRestore);
                u = null;
            }
            return false;
        });
        t = null;
    }
}
//! endzinc                