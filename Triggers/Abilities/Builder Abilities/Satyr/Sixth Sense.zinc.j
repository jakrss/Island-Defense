//! zinc
library Blur {
    //How long to hit someone to refresh it
	private constant integer Ability_Blur = 'A0LJ';
	private constant integer Buff_Blur = 'B06L';
	private constant integer MagicResistance = 'A0LJ';
	private constant real TimerInterval = 0.25;
	private constant string Effect = "Model_Builder_Satyr_Ability_Blur(Detect)4.mdl";
	private constant integer Tech_Blur = 'R03R';
	private constant boolean SendDebug = false;
	private hashtable BlurHash = InitHashtable();
	
	private function SixthSense() {
		timer t = GetExpiredTimer();
		unit u = LoadUnitHandle(BlurHash, GetHandleId(t), 0);
		boolean Detected;
		boolean enemyfound = LoadBoolean(BlurHash, GetHandleId(u), 1);
		boolean hasEffect = LoadBoolean(BlurHash, GetHandleId(u), 4);
		integer i;
		//Only try to find an enemy if we already don't have one:
		if(!enemyfound) {
			i = 0;
			//Loop through players 0-14, stopping at the first enemy (as all enemies share vision).
			while(!enemyfound && i < 14) {
				if(!IsPlayerAlly(GetOwningPlayer(u), Player(i))) { enemyfound = true; }
				if(enemyfound) {
					if(SendDebug) { BJDebugMsg("Player " + I2S(i) + " is an enemy."); }
					SaveBoolean(BlurHash, GetHandleId(u), 1, enemyfound);
					SaveInteger(BlurHash, GetHandleId(u), 2, i);
				} else { i = i + 1; }
			}
			if(!enemyfound) { BJDebugMsg("|cffff0000Error: could not find an enemy!"); }
		}
		if(enemyfound) {
		i = LoadInteger(BlurHash, GetHandleId(u), 2);
		//Check if the unit is seen by the enemy found (meaning all enemies):
			Detected = !IsUnitInvisible(u, Player(i));
			//If the unit is detected:
			if(Detected) { 
				if(SendDebug) { BJDebugMsg("|cff00ff00Unit is detected by Player " + I2S(i)); }
				//And make effects:
				if(!hasEffect) {
					SaveEffectHandle(BlurHash, GetHandleId(u), 3, AddSpecialEffectTarget(Effect, u, "origin"));
					BlzSetSpecialEffectColor(LoadEffectHandle(BlurHash, GetHandleId(u), 3), 255, 0, 0);
					hasEffect = true;
					SaveBoolean(BlurHash, GetHandleId(u), 4, hasEffect);
				}
				//If the unit is not detected:
				} else if(!Detected) {
				if(SendDebug) { BJDebugMsg("|cffff0000Not detected."); }
				if(hasEffect) { DestroyEffect(LoadEffectHandle(BlurHash, GetHandleId(u), 3)); }
				hasEffect = false;
				SaveBoolean(BlurHash, GetHandleId(u), 4, hasEffect);
				}
			}
			//Now if the unit no longer has the buff, it no longer has the ability active and we end this check:
		if(!UnitHasBuffBJ(u, Buff_Blur)) {
			if(SendDebug) { BJDebugMsg("|cffff0000No buff, removing effects"); }
			enemyfound = false;
			hasEffect = false;
			DestroyEffect(LoadEffectHandle(BlurHash, GetHandleId(u), 3));
			FlushChildHashtable(BlurHash, GetHandleId(t));
			FlushChildHashtable(BlurHash, GetHandleId(u));
			DestroyTimer(t);
		}
		t = null;
		u = null;
	}
	
	private function onInit() {
		trigger t = CreateTrigger();
		TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
		TriggerAddCondition(t, function() {
			unit u;
			timer BlurTimer;
			sound SoundOnCast;
			if(GetSpellAbilityId() == Ability_Blur) {
				u = GetTriggerUnit();
				if(GetPlayerTechCount(GetOwningPlayer(u), Tech_Blur, true) == 2) {
					SoundOnCast = CreateSound("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImage.wav", false, true, false, 10, 10, "Spells");
					AttachSoundToUnit(SoundOnCast, u);
					SetSoundPitch(SoundOnCast, 1.6);
					SetSoundDistances(SoundOnCast, 1000, 100000);
					PlaySoundOnUnitBJ(SoundOnCast, 100, u);
					KillSoundWhenDone(SoundOnCast);
					BlurTimer = CreateTimer();
					TimerStart(BlurTimer, TimerInterval, true, function SixthSense);
					SaveUnitHandle(BlurHash, GetHandleId(BlurTimer), 0, u);
				}	
				
			}
			u = null;
			BlurTimer = null;
		});
		t = null;
	}
}
//! endzinc