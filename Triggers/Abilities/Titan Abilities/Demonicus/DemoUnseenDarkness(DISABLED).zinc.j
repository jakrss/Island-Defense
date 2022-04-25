//! zinc
library UnseenDarkness requires Players, BUM, SpawnofDarkness {
    //Ability ID
    private constant integer ABILITY_ID = 'TDAR';
    //Spawn ID
    private constant integer UNIT_ID = 'n00I';
    //Time to get to max bonus movespeed / ready to spawn next attack
    private constant real TIME_TO_MAX = 10;
    //Time subtracted per level above one
    private constant real TIME_TO_MAX_REDUCE = 2.5;
    //Movement speed bonus max (less than 1 is a percentage bonus)
    private constant real MAX_MS_BONUS = 60;
    //Movement speed bonus max added per level
    private constant real MAX_MS_ADD = 60;
    //Movement speed increase per second
    //Timer Speed to check
    private constant real TIMER_SPEED = 2;
    //Effect for the bonus movespeed
    private constant string MS_EFFECT = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl";
    //Effect for ready to summon demon thing
    private constant string SPAWN_EFFECT = "Abilities\\Spells\\Items\\VampiricPotion\\VampPotionCaster.mdl";
    //Hashtable
    private hashtable udTable = InitHashtable();
    
    function loopPlayers(unit u) -> boolean {
        boolean isVisible = false;
        player tempPlayer;
        integer i = 0;
        PlayerDataArray list = 0;
        list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
        //BJDebugMsg("Num Players: " + I2S(list.size()));
        for(0 <= i <= list.size()) {
            tempPlayer = list.at(i).player();
            isVisible = checkUnitVisibility(u, tempPlayer);
            tempPlayer = null;
            if(isVisible) return true;
        }
        //if(isVisible) BJDebugMsg("Demonicus Visible");
        //else BJDebugMsg("Demonicus Invisible");
        return isVisible;
    }
    
    function spawnThingy() {
        unit u = GetEventDamageSource();
        integer uh = GetHandleId(u);
        effect spawnEffect = LoadEffectHandle(udTable, 5, uh);
        unit attacked = GetTriggerUnit();
        real tx = GetUnitX(attacked);
        real ty = GetUnitY(attacked);
        //Create a spawn
        createSpawnOfDarkness(u, tx, ty);
        //Destroy the spawn effect and remove the saved handle
        DestroyEffect(spawnEffect);
        RemoveSavedHandle(udTable, 5, uh);
        //Save the boolean so we don't create more
        SaveBoolean(udTable, 1, uh, false);
    }
    
    function updateMovespeed() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(udTable, 0, th);
        integer uh = GetHandleId(u);
        real curBonus = LoadReal(udTable, 1, th);
        real timeUnseen = LoadReal(udTable, 2, th);
        effect spawnEffect = LoadEffectHandle(udTable, 5, uh);
        real curMovespeed = GetUnitMoveSpeed(u) - curBonus;
        real timeToMax = TIME_TO_MAX - ((GetUnitAbilityLevel(u, ABILITY_ID) - 1) * TIME_TO_MAX_REDUCE);
        real maxMovespeed = MAX_MS_BONUS + ((GetUnitAbilityLevel(u, ABILITY_ID) - 1) * MAX_MS_ADD);
        real msInc = (maxMovespeed / timeToMax) * TIMER_SPEED;
        
        boolean isVisible = loopPlayers(u);
        
        if(GetUnitAbilityLevel(u, ABILITY_ID) == 0) {
            FlushChildHashtable(udTable, th);
            FlushChildHashtable(udTable, uh);
            PauseTimer(t);
            DestroyTimer(t);
            u = null;
            t = null;
            return;
        }
        
        if(!isVisible && curBonus < maxMovespeed) {
            //Update the current movespeed bonus and time unseen
            curBonus = curBonus + msInc;
            timeUnseen = timeUnseen + TIMER_SPEED;
            
            //Add bonus movespeed
            SetUnitMoveSpeed(u, curMovespeed + curBonus);
            
            //Play an effect when MS is increased
            DestroyEffect(AddSpecialEffectTarget(MS_EFFECT, u, "origin"));
            
            if(timeUnseen >= timeToMax && spawnEffect == null) {
                //Time to spawn some monster on next attack
                spawnEffect = AddSpecialEffectTarget(SPAWN_EFFECT, u, "origin");
                //Save a boolean to the 1st of the unit handle so we know to make a spawn
                SaveBoolean(udTable, 1, uh, true);
                SaveEffectHandle(udTable, 5, uh, spawnEffect);
            }
            SaveReal(udTable, 1, th, curBonus);
            SaveReal(udTable, 2, th, timeUnseen);
        } else if(isVisible && curBonus > 0) {
            //Remove the bonus movespeed
            SetUnitMoveSpeed(u, curMovespeed);
            
            curBonus = 0;
            timeUnseen = 0;
            
            SaveReal(udTable, 1, th, curBonus);
            SaveReal(udTable, 2, th, timeUnseen);
        }
        u = null;
        t = null;
    }
    
    function unitLearnedDarkness() {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        unit u = GetTriggerUnit();
        integer uh = GetHandleId(u);
        player tempUnit;
        real curBonus = 0; // Current bonus MS
        real timeUnseen = 0; //Time remained unseen
        
        SaveTimerHandle(udTable, 0, uh, t);
        
        SaveUnitHandle(udTable, 0, th, u);
        SaveReal(udTable, 1, th, curBonus);
        SaveReal(udTable, 2, th, timeUnseen);
        TimerStart(t, TIMER_SPEED, true, function updateMovespeed);
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_SKILL);
        TriggerAddCondition(t, Condition(function() -> boolean {
            if(GetLearnedSkill() == ABILITY_ID && GetLearnedSkillLevel() == 1) {
                unitLearnedDarkness();
            }
            return false;
        }));
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetEventDamageSource();
            if(LoadBoolean(udTable, 1, GetHandleId(u)) && BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {
                spawnThingy();
            }
            return false;
        }));
        t = null;
    }
}
//! endzinc