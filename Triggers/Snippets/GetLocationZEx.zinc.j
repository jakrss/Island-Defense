//TESH.scrollpos=0
//TESH.alwaysfold=0
//! zinc

library GetLocationZEx {
    private constant real METRIC = 25.0;
    private location loc = Location(0.0, 0.0);
    
    private function Round(real x, real multiple) -> real {
        real half = multiple / 2.0;
        return x + half - ModuloReal((x + half), multiple);
    }
    
    public function LocGetZ(location l) -> real {
        // 0100: Added Round to possibly fix desync issues
		// 0101: Reverted due to desync still existing...
        return GetLocationZ(l); //Round(GetLocationZ(l), METRIC);
    }
    
    public function XYGetZ(real x, real y) -> real {
        MoveLocation(loc, x, y);
        return LocGetZ(loc);
    }
}

//! endzinc