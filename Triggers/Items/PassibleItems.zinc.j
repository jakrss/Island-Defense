//! zinc
library PassableItems requires AIDS, Table {
    private Table items = 0;
    private Table patch = 0;
    
    private function registerItems(){
        items = Table.create();
        items['I052'] = 1; // Titanic Wards
    }
    
    private function onInit(){
        trigger t = CreateTrigger();
        patch = Table.create();
        registerItems();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM);
        TriggerAddAction(t, function(){
            unit u = GetTriggerUnit();
            item it = GetManipulatedItem();
            integer id = GetItemTypeId(it);
            integer index = 0;
            
            if (items.exists(id)){
                index = GetUnitIndex(u);
                if (!patch.exists(index)){
                    patch[index] = 0;
                }
                if (patch[index] == 0){
                    patch[index] = 1;
                    RemoveItem(it);
                    UnitAddItemById(u, id);
                    GameTimer.new(function(GameTimer t){
                        integer index = t.data();
                        patch[index] = 0;
                    }).start(0.1).setData(index);
                }
            }
            
            it = null;
            u = null;
        });
    }
}
//! endzinc