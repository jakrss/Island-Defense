//! zinc
library FlintknockPistol requires BUM, MathLibs, TerrainPathability {
    private hashtable flintTable = InitHashtable();
    private constant integer ABILITY_ID = 'A0MZ'; //Ability ID for this
    private constant string HIT_EFFECT = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"; //Effect played on (hit? need to update)
    private constant string KNOCK_EFFECT = "Abilities\\Spells\\Human\\AerialShackles\\AerialShacklesTarget.mdl";
    private constant string LAND_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl";
    private constant real KNOCKBACK = 750; //How far does Pirate go when he uses this?
    private constant real MAX_HEIGHT = 500; //Goes this many units up and back down so it looks like he booms
    private constant integer CROW_FORM_ID = 'Amrf';
    private constant real DAMAGE = 300; //Does 300 at the closest point to Pirate or closer (defined below)
    private constant real AOE_FULL = 250; // Area for full damage (distance)
    private constant real ANGLE = 10; //Angle from the Pirate outward for potential damage / stun on Titan
    private constant real RANGE = 1500; //How far away it'll hit things
    private constant real TIMER_SPEED = .015625; //Timer speed to move pirate
    private constant real DURATION = .8; //How long does it take to knockback etc.
    
    private constant attacktype ATTACKTYPE = ATTACK_TYPE_CHAOS;
    private constant damagetype DAMAGETYPE = DAMAGE_TYPE_UNIVERSAL;
    private constant weapontype WEAPONTYPE = WEAPON_TYPE_WHOKNOWS;
    
    //destroys groups and stuff
    function cleanup(integer th) {
	group unitsHit = LoadGroupHandle(flintTable, 4, th);
	effect e = LoadEffectHandle(flintTable, 5, th);
	
	if(e != null) DestroyEffect(e);
	
	DestroyGroup(unitsHit);
	
	e = null;
	unitsHit = null;
	FlushChildHashtable(flintTable, th);
    }
    
    
    function knockDamageEtc() {
	timer t = GetExpiredTimer();
	integer th = GetHandleId(t);
	unit caster = LoadUnitHandle(flintTable, 0, th);
	real startX = LoadReal(flintTable, 1, th);
	real startY = LoadReal(flintTable, 2, th);
	real angle = LoadReal(flintTable, 3, th);
	group unitsHit = LoadGroupHandle(flintTable, 4, th);
	integer timerLoops = LoadInteger(flintTable, 10, th);
	real finalX = LoadReal(flintTable, 11, th);
	real finalY = LoadReal(flintTable, 12, th);
	real maxLoops = DURATION/TIMER_SPEED;
	//Some math
	real knock = KNOCKBACK / maxLoops; //Knockback to do
	real damDist = timerLoops * (RANGE / maxLoops); //Damage distance (increases with every loop)
	real damMult = ((-1 * AOE_FULL) + damDist) / (RANGE - AOE_FULL); //Negative means do full damage and stun
	//Finally done loading shit
	real cX = GetUnitX(caster);
	real cY = GetUnitY(caster);
	real newX = offsetXTowardsAngle(cX, cY, angle - 180, knock);
	real newY = offsetYTowardsAngle(cX, cY, angle - 180, knock);
	real distFromStart = getDistance(startX, startY, cX, cY);
	real distTotal = getDistance(startX, startY, finalX, finalY);
	real curHeight = LoadReal(flintTable, 8, th);//BlzGetUnitZ(caster);
	real height = GetParabolaZ(distFromStart, distTotal, curHeight);
	//These might be confusing. Basically I am offsetting the starting point by ANGLE degrees in each direction to create a cone
	real validEnemyXLow = offsetXTowardsAngle(startX, startY, angle - ANGLE, damDist); //Low end X coord for valid enemy
	real validEnemyYLow = offsetYTowardsAngle(startX, startY, angle - ANGLE, damDist); //Low end Y coord for valid enemy
	real validEnemyXHigh = offsetXTowardsAngle(startX, startY, angle + ANGLE, damDist); //High end X coord for valid enemy
	real validEnemyYHigh = offsetYTowardsAngle(startX, startY, angle + ANGLE, damDist); //High end Y coord for valid enemy
	real angleOfEnemy;
	real distanceOfEnemy;
	unit tempUnit;
	//Finally done, vars needed
	group g = CreateGroup();
	unit u;
	filterfunc f = Filter(function() -> boolean {
            return GetWidgetLife(GetFilterUnit()) > .405 && !IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE);
        });
	
	//Height calculations
	UnitAddAbility(caster, CROW_FORM_ID);
	UnitRemoveAbility(caster, CROW_FORM_ID);
	SetUnitFlyHeight(caster, height, 1);
	
	//Effect multiplier stuff
	if(damMult < 0) {
	    damMult = 1;
	} else {
	    damMult = 1 - damMult;
	}
	
	GroupEnumUnitsInRange(g, startX, startY, damDist, f);
	u = FirstOfGroup(g);
	
	while(u != null) {
	    angleOfEnemy = getAngle(startX, startY, GetUnitX(u), GetUnitY(u));
	    distanceOfEnemy = getDistance(startX, startY, GetUnitX(u), GetUnitY(u));
	    if(distanceOfEnemy <= damDist && (angleOfEnemy >= angle - 10 || angleOfEnemy <= angle + 10)
		&& IsUnitEnemy(u, GetOwningPlayer(caster)) && !IsUnitInGroup(u, unitsHit)) {
		UnitDamageTarget(caster, u, DAMAGE * damMult, false, false, ATTACKTYPE, DAMAGETYPE, WEAPONTYPE);
		DestroyEffect(AddSpecialEffectTarget(HIT_EFFECT, u, "origin"));
		GroupAddUnit(unitsHit, u);
	    }
	    GroupRemoveUnit(g, u);
	    u = null;
	    u = FirstOfGroup(g);
	}
	
	//Do the knockback on Pirate
	SetUnitX(caster, newX);
	SetUnitY(caster, newY);
	SetUnitFacing(caster, angle);
	//if(timerLoops == 1 || timerLoops / maxLoops == .25 || timerLoops / maxLoops == .5 || timerLoops / maxLoops == .75) {
	//    DestroyEffect(AddSpecialEffectTarget(KNOCK_EFFECT, caster, "origin"));
	//}
	
	//if(modulus(timerLoops, maxLoops/10) || timerLoops == 1) {
	//    for(0 <= i <= 2) {
	//       tempUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u00H', xList[i], yList[i], bj_UNIT_FACING);
	//        UnitAddAbility(tempUnit, 'Aloc');
	//        UnitApplyTimedLife(tempUnit, 'BTLF', DURATION);
	//    }
	//}
	
	timerLoops = timerLoops + 1;
	
	if(timerLoops > (DURATION / TIMER_SPEED)) {
	    PauseTimer(t);
	    cleanup(th);
	    DestroyTimer(t);
	    if(IsTerrainWalkable(newX, newY)) {
	        finalX = newX;
	        finalY = newY;
	    } else {
		finalX = TerrainPathability_X;
		finalY = TerrainPathability_Y;
	    }
	    SetUnitX(caster, finalX);
	    SetUnitY(caster, finalY);
	    DestroyEffect(AddSpecialEffect(LAND_EFFECT, finalX, finalY));
	}
	
	//Save stuff!
	SaveGroupHandle(flintTable, 4, th, unitsHit);
	SaveReal(flintTable, 8, th, 0);
	SaveInteger(flintTable, 10, th, timerLoops);
	
	u = null;
	unitsHit = null;
	t = null;
	caster = null;
	DestroyGroup(g);
	DestroyFilter(f);
    }
    
    function flintknockStart(unit caster) {
	timer t = CreateTimer();
	integer th = GetHandleId(t);
	real startX = GetUnitX(caster);
	real startY = GetUnitY(caster);
	real angle = GetUnitFacing(caster);
	real finalX = offsetXTowardsAngle(startX, startY, angle - 180, KNOCKBACK);
	real finalY = offsetYTowardsAngle(startX, startY, angle - 180, KNOCKBACK);
	effect e = AddSpecialEffectTarget(KNOCK_EFFECT, caster, "feet");
	group unitsHit = CreateGroup();
	SaveUnitHandle(flintTable, 0, th, caster);
	SaveReal(flintTable, 1, th, startX);
	SaveReal(flintTable, 2, th, startY);
	SaveReal(flintTable, 3, th, angle);
	SaveGroupHandle(flintTable, 4, th, unitsHit);
	SaveEffectHandle(flintTable, 5, th, e);
	SaveReal(flintTable, 11, th, finalX);
	SaveReal(flintTable, 12, th, finalY);
	SaveInteger(flintTable, 10, th, 1);
	PlaySoundBJ(gg_snd_Flintknock_Pistol);
	TimerStart(t, TIMER_SPEED, true, function knockDamageEtc);
	unitsHit = null;
	caster = null;
	e = null;
	t = null;
    }
    
    function onInit() {
	trigger t = CreateTrigger();
	TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
	TriggerAddCondition(t, Condition(function() -> boolean {
	    unit caster = GetTriggerUnit();
	    if(GetSpellAbilityId() == ABILITY_ID) {
		flintknockStart(caster);
	    }
	    return false;
	}));
	t = null;
    }
}
//! endzinc