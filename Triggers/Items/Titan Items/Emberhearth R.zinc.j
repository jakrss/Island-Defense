//! zinc
library Emberhearth requires xemissile, xefx, xebasic, ItemExtras, MathLibs {
    //Library for spawning Emberhearths lel
    //Timer speed for burning
    private constant real TIMER_SPEED = .225;
    //Vision Ability for the flames to provide vision
    private constant integer VISION_ABILITY = 'ABCj';
    //Ember (Fiery) model path (or dummy unit)
    private constant string MISSILE_MODEL = "Sparks(Missile).mdx";
    //Hashtable and other constants
    private hashtable emberTable = InitHashtable();
    private constant real EMBER_SEC = 20;
    private constant real EMBER_TIMER = .225;
    private constant real SCALE = 1.0;
    private constant real ARC = .25;
    private constant real SPD_LO = 175;
    private constant real SPD_HI = 500;
    private constant real ANGLE_OFFSET = 45;
    private constant real OFFSET_LO = 150;
    private constant real OFFSET_HI = 350;
    
    function cleanUp(timer t) {
        unit u = LoadUnitHandle(emberTable, 0, GetHandleId(t));
        unit d = LoadUnitHandle(emberTable, 1, GetHandleId(t));
        FlushChildHashtable(emberTable, GetHandleId(d));
        FlushChildHashtable(emberTable, GetHandleId(u));
        FlushChildHashtable(emberTable, GetHandleId(t));
        
        d = null;
        u = null;
        DestroyTimer(t);
        t = null;
    }
    
    function spawnEmbers() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(emberTable, 0, th);
        unit d = LoadUnitHandle(emberTable, 1, th);
        real sx = LoadReal(emberTable, 2, th);
        real sy = LoadReal(emberTable, 3, th);
        real angle = LoadReal(emberTable, 4, th);
        real duration = LoadReal(emberTable, 5, th);
        integer maxCharges = LoadInteger(emberTable, 6, th);
        real chargeTime = LoadReal(emberTable, 7, th);
        integer itemId = LoadInteger(emberTable, 8, th);
        real cLoops = LoadReal(emberTable, 9, th);
        
        real tempAngle = GetRandomReal(angle - ANGLE_OFFSET, angle + ANGLE_OFFSET);
        
        real tempDist = GetRandomReal(OFFSET_LO, OFFSET_HI);
        
        real curElapsed = cLoops * TIMER_SPEED;
        
        xemissilewithvision ember;
        real tX = offsetXTowardsAngle(sx, sy, tempAngle, tempDist);
        real tY = offsetYTowardsAngle(sx, sy, tempAngle, tempDist);
        real distance = getDistance(GetUnitX(u), GetUnitY(u), tX, tY);
        
        //Check if the unit still has the item
        if(!UnitHasItemById(u, itemId) || curElapsed > duration || getHealth(d) <= .405) {
            cleanUp(t);
        } else if((curElapsed - (curElapsed / TIMER_SPEED) * TIMER_SPEED) == 0) {
	    
            ember = xemissilewithvision.create(sx, sy, 50, tX, tY, 50);
            ember.fxpath = MISSILE_MODEL;
            ember.scale = SCALE;
	    ember.owner = GetOwningPlayer(u);
            ember.launch(GetRandomReal(SPD_LO, SPD_HI), ARC);
        }
        
        cLoops = cLoops + 1;
        SaveReal(emberTable, 9, th, cLoops);
        
        d = null;
        u = null;
        t = null;
    }
    
    public function newEmberhearth(unit u, unit d, real dur, integer maxcharges, real chargetime, integer ITEM_ID) {
        timer t;
        integer th;
        real sx = GetUnitX(d);
        real sy = GetUnitY(d);
        real angle = getAngle(GetUnitX(u), GetUnitY(u), sx, sy);
        real duration = dur;
        integer curCharges = LoadInteger(emberTable, 1, GetHandleId(u));
        integer maxCharges = maxcharges;
        real chargeTime = chargetime;
        integer itemId = ITEM_ID;
        boolean isLit = LoadBoolean(emberTable, 0, GetHandleId(d));
        
        if(curCharges > 0 && !isLit) {
            t = CreateTimer();
            th = GetHandleId(t);
            //Save all this sheet
            SaveUnitHandle(emberTable, 0, th, u);
            SaveUnitHandle(emberTable, 1, th, d);
            SaveReal(emberTable, 2, th, sx);
            SaveReal(emberTable, 3, th, sy);
            SaveReal(emberTable, 4, th, angle);
            SaveReal(emberTable, 5, th, duration);
            SaveInteger(emberTable, 6, th, maxCharges);
            SaveReal(emberTable, 7, th, chargeTime);
            SaveInteger(emberTable, 8, th, itemId);
            
            SaveBoolean(emberTable, 0, GetHandleId(d), true);
            
            TimerStart(t, TIMER_SPEED, true, function spawnEmbers);
            SaveInteger(emberTable, 1, GetHandleId(u), curCharges - 1);
			CreateUnit((GetOwningPlayer(u)), 'e01C', sx, sy, 0);
            t = null;
        }
    }
    
    function addCharge() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit u = LoadUnitHandle(emberTable, 0, th);
        integer itemId = LoadInteger(emberTable, 1, th);
        integer uh = GetHandleId(u);
        integer charges = LoadInteger(emberTable, 1, uh);
        integer maxCharge = LoadInteger(emberTable, 2, uh);
        real chargeTime = LoadReal(emberTable, 3, uh);
        
        if(UnitHasItemById(u, itemId)) {
            if(charges < maxCharge) {
                charges = charges + 1;
                SaveInteger(emberTable, 1, uh, charges);
            }
        } else {
            cleanUp(t);
        }
    }
    
    //Meant to be when the item is picked up or dropped
    public function onPickupEmber(unit u, integer itemId, real chargeTime, integer maxCharges) {
        timer chargeTimer = LoadTimerHandle(emberTable, 0, GetHandleId(u));
        integer charges = LoadInteger(emberTable, 1, GetHandleId(u));
        
        if(chargeTimer == null && UnitHasItemById(u, itemId)) {
            //Oh sheet we gotta track the charges
            chargeTimer = CreateTimer();
            SaveTimerHandle(emberTable, 0, GetHandleId(u), chargeTimer);
            SaveInteger(emberTable, 1, GetHandleId(u), 0);
            SaveInteger(emberTable, 2, GetHandleId(u), maxCharges);
            SaveReal(emberTable, 3, GetHandleId(u), chargeTime);
            
            //Save some info to the chargeTimer
            SaveUnitHandle(emberTable, 0, GetHandleId(chargeTimer), u);
            SaveInteger(emberTable, 1, GetHandleId(chargeTimer), itemId);
            
            TimerStart(chargeTimer, chargeTime, true, function addCharge);
            chargeTimer = null;
        } else if(!UnitHasItemById(u, itemId) && chargeTimer != null) {
            cleanUp(chargeTimer);
        }
        chargeTimer = null;
        u = null;
    }
}
//! endzinc