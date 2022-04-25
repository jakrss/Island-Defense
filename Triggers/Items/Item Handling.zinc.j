// This could possibly be improved / updated

scope ItemHandling initializer init
    private function ChangeItemToTitan takes item it returns integer
        local integer i = GetItemTypeId(it)
        if i=='I007' then     // Eye of the Ocean
            return 'I01F'
        elseif i=='I001' then // Healing Wards
            return 'I017'
        elseif i=='I002' then // Replenishment Potion
            return 'I01G'
        elseif i=='I005' then // Staff of Teleportation
            return 'I01I'
        elseif i=='I004' then // Scroll of the Beast
            return 'I018'
        elseif i=='I009' then // Trident
            return 'I03Q'
        elseif i=='I00A' then // Armored Scales
            return 'I03R'
        elseif i=='I060' then // Shadowstone
            return 'I000'
        elseif i=='I06C' then // Wand of the Wind
            return 'I01H'
        endif
        return(0)
    endfunction
    
    private function ChangeItemToBuilder takes item it returns integer 
        local integer i = GetItemTypeId(it)
        if i=='I01F' then     // Eye of the Ocean
            return('I007')
        elseif i=='I017' then // Healing Wards
            return('I001')
        elseif i=='I01G' then // Replenishment Potion
            return('I002')
        elseif i=='I01I' then // Staff of Teleportation
            return('I005')
        elseif i=='I018' then // Scroll of the Beast
            return('I004')
        elseif i=='I03Q' then // Trident
            return('I009')
        elseif i=='I03R' then // Armored Scales
            return('I00A')
        elseif i=='I000' then // Shadowstone
            return 'I060'
        elseif i=='I01H' then // Wand of the Wind
            return 'I06C'
        endif
        return(0)
    endfunction
    
    private function IsUnitAllowedItem takes unit u, item it returns boolean
        local integer i = GetItemTypeId(it)
        local itemtype t = GetItemType(it)
        local player p = GetOwningPlayer(u)
        if (GetUnitTypeId(u) == XE_DUMMY_UNITID) then
            return true
        endif
        
        if t == ITEM_TYPE_CHARGED then
            if PlayerData.get(p).class() == PlayerData.CLASS_TITAN or PlayerData.get(p).class() == PlayerData.CLASS_MINION then
                set i = ChangeItemToTitan(it)
                if i != 0 then
                    call RemoveItem(it)
                    call UnitAddItem(u, CreateItem(i, 0, 0))
                endif
            else
                set i = ChangeItemToBuilder(it)
                if i != 0 then
                    call RemoveItem(it)
                    call UnitAddItem(u, CreateItem(i, 0, 0))
                endif
            endif
        elseif (t == ITEM_TYPE_CAMPAIGN or t == ITEM_TYPE_PERMANENT) and GetUnitPointValue(u) > 199 then
            return false
        elseif t == ITEM_TYPE_ARTIFACT and GetUnitPointValue(u) < 200 then
            return false
        elseif t == ITEM_TYPE_MISCELLANEOUS then
            call RemoveItem(it)
        endif
        return true
    endfunction

    private function act takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local item i = GetManipulatedItem()
        local real x = GetUnitX(u)
        local real y = GetUnitY(u)
        local boolean b = IsUnitAllowedItem(u, i)
        if not b then
            call SetItemPosition(i, x, y)
        endif
        set u=null   
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_PICKUP_ITEM )
        call TriggerAddAction(t, function act)
    endfunction
endscope