//! zinc
library BreezeriousHeal requires GameTimer, xemissile, xedamage, UnitAlive, UnitMaxState, Healing {
    private struct HealMissile extends xehomingmissile {
        private xedamage heal;
        real amount;
        unit caster;
        unit target;
        private method onHit() {
            this.heal = xedamage.create();
            this.heal.damageSelf = true;
            this.heal.damageAllies = true;
            this.heal.damageEnemies = false;
            this.heal.damageNeutral = false;
            this.heal.allyfactor = -1.0;
            
            this.heal.damageTarget(this.caster, this.target, this.amount);
            this.heal.destroy();
        }
    }

    private struct BreezeriousHeal {
        private static integer abilityId = 'A0CT';
        private static string missileEffect = "TBAEMissile.mdx";
        private static integer dummyId = 'n02B';
        private static integer uniqueAbilityId = 'A0D4';
        private unit caster;
        private unit dummyUnit[4];
        private real angle[4];
        private GameTimer periodicTimer;
        private real timerSpeed = .03125;
        private real timerCount = 0;
        private static integer timerTicks = 20;
        private real HPS = 60 * timerSpeed * thistype.timerTicks;
        private real duration = 10;
        private real AOE = 600;
        private real orbOffset = 400;
        //Rotation speed in degrees per second
        private real rotationSpeed = 20 * timerSpeed;
        private integer numOrbs;
        //Orbs HP Regen
        private real orbHPR;
        //Orbs HP
        private real orbHP;
        //Does it target the lowest HP ally in range?
        private boolean lowestHP = true;
        
        private method setup(integer level) {
            this.orbHP = 200 + (level * 200);
            this.orbHPR = 4 * level * this.timerSpeed;
            this.numOrbs = level;
            if(GetUnitAbilityLevel(this.caster, this.uniqueAbilityId) > 0) {
                this.orbHP = 400 + (level * 200) + I2R(GetUnitAbilityLevel(this.caster, this.uniqueAbilityId) * 200);
            }
        }
        
        private method CheckTarget(unit u) -> boolean {
            return IsUnitAlly(u, GetOwningPlayer(this.caster)) && 
            !IsUnitType(u, UNIT_TYPE_MECHANICAL) &&
            GetWidgetLife(u) > .405 &&
            GetUnitTypeId(u) != this.dummyId;
        }
        
        private method CheckOrbsHP() -> boolean {
            integer i;
            boolean dummyAlive = true;
            for(0<i<=this.numOrbs) {
                if(GetWidgetLife(this.dummyUnit[i]) > .405) {
                    return true;
                }
            }
            return false;
        }
        
        private method tick() {
            integer i=0;
            real casterx = GetUnitX(this.caster);
            real castery = GetUnitY(this.caster);
            real offsetx;
            real offsety;
            HealMissile h;
            group g;
            unit u=null;
            unit lowUnit=null;
            this.timerCount += 1;
            for(0<=i<=this.numOrbs) {
                if(!this.CheckOrbsHP()) {
                    this.periodicTimer.deleteLater();
                    this.destroy();
                    break;
                } else if(GetWidgetLife(this.dummyUnit[i]) > .405) {
                    this.angle[i] += this.rotationSpeed;
                    offsetx = casterx + this.orbOffset * Cos(this.angle[i] * bj_DEGTORAD);
                    offsety = castery + this.orbOffset * Sin(this.angle[i] * bj_DEGTORAD);
                    SetUnitX(this.dummyUnit[i], offsetx);
                    SetUnitY(this.dummyUnit[i], offsety);
                    SetWidgetLife(this.dummyUnit[i], GetWidgetLife(this.dummyUnit[i]) + this.orbHPR);
                    if(this.timerCount >= this.timerTicks) {
                        g=CreateGroup();
                        GroupEnumUnitsInRange(g, offsetx, offsety, this.AOE, null);
                        u=FirstOfGroup(g);
                        while(u!=null) {
                            if(this.CheckTarget(u)) {
                                if(this.lowestHP) {
                                    if(lowUnit == null) {
                                        lowUnit = u;
                                    } else if((GetUnitState(u, UNIT_STATE_LIFE)/GetUnitState(u, UNIT_STATE_MAX_LIFE)) < (GetUnitState(lowUnit, UNIT_STATE_LIFE)/GetUnitState(lowUnit, UNIT_STATE_MAX_LIFE))) {
                                        lowUnit = u;
                                    } else if(!this.lowestHP) {
                                        h = HealMissile.create(offsetx, offsety, 100, u, GetUnitFlyHeight(u));
                                        h.fxpath = this.missileEffect;
                                        h.amount = this.HPS;
                                        h.caster = this.caster;
                                        h.launch(800, .15);
                                        break;
                                    }
                                }
                            }
                            GroupRemoveUnit(g, u);
                            u=null;
                            u=FirstOfGroup(g);
                        }
                        h = HealMissile.create(offsetx, offsety, 100, lowUnit, GetUnitFlyHeight(lowUnit));
                        h.fxpath = this.missileEffect;
                        h.amount = this.HPS;
                        h.target = lowUnit;
                        h.caster = this.caster;
                        h.launch(800, .15);
                        DestroyGroup(g);
                        u=null;
                        lowUnit = null;
                    }
                }
            }
            if(this.timerCount >= this.timerTicks) {
                this.timerCount = 0;
            }
        }
        
        private static method Begin() -> thistype {
            thistype this = thistype.allocate();
            real casterx;
            real castery;
            real offsetx;
            real offsety;
            integer i;
            this.caster = GetTriggerUnit();
            this.setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            casterx = GetUnitX(this.caster);
            castery = GetUnitY(this.caster);
            for(0<i<=this.numOrbs) {
                this.angle[i] = (360/this.numOrbs)*i;
                offsetx = casterx + this.orbOffset * Cos(this.angle[i] * bj_DEGTORAD);
                offsety = castery + this.orbOffset * Sin(this.angle[i] * bj_DEGTORAD);
                this.dummyUnit[i] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), this.dummyId, offsetx, offsety, bj_UNIT_FACING);
                SetUnitMaxState(this.dummyUnit[i], UNIT_STATE_MAX_LIFE, this.orbHP);
                UnitApplyTimedLife(this.dummyUnit[i], 'BTLF', this.duration);
            }
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            return this;
        }
    
        private static method onInit() {
            trigger t = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
            TriggerAddCondition(t, function() -> boolean {
                if(GetSpellAbilityId() == thistype.abilityId) {
                    thistype.Begin();
                }
                return false;
            });
        }
    }
}
//! endzinc