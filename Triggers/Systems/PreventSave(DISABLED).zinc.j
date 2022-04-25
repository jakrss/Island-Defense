// Converted to Zinc by Neco for use in Island Defense

//! zinc
library PreventSave requires TimerUtils{
    dialog D = DialogCreate();

    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterGameEvent(t, EVENT_GAME_SAVE);
        TriggerAddCondition(t, function()->boolean {
            DialogDisplay(GetLocalPlayer(), D, true);
            TimerStart(NewTimer(), 0.00, false, function(){
                DialogDisplay(GetLocalPlayer(), D, false);
                ReleaseTimer(GetExpiredTimer());
            });
            return false;
        });
    }
}
//! endzinc