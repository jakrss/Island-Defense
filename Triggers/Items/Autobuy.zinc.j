//! zinc
library ShopSystemAutoBuy requires ItemExtras, BUM, UnitSpawner {
    private constant integer iSwitchPage = 'I051';		//Switch Page ID
	private constant boolean SendDebug = false;	
	private constant integer ConsumableMin = 150;
	private constant integer ConsumableCount = 7;
	private constant integer Tier2MinCount = 200;
	private constant integer Tier2ItemCount  = 20;
	private constant integer Tier3MinCount = 300;
	private constant integer Tier3ItemCount = 17;
	private constant boolean RequireDoubleClick = false;
	private boolean AnkhCrafted = false;
	private integer grade;
	private integer currentSum;
	private integer com[];
	private integer componentFactor;
	private integer recipe[];
	private item tempItem[];
	private integer chargeCount[];
	private integer tempItemSlot[];
	private unit tempItemHolder[];
	private boolean Searching4SecondaryComponents;
	private hashtable RecipeHash = InitHashtable();
	
	private function getItemCostFromId(integer i) -> integer {
		item it = CreateItem(i, 0, 0);
		integer c = GetItemLevel(it);
		RemoveItem(it);
		it = null;
		return c;
	}
	
	private function getItemNameFromId(integer i) -> string {
		item it = CreateItem(i, 0, 0);
		string s = GetItemName(it);
		RemoveItem(it);
		it = null;
		return s;
	}
	
	private function isPreviouslyUsed(item newItem) -> boolean {
		return false;
	}
	
	private function matchComponent2Recipe(integer curComp) -> integer {
		integer v = Tier2MinCount;
		while(curComp != com[v] && v < Tier2MinCount + Tier2ItemCount) {
			v += 1;
		}
		return recipe[v];
	}	
	
	private function setComponents(integer ax, integer bx, integer cx, integer dx, integer ex, integer fx, integer gx) {
		if(!Searching4SecondaryComponents) {
			//Assign the given item codes to com[1-6], the goal item into com[7].
			if(ax != 0) com[1] = com[ax];
			if(bx != 0) com[2] = com[bx];
			if(cx != 0) com[3] = com[cx];
			if(dx != 0) com[4] = com[dx];
			if(ex != 0) com[5] = com[ex];
			if(fx != 0) com[6] = com[fx];
			if(gx != 0) com[7] = com[gx];
		} else {
			//If we are trying to combine a TIER III item, we might want to look for sub-components:
			if(ax != 0) com[1+10*componentFactor] = com[ax];
			if(bx != 0) com[2+10*componentFactor] = com[bx];
			if(cx != 0) com[3+10*componentFactor] = com[cx];
			if(dx != 0) com[4+10*componentFactor] = com[dx];
			if(ex != 0) com[5+10*componentFactor] = com[ex];
			if(fx != 0) com[6+10*componentFactor] = com[fx];
			if(gx != 0) com[7+10*componentFactor] = com[gx];
		}
	}	
	
	//Searches through pre-defined item arrays, matching the bought item with correct components and result item.
	//																																
	//			THIS DEFINES WHICH COMPONENTS A RECIPE REQUIRES																
	//																																
	private function matchRecipe(integer i) {
		integer v;
		v = Tier2MinCount;
		//Loop until we match the recipe (i) with the indexed recipe recipe[v]:
		while(i != recipe[v] && v <= Tier2MinCount + Tier2ItemCount) {
			v += 1;
		}
		//If the recipe is over the Tier 2 limit, it means it didn't match, let's see if it is Tier 3 recipe.
		if(v > Tier2MinCount + Tier2ItemCount) {
			v = Tier3MinCount;
			while(i != recipe[v] && v < Tier3MinCount + Tier3ItemCount) {
				v += 1;
			}
		}
		//Assign the component indices to the correct material (we could also do it here, but this way it's neater):
			 if(v == 201) setComponents(103,107,3-3,4-4,5-5,6-6,v);	//Blasting Wand
		else if(v == 202) setComponents(105,106,110,4-4,5-5,6-6,v);	//Casque of Valor
		else if(v == 203) setComponents(101,107,110,4-4,5-5,6-6,v);	//Caster Scroll
		else if(v == 204) setComponents(153,103,107,4-4,5-5,6-6,v);	//Enchantress' Fluid
		else if(v == 205) setComponents(152,152,106,4-4,5-5,6-6,v);	//Eternal Wards
		else if(v == 206) setComponents(103,108,3-3,4-4,5-5,6-6,v);	//Ethereal Mirror
		else if(v == 207) setComponents(103,104,3-3,4-4,5-5,6-6,v);	//Farseer's Staff
		else if(v == 208) setComponents(102,104,107,4-4,5-5,6-6,v);	//Gauntlets of Embers
		else if(v == 209) setComponents(103,106,110,4-4,5-5,6-6,v);	//Heart of the Sea
		else if(v == 210) setComponents(101,111,3-3,4-4,5-5,6-6,v);	//Kissing Chimaeras
		else if(v == 211) setComponents(104,2-2,3-3,4-4,5-5,6-6,v);	//Pearl of Grand Vision
		else if(v == 212) setComponents(105,105,110,4-4,5-5,6-6,v);	//Reef Armor
		else if(v == 213) setComponents(107,109,157,4-4,5-5,6-6,v);	//Runic Axe
		else if(v == 214) setComponents(154,108,109,4-4,5-5,6-6,v);	//Spectral Blade
		else if(v == 215) setComponents(102,108,111,4-4,5-5,6-6,v);	//Stormrider Cloak
		else if(v == 216) setComponents(105,106,106,4-4,5-5,6-6,v);	//Super Regen Spines
		else if(v == 217) setComponents(109,109,109,4-4,5-5,6-6,v);	//Titanic Trident
		else if(v == 218) setComponents(104,109,3-3,4-4,5-5,6-6,v);	//Voodoo Doll
		else if(v == 219) setComponents(151,102,109,4-4,5-5,6-6,v);	//Warbanner
		else if(v == 220) setComponents(112,2-2,3-3,4-4,5-5,6-6,v);	//Refund Ankh (through recommended items)
		else if(v == 301) setComponents(112,2-2,3-3,4-4,5-5,6-6,v);	//Ankh of Superiority
		else if(v == 302) setComponents(212,216,3-3,4-4,5-5,6-6,v);	//Armor of Tides
		else if(v == 303) setComponents(202,203,3-3,4-4,5-5,6-6,v);	//Dawnkeeper
		else if(v == 304) setComponents(205,2-2,3-3,4-4,5-5,6-6,v);	//Enchanted Druid Leaf
		else if(v == 305) setComponents(213,214,3-3,4-4,5-5,6-6,v);	//Endelune
		else if(v == 306) setComponents(204,209,3-3,4-4,5-5,6-6,v);	//Essence of Pure Magic
		else if(v == 307) setComponents(207,213,3-3,4-4,5-5,6-6,v);	//Foreteller's Sickle
		else if(v == 308) setComponents(218,219,3-3,4-4,5-5,6-6,v);	//Helmet of the Damned
		else if(v == 309) setComponents(215,216,3-3,4-4,5-5,6-6,v);	//Mistlord's Cape
		else if(v == 310) setComponents(208,214,3-3,4-4,5-5,6-6,v);	//Molten Blade
		else if(v == 311) setComponents(209,211,3-3,4-4,5-5,6-6,v);	//Mystic Staff of Gods
		else if(v == 312) setComponents(203,210,219,4-4,5-5,6-6,v);	//Mace of Mortality
		else if(v == 313) setComponents(215,217,3-3,4-4,5-5,6-6,v);	//Poseidon's Trident
		else if(v == 314) setComponents(204,206,212,4-4,5-5,6-6,v);	//Robe of Spellcraft
		else if(v == 315) setComponents(208,218,3-3,4-4,5-5,6-6,v);	//Spear of Fervor
		else if(v == 316) setComponents(201,207,3-3,4-4,5-5,6-6,v);	//Tidal Scepter
		else if(v == 317) setComponents(210,213,102,4-4,5-5,6-6,v);	//Highseer Slippers
	}
	
	private function isItemAvailable(unit u, integer i, player p, integer c) -> boolean {
		boolean b_ItemAvailable = false;
		boolean searchGoldMound = false;
		unit goldMound = getGoldMine();
		integer goldStorage;
		integer n = 0;
		boolean itemCheck;
		boolean isFirstOfType = true;
		integer iSecondaryComponentCounter = c;
		tempItemHolder[c] = null;
		if(SendDebug) BJDebugMsg("|cffff8010Read Data:");
		if(SendDebug) BJDebugMsg(I2S(c));
		if(SendDebug) BJDebugMsg("|ntempItemSlot["+I2S(c)+"] = "+I2S(tempItemSlot[c]));
		if(GetOwningPlayer(u) == GetOwningPlayer(goldMound)) searchGoldMound = true;
		//If we look for first item of the current type (and we haven't checked it before (tempItemSlot[c] != -1)):
		if(SendDebug) BJDebugMsg("|cff5050ffSearching for the item number |r" + I2S(c) + "|cff5050ff. It is of the type |r" + getItemNameFromId(i));
		//For 3 Tier items we scroll through the Tier 2 Items (Which are components) and their components (if we don't have the Tier 2 Items directly).
		//Here we account for the fact that same item type components might not be in the adjacent component indices.
		while(Searching4SecondaryComponents && iSecondaryComponentCounter > 1 && isFirstOfType) {
			iSecondaryComponentCounter -= 1;	//Roll from current Sub-component number down to 0 (other way around we'd always pick up the first sub-component of the type).
			if(com[iSecondaryComponentCounter] == com[c]) {
				isFirstOfType = false;
				if(SendDebug) BJDebugMsg("|cffff0000A previous component was already of this kind, not the first of type!" + I2S(iSecondaryComponentCounter) + " and " + I2S(c));
			}
		}
		if(com[c] != com[c-1] && isFirstOfType) {
			if(SendDebug) BJDebugMsg("|cff5050ffEntering |rSEARCH|cff5050ff for the |rFIRST|cff5050ff item of the type |r" + getItemNameFromId(i));
			if(UnitHasItemById(u, i)) {
				tempItem[c] = GetItemFromUnitById(u, i);
				tempItemSlot[c] = GetSlotById(u, i);
				tempItemHolder[c] = u;
				b_ItemAvailable = true;
				//We do not want to remove Consumable items, nor do we want to move over if there is still more stacks :)
				if(GetItemType(tempItem[c]) == ITEM_TYPE_CHARGED) {
					chargeCount[c] = 1;
					if(SendDebug) BJDebugMsg("|cffffff00Item sought is |rCHARGED|cffffff00.");
				}
			} else if(searchGoldMound && u != goldMound && UnitHasItemById(goldMound, i)) {
				b_ItemAvailable = true;
				tempItem[c] = GetItemFromUnitById(goldMound, i);
				tempItemSlot[c] = GetSlotById(goldMound, i) + 6;
				tempItemHolder[c] = goldMound;
			}
			if(SendDebug && b_ItemAvailable && tempItem[c] != null) BJDebugMsg("|cff00ff00Found |cff3399ff" + getItemNameFromId(i) + "|cff00ff00 from slot |r" + I2S(tempItemSlot[c]));
			else if(SendDebug && tempItem[c] == null) BJDebugMsg("|cffff0000Could not find the first item of the type |r" + getItemNameFromId(i));
			if(SendDebug) BJDebugMsg("|cffffff00Found |rtempItem[" + I2S(c) + "] |cffffff00 and it is of type |r " + getItemNameFromId(GetItemTypeId(tempItem[c])));
			if(GetItemTypeId(tempItem[c]) != i && b_ItemAvailable && SendDebug) {
				if(tempItem[c] != null) BJDebugMsg("|cff202020Critical Error: Accepted item is not the correct item type!");
				else BJDebugMsg("|cff202020Non-Critical Error: Declaring item of type |rnull|cff202020 as the first component!");
			}
			if(SendDebug) BJDebugMsg("|cff5050ffLeaving |rSEARCH|cff5050ff for the |rFIRST|cff5050ff item of the type |r" + getItemNameFromId(i));
		}
		//Check if we are looking for the same item type than previous item:
		else if((c != 1 && tempItemSlot[c] != -1) || (!isFirstOfType && tempItemSlot[iSecondaryComponentCounter-1] != -1)) {
			if(SendDebug) BJDebugMsg("|cff5050ffEntering |rSEARCH|cff5050ff for |rANOTHER|cff5050ff item of the type |r" + getItemNameFromId(i));
			//We don't need to loop through slots smaller than the previous same item.
			if((tempItemSlot[c-1] >= 0 && isFirstOfType)) {
				if(isFirstOfType) {
					n = tempItemSlot[c-1];
					tempItemSlot[c] = tempItemSlot[c-1];
				}
				if(SendDebug) BJDebugMsg("|cffffff00The index |rN = " + I2S(n));
				if(SendDebug) BJDebugMsg("|cffffff00The tempItemSlot[|r"+ I2S(c) +"|cffffff00] = |r" + I2S(n));
				//If we are looking for a consumable of the previous type, we might be able to use the same item twice:
				if(GetItemType(tempItem[c-1]) == ITEM_TYPE_CHARGED) {
					//And if we have charges: Let's skip the slot searching, we already know the item: 
					if(SendDebug) BJDebugMsg("|cffffff00Item sought is |rCHARGED|cffffff00.");
					if(GetItemCharges(tempItem[c-1]) - chargeCount[c-1] >= 1) {
						n = 14;
						chargeCount[c] = chargeCount[c-1] + 1;
						chargeCount[c-1] = 0; //Make this 0, so we don't substract multiple times upon Exit.
					//Adjust the charge count accordingly.
					} else {
						n = tempItemSlot[c-1];
						chargeCount[c] = 1;
					}
				}
			//If temp item slot [c-1] is -1, it means we bought it and still do not have any of them.
			} else if((isFirstOfType && tempItemSlot[c-1] == -1) || (!isFirstOfType && tempItemSlot[iSecondaryComponentCounter-1] == -1)) {
				n = 13;
				if(SendDebug) BJDebugMsg("|cffffff00tempItemSlot[|r"+ I2S(c-1) +"|cffffff00] is |r-1|cffffff00. Skipping SCANNING function!");
			//If the sub-component is not first of its type, then we use the tempItemSlot of the pre-used sub-component and start our search from there:
			} else if(!isFirstOfType && tempItemSlot[iSecondaryComponentCounter] != -1) {
				n = tempItemSlot[iSecondaryComponentCounter];
				tempItemSlot[c] = tempItemSlot[iSecondaryComponentCounter];
				if(SendDebug) BJDebugMsg("|cff5050ffEntering |rSUB-COMPONENT SEARCH|cff5050ff for |rANOTHER|cff5050ff item of the type |r" + getItemNameFromId(i));
				if(SendDebug) BJDebugMsg("|cffffff00The index |rN = " + I2S(n));
				if(SendDebug) BJDebugMsg("|cffffff00The tempItemSlot[|r"+ I2S(c) +"|cffffff00] = |r" + I2S(n));
				//If we are looking for a consumable of the previous type, we might be able to use the same item twice:
				if(GetItemType(tempItem[iSecondaryComponentCounter]) == ITEM_TYPE_CHARGED) {
					//And if we have charges: Let's skip the slot searching, we already know the item: 
					if(SendDebug) BJDebugMsg("|cffffff00Item sought is |rCHARGED|cffffff00.");
					if(GetItemCharges(tempItem[iSecondaryComponentCounter]) - chargeCount[iSecondaryComponentCounter] >= 1) {
						n = 14;
						chargeCount[c] = chargeCount[iSecondaryComponentCounter] + 1;
						chargeCount[iSecondaryComponentCounter] = 0; //Make this 0, so we don't substract multiple times upon Exit.
					//Adjust the charge count accordingly.
					} else {
						n = tempItemSlot[iSecondaryComponentCounter];
						chargeCount[c] = 1;
					}
				}
				if(SendDebug) BJDebugMsg("|cff5050ffLeaving |rSUB-COMPONENT SEARCH|cff5050ff for |rANOTHER|cff5050ff item of the type |r" + getItemNameFromId(i));
			} else if(tempItemSlot[iSecondaryComponentCounter] == -1) {
				n = 13;
				if(SendDebug) BJDebugMsg("|cffffff00tempItemSlot[|r"+ I2S(iSecondaryComponentCounter) +"|cffffff00] is |r-1|cffffff00. Skipping SCANNING function!");
			}
			if(SendDebug) BJDebugMsg("|cff5050ffLEAVING |rSEARCH|cff5050ff for |rANOTHER|cff5050ff item of the type |r" + getItemNameFromId(i));
			//Check previous components:
			//As long as the item slot is less or equal to the previous, we have already used the item.
			//But exit if n (Inventory Slot Number) becomes 12 (if the n becomes 12, it means no item was found).
			while((isFirstOfType && tempItemSlot[c-1] >= tempItemSlot[c] && n <= 12) || (!isFirstOfType && tempItemSlot[iSecondaryComponentCounter] >= tempItemSlot[c] && n <= 12)) {
				if(SendDebug) BJDebugMsg("|cff5050ffEntering |rSCANNING|cff5050ff for the item of the type |r" + getItemNameFromId(i));
				n += 1;
				if(n < 6) {
					if(SendDebug) BJDebugMsg("|cffffff00Scanning |rUNIT|cffffff00 for |r " + getItemNameFromId(i) + "|cffffff00 from slot |r" + I2S(n));
					tempItemSlot[c] = GetNextSlotById(u, i, n);
					if(tempItemSlot[c] == -1) n = 6;
					if(tempItemSlot[c] != -1 && SendDebug) {
						BJDebugMsg("|cff00ff00Found |cff3399ff" + getItemNameFromId(i) + "|cff00ff00 from slot |r" + I2S(tempItemSlot[c]));
						//We could technically assign the tempItem[c] here as well, no?
					}
				}
				//Search Mound inventory:
				if(searchGoldMound && u != goldMound && 6 <= n && n < 12) {
					if(SendDebug) BJDebugMsg("|cffffff00Scanning |rMOUND|cffffff00 for |r " + getItemNameFromId(i) + "|cffffff00 from slot |r" + I2S(n-6));
					tempItemSlot[c] = GetNextSlotById(goldMound, i, n-6);
					if(tempItemSlot[c] == -1) {
						n = 13;
					} else {
						tempItemSlot[c] = tempItemSlot[c] + 6;
						if(SendDebug) BJDebugMsg("|cff00ff00Found |cff3399ff" + getItemNameFromId(i) + "|cff00ff00 from slot |r" + I2S(tempItemSlot[c]));
					}
				}
				if(SendDebug) {
					if(isFirstOfType) {
						if(tempItemSlot[c] == tempItemSlot[c-1]) BJDebugMsg("|cff202020Critical Error: Slot is SAME as previous!");
						if(tempItemSlot[c] < tempItemSlot[c-1]) BJDebugMsg("|cff202020Critical Error: Slot is LESS as previous!");
					} else if(!isFirstOfType) {
						if(tempItemSlot[c] == tempItemSlot[iSecondaryComponentCounter]) BJDebugMsg("|cff202020Critical Error: Slot is SAME as previous!");
						if(tempItemSlot[c] < tempItemSlot[iSecondaryComponentCounter]) BJDebugMsg("|cff202020Critical Error: Slot is LESS as previous!");
					}
					BJDebugMsg("|cff5050ffLeaving |rSCANNING|cff5050ff for the item of the type |r" + getItemNameFromId(i));
				}
			}
			if( n != 13) {
				if(SendDebug) BJDebugMsg("|cff5050ffEntering |rITEM ASSIGN|cff5050ff for the item of the type |r" + getItemNameFromId(i));
				//If the buying unit has it:
				if(n < 6) {
					tempItem[c] = UnitItemInSlot(u, tempItemSlot[c]);
					tempItemHolder[c] = u;
					b_ItemAvailable = true;
					if(SendDebug) BJDebugMsg("UNIT|cffffff00 has it. ItemAvailable = |rtrue");
				//If the Gold Mound has it:
				} else if(searchGoldMound && u != goldMound && n <= 12) {
					tempItem[c] = UnitItemInSlot(goldMound, tempItemSlot[c] - 6);
					tempItemHolder[c] = goldMound;
					b_ItemAvailable = true;
					if(SendDebug) BJDebugMsg("MOUND|cffffff00 has it. ItemAvailable = |rtrue");
				//If n == 14, we are using the previous Consumable item again.
				} else if(n == 14) {
					//Let's make the current item the same as previous item, as it still has atleast 1 charge.
					tempItem[c] = tempItem[c-1];
					tempItemSlot[c] = tempItemSlot[c-1];
					tempItemHolder[c] = tempItemHolder[c-1];
					b_ItemAvailable = true;
					if(SendDebug) BJDebugMsg("|cffffff00It is |rCHARGED|cffffff00, using the previous holder. ItemAvailable = |rtrue");
				}
				if(SendDebug) BJDebugMsg("|cffffff00Found |r(" + getItemNameFromId(i) + ") tempItem[" + I2S(c) + "] |cffffff00 and it is of type |r " + getItemNameFromId(GetItemTypeId(tempItem[c])));
				if(SendDebug) BJDebugMsg("|cff00ff00Assigning the found item to slot |r" + I2S(tempItemSlot[c]));
				SetItemInvulnerable(tempItem[c], true);
				BlzSetItemDescription(tempItem[c], "USED");
			//If n == 13, then we know the item was not found (there is no item).
			
			} else {
				b_ItemAvailable = false;
				if(SendDebug) BJDebugMsg("|cffff0000Could not find the item of the type |r" + getItemNameFromId(i) + "|cffff0000. ItemAvailable =|r false");
			}
			if(SendDebug) BJDebugMsg("|cff5050ffLeaving |rITEM ASSIGN|cff5050ff for the item of the type |r" + getItemNameFromId(i));
		}
		//If still, somehow, the item is the same as previous, then give up on everything:
		if(c != 1 && tempItem[c] == tempItem[c-1] && tempItem[c] != null && GetItemType(tempItem[c]) != ITEM_TYPE_CHARGED) {
			b_ItemAvailable = false;
			if(SendDebug) BJDebugMsg("|cff202020Fatal Error: System is attempting to use the same item twice!|r");
		}
		//If we do not have an item, let's try to buy one:
		//But if the index (c) is over 10, we are searching for sub-components.
		if(!b_ItemAvailable && c < 10 && com[7] != com[301]) {
			if(SendDebug) BJDebugMsg("|cff5050ffEntering |rITEM BUY|cff5050ff for the item of the type |r" + getItemNameFromId(i));
			//But if we are trying to create a TIER 3 item, we might want to see if we have components for the component.
			//If we do have a component, let's refund its cost for the player, and later remove it (upon completion).
			if(grade == 3) {
				//Get the current component's recipe:
				Searching4SecondaryComponents = true;
				grade = 2;
				componentFactor += 1;
				//Back cross the item we are looking for to the recipe, and figure out the components of that recipe.
				matchRecipe(matchComponent2Recipe(i));
				//Integer n is not used for anything else anymore, so, let's use it here:
				n = 0;
				//Loop through up to 6 sub-components and if one is fund, refund it's price.
				com[10*componentFactor] = 0;
				while(n < 6) {
					n += 1;
					//Let's index the sub-component items into +10, (and +20, +30...) for each additional component we handle.
					if(com[n+10*componentFactor] > 0) {
						itemCheck = isItemAvailable(u, com[n+10*componentFactor], p, n+10*componentFactor);
						//If the item is available, then let's reduce its price from the component we're about to buy:
						if(itemCheck) {
							currentSum -= getItemCostFromId(com[n+10*componentFactor]);
							if(SendDebug) BJDebugMsg("|cff00ff00Found a sub-component |r"+ getItemNameFromId(com[n+10*componentFactor]) +"|cff00ff00, refunding |r" + I2S(getItemCostFromId(com[n+10*componentFactor])));
						}
					}
				}
				//Now puts itemCheck to false, since we are actually going to buy the missing main component - albeit with reduced price.
				itemCheck = false;
				grade = 3;
				Searching4SecondaryComponents = false;
			}
			currentSum += getItemCostFromId(i);
			if(SendDebug) BJDebugMsg("|cff00ff00Bought the item of type |r" + getItemNameFromId(i) + "|cff00ff00 as a component[|r"+ I2S(c) +"|cff00ff00]|r");
			//As long as the player has enough money, we can just buy the missing components:
			if(currentSum <= GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)) {
				tempItemSlot[c] = -1;
				tempItemHolder[c] = u;	//Let's just assume that non-existing (bought) items are possession of the buying unit.
				b_ItemAvailable = true;
			} else if(SendDebug) BJDebugMsg("|cffff0000Cannot buy the item, exceeding gold limit! |cffffcc00Total Gold Cost: |r" + I2S(currentSum));
			if(SendDebug) BJDebugMsg("|cff5050ffLeaving |rITEM BUY|cff5050ff for the item of the type |r" + getItemNameFromId(i));
		} else if(!b_ItemAvailable && com[7] == com[301]) {
			DisplayTextToPlayer(p, 0, 0, "|cff3399ffAnkh of Reincarnation|cff99b4d1 must be present to create |cff3399ffAnkh of Superiority|cff99b4d1!|r");
		}
		if(SendDebug && b_ItemAvailable == false) BJDebugMsg("|cffff0000Item of type |r"+ getItemNameFromId(i) +"|cffff0000 is not available!");
		u = null;
		p = null;
		goldMound = null;
		return b_ItemAvailable;
	}
	
	private function ExitAutoCombine(unit u, boolean completion) {
		integer i = 0;
		integer v;
		if(SendDebug) BJDebugMsg("|cff5050ffEntering |rEXIT AUTOBUY|cff5050ff for the item of the type |r" + getItemNameFromId(com[7]));
		//Only remove and grant items if the Auto-Combining is completing, but always flush all data.
		while(i < 6) {
			i += 1;
			if(com[i] != com[0]) {
				if(SendDebug) BJDebugMsg("|cffff0000Queing " + getItemNameFromId(com[i]) + " up for deletion!");
				if(tempItemSlot[i] != -1 && tempItemSlot[i] >= 0) {
					//Remove all items (or adjust their charges if needed) and flush their data. Items that will be bought are accounted for in the currentSum.
					tempItemHolder[i] = null;
					if(GetItemType(tempItem[i]) == ITEM_TYPE_CHARGED && GetItemCharges(tempItem[i]) > chargeCount[i] && completion) {
						SetItemCharges(tempItem[i], GetItemCharges(tempItem[i]) - chargeCount[i]);
					} else if(completion) {
						RemoveItem(tempItem[i]);
						if(SendDebug) BJDebugMsg("Removing " + getItemNameFromId(com[i]) + " from slot " + I2S(tempItemSlot[i]));
						if(SendDebug) BJDebugMsg("|cffff0000Removing tempItem[" + I2S(i) + "] of the type " + getItemNameFromId(GetItemTypeId(UnitItemInSlot(tempItemHolder[i], tempItemSlot[i]))));
					}
				}
			} else if(com[i] == com[0]) {
				if(SendDebug) BJDebugMsg("|cffff0000com[|r"+ I2S(i) +"|cffff0000] is |r0|cffff0000! Looking for false component as |r" + getItemNameFromId(com[i]) + "|cffff0000!|r");
			}
			//If Grade is 3, we might have some items stored in indexes 10-36, so let's handle them too:
			//(The v only goes up to 3, because it is the maximum number of Tier 2 components that any Tier 3 item currently needs!
			if(grade == 3) {
				v = 0;
				while(v < 3) {
					v += 1;
					tempItemHolder[i + 10 * v] = null;
					tempItemSlot[i+10*v] = 0;
					//Only do something if an item exists in the slot, but nullify their information before, since consumables might be the same item.
					if(tempItem[i+10*v] != null) {
						//Let's only remove the Charged item if it has no charges left.
						if(GetItemType(tempItem[i+10*v]) == ITEM_TYPE_CHARGED && GetItemCharges(tempItem[i+10*v]) > chargeCount[i+10*v] && completion) {
							SetItemCharges(tempItem[i+10*v], GetItemCharges(tempItem[i+10*v]) - chargeCount[i+10*v]);
						} else if(completion) RemoveItem(tempItem[i+10*v]);
						tempItem[i + 10 * v] = null;
					}
				}
			}
			com[i] = 0;
			tempItemSlot[i] = 0;
			if(SendDebug) BJDebugMsg("Setting " + getItemNameFromId(com[i]) + " to 0.");
		}
		//If the craft was successful:
		if(completion) {
			SetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD) - currentSum);
			UnitAddItemById(u, com[7]);
		}
		if(SendDebug) BJDebugMsg("|cff5050ffLeaving |rEXIT AUTOBUY|cff5050ff for the item of the type |r" + getItemNameFromId(com[7]));
		com[7] = 0;
		currentSum = 0;
		componentFactor = 0;
		u = null;
		completion = false;
	}

	private function attemptAutoComplete(unit u, integer itemTypeBought, item boughtItem) {
		integer c = 0;
		boolean itemCheck = true;
		player p = GetOwningPlayer(u);
		//Set every component to "0" if somehow there are left-overs from previous times (should not be the case).
		ExitAutoCombine(u, false);
		//Search for the correct recipe index:
		Searching4SecondaryComponents = false;
		matchRecipe(itemTypeBought);
		currentSum = 0;
		componentFactor = 0;
		if((com[7] == com[301] || com[7] == com[220]) && AnkhCrafted) {
				itemCheck = false;
			}
		while(c < 6 && itemCheck == true) {
			c += 1;
			if(com[c] > 0) {
				itemCheck = isItemAvailable(u, com[c], p, c);
			}
		}
		if(!itemCheck) {
			if(SendDebug) BJDebugMsg("|cffff0000Missing a component, terminating check!");
			SetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD) + GetItemLevel(boughtItem));
			if(com[7] == com[301] && AnkhCrafted) {
				DisplayTextToPlayer(GetOwningPlayer(u), 0, 0, "|cff99b4d1There should only be one |cff3399ffAnkh of Superiority|cff99b4d1. Refunding |cffffcc00"+ I2S(GetItemLevel(boughtItem)) +" gold|cff99b4d1.");
			} else DisplayTextToPlayer(GetOwningPlayer(u), 0, 0, "|cff99b4d1Failed to create |cff3399ff"+ getItemNameFromId(com[7]) +". Refunding |cffffcc00"+ I2S(GetItemLevel(boughtItem)) +" gold|cff99b4d1.");
			ExitAutoCombine(u,false);
			}
		if(itemCheck) {
			if(com[1] == com[112]) {
				AnkhCrafted = true;
			}
			ExitAutoCombine(u, true);
			
		}
		u = null;
		p = null;
		boughtItem = null;
	}
	
	private function autoCompleteWindow() {
		timer tim = GetExpiredTimer();
		unit buying = LoadUnitHandle(RecipeHash, GetHandleId(tim), 0);
		integer i = LoadInteger(RecipeHash, GetHandleId(buying), 0);
		i = 'I051';
		//if(SendDebug) BJDebugMsg("|cffffcc00Autobuy interval expired.");
		SaveInteger(RecipeHash, GetHandleId(buying), 0, i);
		FlushChildHashtable(RecipeHash, GetHandleId(tim));
		FlushChildHashtable(RecipeHash, GetHandleId(buying));
		DestroyTimer(tim);
		buying = null;
		tim = null;
	}
	
	private function getRecipeTier(integer shop) -> integer {
		if(shop == 'n01A' || shop == 'n01B' || shop == 'n022') return 2;
		else if(shop == 'n01M' || shop == 'n01N' ) return 3;
		else return 0;
	}
	
	private function switchPage(player pSwitching, unit uShop, integer grade) {
		if(grade == 2) {
			if(uShop == UnitManager.RECIPES_PAGE_TWO) SelectUnitForPlayerSingle(UnitManager.RECIPES_PAGE_ONE, pSwitching);
			else SelectUnitForPlayerSingle(UnitManager.RECIPES_PAGE_TWO, pSwitching);
		} else if(grade == 3) {
			if(uShop == UnitManager.RECIPES_PAGE_TWO_TIER3) SelectUnitForPlayerSingle(UnitManager.RECIPES_PAGE_ONE_TIER3, pSwitching);
			else SelectUnitForPlayerSingle(UnitManager.RECIPES_PAGE_TWO_TIER3, pSwitching);
		}
		pSwitching = null;
		uShop = null;
	}
	
    private function onInit() {
		trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM);
        TriggerAddCondition(t, Condition(function() -> boolean {
			unit buying = GetBuyingUnit();
            unit u_Shop = GetSellingUnit();
			player pBuyer = GetOwningPlayer(buying);
			item boughtItem = GetSoldItem();
			integer r = GetItemTypeId(boughtItem);
			timer tim;
			grade = getRecipeTier(GetUnitTypeId(u_Shop));
			//Check that the Shop is recipe Shop and that it's not Switch Page:
			if( grade > 1 && r != iSwitchPage) {
				//if(SendDebug) BJDebugMsg("|cff00ff00Recipe purchase");
				if(r == LoadInteger(RecipeHash, GetHandleId(buying), 0) || !RequireDoubleClick) {
					//Clean up the auto-buy interval:
					if(RequireDoubleClick) {
						tim = LoadTimerHandle(RecipeHash, GetHandleId(buying), 1);
						FlushChildHashtable(RecipeHash, GetHandleId(tim));
						FlushChildHashtable(RecipeHash, GetHandleId(buying));
						DestroyTimer(tim);
					}
					//Auto-complete initiated:
					attemptAutoComplete(buying, r, boughtItem);
				} else if(RequireDoubleClick) {
					SaveInteger(RecipeHash, GetHandleId(buying), 0, r);
					tim = CreateTimer();
					TimerStart(tim, 1.25, false, function autoCompleteWindow);
					SaveUnitHandle(RecipeHash, GetHandleId(tim), 0, buying);
					SaveTimerHandle(RecipeHash, GetHandleId(buying), 1, tim);
					SetPlayerState(GetOwningPlayer(buying), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(buying), PLAYER_STATE_RESOURCE_GOLD) + GetItemLevel(boughtItem));
					//if(SendDebug) BJDebugMsg("|cffffcc00Autobuy interval initiated.");
				}
			} else if(grade > 1 && r == iSwitchPage) {
				switchPage(pBuyer, u_Shop, grade);
			}
			buying = null;
			u_Shop = null;
			pBuyer = null;
			boughtItem = null;
			tim = null;
		return false;
        }));
		t = null;
		//				
		//Tier II:	
		//			
		recipe[201] = 'I06Y';	//Blasting Wand
		recipe[202] = 'I06B';	//Casque of Valor
		recipe[203] = 'I06S';	//Caster Scroll
		
		recipe[204] = 'I06F';	//Enchantress' Vial
		recipe[205] = 'I01Y';	//Eternal Wards
		recipe[206] = 'I040';	//Ethereal Mirror
		
		recipe[207] = 'I06Q';	//Farseer's Staff
		recipe[208] = 'I054';	//Gauntlets of Embers
		recipe[209] = 'I01W';	//Heart of the Sea
		
		recipe[210] = 'I06J';	//Kissing Chimaeras
		recipe[211] = 'I082';	//Pearl of Grand Vision
		recipe[212] = 'I043';	//Reef Armor
		
		recipe[213] = 'I070';	//Runic Axe
		recipe[214] = 'I07E';	//Spectral Blade
		recipe[215] = 'I06R';	//Stormrider Cloak
		
		recipe[216] = 'I01U';	//Super Regeneration Spines
		recipe[217] = 'I01R';	//Titanic Trident
		recipe[218] = 'I06K';	//Voodoo Doll
		
		recipe[219] = 'I05F';	//Warbanner
		recipe[220] = 'I038';	//Refund Ankh of Reincarnation (through recommended items).
		
		//			
		//Tier III:	
		//			
		recipe[301] = 'I079';	//Ankh of Superiority
		recipe[302] = 'I084';	//Armor of Tides
		recipe[303] = 'I02T';	//Dawnkeeper

		recipe[304] = 'I053';	//Enchanted Druid Leaf
		recipe[305] = 'I08H';	//Endelune
		recipe[306] = 'I07V';	//Essence of Pure Magic
		
		recipe[307] = 'I07Y';	//Foreteller's Sickle
		recipe[308] = 'I00L';	//Helmet of the Damned
		recipe[309] = 'I08O';	//Mistlord's Cape
		
		recipe[310] = 'I085';	//Molten Blade
		recipe[311] = 'I01S';	//Mystic Staff of Gods
		recipe[312] = 'I08I';	//Pendant of Vitality
		
		recipe[313] = 'I04Q';	//Poseidon's Trident
		recipe[314] = 'I083';	//Robe of Spellcraft
		recipe[315] = 'I08M';	//Spear of Fervor
		
		recipe[316] = 'I08K';	//Tidal Scepter
		recipe[317] = 'I050';	//Highseer Slippers
		//				
		//Consumables:	
		//				
		com[151] = 'I018';	//Beast Scroll
		com[152] = 'I017';	//Healing Ward
		com[153] = 'I01G';	//Potion of Recovery
		
		com[154] = 'I01I'; 	//Staff of Teleport
		com[155] = 'I042'; 	//Wand of Neutralization
		com[156] = 'I01H'; 	//Wand of the Wind
		com[157] = 'I01F'; 	//Watcher's Eye
		//			
		//Tier I:	
		//			
		com[101] = 'I05O';	//Chimaera Pendant
		com[102] = 'I00B';	//Gem Of Haste
		com[103] = 'I00M';	//Magic Coral
		
		com[104] = 'I016'; 	//Pearl Of Vision
		com[105] = 'I042'; 	//Reef Shield
		com[106] = 'I00C'; 	//Regenerative Spines
		
		com[107] = 'I07X'; 	//Rune Fragment
		com[108] = 'I05P'; 	//Shadow Shard
		com[109] = 'I00D'; 	//Surge Trident
		
		com[110] = 'I05R'; 	//Tides Heart
		com[111] = 'I00E'; 	//Webbed Feet
		com[112] = 'I00P';	//Ankh of Reincarnation
		//			
		//Tier II:	
		//			
		com[201] = 'I06X';	//Blasting Wand
		com[202] = 'I031';	//Casque of Valor
		com[203] = 'I06T';	//Caster Scroll

		com[204] = 'I06V';	//Enchantress' Vial
		com[205] = 'I01Z';	//Eternal Wards
		com[206] = 'I068';	//Ethereal Mirror
		
		com[207] = 'I06P';	//Farseer's Staff
		com[208] = 'I04Z';	//Gauntlets of Embers
		com[209] = 'I01V';	//Heart of the Sea
		
		com[210] = 'I06G';	//Kissing Chimaeras
		com[211] = 'I063';	//Pearl of Grand Vision
		com[212] = 'I041';	//Reef Armor
		
		com[213] = 'I06Z';	//Runic Axe
		com[214] = 'I07D';	//Spectral Blade
		com[215] = 'I06M';	//Stormrider Cloak
		
		com[216] = 'I01Q';	//Super Regeneration Spines
		com[217] = 'I01P';	//Titanic Trident
		com[218] = 'I06L';	//Voodoo Doll
		
		com[219] = 'I030';	//Warbanner
		com[220] = 'I038';	//Warbanner
		//			
		//Tier III:	
		//			
		com[301] = 'I07A';	//Ankh of Superiority
		com[302] = 'I06E';	//Armor of Tides
		com[303] = 'I069';	//Dawnkeeper

		com[304] = 'I052';	//Enchanted Druid Leaf
		com[305] = 'I08G';	//Endelune
		com[306] = 'I07H';	//Essence of Pure Magic
		
		com[307] = 'I07S';	//Foreteller's Sickle
		com[308] = 'I08A';	//Helmet of the Damned
		com[309] = 'I08P';	//Mistlord's Cape
		
		com[310] = 'I07L';	//Molten Blade
		com[311] = 'I01T';	//Mystic Staff of Gods
		com[312] = 'I08J';	//Mace of Mortality
		
		com[313] = 'I06A';	//Poseidon's Trident
		com[314] = 'I07K';	//Robe of Spellcraft
		com[315] = 'I08N';	//Spear of Fervor
		
		com[316] = 'I08L';	//Tidal Scepter
		com[317] = 'I05E';	//Highseer Slippers
	}
}
//! endzinc