//! zinc
library UpgradeSystem {
    private integer numUpgrades[];
    private hashtable playerUpgrades = InitHashtable();
    
    public function ClearUpgrades(integer playerId) {
        FlushChildHashtable(playerUpgrades, playerId);
    }
    
    public function SwapUpgrades(integer playerOne, integer playerTwo) {
        integer z,x,tempInt = 0;
        //Gotta add one so Player 1 doesn't stay 0
        //Player One will store all the upgrades in 10
        //Player One will store all the upgrade levels in 11
        integer oneStorage = (playerOne + 1) * 10;
        integer twoStorage = (playerTwo + 1) * 10;
        integer upgradeLevel;
        integer techId;
        //First we save each players, then we transfer them
		//Runs through all researches done by playerOne and stores their IDs and levels.
        for(0<=z<numUpgrades[playerOne]) {
            techId = LoadInteger(playerUpgrades, playerOne, z);
            upgradeLevel = GetPlayerTechCount(Player(playerOne), techId, true);
            SaveInteger(playerUpgrades, oneStorage, z, techId);
            SaveInteger(playerUpgrades, oneStorage + 1, z, upgradeLevel);
            BlzDecPlayerTechResearched(Player(playerOne), techId, upgradeLevel);
        }
        ClearUpgrades(playerOne);
        z = 0;
        for(0<=z<numUpgrades[playerTwo]) {
            techId = LoadInteger(playerUpgrades, playerTwo, z);
            upgradeLevel = GetPlayerTechCount(Player(playerTwo), techId, true);
            SaveInteger(playerUpgrades, twoStorage, z, techId);
            SaveInteger(playerUpgrades, twoStorage + 1, z, upgradeLevel);
            BlzDecPlayerTechResearched(Player(playerTwo), techId, upgradeLevel);
        }
        ClearUpgrades(playerTwo);
        z=0;
        for(0<=z<numUpgrades[playerOne]) {
            techId = LoadInteger(playerUpgrades, oneStorage, z);
            upgradeLevel = LoadInteger(playerUpgrades, oneStorage + 1, z);
            SetPlayerTechResearched(Player(playerTwo), techId, upgradeLevel);
            SaveInteger(playerUpgrades, playerTwo, z, techId);
        }
        z=0;
        for(0<=z<numUpgrades[playerTwo]) {
            techId = LoadInteger(playerUpgrades, twoStorage, z);
            upgradeLevel = LoadInteger(playerUpgrades, twoStorage + 1, z);
            SetPlayerTechResearched(Player(playerOne), techId, upgradeLevel);
            SaveInteger(playerUpgrades, playerOne, z, techId);	//Changes "playerTwo" to "PlayerOne" on 4.1.0p
        }
        tempInt = numUpgrades[playerOne];
        numUpgrades[playerOne] = numUpgrades[playerTwo];
        numUpgrades[playerTwo] = tempInt;
        ClearUpgrades(oneStorage);
        ClearUpgrades(oneStorage + 1);
        ClearUpgrades(twoStorage);
        ClearUpgrades(twoStorage + 1);
    }
    
    public function PlayerHasUpgrade(integer upgradeId, integer playerId) -> boolean {
        integer i=0;
        integer loadedVal;
        for(0<=i<numUpgrades[playerId]) {
            loadedVal = LoadInteger(playerUpgrades, playerId, i);
            if(loadedVal == upgradeId) return true;
        }
        return false;
    }
    
    public function AddUpgrade(integer upgradeId, integer playerId) {
        SaveInteger(playerUpgrades, playerId, numUpgrades[playerId], upgradeId);
        numUpgrades[playerId] = numUpgrades[playerId] + 1;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        integer i=0;
        for(0 <= i <= 15) {
            numUpgrades[i] = 0;
        }
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        TriggerAddCondition(t, function() -> boolean {
            integer researchId = GetResearched();
            integer i=0;
            integer playerNum = GetPlayerId(GetOwningPlayer(GetTriggerUnit()));
            if(numUpgrades[playerNum] == 0) {
                AddUpgrade(researchId, playerNum);
            } else if(!PlayerHasUpgrade(researchId, playerNum)) {
                AddUpgrade(researchId, playerNum);
            }
            return false;
        });
    }
}
//! endzinc