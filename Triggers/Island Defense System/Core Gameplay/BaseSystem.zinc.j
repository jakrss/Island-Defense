//! zinc
library BaseSystem requires GT, BUM, ABMA {
    public struct BaseSystem {
        public static hashtable hCocMin = null;
        public rect Base[100][10];

        public method IsUnitInBase(unit u, integer baseID) -> boolean {
            for (0<=rects<=10) { //Only ever a max of 10rects inside a base array
                if (BaseSystem.Base[baseID][rects] == null) break; //break if the next instance of a rect is empty
                if (IsUnitInRegion(BaseSystem.Base[baseID][rects])) {
                    return true;
                }
            }
            return false; //unit not found in base
        }

        private method GetBaseName(integer baseID) -> string {
            //Defensible bases
            if (baseID == 0)    return "Aztec";
            if (baseID == 1)    return "Bay";
            if (baseID == 2)    return "Broken Fountain";
            if (baseID == 3)    return "Claw";
            if (baseID == 4)    return "Heaven";
            if (baseID == 5)    return "Hermit";
            if (baseID == 6)    return "Hideout";
            if (baseID == 7)    return "Ovaries";
            if (baseID == 8)    return "Paradise";
            if (baseID == 9)    return "Poseidon";
            if (baseID == 10)   return "Retreat";
            if (baseID == 11)   return "River";
            if (baseID == 12)   return "Sky";
            if (baseID == 13)   return "Stronghold";
            if (baseID == 14)   return "Tomb";
            if (baseID == 15)   return "Tommy Gun";
            if (baseID == 16)   return "Top of the World";
            if (baseID == 17)   return "Waterfall";

            //Lumber bases
            if (baseID == 0)    return "Blah";
            if (baseID == 0)    return "Blah";

            //Memes - why are you basing here
            if (baseID == 0)    return "Blah";
            if (baseID == 0)    return "Blah";

            return "Unknown Base";
        }
	}

    private function SetupBases() {
        //Defensible bases
            //Aztec
            BaseSystem.Base[0][0] = gg_rct_Base00;
            //Bay
            BaseSystem.Base[0][0] = gg_rct_Base00;
            //Broken Fountain
            //Claw
            //Heaven
            //Hermit
            //Hideout
            //Ovaries
            //Paradise
            //Poseidon
            //Retreat
            //River
            //Sky
            //Stronghold
            //Tomb
            //Tommy Gun
            //Top of the World
            //Waterfall

        //Lumber bases
            //Name here

        //Memes
            //Name here
        
    }
    
    private function onInit(){
        SetupBases();
    }
}

//! endzinc