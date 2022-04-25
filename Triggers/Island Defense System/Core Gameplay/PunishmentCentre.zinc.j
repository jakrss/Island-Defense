//! zinc

library PunishmentCentre requires UnitSpawner, AIDS, DestroyEffectTimed {    
    public struct PunishmentCentre {
        private static integer abilityIds[];
        public static method initialize(){
            thistype.abilityIds[0]      =   '&UP0';  // Red
            thistype.abilityIds[1]      =   '&UP1';  // Blue
            thistype.abilityIds[2]      =   '&UP2';  // Teal
            thistype.abilityIds[3]      =   '&UP3';  // Purple
            thistype.abilityIds[4]      =   '&UP4';  // Yellow
            thistype.abilityIds[5]      =   '&UP5';  // Orange
            thistype.abilityIds[6]      =   '&UP6';  // Green
            thistype.abilityIds[7]      =   '&UP7';  // Pink
            thistype.abilityIds[8]      =   '&UP8';  // Grey
            thistype.abilityIds[9]      =   '&UP9';  // Lightblue
            thistype.abilityIds[10]     =   '&UPA';
        }
        public static method update(){
            unit u = UnitManager.TITAN_PUNISH_CAGE;
            PlayerData titan = PlayerData.get(GetOwningPlayer(u));
            integer i = 0;
            PlayerData p = 0;
            PlayerDataArray list = 0;
            
            // Clear
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list[i];
                //UnitRemoveAbility(u, thistype.abilityIds[p.id()]);
                SetPlayerAbilityAvailable(titan.player(), thistype.abilityIds[p.id()], false);
            }
            list.destroy();
            
            // Add
            list = PlayerData.withClass(PlayerData.CLASS_MINION);
            for (0 <= i < list.size()){
                p = list[i];
                if (!p.isLeaving() && !p.hasLeft()){
                    //UnitAddAbility(u, thistype.abilityIds[p.id()]);
                    SetPlayerAbilityAvailable(titan.player(), thistype.abilityIds[p.id()], true);
                }
            }
            list.destroy();
            u = null;
        }
        
        public static method getIdFromAbility(integer s) -> integer {
            integer i = 0;
            for (0 <= i < 11){
                if (s == thistype.abilityIds[i]){
                    return i;
                }
            }
            return -1;
        }
        
        public static method setAutoPunish(boolean b){
            PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_TITAN);
            PlayerData p = 0;
            integer i = 0;
            if (b){
                GameSettings.setBool("TITAN_AUTOPUNISH", true);
                for (0 <= i < list.size()){
                    p = list.at(i);
                    p.say("The |cffff0000Auto Punish|r feature is now |cffff0000ON|r.");
                }
                UnitRemoveAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU0');
                UnitAddAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU1');
            }
            else {
                GameSettings.setBool("TITAN_AUTOPUNISH", false);
                for (0 <= i < list.size()){
                    p = list.at(i);
                    p.say("The |cffff0000Auto Punish|r feature is now |cffff0000OFF|r.");
                }
                UnitAddAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU0');
                UnitRemoveAbility(UnitManager.TITAN_PUNISH_CAGE, '&PU1');
            }
            list.destroy();
        }
        
        public static method onInit(){
            // Auto Punish
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t ,EVENT_PLAYER_UNIT_ISSUED_ORDER);
            TriggerAddCondition(t, Condition(function() -> boolean {
                return UnitManager.TITAN_PUNISH_CAGE == GetOrderedUnit();
            }));
            TriggerAddAction(t, function(){
                integer i = GetIssuedOrderId();
                player p = GetTriggerPlayer();
                unit u = GetOrderedUnit();
                if (i == OrderId("faeriefireon")){
                    thistype.setAutoPunish(true);
                }
                else if (i == OrderId("faeriefireoff")){
                    thistype.setAutoPunish(false);
                }
                p = null;
                u = null;
            });
            // Punishment
            t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST);
            TriggerAddCondition(t, Condition(function() -> boolean {
                return UnitManager.TITAN_PUNISH_CAGE == GetTriggerUnit();
            }));
            TriggerAddAction(t, function(){
                integer s = GetSpellAbilityId();
                unit t = GetSpellTargetUnit();
                player p = GetOwningPlayer(UnitManager.TITAN_PUNISH_CAGE);
                integer i = 0;

                // Punish (or Alternate)
                if (s == '&PUN' || s == '&PU2'){
                    //if (IsUnitType(t, UNIT_TYPE_SUMMONED)) {
                    //    PlayerData.get(p).say("|cffff0000You are unable to punish summoned units.|r");
                    //}
                    //else {
						if (GetOwningPlayer(t) != p) {
							SetUnitOwner(t, p, true);
						}
                        
                        UnitRemoveBuffs(t, false, true);
                        UnitRemoveAbility(t, 'B01V'); // Tauren Enfeeble
						
						 // Minion Grace Attack Disabler
						if (GetUnitAbilityLevel(t, '&noa') > 0) {
							UnitRemoveAbility(t, '&noa');
							SetUnitInvulnerable(t, false);
						}
                    //}
                }
                // Unpunish (maybe)
                else {
                    i = thistype.getIdFromAbility(s);
                    if (i != -1 && PlayerData[i] != 0 && PlayerData[i].class() == PlayerData.CLASS_MINION){
                        IssueImmediateOrder(t, "stop");
                        SetUnitOwner(t, Player(i), true);
                    }
                }
                t = null;
                p = null;
            });
            // Teleport is in seperate trigger.
            t = null;
        }
    }
   
}

//! endzinc