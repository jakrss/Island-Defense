//! zinc
library EnergyRod requires ItemExtras, IsUnitBuilder, BUM {
    //Item ID for Energy Rod & Rod of Destruction & Crown of Depths
    private constant integer EnergyRod = 'I01E';
	private constant integer RodOfDestruction = 'I06X';
    private constant integer CrownOfDepths = 'I07W';
    //Ability ID of the item ability
    private constant integer ABILITY_ID = 'A04T';	//Active Ability
	private constant integer Crown_Ability = 'A0HH';	//Crown of Depths Ability
    //Damage to deal around units (should be the same as the spell according to description)
    private constant real AOE_DAMAGE = 100;
    //AOE around the main unit
    private constant real AOE = 250;
    //Attack type
    private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC;
    //Damage type
    private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL;
    //Weapon type (lol)
    private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS;
    //Lightning Code
    private constant string L_CODE = "AFOD";
    //Effect on damage
    private constant string DMG_EFFECT = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl";
    
	//We want to know which units there are that we want to damage.
    function TargetFilter() -> boolean {
        return 
			IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) 	&&
            IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false 				&& 
			IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) == false		&&
			UnitAlive(GetFilterUnit()) == true ;
		}
		
	//A cast has been detected. We know which item is being used.
    function onCast(real AreaDamage, real PrimarySpecial) {
        unit caster = GetTriggerUnit();
        unit target = GetSpellTargetUnit();
        real uX = GetUnitX(target); //Target unit X
        real uY = GetUnitY(target); //Target unit Y
        real tX;
        real tY;
        lightning tempLightning;
        group g = CreateGroup();
        unit u;
        
		//Let's form a group of viable targets around the primary target.
        GroupEnumUnitsInRange(g, uX, uY, AOE, Condition(function TargetFilter));
        u = FirstOfGroup(g);
        while(u != null) {
            tX = GetUnitX(u);
            tY = GetUnitY(u);
            //Add lightning effect (hopefully it exists even though we destroy it fast)
            tempLightning = AddLightning(L_CODE, false, uX, uY, tX, tY);
            DestroyEffect(AddSpecialEffectTarget(DMG_EFFECT, u, "origin"));
            //Damage units in the AoE group
			if(IsUnitBuilder(u)) {
                UnitDamageTarget(caster, u, AreaDamage / 2, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
            } else {	//The target is not a builder, so deal full damage.
				if(IsUnitTitanHunter(u) && PrimarySpecial > 0.00 ) { //Unless it is a Titan Hunter and we deal special damage to it.
                UnitDamageTarget(caster, u, (AreaDamage + (PrimarySpecial * getMaxHealth(u))), false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
				} else {	//The target shouldn't take extra damage for being a Titan Hunter.
				UnitDamageTarget(caster, u, AreaDamage, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
            }}
            GroupRemoveUnit(g, u);
            u = null;
            u = FirstOfGroup(g);
            DestroyLightning(tempLightning);
            tempLightning = null;
        }
        DestroyGroup(g);
		//Let's heal the primary target if it's allied.
		if(IsUnitAlly(target, GetOwningPlayer(caster))) {
			//BJDebugMsg("This target is an ally, so you must have Crown of Depths!");
			addHealth(target, (300 + 0.10 * getMaxMana(caster)));
		}
		caster = null;
		target = null;
    }
	
	//When an item is used, we'd like to know which is the best one the unit has.
    private function onInit() {
		trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
			real AreaDamage;
			real PrimarySpecial;
			//Check which item the unit is carrying, but only check for the best ones.
            if(GetSpellAbilityId() == Crown_Ability && UnitHasItemById(u, CrownOfDepths)) {
				AreaDamage = 200;
				PrimarySpecial = 0.35;
				onCast(AreaDamage, PrimarySpecial);
				//BJDebugMsg("Best item = CrownOfDepths");
            } 
			else {
				if(GetSpellAbilityId() == ABILITY_ID && UnitHasItemById(u, RodOfDestruction)) {
					AreaDamage = 150;
					PrimarySpecial = 0.25;
					onCast(AreaDamage, PrimarySpecial);
					//BJDebugMsg("Best item = RodOfDestruction");
				} 	else {
						if(GetSpellAbilityId() == ABILITY_ID && UnitHasItemById(u, EnergyRod)) {
							AreaDamage = 100;
							PrimarySpecial = 0.00;
							onCast(AreaDamage, PrimarySpecial);
					//BJDebugMsg("Best item = Energy Rod");
						}
					}
			}
            u = null;
            return false;
        });
        t=null;
    }
	
}
//! endzinc