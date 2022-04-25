//! zinc
library MolteniousNukeBurn {
	public integer BurnID = 'A0NF';
	public hashtable MoNuBuHash = InitHashtable();

	public function MolteniousNukeBurn(unit caster, unit target) -> boolean {
		//By now we know that Moltenious has casted nuke on target that is Incinerated:
			real XLoc = GetUnitX(target);
			real YLoc = GetUnitY(target);
			integer NukeLevel = GetUnitAbilityLevel(caster, 'TMAQ');
			unit d = CreateUnit(GetOwningPlayer(caster), 'e01B', XLoc, YLoc, 0);
			UnitAddAbility(d, BurnID);
			SetUnitAbilityLevel(d, BurnID, NukeLevel);
			IssueTargetOrderById(d, 852609, target);
			RemoveUnit(d);
			d = null;
			
		return false;
	}
  
}
//! endzinc