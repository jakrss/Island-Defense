/************************************
*
*   ElapsedGameTime
*   v2.0.0.0
*   By Magtheridon96
*   
*   - Fires a code given an elapsed game time.
*   - Retrieves:
*       - A Formatted Game-time String
*       - The Total Elapsed Game-time in Seconds
*       - The Game-time Seconds (0 <= x <= 59)
*       - The Game-time Minutes (0 <= x <= 59)
*       - The Game-time Hours   (0 <= x)
*
*   Optional Requirements:
*   ----------------------
*
*       - Table by Bribe
*           - hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
*   API:
*   ----
*
*       - struct ElapsedGameTime extends array
*
*           - static method registerEvent takes real time, code c returns nothing
*               - Registers a code that will execute at the given time.
*
*           - static method start takes nothing returns nothing
*           - static method pause takes nothing returns nothing
*           - static method resume takes nothing returns nothing
*               - These are used to start/pause/resume the game timer.
*
*           - static method operator paused takes nothing returns boolean
*           - static method operator running takes nothing returns boolean
*               - These determine whether the system is running or not.
*
*           - static method getTime takes nothing returns real
*               - Gets the total elapsed game time in seconds.
*
*           - static method getSeconds takes nothing returns integer
*           - static method getMinutes takes nothing returns integer
*           - static method getHours takes nothing returns integer
*               - These static methods get the clock values.
*
*           - static method getTimeSeconds takes nothing returns integer
*               - Gets the elapsed game time string (Formatted)
*
*       - function RegisterElapsedGameTimeEvent takes real time, code c returns nothing
*           - Registers a code that will execute at the given time.
*
*       - function StartGameTimer takes nothing returns nothing
*       - function PauseGameTimer takes nothing returns nothing
*       - function ResumeGameTimer takes nothing returns nothing
*           - These are used to start/pause/resume the game timer.
*
*       - function IsGameTimerPaused takes nothing returns boolean
*       - function IsGameTimerRunning takes nothing returns boolean
*           - These determine whether the system is running or not.
*
*       - function GetElapsedGameTime takes nothing returns real
*           - Gets the total elapsed game time in seconds.
*
*       - function GetGameTimeSeconds takes nothing returns integer
*       - function GetGameTimeMinutes takes nothing returns integer
*       - function GetGameTimeHours takes nothing returns integer
*           - Gets the elapsed game time hours
*
*       - function GetGameTimeString takes nothing returns string
*           - Gets the elapsed game time string (Formatted)
*
************************************/
library ElapsedGameTime requires optional Table
 
    globals
        // If this is set to true, you need to call ElapsedGameTime.start() manually.
        private constant boolean CUSTOM_START_TIME = true
        // This timer interval. If accuracy means nothing to you, increase it.
        private constant real INTERVAL = 1.0
    endglobals
    
    private module Init
        private static method onInit takes nothing returns nothing
            static if not CUSTOM_START_TIME then
                call start()
            endif
        endmethod
    endmodule
    
    struct ElapsedGameTime extends array
        private static integer seconds = 0
        private static integer minutes = 0
        private static integer hours = 0
        
        private static real current = 0
        private static trigger t = CreateTrigger()
        private static timer gameTimer = CreateTimer()
        
        private static boolean startedX = false
        private static boolean runningX = false
        private static boolean done0 = false
        
        private static method run takes nothing returns nothing
            local integer count
            
            if done0 then
                // Game-time Data manager (For the user)
                if R2I(current + INTERVAL) > current then
                    set seconds = seconds + 1
                    if seconds == 60 then
                        set seconds = 0
                        set minutes = minutes + 1
                        if minutes == 60 then
                            set minutes = 0
                            set hours = hours + 1
                        endif
                    endif
                endif
                
                // Increase current index
                set current = current + INTERVAL
                
            else
                set done0 = true
                call TimerStart(gameTimer, INTERVAL, true, function thistype.run)
            endif
        endmethod
        
        static method operator paused takes nothing returns boolean
            return not runningX
        endmethod
        
        static method operator running takes nothing returns boolean
            return runningX
        endmethod
        
        static method operator started takes nothing returns boolean
            return startedX
        endmethod
        
        static method start takes nothing returns nothing
            if done0 then
                call TimerStart(gameTimer, INTERVAL, true, function thistype.run)
            else
                call TimerStart(gameTimer, 0, false, function thistype.run)
            endif
            set runningX = true
            set startedX = true
        endmethod
        
        static method stop takes nothing returns nothing
            set current = 0.0
            set seconds = 0
            set minutes = 0
            set hours = 0
            set runningX = false
            set startedX = false
            call PauseTimer(gameTimer)
            call DestroyTimer(gameTimer)
            set gameTimer = CreateTimer()
        endmethod
        
        static method pause takes nothing returns nothing
            call PauseTimer(gameTimer)
            set runningX = false
        endmethod
        
        static method resume takes nothing returns nothing
            call start()
        endmethod
        
        static method getTime takes nothing returns real
            // You mad TimerGetElapsed?
            return current
        endmethod
        
        static method getSeconds takes nothing returns integer
            return seconds
        endmethod
        
        static method getMinutes takes nothing returns integer
            return minutes
        endmethod
        
        static method getHours takes nothing returns integer
            return hours
        endmethod
        
        static method getTimeString takes nothing returns string
            local string s = I2S(seconds)
            if seconds < 10 then
                set s = "0" + s
            endif
            set s = I2S(minutes) + ":" + s
            if minutes < 10 then
                set s = "0" + s
            endif
            set s = I2S(hours) + ":" + s
            if hours < 10 then
                set s = "0" + s
            endif
            return s
        endmethod
        
        implement Init
    endstruct
    
    function StartGameTimer takes nothing returns nothing
        call ElapsedGameTime.start()
    endfunction
    
    function PauseGameTimer takes nothing returns nothing
        call ElapsedGameTime.pause()
    endfunction
    
    function ResumeGameTimer takes nothing returns nothing
        call ElapsedGameTime.resume()
    endfunction
    
    function IsGameTimerPaused takes nothing returns boolean
        return ElapsedGameTime.paused
    endfunction
    
    function IsGameTimerRunning takes nothing returns boolean
        return ElapsedGameTime.running
    endfunction
    
    function GetElapsedGameTime takes nothing returns real
        return ElapsedGameTime.getTime()
    endfunction
    
    function GetGameTimeHours takes nothing returns integer
        return ElapsedGameTime.getHours()
    endfunction
    
    function GetGameTimeMinutes takes nothing returns integer
        return ElapsedGameTime.getMinutes()
    endfunction
    
    function GetGameTimeSeconds takes nothing returns integer
        return ElapsedGameTime.getSeconds()
    endfunction
    
    function GetGameTimeString takes nothing returns string
        return ElapsedGameTime.getTimeString()
    endfunction
 
endlibrary