//! zinc

library MultiboardDefender requires MultiboardManager, Board, ExperienceSystem {
    public struct MultiboardDefender extends ClassBoard {
        private static real PlayerWidth       = 0.09;
        private static real NumberWidth       = 0.03;
        private static string GoldIcon        = "UI\\Feedback\\Resources\\ResourceGold.blp";
        private static string WoodIcon        = "UI\\Feedback\\Resources\\ResourceLumber.blp";
        private static string ObserverIcon    = "UI\\Widgets\\EscMenu\\Human\\observer-icon.blp";
        
        private static integer ColumnName     = 0;
        private static integer ColumnGold     = 1;
        private static integer ColumnWood     = 2;
        private static integer ColumnRate     = 3;
        private static integer ColumnFed      = 4;
        
        private integer TitanCount = 0;
        private integer MinionCount = 0;
        private integer DefenderCount = 0;
        private integer ObserverCount = 0;
        private integer LeaverCount = 0;
        
        private PlayerDataArray subscribed = 0;
        private Board board = 0;
        
        private static thistype singleton = 0;
        
        public method forClass(integer c) -> boolean {
            return (c == PlayerData.CLASS_DEFENDER ||
                    c == PlayerData.CLASS_OBSERVER);
        }
        
        public method name() -> string {
            return "MultiboardDefender";
        }
        
        public method initialize(){
            this.subscribed = PlayerDataArray.create();
            this.board = Board.create();
            this.build();
        }
        
        public method subscribe(PlayerData p){
            if (this.isSubscribed(p)) return;
            // Take control
            if (this.forClass(p.class())){
                this.subscribed.append(p);
            }
            else {
                Game.say("Can't subscribe " + p.nameColored() + " (" + p.classString() + ") to " + this.name());
            }
        }
        
        public method isSubscribed(PlayerData p) -> boolean {
            return (this.subscribed.indexOf(p) != -1);
        }
        
        public method unsubscribe(PlayerData p){
            this.subscribed.remove(p);
            this.board.visible[p.player()] = false;
        }
        
        private method rebuild(){
            integer i = 0;
            if (this.board != 0){
                this.board.destroy();
                this.board = Board.create();
            }
            else {
                this.board = Board.create();
            }
            this.build();
        }
        
        private static string mHeader = "";
        public static method setHeader(string header){
            thistype.mHeader = header;
        }
        
        public static method header() -> string {
            string s = "|cff6622ffDefender Information|r";
            if (StringLength(thistype.mHeader) > 0){
                s = s + " - [" + thistype.mHeader + "]";
            }
            if (GameSettings.getBool("DEBUG")){
                s = s + " [|cffffa500D|r]";
            }
            s = s + " [" + Game.currentGameElapsedTime() + "]";
            return s;
        }
        
        private method build(){   
            BoardItem it = 0;
            BoardRow row = 0;
            
            PlayerDataArray list = 0;
            PlayerData p = 0;
            integer i = 0;
            integer currentRow = 0;
            real currentHealth;
            real maxHealth;
            
            integer fed = 0;
            real rate = 0.0;
            PlayerDataFed pFed = 0;
            string s = "";

            this.board.title = thistype.header();
            //this.board.titleColor = 0x0000FF;// (102, 34, 255, 255);

            /*
             * Set up Counts
             */
            this.TitanCount = PlayerData.countClass(PlayerData.CLASS_TITAN);
            this.MinionCount = PlayerData.countClass(PlayerData.CLASS_MINION);
            this.DefenderCount = PlayerData.countClass(PlayerData.CLASS_DEFENDER);
            this.ObserverCount = PlayerData.countClass(PlayerData.CLASS_OBSERVER);
            this.LeaverCount = PlayerData.countLeavers();
            
            /* Header */
            currentRow = 0;
            row = this.board.row[currentRow];
            it = row[thistype.ColumnName];
            it.width = thistype.PlayerWidth;
            it.setDisplay(true, false);
            it.text = "|cff6a5acdPlayer|r";
            it = row[thistype.ColumnGold];
            it.width = thistype.NumberWidth;
            it.setDisplay(false, true);
            it.icon = thistype.GoldIcon;
            it = row[thistype.ColumnWood];
            it.width = thistype.NumberWidth;
            it.setDisplay(false, true);
            it.icon = thistype.WoodIcon;
            it = row[thistype.ColumnRate];
            it.width = thistype.NumberWidth;
            it.setDisplay(true, false);
            it.text = "|cff6a5acdRate|r";
            it = row[thistype.ColumnFed];
            it.width = thistype.NumberWidth;
            it.setDisplay(true, false);
            it.text = "|cff6a5acdFed|r";
            currentRow = currentRow + 1;
            
            /* Defender/Observer Player Stats */
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER)
                    .merge(PlayerData.withClass(PlayerData.CLASS_OBSERVER));
            for (0 <= i < list.size()){
                p = list.at(i);
                
                fed = 0;
                rate = 0.0;
                if (PlayerDataFed.initialized()){
                    pFed = PlayerDataFed[p];
                    fed = pFed.fed();
                    rate = pFed.rate();
                }
                
                row = this.board.row[currentRow];
                
                it = row[thistype.ColumnName];
                it.width = thistype.PlayerWidth;
                it.setDisplay(true, true);
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    it.icon = p.race().icon();
                }
                else {
                    it.icon = thistype.ObserverIcon;
                }
                it.text = p.nameColored();
                
                it = row[thistype.ColumnGold];
                it.width = thistype.NumberWidth;
                it.setDisplay(true, false);
                
                it = row[thistype.ColumnWood];
                it.width = thistype.NumberWidth;
                it.setDisplay(true, false);
                
                it = row[thistype.ColumnRate];
                it.width = thistype.NumberWidth;
                it.setDisplay(true, false);
                s = R2SW(rate * 100, 4, 1) + "%";
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    it.text = s;
                }
                else {
                    it.text = "|cff2f4f4f" + s + "|r";
                }
                
                it = row[thistype.ColumnFed];
                it.width = thistype.NumberWidth;
                it.setDisplay(true, false);
                s = I2S(fed);
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    it.text = s;
                }
                else {
                    it.text = "|cff2f4f4f" + s + "|r";
                }

                currentRow = currentRow + 1;
            }

            list.destroy();
            
            /* Titan/Minion Stats */
            list = PlayerData.withClass(PlayerData.CLASS_TITAN)
                    .merge(PlayerData.withClass(PlayerData.CLASS_MINION));
            if (list.size() > 0){
                /* Spacer */
                row = this.board.row[currentRow];
                row.width = 0.00;
                row.setDisplay(false, false);
                currentRow = currentRow + 1;
                
                for (0 <= i < list.size()){
                    p = list.at(i);
                    
                    row = this.board.row[currentRow];
                    it = row[thistype.ColumnName];
                    it.width = thistype.PlayerWidth;
                    it.setDisplay(true, true);
                    it.icon = NullRace.instance().icon();
                    it.text = p.nameColored();
                    
                    it = row[thistype.ColumnGold];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(false, false);

                    it = row[thistype.ColumnWood];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(false, false);
                    
                    if (p.class() == PlayerData.CLASS_MINION){
                        fed = 0;
                        rate = 0.0;
                        if (PlayerDataFed.initialized()){
                            pFed = PlayerDataFed[p];
                            fed = pFed.fed();
                            rate = pFed.rate();
                        }
                        
                        it = row[thistype.ColumnRate];
                        it.width = thistype.NumberWidth;
                        it.setDisplay(true, false);
						s = R2SW(rate * 100, 4, 1) + "%";
                        it.text = "|cff2f4f4f" + s + "|r";
                        
                        it = row[thistype.ColumnFed];
                        it.width = thistype.NumberWidth;
                        it.setDisplay(true, false);
                        s = I2S(fed);
                        it.text = "|cff2f4f4f" + s + "|r";
                    }
                    else {
                        it = row[thistype.ColumnRate];
                        it.width = thistype.NumberWidth;
                        it.setDisplay(false, false);
                        
                        it = row[thistype.ColumnFed];
                        it.width = thistype.NumberWidth;
                        it.setDisplay(false, false);
                    }
                    
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();
            
            /* Leaver Player Stats */
            list = PlayerData.leavers();
            if (list.size() > 0){
                /* Spacer */
                row = this.board.row[currentRow];
                row.width = 0.00;
                row.setDisplay(false, false);
                currentRow = currentRow + 1;
            
                for (0 <= i < list.size()){
                    p = list.at(i);
                    
                    row = this.board.row[currentRow];
                    it = row[0];
                    it.width = thistype.PlayerWidth;
                    it.setDisplay(true, true);
                    it.icon = thistype.ObserverIcon;
                    it.text = "|cff2f4f4f" + p.name() + "|r";
                    
                    it = row[thistype.ColumnGold];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(false, false);

                    it = row[thistype.ColumnWood];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(false, false);
                    
                    fed = 0;
                    rate = 0.0;
                    if (PlayerDataFed.initialized()){
                        pFed = PlayerDataFed[p];
                        fed = R2I(pFed.fed());
                        rate = pFed.rate();
                    }
                    
                    it = row[thistype.ColumnRate];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(true, false);
					s = R2SW(rate * 100, 4, 1) + "%";
                    it.text = "|cff2f4f4f" + s + "|r";
                    
                    it = row[thistype.ColumnFed];
                    it.width = thistype.NumberWidth;
                    it.setDisplay(true, false);
                    s = I2S(fed);
                    it.text = "|cff2f4f4f" + s + "|r";
                    
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();

            this.update();
        }

        public method update(){
            BoardItem it = 0;
            BoardRow row = 0;
            PlayerDataArray list = 0;
            PlayerData p = 0;
            integer i = 0;
            integer currentRow = 0;
            real currentHealth;
            real maxHealth;
            integer fed = 0;
            real rate = 0.0;
            PlayerDataFed pFed = 0;
            
            if (this.TitanCount != PlayerData.countClass(PlayerData.CLASS_TITAN) ||
                this.MinionCount != PlayerData.countClass(PlayerData.CLASS_MINION) ||
                this.DefenderCount != PlayerData.countClass(PlayerData.CLASS_DEFENDER) ||
                this.ObserverCount != PlayerData.countClass(PlayerData.CLASS_OBSERVER) ||
                this.LeaverCount != PlayerData.countLeavers()){
                // Team sizes have changed, we have to resize it now
                this.rebuild();
                return;
            }
            
            thistype.setHeader(TweakManager.getGameTweakLights());
            this.board.title = thistype.header();
            
            /* Header */
            currentRow = currentRow + 1;

            /* Defender/Observer Stats */
            list = PlayerData.withClass(PlayerData.CLASS_DEFENDER)
                    .merge(PlayerData.withClass(PlayerData.CLASS_OBSERVER));
            for (0 <= i < list.size()){
                p = list.at(i);
                
                row = this.board.row[currentRow];
                if (p.class() == PlayerData.CLASS_DEFENDER){
                    row[thistype.ColumnName].text = p.nameColored();
                    row[thistype.ColumnName].icon = p.race().icon();
                    row[thistype.ColumnGold].text = I2S(p.gold());
                    row[thistype.ColumnWood].text = I2S(p.wood());
                    
                    fed = 0;
                    rate = 0.0;
                    if (PlayerDataFed.initialized()){
                        pFed = PlayerDataFed[p];
                        fed = R2I(pFed.fed());
                        rate = pFed.rate();
                    }
                    row[thistype.ColumnRate].text = R2SW(rate * 100, 4, 1) + "%";
                    row[thistype.ColumnFed].text = I2S(fed);
                }
                currentRow = currentRow + 1;
            }
            list.destroy();
            
            /* Titan/Minion Stats */
            list = PlayerData.withClass(PlayerData.CLASS_TITAN)
                    .merge(PlayerData.withClass(PlayerData.CLASS_MINION));
            if (list.size() > 0){
                currentRow = currentRow + 1;
                for (0 <= i < list.size()){
                    p = list.at(i);
                    
                    row = this.board.row[currentRow];
                    row[thistype.ColumnName].text = p.nameColored();
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();
            
            /* Leaver Stats */
            list = PlayerData.leavers();
            if (list.size() > 0){
                currentRow = currentRow + 1;
                for (0 <= i < list.size()){
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();
            
            this.display(true);
        }
        
        private method display(boolean b){
            PlayerData p = 0;
            integer i = 0;

            for (0 <= i < this.subscribed.size()){
                p = subscribed[i];
                this.board.visible[p.player()] = b;
            }
        }
        
        public method terminate(){
            PlayerDataArray list = 0;
            integer i = 0;
            list = PlayerData.all();
            for (0 <= i < list.size()){
                this.unsubscribe(list[i]);
            }
            list.destroy();
            list = 0;
            this.board.destroy();
            this.board = 0;
            this.subscribed.destroy();
            this.subscribed = 0;
        }
        
        public static method create() -> thistype {
            if (thistype.singleton == 0)
                thistype.singleton = thistype.allocate();
            return thistype.singleton;
        }
        
        private static method onInit(){
            MultiboardManager.register(thistype.create());
        }
    }
}

//! endzinc
