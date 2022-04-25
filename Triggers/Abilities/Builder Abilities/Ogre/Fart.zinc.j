//! zinc

library Fart requires GT, xecast, xepreload {
    private constant integer ABILITY_ID = 'A067';
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, ABILITY_ID);
        TriggerAddCondition(t , Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            xecast xe = xecast.createBasic('A0LI', OrderId("silence"), p);
			real x = GetUnitX(u);
			real y = GetUnitY(u);
			integer i = 0;
			unit a = null;
			
			// Cast Silence
            xe.recycledelay = 1.0;
            xe.castOnPoint(x, y);
			
			// Create Fart Clouds
			for (0 <= i < 5) {
				a = CreateUnit(p, 'u00T', GetRandomReal(-50, 50) + x, GetRandomReal(-50, 50) + y, 0);
				UnitApplyTimedLife(a, 'BTLF', 5.0);
			}
            
			// Play Sound
            PlaySoundBJ(gg_snd_Fart);
			
			// Cleanup
            u = null;
			a = null;
            return false;
        }));
        XE_PreloadAbility(ABILITY_ID);
        t = null;
    }
}

//! endzinc