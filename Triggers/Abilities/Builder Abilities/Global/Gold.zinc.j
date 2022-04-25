//! zinc

library GetGold requires GT, UnitManager {
    private constant string GOLD_EFFECT = "Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl";

    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A041');
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
            player p = GetOwningPlayer(u);
            unit v = GetSpellTargetUnit();

            if (GetUnitTypeId(u) == 'O01Q'){ // Tauren
                ExperienceSystem.giveExperience(u, 2);
            }
	    if (GetUnitTypeId(u) == 'h035' && GetPlayerTechCountSimple('R02Y', GetOwningPlayer(u)) > 0 ) { // Satyr
		IssueTargetOrderBJ(u,"restoration",v);	//There are some issues with this (getting ordered automatically, but works for now
	    }
            
            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + 1);
            
			DestroyEffect(AddSpecialEffect(GOLD_EFFECT, GetUnitX(v), GetUnitY(v)));
            SetUnitState(v, UNIT_STATE_LIFE, GetUnitState(v, UNIT_STATE_MAX_LIFE) / 4.0);
			
			GameSettings.setInt("TITAN_MOUND_GOLD_STOLEN", GameSettings.getInt("TITAN_MOUND_GOLD_STOLEN") + 1);
			
            u = null;
            p = null;
            v = null;
            return false;
        }));
        t = null;
    }
}

//! endzinc