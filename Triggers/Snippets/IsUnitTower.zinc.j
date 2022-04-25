//! zinc

library IsUnitTower {
    public function IsUnitTower(unit u) -> boolean {
        return GetUnitAbilityLevel(u, 'TOWR') > 0;
    }
}

//! endzinc