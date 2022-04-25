library DestroyEffectTimed requires TimerUtils
    struct effectTimed
        effect e
    endstruct
    
    public function effectExpire takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local effectTimed et = GetTimerData(t)
        call DestroyEffect(et.e)
        call et.destroy()
        call ReleaseTimer(t)
        set t = null
    endfunction
    
    function DestroyEffectTimed takes effect e, real s returns nothing
        local timer t = NewTimer()
        local effectTimed et = effectTimed.create()
        set et.e = e
        call SetTimerData(t, et)
        call TimerStart(t, s, false, function effectExpire)
        set t = null
    endfunction
endlibrary