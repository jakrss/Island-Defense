//! zinc

library CreateItemEx {
    public function CreateItemEx(integer itemid, real x, real y) -> item {
        item it = CreateItem(itemid, x, y);
        //InvulnerableItems.checkItem(it);
        return it;
    }
}

//! endzinc