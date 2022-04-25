//! zinc
library Manhunt requires BonusMod {
    private constant integer DUMMY_ID = 'e018';
    //Vision given
    private constant integer VISION = 300;
    //Timer speed
    private constant real TIMER_SPEED = .03125;
    //Ability real field of sight
    private constant unitrealfield SIGHT_FIELD = UNIT_RF_SIGHT_RADIUS;
    //Manhunt table
    private hashtable mTable = InitHashtable();
    
    function updatePos() {
        timer t = GetExpiredTimer();
        integer th = GetHandleId(t);
        unit dummy = LoadUnitHandle(mTable, 0, th);
        unit target = LoadUnitHandle(mTable, 1, th);
        
        if(GetWidgetLife(dummy) < .405 || GetWidgetLife(target) < .405) {
            DestroyTimer(t);
            FlushChildHashtable(mTable, th);
            FlushChildHashtable(mTable, GetHandleId(target));
        } else {
            SetUnitX(dummy, GetUnitX(target));
            SetUnitY(dummy, GetUnitY(target));
        }
        
        dummy = null;
        target = null;
        t = null;
    }
    
    public function hasManhunt(unit u) -> boolean {
        return LoadUnitHandle(mTable, 0, GetHandleId(u)) != null;
    }
    
    public function newManhunt(unit u, unit tu, real duration) {
        timer t = CreateTimer();
        integer th = GetHandleId(t);
        unit dummy = CreateUnit(GetOwningPlayer(u), DUMMY_ID, GetUnitX(tu), GetUnitY(tu), GetUnitFacing(tu));
        
        UnitApplyTimedLife(dummy, 'BTLF', duration);
        
        SaveUnitHandle(mTable, 0, th, dummy);
        SaveUnitHandle(mTable, 1, th, tu);
        
        SaveUnitHandle(mTable, 0, GetHandleId(tu), dummy);
        
        TimerStart(t, TIMER_SPEED, true, function updatePos);
        
        t = null;
        u = null;
        dummy = null;
    }
}
//! endzinc