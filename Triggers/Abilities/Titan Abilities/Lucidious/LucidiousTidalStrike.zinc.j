//! zinc
library LucidiousTidalStrike {
	//Lucidious Unique Ability ID and Dummy Ability ID
	private constant integer UniqueID = 'TLAR';
	private constant integer DummyID = 'TLDR';
	//Damage per hero level on Tidal Strike and its features
	private constant integer damage = 25;
	private constant attacktype AT = ATTACK_TYPE_CHAOS;
	private constant weapontype WT = WEAPON_TYPE_WHOKNOWS;
	//Special Effect on attack
	private constant string EFFECT = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl";
	
	//And when angry Lucidious hits walls
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
			TriggerAddCondition(t, function() -> boolean {
				unit u = GetEventDamageSource();
				unit t = GetTriggerUnit();
				real x = GetUnitX(t);
				real y = GetUnitY(t);
				location p = Location(x,y);
				integer HeroLevel = GetHeroLevel(u);
				damagetype DT;
					trigger yt = GetTriggeringTrigger();
				//Check if he has Tidal Strike ready.
				if(GetUnitAbilityLevel(u, DummyID) >= 6		&& 		//Lets check that unit has Tidal Strike
					IsUnitType(t, UNIT_TYPE_STRUCTURE) && 				//And that the target is a structure
					BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {	//And that it is a basic attack
					SetUnitAbilityLevel(u, DummyID, 1);
					//BJDebugMsg("You have Tidal Strike");
					if(GetUnitAbilityLevel(u, UniqueID) == 2) {
						DT = DAMAGE_TYPE_UNIVERSAL ;
						DisableTrigger(yt);
						UnitDamageTarget(u, t, (HeroLevel * damage)*(HeroLevel/20), false, false, AT, DT, WT);
						UnitDamageTarget(u, t, (HeroLevel * damage)*(1-HeroLevel/20), false, false, AT, DAMAGE_TYPE_NORMAL, WT);
						DestroyEffect(AddSpecialEffectLoc(EFFECT, p));	//Special effect at the target's location
						EnableTrigger(yt);
					} else if(GetUnitAbilityLevel(u, UniqueID) == 1) {
						DT = DAMAGE_TYPE_NORMAL ;
					DisableTrigger(yt);
					UnitDamageTarget(u, t, HeroLevel * damage, false, false, AT, DT, WT);
					DestroyEffect(AddSpecialEffectLoc(EFFECT, p));	//Special effect at the target's location
					EnableTrigger(yt);
					}
					
					//If not, lets give stacks also for hitting structures
				} else if (GetUnitAbilityLevel(u, DummyID) < 6	&& 	//Lets check that unit has Tidal Strike
					IsUnitType(t, UNIT_TYPE_STRUCTURE) && 				//And that the target is a structure
					BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {	//And that it is a basic attack
					IncUnitAbilityLevel(u, DummyID);
				}
				u = null;
				t = null;
				DT = null;
				yt = null;
				return false;
			});
			t = null;
	}
}
//! endzinc