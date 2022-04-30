//! zinc
library RecommendedItems requires UnitSpawner, Unit, TitanUnit, Races {
	private constant boolean bDebug = true;
	private integer iItemInShop[];
	private integer iItemInSlot[];
	private integer iSlot;
	
	private function fGetItemName(integer i) -> string {
		item iItemTemporary = CreateItem(i, 0, 0);
		string sName = GetItemName(iItemTemporary);
		RemoveItem(iItemTemporary);
		return sName;
	}
	
	private function getItemCostFromId(integer i) -> integer {
		item it = CreateItem(i, 0, 0);
		integer c = GetItemLevel(it);
		RemoveItem(it);
		it = null;
		return c;
	}
	
	private function fClearShop() {
		integer i = 0;
		item iItemTemporary;
		iSlot = 0;
		while(i < 12) {
			if(iItemInShop[i] != 0) RemoveItemFromStock(UnitManager.RECOMMENDED_ITEMS, iItemInShop[i]);
			if(bDebug) {
				if(bDebug) BJDebugMsg("|cff00cc40Removing |r" + fGetItemName(iItemInShop[i]) + "|cff00cc40 from selection.|r");
			}
			iItemInShop[i] = 0;
			i += 1;
		}
		return;
	}
	
	private function fGetTitanItems(unit uTitan) {
		unit uGoldMound = getGoldMine();
		integer i = 0;
		item iItem[];
		if(bDebug) BJDebugMsg("|cff00cc40Getting Titan items.");
		while(i <= 11) {	// Slots 0-5 are Titan. 
			if(i <= 5) {
				iItem[i] = UnitItemInSlot(uTitan, i);
				iItemInSlot[i] = GetItemTypeId(iItem[i]);
			} else if(i <= 11) {	// Slots 6-11 are Gold Mound.
				iItem[i] = UnitItemInSlot(uGoldMound, i);
				iItemInSlot[i] = GetItemTypeId(iItem[i]);
			}
			i += 1;
		}
	}
	
	//Checks if a certain item (by itemtype ID) or a component is being held by the Titan or the Gold Mound.
	private function fIsOwned(integer iItemType) -> boolean {
		integer i = 0;
		while(i <= 11) {
			if(iItemInSlot[i] == iItemType) return true;
			i += 1;
		}
		return false;
	}
	
	//Adds an item to the shop and indexes the item to a slot.
	private function fAddItemToSlot(integer iItemType) -> nothing {
		item iItemTemporary;
		if(iItemInShop[iSlot] == 0 && iSlot < 12) {
			iItemInShop[iSlot] = iItemType;
			AddItemToStock(UnitManager.RECOMMENDED_ITEMS, iItemType, 1, iSlot);
			if(bDebug) BJDebugMsg("|cff00cc40Adding |r" + fGetItemName(iItemType) + "|cff00cc40 to the selection.|r");
			iSlot += 1;
			return;
		} else {
			BJDebugMsg("|cffbb2020Error: Attaching an item to a faulty slot.");
			while(iSlot < 11 && iItemInShop[iSlot] != 0) {
				iSlot += 1;
			}
			if(iItemInShop[iSlot] == 0) {
				BJDebugMsg("|cff20bb20Solved: Found a viable slot.");
				iItemInShop[iSlot] = iItemType;
				//AddItemToStock(UnitManager.RECOMMENDED_ITEMS, iItemType, 1, iSlot);
				if(bDebug) BJDebugMsg("|cff00cc40Adding |r" + fGetItemName(iItemType) + "|cff00cc40 to the selection.|r");
				iSlot += 1;
				return;
			} else {
				BJDebugMsg("|cffbb2020Error: Failed to find a slot - aborting.");
				return;
			}
		}
	}
	
	private function fGetRecommendations(string sRace, integer iGold, integer iLevel, PlayerData pData, unit uTitan) {
		//Figures out what items the Titan and Gold Mound have available (autobuy accounts for those two).
		fGetTitanItems(uTitan);
		//If Titan is level 2 and has little gold, recommend selling the Ankh of Reincarnation.
		if(iLevel == 2 && iGold < 300 && fIsOwned('I00P')) fAddItemToSlot('I038');
		if(iLevel <= 3 && iGold > getItemCostFromId('I016') && !fIsOwned('I016')) fAddItemToSlot('I016');	//Pearl of Vision
			   if(sRace == "Arborius") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Breezerious") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Bubonicus") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Demonicus") {
			if(iLevel <= 4 && iGold > getItemCostFromId('I06Z') && !fIsOwned('I06Z')) fAddItemToSlot('I06Z');	//Runic Axe
		} else if(sRace == "Fossurious") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Glacious") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Granitacles") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Lucidious") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Moltenious") {
			if(iLevel <= 3 && iGold > getItemCostFromId('I05O') && !fIsOwned('I05O')) fAddItemToSlot('I05O');		//Chimaera Pendant
			if(iLevel <= 3 && iGold > getItemCostFromId('I00E') && !fIsOwned('I00E')) fAddItemToSlot('I00E');		//Webbed Feet
			if((iLevel > 3 && iLevel <= 6) && !fIsOwned('I04Z')) fAddItemToSlot('I054');							//Gauntlets of Embers
			if((iLevel > 3 && iLevel <= 6) && fIsOwned('I04Z') && !fIsOwned('I01P')) fAddItemToSlot('I01R');		//Titanic Trident after Gauntlets of Embers.
			if((iLevel > 4 && iLevel <= 7) && fIsOwned('I04Z') && !fIsOwned('I06G')) fAddItemToSlot('I00E');		//Kissing Chimaeras: After Gauntlets of Embers.
			if((iLevel > 4) && fIsOwned('I04Z') && fIsOwned('I06L') && !fIsOwned('I08N')) fAddItemToSlot('I08M');	//Spear of Fervor, if Titan has both.
					
		} else if(sRace == "Noxious") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		} else if(sRace == "Voltron") {
			pData.say("|cff00cc40Recommended items do not exist for this Titan.");
		}
	}
	
	private function UpdateItemSelection() {
		unit uTitan;
		player pPlayer = GetOwningPlayer(UnitManager.RECOMMENDED_ITEMS);
		string sRace;
		integer iLevel;
		integer iGold = GetPlayerState(pPlayer, PLAYER_STATE_RESOURCE_GOLD);
		PlayerData pData = 0;
		Unit uData = 0;
		pData = PlayerData.get(pPlayer);		//Associates the pData with the correct player.
		sRace = pData.race().toString();		//Fetches the race of the player as a string (such as "Moltenious").
		uData = pData.getUnit();				//Associates the uData with the correct player's unit.
		uTitan = uData.unit();					//Based on the player's uData, creates a reference to the correct unit (the Titan).
		if(sRace != "_NULL") {
			fClearShop();
			iLevel = GetHeroLevel(uTitan);
			fGetRecommendations(sRace, iGold, iLevel, pData, uTitan);
		}
		uTitan = null;
		pPlayer = null;
		sRace = null;
	}

	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterTimerEvent(t, 2.5, true);
		TriggerAddCondition(t, Condition(function() -> boolean {
			UpdateItemSelection();
		return false;
		}));
		t = null;
	}
}
//! endzinc