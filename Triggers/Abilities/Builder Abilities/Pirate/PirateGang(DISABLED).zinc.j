//! zinc
library PirateGang requires BUM, MathLibs {
    //Globals
    private hashtable pgTable = InitHashtable();
    private constant integer ABILITY_ID = 'A0N0';
    private constant integer REVEAL_ID = 'PIID'; //Ability dummy pirates will be given to reveal for 5 seconds
    private constant real AREA = 350; //Area effected, pirates will be around the outer edge
    private constant real DMG = 50; //Damage per swing per pirate, will be divided by ATK_CD to get DPS
    private constant integer NUM_PIRATES = 3; //Number of pirates, effects damage overall (DMG / NUM_ENEMIES) * ATK_CD)
    private constant real PIRATE_SCALE = 1.25; //Scale of the units
    private constant string ATK_ANIM_NAME = "attack"; //Attack animation of unit meant to be doin the swinging
    private constant string UNIT_HIT_EFFECT = "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl"; //Effect played when enemy unit gets hit
    private constant string ON_CAST_EFFECT = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"; //Played on cast, but colored
    private constant string PIRATE_DIE_EFFECT = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"; //Added because RemoveUnit is so sudden
    private constant integer UNIT_SPAWN = 'h044'; //Pirate's harvester to spawn, will be given locust ability
    private constant damagetype DMG_TYPE = DAMAGE_TYPE_UNIVERSAL;
    private constant attacktype ATK_TYPE = ATTACK_TYPE_CHAOS;
    private constant weapontype WPN_TYPE = WEAPON_TYPE_WHOKNOWS;
    private constant real TIMER_SPEED = .25; //How fast it ticks
    private constant real DURATION = 5.0; //Duration of ability
    private constant real ATK_CD = 1.0; //CD of each pirates attack (individually handled) - Make sure this is a multiple of TIMER_SPEED
    
    function pgCheckDmgArea(unit pirate) -> boolean {
        integer ph = GetHandleId(pirate);
        real atkCd = LoadReal(pgTable, 0, ph);
        real tX = LoadReal(pgTable, 1, ph);
        real tY = LoadReal(pgTable, 2, ph);
        unit u;
        group g;
        integer numUnits = 0;
        filterfunc f = Filter(function() -> boolean {
            return IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false && UnitAlive(GetFilterUnit());
        });
        
        if(!UnitAlive(pirate)) {
            DestroyFilter(f);
            FlushChildHashtable(pgTable, ph);
            DestroyEffect(AddSpecialEffect(PIRATE_DIE_EFFECT, GetUnitX(pirate), GetUnitY(pirate)));
            RemoveUnit(pirate);
            return true;
        }
        
        if(atkCd <= 0) {
            g = CreateGroup();
            GroupEnumUnitsInRange(g, tX, tY, AREA, f);
            numUnits = CountUnitsInGroup(g);
            u = FirstOfGroup(g);
            while(u != null) {
                if(IsUnitEnemy(u, GetOwningPlayer(pirate))) {
                    IssueTargetOrderById(pirate, 852570, u);
                    UnitDamageTarget(pirate, u, (DMG / numUnits) * ATK_CD, true, false, ATK_TYPE, DMG_TYPE, WPN_TYPE);
                    SetUnitAnimation(pirate, ATK_ANIM_NAME);
                    DestroyEffect(AddSpecialEffectTarget(UNIT_HIT_EFFECT, u, "origin"));
                    atkCd = ATK_CD;
                }
                GroupRemoveUnit(g, u);
                u = null;
                u = FirstOfGroup(g);
            }
            DestroyGroup(g);
        } else {
            atkCd = atkCd - TIMER_SPEED;
        }
        SaveReal(pgTable, 0, ph, atkCd);
        DestroyFilter(f);
        u = null;
        pirate = null;
        return false;
    }
    
    function pgTimer() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit caster = LoadUnitHandle(pgTable, 0, th);
        real tX = LoadReal(pgTable, 1, th);
        real tY = LoadReal(pgTable, 2, th);
        unit tempUnit = null; //Load the first pirate to check if still alive
        boolean cleanup = false; //True to cleanup shit
        integer numUnits = 0;
        
        while(numUnits < NUM_PIRATES) {
            tempUnit = LoadUnitHandle(pgTable, 11 + numUnits, th);
            //If tempBool (cleanup) we have to make sure we keep it that way
            if(!cleanup) {
                cleanup = pgCheckDmgArea(tempUnit);
            } else if(tempUnit != null) {
                pgCheckDmgArea(tempUnit);
            }
            
            numUnits = numUnits + 1;
            tempUnit = null;
        }
        
        if(cleanup) {
            DestroyTimer(t);
            FlushChildHashtable(pgTable, th);
        }
        t = null;
        caster = null;
    }
    
    function onCast() {
        unit caster = GetTriggerUnit(); //Stored as 0 of Timer Handle
        real cX = GetUnitX(caster);
        real cY = GetUnitY(caster);
        timer t = CreateTimer(); //Yup
        integer th = GetHandleId(t); //Store everything here brah
        real tX = GetSpellTargetX(); //1 of TH
        real tY = GetSpellTargetY(); //2 of TH
        unit u = null;
        integer numUnits = 0;
        real angle = getAngle(cX, cY, tX, tY);
        real angleToAdd = 360 / NUM_PIRATES;
        real spawnX, spawnY;
        effect e = AddSpecialEffect(ON_CAST_EFFECT, tX, tY);
        BlzSetSpecialEffectScale(e, 5);
        DestroyEffect(e);
        SaveUnitHandle(pgTable, 0, th, caster);
        SaveReal(pgTable, 1, th, tX);
        SaveReal(pgTable, 2, th, tY);
        //Pirates are stored as 11 of Timer Handle to however many there are.
        while(numUnits < NUM_PIRATES) {
            spawnX = offsetXTowardsAngle(tX, tY, angle + (angleToAdd * numUnits), AREA);
            spawnY = offsetYTowardsAngle(tX, tY, angle + (angleToAdd * numUnits), AREA);
            u = CreateUnit(GetOwningPlayer(caster), UNIT_SPAWN, spawnX, spawnY, getAngle(spawnX, spawnY, tX, tY));
            SetUnitScale(u, PIRATE_SCALE, PIRATE_SCALE, PIRATE_SCALE);
            SaveReal(pgTable, 0, GetHandleId(u), GetRandomReal(ATK_CD - .75, ATK_CD + .75));
            SaveReal(pgTable, 1, GetHandleId(u), tX);
            SaveReal(pgTable, 2, GetHandleId(u), tY);
            UnitApplyTimedLife(u, 'BTLF', DURATION);
            UnitAddAbility(u, REVEAL_ID);
            UnitAddAbility(u, 'Aloc');
            SaveUnitHandle(pgTable, 11 + numUnits, th, u);
            u = null;
            numUnits = numUnits + 1;
        }
        TimerStart(t, TIMER_SPEED, true, function pgTimer);
        e = null;
        t = null;
        caster = null;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, Condition(function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            return false;
        }));
        t = null;
    }
}
//! endzinc