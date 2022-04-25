//! zinc
library BreezeriousNuke requires GameTimer, GT, xepreload, xebasic, xedamage, xecast, ItemExtras, IsUnitTitanHunter, Nukes {
    private struct UnitHit {
        unit u;
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.u = u;
            return this;
        }
    }
    private struct BreezeriousNuke {
        private static integer abilityId = 'A094';
        private static string cycloneEffect = "Abilities\\Spells\\Other\\Tornado\\TornadoElemental.mdl";
        private static integer dummyId = 'u00R';
        private static integer stunId = 'A09K';
        private static integer stunBuffId = 'Bcyc';
        private static integer gustBuffId = 'B041';
        private static integer uniqueAbilityId = 'A0D4';
        private real maxDistance;
        private real currentDistance;
        private real maxMovespeed;
        private real startingMovespeed;
        private real currentMovespeed;
        private real startingStun;
        private real maxStun;
        private real currentStun;
        private real damageToDo;
        private real targetX;
        private real targetY;
        private real casterX;
        private real casterY;
        private real dummyX;
        private real dummyY;
        private real startingScale;
        private real currentScale;
        private real maxScale;
        private real currentAOE;
        private real maxAOE;
        private real startingAOE;
        private real angle;
        private unit caster;
        private real distanceTraveled;
        private real timerSpeed = .03125;
        private group unitsHit;
        private xedamage damage;
        private GameTimer periodicTimer;
        private unit cycloneMissile;
        private xecast dummyCaster;
        
        private method setup(integer level) {
            //Distance to travel
            this.maxDistance = 700.00;
            //How far it's currently traveled
            this.currentDistance = 0.0;
            //How fast is the MAX it should travel at the end of it's lifetime?
            this.maxMovespeed = 1400;
            //How fast should it start out?
            this.startingMovespeed = 800;
            //Set the current movespeed to the starting
            this.currentMovespeed = this.startingMovespeed;
            //Minimum cyclone time
            this.startingStun = .1;
            //Maximum stun time - Not including other abilities buffs
            this.maxStun = .75;
            //Current stun ime
            this.currentStun = this.startingStun;
            //How much damage should it do?
            this.damageToDo = 105 + (25 * level);
            //Starting size of the projectile
            this.startingScale = .3;
            //Max scale of the projectile
            this.maxScale = 1.2;
            //Set the current scale
            this.currentScale = this.startingScale;
            //Max AOE to pick up units
            this.maxAOE = 240;	//Used to be 275
            //Starting AOE to pick up units
            this.startingAOE = 150;
            //Set the current AOE
            this.currentAOE = this.startingAOE;
            //Set the distance traveled
            this.distanceTraveled = 0;
            //Create our units hit group
            this.unitsHit = CreateGroup();
            if(GetUnitAbilityLevel(this.caster, this.uniqueAbilityId) > 0) {
                this.maxStun = .75 * (1+(.5*GetUnitAbilityLevel(this.caster, this.uniqueAbilityId)));
            }
        }
        
        private method CheckTarget(unit u) -> boolean {
            return !IsUnitAlly(u, GetOwningPlayer(this.caster)) &&
                UnitAlive(u) && !(IsUnitType(u, UNIT_TYPE_STRUCTURE)) && !IsUnitInGroup(u, this.unitsHit) &&
                !BlzIsUnitInvulnerable(u);
        }
        
        private method unitHit(unit u) {
            GameTimer stunTimer;
            UnitHit uh = UnitHit.create(u);
            this.damage = xedamage.create();
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_MAGIC_IMMUNE;
            this.damageToDo = this.damageToDo * getModifiers(this.caster, u);
            this.damage.damageTarget(this.caster, u, this.damageToDo);
            this.damage.destroy();
            if(GetWidgetLife(u) > .405) {
                if(GetUnitAbilityLevel(u, this.gustBuffId) > 0) {
                    this.currentStun = this.currentStun + .5;
                }
                this.dummyCaster = xecast.createBasicA(this.stunId, 852144, GetOwningPlayer(this.caster));
                this.dummyCaster.castOnTarget(u);
                stunTimer = GameTimer.new(function (GameTimer t) {
                    UnitHit this = t.data();
                    UnitRemoveAbility(this.u, 'Bcyc');
                    UnitRemoveAbility(this.u, 'Bcy2');
                    SetUnitInvulnerable(this.u, false);
                    this.destroy();
                }).start(this.currentStun);
                stunTimer.setData(uh);
            }
        }
        
        private method tick() {
            real newX;
            real newY;
            real distancePercent;
            group g = CreateGroup();
            unit u = null;
            this.distanceTraveled += (this.currentMovespeed * this.timerSpeed);
            distancePercent = this.distanceTraveled / this.maxDistance;
            this.dummyX = GetUnitX(this.cycloneMissile);
            this.dummyY = GetUnitY(this.cycloneMissile);
            this.currentMovespeed = this.maxMovespeed * distancePercent;
            this.currentAOE = this.maxAOE * distancePercent;
            this.currentScale = this.maxScale * distancePercent;
            this.currentStun = this.maxStun * distancePercent;
            if(this.currentMovespeed < this.startingMovespeed) { this.currentMovespeed = this.startingMovespeed; }
            if(this.currentAOE < this.startingAOE) { this.currentAOE = this.startingAOE; }
            if(this.currentScale < this.startingScale) { this.currentScale = this.startingScale; }
            if(this.currentStun < this.startingStun) { this.currentStun = this.startingStun; }
            SetUnitScale(this.cycloneMissile, this.currentScale, this.currentScale, this.currentScale);
            if(this.distanceTraveled > this.maxDistance) {
                DestroyGroup(g);
                u=null;
                this.periodicTimer.deleteLater();
                UnitApplyTimedLife(this.cycloneMissile, 'BTLF', .2);
                this.destroy();
            } else {
                newX = this.dummyX + (this.currentMovespeed * this.timerSpeed) * Cos(this.angle * bj_DEGTORAD);
                newY = this.dummyY + (this.currentMovespeed * this.timerSpeed) * Sin(this.angle * bj_DEGTORAD);
                SetUnitX(this.cycloneMissile, newX);
                SetUnitY(this.cycloneMissile, newY);
                GroupEnumUnitsInRange(g, newX, newY, this.currentAOE, null);
                u=FirstOfGroup(g);
                while(u!=null) {
                    if(this.CheckTarget(u)) {
                        GroupAddUnit(this.unitsHit, u);
                        this.unitHit(u);
                    }
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
            }
            DestroyGroup(g);
            u=null;
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            unit u;
            this.caster = caster;
            this.setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            this.targetX = GetSpellTargetX();
            this.targetY = GetSpellTargetY();
            this.angle = bj_RADTODEG * Atan2(this.targetY - this.casterY, this.targetX - this.casterX);
            this.targetX = this.casterX + this.maxDistance * Cos(this.angle * bj_DEGTORAD);
            this.targetY = this.casterY + this.maxDistance * Sin(this.angle * bj_DEGTORAD);
            this.cycloneMissile = CreateUnit(GetOwningPlayer(this.caster), this.dummyId, this.casterX, this.casterY, bj_UNIT_FACING);
            SetUnitScale(this.cycloneMissile, this.startingScale, this.startingScale, this.startingScale);
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            return this;
        }
        
        private static method OnCast() {
            unit caster = GetSpellAbilityUnit();
            thistype.Begin(caster);
        }
        
        private static method OnAbilitySetup() {
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId;
            this.destroy();
            GT_RegisterStartsEffectEvent(t, id);
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.OnCast();
                return false;
            }));
            XE_PreloadAbility(id);
        }
        
        private static method onInit() {
            thistype.OnAbilitySetup.execute();
        }
    }
}
//! endzinc