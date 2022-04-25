//! zinc

library RevealMapForPlayer requires UnitManager, GameTimer, xebasic {
    public function RevealMapForPlayer(player p){
        unit u = CreateUnit(p, XE_DUMMY_UNITID,
                            GetUnitX(UnitManager.TITAN_SPELL_WELL),
                            GetUnitY(UnitManager.TITAN_SPELL_WELL),
                            bj_UNIT_FACING);
        integer id = GetUnitIndex(u);
        item it = CreateItem('IREV', 0, 0);
        
        UnitAddAbility(u, 'AInv');
        SetUnitMoveSpeed(u, 0.0);
        UnitAddItem(u, it);
        UnitUseItem(u, it);
        UnitApplyTimedLife(u, 'BTLF', 2.0);
        
        u = null;
        it = null;
        
        
        // Old way (stops unit attacks, other problems, etc)
        //FogEnable(false);
        //FogEnable(true);
    }
}

//! endzinc