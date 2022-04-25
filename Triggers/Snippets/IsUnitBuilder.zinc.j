//! zinc

library IsUnitBuilder {
    public function IsUnitBuilder(unit u) -> boolean {
        //Get's the units level of the BUILDER CLASSIFICATION spell
        return GetUnitAbilityLevel(u, 'BLDR') > 0;
    }
}

//! endzinc