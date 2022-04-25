//! zinc
library SpawnofDarkness requires BUM {
    //Spawn of Darkness ID
    private constant integer UNIT_ID = 'n00I';
    //HP Degeneration rate (less than one is a percentage)
    private constant real HP_DEGEN = .05;
    //HP Regeneration rate per attack (less than one is a percentage)
    private constant real HP_REGEN = .20;
    //Effect to play on HP Regen
    private constant string REGEN_EFFECT = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl";
    //Effect to play on Spawn
    private constant string SPAWN_EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl";
    //Timer speed
    private constant real TIMER_SPEED = .25;
    //Hashtable
    private hashtable sodTable = InitHashtable();
    
    function degenSpawn() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit spawn = LoadUnitHandle(sodTable, 0, th);
        
        real health = getHealth(spawn);
        real maxHealth = getMaxHealth(spawn);
        real healthToRemove;
        
        if(HP_DEGEN < 1) {
            healthToRemove = maxHealth * HP_DEGEN * TIMER_SPEED;
            setHealth(spawn, health - healthToRemove);
        } else {
            healthToRemove = HP_DEGEN * TIMER_SPEED;
            setHealth(spawn, health - healthToRemove);
        }
        
        if(GetWidgetLife(spawn) < .405) {
            FlushChildHashtable(sodTable, th);
            PauseTimer(t);
            DestroyTimer(t);
        }
        spawn = null;
    }
    
    public function createSpawnOfDarkness(unit owner, real tx, real ty) {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        unit spawn;
        
        DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, tx, ty));
        spawn = CreateUnit(GetOwningPlayer(owner), UNIT_ID, tx, ty, GetUnitFacing(owner));
        
        SaveUnitHandle(sodTable, 0, th, spawn);
        TimerStart(t, TIMER_SPEED, true, function degenSpawn);
        
        spawn = null;
        t = null;
    }
    
    function onDamage() {
        unit spawn = GetEventDamageSource();
        real health = getHealth(spawn);
        real maxHealth = getMaxHealth(spawn);
        real healthToRegen;
        
        if(HP_REGEN < 1) {
            healthToRegen = maxHealth * HP_REGEN;
        } else {
            healthToRegen = HP_REGEN;
        }
        setHealth(spawn, health + healthToRegen);
        DestroyEffect(AddSpecialEffectTarget(REGEN_EFFECT, spawn, "origin"));
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetEventDamageSource();
            unit t = GetTriggerUnit();
            if(GetUnitTypeId(u) == UNIT_ID && IsUnitEnemy(t, GetOwningPlayer(u))) {
                onDamage();
            }
            u = null;
            t = null;
            return false;
        }));
        t = null;
    }
}
//! endzinc