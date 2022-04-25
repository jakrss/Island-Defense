//! zinc
library DemoWW requires GameTimer, GT {
    private struct DemoWW {
        private static constant integer abilityId = 'A096';
        private static constant integer invisAbilityId = 'A01X';
        private static constant integer etherityId = 'A099';
        private GameTimer durationTimer;
        private unit caster;
        private integer duration = 30;
        
        private method Help(boolean b) {
            //Outergroup is the players 0-9 (red is 0)
            integer outerGroup = 0;
            //Innergroup is the rest of the players except whichever player is currently targeted in the outer group
            integer innerGroup = 0;
            for(0 <= outerGroup <= 9) {
                for( 0 <= innerGroup <= 9) {
                    if(!(outerGroup == innerGroup)) {
                        SetPlayerAlliance(Player(outerGroup), Player(innerGroup), ALLIANCE_HELP_REQUEST, b);
                        SetPlayerAlliance(Player(outerGroup), Player(innerGroup), ALLIANCE_HELP_RESPONSE, b);
                    }
                }
            }
        }
        
        private static method Begin(unit caster) -> thistype {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.Help(false);
            SetUnitAbilityLevel(this.caster, this.abilityId, GetUnitAbilityLevel(this.caster, this.etherityId)+1);
            UnitAddAbility(this.caster, this.invisAbilityId);
            SetUnitAbilityLevel(this.caster, this.invisAbilityId, GetUnitAbilityLevel(this.caster, this.abilityId));
            this.durationTimer = GameTimer.new(function(GameTimer t) {
                thistype this = t.data();
                this.Help(true);
                UnitRemoveAbility(this.caster, this.invisAbilityId);
                this.durationTimer.deleteLater();
                this.destroy();
            }).start(this.duration);
            this.durationTimer.setData(this);
            return this;
        }
        
        private static method OnCast() {
            thistype.Begin(GetSpellAbilityUnit());
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
            t=null;
            t=CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_SKILL);
            TriggerAddCondition(t, function() -> boolean {
                if(GetLearnedSkill() == thistype.etherityId) {
                    IncUnitAbilityLevel(GetTriggerUnit(), thistype.abilityId);
                }
                return false;
            });
            t=null;
        }
        
        private static method onInit() {
            thistype.OnAbilitySetup.execute();
        }
    }
}
//! endzinc