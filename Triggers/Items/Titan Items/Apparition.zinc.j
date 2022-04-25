//! zinc
library Apparition requires xecast, xefx, xebasic, xemissile, TimerUtils, BonusMod {
    //This is to create an Apparition missile
    //Apparition buff
    private constant integer BUFF_ID = 'B04L';
    //Dummy Ability to Apply BUFF
    private constant integer DUMMY_ABIL_ID = 'A0EU';
    //On Impact Ability / Items
	private constant integer I_SCEPTER = 'I05Q';
    private constant integer I_FARSEER = 'I06P';
	private constant integer I_SICKLE = 'I07S';
	private constant integer I_SIREN = 'I02S';
	private constant integer OI_SCEPTER = 'A0E6';
    private constant integer OI_FARSEER = 'A0NQ';
	private constant integer OI_SICKLE_SIREN = 'A0NW';
    //AOE around missile to detect units
    private constant real AOE = 300;
    //Missile Model
    private constant string MISSILE_MODEL = "Missile_Apparition_Missile.mdx";
    //ORDER ID for Wand of Shadowsight
    private constant integer ORDERID = 852570;
    //Order ID for AOE ability
    private constant integer IMPACT_ORDERID = 852122;
    //Ability Real Field of the Area of Effect of the ON_IMPACT_ID ability
    private constant abilityreallevelfield AOE_MOD = ABILITY_RLF_AREA_OF_EFFECT;
    private hashtable appTable = InitHashtable();
    private group hitGroup = CreateGroup();
    
    
    //Mini missile to keep track of the target
    struct miniMissile extends xehomingmissilewithvision {
        unit caster;
        
        method onHit() {
            xecast dummyCast;
            if(GetUnitAbilityLevel(this.targetUnit, BUFF_ID) == 0) {
                dummyCast = xecast.createBasicA(DUMMY_ABIL_ID, ORDERID, GetOwningPlayer(this.caster));
                dummyCast.castOnTarget(this.targetUnit);
                
                GroupRemoveUnit(hitGroup, this.targetUnit);
            }
        }
    }
    
    //We store the caster, the number of units hit, whether or not it collides with a unit
    //(explodes on contact), the vision abilities duration and the AOE of the vision ability
    //on contact with the end target X/Y or on impact
	
	private function getImpactSettings(unit u) -> integer {
		integer i;
		if(UnitHasItemById(u, I_SICKLE) || UnitHasItemById(u, I_SIREN)) { i = OI_SICKLE_SIREN;
			} else if(UnitHasItemById(u, I_SICKLE)) { i = OI_FARSEER;
				} else if(UnitHasItemById(u, I_SCEPTER)) { i = OI_SCEPTER;
					} else i = 0;
		return i;
	}
	
    struct ApparitionMissile extends xemissilewithvision {
        unit caster;
        integer index = 0;
        boolean collide = false;
        real visionDuration = 5;
        real impactAOE = 350;

        method onHit() {
            xecast dummyUnit = xecast.createBasicA(getImpactSettings(caster), IMPACT_ORDERID, GetOwningPlayer(this.caster));
            dummyUnit.castOnPoint(this.x, this.y);
        }
        
        method loopControl() {
            group g;
            unit u;
            miniMissile h;
            
            if(this.index >= 10) {
                g = CreateGroup();
                u=null;
                if(!this.collide) {
                    GroupEnumUnitsInRange(g, this.x, this.y, AOE, null);
                } else {
                    GroupEnumUnitsInRange(g, this.x, this.y, 100, null);
                }
                u=FirstOfGroup(g);
                while(u != null) {
                    if(GetUnitAbilityLevel(u, BUFF_ID) == 0 && IsUnitAliveBJ(u) && !IsUnitAlly(u, GetOwningPlayer(this.caster)) && !IsUnitType(u, UNIT_TYPE_STRUCTURE) && !IsUnitInGroup(u, hitGroup)) {
                        h = miniMissile.create(this.x, this.y, 50, u, 10);
                        h.caster = this.caster;
                        h.owner = GetOwningPlayer(this.caster);
                        h.fxpath = MISSILE_MODEL;
                        h.launch(800, .15);
                        GroupAddUnit(hitGroup, u);
                        if(this.collide && !IsUnitType(u, UNIT_TYPE_STRUCTURE) && IsUnitEnemy(u, GetOwningPlayer(this.caster))) {
                            DestroyGroup(g);
                            u = null;
                            this.onHit();
                        }
                    }
                    GroupRemoveUnit(g, u);
                    u=null;
                    u=FirstOfGroup(g);
                }
                DestroyGroup(g);
                this.index = 0;
            } else {
                this.index = this.index + 1;
            }
        }
    }
    
    public function CreateApparition(unit caster, real tX, real tY, boolean collide, real visDur, real impactAOE) {
        ApparitionMissile a = ApparitionMissile.create(GetUnitX(caster),GetUnitY(caster), 80, tX, tY, 50);
        a.caster = caster;
        a.owner = GetOwningPlayer(caster);
        a.collide = collide;
        a.visionDuration = visDur;
        a.impactAOE = impactAOE;
        a.fxpath = MISSILE_MODEL;
        a.scale = 3;
        a.launch(800, .15);
    }
        
    public function apparitionTarget(unit caster, unit target, real duration) {
        xecast dummyCast;
        if(GetUnitAbilityLevel(target, BUFF_ID) == 0) {
            dummyCast = xecast.createBasicA(DUMMY_ABIL_ID, ORDERID, GetOwningPlayer(caster));
            dummyCast.castOnTarget(target);
        }
        caster = null;
        target = null;
    }
}

//! endzinc