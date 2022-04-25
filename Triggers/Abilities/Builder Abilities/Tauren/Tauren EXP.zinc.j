//! zinc

library TaurenEXP requires Damage, GameTimer {
    private constant real AOE = 1000;
    //Ashen Earth ability ID
    private constant integer ABILITY_ID = 'A00E';
    //restoreEffect - the effect played on the Totem towers when the Tauren hits the titan or mini and heals em
    private constant string restoreEffect = "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl";
    //Percentage life restored
    private constant integer pLifeRestored = 5;

    struct TaurenTotemsDamage {
	//How long does the bonus damage last (each stack is independent)?
	private static constant real duration = 10;
	//Ability ID of the damage ability for the towers
	private static constant integer abilityId = 'A00R';
	private integer abilityLevel;
	private unit tower;
	private GameTimer t;
	
	public static method create(unit tower) -> thistype {
	    thistype this = thistype.allocate();
	    this.tower = tower;
	    this.abilityLevel = GetUnitAbilityLevel(this.tower, this.abilityId);
	    if(this.abilityLevel < 100) { 
		IncUnitAbilityLevel(this.tower, this.abilityId);
	    }
	    this.t = GameTimer.new(function (GameTimer t) {
                thistype this = t.data();
                if(abilityLevel >= 1) {
		    DecUnitAbilityLevel(this.tower, this.abilityId);
		}
		this.destroy();
            }).start(this.duration);
	    t.setData(this);
	    return this;
	}
    }

    private function empowerTowers(unit tauren) {
	group g = CreateGroup();
	integer t1, t2, t3, t4;
	TaurenTotemsDamage damageInstance;
	unit u=null;
	filterfunc f;
	t1='e00Q';
	t2='e00S';
	t3='e00T';
	t4='e00U';
	f = Filter(function() -> boolean {
            integer mUnitId = GetUnitTypeId(GetFilterUnit());
	    //Returns true if it's a totem tower
	    return mUnitId == 'e00Q' || mUnitId == 'e00S' || 
	    	   mUnitId == 'e00T' || mUnitId == 'e00U';
        });
	//Get all Totem Towers within range
	GroupEnumUnitsInRange(g, GetUnitX(tauren), GetUnitY(tauren), AOE, f);
	//Loop through and restore mana/HP to towers
	u=FirstOfGroup(g);
	while(u!=null) {
	    SetUnitState(u, UNIT_STATE_MANA, BlzGetUnitMaxMana(u));
	    SetUnitLifePercentBJ(u, GetUnitLifePercent(u) + pLifeRestored);
	    DestroyEffect(AddSpecialEffectTarget(restoreEffect, u, "origin"));
	    damageInstance = TaurenTotemsDamage.create(u);
	    GroupRemoveUnit(g, u);
	    u=null;
	    u=FirstOfGroup(g);
	}
	DestroyGroup(g);
	u=null;
    }

    private function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, Condition(function() -> boolean {
            return BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL &&
               (GetUnitTypeId(GetEventDamageSource()) == 'O01Q' ||
                GetUnitTypeId(GetEventDamageSource()) == 'O01R') &&
               (UnitManager.isTitan(GetTriggerUnit()) ||
                UnitManager.isMinion(GetTriggerUnit()));
        }));
        TriggerAddAction(t, function(){
            unit u = GetEventDamageSource();
	    unit attacker = GetTriggerUnit();
            real damage = GetEventDamage();
	    integer level = GetHeroLevel(attacker);
	    integer exp = 2;
	    
	    if (level < 6) exp = 3;
		else if (level <= 11) exp = 4;
		else exp = 5;
			
            // Threshold of 45 so whirlpool, bombard, etc don't damage
            if (damage > 45.0) {
                ExperienceSystem.giveExperience(u, exp);
		empowerTowers(u);
            }
	    attacker = null;
            u = null;
        });
        t = null;
    }
}

//! endzinc