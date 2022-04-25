//! zinc
library HCLSystem requires IslandDefenseSystem, HCL, StringLib {
	// TODOTODO
	public struct HCLSystem {
	
		public static method setup(){
			string commands = HCL_GetCommandString();
			
			if (StringIndexOf(commands, "m", false) != STRING_INDEX_NONE){
				GameSettings.setBool("MMD_EXTRAS_ENABLED", true);
				Game.say("|cff00bfffMMD Extras have been enabled.|r");
			}
			if (StringIndexOf(commands, "d", false) != STRING_INDEX_NONE){
				GameSettings.setBool("FORCE_DEBUG_MODE", true);
				Game.say("|cff00bfffDebug mode has been enabled.|r");
			}
			if (StringIndexOf(commands, "a", false) != STRING_INDEX_NONE){
				GameSettings.setBool("PICKMODE_VOTE_ENABLED", false);
				GameSettings.setStr("PICKMODE_DEFAULT", "AR");
				Game.say("|cff00bfffAR will be chosen by default.|r");
			}
			if (StringIndexOf(commands, "b", false) != STRING_INDEX_NONE){
				GameSettings.setBool("PICKMODE_VOTE_ENABLED", false);
				GameSettings.setStr("PICKMODE_DEFAULT", "BR");
				Game.say("|cff00bfffBR will be chosen by default.|r");
			}
			if (StringIndexOf(commands, "p", false) != STRING_INDEX_NONE){
				GameSettings.setBool("PICKMODE_VOTE_ENABLED", false);
				GameSettings.setStr("PICKMODE_DEFAULT", "AP");
				Game.say("|cff00bfffAP will be chosen by default.|r");
			}
			if (StringIndexOf(commands, "e", false) != STRING_INDEX_NONE){
				GameSettings.setBool("TITAN_EXP_GLOBAL_FACTOR_DOUBLED", true);
				Game.say("|cff00bfffEXP will be enabled by default.|r");
			}
			if (StringIndexOf(commands, "f", false) != STRING_INDEX_NONE){
				GameSettings.setBool("TITAN_EXP_REDUCTION_ENABLED", false);
				Game.say("|cff00bfffFR will be disabled by default.|r");
			}
			if (StringIndexOf(commands, "g", false) != STRING_INDEX_NONE){
				GameSettings.setStr("TWEAK_GC", "on");
				Game.say("|cff00bfffGC will be enabled by default.|r");
			}
			if (StringIndexOf(commands, "s", false) != STRING_INDEX_NONE){
				GameSettings.setBool("MINION_SPAWN_ALLOW_GRACE", false);
				Game.say("|cff00bfffMinion spawning will not have a grace time.|r");
			}
			if (StringIndexOf(commands, "o", false) != STRING_INDEX_NONE){
				GameSettings.setBool("MINION_FORCE_OBS", true);
				Game.say("|cff00bfffMinions will be forced to observer automatically.|r");
			}
			if (StringIndexOf(commands, "t", false) != STRING_INDEX_NONE){
				GameSettings.setStr ("GAME_MODE", "IDT");
				Game.say("|cff00bfffIsland Defense Tag Mode has been activated.|r");
			}
		}
	}
}
//! endzinc