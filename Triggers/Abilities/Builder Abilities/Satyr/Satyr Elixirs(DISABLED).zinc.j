//! zinc

//! textmacro DEF_ELIXIR takes ITEMID
		t = CreateTrigger();
        GT_RegisterItemUsedEvent(t, '$ITEMID$');
        TriggerAddCondition(t, Condition(function() -> boolean {
//! endtextmacro

//! textmacro END_ELIXIR
            return false;
		}));
        t = null;
//! endtextmacro

library SatyrElixir requires xecast, GT, GameTimer {
    private function onInit(){
        trigger t = null;
		//! runtextmacro DEF_ELIXIR("I05C")
            unit u = GetTriggerUnit();
            xecast xe = xecast.createBasicA('A03P', 852271, GetOwningPlayer(u));
			xe.recycledelay = 1.0;
			xe.castOnTarget(u);
            u = null;
		//! runtextmacro END_ELIXIR()
    }
}

//! endzinc