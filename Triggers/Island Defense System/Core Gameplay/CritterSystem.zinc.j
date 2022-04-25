//! zinc

library CritterSystem requires GameTimer, RegisterPlayerUnitEvent, Table, AIDS, ShowTagFromUnit, DestroyEffectTimed, UnitAlive {
    private struct Critter {
        private unit u = null;
        private real locX = 0.0;
        private real locY = 0.0;
        private real facing = 0.0;
        private player owner = null;
        private integer id = 0;
        
        private boolean mDelayed = false;
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.u = u;
            this.locX = GetUnitX(this.u);
            this.locY = GetUnitY(this.u);
            this.facing = GetUnitFacing(this.u);
            this.owner = GetOwningPlayer(this.u);
            this.id = GetUnitTypeId(this.u);
            return this;
        }
        
        public method x() -> real {
            return this.locX;
        }
        
        public method y() -> real {
            return this.locY;
        }
        
        public method isAlive() -> boolean {
            boolean b = false;
            if (this.u == null){
                // Second check after death
                this.mDelayed = false;
                return false;
            }
            b = UnitAlive(this.u);
            if (!b){
                // First check after death
                this.u = null;
                this.mDelayed = true;
            }
            return b;
        }
        
        public method delayed() -> boolean {
            return this.mDelayed;
        }
        
        public method respawn(){
            this.u = CreateUnit(this.owner, this.id, this.x(), this.y(), this.facing);
        }
    }
    
    public struct CritterSystem {
        private static GameTimer checkTimer = 0;
        public static method initialize(){
            group g = CreateGroup();
            boolexpr filter = Filter(function() -> boolean {
                integer id = GetUnitTypeId(GetFilterUnit());
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
            });
            unit u = null;
            
            GroupEnumUnitsInRect(g, GetWorldBounds(), filter);
            DestroyBoolExpr(filter);
            
            u = FirstOfGroup(g);
            while (u != null){
                thistype.register(Critter.create(u));
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }
            
            DestroyGroup(g);
            g = null;
            u = null;
            filter = null;
            
            thistype.checkTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype.tick();
            }).start(20.0);
        }
        
        public static method terminate(){
            integer i = 0;
            Critter c = 0;
            for (0 <= i < thistype.index){
                c = thistype.critters[i];
                if (c != 0){
                    c.destroy();
                }
                c = 0;
            }
            if (thistype.checkTimer != 0){
                thistype.checkTimer.destroy();
            }
            thistype.checkTimer = 0;
        }
        
        public static method IsPointVisible(real x, real y) -> boolean {
            integer i = 0;
            for (0 <= i < bj_MAX_PLAYERS){
                if (IsVisibleToPlayer(x, y, Player(i))){
                    return true;
                }
            }
            return false;
        }
        
        private static Critter critters[];
        private static integer index = 0;
        
        public static method tick(){
            integer i = 0;
            Critter critter = 0;
            real x = 0.0, y = 0.0;
            
            for (0 <= i < thistype.index){
                critter = thistype.critters[i];
                if (!critter.isAlive()){
                    x = critter.x();
                    y = critter.y();
                    if (!thistype.IsPointVisible(x, y) && !critter.delayed()){
                        // Spawn a critter in an invisible point to all players
                        critter.respawn();
                    }
                }
            }
        }
        
        public static method register(Critter c){
            thistype.critters[thistype.index] = c;
            thistype.index += 1;
        }
        
        private static Table explodableCritters = 0;
        public static method onInit() {
            thistype.explodableCritters = Table.create();
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function() -> boolean {
                unit u = GetTriggerUnit();
                integer i = GetUnitTypeId(u);
                integer id = 0;
                
                if (i != 'n020' &&
                    i != 'nJEN' &&
                    i != 'nfbr') return false;
                
                id = GetUnitIndex(u);
                
                if (!thistype.explodableCritters.has(id)) {
                    thistype.explodableCritters.integer[id] = 100;
                }
                thistype.explodableCritters.integer[id] = thistype.explodableCritters.integer[id] - 1;
                if (thistype.explodableCritters.integer[id] <= 0) {
                    ShowTagFromUnitForAll("|cffff0000BOOM!|r", u);
                    DestroyEffectTimed(AddSpecialEffect("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdx", GetUnitX(u), GetUnitY(u)), 1.0);
                    DestroyEffectTimed(AddSpecialEffect("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdx", GetUnitX(u), GetUnitY(u)), 1.0);
                    DestroyEffectTimed(AddSpecialEffect("Abilities\\Weapons\\Mortar\\ScatterShotTarget.mdl", GetUnitX(u), GetUnitY(u)), 1.0); // (death anim)
                    DestroyEffectTimed(AddSpecialEffect("Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdx", GetUnitX(u), GetUnitY(u)), 1.0);
                    KillUnit(u);
                }
                else if (thistype.explodableCritters.integer[id] <= 10) {
                    ShowTagFromUnitForAll("|cffff0000" + I2S(thistype.explodableCritters.integer[id]) + "!|r", u);
                }
                 
                
                u = null;
                return false;
            });
        }
    }
}
//! endzinc