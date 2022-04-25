//! zinc

library PlayerDataPickRandoming {
    public module PlayerDataPickRandoming {
        public static method getRandomRace(integer class) -> Race {
            if (class == PlayerData.CLASS_TITAN){
                return TitanRace.random();
            }
            else if (class == PlayerData.CLASS_DEFENDER){
                return DefenderRace.random();
            }
            return NullRace.instance();
        }
        
        public static method getRandomRaceUniqueEx(integer class) -> Race {
            integer i = 0;
            integer count = 0;
            Race options[];
            if (class == PlayerData.CLASS_TITAN){
                for (0 <= i < TitanRace.count()){
                    if (TitanRace[i].inRandomPool() && PlayerData.countRace(TitanRace[i]) == 0){
                        options[count] = TitanRace[i];
                        count = count + 1;
                    }
                }
            }
            else if (class == PlayerData.CLASS_DEFENDER){
                for (0 <= i < DefenderRace.count()){
                    if (DefenderRace[i].inRandomPool() && PlayerData.countRace(DefenderRace[i]) == 0){
                        options[count] = DefenderRace[i];
                        count = count + 1;
                    }
                }
            }
            if (count > 0){
                // Return a random available race
                return options[GetRandomInt(0, count - 1)];
            }
            else {
                // Failed to find a unique random - not enough races.
                return thistype.getRandomRace(class);
            }
        }
		
		public static method getPlayerDataPickRandomRaceUniqueWithBans(PlayerDataPick this) -> Race {
            integer i = 0;
            integer count = 0;
            integer class = this.class();
            Race options[];
            Race r = 0;
            if (class == PlayerData.CLASS_TITAN){
                for (0 <= i < TitanRace.count()){
                    r = TitanRace[i];
                    if (r.inRandomPool() && 
                        PlayerData.countRace(r) == 0 &&
                        !this.isRaceBanned(r)){
                        options[count] = r;
                        count = count + 1;
                    }
                }
            }
            else if (class == PlayerData.CLASS_DEFENDER){
                for (0 <= i < DefenderRace.count()){
                    r = DefenderRace[i];
                    if (r.inRandomPool() && 
                        PlayerData.countRace(r) == 0 &&
                        !this.isRaceBanned(r)){
                        options[count] = r;
                        count = count + 1;
                    }
                }
            }
            if (count > 0){
                // Return a random available race
                r = options[GetRandomInt(0, count - 1)];
            }
            else {
                // Failed to find a unique random with bans - not enough races.
                this.say("|cffff0000WARNING: Failed to acquire unique random race with bans for |r" + this.nameColored());
                r = thistype.getRandomRaceUniqueEx(class);
            }
            
            return r;
        }
        
        public static method setPlayerDataPickRandomRaceUniqueWithBans(PlayerDataPick this) -> Race {
            Race r = getPlayerDataPickRandomRaceUniqueWithBans(this);
            this.playerData.setRace(r);
            return r;
        }
    }
}

//! endzinc