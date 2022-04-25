//! zinc
library HunterExpSystem {
    //All Titan Hunters
    private constant integer DRAENEI_HUNTER = 'H040';
    private constant integer DRYAD_HUNTER = 'H02L';
    private constant integer GNOLL_HUNTER = 'H00O';
    private constant integer GOBLIN_HUNTER = 'H00Z';
    private constant integer MAKRURA_HUNTER = 'H00N';
    private constant integer MURLOC_HUNTER = 'H04K';
    private constant integer NATURE_HUNTER = 'H00S';
    private constant integer OGRE_HUNTER = 'H039';
    private constant integer PIRATE_HUNTER = 'H046';
    private constant integer RADIO_HUNTER = 'H020';
    private constant integer TROLL_HUNTER = 'H00M';
    private constant integer DEMO_HUNTER = 'U00S';
    //Units that can gain stats with "levels"
    private constant integer TAUREN_ID = 'O01Q';
    private constant integer SATYR_ID = 'h035';
    private constant integer MAG_ID = 'h01B';
    private constant integer MORPH_ID = 'h021';
    private constant integer MORPH_BEAST_ID = 'h024';
    private constant integer MORPH_WARR_ID = 'h023';
    private constant integer FAERIE_ID = 'h02S';
    private constant integer FAERIE_BATT_ID = 'h004';
    
    //Gold / XP for mini minis
    private constant integer MINI_MINI_GOLD = 5;
    private constant integer MINI_MINI_XP = 80;
    
    //And our list of Mini Mini's
    private constant integer BREEZE_MM = 'u00Z';
    private constant integer GLAC_MM = 'u00E';
    private constant integer TERM_MM = 'u00P';
    private constant integer LUCI_MM = 'u00F';
    private constant integer BUB_MM = 'u00C';
    private constant integer MOLT_MM = 'u002';
    private constant integer VOLT_MM = 'u00M';
    private constant integer NOX_MM = 'u000';
    
    //How much AOE XP Mini's give off when they die (divided by # of titan hunters)
    private constant real MINI_AOE_XP_PER_LEVEL = 750;
    //How far do we look for Titan Hunters?
    private constant real MINI_AOE_XP = 1000;
    
    public function isCritter(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == 'nalb' ||
                id == 'nech' ||
                id == 'ncrb' ||
                id == 'ndog' ||
                id == 'ndwm' ||
                id == 'nfro' ||
                id == 'nhmc' ||
                id == 'npig' ||
                id == 'nerc' ||
                id == 'nrat' ||
                id == 'nsea' ||
                id == 'nshe' ||
                id == 'nskk' ||
                id == 'nsno' ||
                id == 'nder' ||
                id == 'nvul');
    }
    
    public function isHunter(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == DRAENEI_HUNTER ||
                id == DRYAD_HUNTER ||
                id == GNOLL_HUNTER ||
                id == GOBLIN_HUNTER ||
                id == MAKRURA_HUNTER ||
                id == MURLOC_HUNTER ||
                id == NATURE_HUNTER ||
                id == OGRE_HUNTER ||
                id == PIRATE_HUNTER ||
                id == RADIO_HUNTER ||
                id == TROLL_HUNTER ||
                id == DEMO_HUNTER);
    }
    
    public function isHeroBuilder(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == TAUREN_ID ||
                id == SATYR_ID ||
                id == MAG_ID ||
                id == MORPH_ID ||
                id == MORPH_BEAST_ID ||
                id == MORPH_WARR_ID ||
                id == FAERIE_ID ||
                id == FAERIE_BATT_ID);
    }
    
    public function isMiniMini(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == BREEZE_MM ||
                id == GLAC_MM ||
                id == BUB_MM ||
                id == LUCI_MM ||
                id == NOX_MM ||
                id == TERM_MM ||
                id == VOLT_MM ||
                id == MOLT_MM);
    }
    
    public function GetGoldTier(unit killer, unit dead) -> integer {
        if(isMiniMini(dead)) {
            return 5;
        }
        return 0;
    }
    
    public function GetExpTier(unit killer, unit dead) -> integer {
        integer id = GetUnitTypeId(killer);
        //Mini Mini - Just need to check who killed it
        if(isMiniMini(dead)) {
            if(isHunter(killer) || isHeroBuilder(killer)) {
                return MINI_MINI_XP;
            }
        }
        //Each tier returns how much killing a critter gives
        if(isHeroBuilder(killer) && isCritter(dead)) {
            return 5;
        } else if(isHunter(killer)) {
            if(id == RADIO_HUNTER) {
                //Rad's hunter is fast and 1x1 so nooope
                return 5;
            } else if(id == DRAENEI_HUNTER || id == DRYAD_HUNTER || id == GNOLL_HUNTER ||
                id == MURLOC_HUNTER || id == NATURE_HUNTER || id == OGRE_HUNTER ||
                id == TROLL_HUNTER) {
                //Normal hunters, similar MS
                return 10;
            } else if(id == GOBLIN_HUNTER || id == PIRATE_HUNTER) {
                //Pirate and Gob - Slow and vulnerable but flying
                return 15;
            } else if(id == DEMO_HUNTER) {
                //He's only alive 45 seconds for every 180
                return 35;
            } else if(id == MAKRURA_HUNTER) {
                //Exremely slow, extremely easy to kill
                return 50;
            }
        }
        return 0;
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function() -> boolean {
            unit killer = GetKillingUnit();
            unit dead = GetTriggerUnit();
            if(isMiniMini(dead) || isCritter(dead)) {
                if(isMiniMini(dead)) {
                    if(isHunter(killer)) {
                        AddHeroXP(killer, GetExpTier(killer, dead), true);
                        SetPlayerState(GetOwningPlayer(killer), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(killer), PLAYER_STATE_RESOURCE_GOLD) + GetGoldTier(killer, dead));
                    }
                } else {
                    if(isHunter(killer)) {
                        AddHeroXP(killer, GetExpTier(killer, dead), true);
                    }
                }
            }
            killer = null;
            dead = null;
            return false;
        });
    }
    
}
//! endzinc