//! zinc

library TagDefenderDeath requires IslandDefenseSystem, RevealMapForPlayer, GT, Damage {
    public module TagDefenderDeath {
		public method moveAllTitanUnits() {
			UnitList list = UnitManager.getTitans();
			Unit u = 0;
			integer i = 0;
			real x = GetUnitX(UnitManager.TITAN_SPELL_WELL);
			real y = GetUnitY(UnitManager.TITAN_SPELL_WELL);
			
            list.copy(UnitManager.getMinions());
			for (0 <= i < list.size()) {
				u = list[i];
				// Apply Grace
				MinionUnit.grace(u);
				UnitResetCooldown(u.unit());
				SetUnitState(u.unit(), UNIT_STATE_LIFE, GetUnitState(u.unit(), UNIT_STATE_MAX_LIFE));
				SetUnitState(u.unit(), UNIT_STATE_MANA, GetUnitState(u.unit(), UNIT_STATE_MAX_MANA));
				SetUnitPosition(u.unit(), x, y);
			}
		}
		
		public method onDefenderDeath(DefenderUnit u, unit killer) {
			PlayerData p = u.owner();
            PlayerData k = PlayerData.get(GetOwningPlayer(killer));
            real x=GetUnitX(u.unit());
            real y=GetUnitY(u.unit());
            real q=GetUnitX(killer);
            real r=GetUnitY(killer);
			integer temp = 0;
			
			// Stop unit from dying!
			Damage_BlockAll();
			// Re-add
			UnitManager.defenders.append(u);
            
            // First up, ping the minimap to show everyone where the defender died.
            if (PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_DEFENDER) ||
                PlayerData.get(GetLocalPlayer()).isClass(PlayerData.CLASS_OBSERVER)){
                PingMinimapEx(x, y, 10.00, 254, 0, 0, true);
            }
            else {
                PingMinimapEx(x, y, 10.00, 0, 255, 0, true);
            }
            
            if (k == 0 || 
                (k.class() != PlayerData.CLASS_TITAN &&
                k.class() != PlayerData.CLASS_MINION)){
                // Something went wrong, they were killed by something other than a titan
                // We're going to have problems spawning the minion... this may end with hilarious results!
                // Let's assume the killer is the first titan we find.
                Game.say("UnitManager.DefenderUnit.onDeath could not complete properly. The killing player was not of the right class.\n" +
                             "Please report this bug with the replay and time of occurance to one of the websites listed in the top-right corner.");
                k = PlayerData.findTitanPlayer();
                q = GetUnitX(k.unit().unit());
                r = GetUnitY(k.unit().unit());
                if (k == 0){
                    // Unable to find a titan, what the fuck happened?!
                    Game.say("No Titan's found... something has gone terribly wrong.");
                    Game.say("Now attempting to resolve the situation by finding another minion to copy...");
                    k = PlayerData.findMinionPlayer();
                    q = GetUnitX(k.unit().unit());
                    r = GetUnitY(k.unit().unit());
                    if (k == 0){
                        Game.say("Nope, no Titans or Minions... ignoring the death.");
                        p.setClass(PlayerData.CLASS_OBSERVER);
                        Game.checkVictory();
                        return;
                    }
                }
            }

            // Announce it
            Game.say(p.nameColored() + "|cff00bfff was killed by |r" + k.nameColored());
            PlaySoundBJ(gg_snd_Titan_BuilderKill);
			
			if (p.isLeaving()){
                p.left();
            }
			k.setClassEx(PlayerData.CLASS_DEFENDER, false);
            if (p.isLeaving() || p.hasLeft()){
				p.setClassEx(PlayerData.CLASS_NONE, true);
				return;
            }
			
			p.setClassEx(PlayerData.CLASS_TITAN, true);
			
			// First, move the Titan and all of his minions to the Mound!
			this.moveAllTitanUnits();
			UnitManager.swapPlayerUnits(p, k);
			//Upgrades.swapPlayerUpgradeTables(p.player(), k.player());
            
			temp = p.gold();
			p.setGold(k.gold());
			k.setGold(temp);
			temp = p.wood();
			p.setWood(k.wood());
			k.setWood(temp);
			temp = p.race();
			p.setRace(k.race());
			k.setRace(temp);
			temp = p.unit();
			p.setUnit(k.unit());
			k.setUnit(temp);
			
			// Heal
			UnitResetCooldown(u.unit());
			SetUnitState(u.unit(), UNIT_STATE_LIFE, GetUnitState(u.unit(), UNIT_STATE_MAX_LIFE));
			SetUnitState(u.unit(), UNIT_STATE_MANA, GetUnitState(u.unit(), UNIT_STATE_MAX_MANA));
			
			if (GetLocalPlayer() == k.player()) {
				ClearSelection();
				PanCameraToTimed(x, y, 0.0);
				SelectUnit(u.unit(), true);
			}
			
			if (GetLocalPlayer() == p.player()) {
				ClearSelection();
				PanCameraToTimed(GetUnitX(UnitManager.TITAN_SPELL_WELL), GetUnitY(UnitManager.TITAN_SPELL_WELL), 0.0);
				SelectUnit(UnitManager.TITAN_SPELL_WELL, true);
			}
            
            // Reveal the map after a very short delay, in order to allow currently running nukes
			// to choose new targets
			GameTimer.newNamed(function(GameTimer t){
				PlayerData k = t.data();
				RevealMapForPlayer(k.player());
			}, "DefenderDeathMapReveal").start(0.2).setData(k); 
			
			GameTimer.newNamed(function(GameTimer t){
				PlayerData p = t.data();
				RevealMapForPlayer(p.player());
			}, "DefenderDeathMapReveal").start(0.2).setData(p); 
		}
    }
}

//! endzinc