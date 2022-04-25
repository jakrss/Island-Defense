//! zinc

library IsUnitTitanHunter {
    public function IsUnitTitanHunter(unit u) -> boolean {
        //Get's the units level of the TITAN HUNTER CLASSIFICATION spell
        return GetUnitAbilityLevel(u, 'TIHU') > 0;
    }
}

//! endzinc