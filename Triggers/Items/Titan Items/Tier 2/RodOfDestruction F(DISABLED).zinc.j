//! zinc
library RodOfDestruction requires IsUnitWorker {
    //Item ID for Rod of Destruction
    private constant integer ITEM_ID = 'I06X';
    //Ability ID of the item ability
    private constant integer ABILITY_ID = 'A0HH';
    //Damage to deal around units (should be the same as the spell according to description)
    private constant real AOE_DAMAGE = 100;
    //AOE around the main unit
    private constant real AOE = 200;
    //Whether the damage is doubled against harvesters or not
    private constant boolean HARVEST_DOUBLE = true;
    //Attack type
    private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL;
    //Damage type
    private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL;
    //Weapon type (lol)
    private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS;
    //Lightning Code
    private constant string L_CODE = "AFOD";
    //Effect on damage
    private constant string DMG_EFFECT = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl";
    
    function TargetFilter() -> boolean {
        return IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) &&
                IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false && GetFilterUnit() != GetSpellTargetUnit();
    }
    
    function onCast() {
        unit caster = GetTriggerUnit();
        unit target = GetSpellTargetUnit();
        real uX = GetUnitX(target); //Target unit X & Y
        real uY = GetUnitY(target);
        real tX;
        real tY;
        lightning tempLightning;
        group g = CreateGroup();
        unit u;
        
        GroupEnumUnitsInRange(g, uX, uY, AOE, Condition(function TargetFilter));
        u = FirstOfGroup(g);
        while(u != null) {
            tX = GetUnitX(u);
            tY = GetUnitY(u);
            //Add lightning effect (hopefully it exists even though we destroy it fast)
            tempLightning = AddLightning(L_CODE, false, uX, uY, tX, tY);
            DestroyEffect(AddSpecialEffectTarget(DMG_EFFECT, u, "origin"));
            //Damage the unit (double if it's a harvester)
            if(IsUnitWorker(u)) {
                UnitDamageTarget(caster, u, AOE_DAMAGE * 2, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
            } else {
                UnitDamageTarget(caster, u, AOE_DAMAGE, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE);
            }
            GroupRemoveUnit(g, u);
            u = null;
            u = FirstOfGroup(g);
            DestroyLightning(tempLightning);
            tempLightning = null;
        }
        DestroyGroup(g);
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetTriggerUnit();
            if(GetSpellAbilityId() == ABILITY_ID && UnitHasItemById(u, ITEM_ID)) {
                onCast();
            }
            u = null;
            return false;
        });
        t=null;
    }
	
}
//! endzinc