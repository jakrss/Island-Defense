//! zinc

library IsUnitWard {
    public function IsUnitWard(unit u) -> boolean {
        return GetUnitAbilityLevel(u, 'WARD') > 0;
    }
}

//! endzinc