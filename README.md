# Island-Defense
 Island Defense for Warcraft 3 Repository<br/>
 
[Zinc Documentation](https://htmlpreview.github.io/?https://raw.githubusercontent.com/jakrss/Island-Defense/master/zinc.html)
<br/>
[vJass Documentation](https://htmlpreview.github.io/?https://raw.githubusercontent.com/jakrss/Island-Defense/master/vjass.html)


## Object Editor
### Ability Naming Convention

[What class has the ability] [What entity has the ability] "Ability" [Ability Class] [(Ability Name)] [Extra Note]

For example:
[Item] [Helmet of Dominator] [Ability] [Passive] (Dominator Aura) (15%)
= Item Helmet of Dominator Ability Passive (Dominator Aura) (15%)

or
Titan Arborius Ability Info (Lush Meadow)

Entity Classes: Item / Titan / Builder / Unit / Global
Entities : Whatever is the root source / holder of the ability (e.g. "Faerie")
Ability Classes: Active / Passive / Dummy / Transformation / Menu / Hidden
Extra note: Something that separated and clarifies this object from a very similar one (e.g. a percentage change or "Visual Only"
