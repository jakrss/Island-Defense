//! zinc
library BreezeriousWW requires GameTimer, GT, xebasic, xefx {
    private struct BreezeriousWW {
    //CONFIGURABLE VARIABLES
        private static integer abilityId = 'A0CA';
        private unit caster;
        //How long does it take for the clouds to come in?
        private real fadeTime = 2.0;
        //How far out do they start?
        private real radius = 500;
        //How many clouds? UPDATE BELOW NON-CONFIGURABLES SIZE IF YOU MODIFY THIS NUMBER
        private real cloudCount = 6;
        //Whats the effect used for the clouds?
        private string cloudEffect = "Model_Ability_BreezeriousStealth.mdx";
        //Rate of Change of Angle (How fast we create spirals)
        private real ROC = 3;
    //NON-CONFIGURABLE VARIABLES (NEEDED FOR OPERATION)
        //Dummy Units array
        private xefx dummyUnits[6];
        //Angles array to continuously change the angle
        private real dummyAngles[6];
        //GameTimer to tick this biatch
        private GameTimer periodicTimer;
        //Timer Speed, best to leave it alone
        private real timerSpeed = .03125;
        //Speed that we need to move to get there in time
        private real speed = (radius/fadeTime)*timerSpeed;
        //Distance to keep track of how far they should remain
        private real distance = radius;
        //X and Y of casters original location
        private real casterX;
        private real casterY;
        
        private method tick() {
            real x = this.casterX;
            real y = this.casterY;
            real xOffset;
            real yOffset;
            integer i;
            integer z;
            this.distance = this.distance - this.speed;
            for(0<=i<this.cloudCount) {
                this.dummyAngles[i] = this.dummyAngles[i] - this.ROC;
                xOffset = x + this.distance * Cos(this.dummyAngles[i]);
                yOffset = y + this.distance * Sin(this.dummyAngles[i]);
                this.dummyUnits[i].x = xOffset;
                this.dummyUnits[i].y = yOffset;
            }
            if(this.distance <= 50) {
                this.periodicTimer.deleteLater();
                for(0<=z<this.cloudCount) {
                    this.dummyUnits[z].destroy();
                }
                this.destroy();
            }
        }
        
        private static method Begin() -> thistype {
            thistype this = thistype.allocate();
            real angle = 0;
            real x;
            real y;
            integer i;
            real xOffset;
            real yOffset;
            this.caster = GetSpellAbilityUnit();
            x = GetUnitX(this.caster);
            y = GetUnitY(this.caster);
            this.casterX = x;
            this.casterY = y;
            for(0<=i<this.cloudCount) {
                xOffset = x + this.radius * Cos(angle * bj_DEGTORAD);
                yOffset = x + this.radius * Sin(angle * bj_DEGTORAD);
                this.dummyUnits[i] = xefx.create(xOffset, yOffset, bj_UNIT_FACING);
                this.dummyUnits[i].fxpath = cloudEffect;
                this.dummyUnits[i].scale = .3;
                this.dummyUnits[i].z = 200;
                this.dummyAngles[i] = angle;
                angle+=(360/this.cloudCount);
            }
            this.periodicTimer = GameTimer.newPeriodic(function (GameTimer t) {
                thistype this = t.data();
                this.tick();
            }).start(this.timerSpeed);
            this.periodicTimer.setData(this);
            return this;
        }
        
        private static method onInit() {
            trigger t=CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
            TriggerAddCondition(t, function() -> boolean {
                if(GetSpellAbilityId() == thistype.abilityId) {
                    thistype.Begin();
                }
                return false;
            });
            t=null;
        }
    }
}
//! endzinc