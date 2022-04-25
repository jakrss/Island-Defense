//! zinc
library Skystrike requires BUM, xemissile, xefx, xebasic, MathLibs {
    //Ability ID
    private constant integer ABILITY_ID = 'A0JG';
    //Arcane Missile effect
    private constant string MISSILE_MODEL = "AirStrikeMissile.mdx";
    //Effect for hitting a unit
    private constant string EFFECT = "Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdl";
    //Damage per missile (base)
    private real DMG = 125;
    //Max num of missiles (base)
    private integer MAX_MISSILES = 8;
    //AOE of ability
    private constant real AOE = 200;
    //Missiles per second
    private constant integer MPS = 4;
    //AOE of impact of missile
    private constant real IMPACT_AOE = 135;
    //ARC of the missile
    private constant real ARC = .35;
    //Missile speed
    private constant real SPEED = 1300;
    //Attack type, damage type, weapon type
    private constant attacktype AT = ATTACK_TYPE_NORMAL;
    private constant damagetype DT = DAMAGE_TYPE_MAGIC;
    private constant weapontype WT = WEAPON_TYPE_WHOKNOWS;
    //Timer speed for creating missiles
    private constant real TIMER_SPEED = 1.0 / I2R(MPS);
    //Hashtable to store the bullshat
    private hashtable skyTable = InitHashtable();
    
    struct arcaneMissile extends xemissilewithvision {
        unit caster;
        real damage = DMG;
        real impact_aoe = IMPACT_AOE;
        
        method onHit() {
            group g = CreateGroup();
            unit u;
            
            GroupEnumUnitsInRange(g, this.x, this.y, IMPACT_AOE, null);
            
            u = FirstOfGroup(g);
            while(u != null) {
                if(!IsUnitAlly(u, GetOwningPlayer(this.caster)) && getDistance(this.x, this.y, GetUnitX(u), GetUnitY(u)) <= IMPACT_AOE) {
			if(GetUnitAbilityLevel(u, 'WARD') > 0) {
				UnitDamageTarget(this.caster, u, (this.damage * 0.5), false, false, AT, DT, WT);
			} else {
				UnitDamageTarget(this.caster, u, this.damage, false, false, AT, DT, WT);
			}
                    
                }
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
            u = null;
            DestroyEffect(AddSpecialEffect(EFFECT, this.x, this.y));
        }
    }
    
    function createMissile() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(skyTable, 0, th);
        
        arcaneMissile a;
        
        real sX = LoadReal(skyTable, 1, th);
        real sY = LoadReal(skyTable, 2, th);
        real tX = LoadReal(skyTable, 3, th);
        real tY = LoadReal(skyTable, 4, th);
        real tZ = 0;
        real sZ = 0;
        integer numMissiles = LoadInteger(skyTable, 5, th);
        integer maxMissiles = LoadInteger(skyTable, 6, th);
        
        if(numMissiles >= maxMissiles) {
            PauseTimer(t);
            DestroyTimer(t);
            FlushChildHashtable(skyTable, th);
        } else {
        
            tX = offsetXTowardsAngle(tX, tY, GetRandomReal(0, 360), GetRandomReal(0, AOE));
            tY = offsetYTowardsAngle(tX, tY, GetRandomReal(0, 360), GetRandomReal(0, AOE));
            sX = offsetXTowardsAngle(sX, sY, GetRandomReal(0, 360), GetRandomReal(0, AOE));
            sY = offsetYTowardsAngle(sX, sY, GetRandomReal(0, 360), GetRandomReal(0, AOE));
            sZ = 0;
            tZ = 0;
            
            a = arcaneMissile.create(sX, sY, sZ, tX, tY, tZ);
            a.caster = u;
            a.owner = GetOwningPlayer(u);
            a.fxpath = MISSILE_MODEL;
            if(GetUnitAbilityLevel(u, ABILITY_ID) > 2) {
                a.damage = 250;
            }
            a.launch(SPEED, ARC);
            
            numMissiles = numMissiles + 1;
            SaveInteger(skyTable, 5, th, numMissiles);
        }
        t = null;
        u = null;
    }
    
    function onCast() {
        unit u = GetTriggerUnit();
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        
        real sX = GetUnitX(u);
        real sY = GetUnitY(u);
        real tX = GetSpellTargetX();
        real tY = GetSpellTargetY();
        
        SaveUnitHandle(skyTable, 0, th, u);
        SaveReal(skyTable, 1, th, sX);
        SaveReal(skyTable, 2, th, sY);
        SaveReal(skyTable, 3, th, tX);
        SaveReal(skyTable, 4, th, tY);
        //Num missiles created
        SaveInteger(skyTable, 5, th, 0);
        //Max missiles
        if(GetUnitAbilityLevel(u, ABILITY_ID) > 1) {
            SaveInteger(skyTable, 6, th, 14);
        } else {
            SaveInteger(skyTable, 6, th, 8);
        }
        
        TimerStart(t, TIMER_SPEED, true, function createMissile);
        
        t = null;
        u = null;
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
        t = null;
    }
}

//! endzinc