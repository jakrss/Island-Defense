//! zinc
library SirenScepter requires ItemExtras, Apparition, DrawMagic {
    //Item ID
    private constant integer ITEM_ID = 'I02S';
    //Active ability ID
    private constant integer ABILITY_ID = 'A0EV';
	//Passive ability ID (Attack speed)
	private constant integer Ability_SirenSong = 'A0EQ';
	private constant integer Ability_SirenSongMana = 'A0ER';
    //Sight radius
    private constant integer SIGHT_RADIUS = 1500;
    //Sight radius duration
    private constant real ACTIVE_DURATION = 60.00;
    //Apparition Duration
    private constant real DURATION = 20.00;
    //Mana to restore on killing and killing unit marked with apparition permanently add
    private constant real MP_RESTORE = 65;
    private constant real MP_KILL = 10;
    
    
    private function onCast(){
        unit caster = GetTriggerUnit();
        real tX = GetSpellTargetX();
        real tY = GetSpellTargetY();
        boolean collide = false;
        real visDur = ACTIVE_DURATION;
        real impactAOE = SIGHT_RADIUS;
        
        CreateApparition(caster, tX, tY, collide, visDur, impactAOE);
    }
    
    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED);
        TriggerAddCondition(t, function() -> boolean {
            unit u = GetEventDamageSource();
            unit t = GetTriggerUnit();
			integer attackSpeedLevel = GetUnitAbilityLevel(u, Ability_SirenSong);
			integer uMaximMana = BlzGetUnitMaxMana(u);
			boolean bestRestore = true;
            trigger tr = GetTriggeringTrigger();
		//Other items with Draw Magic that are better than this one.
            if(UnitHasItemById(u, ITEM_ID) && !IsUnitAlly(t, GetOwningPlayer(u)) && bestRestore == true) {
                DisableTrigger(tr);
                if(BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL) {apparitionTarget(u, t, DURATION); }
				onDrawMagicAttack(u, t, GetEventDamage(), MP_RESTORE, MP_KILL, true, false);
				if(attackSpeedLevel < R2I(uMaximMana / 600)) {
					attackSpeedLevel = R2I(uMaximMana / 600);
					DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzyAOE\\UnholyFrenzyAOETarget.mdl", u, "origin"));
					SetUnitAbilityLevel(u, Ability_SirenSong, attackSpeedLevel);
				}
                EnableTrigger(tr);
            }
            u = null;
            tr = null;
            return false;
        });
        t=null;
        t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddCondition(t, function() -> boolean {
            if(GetSpellAbilityId() == ABILITY_ID) {
                onCast();
            }
            return false;
        });
        t=null;
		t = CreateTrigger();
		onAcquireItem(t);
		TriggerAddCondition(t, function() {
			unit u;
			item i = GetManipulatedItem();
			integer it = GetItemTypeId(i);
			if(it == ITEM_ID) {
				u = GetTriggerUnit();
				SetUnitAbilityLevel(u, Ability_SirenSongMana, GetHeroLevel(u));
				DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzyAOE\\UnholyFrenzyAOETarget.mdl", u, "origin"));
			}
		});
		t=null;
		t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_LEVEL);
		TriggerAddCondition(t, function() {
			unit u = GetTriggerUnit();
			if(UnitHasItemById(u, ITEM_ID)) {
				SetUnitAbilityLevel(u, Ability_SirenSongMana, GetHeroLevel(u));
				DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzyAOE\\UnholyFrenzyAOETarget.mdl", u, "origin"));
			}
		});
    }
    
}
//! endzinc
