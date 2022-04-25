//! zinc
library DemoNuke requires GameTimer, GT, xefx, xebasic, xemissile, xepreload, IsUnitWall, xedamage, ItemExtras, IsUnitTitanHunter, Nukes, SpawnofDarkness {
    private struct NukeMissile extends xehomingmissile {
        private xedamage damage;
        integer spawnUnitId = 'n00I';
        real amount;
        integer spawnChance = 20;
        unit caster;
        private method onHit() {
            integer spawnChance;
            this.damage = xedamage.create();
            this.damage.dtype = DAMAGE_TYPE_MAGIC;
            this.damage.exception = UNIT_TYPE_MAGIC_IMMUNE;
            this.damage.useSpecialEffect("Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl","origin");
            this.amount = this.amount * getModifiers(this.caster, this.targetUnit);
            this.damage.damageTarget(this.caster, this.targetUnit, this.amount);
            this.damage.destroy();
            if(GetWidgetLife(this.targetUnit) < .405) {
                spawnChance = GetRandomInt(1, 100);
                if(spawnChance <= this.spawnChance) {
                    createSpawnOfDarkness(this.caster, GetUnitX(this.targetUnit), GetUnitY(this.targetUnit));
                }
            }
        }
    }
    
    private struct DemoNuke {
        private static constant integer abilityId = 'TDAQ';
        private static constant real timerInterval = .1;
        private static constant string missileEffect = "war3mapImported\\Model_Ability_Titan_Demonicus_Nuke(Missile).mdx";
        private static constant string chargeMissile = "war3mapImported\\DemonicusShardCharge.mdx";
        private NukeMissile dummyMissile;
        private unit caster;
        private real casterX;
        private real casterY;
        private real AOE;
        private real damageDone;
        private real spawnChance;
        private xedamage damage;
        
        private method setup(integer level) {
            //AOE is the base AOE of the spell
            this.AOE = 650;
            //damagePerSecond is how much damage charging does per second
            this.damageDone = 105+(25*level);
            //Spawn chance for spawns of darkness
            this.spawnChance = .2;
        }
        
        private static method damageFactor() -> real {
            return 1.33;
        }
        
        private method checkTarget(unit u) -> boolean {
        return IsUnitNukable(u, this.caster) &&
                IsUnitVisible(u, GetOwningPlayer(this.caster));
        }
        
        private method fireAtTargets() {
            group g = CreateGroup();
            unit tempUnit = null;
            unit spawnedUnit = null;
            real spawnChance;
            GroupEnumUnitsInRange(g, this.casterX, this.casterY, this.AOE, null);
            tempUnit = FirstOfGroup(g);
            while(tempUnit!=null) {
                if(this.checkTarget(tempUnit)) {
                    this.dummyMissile = NukeMissile.create(this.casterX, this.casterY, 100, tempUnit, 20);
                    this.dummyMissile.fxpath = this.missileEffect;
                    this.dummyMissile.amount = this.damageDone;
                    this.dummyMissile.caster = this.caster;
                    this.dummyMissile.launch(1600, .1);
                }
                GroupRemoveUnit(g, tempUnit);
                tempUnit=null;
                tempUnit = FirstOfGroup(g);
            }
            DestroyGroup(g);
            this.destroy();
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.casterX = GetUnitX(this.caster);
            this.casterY = GetUnitY(this.caster);
            this.setup(GetUnitAbilityLevel(this.caster, this.abilityId));
            this.fireAtTargets();
            return this;
        }
        
        private static method OnCast() {
            thistype.Begin(GetTriggerUnit());
        }
        
        private static method OnAbilitySetup() {
            trigger t = CreateTrigger();
            thistype this = thistype.allocate();
            integer id = this.abilityId;
            this.destroy();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
            TriggerAddCondition(t, Condition(function() -> boolean {
                if(GetSpellAbilityId() == thistype.abilityId) {
                    thistype.OnCast();
                }
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