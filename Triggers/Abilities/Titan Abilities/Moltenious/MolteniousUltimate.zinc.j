//! zinc
library MolteniousUltimate requires MathLibs, BUM, TerrainPathability {
	private constant integer AMU = 'A0NG';				//Ability Moltenious Ultimate
	private constant integer ChannelBuff = 'A0NZ';		//Moltenious has this when he channels
	private constant integer MagID = 'n008';			//Magmide unit ID
	private constant real LEASHRANGE = 1500;
	private group MagmideGroup = CreateGroup();
	private hashtable Maghash = InitHashtable();

	private function FlushAll(unit Moltenious, unit Magmide) {
		player p = GetOwningPlayer(Moltenious);
		integer c = 1;
		integer i[];
		timer t = LoadTimerHandle(Maghash, GetHandleId(Magmide), 5);
		DestroyTimer(t);
		GroupRemoveUnit(MagmideGroup, Magmide);
		SelectUnitAddForPlayer(Moltenious, p);
		FlushChildHashtable(Maghash, GetHandleId(Magmide));
		FlushChildHashtable(Maghash, GetHandleId(Moltenious));
		UnitRemoveAbility(Moltenious, ChannelBuff);
		if(GetWidgetLife(Magmide) > 0.45) KillUnit(Magmide);
		
		p = null;
		Moltenious = null;
		Magmide = null;
	}
	
	function checkLeash() {
	    group g = CreateGroup();
	    unit u;
	    unit molt;
	    timer t;
	    real distance;
	    u = FirstOfGroup(MagmideGroup);
	    while(u != null) {
		if(GetUnitTypeId(u) == MagID) {
		    t = LoadTimerHandle(Maghash, GetHandleId(u), 5);
		    molt=LoadUnitHandle(Maghash, GetHandleId(u), 0);
		    distance = getDistance(GetUnitX(u), GetUnitY(u), GetUnitX(molt), GetUnitY(molt));
		    if(distance > LEASHRANGE) {
			FlushAll(molt, u);
		    }
		    molt = null;
		}
		GroupRemoveUnit(g, u);
		u=FirstOfGroup(g);
	    }
	    u=null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit Moltenious = GetTriggerUnit();
			unit Magmide;
			real XLoc;
			real YLoc;
			real Face;
			real finalX;
			real finalY;
			timer t;
			player p = GetOwningPlayer(Moltenious);
			integer c = 1;
			integer i[];
			//If it is Moltenious' ultimate cast:
			if(GetSpellAbilityId() == AMU) {
				XLoc = GetUnitX(Moltenious);
				YLoc = GetUnitY(Moltenious);
				Face = GetUnitFacing(Moltenious);
				finalX = offsetXTowardsAngle(XLoc, YLoc, Face, 150);
				finalY = offsetYTowardsAngle(XLoc, YLoc, Face, 150);
				UnitAddAbility(Moltenious, ChannelBuff);
				UnitAddAbility(Moltenious, 'Aeth'); //Ghost
				if(!IsTerrainWalkable(XLoc, YLoc)) {
				    finalX = TerrainPathability_X;
				    finalY = TerrainPathability_Y;
				}
				Magmide = CreateUnit(p, MagID, finalX, finalY, Face);
				GroupAddUnit(MagmideGroup, Magmide);
				DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", Magmide, "chest"));
				DestroyEffect(AddSpecialEffectTarget("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", Magmide, "chest"));
				SaveUnitHandle(Maghash, GetHandleId(Magmide), 0, Moltenious);
				SaveUnitHandle(Maghash, GetHandleId(Moltenious), 0, Magmide);
				SelectUnitAddForPlayer(Magmide, p);
				t = CreateTimer();
				SaveTimerHandle(Maghash, GetHandleId(Magmide), 5, t);
				TimerStart(t, 0.5, true, function checkLeash);
				t = null;
			}
			Moltenious = null;
			Magmide = null;
			p = null;
		});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
		TriggerAddCondition(t, function() {
			unit Magmide = GetTriggerUnit();
			unit Moltenious;
			integer c = 1;
			integer i[];
			player p;
			if(GetUnitTypeId(Magmide) == MagID) {
				Moltenious = LoadUnitHandle(Maghash, GetHandleId(Magmide), 0);
				p = GetOwningPlayer(Moltenious);
				FlushAll(Moltenious, Magmide);
				IssueImmediateOrder(Moltenious, "stop");
				SelectUnitAddForPlayer(Moltenious, p);
			}
			Magmide = null;
			Moltenious = null;
		});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_ENDCAST);
		TriggerAddCondition(t, function() {
			unit Moltenious = GetTriggerUnit();
			unit Magmide;
			if(GetSpellAbilityId() == AMU) {
				Magmide = LoadUnitHandle(Maghash, GetHandleId(Moltenious), 0);
					FlushAll(Moltenious, Magmide);
			}
		});
		t = null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
		TriggerAddCondition(t, function() {
			unit Moltenious = GetTriggerUnit();
			if(GetUnitAbilityLevel(Moltenious, ChannelBuff) > 0) {
				BlzSetEventDamage(0);
			}
			Moltenious = null;
		});
		t = null;
	}
}
//! endzinc