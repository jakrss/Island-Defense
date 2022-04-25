//! zinc

library NetherWarp requires xecast, GT {
    private struct NetherWarp {
        private static constant integer ETHEREAL_MARK_ID = 'h02C';
        private GameTimer netherTimer = 0;
        private unit caster = null;
        private player castingPlayer = null;
        private xecast cast = 0;

        private method getWarpPointLoc(real x, real y) -> location {
            real warpX[];
            real warpY[];
            integer index = -1;
            integer i = 0;
            integer closestIndex = -1;
            real dist = 0.0;
            real closestDist = 0.0;
            real dx = 0.0;
            real dy = 0.0;
            
            //if (GetPlayerActualName(this.castingPlayer) == "ShadowZz")
            //    index = 0;
            //}
            
            warpX[0]  = -500;    warpY[0]  = -700;
            warpX[1]  = 3600;    warpY[1]  = -6200;
            warpX[2]  = -8600;   warpY[2]  = -3600;
            warpX[3]  = -750;    warpY[3]  = -6000;
            warpX[4]  = 3500;    warpY[4]  = 5000;
            warpX[5]  = 8500;    warpY[5]  = 3800;
            warpX[6]  = -7800;   warpY[6]  = 6800;
            warpX[7]  = -3600;   warpY[7]  = -8800;
            warpX[8]  = -3100;   warpY[8]  = 800;
            warpX[9]  = 1800;    warpY[9]  = 2200;
            warpX[10] = 9000;    warpY[10] = -6000;
            warpX[11] = 3770;    warpY[11] = 2000;
            warpX[12] = 5376;    warpY[12] = 5888;
            warpX[13] = -2688;   warpY[13] = 8192;
            
            for (0 <= i < 14) {
                dx = warpX[i] - x;
                dy = warpY[i] - y;
                dist = SquareRoot(dx * dx + dy * dy);
                if (dist < closestDist || closestIndex == -1) {
                    closestDist = dist;
                    closestIndex = i;
                }
                
                //DestroyEffect(AddSpecialEffect("", warpX[i], warpY[i]));
            }
            
            debug {
                BJDebugMsg("Closest index was: #" + I2S(closestIndex));
                PingMinimap(warpX[closestIndex], warpY[closestIndex], 5.00);
            }
            
            index = closestIndex;
            while (index == closestIndex) {
                index = GetRandomInt(0, 13);
            }
            
            debug {
                BJDebugMsg("Chosen index was: #" + I2S(index));
                //PingMinimap(warpX[index], warpY[closestIndex], 5.00);
            }

            return Location(warpX[index], warpY[index]);
        }
        
        public method warp(){
            unit u = null;
            group g = CreateGroup();
            boolexpr b = Filter(function() -> boolean {
                return GetUnitTypeId(GetFilterUnit()) == thistype.ETHEREAL_MARK_ID;
            });
            real x = 0.0;
            real y = 0.0;
            location l = null;
            
            GroupEnumUnitsOfPlayer(g, this.castingPlayer, b);
            u = FirstOfGroup(g);
            DestroyBoolExpr(b);
            DestroyGroup(g);
            
            if (u != null){
                x = GetUnitX(u);
                y = GetUnitY(u);
                KillUnit(u);
            }
            else {
                l = this.getWarpPointLoc(GetUnitX(this.caster), GetUnitY(this.caster));
                x = GetLocationX(l);
                y = GetLocationY(l);
                RemoveLocation(l);
            }
            
            SetUnitPosition(this.caster, x, y);
            if (GetLocalPlayer() == this.castingPlayer){
                PanCameraToTimed(x, y, 0);
            }
            
            b = null;
            u = null;
            g = null;
            l = null;
            this.destroy();
        }
        
        public method onDestroy(){
            this.cast.destroy();
            this.cast = 0;
            this.caster = null;
            this.castingPlayer = null;
        }
        
        public static method begin(unit u) -> thistype {
            thistype this = thistype.allocate();
            
            this.caster = u;
            this.castingPlayer = GetOwningPlayer(this.caster);
            
            this.cast = xecast.createBasic('A05H', OrderId("banish"), this.castingPlayer);
            this.cast.recycledelay = 3.0;

            // Banish
            GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.cast.castOnTarget(this.caster);
            }).start(0.00).setData(this);
            
            // Actual Nether Timer
            this.netherTimer = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                if (UnitAlive(this.caster)){
                    this.warp();
                }
                else {
                    this.destroy();
                }
            });
            this.netherTimer.setData(this);
            this.netherTimer.start(1.0);
            
            return this;
        }
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        GT_RegisterStartsEffectEvent(t, 'A0DN');

        TriggerAddCondition(t, Condition(function() -> boolean {
            NetherWarp.begin(GetSpellAbilityUnit());
            return false;
        }));
        t = null;
        
        XE_PreloadAbility('A0DN');
        XE_PreloadAbility('A05H');
    }
}

//! endzinc
