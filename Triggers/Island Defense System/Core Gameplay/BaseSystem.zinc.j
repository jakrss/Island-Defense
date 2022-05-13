//! zinc
library BaseSystem requires GT, BUM, ABMA, IsUnitTower, IsUnitWall {
    public struct BaseSystem {
        private static constant integer totalBase = 32; //total amount of base arrays on the map

        private static constant integer baseTowers = 10; //how many towers until it is considered a base
        private static constant integer baseWalls = 5; //how many walls until it is considered a base

        public rect BaseRects[100][10]; //array containing rectangle regions for each base
        public region Base[100]; //base region array containing each rect from BaseRects
        public boolean baseDetected[100]; //boolean if a base has existed at this location before
        public boolean baseDestroyed[100]; //boolean if the detected base has already been destroyed once

        public method IsUnitInBase(unit uBase, integer baseID) -> boolean {
            if (IsUnitInRegion(thistype.Base[baseID], uBase)) return true;
            return false; //unit not found in base
        }

        public method IsItABase(integer baseID) -> boolean {
            group gBase;
            unit uBase;
            integer countTower = 0;
            integer countWall = 0;

            gBase = thistype.GroupUnitsInBase(baseID);

            if(CountUnitsInGroup(gBase) > 0) { //there are units in the base region, maybe it is a base?
                uBase = FirstOfGroup(gBase);
                while (uBase != null) {
                    if (IsUnitTower(uBase)) countTower =+ 1;
                    if (IsUnitWall(uBase)) countWall =+ 1;
                    GroupRemoveUnit(gBase, uBase);
                    uBase = FirstOfGroup(gBase);
                }
            }

            if ((countWall >= thistype.baseWalls) && (countTower >= thistype.baseTowers)) {
                thistype.baseDetected[baseID] = true;
                GroupClear(gBase);
                DestroyGroup(gBase);
                gBase = null;
                uBase = null;
                return true;
            }

            GroupClear(gBase);
            DestroyGroup(gBase);
            gBase = null;
            uBase = null;
            return false;
        }

        public method GroupUnitsInBase(integer baseID) -> group { //GroupEnumUnitsInRegion
            group gBase = CreateGroup();
            for (0<=rects<=10) { //Only ever a max of 10rects inside a base array
                if (thistype.BaseRects[baseID][rects] == null) break; //break if the next instance of a rect is empty
                GroupEnumUnitsInRect(gBase, thistype.BaseRects[baseID][rects], null);
            }
            return gBase;
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

    private function SetupBaseRects() {
        //Defensible bases
            //Aztec
            BaseSystem.BaseRects[0][0] = gg_rct_Base00;
            //Bay
            BaseSystem.BaseRects[0][0] = gg_rct_Base00;
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
    
    private function SetupBaseRegions() {
        integer baseID, rects = 0;
        for(0<=baseID<=BaseSystem.totalBase) {
            Base[baseID] = CreateRegion();
            BaseSystem.baseDetected[baseID]] = false;
            BaseSystem.baseDestroyed[baseID]] = false;

            for (0<=rects<=10) { //Only ever a max of 10rects inside a base array
                if (BaseSystem.BaseRects[baseID][rects] == null) break; //break if the next instance of a rect is empty
                RegionAddRect(BaseSystem.Base[baseID], BaseSystem.BaseRects[baseID][rects]);
            }
        }
    }
    
    private function onInit(){
        SetupBaseRects();
        SetupBaseRegions();
    }
}

//! endzinc