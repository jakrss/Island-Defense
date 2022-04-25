//! zinc
library Insight requires BUM {
    //Library for Insight - Heals for % of Max Mana at no additional cost
    //Effect to play on mana refund
    private constant string EFFECT = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl";
    
    //Unit u (unit getting the bonus heal)
    //Real mp (manaPercent in the form of a decimal or percent)
    public function insightHeal(unit u, real mp, real flat) -> real {
        real extraHeal;
        real life;
        if(mp > 1) mp = mp / 100;
        extraHeal = getMaxMana(u) * mp;
		//Now check that the unit has sufficient mana:
		if(getMana(u) >= extraHeal/2) {
			addHealth(u, (extraHeal + flat));
			addMana(u, -extraHeal/2);
		}
        u = null;
        return extraHeal;
    }
    
}
//! endzinc