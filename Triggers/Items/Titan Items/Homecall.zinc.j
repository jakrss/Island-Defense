//! zinc
library Homecall {
   private hashtable homeTable = InitHashtable();
   
   
   public function getHomecallKills(unit u) -> integer {
       return LoadInteger(homeTable, 1, GetHandleId(u));
   }
   
   public function getHomecallMaxKills(unit u) -> integer {
       return LoadInteger(homeTable, 2, GetHandleId(u));
   }
   
   
   public function setHomecallKills(unit u, integer kills) {
       integer maxKills = LoadInteger(homeTable, 2, GetHandleId(u));
       if(kills > maxKills) kills = maxKills;
       SaveInteger(homeTable, 1, GetHandleId(u), kills);
   }
   
   public function setHomecallMaxKills(unit u, integer kills) {
       SaveInteger(homeTable, 2, GetHandleId(u), kills);
   }
   
   public function addHomecallKill(unit u) {
       integer kills = LoadInteger(homeTable, 1, GetHandleId(u));
       integer maxKills = LoadInteger(homeTable, 2, GetHandleId(u));
       if(kills + 1 <= maxKills) {
           SaveInteger(homeTable, 1, GetHandleId(u), kills + 1);
       }
   }
}
//! endzinc