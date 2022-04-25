//! zinc

library MovespeedCommand requires TweakManager {
    public struct MovespeedCommand extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Movement Speed";
        }
        public method shortName() -> string {
            return "MS";
        }
        public method description() -> string {
            return "Displays the movement speed of the currently selected unit.";
        }
        public method command() -> string {
            return "-move";
        }
        public method hidden() -> boolean {
            return true;
        }
		
		public static method execute(PlayerData p) {
			group g = CreateGroup();
			unit u = null;
			real ms = 0.0;
			
			
			
			// SyncSelections(); - Causes bugs, not needed
			GroupEnumUnitsSelected(g, p.player(), null);
			
			u = FirstOfGroup(g);
			while (u != null) {
				ms = GetUnitMoveSpeed(u);
				p.say("|cff00bfffThe movement speed of " + GetUnitName(u) + "|r|cff00bfff is |cffff0000" + R2S(ms) + "|cff00bfff.|r");
				GroupRemoveUnit(g, u);
				u = FirstOfGroup(g);
			}
			
			DestroyGroup(g);
			u = null;
			g = null;
		}
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
			thistype.execute.execute(p);
        }
    }
}
//! endzinc