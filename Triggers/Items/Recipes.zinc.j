//! zinc
library ItemRecipes requires RecipeSYS {
    private itempool ultimateTowersPool;
    public function initTitanItems(){
        // "Hidden" recipes
        AddRecipe('I03Q', 'I03Q', 0     , 0     , 0     , 0     , 'I00D'); // Tridents
        AddRecipe('I000', 'I000', 0     , 0     , 0     , 0     , 'I00B'); // Shadowstone
        AddRecipe('I03R', 'I03R', 0     , 0     , 0     , 0     , 'I042'); // Armor Scales
        //AddRecipe('I01G', 'I01G', 0     , 0     , 0     , 0     , 'I036'); // Super Replenishment Flask
        
        AddConsumableMerge('I001'); // Healing Wards (Stacking)
        AddConsumableMerge('I017'); // Healing Wards (Stacking)
        
        AddConsumableMerge('I007'); // Watchers Eye (Stacking)
        AddConsumableMerge('I01F'); // Watchers Eye (Stacking)
        
        AddConsumableMerge('I018'); // Scroll of the Beast (Stacking)
        AddConsumableMerge('I004'); // Scroll of the Beast (Stacking) 
        
        AddConsumableMerge('I01I'); // Staff of Teleportation (Stacking)
        AddConsumableMerge('I005'); // Staff of Teleportation (Stacking) 
        
        AddConsumableMerge('I06C'); // Wand of the Wind (Stacking)
        AddConsumableMerge('I01H'); // Wand of the Wind (Stacking) 
        
        AddConsumableMerge('I002'); // Replenishment Potion (Builder-Only)(Stacking)
		AddConsumableMerge('I05B'); // Chimaera Idol (Titan Only) (Stacking)
        
        // IMPORTANT: Recipe "powerups" must be the last item in the list.
// TIER 2
	AddRecipe('I00P', 'I00C', 'I05R', 'I079',  0	,  0	, 'I07A'); // Ankh of Absolution
	AddRecipe('I01F', 'I00D', 'I070',  0	,  0	,  0	, 'I06Z'); // Axe of Manhunt
	AddRecipe('I042', 'I05R', 'I06B',  0	,  0	,  0	, 'I031'); // Casque of Valor	
	AddRecipe('I018', 'I018', 'I00B', 'I00E', 'I074',  0	, 'I073'); // Charger's Bane
	AddRecipe('I00L', 'I00M', 'I06F',  0	,  0	,  0	, 'I06V'); // Enchantress' Fluid
	AddRecipe('I017', 'I017', 'I017', 'I01Y',  0	,  0	, 'I01Z'); // Eternal Wards
	AddRecipe('I01F', 'I00M', 'I05Q', 'I06Q',  0	,  0	, 'I06P'); // Farseer's Staff
	AddRecipe('I027', 'I00B', 'I016', 'I054',  0	,  0	, 'I04Z'); // Gauntlets of Embers
	AddRecipe('I00C', 'I00M', 'I05R', 'I01W',  0	,  0	, 'I01V'); // Heart of the Sea
	AddRecipe('I00B', 'I040', 'I00D', 'I05F',  0	,  0	, 'I030'); // Helmet of Dominator
	AddRecipe('I05B', 'I05O', 'I06J',  0	,  0	,  0    , 'I06G'); // Kissing Chimaeras			¤
	//AddRecipe('I05B', 'I067', 'I06J',  0	,  0	,  0    , 'I06G'); // Kissing Chimaeras	(C) Take care of in RecipeBackUps
	AddRecipe('I068', 'I00M', 'I078',  0	,  0	,  0	, 'I077'); // Mirror of the Underworld
	AddRecipe('I016', 'I082',  0	,  0	,  0	,  0	, 'I063'); // Pearl of Grand Vision
	AddRecipe('I00D', 'I05Y', 'I06K',  0	,  0	,  0	, 'I06L'); // Pendant of Dark Arts		¤
	AddRecipe('I042', 'I042', 'I05R', 'I043',  0	,  0	, 'I041'); // Reef Armor
	AddRecipe('I01E', 'I06Y',  0	,  0	,  0	,  0	, 'I06X'); // Rod of Destruction
	AddRecipe('I01O', 'I05P', 'I06W',  0	,  0	,  0	, 'I06U'); // Shadow Mask
	AddRecipe('I05H', 'I00D', 'I072',  0	,  0	,  0	, 'I071'); // Stench Lance
	AddRecipe('I05P', 'I00E', 'I06R',  0	,  0	,  0	, 'I06M'); // Stormrider's Cloak
	AddRecipe('I042', 'I042', 'I05Q', 'I06S',  0	,  0	, 'I06T'); // Summoner's Wrist Guard
	AddRecipe('I042', 'I042', 'I00C', 'I00C', 'I01U',  0	, 'I01Q'); // Super Regen Spines
	AddRecipe('I01I', 'I01O', 'I00D', 'I07E',  0	,  0	, 'I07D'); // Thief's Edge
	AddRecipe('I00D', 'I05R', 'I076',  0	,  0	,  0	, 'I075'); // Tidal Guardian's Grace
	AddRecipe('I00D', 'I00D', 'I00D', 'I01R',  0	,  0	, 'I01P'); // Titanic Trident
	AddRecipe('I05R', 'I05O', 'I06O',  0	,  0	,  0	, 'I06N'); // Watcher's Necklace		¤
	//AddRecipe('I05R', 'I067', 'I06O',  0	,  0	,  0	, 'I06N'); // Watcher's Necklace (C) Take care of in RecipeBackUps
// TIER 3
	AddRecipe('I041', 'I01Q', 'I084',  0	,  0	,  0	, 'I06E'); // Armor of Tides
	AddRecipe('I06Z', 'I030', 'I03G',  0	,  0	,  0	, 'I03H'); // Axe of Slaughter
	AddRecipe('I031', 'I030', 'I063', 'I07G',  0	,  0	, 'I07B'); // Banner of War
	AddRecipe('I06M', 'I07D', 'I07C',  0	,  0	,  0	, 'I07I'); // Blood Decree
	AddRecipe('I06U', 'I06M', 'I07T',  0	,  0	,  0	, 'I07Q'); // Boots of Swiftness
	AddRecipe('I06G', 'I06T', 'I075', 'I045',  0	,  0	, 'I04P'); // Crest of the Immortal
	AddRecipe('I042', 'I06X', 'I06T', 'I07J',  0	,  0	, 'I07W'); // Crown of Depths
	AddRecipe('I01Z', 'I06L', 'I032',  0	,  0	,  0	, 'I03E'); // Cryptomancer's Urn		¤
	AddRecipe('I031', 'I06N', 'I02T',  0	,  0	,  0	, 'I069'); // Dawnkeeper
	AddRecipe('I01V', 'I06G', 'I07N',  0	,  0	,  0	, 'I07U'); // Emblem of Eternal Life
	AddRecipe('I04Z', 'I07D', 'I03F',  0	,  0	,  0	, 'I044'); // Embermask
	AddRecipe('I01Z', 'I053',  0	,  0	,  0	,  0	, 'I052'); // Enchanted Druid Leaf
	AddRecipe('I06V', 'I01V', 'I07V',  0	,  0	,  0	, 'I07H'); // Essence of Pure Magic
	AddRecipe('I06P', 'I00M', 'I00D', 'I07Y',  0	,  0	, 'I07S'); // Foreteller's Sickle
	AddRecipe('I073', 'I01Q', 'I07Z',  0	,  0	,  0	, 'I07P'); // Gaze of Rage
	AddRecipe('I06L', 'I071', 'I07M',  0	,  0	,  0	, 'I080'); // Grim Spear			¤
	AddRecipe('I04Z', 'I075', 'I00D', 'I085',  0	,  0	, 'I07L'); // Molten Blade
	AddRecipe('I063', 'I00M', 'I01S',  0	,  0	,  0	, 'I01T'); // Mystic Staff of Gods
	AddRecipe('I073', 'I01P', 'I04Q',  0	,  0	,  0	, 'I06A'); // Poseidon's Trident
	AddRecipe('I071', 'I01P', 'I081',  0	,  0	,  0	, 'I07F'); // Reaper Lance
	AddRecipe('I030', 'I077', 'I063', 'I06I',  0	,  0	, 'I07Q'); // Ring of the Afterlife
	AddRecipe('I06V', 'I041', 'I06N', 'I083',  0	,  0	, 'I07K'); // Robe of Lies
	AddRecipe('I06Z', 'I06P', 'I02R',  0	,  0	,  0	, 'I02S'); // Siren Scepte
	AddRecipe('I06U', 'I06M', 'I077', 'I07T',  0	,  0	, 'I086'); // Visage of Mist
		
    }

    private function addUltimateTower(integer itemid, real chance) {
        //        recipe, tower , egg
        AddRecipe('I02Z', itemid, 'I022', 0     , 0     , 0     , 'I03C'); // Randomize Ultimate Tower
        
        // Also add to the item pool!
        ItemPoolAddItemType(ultimateTowersPool, itemid, chance);
    }
    
    private function addUltimateTowers() {
        /*== SACRED SEASHELL*/
        addUltimateTower('I00J', 1.0);
        /*== HEAVY CANNON*/
        addUltimateTower('I00Y', 1.0);
        /*== METHANE MACHINE*/
        addUltimateTower('I03A', 1.0);
        /*== SLUDGE LAUNCHER*/
        addUltimateTower('I00K', 1.0);
        /*== TROPICAL GLYPH*/
        addUltimateTower('I00N', 1.0);
        /*== GIANT HERMIT*/
        addUltimateTower('I00T', 1.0);
        /*== CRAB MUTANT*/
        addUltimateTower('I00U', 1.0);
        /*== CATAPULT*/
        addUltimateTower('I00V', 1.0);
        /*== WHIRLPOOL*/
        addUltimateTower('I011', 1.0);
        /*== STATIS TOTEM*/
        addUltimateTower('I00W', 1.0);
        /*== MAGIC PEARL*/
        addUltimateTower('I00O', 1.0);
        /*== MAGIC TOWER*/
        addUltimateTower('I00Z', 1.0);
        /*== BOMBARD*/
        addUltimateTower('I010', 1.0);
        /*== MAGIC MUSHROOM*/
        addUltimateTower('I00X', 1.0);
        /*== AURA TREE*/
        addUltimateTower('I013', 1.0);
        /*== SPELL WELL*/
        addUltimateTower('I014', 1.0);
        /*== SPINY PROTECTOR*/
        addUltimateTower('I015', 1.0);
        /*== RAPID FIRE TOWER*/
        addUltimateTower('I01A', 1.0);
        /*== DEEPFREEZE*/
        addUltimateTower('I01B', 1.0);
        /*== ENERGY SPIRE*/
        addUltimateTower('I01C', 1.0);
        /*== MUTATION TOWER*/
        addUltimateTower('I01K', 1.0);
        /*== TOXIC TOWER*/
        addUltimateTower('I01L', 1.0);
        /*== WAVE TOWER*/
        addUltimateTower('I02V', 1.0);
        /*== DEMOLISHER TOTEM*/
        addUltimateTower('I02Y', 1.0);
        /*== CROWN OF THIEVES*/
        addUltimateTower('I037', 1.0);
        /*== REPLICATOR*/
        addUltimateTower('I038', 1.0);
        /*== BOX OF GAIA*/
        addUltimateTower('I05A', 1.0);
        /*== BOX OF PYROS*/
        addUltimateTower('I058', 1.0);
        /*== BOX OF STORMS*/
        addUltimateTower('I059', 1.0);
        /* HIGH ENERGY CONDUIT*/
        addUltimateTower('I057', 1.0);
        /* ICE PALACE*/
        addUltimateTower('I04O', 1.0);
        /* EGG SACK*/
        addUltimateTower('I05T', 1.0);
        /* FIREWORKS LAUNCHER*/
        addUltimateTower('I04J', 1.0);
        /* TAVERN*/
        addUltimateTower('I04L', 1.0);
        /* WELL OF POWER*/
        addUltimateTower('I056', 1.0);
        /* SPIRITUAL RIFT*/
        //addUltimateTower('I061', 1.0);
        /* ISLAND BLOOM*/
        addUltimateTower('I06D', 1.0);
        /* LIGHT ENERGY TOWER*/
        addUltimateTower('I01M', 1.0);
	/* DEMONIC ALTAR*/
        addUltimateTower('I07R', 1.0);
    }
    
    public function initBuilderItems(){
        AddRecipe('I00H', 'I04B', 0, 0, 0, 0, 'I048'); // Greater Troll Hands
        AddRecipe('I00G', 'I049', 0, 0, 0, 0, 'I046'); // Greater Summoning Stone
        AddRecipe('I00I', 'I04A', 0, 0, 0, 0, 'I047'); // Greater Gnoll Luck
		AddRecipe('I04F', 'I04G', 0, 0, 0, 0, 'I05D'); // Shield of Fortitude

        AddRecipe('I022', 'I022', 'I022', 'I022', 'I047', 'I023', 'I020'); // Ring of Shadows
        AddRecipe('I023', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I022', 'I009', 'I021', 0, 0, 'I01X'); // Storm Hammer
        AddRecipe('I021', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I022', 'I005', 'I026', 0, 0, 'I025'); // Teleporter
        AddRecipe('I026', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I00A', 'I00A', 'I03S', 0, 0, 'I03P'); // Shield of Will
        AddRecipe('I03S', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I03P', 'I04H', 0, 0, 0, 'I04G'); // Shield of Might
        AddRecipe('I04H', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I022', 'I00A', 'I04I', 0, 0, 0, 'I04F'); // Runed Bracers
        AddRecipe('I04I', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I00Q', 'I04W', 'I022', 0, 0, 0, 'I04Y'); // Great Turtle Summons
        AddRecipe('I04W', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I05W', 'I05V', 'I004', 'I022', 'I009', 0, 'I04R'); // Solar Blade
        AddRecipe('I05W', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I04S', 'I022', 'I022', 'I009', 0, 0, 'I05V'); // Sword of the Magistrate
        AddRecipe('I04S', 0, 0, 0, 0, 0, 0); // Destroy
        AddRecipe('I05G', 'I022', 'I022', 'I005', 0, 0, 'I05X'); // Mystic Stone
        AddRecipe('I05G', 0, 0, 0, 0, 0, 0); // Destroy
		
		// Runed Bracers
		// I04F (25%)
		// I03W (50%)
		// I03Z (75%)
		// I04D (100%)
		/*
		AddRecipe('I04F', 'I04F', 0, 0, 0, 0, 'I03W'); 
		AddRecipe('I04F', 'I03W', 0, 0, 0, 0, 'I03Z');
		AddRecipe('I04F', 'I03Z', 0, 0, 0, 0, 'I04D');
		AddRecipe('I03W', 'I03W', 0, 0, 0, 0, 'I04D');
		*/
        
        // Ultimate Towers
        addUltimateTowers();
        AddRecipe('I02Z', 0, 0, 0, 0, 0, 0); // Destroy
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterItemAcquiredEvent(t, 'I03C');
        TriggerAddCondition(t, Condition(function() -> boolean {
            item it = GetManipulatedItem();
			integer id = GetItemTypeId(it);
            unit u = GetTriggerUnit();
			while (id == GetItemTypeId(it)) {
				RemoveItem(it);
				it = PlaceRandomItem(ultimateTowersPool, GetUnitX(u), GetUnitY(u));
			}
            UnitAddItem(u, it);
            it = null;
            u = null;
            return false;
        }));
        t = null;
        
        ultimateTowersPool = CreateItemPool();
        
        initTitanItems();
        initBuilderItems();
    }
}
//! endzinc