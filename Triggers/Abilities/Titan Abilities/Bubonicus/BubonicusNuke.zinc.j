//! zinc

// TBAQ
library BubonicusNuke requires GameTimer, GT, xebasic, xepreload, UnitStatus, Table, AIDS, Bubonicus, GenericTitanTargets, IsUnitTitanHunter, ItemExtras, Nukes {
    private struct BubonicusMissile extends xemissile {
        private BubonicusNuke object = 0;
        public method setNukeObject(BubonicusNuke obj){
            this.object = obj;
        }
        
        public method onHit(){
            this.object.onHit(this.x, this.y, this.z);
            this.terminate();
        }
        
        public method onDestroy() {
            integer i = GetRandomInt(1, 6);
            DestroyEffectTimed(AddSpecialEffect("war3mapImported\\Splat0" + I2S(i) + ".mdx", this.x, this.y), 5.0);
        }
    }
    private struct BubonicusNuke {
        private static constant integer ABILITY_ID = 'TBAQ';
        private static constant string MISSILE_EFFECT = "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl";
        private static constant string TARGET_EFFECT = "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl";
        private static constant integer MISSILE_COUNT = 24;
        private static Table instances = 0;
        
        private method setup(integer level){
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_STRUCTURE;
            this.damage.useSpecialEffect(thistype.TARGET_EFFECT, "chest");
            
            if (level == 1){
                this.damageAmount = 135.0;
                this.damageArea = 250.0;
                this.stunDuration = 0.25;
            }
            else if (level == 2){
                this.damageAmount = 155.0;
                this.damageArea = 250.0;
                this.stunDuration = 0.5;
            }
            else if (level == 3){
                this.damageAmount = 180.0;
                this.damageArea = 250.0;
                this.stunDuration = 1.0;
            }
           
        }
        public unit caster = null;
        private player castingPlayer = null;
        private integer level = 0;
        
        private real stunDuration = 0.0;
        private real damageAmount = 0.0;
        private real damageArea = 0.0;
        private xedamage damage = 0;
        private BubonicusMissile missiles[thistype.MISSILE_COUNT];
        private Table damagedUnitsAmount = 0;
        private integer launchCount = 0;
        private integer hitCount = 0;
        private GameTimer launchTimer = 0;
        private real castX = 0.0;
        private real castY = 0.0;
        private real targetX = 0.0;
        private real targetY = 0.0;
        private integer index = 0;
        private boolean canceled = false;
        
        public method checkTarget(unit u) -> boolean {
            return IsUnitNukable(u, this.caster);
        }
        
        private static method distanceFromUnit(real x, real y, unit u) -> real {
            real dx = x - GetUnitX(u);
            real dy = y - GetUnitY(u);
            return SquareRoot(dx * dx + dy * dy);
        }
        
        public method onHit(real x, real y, real z){
            group g = CreateGroup();
            unit u = null;
            integer id = 0;
            real splashArea = this.damageArea / 2;
            real factor = 0.0;
            real damageTaken = 0.0;
            real damage = 0.0;
            GroupEnumUnitsInRange(g, x, y, splashArea, null);
            u = FirstOfGroup(g);
            while (u != null){
                if (this.checkTarget(u)){
                    id = GetUnitIndex(u);
                    damageTaken = this.damagedUnitsAmount.real[id];
                    if (damageTaken < this.damageAmount){
                        factor = 1.0 - ((thistype.distanceFromUnit(x, y, u) / splashArea) / 2.0);
                        damage = this.damageAmount * factor;
                        
                        if (damage + damageTaken > this.damageAmount){
                            damage = (this.damageAmount - damageTaken);
                        }
                        
                        damage = damage * getModifiers(this.caster, u);
                        if (this.damage.damageTarget(this.caster, u, damage)){
                            if (UnitAlive(u)){
                                StunUnitTimed(u, this.stunDuration);
                            }
                        }
                        
                        this.damagedUnitsAmount.real[id] = damageTaken + damage;
                    }
                }
            
                GroupRemoveUnit(g, u);
                u = FirstOfGroup(g);
            }

            GroupClear(g);
            DestroyGroup(g);
            g = null;
            u = null;
            
            this.hitCount = this.hitCount + 1;
            if (this.hitCount >= this.launchCount){
                this.destroy();
            }
        }
        
        public method launchNext(){
            BubonicusMissile missile = 0;
            real x = this.targetX;
            real y = this.targetY;
            real startX = 0.0;
            real startY = 0.0;
            real angle = 0.0;
            real dist = 0.0;
            
            if (this.launchCount >= thistype.MISSILE_COUNT){
                this.launchTimer.deleteLater();
                this.launchTimer = 0;
                return;
            }
            
            this.castX = GetUnitX(this.caster);
            this.castY = GetUnitY(this.caster);
            
            angle = GetRandomReal(0.0, 360.0);
            dist = GetRandomReal(0, this.damageArea);
            x = x + dist * Cos(angle * bj_DEGTORAD);
            y = y + dist * Sin(angle * bj_DEGTORAD);
            
            angle = GetUnitFacing(this.caster);
            dist = 60.0;
            startX = this.castX + dist * Cos(angle * bj_DEGTORAD);
            startY = this.castY + dist * Sin(angle * bj_DEGTORAD);
            
            missile = BubonicusMissile.create(startX, startY, 40.0, x, y, 0.0);
            this.missiles[this.launchCount] = missile;
            this.launchCount = this.launchCount + 1;
            
            missile.fxpath = thistype.MISSILE_EFFECT;
            missile.owner = this.castingPlayer;
            missile.setNukeObject(this);
            missile.scale = 1.5;
            missile.launch(600, 0.4);
        }
        
        private static method begin(unit caster, real x, real y, integer level) -> thistype {
            thistype this = 0;
            integer i = 0;
            
            if (Bubonicus[caster].count() == 0) {
                return this;
            }
            
            this = thistype.allocate();
            
            this.caster = caster;
            this.castingPlayer = GetOwningPlayer(this.caster);
            this.level = level;
            this.castX = GetUnitX(this.caster);
            this.castY = GetUnitY(this.caster);
            this.targetX = x;
            this.targetY = y;
        
            this.damage = xedamage.create();
            this.damagedUnitsAmount = Table.create();
            this.setup(this.level);
            
            this.canceled = false;
            this.launchCount = 0;
            this.launchTimer = 0;
            Bubonicus[this.caster].subtract(); // Costs 1 corpse
            
            this.launchTimer = GameTimer.newPeriodic(function(GameTimer t){
                thistype this = t.data();
                if ((ModuloInteger(this.launchCount, 8) == 0 &&
                     this.canceled) ||
                    this.launchCount >= 24) {
                    this.launchTimer.deleteLater();
                    this.launchTimer = 0;
                }
                else {
                    this.launchNext();
                    this.launchNext();
                    return;
                }
            });
            this.launchTimer.setData(this);
            this.launchTimer.start(0.05);

            return this;
        }
        
        public method cancel() {
            // Cancel's the internal timer loop
            this.canceled = true;
        }
        
        
        private method onDestroy(){
            this.damagedUnitsAmount.destroy();
            this.damage.destroy();
            if (this.launchTimer != 0) {
                this.launchTimer.deleteNow();
                this.launchTimer = 0;
            }
            this.caster = null;
            this.castingPlayer = null;
            thistype.instances.remove(this.index);
        }
        
        private static method onCast(){
            unit caster = GetSpellAbilityUnit();
            real x = GetSpellTargetX();
            real y = GetSpellTargetY();
            integer level = GetUnitAbilityLevel(caster, thistype.ABILITY_ID);
            integer id = GetUnitIndex(caster);
            thistype this = thistype.begin(caster, x, y, level);
            this.index = id;
            thistype.instances[id] = this;
        }
        
        public static method onSetup(){
            trigger t = CreateTrigger();
            GT_RegisterBeginsCastingEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onCast();
                return false;
            }));
            t = CreateTrigger();
            GT_RegisterStopsCastingEvent(t, thistype.ABILITY_ID);
            TriggerAddCondition(t, Condition(function() -> boolean {
                integer id = GetUnitIndex(GetTriggerUnit());
                thistype this = 0;
                if (id != 0 && thistype.instances.has(id)) {
                    this = thistype.instances[id];
                    this.cancel();
                }
                return false;
            }));
            t = null;
            XE_PreloadAbility(thistype.ABILITY_ID);
            
            thistype.instances = Table.create();
        }
    }
    
    private function onInit(){
        BubonicusNuke.onSetup.execute();
    }
}


//! endzinc