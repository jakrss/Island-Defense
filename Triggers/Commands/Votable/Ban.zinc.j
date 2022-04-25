//! zinc

library BanTweak requires TweakManager {
    public struct BanTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Ban Random";
        }
        public method shortName() -> string {
            return "BAN";
        }
        public method description() -> string {
            return "Bans up to " + I2S(GameSettings.getInt("PICKMODE_RACE_BAN_MAX")) + " Defender races and " + I2S(GameSettings.getInt("PICKMODE_RACE_BAN_MAX_TITANS")) + 
			" Titans from being randomed.";
        }
        public method command() -> string {
            return "-ban,-b,-banrandom";
        }
        
        public method activate(Args args){
            PlayerData p = 0;
            integer index = 0;
            integer class = 0;
            string match = "";
            Race r = 0;
            integer max = GameSettings.getInt("PICKMODE_RACE_BAN_MAX");
            p = PlayerData.get(GetTriggerPlayer());
            
            if (p.class() != PlayerData.CLASS_TITAN &&
                p.class() != PlayerData.CLASS_DEFENDER) {
                return;
            }
			
			if (p.class() == PlayerData.CLASS_TITAN) {
				max = GameSettings.getInt("PICKMODE_RACE_BAN_MAX_TITANS");
			}
            
            if (PlayerDataPick.initialized() &&
				RacePicker.state() == RacePicker.STATE_RUNNING &&
                !PlayerDataPick[p].hasPicked()){
                
                if (PlayerDataPick[p].hasRandomBans()) {
                    p.say("|cff00bfffCleared your previous banlist.|r");
                    PlayerDataPick[p].clearRaceRandomBans();
                }
                
                while (index < args.size()) {
                    if (index == max) {
                        p.say("|cffff0000Only " + I2S(max) + " races are allowed to be banned.|r");
                        break;
                    }
                    match = args[index].getStr();
                    if (p.class() == PlayerData.CLASS_TITAN) {
                        r = TitanRace.fromNamePartial(match, true);
                    }
                    else if (p.class() == PlayerData.CLASS_DEFENDER) {
                        r = DefenderRace.fromNamePartial(match, true);
                    }
                    
                    if (r != NullRace.instance()) {
                        PlayerDataPick[p].addRaceRandomBan(r);
                        p.say("|cff00bfffBanned " + r.toString() + " from being randomed (" + I2S(index + 1) + "/" + I2S(max) + ").|r");
                    }
                    else {
                        p.say("|cffff0000Unknown or conflicting race: |r" + match);
                    }
                    
                    debug {
                        p.say("\tID: " + I2S(r));
                        
                        if (PlayerDataPick[p].isRaceBanned(r)) {
                            p.say("\tBanned: true");
                        }
                        else {
                            p.say("\tBanned: false");
                        }
                    }
                    index = index + 1;
                }
                
                if (PlayerDataPick[p].hasRandomBans()) {
                    if (GetLocalPlayer() == p.player()){
                        PlaySoundBJ(gg_snd_Builder_YouveDoneWell);
                    }
                }
            }
			else {
				p.say("|cffff0000Now is not the right time to be using the |cff00bfff" + this.shortName() + "|r |cffff0000command. Try again another time.|r");
			}
        }
    }
}
//! endzinc