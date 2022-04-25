//! zinc

library QuestTweak requires TweakManager, GameTimer, Table {
    public struct Quest {
        private string questName = "";
        private integer questId = 0;
        private integer questIndex = 0;
        private quest quest = null;
        
        public method name() -> string {
            return this.questName;
        }
        
        public method id() -> integer {
            return this.questId;
        }
        
        public method setDescription(string description) {
            QuestSetDescription(this.quest, description);
        }
    
        private static Table quests = 0;
        private static thistype questList[100];
        private static integer questCount = 0;
        
        public static method operator [] (integer id) -> thistype {
            return quests[id];
        }
        
        private static constant string QUEST_DEFAULT_ICON = "ReplaceableTextures\\CommandButtons\\BTNTomeBrown.blp";
        public static method create(trigger t, integer id, string n) -> thistype {
            thistype this = thistype.allocate();
            this.quest = CreateQuest();
            this.questName = n;
            this.questId = id;
            
            QuestSetTitle(this.quest, this.questName);
            QuestSetDiscovered(this.quest, false);
            QuestSetEnabled(this.quest, false);
            QuestSetRequired(this.quest, false);
            QuestSetIconPath(this.quest, thistype.QUEST_DEFAULT_ICON);
            
            // Register
            GT_RegisterItemAcquiredEvent(t, id);
            thistype.quests[id] = this;
            
            this.questIndex = thistype.questCount;
            thistype.questList[thistype.questCount] = this;
            thistype.questCount = thistype.questCount + 1;
            return this;
        }
        
        // Use this method instead of .destroy()
        public method delete(trigger t) {
            GT_UnregisterItemAcquiredEvent(t, this.questId);
            this.destroy();
        }
        
        public method onDestroy() {
            thistype.questList[this.questIndex] = 0;
            thistype.quests.remove(this.questId);
            this.questName = "";
            this.questId = 0;
            this.questIndex = 0;
        }
        
        public static method terminate(trigger t) {
            integer i = 0;
            thistype this = 0;
            for (0 <= i < thistype.questCount) {
                this = thistype.questList[i];
                if (this != 0) {
                    this.delete(t);
                }
                thistype.questList[i] = 0;
            }
            thistype.questCount = 0;
        }
        
        public static method initialize(trigger t) {
            thistype this = 0;
            thistype.quests = Table.create();
            
            this = thistype.create(t, 'I03J', "Early Beginnings");
            this.setDescription("Find water or something.");
        }
        
        public method begin(player p) {
            string s = "";
            s = "|cff00bfffYou have started the " + this.questName + " quest. Check your Guide for more details.|r";
            if (GetLocalPlayer() == p) {
                if (!IsQuestDiscovered(this.quest)) {
                    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, s);
                    
                    QuestSetDiscovered(this.quest, true);
                    QuestSetEnabled(this.quest, true);
                    FlashQuestDialogButton();
                    StartSound(bj_questDiscoveredSound);
                }
            }
        }
    }
    
    public struct QuestTweak extends Tweak {
        module TweakModule;
        
        public method name() -> string {
            return "Quests";
        }
        public method shortName() -> string {
            return "QUESTS";
        }
        public method description() -> string {
            return "Allows you to manage your Island Keeper Quests.";
        }
        public method command() -> string {
            return "-quests";
        }
        public method hidden() -> boolean {
            return true;
        }
        
        public method activate(Args args){
            PlayerData p = PlayerData.get(GetTriggerPlayer());
        }
        
        public method onQuestStartItem(unit u, integer id) {
            Quest[id].begin(GetOwningPlayer(u));
        }
        
        private trigger itemTrigger = null;
        private unit questGiver = null;
        public method initialize() {
            this.questGiver = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n00L', 672.0, 6432.0, 270.0);
            this.itemTrigger = CreateTrigger();
            Quest.initialize(this.itemTrigger);
            
            TriggerAddCondition(this.itemTrigger, Condition(function() -> boolean {
                unit u = GetManipulatingUnit();
                item it = GetManipulatedItem();
                integer i = GetItemTypeId(it);
                thistype t = TweakManager.tweakByShortName("QUESTS");
                
                RemoveItem(it);
                t.onQuestStartItem(u, i);
                u = null;
                it = null;
                return false;
            }));
        }
        
        public method terminate() {
            Quest.terminate(this.itemTrigger);
            DestroyTrigger(this.itemTrigger);
            RemoveUnit(this.questGiver);
            this.itemTrigger = null;
            this.questGiver = null;
        }
    }
}
//! endzinc