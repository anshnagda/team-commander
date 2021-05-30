package staticData;

import entities.Unit;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.util.FlxColor;
import haxe.ds.Map;
import openfl.display.BitmapData;

class UnitData
{
	public static function enemyOutlineEffect(pixels:BitmapData)
	{
		var enemyOutlineEffectObj = new FlxOutlineEffect(FlxOutlineMode.PIXEL_BY_PIXEL, FlxColor.RED, 1);
		return enemyOutlineEffectObj.apply(pixels);
	}

	public static function allyOutlineEffect(pixels:BitmapData)
	{
		var allyOutlineEffectObj = new FlxOutlineEffect(FlxOutlineMode.PIXEL_BY_PIXEL, FlxColor.BLUE, 1);
		return allyOutlineEffectObj.apply(pixels);
	}

	public static var unitNames = [
		"warrior", "archer", "thief", "mage", "knight", "sniper", "rogue", "warlock", "bard", "priestess", "slayer", "ranger", "samurai", "duelist",
		"paragon", "artillery", "assassin", "archmage", "laureate", "exarch", "bloodmancer", "enforcer", "shogun", "valkyrie", "all-seeing eye", "slime",
		"champion", "zombie", "pawn", "king", "queen", "thunder spirit", "mothership", "alien", "ashen lord", "fire elemental", "joker", "overlord",
		"withering soul", "the exalted one"
	];
	public static var unitIDs:Map<String, Int>;

	// different subsets of units
	public static var rangedUnits = [
		"archer", "mage", "sniper", "warlock", "bard", "bloodmancer", "ranger", "artillery", "laureate", "archmage"
	];
	public static var arrowUnits = ["archer", "sniper", "bard", "ranger", "artillery", "laureate"];
	public static var magicUnits = ["mage", "warlock", "bloodmancer", "archmage"];
	public static var unitToRanged:Array<Bool>;

	public static var basicUnits = ["warrior", "archer", "thief", "mage"];
	public static var advancedUnits = [
		"knight", "sniper", "rogue", "warlock", "bard", "priestess", "slayer", "ranger", "samurai", "duelist"
	];
	public static var masterUnits = [
		"paragon", "artillery", "assassin", "archmage", "laureate", "exarch", "bloodmancer", "enforcer", "shogun", "valkyrie"
	];
	public static var elites = ["all-seeing eye", "slime", "mothership", "alien", "thunder spirit", "joker"];
	public static var bosses = [
		"champion",
		"pawn",
		"king",
		"queen",
		"ashen lord",
		"fire elemental",
		"overlord",
		"withering soul",
		"the exalted one"
	];
	public static var summons = ["zombie"];
	public static var unitToRarity:Array<String>;

	public static function unitIDToBattleSpritePath(id:Int)
	{
		if (unitToRarity[id] == "elite" || unitToRarity[id] == "boss" || unitToRarity[id] == "summon")
		{
			return unitIDToSpritePath(id);
		}
		var root = "assets/images/units/";
		var rarity_path = root + unitToRarity[id] + "/battle/";
		var unit_path = rarity_path + unitNames[id] + "_sq.png";
		return unit_path;
	}

	public static function unitIDToSpritePath(id:Int)
	{
		var root = "assets/images/units/";
		var rarity_path = root + unitToRarity[id] + "/";
		var unit_path = rarity_path + unitNames[id] + "_sq.png";
		return unit_path;
	}

	public static function unitIDToStats(id:Int):Stats
	{
		switch unitNames[id]
		{
			case "warrior":
				return new Stats(300, 75, 1, 1, 1, 1);
			case "archer":
				return new Stats(150, 125, 2, 3, 1, 1);
			case "thief":
				return new Stats(150, 125, 1, 1, 2, 3);
			case "mage":
				return new Stats(175, 110, 1, 2, 1, 2);
			case "knight":
				return new Stats(425, 100, 1, 1, 1, 1, 0, 0, 0, 0, 8);
			case "sniper":
				return new Stats(175, 150, 3, 4, 1, 1);
			case "rogue":
				return new Stats(225, 150, 1, 1, 2, 4);
			case "warlock":
				return new Stats(225, 150, 1, 2, 1, 2);
			case "bard":
				return new Stats(200, 100, 1, 2, 1, 2);
			case "priestess":
				return new Stats(300, 100, 1, 2, 1, 0);
			case "slayer":
				return new Stats(275, 100, 1, 2, 2, 2);
			case "ranger":
				return new Stats(200, 150, 2, 3, 2, 3, 33);
			case "samurai":
				return new Stats(250, 75, 1, 1, 2, 3);
			case "duelist":
				return new Stats(225, 125, 1, 2, 1, 2, 0, 50);
			case "paragon":
				return new Stats(550, 125, 1, 1, 1, 2, 0, 0, 0, 0, 12);
			case "artillery":
				return new Stats(275, 225, 2, 4, 1, 2);
			case "assassin":
				return new Stats(350, 275, 1, 1, 3, 5);
			case "archmage":
				return new Stats(300, 175, 1, 3, 1, 3);
			case "laureate":
				return new Stats(275, 150, 1, 2, 2, 4);
			case "exarch":
				return new Stats(450, 150, 1, 2, 2, 2);
			case "bloodmancer":
				return new Stats(350, 150, 1, 2, 2, 3);
			case "enforcer":
				return new Stats(300, 200, 2, 3, 2, 4, 50, 0, 0, 2);
			case "shogun":
				return new Stats(300, 100, 1, 1, 3, 3);
			case "valkyrie":
				return new Stats(350, 175, 1, 1, 2, 4, 0, 75);
			case "all-seeing eye":
				return new Stats(1000, 120, 0, 100, 0, 1);
			case "slime":
				return new Stats(32, 6, 1, 1, 1, 1);
			case "champion":
				return new Stats(2000, 100, 1, 1, 3, 1);
			case "mothership":
				return new Stats(2500, 200, 1, 5, 1, 1);
			case "alien":
				return new Stats(200, 125, 1, 3, 1, 6);
			case "thunder spirit":
				return new Stats(5000, 300, 0, 99, 0, 99, 0, 0, 0, 2);
			case "pawn":
				return new Stats(150, 0, 0, 0, 0, 1);
			case "king":
				return new Stats(3500, 150, 1, 1, 2, 8);
			case "queen":
				return new Stats(500, 225, 1, 1, 20, 10);
			case "ashen lord":
				return new Stats(5000, 250, 1, 99, 0, 1, 50);
			case "fire elemental":
				return new Stats(750, 50, 1, 5, 0, 0);
			case "joker":
				return new Stats(2000, 250, 1, 2, 3, 3);
			case "overlord":
				return new Stats(4000, 250, 0, 99, 0, 5);
			case "withering soul":
				return new Stats(1000, 150, 1, 1, 10, 10);
			case "the exalted one":
				return new Stats(7500, 350, 1, 4, 3, 25);
			case _:
				return new Stats(1, 1, 1, 1, 1, 1);
		}
	}

	public static function unitIdToAbility(id:Int, unit:Unit):Array<String>
	{
		switch unitNames[id]
		{
			case "knight":
				return [
					"Take 8% of my health (" + Math.round(0.08 * unit.currStats.hp) + ") less damage from hits"
				];
			case "sniper":
				return ["Every 3rd attack deals 1.75x damage"];
			case "rogue":
				return ["Teleports behind the weakest enemy at the start of battle"];
			case "warlock":
				return ["Also deals 50% damage to all enemies within 1 block of target enemy"];
			case "bard":
				return [
					"Allies within 3 columns centered on unit also get 50% of my attack (" + Math.round(unit.currStats.atk * 0.50) + ")"
				];
			case "priestess":
				return [
					"Every 2 turns, heal me and allies within 2 squares for 50 + 25% of my health (" + Math.round(50 + unit.currStats.atk / 4) + ")"
				];
			case "slayer":
				return [
					"Gain 40 attack this battle when an enemy dies. Gain 75 health this battle when an ally dies"
				];
			case "ranger":
				return ["33% chance to dodge an attack. Heal 75 HP on dodge"];
			case "samurai":
				return ["I Strike twice when I attack"];
			case "duelist":
				return ["Heals for 50% of damage dealt"];
			case "paragon":
				return [
					"Take 12% of my health (" + Math.round(0.12 * unit.currStats.hp) + ") less damage from hits",
					"Redirects 50% of damage from adjacent allies to me"
				];
			case "artillery":
				return [
					"Every third attack deals double damage",
					"Also damages a random enemy for bonus damage based off of attack"
				];
			case "assassin":
				return [
					"Teleports behind the weakest enemy unit",
					"When assassin kills an enemy, assassin can take another action"
				];
			case "archmage":
				return [
					"Deals damage to all enemies within a 3x3 block range of the target enemy",
					"Reduces the attack of enemies hit by 25%, and their move by 1"
				];
			case "laureate":
				return [
					"Allies within 3 columns centered on unit get 75% of Laureate's attack (" + Math.round(unit.currStats.atk * 0.75) +
					") 1 extra range, and 1 extra move"
				];
			case "exarch":
				return ["Every 2 turns, heal Exarch and all allies within 3 blocks 30% of Exarch's health ("
					+ Math.round(unit.currStats.hp * 0.30)
					+ ") and grants a shield equal to 15% of Exarch's health ("
					+ Math.round(unit.currStats.hp * 0.15)
					+ ")"];
			case "bloodmancer":
				return ["When an ally or an enemy dies, gain 40 attack and 50 hp this battle",
					"When an ally dies, summon a zombie with 25% of my attack ("
					+ Math.round(unit.currStats.atk * 0.25)
					+ ") and health ("
					+ Math.round(unit.currStats.hp * 0.25)
					+ ")"];
			case "enforcer":
				return [
					"50% chance to dodge an attack. Heal 100 hp on dodge",
					"Knock back enemies 2 spaces on attack"
				];
			case "shogun":
				return [
					"I Strike twice when I attack",
					"At the start of battle, create an exact clone of myself on a nearby square. The clone has half my attack and hp"
				];
			case "valkyrie":
				return [
					"Heals for 75% of damage dealt",
					"The first time I would die this battle, I cannot take damage for the next 2 turns"
				];
			case "all-seeing eye":
				return ["Attacks the first unit in all columns"];
			case "slime":
				return ["Absorbs the max HP and attack of slimes that have been killed"];
			case "champion":
				return [
					"Every turn, Champion's attack increases by 30, max health by 50, and heals 50. Every 3rd turn, Champion's move increases by 1"
				];
			case "mothership":
				return ["Every 2 turns, summons one alien around Mothership"];
			case "pawn":
				return [
					"Only moves forward. Once Pawn reaches the last row, transform it into a Queen with 500 hp and 225 attack"
				];
			case "king":
				return ["King takes damage for all Pawns within 2 spaces of it"];
			case "thunder spirit":
				return [
					"On odd turns push back all units within 1 blocks and deal " + Math.round(unit.currStats.atk * 0.5) + " damage to them",
					"On even turns deal " + Math.round(unit.currStats.atk * 1.5) + " damage to the furthest unit"
				];
			case "ashen lord":
				return [
					"All your units get marked. Every turn, the mark explodes, dealing 25% of the unit's health to nearby spaces",
					"Gain 50% dodge if a fire elemental is alive"
				];
			case "fire elemental":
				return ["When Fire Elemental dies, prevent the mark from exploding for 1 turn"];
			case "joker":
				return [
					"Every turn I teleport to a random space on the board, and gain a random bonus stat that turn"
				];
			case "overlord":
				return [
					"On odd turns summon 2 withering souls. On even turns attack the first unit in all columns",
					"Something feels off..."
				];
			case "withering soul":
				return [
					"Debuff enemies on hit, reducing their attack by 25%, range by 1, and move by 1 for 1 turn"
				];
			case "the exalted one":
				return ["At the end of turn, spawn a copy of myself with half the health"];
			case _:
				return [];
		}
	}

	static function getAdvancedMerge(id1:Int)
	{
		return id1 + 10;
	}

	static function pairEq(id1:Int, id2:Int, n1:String, n2:String)
	{
		var name1 = unitNames[id1];
		var name2 = unitNames[id2];
		if (name1 == n1 && name2 == n2)
		{
			return true;
		}
		if (name1 == n2 && name2 == n1)
		{
			return true;
		}

		return false;
	}

	static function getBasicMerge(id1:Int, id2:Int)
	{
		if (id1 == id2)
		{
			return id1 + 4;
		}

		if (pairEq(id1, id2, "archer", "mage"))
		{
			return unitIDs.get("bard");
		}

		if (pairEq(id1, id2, "warrior", "mage"))
		{
			return unitIDs.get("priestess");
		}

		if (pairEq(id1, id2, "thief", "mage"))
		{
			return unitIDs.get("slayer");
		}

		if (pairEq(id1, id2, "archer", "thief"))
		{
			return unitIDs.get("ranger");
		}

		if (pairEq(id1, id2, "warrior", "thief"))
		{
			return unitIDs.get("samurai");
		}

		if (pairEq(id1, id2, "warrior", "archer"))
		{
			return unitIDs.get("duelist");
		}

		return 0;
	}

	public static function mergeResult(id1:Int, id2:Int)
	{
		if (unitToRarity[id1] != "basic" || unitToRarity[id2] != "basic")
		{
			return {unit: null, error: "Both units need to be basic."};
		}

		return {unit: getBasicMerge(id1, id2), error: null};
	}

	public static function mergeResultAdv(id1:Int, id2:Int, id3:Int)
	{
		if (unitToRarity[id1] != "advanced" || unitToRarity[id2] != "advanced" || unitToRarity[id3] != "advanced")
		{
			return {unit: null, error: "All units need to be advanced."};
		}
		if (id1 != id2 || id2 != id3)
		{
			return {unit: null, error: "Units need to be identical."};
		}
		return {unit: getAdvancedMerge(id1), error: null};
	}

	public static function init()
	{
		unitIDs = new Map<String, Int>();
		for (i in 0...unitNames.length)
		{
			unitIDs.set(unitNames[i], i);
		}

		unitToRanged = new Array<Bool>();
		for (i in 0...unitNames.length)
		{
			unitToRanged.push(false);
		}

		for (unitName in rangedUnits)
		{
			unitToRanged[unitIDs.get(unitName)] = true;
		}

		unitToRarity = new Array<String>();
		for (i in 0...unitNames.length)
		{
			unitToRarity.push("basic");
		}
		for (unitName in advancedUnits)
		{
			unitToRarity[unitIDs.get(unitName)] = "advanced";
		}

		for (unitName in masterUnits)
		{
			unitToRarity[unitIDs.get(unitName)] = "master";
		}

		for (unitName in elites)
		{
			unitToRarity[unitIDs.get(unitName)] = "elite";
		}

		for (unitName in bosses)
		{
			unitToRarity[unitIDs.get(unitName)] = "boss";
		}

		for (unitName in summons)
		{
			unitToRarity[unitIDs.get(unitName)] = "summon";
		}
	}
}
