//! zinc

library ExchangeGold requires GT, GameTimer, ShowTagFromUnit {
    private real currentRate[];
    private real diminishingAmount = 12;
    private GameTimer diminishingTimer[];
    private integer currentIndex = 0;
    private real duration = 300;
    
    
    private function onInit(){
        trigger t = CreateTrigger();
        integer i;
        for(0<=i<=11) {
            currentRate[i] = 100;
        }
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_TRAIN_FINISH);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            unit v = GetTrainedUnit();
            player p = GetOwningPlayer(u);
            integer amount;
            if (GetUnitTypeId(v) == 'n007'){ // Dummy Unit
                amount = R2I(600 * (currentRate[GetPlayerId(p)]/100));
                if(amount < 300) {
                    amount = 300;
                } else if(amount > 600) {
                    amount = 600;
                }
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", GetUnitX(u), GetUnitY(u)));
                SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + amount);
                ShowTagFromUnitWithColor("+" + I2S(amount), v, 50, 205, 50);
                RemoveUnit(v);
                if(amount > 300) {
                    currentRate[GetPlayerId(p)] = currentRate[GetPlayerId(p)] - diminishingAmount;
                    diminishingTimer[currentIndex] = GameTimer.new(function (GameTimer t) {
                        integer pID = t.data();
                        currentRate[pID] = currentRate[pID] + diminishingAmount;
                        if(currentRate[pID] > 100) {
                            currentRate[pID] = 100;
                        }
                    }).start(duration);
                    diminishingTimer[currentIndex].setData(GetPlayerId(p));
                    currentIndex += 1;
                }
            }

            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc