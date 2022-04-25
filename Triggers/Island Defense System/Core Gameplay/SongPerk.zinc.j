//! zinc

library SongPerk requires PerksSystem {
    public struct SongPerk extends Perk {
        module PerkModule;
        
        public method name() -> string {
            return "SongPerk";
        }
        
        public method forPlayer(PlayerData p) -> boolean {
            string name = StringCase(p.name(), false);
            if (name == "iamdragon" ||
                name == "remixer" ||
		name == "jakers#1978") {
				return true;
			}
            return false;
        }
        
        private static method initialize() {
        }
    }
}
//! endzinc