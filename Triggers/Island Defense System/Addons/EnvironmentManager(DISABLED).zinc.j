//! zinc

library EnvironmentManager requires GameTimer {
    public struct MusicManager {
        private static constant string MUSIC_IDLE = "Sound\\Music\\mp3Music\\Mainscreen.mp3";
        private static constant string MUSIC_STARTING = "Sound\\Music\\mp3Music\\DarkAgents.mp3";
        private static constant string MUSIC_TENSION = "Sound\\Music\\mp3Music\\Tension.mp3";
        
        private static constant string MUSIC_STARTED = "Sound\\Music\\mp3Music\\NightElf.mp3";
        public static method stateChanged(integer state, integer oldState){
            return;
            if (state == Game.STATE_IDLE){
                thistype.playerDeathPlaying = false;
                StopMusic(true);
                ClearMapMusic();
                PlayMusic(thistype.MUSIC_IDLE);
            }
            if (state == Game.STATE_STARTING){
                thistype.playerDeathPlaying = false;
                StopMusic(false);
                PlayMusic(thistype.MUSIC_STARTING);
            }
            if (state == Game.STATE_STARTED){
                if (oldState == Game.STATE_PAUSED){
                    ResumeMusic();
                }
                else {
                    SetMusicPlayPosition(1100);
                    PlayMusic(thistype.MUSIC_TENSION);
                    GameTimer.newNamed(function(GameTimer t){
                        StopMusic(true);
                        SetMusicPlayPosition(0);
                        PlayMusic(thistype.MUSIC_STARTED);
                    }, "MusicTensionDelay").start(20.0);
                }
            }
            if (state == Game.STATE_PAUSED){
                StopMusic(false);
            }
            if (state == Game.STATE_FINISHED){
                // End game has its own music!
                thistype.playerDeathPlaying = false;
                StopMusic(true);
                ClearMapMusic();
            }
        }
        
        private static constant string MUSIC_CONFRONTATION = "Sound\\Music\\mp3Music\\TragicConfrontation.mp3";
        private static boolean playerDeathPlaying = false;
        public static method PlayerDeath(integer class){
            return;
            if (playerDeathPlaying) return;
            StopMusic(true);
            PlayMusic(thistype.MUSIC_CONFRONTATION);
            GameTimer.new(function(GameTimer t){
                StopMusic(true);
                
            }).start(72.00);
        }
    }
    
    private struct Rain {
        private static sound rainSound = null;
        private static sound windSound = null;
        //private static weathereffect lightRain = null;
        private static weathereffect heavyRain = null;
        
        private static boolean mRaining = false;
        public static method raining() -> boolean {
            return thistype.mRaining;
        }
        
        public static method begin(){
            if (thistype.mRaining) return;
            //if (thistype.lightRain == null){
            //    thistype.lightRain = AddWeatherEffect(GetWorldBounds(), 'RAlr');
            //    EnableWeatherEffect(thistype.lightRain, false);
            //}
            if (thistype.heavyRain == null){
                thistype.heavyRain = AddWeatherEffect(GetWorldBounds(), 'RAhr');
                EnableWeatherEffect(thistype.heavyRain, false);
            }
            
            Game.say("|cff00bfffThe sky darkens...");
            SetDayNightModels("Environment\\DNC\\DNCFelwood\\DNCFelwoodTerrain\\DNCFelwoodTerrain.mdl",
                              "Environment\\DNC\\DNCFelwood\\DNCFelwoodUnit\\DNCFelwoodUnit.mdl");
            StartSound(thistype.windSound);
            SetSoundVolume(thistype.windSound, 50);
            GameTimer.new(function(GameTimer t){
                StartSound(thistype.rainSound);
                Game.say("|cff00bfffThe rain slowly pours down from the sky.");
                thistype.rain();
            }).start(5.00);
        }
        
        public static method rain(){
            SetSoundPitch(thistype.rainSound, 1.1);
            SetSoundVolume(thistype.rainSound, 50);
            //EnableWeatherEffect(thistype.lightRain, true);
            EnableWeatherEffect(thistype.heavyRain, true);
            thistype.mRaining = true;
            
            GameTimer.new(function(GameTimer t){
                if (GetRandomInt(0, 2) == 1){
                    thistype.end();
                }
                else {
                    thistype.rainHard();
                }
            }).start(60.0);
        }
        
        public static method rainHard(){
            SetSoundPitch(thistype.rainSound, 0.7);
            SetSoundVolume(thistype.rainSound, 150);
            //EnableWeatherEffect(thistype.heavyRain, true);
            //EnableWeatherEffect(thistype.lightRain, false);
            GameTimer.new(function(GameTimer t){
                thistype.rain();
            }).start(30.0);
        }
        
        public static method end(){
            Game.say("|cff00bfffThe sky lightens, the clouds have moved away...");
            StopSound(thistype.rainSound, false, true);
            SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl",
                              "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl");
            GameTimer.new(function(GameTimer t){
                EnableWeatherEffect(thistype.heavyRain, false);
                StopSound(thistype.windSound, false, true);
                thistype.mRaining = false;
            }).start(3.0);
        }
        
        public static method onInit(){
            thistype.rainSound = CreateSound("Sound\\Ambient\\RainAmbience.wav",
                                                     true, false, false, 10, 10, "");
            thistype.windSound = CreateSound("Sound\\Ambient\\WindLoopStereo.wav",
                                                     true, false, false, 10, 10, "");
        }
    }
    
    private function onInit(){
        //trigger t= CreateTrigger();
        //TriggerRegisterTimerEventPeriodic(t, 240.0);
        //TriggerAddAction(t, function(){
        //    if (GetRandomInt(0, 1) == 1)
        //        Rain.begin();
        //});
        //t = null;
    }
}

//! endzinc