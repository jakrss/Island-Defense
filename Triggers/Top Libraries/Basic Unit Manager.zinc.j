//! zinc
//lol
library BUM {
    //Gold mine ID
    private constant integer GOLD_MINE = 'h001';
    private unit goldMine;
    
    public function getGoldMine() -> unit {
        return goldMine;
    }
    
    public function getHealth(unit u) -> real {
        return GetUnitState(u, UNIT_STATE_LIFE);
    }
    
    public function getMaxHealth(unit u) -> real {
        return I2R(BlzGetUnitMaxHP(u));
    }
    
    public function getMana(unit u) -> real {
        return GetUnitState(u, UNIT_STATE_MANA);
    }
    
    public function getMaxMana(unit u) -> real {
        return I2R(BlzGetUnitMaxMana(u));
    }
    
    public function getRatioHealth(unit u) -> real {
        return getHealth(u) / getMaxHealth(u);
    }
    
    public function getRatioMana(unit u) -> real {
        return getMana(u) / getMaxMana(u);
    }
    
    public function setHealth(unit u, real hp) {
        SetUnitState(u, UNIT_STATE_LIFE, hp);
    }
    
    public function setMana(unit u, real mp) {
        SetUnitState(u, UNIT_STATE_MANA, mp);
    }
    
    public function setMaxHealth(unit u, real hp) {
        BlzSetUnitMaxHP(u, R2I(hp));
    }
    
    public function setMaxMana(unit u, real mp) {
        BlzSetUnitMaxMana(u, R2I(mp));
    }
    
    public function addHealth(unit u, real hp) {
        setHealth(u, getHealth(u) + hp);
    }
    
    public function addMana(unit u, real mp) {
        setMana(u, getMana(u) + mp);
    }
    
    public function addMaxHealth(unit u, real hp) {
        setMaxHealth(u, getMaxHealth(u) + hp);
    }
    
    public function addMaxMana(unit u, real mp) {
        setMaxMana(u, getMaxMana(u) + mp);
    }
    
    public function disAbility(unit u, integer abil) {
        BlzUnitDisableAbility(u, abil, true, true);
    }
    
    public function enAbility(unit u, integer abil) {
        BlzUnitDisableAbility(u, abil, false, false);
    }
    
    public function checkUnitVisibility(unit u, player p) -> boolean {
        return IsUnitVisible(u, p);
    }
	
	public function healUnit(unit u, real hp) {
		real curHP = GetUnitState(u, UNIT_STATE_LIFE);
		UnitDamageTarget(u, u, -hp, false, false, null, null, null);
		//We also want to heal invulnerable units:
		if(GetUnitState(u, UNIT_STATE_LIFE) < curHP + hp) {
			addHealth(u, hp);	//But sadly this won't be increased by heal modifiers.
		}
		u = null;
	}
    
    function handleSetup() {
        unit pickedUnit = GetEnumUnit();
        if(GetUnitTypeId(pickedUnit) == GOLD_MINE) {
            //Only ever one gold mine right?
            goldMine = pickedUnit;
        }
    }
    
    function setupVars() {
        group g = CreateGroup();
        timer t = GetExpiredTimer();
        GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
        ForGroup(g, function handleSetup);

        DestroyGroup(g);
        DestroyTimer(t);
    }
    
    private function onInit() {
        timer t = CreateTimer();
        TimerStart(t, 20, false, function setupVars);
    }
}
//! endzinc