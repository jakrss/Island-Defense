//! zinc
library PanicSoundEffect requires GT {
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A003'); // Murloc
        GT_RegisterStartsEffectEvent(t, 'A03D'); // 
        GT_RegisterStartsEffectEvent(t, 'A02K'); //
		GT_RegisterStartsEffectEvent(t, 'A0A5'); // 
        GT_RegisterStartsEffectEvent(t, 'A0IA'); // 
        GT_RegisterStartsEffectEvent(t, 'A0F5'); // Dryad (Flee)
        GT_RegisterStartsEffectEvent(t, 'A07J'); // Morphling
		GT_RegisterStartsEffectEvent(t, 'A0M2'); // Arachnid
        TriggerAddCondition(t, Condition( function() -> boolean {
            PlaySoundBJ(gg_snd_Builder_Aahh);
            return false;
        }));
        t = null;
    }
}
//! endzinc