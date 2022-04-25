//! zinc
library FeralTowerRegeneration requires GameTimer {
    constant integer DAY_REGEN_ID = 'A0NR';
    constant integer DAY_REGEN_ICON_ID = 'A0NT';
    constant integer NIGHT_REGEN_ID = 'A0NS';
    constant integer NIGHT_REGEN_ICON_ID = 'A0NU';

    constant integer ISLAND_BLOOM_ID = 'o03C';
    constant integer DISABLE_ATTACK = '&noa';
	
    integer TOWER_IDS[10];
    function initTowerIds(){
        TOWER_IDS[0] = 'o032';
        TOWER_IDS[1] = 'o033';
        TOWER_IDS[2] = 'o034';
        TOWER_IDS[3] = 'o035';
        TOWER_IDS[4] = 'o036';
        TOWER_IDS[5] = 'o037';
        TOWER_IDS[6] = 'o038';
        TOWER_IDS[7] = 'o039';
        TOWER_IDS[8] = 'o03A';
        TOWER_IDS[9] = 'o03B';
    }
	private boolexpr bloomFilter = null;
	private boolexpr feralFilter = null;
    
    struct TempUnit {
        public unit u = null;
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.u = u;
            return this;
        }
    }
    
    function setUnitRegenDay(unit u){
        UnitRemoveAbility(u, NIGHT_REGEN_ID);
        UnitRemoveAbility(u, NIGHT_REGEN_ICON_ID);
        UnitAddAbility(u, DAY_REGEN_ICON_ID);
        UnitAddAbility(u, DAY_REGEN_ID);
        
    }
	
    function setUnitRegenNight(unit u){
        UnitRemoveAbility(u, DAY_REGEN_ID);
        UnitRemoveAbility(u, DAY_REGEN_ICON_ID);
        UnitAddAbility(u, NIGHT_REGEN_ICON_ID);
        UnitAddAbility(u, NIGHT_REGEN_ID);
    }
	
    public function getFeralTowerLevel(unit u) -> integer {
        integer id = GetUnitTypeId(u);
        integer i = 0;
        integer result = -1;
        for(0 <= i <= 9){
            if (TOWER_IDS[i] == id){
                result = i;
                break;
            }
        }
        return result;
    }
	
    function onDayStart(){
		// First, we work with the Island Bloom tower
        group g = CreateGroup();
		GroupEnumUnitsInRect(g, GetWorldBounds(), bloomFilter);
		ForGroup(g, function(){
			unit u = GetEnumUnit();
			UnitRemoveAbility(u, DISABLE_ATTACK);
			setUnitRegenDay(u);
			u = null;
		});
        DestroyGroup(g);
		g = null;
		
		// Next, Feral Towers
		g = CreateGroup();
        GroupEnumUnitsInRect(g, GetWorldBounds(), feralFilter);
		ForGroup(g, function() {
			unit u = GetEnumUnit();
			integer id = GetUnitCurrentOrder(u);
			string order = OrderId2String(id);
			setUnitRegenDay(u);
			if (GetUnitState(u, UNIT_STATE_MANA) == GetUnitState(u, UNIT_STATE_MAX_MANA)) {
				// It's daytime and the tower is doing nothing... upgrade!
				// 852531 = avengerform, because apparently sphinxform = avengerform...
				IssueImmediateOrderById(u, 852531);
			}
			u = null;
		});
        DestroyGroup(g);
        g = null;
    }
	
    function onNightStart(){
        group g = CreateGroup();
		GroupEnumUnitsInRect(g, GetWorldBounds(), bloomFilter);
		ForGroup(g, function(){
			unit u = GetEnumUnit();
			UnitAddAbility(u, DISABLE_ATTACK);
			setUnitRegenNight(u);
			u = null;
		});
        DestroyGroup(g);
		g = null;
		// Next, Feral Towers
		g = CreateGroup();
        GroupEnumUnitsInRect(g, GetWorldBounds(), feralFilter);
		ForGroup(g, function() {
			setUnitRegenNight(GetEnumUnit());
            if (GetUnitState(GetEnumUnit(), UNIT_STATE_MANA) == GetUnitState(GetEnumUnit(), UNIT_STATE_MAX_MANA)) {
				// It's daytime and the tower is doing nothing... upgrade!
				// 852531 = avengerform, because apparently sphinxform = avengerform...
				IssueImmediateOrderById(GetEnumUnit(), 852531);
			}
		});
        DestroyGroup(g);
        g = null;
    }
	
	function onTimeChange(unit u) {
		integer id = GetUnitTypeId(u);
		real timeOfDay = GetFloatGameState(GAME_STATE_TIME_OF_DAY);
        if (getFeralTowerLevel(u) != -1 ||  id == ISLAND_BLOOM_ID) {
			if (timeOfDay >= 6. && timeOfDay < 18.) {
				setUnitRegenDay(u);
			}
			else {
				setUnitRegenNight(u);
				if (id == ISLAND_BLOOM_ID) {
					UnitAddAbility(u, DISABLE_ATTACK);
				}
			}
			SetUnitState(u, UNIT_STATE_MANA, 0);
		}
	}
	
    function onCast(){
        unit u = GetTriggerUnit();
        integer id = GetSpellAbilityId();
        TempUnit v = 0;
		real x = GetUnitX(u);
		real y = GetUnitY(u);
        
        if (id == 'ADT0' ||
            id == 'A0NV' || /* ADT1 crashes the game for some reason? */
            id == 'ADT2' ||
            id == 'ADT3' ||
            id == 'ADT4' ||
            id == 'ADT5' ||
            id == 'ADT6' ||
            id == 'ADT7' ||
            id == 'ADT8'){
			
			DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", x, y));
            
            v = TempUnit.create(u);
            GameTimer.new(function(GameTimer t){
                real timeOfDay = GetFloatGameState(GAME_STATE_TIME_OF_DAY);
                TempUnit v = t.data();
                unit u = v.u;
                SetUnitAnimation(u, "stand");
                QueueUnitAnimation(u, "stand");
                
                if (timeOfDay >= 6. && timeOfDay < 18.) {
                    setUnitRegenDay(u);
                }
                else {
                    setUnitRegenNight(u);
                }
                
                v.destroy();
                u = null;
            }).start(0.01).setData(v);
            
        }
        u = null;
    }
    
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 6.);
        TriggerAddAction(t, function onDayStart);
        t = CreateTrigger();
        TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 18.);
        TriggerAddAction(t, function onNightStart);
		
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
			onTimeChange(GetConstructedStructure());
			return false;
		}));
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
			onTimeChange(GetTriggerUnit());
			return false;
		}));
		
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_ENDCAST);
        TriggerAddAction(t, function onCast);
        t = null;
		
		bloomFilter = Filter(function() -> boolean {
			return GetUnitTypeId(GetFilterUnit()) == ISLAND_BLOOM_ID;
		});
		
        initTowerIds();
		feralFilter = Filter(function() -> boolean {
			integer id = GetUnitTypeId(GetFilterUnit());
			integer i = 0;
			for (0 <= i < TOWER_IDS.size) {
				if (id == TOWER_IDS[i]) {
					return true;
				}
			}
			return false;
		});
        
    }
}
//! endzinc