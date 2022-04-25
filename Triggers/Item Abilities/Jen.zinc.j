//! zinc

library Jen requires ShowTagFromUnit, DestroyEffectTimed {
	private constant real sX = 10432.0;
	private constant real sY = 1600.0;
	
	private real oX = 0.0;
	private real oY = 0.0;
	private real oF = 0.0;

	private function UnitIndexItemOfType(unit whichUnit, integer itemId) -> integer {
		integer index = 0;
		item indexItem = null;

		for(0 <= index < bj_MAX_INVENTORY) {
			indexItem = UnitItemInSlot(whichUnit, index);
			if (indexItem != null && GetItemTypeId(indexItem) == itemId) {
				indexItem = null;
				return index + 1;
			}
		}
		indexItem = null;
		return 0;
	}

    private function HasItem() -> boolean {
		unit u = GetFilterUnit();
		boolean b = UnitIndexItemOfType(u, 'I00Q') > 0;
		u = null;
        return b;
    }
    
    private function tick() {
        group g = null;
        boolexpr b = null;
        unit u = null;
		unit a = null;
        real x = 0.0;
		real y = 0.0;
		
		if (gg_unit_nJEN_0152 != null && UnitAlive(gg_unit_nJEN_0152)) {
			g = CreateGroup();
			a = gg_unit_nJEN_0152;
			b = Filter(function HasItem);
			x = GetUnitX(a);
			y = GetUnitY(a);	
			
			if (oX == 0.0) {
				// On first run get default Jen frog pos
				oX = x;
				oY = y;
				oF = GetUnitFacing(a);
			}
			
			
			GroupEnumUnitsInRange(g, x, y, 500.0, b);
			
			u = FirstOfGroup(g);
			if (u != null) {
				if (IsUnitInRangeXY(a, sX, sY, 300.0)) {
					ShowTagFromUnitForAll("|cffffffff"+"T"+"ha"+"t"+"'"+"s "+"e"+"no"+"u"+"g"+"h "+"a"+"d"+"v"+"e"+"n"+"t"+"u"+"r"+"in"+"g"+" f"+"o"+"r "+"t"+"o"+"d"+"a"+"y"+"!"+"|r", a);
					DestroyEffectTimed(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl", x, y), 1.0);
					SetUnitX(a, oX);
					SetUnitY(a, oY);
					SetUnitFacing(a, oF);
					SetUnitPathing(a, true);
					
					CreateItem('I055', x, y);
				}
				else {
					IssuePointOrder(a, "smart", GetUnitX(u), GetUnitY(u));
					SetUnitPathing(a, false);
				}
			}
			GroupClear(g);
			DestroyGroup(g);
			DestroyBoolExpr(b);
		}
		a = null;
        u = null;
        g = null;
        b = null;
    }

    private function onInit() {
        trigger t = CreateTrigger();
        TriggerRegisterTimerEvent(t, 2.00, true);
        TriggerAddAction(t, function tick);
        t = null;
    }
}

//! endzinc
