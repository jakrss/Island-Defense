//! zinc

library UnitAlive {
    public function UnitAlive(unit id) -> boolean {
        return !IsUnitType(id, UNIT_TYPE_DEAD) && GetUnitTypeId(id) != 0;
    }
}

//! endzinc