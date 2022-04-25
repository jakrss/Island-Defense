//! zinc

library IsUnitWall {
    public function IsUnitWall(unit u) -> boolean {
        return GetUnitAbilityLevel(u, 'WALL') > 0;
    }
}

//! endzinc