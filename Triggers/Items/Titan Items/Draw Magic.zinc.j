//! zinc
library DrawMagic requires xemissile, xefx, xebasic, BUM {
    //Library for Draw Magic - Restores mana on hit and (sometimes permanently) on kill
    //My favorite soul stealer thing
    //Effect on mana heal
    private constant string EFFECT = "Abilities\\Spells\\Items\\Alma\\AlmaTarget.mdl";
    //Missile model
    private constant string MISSILE = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareMissile.mdl";
    private constant real MISSILE_SPEED = 400;
    private constant real MISSILE_ARC = .15;
    //Apparition buff
    private constant integer BUFF_ID = 'B04L';
    
    //Effect for mana burn
    private constant string MANA_BURN_EFFECT = "Abilities\\Spells\\Items\\Alma\\AlmaTarget.mdl";
    //Attack type of the burn
    private constant attacktype AT = ATTACK_TYPE_NORMAL;
    private constant damagetype DT = DAMAGE_TYPE_UNIVERSAL;
    private constant weapontype WT = WEAPON_TYPE_WHOKNOWS;
	
	//Yet another HASH setup:
	public hashtable DrawHash = InitHashtable();			
    
    struct StealMana extends xehomingmissile {
        integer MANA_ADD;
        
        method onHit() {
            addMaxMana(this.targetUnit, I2R(this.MANA_ADD));
            DestroyEffect(AddSpecialEffectTarget(EFFECT, this.targetUnit, "origin"));
        }
    }
    
    //Attacker, target, decimal percent of maximum mana to deal as bonus damage
    //public function manaBurnDamage(unit attacker, unit target, real mp) -> real {
    //    real damage = BlzGetUnitMaxMana(attacker) * mp;
    //    real curMP = GetUnitState(attacker, UNIT_STATE_MANA);
    //    
    //    if(curMP >= damage) {
    //        addMana(attacker, damage * -1);
    //        UnitDamageTarget(attacker, target, damage, false, false, AT, DT, WT);
	//		BJDebugMsg(R2S(damage));
    //        DestroyEffect(AddSpecialEffectTarget(MANA_BURN_EFFECT, target, "origin"));
    //    }
    //    return damage;
    //}
    
    public function addManaAttack(unit attacker, real MANA_RESTORE) {
        addMana(attacker, MANA_RESTORE);
        DestroyEffect(AddSpecialEffectTarget(EFFECT, attacker, "origin"));
    }
    
    public function addManaPerm(unit killer, unit dyer, integer MANA_ADD) {
        StealMana missile = StealMana.create(GetUnitX(dyer), GetUnitY(dyer), 100, killer, 20);
        missile.fxpath = MISSILE;
        missile.MANA_ADD = MANA_ADD;
        missile.launch(MISSILE_SPEED, MISSILE_ARC);
        killer = null;
        dyer = null;
    }
	
	public function checkDrawMagicCap(unit a) -> real {
		real MaxManaCap;
		
		if(UnitHasItemById(a, 'I02S')) { //Siren Scepter
			MaxManaCap = 3500;
		} else if(UnitHasItemById(a, 'I07S')) { //Foreteller's Sickle
				MaxManaCap = 3000;
			} else if(UnitHasItemById(a, 'I04P')) { //Crest of Immortal
					MaxManaCap = 2000;
				} else if(UnitHasItemById(a, 'I06P')) { //Farseer's Staff
						MaxManaCap = 2000;
					} else if(UnitHasItemById(a, 'I07W')) { //Crown of the Depths
							MaxManaCap = 1500;
						} else if(UnitHasItemById(a, 'I05Q')) { //Scepter of Apparition
								MaxManaCap = 1000;
								} else { //Summoner's Wrist Guard
									MaxManaCap = 500;
								}
		return MaxManaCap;
	}
    
    public function onDrawMagicAttack(unit a, unit t, real dmg, real mpAttack, real mpKill, boolean BuffEnhance, boolean restoreOnAttack ) {
		real currentManaBonus;
        //If they die from the damage.
		if(getHealth(t) <= dmg) {
			//All items restore mana on kill (regardless of buff).
				if(mpAttack >= 1.00) { 
					addManaAttack(a, mpAttack);
					//BJDebugMsg("Restoring mana, the unit dies");
				}
				//Check if the unit has exceeded the maximum mana benefit.
				currentManaBonus = LoadReal(DrawHash, GetHandleId(a), 0);
				if((currentManaBonus <= checkDrawMagicCap(a)) && mpKill >= 1.0) {
					//If the buff is required something should only happen if its found.
					if(BuffEnhance == true) {	
						if(GetUnitAbilityLevel(t, BUFF_ID) > 0) mpKill = mpKill * 3;
						addManaPerm(a, t, R2I(mpKill));
					}	
					//The buff is not required, maximum mana is added regardless of buff.
					if(BuffEnhance == false) {
						//BJDebugMsg("Buff not required on kill");
						//BJDebugMsg("So adding max mana on kill");
						addManaPerm(a, t, R2I(mpKill));
					}
					currentManaBonus = currentManaBonus + mpKill;
					//BJDebugMsg(R2S(currentManaBonus));
					//BJDebugMsg(R2S(checkDrawMagicCap(a)));
					SaveReal(DrawHash, GetHandleId(a), 0, currentManaBonus);
				}
			}
		//They don't die we restore mana on attack if the item says so.
		else {
            if(restoreOnAttack == true && mpAttack >= 1.0) {
				//BJDebugMsg("Target doesn't die");
				//BJDebugMsg("But restores mana regardless");
				addManaAttack(a, mpAttack); 
			}
		}
		//Do these break this?
		a = null;
		t = null;
    }
    
}
//! endzinc