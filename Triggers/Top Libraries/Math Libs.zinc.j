//! zinc
library MathLibs {
    //Library for math libs cause I'm lazy
    public function getDistance(real cX, real cY, real tX, real tY) -> real {
        real dx = tX - cX;
        real dy = tY - cY;
        return SquareRoot(dx * dx + dy * dy);
    }
    
    public function getAngle(real cX, real cY, real tX, real tY) -> real {
        return bj_RADTODEG * Atan2(tY - cY, tX - cX);
    }
    
    public function offsetXTowardsPoint(real cX, real cY, real tX, real tY, real offset) -> real {
        real angle = getAngle(cX, cY, tX, tY);
        real x = cX + offset * Cos(angle * bj_DEGTORAD);
        return x;
    }
    
    public function offsetYTowardsPoint(real cX, real cY, real tX, real tY, real offset) -> real {
        real angle = getAngle(cX, cY, tX, tY);
        real y = cY + offset * Sin(angle * bj_DEGTORAD);
        return y;
    }
    
    public function offsetXTowardsAngle(real cX, real cY, real angle, real offset) -> real {
        real x = cX + offset * Cos(angle * bj_DEGTORAD);
        return x;
    }
    
    public function offsetYTowardsAngle(real cX, real cY, real angle, real offset) -> real {
        real y = cY + offset * Sin(angle * bj_DEGTORAD);
        return y;
    }
    
    public function getHalfwayX(real sX, real sY, real tX, real tY) -> real {
        real distance = getDistance(sX, sY, tX, tY);
        return offsetXTowardsPoint(sX, sY, tX, tY, distance / 2);
    }
    
    public function getHalfwayY(real sX, real sY, real tX, real tY) -> real {
        real distance = getDistance(sX, sY, tX, tY);
        return offsetYTowardsPoint(sX, sY, tX, tY, distance / 2);
    }
    
    public function modulo(real dividend, real divisor) -> real {
	real modulus = dividend - I2R(R2I(dividend / divisor)) * divisor;
	
	if(modulus < 0) modulus = modulus + divisor;
	
	return modulus;
    }
    
    //Goes in a circle near the X/Y to find the nearest pathable point, optional angle if greater than 0 will find it in an angle from the X/Y
    //public function findPathableTerrainPoint(real x, real y, real angle) {
	//pathingtype p = PATHING_TYPE_WALKABILITY;
	//integer i=0;
	//
    //}
    
	//X = Distance from start to current position, D = total distance from start to finish, h = max height
    public function GetParabolaZ(real x, real d, real h) -> real {
	return 4 * h * x * (d - x) / (d * d);
    }

}
//! endzinc
        