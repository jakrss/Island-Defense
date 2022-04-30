//! zinc
library HeroLevelArmorBonus requires IsUnitTitanHunter, IsUnitBuilder, IsUnitTitanous {
	//Generic:
	private unit ankhHolder;

	private function ankhDelay() {
		timer tAnkh = GetExpiredTimer();
		UnitAddItemById(ankhHolder, 'I027');	//Adds +10 damage
		DestroyTimer(tAnkh);
		tAnkh = null;
		ankhHolder = null;
	}

	public function fGetPrimaryAttribute(unit uTitan) -> integer {
		if((GetUnitTypeId(uTitan) == 'E00B') || (GetUnitTypeId(uTitan) == 'E00I') || (GetUnitTypeId(uTitan) == 'E012') || (GetUnitTypeId(uTitan) == 'E00O') || (GetUnitTypeId(uTitan) == 'E00C')) {
			return 1;
		} else if(GetUnitTypeId(uTitan) == 'E00K' || GetUnitTypeId(uTitan) == 'E01D' || GetUnitTypeId(uTitan) == 'E011' || GetUnitTypeId(uTitan) == 'TITA') {
			return 2;
		} else return 3;
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_LEVEL);
		TriggerAddCondition(t, function() {
			unit levelingHero = GetTriggerUnit();
			real r_armor;
			integer i_attackdamage;
			integer i_ADPerLevel;
			timer tAnkh;
			integer iPrimAtt;
			r_armor = BlzGetUnitRealField(levelingHero, UNIT_RF_DEFENSE);
			BlzSetUnitRealFieldBJ(levelingHero, UNIT_RF_DEFENSE, (r_armor + 1));
			if(IsUnitTitanous(levelingHero)) {
				if(GetUnitAbilityLevel(levelingHero, 'A012') <= 0) UnitAddItemById(levelingHero, 'I027');	//Adds +10 damage
				else {
					tAnkh = CreateTimer();
					TimerStart(tAnkh, 7.25, false, function ankhDelay);
					ankhHolder = levelingHero;	//This can, in reality, only occur once in the game.
					tAnkh = null;
				}
				//Let's give Titan with an Ankh more stats:
				if(UnitHasItemOfTypeBJ(levelingHero, 'I00P') || UnitHasItemOfTypeBJ(levelingHero, 'I07A')) {
					iPrimAtt = fGetPrimaryAttribute(levelingHero);
					if(iPrimAtt == 1) SetHeroStr(levelingHero, GetHeroStr(levelingHero, false) + 2, true);
					if(iPrimAtt == 2) SetHeroAgi(levelingHero, GetHeroAgi(levelingHero, false) + 2, true);
					if(iPrimAtt == 3) SetHeroInt(levelingHero, GetHeroInt(levelingHero, false) + 2, true);
				}
			}
			else if(IsUnitTitanHunter(levelingHero)) UnitAddItemById(levelingHero, 'I027'); //Adds +10 damage
			else if(IsUnitBuilder(levelingHero) && GetUnitTypeId(levelingHero) != 'O01Q' && GetUnitTypeId(levelingHero) != 'O01R') UnitAddItemById(levelingHero, 'I01O'); //Adds +5 damage
			else if(GetUnitTypeId(levelingHero) == 'O01Q' || GetUnitTypeId(levelingHero) == 'O01R') {
				SetPlayerTechResearched(GetOwningPlayer(levelingHero), 'RPAD', GetPlayerTechCount(GetOwningPlayer(levelingHero), 'RPAD', false) + 1);
			}
		levelingHero = null;
		});
	t = null;
	}
}
//! endzinc