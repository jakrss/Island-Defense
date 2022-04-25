//! zinc

library UnitAddChaos {
    public function UnitAddChaos(unit u, integer id) {
		real x = GetUnitX(u);
		real y = GetUnitY(u);
		item items[];
		integer i = 0;
		if (UnitInventorySize(u) > 0) {
			for (0 <= i < 6) {
				items[i] = UnitItemInSlot(u, i);
				SetItemPosition(items[i], x, y);
			}
		}
		
		UnitRemoveBuffs(u, true, true);
		
		UnitAddAbility(u, id);
		
		if (UnitInventorySize(u) > 0) {
			for (0 <= i < 6) {
				if (items[i] != null) {
					UnitAddItem(u, items[i]);
					items[i] = null;
				}
			}
		}
    }
}

//! endzinc