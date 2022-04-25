//! zinc

library VoteBoardGeneric requires VoteModule, Board {
    public struct VoteBoardGeneric extends VoteBoard {
        private static real PlayerWidth       = 0.09;
        private static real NumberWidth       = 0.03;
        private static string VoteIcon        = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp";
        
        private integer PlayerCount = 0;
        
        private boolean running = false;
        private voteFunc func = 0;
        private checkFunc forFunc = 0;
        private VoteResult result = 0;
        private thistype data = 0;
        private string title = "";
        private GameTimer countdown = 0;
        
        private Board board = 0;
        
        private static thistype singleton = 0;
        
        public method forPlayer(PlayerData p) -> boolean {
            return this.forFunc.evaluate(p);
        }
        
        public method name() -> string {
            return "VoteBoardGeneric";
        }
        
        public method voteData() -> integer {
            return data;
        }
        
        public method initialize(){
            this.board = Board.create();
            this.PlayerCount = 0;
            this.build();
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
        
        
        private method build(){  
            integer currentRow = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            PlayerData p = 0;
            BoardRow row = 0;
            BoardItem it = 0;
            
            list = PlayerData.all();
            this.PlayerCount = 0;
            for (0 <= i < list.size()){
                p = list[i];
                if (this.forPlayer(p) && this.result[p] != ""){
                    this.PlayerCount = this.PlayerCount + 1;
                }
            }
            list.destroy();
            
            board.title = "Vote for: " + this.title;
            
            
            currentRow = 0;
            row = this.board.row[currentRow];
            it = row[0];
            it.width = 0.09;
            it.setDisplay(true, false);
            it.text = "Voters";
            it = row[1];
            it.width = 0.03;
            it.setDisplay(false, true);
            it.icon = thistype.VoteIcon;
            currentRow = currentRow + 1;
            
            // Defenders
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list.at(i);
                if (this.forPlayer(p) && this.result[p] != ""){
                    row = this.board.row[currentRow];
                    it = row[0];
                    it.width = 0.09;
                    it.setDisplay(true, true);
                    it.icon = NullRace.instance().icon();
                    it.text = p.nameColored();
                    it = row[1];
                    it.width = 0.03;
                    it.setDisplay(true, false);
                    it.text = "";
                    
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();
            
            row = this.board.row[currentRow];
            row[0].width = 0.01;

            currentRow = currentRow + 1;
            row = this.board.row[currentRow];
            it = row[0];
            it.width = 0.09;
            it.setDisplay(true, false);
            it.text = "Expires in: ";
            it = row[1];
            it.width = 0.03;
            it.setDisplay(true, false);
            it.text = "0";
            
            this.update();
        }

        public method update(){
            integer currentRow = 0;
            PlayerDataArray list = 0;
            integer i = 0;
            PlayerData p = 0;
            BoardRow row = 0;
            BoardItem it = 0;
            integer count = 0;
            
            if (!this.running) return;
            
            list = PlayerData.all();
            count = 0;
            for (0 <= i < list.size()){
                p = list[i];
                if (this.forPlayer(p) && this.result[p] != ""){
                    count = count + 1;
                }
            }
            list.destroy();
            
            if (count != this.PlayerCount){
                // Team sizes have changed, we have to resize it now
                this.rebuild();
                return;
            }
            
            currentRow = 0;
            currentRow = currentRow + 1;
            
            // Voters
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list.at(i);
                if (this.forPlayer(p) && this.result[p] != ""){
                    row = this.board.row[currentRow];
                    it = row[0];
                    it.text = p.nameColored();
                    it = row[1];
                    it.text = this.result[p];
                    
                    currentRow = currentRow + 1;
                }
            }
            list.destroy();
            
            if (this.countdown != 0 && this.countdown.timer() != null){
                currentRow = currentRow + 1;
                row = this.board.row[currentRow];
                row[1].text = I2S(R2I(TimerGetRemaining(this.countdown.timer())));
            }

            this.display(true);
        }
        
        private method display(boolean b){
            PlayerData p = 0;
            PlayerDataArray list = 0;
            integer i = 0;

            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list[i];
                if (this.forPlayer(p) && PlayerDataMultiboard[p].isVotingEnabled()){
                    this.board.visible[p.player()] = b;
                }
            }
            list.destroy();
        }
        
        public method begin(string vote, checkFunc f, voteFunc func, real timeout, integer data) -> boolean {
            PlayerDataArray list = 0;
            PlayerDataMultiboard p = 0;
            integer i = 0;
            if (this.running) return false;
            this.data = data;
            this.running = true;
            this.func = func;
            this.forFunc = f;
            this.result = VoteResult.create();
            this.title = vote;
            this.initialize();
            
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list[i];
                p.startVoting(this);
            }
            list.destroy();
            
            this.countdown = GameTimer.new(function(GameTimer t){
                thistype this = t.data();
                this.result.setExpired();
                this.done();
            }).start(timeout);
            this.countdown.setData(this);
            
            return true;
        }
        
        public method vote(PlayerData p, string v){
            if (!this.running) return;
            if (!this.forPlayer(p)) return; // Not interested
            if (this.result[p] == v) return; // Ignore the same vote
            this.result[p] = v;
            PlayerDataMultiboard[p].setVoting(false);
            PlayerDataMultiboard[p].update();
            this.func.execute(this.result, this.data);
        }
        
        public method done(){
            PlayerDataArray list = 0;
            PlayerData p = 0;
            integer i = 0;
            if (!this.running) return;
            this.running = false;
            countdown.stop();
            
            list = PlayerData.all();
            for (0 <= i < list.size()){
                p = list[i];
                PlayerDataMultiboard[p].setVoting(false);
            }
            list.destroy();
            
            this.func.execute(this.result, this.data);
            this.terminate();
        }
        
        public method terminate(){
            this.forFunc = 0;
            this.func = 0;
            this.data = 0;
            this.running = false;
            if (this.result != 0){
                this.result.destroy();
                this.result = 0;
            }
            this.board.destroy();
            this.board = 0;
        }
        
        public static method instance() -> thistype {
            return thistype.create();
        }
        
        public static method create() -> thistype {
            if (thistype.singleton == 0)
                thistype.singleton = thistype.allocate();
            return thistype.singleton;
        }
    }
}

//! endzinc
