//! zinc
library Transmute requires CreateItemEx {
    function whichItem(integer i) -> integer {
	/*== Elemental Shrine*/
	if (i=='e01O') {return('I02Q');}
	/*== Demonic Altar*/
	if (i=='o03S') {return('I07R');}
        /*== SACRED SEASHELL*/
        if (i=='o005') {return('I00J');}
        /*== HEAVY CANNON*/
        if (i=='h00P') {return('I00Y');}
        /*== METHANE MACHINE*/
        if (i=='o01Y') {return('I03A');}
        /*== SLUDGE LAUNCHER*/
        if (i=='o003') {return('I00K');}
        /*== TROPICAL GLYPH*/
        if (i=='o006') {return('I00N');}
        /*== GIANT HERMIT*/
        if (i=='o00J') {return('I00T');}
        /*== CRAB MUTANT*/
        if (i=='o00K') {return('I00U');}
        /*== CATAPULT*/
        if (i=='o00L') {return('I00V');}
        /*== WHIRLPOOL*/
        if (i=='o00N') {return('I011');}
        /*== STATIS TOTEM*/
        if (i=='o00M') {return('I00W');}
        /*== MAGIC PEARL*/
        if (i=='o007') {return('I00O');}
        /*== MAGIC TOWER*/
        if (i=='o00O') {return('I00Z');}
        /*== BOMBARD*/
        if (i=='o00P') {return('I010');}
        /*== MAGIC MUSHROOM*/
        if (i=='o00Q') {return('I00X');}
        /*== AURA TREE*/
        if (i=='o00R') {return('I013');}
        /*== SPELL WELL*/
        if (i=='o00S') {return('I014');}
        /*== SPINY PROTECTOR*/
        if (i=='o00T') {return('I015');}
        /*== RAPID FIRE TOWER*/
        if (i=='n01K') {return('I01A');}
        /*== DEEPFREEZE*/
        if (i=='n01J') {return('I01B');}
        /*== ENERGY SPIRE*/
        if (i=='n01L') {return('I01C');}
        /*== MUTATION TOWER*/
        if (i=='o015') {return('I01K');}
        /*== TOXIC TOWER*/
        if (i=='o016') {return('I01L');}
        /*== WAVE TOWER*/
        if (i=='o01P') {return('I02V');}
        /*== DEMOLISHER TOTEM*/
        if (i=='o01U') {return('I02Y');}
        /*== CROWN OF THIEVES*/
        if (i=='e00Y') {return('I037');}
        /*== REPLICATOR*/
        if (i=='o01V') {return('I038');}
        /*== BARRICADE*/
        if (i=='h036') {return('I034');}
        /*== BOX OF GAIA*/
        if (i=='o02H') {return('I05A');}
        /*== BOX OF PYROS*/
        if (i=='o02G') {return('I058');}
        /*== BOX OF STORMS*/
        if (i=='o02I') {return('I059');}
        /* HIGH ENERGY CONDUIT*/
        if (i=='o02A') {return('I057');}
        /* ICE PALACE*/
        if (i=='o02R') {return('I04O');}
        /* EGG SACK*/
        if (i=='o02Z') {return('I05T');}
        /* FIREWORKS LAUNCHER*/
        if (i=='o02Q') {return('I04J');}
        /* TAVERN*/
        if (i=='o02P') {return('I04L');}
        /* WELL OF POWER*/
        if (i=='o02E') {return('I056');}
        /* SPIRITUAL RIFT*/
        if (i=='o031') {return('I061');}
        /* ISLAND BLOOM*/
        if (i=='o03C') {return('I06D');}
        /* LIGHT ENERGY TOWER*/
        if (i=='o017') {return('I01M');}
	/* SUPER KEG OF DESTRUCTION*/
        if (i=='o03N') {return('I08C');}
		/* Ultimate Structure */
		if (i=='o00Z') {return('I04E');}
        return 0;
    }

    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_FINISH );
        TriggerAddCondition(t, Condition(function() -> boolean {
            return GetSpellAbilityId()=='A00D';
        }));
        TriggerAddAction(t, function(){
            unit u=GetTriggerUnit();
            integer i=whichItem(GetUnitTypeId(u));
            if (i != 0){
                RemoveUnit(u);
                CreateItemEx(i,GetUnitX(u),GetUnitY(u));
            }
            u=null;
        });
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetCancelledStructure();
			integer id = GetUnitTypeId(u);
            integer i = whichItem(id);
			
			// Don't create an item for an Ultimate Structure..
            if (i != 0 && id != 'o00Z'){
                CreateItem(i,GetUnitX(u),GetUnitY(u));
            }
            u = null;
            
            return false;
        }));
		 t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_START);
        TriggerAddCondition(t, Condition(function() -> boolean {
            unit u = GetTriggerUnit();
			integer id = GetUnitTypeId(u);
            integer i = whichItem(id);
			
            if (i != 0){
				UnitSetUpgradeProgress(u, 80); // Can't be 99 as it messes up scaling
            }
            u = null;
            
            return false;
        }));
        t = null;
    }
}

//! endzinc