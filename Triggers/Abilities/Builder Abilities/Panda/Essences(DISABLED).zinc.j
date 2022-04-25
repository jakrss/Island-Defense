//! zinc
library PandaEssences requires PandaTransformations {
    //ID's of the units
    private constant integer PS_ID = 'h04D';
    private constant integer PE_ID = 'h04O';
    private constant integer PF_ID = 'h02N';
    
    //Essence unit ID's
    private constant integer PS_ESSENCE = 'A003';
    private constant integer PE_ESSENCE = 'A004';
    private constant integer PF_ESSENCE = 'A005';
    
    private constant integer P_WALL = 'h02I';
    private constant integer PE_WALL = 'h03E';
    
    private constant integer TECH_ID = 'R03C';
    
    //AOE of the Earth Panda's eseence thing
    private constant real PE_AOE = 1500;
    //Duration of the essences
    private constant real DURATION = 20;
    
    private hashtable essenceTable = InitHashtable();
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            //Unit casting the spell
            unit u = GetTriggerUnit();
            unit essence;
            integer uid = getPandaFormInt(u);
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            unit tu = GetSpellTargetUnit();
            
            if(tu != null) {
                x = GetUnitX(tu);
                y = GetUnitY(tu);
                tu = null;
            }
            BJDebugMsg("uID == " + I2S(uid));
            if(uid == 1 && GetPlayerTechCount(GetOwningPlayer(u), TECH_ID, false) > 0) {
                BJDebugMsg("essence created");
                essence = CreateUnit(GetOwningPlayer(u), PS_ESSENCE, x, y, bj_UNIT_FACING);
                UnitApplyTimedLife(essence, 'BTLF', DURATION);
                essence = null;
            }
            u = null;
            return false;
        });
        t = null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            //Unit casting the spell
            unit u = GetEventDamageSource();
            unit t = GetTriggerUnit();
            unit essence;
            integer uid = getPandaFormInt(u);
            integer uit = getPandaFormInt(t);
            real randReal = GetRandomReal(20, 140);
            if(GetPlayerTechCount(GetOwningPlayer(u), TECH_ID, false) > 0 && 
                (IsUnitEnemy(u, GetOwningPlayer(t)) || IsUnitEnemy(t, GetOwningPlayer(u)))) {
                if(uid == 3) {
                    essence = CreateUnit(GetOwningPlayer(u), PF_ESSENCE, GetUnitX(t) + randReal, GetUnitY(t) + randReal, bj_UNIT_FACING);
                    UnitApplyTimedLife(essence, 'BTLF', DURATION);
                    essence = null;
                } else if(uit == 2 || GetUnitTypeId(t) == P_WALL || GetUnitTypeId(t) == PE_WALL) {
                    essence = CreateUnit(GetOwningPlayer(t), PE_ESSENCE, GetUnitX(t) + randReal, GetUnitY(t) + randReal, bj_UNIT_FACING);
                    UnitApplyTimedLife(essence, 'BTLF', DURATION);
                    essence = null;
                }
                    
            }
            u = null;
            t = null;
            return false;
        });
        t = null;
    }

}
//! endzinc