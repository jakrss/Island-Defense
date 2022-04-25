//! zinc
library Missile requires MathLibs {
    //Library to create and launch missiles at points or targets
    //Gonna store a lot in this, hard to keep track so gonna add wrappers
    //X, Y, Z, targetX, targetY, targetZ, Roll, Pitch, Yaw, Alpha, Scale
    //Timer stored in parent 30
    //Caster unit (if set) is stored in parent 20
    //Target unit (if there is one) stored in parent 21
    //Effect stored in parent 0 of the timer
    
    //CONFIGURABLE VARIABLES
    //.03125 is the slowest a timer can go and the human eye won't notice
    private constant real TIMER_SPEED = 0.03125;
    //Maximum angle to be able to turn per second (not active right now)
    private constant real MAX_APS = 30;
    //END CONFIGURABLE VARAIBLES
    //Current effect for TriggerEvaluate
    private effect doME;
    private hashtable mTable = InitHashtable();
    
    //Wrappers for Blizz functions
    //Setters and getters
    public function setX(effect e, real nX) {
        BlzSetSpecialEffectX(e, nX);
        SaveReal(mTable, 1, GetHandleId(e), nX);
    }
    
    public function setY(effect e, real nY) {
        BlzSetSpecialEffectY(e, nY);
        SaveReal(mTable, 2, GetHandleId(e), nY);
    }
    
    public function setZ(effect e, real nZ) {
        setH(e, nZ);
    }
    
    public function getX(effect e) -> real {
        return LoadReal(mTable, 1, GetHandleId(e));
    }
    
    public function getY(effect e) -> real {
        return LoadReal(mTable, 2, GetHandleId(e));
    }
    
    public function getZ(effect e) -> real {
        return LoadReal(mTable, 3, GetHandleId(e));
    }
    
    public function getTargetX(effect e) -> real {
        return LoadReal(mTable, 4, GetHandleId(e));
    }
    
    public function getTargetY(effect e) -> real {
        return LoadReal(mTable, 5, GetHandleId(e));
    }
    
    public function getTargetZ(effect e) -> real {
        return LoadReal(mTable, 6, GetHandleId(e));
    }
    
    public function getStartX(effect e) -> real {
        return LoadReal(mTable, 7, GetHandleId(e));
    }
    
    public function getStartY(effect e) -> real {
        return LoadReal(mTable, 8, GetHandleId(e));
    }
    
    public function getStartZ(effect e) -> real {
        return LoadReal(mTable, 9, GetHandleId(e));
    }
    
    public function getRoll(effect e) -> real {
        return LoadReal(mTable, 10, GetHandleId(e));
    }
    
    public function getFacing(effect e) -> real {
        return LoadReal(mTable, 11, GetHandleId(e));
    }
    
    public function getVerticalFacing(effect e) -> real {
        return LoadReal(mTable, 12, GetHandleId(e));
    }
    
    public function getScale(effect e) -> real {
        return LoadReal(mTable, 15, GetHandleId(e));
    }
    
    public function getTargetScale(e) -> real {
        return LoadReal(mTable, 115, GetHandleId(e));
    }
    
    public function getScaleCPS(e) -> real {
        return LoadReal(mTable, 215, GetHandleId(e));
    }
    
    public function getCollisionSize(effect e) -> real {
        return LoadReal(mTable, 16, GetHandleId(e);
    }
    
    public function getTargetCollisionSize(e) -> real {
        return LoadReal(mTable, 116, GetHandleId(e));
    }
    
    public function getCollisionSizeCPS(e) -> real {
        return LoadReal(mTable, 216, GetHandleId(e));
    }
    
    public function getAlpha(effect e) -> real {
        return LoadReal(mTable, 17, GetHandleId(e);
    }
    
    public function getTargetAlpha(e) -> real {
        return LoadReal(mTable, 117, GetHandleId(e));
    }
    
    public function getAlphaCPS(e) -> real {
        return LoadReal(mTable, 217, GetHandleId(e));
    }
    
    public function getSpeed(effect e) -> real {
        return LoadReal(mTable, 18, GetHandleId(e));
    }
    
    public function getTargetSpeed(effect e) -> real {
        return LoadReal(mTable, 118, GetHandleId(e));
    }
    
    public function getSpeedCPS(effect e) -> real {
        return LoadReal(mTable, 218, GetHandleId(e));
    }
    
    public function getDistanceToGo(effect e) {
        return getDistance(getX(e), getY(e), getTargetX(e), getTargetY(e));
    }
    
    public function getTotalDistance(effect e) {
        return getDistance(getStartX(e), getStartY(e), getTargetX(e), getTargetY(e));
    }
    
    public function getETA(effect e) -> real {
        real distance = getDistance(getX(e), getY(e), getTargetX(e), getTargetY(e));
        real movespeed = getSpeed(e);
        return distance / movespeed;
    }
    
    public function getOwningUnit(effect e) -> unit {
        return LoadUnitHandle(mTable, 20, GetHandleId(e));
    }
    
    public function getTargetUnit(effect e) -> unit {
        return LoadUnitHandle(mTable, 21, GetHandleId(e));
    }
    
    //Set all three at once, how convenient
    public function setXYZ(effect e, real nX, real nY, real nZ) {
        setX(e, nX);
        setY(e, nY);
        setZ(e, nZ);
    }
    
    //Sets the target X / Y / Z
    //ONLY USE IF MISSILE IS NOT HOMING, OTHERWISE COULD CREATE WEIRD EFFECTS
    public function setTargetX(effect e, real nX) {
        SaveReal(mTable, 4, GetHandleId(e), nX);
    }
    public function setTargetY(effect e, real nY) {
        SaveReal(mTable, 5, GetHandleId(e), nY);
    }
    public function setTargetZ(effect e, real nZ) {
        SaveReal(mTable, 6, GetHandleId(e), nZ);
    }
    
    //Same deal sets all 3 you get it
    public function setTargetXYZ(effect e, real nX, real nY, real nZ) {
        setTargetX(e, nX);
        setTargetY(e, nY);
        setTargetZ(e, nZ);
    }
    
    //Takes terrain height into account, always use this
    public function setH(effect e, real height) {
        BlzSetSpecialEffectHeight(e, height);
        SaveReal(mTable, 3, GetHandleId(e), height);
    }
    
    public function setAlpha(effect e, integer a) {
        if(a > 100) a = 100;
        if(a < 0) a = 0;
        BlzSetSpecialEffectAlpha(e, a);
    }
    
    //Roll is like doing a barrel roll. 360 degree roll is a barrel roll.
    public function setRoll(effect e, real roll) {
        BlzSetSpecialEffectRoll(e, roll);
    }
    
    //Pitch is rotation like doing a backflip.
    //The special effects rotation on the Z axis like if it angles upwards
    public function setVerticalFacing(effect e, real pitch) {
        BlzSetSpecialEffectRoll(e, bj_DEGTORAD * pitch);
    }
    
    //Yaw is horizontal rotation
    //The special effects facing
    public function setFacing(effect e, real yaw) {
        BlzSetSpecialEffectYaw(e, yaw);
    }
    
    public function setScale(effect e, real newScale) {
        BlzSetSpecialEffectScale(e, newScale);
    }
    
    //If no owning unit we can't do damage
    public function setOwningUnit(effect e, unit caster) {
        SaveUnitHandle(mTable, 20, GetHandleId(e), caster);
    }
    
    //If no owning player we assume owning unit
    public function setOwningPlayer(effect e, player p) {
        integer mh = GetHandleId(e);
        unit caster = LoadUnitHandle(mTable, 20, mh);
        if(caster != null) {
            if(GetOwningPlayer(caster) != p) {
                SavePlayerHandle(mTable, 19, mh, p);
            }
        } else {
            SavePlayerHandle(mTable, 19, mh, p);
        }
    }
    
    //If no target is set we assume it's an ordinary missile
    public function setTarget(effect e, unit target) {
        SaveUnitHandle(mTable, 21, GetHandleId(e), target);
    }
    
    //Sets collision size, default is 50
    public function setCollisionSize(effect e, real collision) {
        SaveReal(mTable, 16, GetHandleId(e), collision);
    }
    
    //Sets the scale gradually over X seconds
    public function setScaleGradual(effect e, real newScale, real seconds) {
        real currentScale = LoadReal(mTable, 15, GetHandleId(e));
        SaveReal(mTable, 115, GetHandleId(e), newScale);
        SaveReal(mTable, 215, GetHandleId(e), (newScale - currentScale) * (seconds / TIMER_SPEED));
    }
    
    
    //Sets the alpha gradually over X seconds
    public function setAlphaGradual(effect e, real newAlpha, real seconds) {
        real curAlpha = LoadReal(mTable, 17, GetHandleId(e));
        if(newAlpha > 1) newAlpha = 1;
        if(newAlpha < 0) newAlpha = 0;
        SaveReal(mTable, 116, GetHandleId(e), newAlpha);
        SaveReal(mTable, 216, GetHandleId(e), (newAlpha - curAlpha) * (seconds / TIMER_SPEED));
    }
    
    //Sets whether the missile collides on hit with any unit
    public function setCollideAnyUnit(effect e, boolean collide) {
        SaveBoolean(mTable, 100, GetHandleId(e), collide);
    }
    
    //Sets whether the missile stops when it hits something
    public function setDestroyOnHit(effect e, boolean destroy) {
        SaveBoolean(mTable, 101, GetHandleId(e), destroy);
    }
    
    //What does it do onHit
    public function setOnHit(effect e, boolexpr t) {
        SaveBooleanExprHandle(mTable, 25, GetHandleId(e), t);
    }
    
    //Speed of missile per second
    public function setSpeed(effect e, real speed) {
        SaveReal(mTable, 18, GetHandleId(e), speed);
    }
    
    //Set speed gradually
    public function setSpeedGradual(effect e, real speed, real seconds) {
        real curSpeed = LoadReal(mTable, 18, GetHandleId(e));
        SaveReal(mTable, 118, GetHandleId(e), speed);
        SaveReal(mTable, 218, GetHandleId(e), (speed - curSpeed) * (seconds / TIMER_SPEED));
    }
    
    private function updateX(effect e) -> real {
        real x = getX(e);
        real speed = getSpeed(e);
        if(x != getTargetX) {
            return offsetXTowardsPoint(getX(e), getY(e), getTargetX(e), getTargetY(e), speed * TIMER_SPEED);
        }
        return x;
    }
    
    private function updateY(effect e) -> real {
        real y = getY(e);
        real speed = getSpeed(e);
        if(y != getTargetY(e)) {
            return offsetYTowardsPoint(getX(e), getY(e), getTargetX(e), getTargetY(e), speed * TIMER_SPEED);
        }
        return y;
    }
    
    private function updateZ(effect e) -> real {
        if(getZ(e) != getTargetZ(e)) {
            return (getZ(e) - getTargetZ(e)) / (getETA(e) * TIMER_SPEED);
        }
        return getZ(e);
    }
    
    private function onHit(effect e) {
        timer t = LoadTimerHandle(mTable, 30, GetHandleId(e));
        trigger tr = LoadTriggerHandle(mTable, 25, GetHandleId(e));
        doME = e;
        TriggerEvaluate(tr);
        doME = null;
        FlushChildHashtable(mTable, t);
        DestroyTimer(t);
        DestroyTrigger(tr);
        FlushChildHashtable(mTable, e);
    }
    
    private function updateXYZ(effect e) -> boolean {
        real nX, nY, nZ;
        if(getX(e) == getTargetX(e) && getY(e) == getTargetY(e) && getZ(e) == getTargetZ(e)) {
            //DONE
            onHit();
        } else {
            nX = updateX(e);
            nY = updateY(e);
            nZ = updateZ(e);
            setX(e, nX);
            setY(e, nY);
            setZ(e, nZ);
        }
    }
    
    private function tick() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        effect e = LoadEffectHandle(mTable, 0, th);
        integer mh = GetHandleId(e);
        //Still got a bunch of stuff to load
        //Start with missiles current X / Y / Z
        real sx = getX(e);
        real sy = getY(e);
        real sz = getZ(e);
        
        //Then load targets X / Y / Z
        real tx = getTargetX(e);
        real ty = getTargetY(e);
        real tz = getTargetZ(e);
        
        //Load the target if there is one
        unit target = LoadUnitHandle(mTable, 21, mh);
        
        //Load scale, collision size, alpha, speed
        real scale = getScale(e);
        real alpha = getAlpha(e);
        real cSize = getCollisionSize(e);
        real speed = getSpeed(e);
        
        //Load target scale / collision size / alpha / speed
        //Also load rate of change of each (if set)
        real tScale = getTargetScale(e);
        real scaleCPS = getScaleCPS(e);
        
        real tAlpha = getTargetAlpha(e);
        real alphaCPS = getAlphaCPS(e);
        
        real tcSize = getTargetCollisionSize(e);
        real cSizeCPS = getCollisionSizeCPS(e);
        
        real tSpeed = getTargetSpeed(e);
        real speedCPS = getSpeedCPS(e);
        
        //Let's load booleans to determine how we do what we do
        boolean collideOnHit = LoadBoolean(mTable, 100, mh);
        boolean destroyOnHit = LoadBoolean(mTable, 101, mh);
        
        //Create a quick unit group and unit to loop through to check around the missile
        group g;
        unit u;
        
        //Update all things according to the user specified rates
        if(scale != tScale) {
            setScale(e, scale + scaleCPS);
        }
        if(alpha != tAlpha) {
            setAlpha(e, alpha + alphaCPS);
        }
        if(cSize != tcSize) {
            setCollsionSize(e, cSize + cSizeCPS);
        }
        if(speed != tSpeed) {
            setSpeed(e, speed + speedCPS);
        }
        
        //If there is a target, let's go ahead and update the target X / Y / Z
        if(target != null) {
            tx = GetUnitX(target);
            ty = GetUnitY(target);
            tz = GetUnitZ(target);
            setTargetXYZ(e, tx, ty, tz);
        }
        
        //Update missile X / Y / Z according to function
        updateXYZ(e);
        
        //If collide on hit is true
        if(collideOnHit) {
            //Create the group and check
        }
    }
    
    public function launchMissile(effect e, real speed) {
        integer mh = GetHandleId(e);
        timer t = LoadTimerHandle(mTable, 30, mh);
        
        setSpeed(e, speed);
        
        TimerStart(t, TIMER_SPEED, true, function tick);
        
        t = null;
    }
    
    //Creates a missile of model m, start X, Y, & Z, target X,  Y, & Z offset
    public function CreateBasicMissile(string m, real sX, real sY, real sZ, real tX, real tY, real tZ, real o) -> effect {
        timer t = CreateTimer(); //Timer to move the units and detect stuff
        integer th = GetHandleId(t);
        //The head honcho, timers and everything are stored in this
        effect missile;
        integer mh;
        //Get our starting X and Y real quick
        real x = offsetXTowardsPoint(sX, sY, tX, tY, o);
        real y = offsetYTowardsPoint(sX, sY, tX, tY, o);
        real distance = getDistance(x, y, tX, tY);
        real halfwayX = offSetXTowardsPoint(x, y, tX, tY, getDistance
        real angle = getAngle(sX, sY, tX, tY);
        real scale = 1;
        real collisionSize = 50;
        real alpha = 1;
        
        missile = AddSpecialEffect(m, x, y);
        mh = GetHandleId(missile);
        //Save the missile
        SaveEffectHandle(mTable, 0, mh, missile);
        //Also save to the timer so we can get it
        SaveEffectHandle(mTable, 0, th, missile);
        
        //Save stuff in the missile's table
        //Start with start X Y Z
        SaveReal(mTable, 1, mh, x);
        SaveReal(mTable, 2, mh, y);
        SaveReal(mTable, 3, mh, sZ);
        
        //Set the special effects Z
        setHeight(missile, sZ);
        
        //Saves target X Y Z
        SaveReal(mTable, 4, mh, tX);
        SaveReal(mTable, 5, mh, tY);
        SaveReal(mTable, 6, mh, tZ);
        
        //Saves the halfway X Y Z
        SaveReal(mTable, 7, mh, x);
        SaveReal(mTable, 8, mh, y);
        SaveReal(mTable, 9, mh, sZ);
        
        //Saves roll / pitch / yaw
        //AKA exactly what it sounds like / unit facing / unit facing towards sky or ground
        SaveReal(mTable, 10, mh, 0);
        SaveReal(mTable, 11, mh, angle);
        SaveReal(mTable, 12, mh, 0);
        
        //Sets the effects facing
        setFacing(missile, angle);
        
        //Saves misc info - scale, collision size, fly height,
        SaveReal(mTable, 15, mh, scale);
        SaveReal(mTable, 16, mh, collisionSize);
        SaveReal(mTable, 17, mh, alpha);
        
        //Saves the Timer
        SaveTimerHandle(mTable, 30, mh, t);
        
        t = null;
        //returns the missile effect so triggers can do stuff with it;
        return missile;
    }
    
    //Creates a homing missile of model m, start X, Y, & Z, target, and offset
    public function CreateBasicHomingMissile(string m, real sX, real sY, real sZ, unit target, real o) -> effect {
        timer t = CreateTimer(); //Timer to move the units and detect stuff
        integer th = GetHandleId(t);
        //The head honcho, timers and everything are stored in this
        effect missile;
        integer mh;
        //Target unit X / Y / Z
        real tX = GetUnitX(target);
        real tY = GetUnitY(target);
        real tZ = BlzGetUnitZ(target);
        
        //Get our starting X and Y real quick
        real x = offsetXTowardsPoint(sX, sY, tX, tY, o);
        real y = offsetYTowardsPoint(sX, sY, tX, tY, o);
        real distance = getDistance(x, y, tX, tY);
        real halfwayX = offSetXTowardsPoint(x, y, tX, tY, getDistance
        real angle = getAngle(sX, sY, tX, tY);
        real scale = 1;
        real collisionSize = 50;
        real alpha = 1;
        
        missile = AddSpecialEffect(m, x, y);
        mh = GetHandleId(missile);
        //Save the missile
        SaveEffectHandle(mTable, 0, mh, missile);
        //Also save to the timer so we can get it
        SaveEffectHandle(mTable, 0, th, missile);
        
        //Save stuff in the missile's table
        //Start with start X Y Z
        SaveReal(mTable, 1, mh, x);
        SaveReal(mTable, 2, mh, y);
        SaveReal(mTable, 3, mh, sZ);
        
        //Set the special effects Z
        setHeight(missile, sZ);
        
        //Saves target X Y Z
        SaveReal(mTable, 4, mh, tX);
        SaveReal(mTable, 5, mh, tY);
        SaveReal(mTable, 6, mh, tZ);
        
        //Saves the halfway X Y Z
        SaveReal(mTable, 7, mh, offsetXTowardsPoint(x, y, tX, tY, distance / 2));
        SaveReal(mTable, 8, mh, offsetYTowardsPoint(x, y, tX, tY, distance / 2));
        SaveReal(mTable, 9, mh, sZ + ((tZ - sZ) / 2));
        
        //Saves roll / pitch / yaw
        //AKA exactly what it sounds like / unit facing / unit facing towards sky or ground
        SaveReal(mTable, 10, mh, 0);
        SaveReal(mTable, 11, mh, angle);
        SaveReal(mTable, 12, mh, 0);
        
        //Sets the effects facing
        setFacing(missile, angle);
        
        //Saves misc info - scale, collision size, fly height,
        SaveReal(mTable, 15, mh, scale);
        SaveReal(mTable, 16, mh, collisionSize);
        SaveReal(mTable, 17, mh, alpha);
        
        //Saves the Timer
        SaveTimerHandle(mTable, 30, mh, t);
        
        //returns the missile effect so triggers can do stuff with it;
        return missile;
    }
    
    //Creates a homing missile of model m, start unit, target unit, and offset
    public function CreateHomingMissile(string m, unit caster, unit target, real o) -> effect {
        timer t = CreateTimer(); //Timer to move the units and detect stuff
        integer th = GetHandleId(t);
        //The head honcho, timers and everything are stored in this
        effect missile;
        integer mh;
        //Caster X / Y / Z
        real sX = GetUnitX(caster);
        real sY = GetUnitY(caster);
        real sZ = BlzGetUnitZ(caster);
        //Target unit X / Y / Z
        real tX = GetUnitX(target);
        real tY = GetUnitY(target);
        real tZ = BlzGetUnitZ(target);
        
        //Get our starting X and Y real quick
        real x = offsetXTowardsPoint(sX, sY, tX, tY, o);
        real y = offsetYTowardsPoint(sX, sY, tX, tY, o);
        real distance = getDistance(x, y, tX, tY);
        real halfwayX = offSetXTowardsPoint(x, y, tX, tY, getDistance
        real angle = getAngle(sX, sY, tX, tY);
        real scale = 1;
        real collisionSize = 50;
        real alpha = 1;
        
        missile = AddSpecialEffect(m, x, y);
        mh = GetHandleId(missile);
        //Save the missile
        SaveEffectHandle(mTable, 0, mh, missile);
        //Also save to the timer so we can get it
        SaveEffectHandle(mTable, 0, th, missile);
        
        //Save stuff in the missile's table
        //Start with start X Y Z
        SaveReal(mTable, 1, mh, x);
        SaveReal(mTable, 2, mh, y);
        SaveReal(mTable, 3, mh, sZ);
        
        //Set the special effects Z
        setHeight(missile, sZ);
        
        //Saves target X Y Z
        SaveReal(mTable, 4, mh, tX);
        SaveReal(mTable, 5, mh, tY);
        SaveReal(mTable, 6, mh, tZ);
        
        //Saves the halfway X Y Z
        SaveReal(mTable, 7, mh, offsetXTowardsPoint(x, y, tX, tY, distance / 2));
        SaveReal(mTable, 8, mh, offsetYTowardsPoint(x, y, tX, tY, distance / 2));
        SaveReal(mTable, 9, mh, sZ + ((tZ - sZ) / 2));
        
        //Saves roll / pitch / yaw
        //AKA exactly what it sounds like / unit facing / unit facing towards sky or ground
        SaveReal(mTable, 10, mh, 0);
        SaveReal(mTable, 11, mh, angle);
        SaveReal(mTable, 12, mh, 0);
        
        //Sets the effects facing
        setFacing(missile, angle);
        
        //Saves misc info - scale, collision size, fly height,
        SaveReal(mTable, 15, mh, scale);
        SaveReal(mTable, 16, mh, collisionSize);
        SaveReal(mTable, 17, mh, alpha);
        
        //Saves the Timer
        SaveTimerHandle(mTable, 30, mh, t);
        
        //returns the missile effect so triggers can do stuff with it;
        return missile;
    }
    
    private function onInit() {
        
    }
}
//! endzinc