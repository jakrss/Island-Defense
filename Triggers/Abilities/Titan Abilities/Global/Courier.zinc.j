//! zinc

library TitanCourier requires GT, xemissile {
    type HitFunction extends function(TitanCourier);
    
    public struct TitanCourier extends xemissile {
        public item items[6];
        private HitFunction hitCallback = 0;
        private integer extraData = 0;
        
        public static method create(real x, real y, real z, real tx, real ty, real tz) -> thistype {
            thistype this = thistype.allocate(x,y,z,tx,ty,tz);
            integer i = 0;
            for (0 <= i < 6) {
                this.items[i] = null;
            }
            this.hitCallback = 0;
            this.extraData = 0;
            this.fxpath = "units\\nightelf\\Chimaera\\Chimaera.mdl";
            this.scale = 0.4;
            
            return this;
        }
        
        public method setOnHit(integer d, HitFunction callback) {
            this.extraData = d;
            this.hitCallback = callback;
        }
        
        public method data() -> integer {
            return this.extraData;
        }
        
        public method addItem(item it) {
            integer i = 0;
            for (0 <= i < 6) {
                if (this.items[i] == null) {
                    SetItemPosition(it, 0, 0);
                    SetItemVisible(it, false);
                    this.items[i] = it;
                    break;
                }
            }
        }
        
        public method onHit() {
            if (this.hitCallback != 0) {
                this.hitCallback.execute(this);
                this.hitCallback = 0;
            }
            this.terminate(); // Destroy
        }
        
        private method onDestroy() {
            integer i = 0;
            item it = null;
            for (0 <= i < 6) {
                it = this.items[i];
                if (it != null) {
                    SetItemVisible(it, true);
                    SetItemPosition(it, this.x, this.y);
                    if (this.targetUnit != null) {
                        UnitAddItem(this.targetUnit, it);
                    }
                }
            }
            it = null;
        }
        
        public static method onInit(){
            trigger t = CreateTrigger();
            GT_RegisterStartsEffectEvent(t, 'A02H');
            TriggerAddCondition(t, Condition(function() -> boolean {
                unit u = GetTriggerUnit();
                real x = GetSpellTargetX();
                real y = GetSpellTargetY();
                unit target = GetSpellTargetUnit();
                TitanCourier courier = 0;
                item it = null;
                integer i = 0;
                
                courier = TitanCourier.create(GetUnitX(u), GetUnitY(u), 120.0, x, y, 120.0);
                for (0 <= i < 6) {
                    it = UnitItemInSlot(u, i);
                    if (it != null) {
                        courier.addItem(it);
                    }
                }
                
                if (target != null) {
                    courier.targetUnit = target;
                    courier.zoffset = GetUnitFlyHeight(target) + 120.0;
                }
                
                // Speed and Arc
                courier.launch(522.0, 0.0);
                
                u = null;
                it = null;
                return false;
            }));
            t = null;
        }
    }
}

//! endzinc