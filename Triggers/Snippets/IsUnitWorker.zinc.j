//! zinc

library IsUnitWorker {
    public function IsUnitWorker(unit u) -> boolean {
        //Get's the units level of the WORKER CLASSIFICATION spell, AKA - Is it a worker?
        return GetUnitAbilityLevel(u, 'A0CN') > 0;
    }
}

//! endzinc