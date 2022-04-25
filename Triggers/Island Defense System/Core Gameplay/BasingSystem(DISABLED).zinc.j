//! zinc
library BasingSystem requires IsUnitWall, CommandParser, IsUnitTower, GameTimer, IslandDefenseSystem {
    private rect Base[100][10];
    private integer numRects[];
    private boolean baseTaken[];
    private integer numBasers[];
    private integer baseOwner[];
    private integer baseSecondary[];
    private integer numBases = 32;
    private region Bases[100];
    
    private struct pData {
        integer pNum;
        unit constructedUnit;
    }
    
    private function SetupRects() {
        integer i, z;
        numRects[0] = 2;
        numRects[1] = 2;
        numRects[2] = 2;
        numRects[3] = 2;
        numRects[4] = 2;
        numRects[5] = 2;
        numRects[6] = 2;
        numRects[7] = 2;
        numRects[8] = 3;
        numRects[9] = 2;
        numRects[10] = 2;
        numRects[11] = 2;
        numRects[12] = 2;
        numRects[13] = 3;
        numRects[13] = 3;
        numRects[14] = 4;
        numRects[15] = 2;
        numRects[16] = 5;
        numRects[17] = 4;
        numRects[18] = 2;
        numRects[19] = 2;
        numRects[20] = 1;
        numRects[21] = 1;
        numRects[22] = 3;
        numRects[23] = 1;
        numRects[24] = 2;
        numRects[25] = 4;
        numRects[26] = 3;
        numRects[27] = 2;
        numRects[28] = 1;
        numRects[29] = 4;
        numRects[30] = 4;
        numRects[31] = 1;
        numRects[32] = 2;
        Base[0][0] = gg_rct_Base00;
        Base[0][1] = gg_rct_Base01;
        Base[1][0] = gg_rct_Base10;
        Base[1][1] = gg_rct_Base11;
        Base[2][0] = gg_rct_Base20;
        Base[2][1] = gg_rct_Base21;
        Base[3][0] = gg_rct_Base30;
        Base[3][1] = gg_rct_Base31;
        Base[4][0] = gg_rct_Base40;
        Base[4][1] = gg_rct_Base41;
        Base[5][0] = gg_rct_Base50;
        Base[5][1] = gg_rct_Base51;
        Base[6][0] = gg_rct_Base60;
        Base[6][1] = gg_rct_Base61;
        Base[7][0] = gg_rct_Base70;
        Base[7][1] = gg_rct_Base71;
        Base[8][0] = gg_rct_Base80;
        Base[8][1] = gg_rct_Base81;
        Base[9][0] = gg_rct_Base90;
        Base[9][1] = gg_rct_Base91;
        Base[10][0] = gg_rct_Base100;
        Base[10][1] = gg_rct_Base101;
        Base[11][0] = gg_rct_Base110;
        Base[11][1] = gg_rct_Base111;
        Base[12][0] = gg_rct_Base120;
        Base[12][1] = gg_rct_Base121;
        Base[13][0] = gg_rct_Base130;
        Base[13][1] = gg_rct_Base131;
        Base[13][2] = gg_rct_Base132;
        Base[14][0] = gg_rct_Base140;
        Base[14][1] = gg_rct_Base141;
        Base[14][2] = gg_rct_Base142;
        Base[15][0] = gg_rct_Base150;
        Base[15][1] = gg_rct_Base151;
        Base[16][0] = gg_rct_Base160;
        Base[16][1] = gg_rct_Base161;
        Base[17][0] = gg_rct_Base170;
        Base[17][1] = gg_rct_Base171;
        Base[17][2] = gg_rct_Base172;
        Base[17][3] = gg_rct_Base173;
        Base[18][0] = gg_rct_Base180;
        Base[18][1] = gg_rct_Base181;
        Base[19][0] = gg_rct_Base190;
        Base[19][1] = gg_rct_Base191;
        Base[20][0] = gg_rct_Base200;
        Base[21][0] = gg_rct_Base210;
        Base[22][0] = gg_rct_Base220;
        Base[22][1] = gg_rct_Base221;
        Base[22][2] = gg_rct_Base222;
        Base[23][0] = gg_rct_Base230;
        Base[24][0] = gg_rct_Base240;
        Base[24][1] = gg_rct_Base241;
        Base[25][0] = gg_rct_Base250;
        Base[25][1] = gg_rct_Base251;
        Base[25][2] = gg_rct_Base252;
        Base[25][3] = gg_rct_Base253;
        Base[26][0] = gg_rct_Base260;
        Base[26][1] = gg_rct_Base261;
        Base[26][2] = gg_rct_Base262;
        Base[27][0] = gg_rct_Base270;
        Base[27][1] = gg_rct_Base271;
        Base[28][0] = gg_rct_Base280;
        Base[29][0] = gg_rct_Base290;
        Base[29][1] = gg_rct_Base291;
        Base[29][2] = gg_rct_Base292;
        Base[29][3] = gg_rct_Base293;
        Base[30][0] = gg_rct_Base300;
        Base[30][1] = gg_rct_Base301;
        Base[30][2] = gg_rct_Base302;
        Base[30][3] = gg_rct_Base303;
        Base[31][0] = gg_rct_Base310;
        Base[32][0] = gg_rct_Base320;
        Base[32][1] = gg_rct_Base321;
        for(0<=i<=numBases) {
            Bases[i] = CreateRegion();
            baseTaken[i] = false;
            numBasers[i] = 0;
            baseOwner[i] = 15;
            baseSecondary[i] = 15;
            for(0<=z<=numRects[i]) {
                RegionAddRect(Bases[i], Base[i][z]);
            }
        }
    }
    
    private function FilterUnits() -> boolean {
        integer pNum = GetPlayerId(GetOwningPlayer(GetConstructingStructure()));
        if(GetPlayerId(GetOwningPlayer(GetFilterUnit())) == pNum) {
            return true;
        } else {
            return false;
        }
    }
    
    private function GroupEnumUnitsInRegion(integer baseNum) -> group {
        integer z;
        group g = CreateGroup();
        for(0<=z<=numRects[baseNum]) {
            GroupEnumUnitsInRect(g, Base[baseNum][z], function FilterUnits);
        }
        return g;
    }
    
    private function ClaimBase(region triggerRect, integer baseNum) {
        integer i;
        group g;
        group unitsInBase;
        unit u=null;
        GameTimer t;
        pData p;
        integer pNum = GetPlayerId(GetOwningPlayer(GetConstructingStructure()));
        unit structure = null;
        boolean canTakeBase = true;
        if(!baseTaken[baseNum]) {
            for(0<=i<=numBases) {
                if(baseOwner[i] == pNum) {
                    canTakeBase = false;
                    g=GroupEnumUnitsInRegion(i);
                    if(CountUnitsInGroup(g) <= 0) {
                        canTakeBase = true;
                        Game.sayClass(3, GetPlayerName(Player(pNum)) + " has unclaimed base " + I2S(i));
                        baseOwner[i] = 12;
                        baseSecondary[i] = 12;
                        numBasers[i] = numBasers[i] - 1;
                    }
                    DestroyGroup(g);
                    if(GetLocalPlayer() == Player(pNum) && !canTakeBase) {
                        DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "You have already claimed Base "+I2S(i)+". To remove your claim destroy all buildings in that base.");
                        p = pData.create();
                        p.constructedUnit = GetConstructingStructure();
                        p.pNum = pNum;
                        t = GameTimer.new(function (GameTimer t) {
                            pData p = t.data();
                            IssueImmediateOrderById(p.constructedUnit, 851976);
                            p.destroy();
                            t.deleteLater();
                        }).start(.01);
                        t.setData(p);
                    }
                }
            }
            if(canTakeBase) {
                baseTaken[baseNum] = true;
                numBasers[baseNum] = numBasers[baseNum] + 1;
                baseOwner[baseNum] = pNum;
                Game.sayClass(3, "Player " + I2S(pNum+1) + " has claimed Base " + I2S(baseNum) + ".");
            }
        } else if(!(baseSecondary[baseNum] == pNum) && !(baseOwner[baseNum] == pNum)) {
            if(GetLocalPlayer() == Player(pNum)) {
                DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Another Player Has Already Claimed This Base");
                DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "To build here they must allow you to build with -allow color or number");
                p = pData.create();
                p.constructedUnit = GetConstructingStructure();
                p.pNum = pNum;
                t = GameTimer.new(function (GameTimer t) {
                    pData p = t.data();
                    if(GetLocalPlayer() == Player(p.pNum)) {
                        ClearSelection();
                        SelectUnit(p.constructedUnit, true);
                        ForceUICancel();
                    }
                    p.destroy();
                    t.deleteLater();
                }).start(.01);
                t.setData(p);
            }
        }
    }
    
    private function UnclaimBase(region triggerRect, integer baseNum) {
        if(UnitManager.isMinion(GetKillingUnit()) || UnitManager.isTitan(GetKillingUnit())) {
            if(!IsUnitWall(GetTriggerUnit()) && !IsUnitTower(GetTriggerUnit())) {
                baseTaken[baseNum] = false;
                numBasers[baseNum] = 0;
                baseOwner[baseNum] = 12;
                baseSecondary[baseNum] = 12;
                DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "The Titan and his Minions are destroying Base " + I2S(baseNum) + ". That base is now unclaimed.");
            }
        }
    }
    
    private function AddSecondaryBaser(integer baseNum) {
        integer i;
        string s = StringCase(GetEventPlayerChatString(), false);
        string color = StringCase(SubString(s, 7, 8), false);
        integer pNum = S2I(SubString(s, 7, StringLength(s)));
        if(SubString(s, 1, 2) == "a" || SubString(s, 1, 5) == "allow") {
            if(pNum == 1 || pNum == 2 || pNum == 3 || pNum == 4 || pNum == 5 || pNum == 6 || pNum == 7 || pNum == 8 || pNum == 9 || pNum == 10) {
                baseSecondary[baseNum] = pNum - 1;
                numBasers[baseNum] += 1;
            } else if(color == "r") {
                baseSecondary[baseNum] = 0;
                numBasers[baseNum] += 1;
            } else if(color == "b") {
                baseSecondary[baseNum] = 1;
                numBasers[baseNum] += 1;
            } else if(color == "t") {
                baseSecondary[baseNum] = 2;
                numBasers[baseNum] += 1;
            } else if(color == "p") {
                baseSecondary[baseNum] = 3;
                numBasers[baseNum] += 1;
            } else if(color == "y") {
                baseSecondary[baseNum] = 4;
                numBasers[baseNum] += 1;
            } else if(color == "o") {
                baseSecondary[baseNum] = 5;
                numBasers[baseNum] += 1;
            } else if(color == "g") {
                baseSecondary[baseNum] = 6;
                numBasers[baseNum] += 1;
            } else if(color == "p") {
                baseSecondary[baseNum] = 7;
                numBasers[baseNum] += 1;
            } else if(StringCase(SubString(s, 7, 10), false) == "gre" || StringCase(SubString(s, 7, 10), false) == "gra") {
                baseSecondary[baseNum] = 8;
                numBasers[baseNum] += 1;
            } else if(color == "l") {
                baseSecondary[baseNum] = 9;
                numBasers[baseNum] += 1;
            } else {
                if(GetLocalPlayer() == GetTriggerPlayer()) {
                    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Player not recognized, please enter a valid color or player number.");
                }
            }
        }
    }
    
    private function RemoveSecondaryBaser(integer baseNum) {
        integer i;
        string s = StringCase(GetEventPlayerChatString(), false);
        string color = StringCase(SubString(s, 11, 12), false);
        integer pNum = S2I(SubString(s, 11, StringLength(s)));
        if(SubString(s, 1, 2) == "a" || SubString(s, 1, 5) == "allow") {
            if(pNum == 1 || pNum == 2 || pNum == 3 || pNum == 4 || pNum == 5 || pNum == 6 || pNum == 7 || pNum == 8 || pNum == 9 || pNum == 10) {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "r") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "b") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "t") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "p") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "y") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "o") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "g") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "p") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(StringCase(SubString(s, 11, 14), false) == "gre" || StringCase(SubString(s, 11, 14), false) == "gra") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else if(color == "l") {
                baseSecondary[baseNum] = 12;
                numBasers[baseNum] -= 1;
            } else {
                if(GetLocalPlayer() == GetTriggerPlayer()) {
                    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Player not recognized, please enter a valid color or player number.");
                }
            }
        }
    }
    
    private function onInit() {
        trigger t;
        integer i;
        SetupRects();
        t=CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_START);
        TriggerAddCondition(t, function() -> boolean {
            boolean activated = GameSettings.getBool("BASING_SYSTEM_ACTIVATED");
            if(activated) {
                integer i, z;
                for(0<=i<=numBases) {
                    if(IsUnitInRegion(Bases[i], GetConstructingStructure())) {
                        ClaimBase(Bases[i], i);
                        break;
                    }
                }
            }
            return false;
        });
        t=null;
        t=CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddCondition(t, function() -> boolean {
            integer i, z;
            boolean activated = GameSettings.getBool("BASING_SYSTEM_ACTIVATED");
            if(activated) {
                for(0<=i<=numBases) {
                    if(IsUnitInRegion(Bases[i], GetConstructingStructure())) {
                        UnclaimBase(Bases[i], i);
                    }
                }
            }
            return false;
        });
        t=null;
        t=CreateTrigger();
        for(0<=i<=9) {
            TriggerRegisterPlayerChatEvent(t, Player(i), "-all", false);
        }
        TriggerAddCondition(t, function() -> boolean {
            boolean activated = GameSettings.getBool("BASING_SYSTEM_ACTIVATED");
            integer i, z;
            if(activated) {
                for(0<=i<=numBases) {
                    if(GetPlayerId(GetTriggerPlayer()) == baseOwner[i] && numBasers[i] < 2) {
                        AddSecondaryBaser(i);
                    }
                }
            }
            return false;
        });
        t=null;
        i=0;
        t=CreateTrigger();
        for(0<=i<=9) {
            TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE);
        }
        TriggerAddCondition(t, function() -> boolean {
            boolean activated = GameSettings.getBool("BASING_SYSTEM_ACTIVATED");
            integer i;
            if(activated) {
                for(0<=i<=numBases) {
                    if(GetPlayerId(GetTriggerPlayer()) == baseOwner[i]) {
                        baseOwner[i] = 12;
                        baseSecondary[i] = 12;
                        baseTaken[i] = false;
                        numBasers[i] = 0;
                    }
                }
            }
            return false;
        });
        t=null;
        t=CreateTrigger();
        i=0;
        for(0<=i<=9) {
            TriggerRegisterPlayerChatEvent(t, Player(i), "-d", false);
        }
        TriggerAddCondition(t, function() -> boolean {
            integer i, z;
            boolean activated = GameSettings.getBool("BASING_SYSTEM_ACTIVATED");
            if(activated) {
                for(0<=i<=numBases) {
                    if(GetPlayerId(GetTriggerPlayer()) == baseOwner[i] && numBasers[i] == 2) {
                        RemoveSecondaryBaser(i);
                    }
                }
            }```````
            return false;
        });
        t=null;
    }
}
//! endzinc