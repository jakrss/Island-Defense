//! zinc
library VoltronUnique requires GameTimer, xedamage, IsUnitWall, xefx {
    private struct VoltronUnique {
        private static integer abilityId = 'TVAR';
        private unit caster;
        private unit lastUnit;
        private integer bounceAmount;
        private real damagePercent;
        private string effectString;
        private group bounceGroup;
        private integer bounceCounter;
        private real bounceAOE;
        private real damageAmount;
        private real bounceSpeed = .2;
        private xedamage damage;
        private xefx dummyFX;
        private GameTimer bounceTimer;
        
        private method Setup(integer level) {
            //To how many walls should it bounce
            this.bounceAmount = 1+(1*level);
            //How much of his damage done to the wall should it do?
            //This is physical damage done so if he hits a wall for 100 it'll do this
            this.damagePercent = (.1*level);
            //The effect to show on hit
            this.effectString = "war3mapImported\\LightningSphere_FX.mdx";
            //How far do we look to bounce?
            this.bounceAOE = 250;
            //Ignore this, group needed to track who's been bounced
            this.bounceGroup = CreateGroup();
            //Initialize the counter variable
            this.bounceCounter = 0;
        }
        
        private method CheckDistance(real x, real y, real tX, real tY) -> real {
            real dx = tX - x;
            real dy = tY - y;
            return SquareRoot(dx * dx + dy * dy);
        }
        
        private method DamageTarget() {
            this.dummyFX = xefx.create(GetUnitX(this.lastUnit), GetUnitY(this.lastUnit), bj_UNIT_FACING);
            this.dummyFX.fxpath = this.effectString;
            this.dummyFX.z = 50;
            this.damage.tag = 19;
            this.damage.damageTarget(this.caster, this.lastUnit, this.damageAmount);
            this.dummyFX.destroy();
        }
        
        private method CheckTarget(unit u) -> boolean {
            return IsUnitWall(u) && IsUnitEnemy(u, GetOwningPlayer(this.caster)) && !IsUnitInGroup(u, this.bounceGroup);
        }
        
        private method tick() {
            real x = GetUnitX(this.lastUnit);
            real y = GetUnitY(this.lastUnit);
            group g = CreateGroup();
            unit u = null;
            real leastDistance=this.bounceAOE;
            real curDistance;
            real maxMana;
            real currentMana;
            if(this.bounceCounter < this.bounceAmount) {
                GroupEnumUnitsInRange(g, x, y, this.bounceAOE, null);
                u=FirstOfGroup(g);
                while(u!=null) {
                    if(this.CheckTarget(u)) {
                        curDistance = this.CheckDistance(x, y, GetUnitX(u), GetUnitY(u));
                        if(curDistance < leastDistance) {
                            leastDistance = curDistance;
                            this.lastUnit = u;
                        }
                    }
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
                DestroyGroup(g);
                u=null;
                this.bounceCounter += 1;
                this.DamageTarget();
                maxMana = GetUnitState(this.lastUnit, UNIT_STATE_MAX_MANA);
                currentMana = GetUnitState(this.lastUnit, UNIT_STATE_MANA);
                if(maxMana > 10) {
                    this.damageAmount = GetHeroLevel(this.caster)*2;
                    if(currentMana > this.damageAmount) {
                        SetUnitState(this.lastUnit, UNIT_STATE_MANA, currentMana - this.damageAmount);
                    }
                }
                GroupAddUnit(this.bounceGroup, this.lastUnit);
            } else {
                DestroyGroup(g);
                DestroyGroup(this.bounceGroup);
                u=null;
                this.damage.destroy();
                this.bounceTimer.destroy();
                this.destroy();
            }
        }
        
        private static method Begin(unit attacked, unit attacker) -> thistype {
            thistype this = thistype.allocate();
            this.caster = attacker;
            this.Setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.damage = xedamage.create();
            this.damage.dtype = DAMAGE_TYPE_UNIVERSAL;
            this.damageAmount = GetEventDamage() * this.damagePercent;
			//Let's check if Voltron is Discharged, so the damage amount should be higher:
			if(GetUnitAbilityLevel(attacker, 'B077') > 0) {
				this.damageAmount = this.damageAmount + (20 + GetUnitAbilityLevel(attacker, 'TVA0') * 15);
				UnitRemoveBuffBJ('B077', attacker);
			}
			//-----------------------------------------------------------------------------
            this.lastUnit = attacked;
            this.DamageTarget();
            this.bounceTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.bounceSpeed);
            this.bounceTimer.setData(this);
            return this;
        }
        
        private static method onAttackSetup(){
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit a = GetEventDamageSource();
                unit u = GetTriggerUnit();
                real damage = GetEventDamage();
                //Purely checking for Voltron doing damage on a wall:
                if (BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL && IsUnitWall(u) && GetUnitAbilityLevel(a, 'TVAS') > 0) {
					//If Voltron has unique the effect removes the buff from him - we know he is attacking a wall already:
					if(GetUnitAbilityLevel(a, 'TVAR') > 0 ) {
						thistype.Begin(u, a);
					//Now Voltron attacks a wall, but he does not have a passive, but if he is Discharged, we should remove the buff:
					} else if(GetUnitAbilityLevel(a, 'B077') > 0 ) {
						//Turns out that we can just roll the unique here too, since the bouncecount and damage% are actually 0 then.
						thistype.Begin(u, a);
					}
                }
                a = null;
                u = null;
                return false;
            }));
            t=null;
        }
		
		private static method onInit() {
			thistype.onAttackSetup.execute();
		}
    }
}
//! endzinc