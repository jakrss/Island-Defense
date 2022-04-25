//! zinc

library ShowTagFromUnit {
    public function ShowTag(string s, real posX, real posY, real height){
        texttag t = CreateTextTag();
        real x = TextTagSpeed2Velocity(50.) * Cos(90 * bj_DEGTORAD);
        real y = TextTagSpeed2Velocity(50.) * Sin(90 * bj_DEGTORAD);

        SetTextTagPos(t, posX, posY, height);
        SetTextTagText(t, s, TextTagSize2Height(10));
        SetTextTagColor(t, 255, 255, 255, 255);

        //SetTextTagVelocity(t, 0.0, 10 * 0.071 / 128);
        SetTextTagVelocity(t, x, y);
        SetTextTagFadepoint(t, 1.5);
        SetTextTagLifespan(t, 2);
        SetTextTagPermanent(t, false);
        
        SetTextTagVisibility(t, true);
        t = null;
    }
    
    public function ShowTagFromUnit(string s, unit a){
        texttag t = CreateTextTagUnitBJ(s, a, 0, 10, 0, 0, 100, 0);
        real x = TextTagSpeed2Velocity(50.) * Cos(90 * bj_DEGTORAD);
        real y = TextTagSpeed2Velocity(50.) * Sin(90 * bj_DEGTORAD);

        SetTextTagVelocity(t, x, y);
        SetTextTagFadepoint(t, 1.5);
        SetTextTagLifespan(t, 2);
        SetTextTagPermanent(t, false);
        if (IsUnitVisible(a, GetLocalPlayer())){
            SetTextTagVisibility(t, true);
        }
        else {
            SetTextTagVisibility(t, false);
        }
        t = null;
    }
    
    public function ShowTagFromUnitForAll(string s, unit a){
        texttag t = CreateTextTagUnitBJ(s, a, 0, 10, 0, 0, 100, 0);
        real x = TextTagSpeed2Velocity(50.) * Cos(90 * bj_DEGTORAD);
        real y = TextTagSpeed2Velocity(50.) * Sin(90 * bj_DEGTORAD);

        SetTextTagVelocity(t, x, y);
        SetTextTagFadepoint(t, 1.5);
        SetTextTagLifespan(t, 2);
        SetTextTagPermanent(t, false);
        SetTextTagVisibility(t, true);
        t = null;
    }
    
    public function ShowTagFromUnitWithColor(string s, unit a, integer r, integer g, integer b){
        texttag t = CreateTextTagUnitBJ(s, a, 0, 10, 0, 0, 100, 0);
        real x = TextTagSpeed2Velocity(50.) * Cos(90 * bj_DEGTORAD);
        real y = TextTagSpeed2Velocity(50.) * Sin(90 * bj_DEGTORAD);

        SetTextTagVelocity(t, x, y);
        SetTextTagFadepoint(t, 1.5);
        SetTextTagLifespan(t, 2);
        SetTextTagPermanent(t, false);
        SetTextTagColor(t, r, g, b, 255);
        if (IsUnitVisible(a, GetLocalPlayer())){
            SetTextTagVisibility(t, true);
        }
        else {
            SetTextTagVisibility(t, false);
        }
        t = null;
    }
}

//! endzinc