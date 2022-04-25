//! zinc
library LucidiousUnique requires xecast, xefx, xebasic {
	//Lucidious Unique Ability ID and Dummy Ability ID
	private constant integer UniqueID = 'TLAR';
	private constant integer DummyID = 'TLDR';
	private constant integer HasteID = 'A098';
	private constant integer ORDERID = 852189;	//Cast orderid for the HASTE ability.
	//Timer period
	private constant real period = 0.5;
	//Hashtable
	private hashtable ht = InitHashtable();

	//Checking when the unit is in shallow water.
	public function inShallowWater() {
		timer t = GetExpiredTimer();
		integer index = GetHandleId(t);
		unit u = LoadUnitHandle(ht, 0, index);
		integer UniqueLevel = GetUnitAbilityLevel(u, UniqueID);
		real px = GetUnitX(u);
		real py = GetUnitY(u);
		location p = Location(px,py);
		xecast dummyCast;
		//And actually checking it:
		if(IsTerrainPathableBJ(p, PATHING_TYPE_FLOATABILITY) == false) {
			//BJDebugMsg("You are in shallow water, lets give you Tidal Strike.");
			if(GetUnitAbilityLevel(u, UniqueID) <= 2) {
				//BJDebugMsg("Increasing Tidal Strike level");
				SetUnitAbilityLevel(u, DummyID, 7);
				//BJDebugMsg("Tidal Strike level" + I2S(GetUnitAbilityLevel(u, DummyID)));
			}
		} if(IsTerrainPathableBJ(p, PATHING_TYPE_FLOATABILITY) == true) {
			if(GetUnitAbilityLevel(u, DummyID) > 6) {
			//BJDebugMsg("You left shallow water, let's give you speed!");
				dummyCast = xecast.createBasicA(HasteID, ORDERID, GetOwningPlayer(u));
				dummyCast.castOnTarget(u);
				SetUnitAbilityLevel(u, DummyID, 6);
				//BJDebugMsg("Setting b to true");
			}
		}
		t = null;
		u = null;
		p = null;
		
	}
	
	//Let's detect when a unit learns Lucidious' unique ability.
	private function onInit() {
		trigger t = CreateTrigger();
		trigger y = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_SKILL);
		TriggerAddCondition(t, function() -> boolean {
			unit u = GetTriggerUnit();
			timer t;
			integer timerIndex;
			integer UniqueLevel = GetLearnedSkillLevel();
			if(GetLearnedSkill() == UniqueID && UniqueLevel < 2) {
				//BJDebugMsg("You learned Lucidious unique");
				UnitAddAbility(u, DummyID);
				t = CreateTimer();
				timerIndex= GetHandleId(t);
				
				SaveUnitHandle(ht, 0, timerIndex, u);
				
				TimerStart(t, period, true, function inShallowWater);
				t = null;
			}
			u = null;
			return false;
			
		});	
		t = null;
	}

}

//! endzinc