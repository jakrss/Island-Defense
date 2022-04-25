//! zinc

library SpeechSystem requires Table, Players, GameTimer, StringLib, CommandParser {
	type ClassFilter extends function(integer) -> boolean;
	
    private struct SpeechData {
        public string s = "";
        public sound so = null;
        public ClassFilter classFilter = 0;
    }
    
    public struct PlayerDataSpeech extends PlayerDataExtension {
        module PlayerDataWrappings;
        
        private GameTimer cooldown = 0;
        private boolean mCoolingDown = false;
        private boolean mSilence = false;
        public method onSetup(){
            this.mSilence = false;
            this.mCoolingDown = false;
        }
        public method onTerminate(){
            this.cooldown.destroy();
            this.cooldown = 0;
        }
        
        public method cooldownOver(){
            this.mCoolingDown = false;
            this.cooldown = 0;
        }
        
        public method coolingDown() -> boolean {
            return this.mCoolingDown;
        }
        
        public method setSilence(boolean b){
            this.mSilence = b;
        }
        
        public method wantsSilence() -> boolean {
            return this.mSilence;
        }
        
        public method playSpeech(SpeechData s){
            integer i = 0;
            PlayerDataArray list = 0;
            thistype p = 0;
            
            if (this.wantsSilence()){ 
                return;
            }
            if (this.coolingDown()){ 
                return;
            }
            if (!s.classFilter.evaluate(this.class())){ 
                return;
            }
            
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = thistype[list[i]];
                if (!p.wantsSilence()){
                    if (p.playerData.player() == GetLocalPlayer()){
                        PlaySoundBJ(s.so);
                    }
                }
            }
            list.destroy();

            this.mCoolingDown = true;
            
            this.cooldown = GameTimer.newNamed(function(GameTimer t){
                thistype this = t.data();
                this.cooldownOver();
            }, "SpeechCooldown");
            this.cooldown.setData(this);
            this.cooldown.start(5.0);
        }
    }
    
    public struct SpeechSystem {
        private static Table soundTable = 0;
        public static method initialize(){
            PlayerDataSpeech.initialize();
        }
        public static method terminate(){
            PlayerDataSpeech.terminate();
        }
        
        public static method getSpeechData(string s) -> SpeechData {
            integer hash = StringHash(StringCase(StringTrim(s), false));
            if (thistype.soundTable.has(hash)){
                return thistype.soundTable[hash];
            }
            return 0;
        }
        
        public static method registerSpeech(string s, sound so, ClassFilter classFilter) -> SpeechData {
            SpeechData d = SpeechData.create();
            integer hash = StringHash(StringCase(StringTrim(s), false));
            d.s = s;
            d.so = so;
            d.classFilter = classFilter;
            thistype.soundTable[hash] = d;
            return d;
        }
        
        private static method onSpeech(){
            PlayerDataSpeech p = 0;
            SpeechData d = 0;
            string s = GetEventPlayerChatString();
            if (!PlayerDataSpeech.initialized()){
                return;
            }

            d = thistype.getSpeechData(s);
            if (d == 0){
                return;
            }
            
            p = PlayerDataSpeech[PlayerData.get(GetTriggerPlayer())];
            if (p != 0){
                p.playSpeech(d);
            }
        }
        
        public static method setup(){
            trigger t = CreateTrigger();
            integer i = 0;
            
            SpeechSystem.soundTable = Table.create();
            
            SpeechSystem.registerSpeeches();
            
            for (0 <= i < bj_MAX_PLAYERS){
                TriggerRegisterPlayerChatEvent(t, Player(i), "", false);
            }
            TriggerAddCondition(t, Condition(function() -> boolean {
                thistype.onSpeech();
                return false;
            }));
            t = null;
            
            Command["-silence"].register(function(Args a){
                PlayerDataSpeech p = 0;
                if (PlayerDataSpeech.initialized()){
                    p = PlayerDataSpeech[PlayerData.get(GetTriggerPlayer())];
                    p.setSilence(true);
                    p.say("|cff0080ffPlayer-produced sounds |r|cffff0000OFF.|r");
                }
            });
            
            Command["-unsilence"].register(function(Args a){
                PlayerDataSpeech p = 0;
                if (PlayerDataSpeech.initialized()){
                    p = PlayerDataSpeech[PlayerData.get(GetTriggerPlayer())];
                    p.setSilence(false);
                    p.say("|cff0080ffPlayer-produced sounds |r|cffff0000ON.|r");
                }
            });
        }
        
        private static method registerSpeeches(){
			ClassFilter class = function(integer class) -> boolean {
				return class == PlayerData.CLASS_DEFENDER || class == PlayerData.CLASS_OBSERVER;
			};
            thistype.registerSpeech("im waiting", 
                                    gg_snd_Builder_ImWaiting, class);
            thistype.registerSpeech("this is too easy", 
                                    gg_snd_Builder_ThisIsTooEasy, class);
            thistype.registerSpeech("by the gods", 
                                    gg_snd_Builder_ByTheGodsYourAnnoying, class);
            thistype.registerSpeech("aahh", 
                                    gg_snd_Builder_Aahh, class);
            thistype.registerSpeech("what", 
                                    gg_snd_Builder_What, class);
            thistype.registerSpeech("begone", 
                                    gg_snd_Builder_BeGoneSpawnOfDarkness, class);
            thistype.registerSpeech("i grow tired of waiting", 
                                    gg_snd_Builder_IGrowTiredOfWaiting, class);
            thistype.registerSpeech("lolol", 
                                    gg_snd_Builder_Lolol, class);
            thistype.registerSpeech("huh", 
                                    gg_snd_Builder_Huh, class);
            thistype.registerSpeech("yes", 
                                    gg_snd_Builder_Yes, class);
            thistype.registerSpeech("why not", 
                                    gg_snd_Builder_WhyNot, class);
            thistype.registerSpeech("bring it on", 
                                    gg_snd_Builder_BringItOn, class);
            thistype.registerSpeech("time to die", 
                                    gg_snd_Builder_TimeToDie, class);
            thistype.registerSpeech("let me at them", 
                                    gg_snd_Builder_LetMeAtThem, class);
            thistype.registerSpeech("youve done well", 
                                    gg_snd_Builder_YouveDoneWell, class);
            thistype.registerSpeech("you've done well", 
                                    gg_snd_Builder_YouveDoneWell, class);
            thistype.registerSpeech("lets get the hell out of here", 
                                    gg_snd_Builder_LetsGetTheHellOutOfHere, class);
            thistype.registerSpeech("let's get the hell out of here", 
                                    gg_snd_Builder_LetsGetTheHellOutOfHere, class);
            thistype.registerSpeech("no not that way", 
                                    gg_snd_Builder_NoNotThatWay, class);
            thistype.registerSpeech("to hell with your apologies", 
                                    gg_snd_Builder_ToHellWithYourApologies, class);
            thistype.registerSpeech("then lets go", 
                                    gg_snd_Builder_ThenLetsGoIDontWantToKeepTheBastardWaiting, class);
            thistype.registerSpeech("then let's go", 
                                    gg_snd_Builder_ThenLetsGoIDontWantToKeepTheBastardWaiting, class);
            thistype.registerSpeech("damned cowards", 
                                    gg_snd_Builder_DamnedCowards, class);
            thistype.registerSpeech("you bastard", 
                                    gg_snd_Builder_YouBastard, class);
            thistype.registerSpeech("what the hell is that", 
                                    gg_snd_Builder_WhatTheHellIsThat, class);
            thistype.registerSpeech("here they come boys", 
                                    gg_snd_Builder_HereTheyComeBoysStandYourGround, class);
            thistype.registerSpeech("take cover", 
                                    gg_snd_Builder_TakeCover, class);
            thistype.registerSpeech("hes escaping", 
                                    gg_snd_Builder_HesEscapingKillHim, class);
            thistype.registerSpeech("he's escaping", 
                                    gg_snd_Builder_HesEscapingKillHim, class);
            thistype.registerSpeech("save us", 
                                    gg_snd_Builder_SaveUs, class);
            thistype.registerSpeech("oh no", 
                                    gg_snd_Builder_OhNo, class);
            thistype.registerSpeech("where", 
                                    gg_snd_Builder_Where, class);
            thistype.registerSpeech("damn beasts", 
                                    gg_snd_Builder_DamnBeasts, class);
            thistype.registerSpeech("im so tired", 
                                    gg_snd_Builder_ImSoTired, class);
            thistype.registerSpeech("i'm so tired", 
                                    gg_snd_Builder_ImSoTired, class);
			thistype.registerSpeech("demon spawned wretchs", 
                                    gg_snd_Builder_DemonSpawnedWretchs, class);
            thistype.registerSpeech("demon spawned wretches", 
                                    gg_snd_Builder_DemonSpawnedWretchs, class);
            thistype.registerSpeech("kill them all twice", 
                                    gg_snd_Builder_KillThemAllTwice, class);
            thistype.registerSpeech("panda", 
                                    gg_snd_Builder_Panda, class);
            thistype.registerSpeech("take this",
                                    gg_snd_Builder_TakeThis, class);
            thistype.registerSpeech("dancing",
                                    gg_snd_Builder_Dancing, class);
            thistype.registerSpeech("insult",
                                    gg_snd_Builder_Insult, class);								
            // Titan Sounds
            class = function(integer class) -> boolean {
				return class == PlayerData.CLASS_TITAN || class == PlayerData.CLASS_MINION;
			};
            thistype.registerSpeech("this one is mine", 
                                    gg_snd_Titan_ThisOneIsMine, class);
            thistype.registerSpeech("vanquish the weak", 
                                    gg_snd_Titan_VanquishTheWeak, class);
            thistype.registerSpeech("dont waste my time",
                                    gg_snd_Titan_DontWasteMyTime, class);
            thistype.registerSpeech("don't waste my time",
                                    gg_snd_Titan_DontWasteMyTime, class);
            thistype.registerSpeech("right",
									gg_snd_Titan_Right, class);
            thistype.registerSpeech("of course",
									gg_snd_Titan_OfCourse, class);
            thistype.registerSpeech("stay out of my way",
									gg_snd_Titan_StayOutOfMyWay, class);
            thistype.registerSpeech("pitiful",
									gg_snd_Titan_Pitiful, class);
            thistype.registerSpeech("i must feed",
									gg_snd_Titan_IMustFeed, class);
            thistype.registerSpeech("im always on the winning side",
									gg_snd_Titan_ImAlwaysOnTheWinningSide, class);
            thistype.registerSpeech("i'm always on the winning side",
									gg_snd_Titan_ImAlwaysOnTheWinningSide, class);
            thistype.registerSpeech("die",
									gg_snd_Titan_Die, class);
            thistype.registerSpeech("your soul is mine",
									gg_snd_Titan_YourSoulIsMine, class);
            thistype.registerSpeech("outstanding",
									gg_snd_Titan_Outstanding, class);
            thistype.registerSpeech("cross over children",
									gg_snd_Titan_CrossOverChildrenCrossOverIntoTheLight, class);
            thistype.registerSpeech("i come to cleanse",
									gg_snd_Titan_IComeToCleansThisLand, class);
            thistype.registerSpeech("taste this",
									gg_snd_Titan_TasteThis, class);
            thistype.registerSpeech("the dead shall serve",
									gg_snd_Titan_TheDeadShallServe, class);
            thistype.registerSpeech("let blood drown the weak",
									gg_snd_Titan_LetBloodDrownedTheWeak, class);
            thistype.registerSpeech("now feel my wrath",
									gg_snd_Titan_NowFeelMyWrath, class);
            thistype.registerSpeech("never",
									gg_snd_Titan_Never, class);
            thistype.registerSpeech("what the hell",
									gg_snd_Titan_WhatTheHellIsGoingOnHere, class);
            thistype.registerSpeech("kill them all",
									gg_snd_Titan_KillThemAll, class);
            thistype.registerSpeech("youve betrayed us all",
									gg_snd_Titan_YouveBetrayedUsAll, class);
            thistype.registerSpeech("you've betrayed us all",
									gg_snd_Titan_YouveBetrayedUsAll, class);
            thistype.registerSpeech("you have betrayed us all",
									gg_snd_Titan_YouveBetrayedUsAll, class);
            thistype.registerSpeech("you should burn",
									gg_snd_Titan_YouShouldBurnInHell, class);
            thistype.registerSpeech("gladly",
									gg_snd_Titan_Gladly, class);
            thistype.registerSpeech("fateless coward",
									gg_snd_Titan_FatelessCoward, class);
            thistype.registerSpeech("its a trap",
									gg_snd_Titan_ItsATrap, class);
            thistype.registerSpeech("it's a trap",
									gg_snd_Titan_ItsATrap, class);
            thistype.registerSpeech("too difficult",
									gg_snd_Titan_ThatDoesntSoundTooDifficult, class);
            thistype.registerSpeech("that doesn't sound too difficult",
									gg_snd_Titan_ThatDoesntSoundTooDifficult, class);
            thistype.registerSpeech("your time has come",
									gg_snd_Titan_YourTimeHasCome, class);
            thistype.registerSpeech("well see about that",
									gg_snd_Titan_WellSeeAboutThat, class);
            thistype.registerSpeech("we'll see about that",
									gg_snd_Titan_WellSeeAboutThat, class);
            thistype.registerSpeech("we will see about that",
									gg_snd_Titan_WellSeeAboutThat, class);
            thistype.registerSpeech("so youre not upset",
									gg_snd_Titan_SoYoureNotUpsetAboutMeKillingYouThatOneTime, class);
            thistype.registerSpeech("so you're not upset",
									gg_snd_Titan_SoYoureNotUpsetAboutMeKillingYouThatOneTime, class);
            thistype.registerSpeech("tremble mortals",
									gg_snd_Titan_TrembleMortals, class);
            thistype.registerSpeech("haha",
									gg_snd_Titan_Haha, class);
            thistype.registerSpeech("feel",
                                    gg_snd_Titan_Feel, class);
            thistype.registerSpeech("I am the wind     ",
                                    gg_snd_Titan_Breezerious, class);
        }
    }
}

//! endzinc