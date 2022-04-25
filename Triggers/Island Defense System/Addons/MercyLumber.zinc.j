//! zinc

library MercyLumber requires GameTimer, CritterSystem {
    public struct MercyLumber {
        private static integer LUMBER_PER_TICK = 10;
        private static real factor = 1.0;
        
        static method initialize(){
            GameTimer.newNamedPeriodic(function(GameTimer t){
                integer i = 0;
                PlayerDataArray list = PlayerData.withClass(PlayerData.CLASS_DEFENDER);
                for(0 <= i < list.size()){
                    list[i].setWood(list[i].wood() + thistype.LUMBER_PER_TICK);
                }
                list.destroy();
            }, "MercyLumber").start(60.0 * factor);
            
            /*
            GameTimer.newNamedPeriodic(function(GameTimer t){
                integer LUMBER_ITEM_ID = 'I065';
                integer LOOP_GUARD = 20;
                rect bounds = GetWorldBounds();
                real x = 0.0;
                real y = 0.0;
                boolean isInvisible = false; 
                boolean isWalkable = false; 
                integer count = 0;
                
                while (!(isInvisible && isWalkable) && count < LOOP_GUARD){
                    x = GetRandomReal(GetRectMinX(bounds) + 1000.0, GetRectMaxX(bounds) - 1000.0);
                    y = GetRandomReal(GetRectMinY(bounds) + 1000.0, GetRectMaxY(bounds) - 1000.0);
                    
                    isInvisible = !CritterSystem.IsPointVisible(x, y);
                    isWalkable = IsTerrainWalkable(x, y) && !IsTerrainDeepWater(x, y);
                    count = count + 1;
                }
                
                if (isInvisible && isWalkable){
                    Game.say("|cff00bfffA Bundle of Lumber has spawned on the Island! Find it to gain additional resources.|r");
                    CreateItem(LUMBER_ITEM_ID, x, y);
                }
                
                RemoveRect(bounds);
                bounds = null;
            }, "RandomLumber").start(48.0 * factor * (100.0 / LUMBER_PER_TICK));
            */
        }
        static method terminate(){
        }
    }
}

//! endzinc