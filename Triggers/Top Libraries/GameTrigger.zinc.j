//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~ GT ~~ GTrigger ~~ By Jesus4Lyf ~~ Version 1.05 ~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//  What is GTrigger?
//		 - GTrigger is an event system that replaces the cumbersome WC3
//		   event system.
//		 - GTrigger only launches the necessary threads instead of x threads,
//		   where x is the number of times the event type occurs in the map.
//
//	=Pros=
//		 - Instead of having 16 events (for "16" players) per use of an,
//		   event type, you have 0 per use and 16 total for that event type.
//		 - If you have 100 events of one type in your map, instead of firing
//		   100 triggers each time any spell is cast, you fire only what's needed.
//		 - GTrigger is faster to code with, more efficient to execute, and just
//		   better programming practises and nicer code all round.
//
//	=Cons=
//		 - If a trigger with a GTrigger event is destroyed, it must have its
//		   event unregistered first or it will leak an event (slows firing down).
//		 - Shouldn't use "wait" actions anywhere in the triggers.
//
//	Functions:
//		   // General
//		 - GT_UnregisterTriggeringEvent()
//
//		   // Ability events
//		 - GT_RegisterStartsEffectEvent(trigger, abilityid)       (returns the trigger passed in)
//		 - GT_RegisterBeginsChannelingEvent(trigger, abilityid)   (returns the trigger passed in)
//		 - GT_RegisterBeginsCastingEvent(trigger, abilityid)      (returns the trigger passed in)
//		 - GT_RegisterStopsCastingEvent(trigger, abilityid)       (returns the trigger passed in)
//		 - GT_RegisterFinishesCastingEvent(trigger, abilityid)    (returns the trigger passed in)
//		 - GT_RegisterLearnsAbilityEvent(trigger, abilityid)       (returns the trigger passed in)
//		   // Order events // (can use String2OrderIdBJ("OrderString") for orderid
//		 - GT_RegisterTargetOrderEvent(trigger, orderid)          (returns the trigger passed in)
//		 - GT_RegisterPointOrderEvent(trigger, orderid)           (returns the trigger passed in)
//		 - GT_RegisterNoTargetOrderEvent(trigger, orderid)        (returns the trigger passed in)
//		   // Item events
//		 - GT_RegisterItemUsedEvent(trigger, itemtypeid)          (returns the trigger passed in)
//		 - GT_RegisterItemAcquiredEvent(trigger, itemtypeid)      (returns the trigger passed in)
//		 - GT_RegisterItemDroppedEvent(trigger, itemtypeid)       (returns the trigger passed in)
//		   // Unit events
//		 - GT_RegisterUnitDiesEvent(trigger, unittypeid)          (returns the trigger passed in)
//
//		   // Ability Events
//		 - GT_UnregisterSpellEffectEvent(trigger, abilityid)      (returns the trigger passed in)
//		 - GT_UnregisterBeginsChannelingEvent(trigger, abilityid) (returns the trigger passed in)
//		 - GT_UnregisterBeginsCastingEvent(trigger, abilityid)    (returns the trigger passed in)
//		 - GT_UnregisterStopsCastingEvent(trigger, abilityid)     (returns the trigger passed in)
//		 - GT_UnregisterFinishesCastingEvent(trigger, abilityid)  (returns the trigger passed in)
//		 - GT_UnregisterLearnsAbilityEvent(trigger, abilityid)     (returns the trigger passed in)
//		   // Order events // (can use String2OrderIdBJ("OrderString") for orderid
//		 - GT_UnregisterTargetOrderEvent(trigger, orderid)        (returns the trigger passed in)
//		 - GT_UnregisterPointOrderEvent(trigger, orderid)         (returns the trigger passed in)
//		 - GT_UnregisterNoTargetOrderEvent(trigger, orderid)      (returns the trigger passed in)
//		   // Item events
//		 - GT_UnregisterItemUsedEvent(trigger, itemtypeid)        (returns the trigger passed in)
//		 - GT_UnregisterItemAcquiredEvent(trigger, itemtypeid)    (returns the trigger passed in)
//		 - GT_UnregisterItemDroppedEvent(trigger, itemtypeid)     (returns the trigger passed in)
//		   // Unit events
//		 - GT_UnregisterUnitDiesEvent(trigger, unittypeid)        (returns the trigger passed in)
//
//	Alternative interface (not recommended):
//		If you aren't familiar with how this works, you shouldn't use it.
//		All funcs must return false. (That is the only reason it isn't recommended.)
//		   // General
//		 - GT_RemoveTriggeringAction() // Use this to remove actions.
//		   // Ability Events
//		 - GT_AddStartsEffectAction(func, abilityid)
//		 - GT_AddBeginsChannelingActon(func, abilityid)
//		 - GT_AddBeginsCastingAction(func, abilityid)
//		 - GT_AddStopsCastingAction(func, abilityid)
//		 - GT_AddFinishesCastingAction(func, abilityid)
//		 - GT_AddLearnsAbilityAction(func, abilityid)
//		   // Order events // (can use String2OrderIdBJ("OrderString") for orderid
//		 - GT_AddTargetOrderAction(func, orderid)
//		 - GT_AddPointOrderAction(func, orderid)
//		 - GT_AddNoTargetOrderAction(func, orderid)
//		   // Item events
//		 - GT_AddItemUsedAction(func, itemtypeid)
//		 - GT_AddItemAcquiredAction(func, itemtypeid)
//		 - GT_AddItemDroppedAction(func, itemtypeid)
//		   // Unit events
//		 - GT_AddUnitDiesAction(func, unittypeid)
//
//  Details:
//		 - Due to the storage method, only 8191 GTrigger events are possible at any one time.
//
//  Thanks:
//		 - Daxtreme: For voluntarily testing this system and the UnitDies event idea.
//		 - kenny!: For the Order and Learns Ability event ideas.
//
//  How to import:
//		 - Create a trigger named GT.
//		 - Convert it to custom text and replace the whole trigger text with this.
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library GT initializer Init
    //////////////
    // Pointers //
    ////////////////////////////////////////////////////////////////////////////
    // Assigned to abilities, and point to trigger grouping linked lists.
    //
    // Use:
    //  GetPointer --> int (pointer)
    //  FreePointer(int (pointer))
    //  set PointerTarget[int (pointer)]=int (list link)
    //  PointerTarget[int (pointer)] --> int (list link)
    globals
        // Pointer
        private integer array PointerTarget
        private integer PointerMax=0
        // Spare Pointer Stack
        private integer array NextPointer
        private integer NextPointerMaxPlusOne=1
    endglobals
    
    private function GetPointer takes nothing returns integer
        if NextPointerMaxPlusOne==1 then
            set PointerMax=PointerMax+1
            return PointerMax
        endif
        set NextPointerMaxPlusOne=NextPointerMaxPlusOne-1
        return NextPointer[NextPointerMaxPlusOne]
    endfunction
    private function FreePointer takes integer pointer returns nothing
        set PointerTarget[pointer]=0
        set NextPointer[NextPointerMaxPlusOne]=pointer
        set NextPointerMaxPlusOne=NextPointerMaxPlusOne+1
    endfunction
    
    ///////////////////////////////////
    // Trigger Grouping Linked Lists //
    ////////////////////////////////////////////////////////////////////////////
    // Contains a chain of triggers to be executed together.
    //
    // Use:
    //  GetMem() --> int (mem)
    //  FreeMem(int (mem))
    //  Link(int (pointer), int (mem))
    //  Unlink(int (pointer), int (mem))
    globals
        // Spare Link Stack
        private integer array NextMem
        private integer NextMemMaxPlusOne=1
        // Linked list
        private trigger array Trig
        private integer array Next
        private integer array Prev
        private integer TrigMax=0
    endglobals
    
    private function GetMem takes nothing returns integer
        if NextMemMaxPlusOne==1 then
            set TrigMax=TrigMax+1
            return TrigMax
        endif
        set NextMemMaxPlusOne=NextMemMaxPlusOne-1
        return NextMem[NextMemMaxPlusOne]
    endfunction
    private function FreeMem takes integer i returns nothing
        set Trig[i]=null
        set NextMem[NextMemMaxPlusOne]=i
        set NextMemMaxPlusOne=NextMemMaxPlusOne+1
    endfunction
    
    // Linked list functionality
    // NOTE: This means "Next" must be loaded BEFORE executing the trigger, which could delete the current link.
    private function Link takes integer pointer, integer new returns nothing
        set Prev[new]=0
        set Next[new]=PointerTarget[pointer]
        set Prev[PointerTarget[pointer]]=new
        set PointerTarget[pointer]=new
    endfunction
    private function Unlink takes integer pointer, integer rem returns nothing
        if Prev[rem]==0 then
            set PointerTarget[pointer]=Next[rem]
            set Prev[Next[rem]]=0
        endif
        set Next[Prev[rem]]=Next[rem]
        set Prev[Next[rem]]=Prev[rem]
    endfunction
    
    //////////////////////
    // GTrigger General //
    ////////////////////////////////////////////////////////////////////////////
    // Only contains the UnregisterTriggeringEvent action for public use.
    globals
        boolean UnregisterLastEvent=false
    endglobals
    public function UnregisterTriggeringEvent takes nothing returns nothing
        set UnregisterLastEvent=true
    endfunction
    
    /////////////////////////////////////
    // GTrigger Ability Implementation //
    ////////////////////////////////////////////////////////////////////////////
    // The nasty textmacro implementation of special "All Players" events.
    //! textmacro SetupSpecialAllPlayersEvent takes NAME, EVENT, GETSPECIAL
        globals
            private trigger $NAME$Trigger=CreateTrigger()
            // Extendable arrays
            private integer array $NAME$AbilityIdA
            private integer array $NAME$ListPointerA
            private integer array $NAME$AbilityIdB
            private integer array $NAME$ListPointerB
            private integer array $NAME$AbilityIdC
            private integer array $NAME$ListPointerC
            private integer array $NAME$AbilityIdD
            private integer array $NAME$ListPointerD
            private integer array $NAME$AbilityIdE
            private integer array $NAME$ListPointerE
        endglobals
        
        globals//locals
            private integer GetOrCreateListPointer$NAME$AbilHashed
        endglobals
        private function GetOrCreate$NAME$ListPointer takes integer abil returns integer
            set GetOrCreateListPointer$NAME$AbilHashed=abil-(abil/8191)*8191
            if $NAME$AbilityIdA[GetOrCreateListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerA[GetOrCreateListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdA[GetOrCreateListPointer$NAME$AbilHashed]<1 then // Empty
                set $NAME$AbilityIdA[GetOrCreateListPointer$NAME$AbilHashed]=abil
                set $NAME$ListPointerA[GetOrCreateListPointer$NAME$AbilHashed]=GetPointer()
                return $NAME$ListPointerA[GetOrCreateListPointer$NAME$AbilHashed]
            endif
            if $NAME$AbilityIdB[GetOrCreateListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerB[GetOrCreateListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdB[GetOrCreateListPointer$NAME$AbilHashed]<1 then // Empty
                set $NAME$AbilityIdB[GetOrCreateListPointer$NAME$AbilHashed]=abil
                set $NAME$ListPointerB[GetOrCreateListPointer$NAME$AbilHashed]=GetPointer()
                return $NAME$ListPointerB[GetOrCreateListPointer$NAME$AbilHashed]
            endif
            if $NAME$AbilityIdC[GetOrCreateListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerC[GetOrCreateListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdC[GetOrCreateListPointer$NAME$AbilHashed]<1 then // Empty
                set $NAME$AbilityIdC[GetOrCreateListPointer$NAME$AbilHashed]=abil
                set $NAME$ListPointerC[GetOrCreateListPointer$NAME$AbilHashed]=GetPointer()
                return $NAME$ListPointerC[GetOrCreateListPointer$NAME$AbilHashed]
            endif
            if $NAME$AbilityIdD[GetOrCreateListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerD[GetOrCreateListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdD[GetOrCreateListPointer$NAME$AbilHashed]<1 then // Empty
                set $NAME$AbilityIdD[GetOrCreateListPointer$NAME$AbilHashed]=abil
                set $NAME$ListPointerD[GetOrCreateListPointer$NAME$AbilHashed]=GetPointer()
                return $NAME$ListPointerD[GetOrCreateListPointer$NAME$AbilHashed]
            endif
            if $NAME$AbilityIdE[GetOrCreateListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerE[GetOrCreateListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdE[GetOrCreateListPointer$NAME$AbilHashed]<1 then // Empty
                set $NAME$AbilityIdE[GetOrCreateListPointer$NAME$AbilHashed]=abil
                set $NAME$ListPointerE[GetOrCreateListPointer$NAME$AbilHashed]=GetPointer()
                return $NAME$ListPointerE[GetOrCreateListPointer$NAME$AbilHashed]
            endif
            call BJDebugMsg("GTrigger Error: Ran out of storage locations for pointers on object "+GetObjectName(abil)+"!")
            set PointerTarget[0]=0
            return 0
        endfunction
        
        globals//locals
            private integer GetListPointer$NAME$AbilHashed
        endglobals
        private function Get$NAME$ListPointer takes integer abil returns integer
            set GetListPointer$NAME$AbilHashed=abil-(abil/8191)*8191
            if $NAME$AbilityIdA[GetListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerA[GetListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdA[GetListPointer$NAME$AbilHashed]<1 then // Empty
                set PointerTarget[0]=0 // Make sure.
                return 0
            endif
            if $NAME$AbilityIdB[GetListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerB[GetListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdB[GetListPointer$NAME$AbilHashed]<1 then // Empty
                set PointerTarget[0]=0 // Make sure.
                return 0
            endif
            if $NAME$AbilityIdC[GetListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerC[GetListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdC[GetListPointer$NAME$AbilHashed]<1 then // Empty
                set PointerTarget[0]=0 // Make sure.
                return 0
            endif
            if $NAME$AbilityIdD[GetListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerD[GetListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdD[GetListPointer$NAME$AbilHashed]<1 then // Empty
                set PointerTarget[0]=0 // Make sure.
                return 0
            endif
            if $NAME$AbilityIdE[GetListPointer$NAME$AbilHashed]==abil then // Correct
                return $NAME$ListPointerE[GetListPointer$NAME$AbilHashed]
            elseif $NAME$AbilityIdE[GetListPointer$NAME$AbilHashed]<1 then // Empty
                set PointerTarget[0]=0 // Make sure.
                return 0
            endif
            call BJDebugMsg("GTrigger Error: Ran out of storage locations for pointers at ability "+GetObjectName(abil)+"!")
            set PointerTarget[0]=0
            return 0
        endfunction
        
        globals//locals
            private integer Register$NAME$Mem
        endglobals
        public function Register$NAME$Event takes trigger t, integer abil returns trigger
            set Register$NAME$Mem=GetMem()
            set Trig[Register$NAME$Mem]=t
            call Link(GetOrCreate$NAME$ListPointer(abil),Register$NAME$Mem)
            return t
        endfunction
        
        globals//locals
            private integer Unregister$NAME$Pointer
            private integer Unregister$NAME$Mem
        endglobals
        public function Unregister$NAME$Event takes trigger t, integer abil returns trigger
            set Unregister$NAME$Pointer=Get$NAME$ListPointer(abil)
            set Unregister$NAME$Mem=PointerTarget[Unregister$NAME$Pointer]
            loop
                exitwhen Trig[Unregister$NAME$Mem]==t
                if Unregister$NAME$Mem==0 then
                    return t // Not found.
                endif
                set Unregister$NAME$Mem=Next[Unregister$NAME$Mem]
            endloop
            call Unlink(Unregister$NAME$Pointer,Unregister$NAME$Mem)
            call FreeMem(Unregister$NAME$Mem)
            return t
        endfunction
        
        private function Trigger$NAME$Event takes nothing returns boolean
            local integer Trigger$NAME$Pointer=Get$NAME$ListPointer($GETSPECIAL$)
            local integer Trigger$NAME$Mem=PointerTarget[Trigger$NAME$Pointer]
            local integer Trigger$NAME$NextMem
            set UnregisterLastEvent=false
            loop
                exitwhen Trigger$NAME$Mem<1
                set Trigger$NAME$NextMem=Next[Trigger$NAME$Mem]
                if TriggerEvaluate(Trig[Trigger$NAME$Mem]) then
                    call TriggerExecute(Trig[Trigger$NAME$Mem])
                endif
                if UnregisterLastEvent then
                    set UnregisterLastEvent=false
                    call Unlink(Trigger$NAME$Pointer,Trigger$NAME$Mem)
                    call FreeMem(Trigger$NAME$Mem)
                endif
                set Trigger$NAME$Mem=Trigger$NAME$NextMem
            endloop
            return false
        endfunction
        
        private function Init$NAME$ takes nothing returns nothing
            local integer i=bj_MAX_PLAYER_SLOTS
            call TriggerAddCondition($NAME$Trigger,Condition(function Trigger$NAME$Event))
            loop
                set i=i-1
                call TriggerRegisterPlayerUnitEvent($NAME$Trigger,Player(i),EVENT_PLAYER_$EVENT$,null)
                exitwhen i==0
            endloop
        endfunction
    //! endtextmacro
    
    //! runtextmacro SetupSpecialAllPlayersEvent("StartsEffect",     "UNIT_SPELL_EFFECT",        "GetSpellAbilityId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("BeginsChanneling", "UNIT_SPELL_CHANNEL",       "GetSpellAbilityId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("BeginsCasting",    "UNIT_SPELL_CAST",          "GetSpellAbilityId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("StopsCasting",     "UNIT_SPELL_ENDCAST",       "GetSpellAbilityId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("FinishesCasting",  "UNIT_SPELL_FINISH",        "GetSpellAbilityId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("TargetOrder",      "UNIT_ISSUED_TARGET_ORDER", "GetIssuedOrderId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("PointOrder",       "UNIT_ISSUED_POINT_ORDER",  "GetIssuedOrderId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("NoTargetOrder",    "UNIT_ISSUED_ORDER",        "GetIssuedOrderId()")
    //! runtextmacro SetupSpecialAllPlayersEvent("ItemUsed",         "UNIT_USE_ITEM",            "GetItemTypeId(GetManipulatedItem())")
    //! runtextmacro SetupSpecialAllPlayersEvent("ItemAcquired",     "UNIT_PICKUP_ITEM",         "GetItemTypeId(GetManipulatedItem())")
    //! runtextmacro SetupSpecialAllPlayersEvent("ItemDropped",      "UNIT_DROP_ITEM",           "GetItemTypeId(GetManipulatedItem())")
    //! runtextmacro SetupSpecialAllPlayersEvent("UnitDies",         "UNIT_DEATH",               "GetUnitTypeId(GetTriggerUnit())")
    //! runtextmacro SetupSpecialAllPlayersEvent("LearnsAbility",    "HERO_SKILL",               "GetLearnedSkill()")
    // Note to self: Remember to update the Init function.
    
    /////////////////////////////////////////
    // GTrigger All Players Implementation //
    ////////////////////////////////////////////////////////////////////////////
    // The textmacro implementation of other "All Players" events.
    //! textmacro SetupAllPlayersEvent takes NAME, EVENT
        globals
            private trigger $NAME$Trigger=CreateTrigger()
            private integer $NAME$ListPointer=0
        endglobals
        
        globals//locals
            private integer Register$NAME$Mem
        endglobals
        public function Register$NAME$Event takes trigger t returns trigger
            set Register$NAME$Mem=GetMem()
            set Trig[Register$NAME$Mem]=t
            call Link($NAME$ListPointer,Register$NAME$Mem)
            return t
        endfunction
        
        globals//locals
            private integer Unregister$NAME$Pointer
            private integer Unregister$NAME$Mem
        endglobals
        public function Unregister$NAME$Event takes trigger t returns trigger
            set Unregister$NAME$Mem=PointerTarget[$NAME$ListPointer]
            loop
                exitwhen Trig[Unregister$NAME$Mem]==t
                if Unregister$NAME$Mem==0 then
                    return t // Not found.
                endif
                set Unregister$NAME$Mem=Next[Unregister$NAME$Mem]
            endloop
            call Unlink($NAME$ListPointer,Unregister$NAME$Mem)
            call FreeMem(Unregister$NAME$Mem)
            return t
        endfunction
        
        private function Trigger$NAME$Event takes nothing returns boolean
            local integer Trigger$NAME$Mem=PointerTarget[$NAME$ListPointer]
            local integer Trigger$NAME$NextMem
            set UnregisterLastEvent=false
            loop
                exitwhen Trigger$NAME$Mem<1
                set Trigger$NAME$NextMem=Next[Trigger$NAME$Mem]
                if TriggerEvaluate(Trig[Trigger$NAME$Mem]) then
                    call TriggerExecute(Trig[Trigger$NAME$Mem])
                endif
                if UnregisterLastEvent then
                    set UnregisterLastEvent=false
                    call Unlink($NAME$ListPointer,Trigger$NAME$Mem)
                    call FreeMem(Trigger$NAME$Mem)
                endif
                set Trigger$NAME$Mem=Trigger$NAME$NextMem
            endloop
            return false
        endfunction
        
        private function Init$NAME$ takes nothing returns nothing
            local integer i=bj_MAX_PLAYER_SLOTS
            call TriggerAddCondition($NAME$Trigger,Condition(function Trigger$NAME$Event))
            loop
                set i=i-1
                call TriggerRegisterPlayerUnitEvent($NAME$Trigger,Player(i),EVENT_PLAYER_UNIT_$EVENT$,null)
                exitwhen i==0
            endloop
            // Initialise the pointer.
            set $NAME$ListPointer=GetPointer()
        endfunction
    //! endtextmacro
    
    // Old: //! runtextmacro SetupAllPlayersEvent("AnyUnitDies", "DEATH")
    
    private function Init takes nothing returns nothing
        // Ability events
        call InitStartsEffect()
        call InitBeginsChanneling()
        call InitBeginsCasting()
        call InitStopsCasting()
        call InitFinishesCasting()
        call InitLearnsAbility()
        // Order events
        call InitTargetOrder()
        call InitPointOrder()
        call InitNoTargetOrder()
        // Item events
        call InitItemUsed()
        call InitItemAcquired()
        call InitItemDropped()
        // Unit events
        call InitUnitDies()
    endfunction
    
    //////////////
    // Wrappers //
    ////////////////////////////////////////////////////////////////////////////
    // Wraps it up, for those who really want this interface.
    
    // General
    public function RemoveTriggeringAction takes nothing returns nothing
        call UnregisterTriggeringEvent()
        call DestroyTrigger(GetTriggeringTrigger())
    endfunction
    
    // Special All Player Events
    //! textmacro AddSpecialAllPlayersWrapper takes EVENT
        public function Add$EVENT$Action takes code func, integer special returns nothing
            call TriggerAddCondition(Register$EVENT$Event(CreateTrigger(),special),Condition(func))
        endfunction
    //! endtextmacro
    //! runtextmacro AddSpecialAllPlayersWrapper("StartsEffect")
    //! runtextmacro AddSpecialAllPlayersWrapper("BeginsChanneling")
    //! runtextmacro AddSpecialAllPlayersWrapper("BeginsCasting")
    //! runtextmacro AddSpecialAllPlayersWrapper("StopsCasting")
    //! runtextmacro AddSpecialAllPlayersWrapper("FinishesCasting")
    //! runtextmacro AddSpecialAllPlayersWrapper("TargetOrder")
    //! runtextmacro AddSpecialAllPlayersWrapper("PointOrder")
    //! runtextmacro AddSpecialAllPlayersWrapper("NoTargetOrder")
    //! runtextmacro AddSpecialAllPlayersWrapper("ItemUsed")
    //! runtextmacro AddSpecialAllPlayersWrapper("ItemAcquired")
    //! runtextmacro AddSpecialAllPlayersWrapper("ItemDropped")
    //! runtextmacro AddSpecialAllPlayersWrapper("UnitDies")
    //! runtextmacro AddSpecialAllPlayersWrapper("LearnsAbility")
    // Note to self: Remember to update the Init function.
    
    // All Player Events
    //! textmacro AddAllPlayersWrapper takes EVENT
        public function Add$EVENT$Action takes code func returns nothing
            call TriggerAddCondition(Register$EVENT$Event(CreateTrigger()),Condition(func))
        endfunction
    //! endtextmacro
    // Old: //! runtextmacro AddAllPlayersWrapper("AnyUnitDies")
endlibrary