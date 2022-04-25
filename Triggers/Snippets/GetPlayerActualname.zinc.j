library GetPlayerActualName initializer init
    globals
        private string array NAMES
    endglobals
    
    function GetPlayerActualName takes player p returns string
        return NAMES[GetPlayerId(p)]
    endfunction
    
    private function init takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i > 11
            set NAMES[i] = GetPlayerName(Player(i))
            set i = i + 1
        endloop
    endfunction
endlibrary