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
		"paragon", "artillery", "assassin", "archmage", "laureate", "exarch", "bloodmancer", "commander", "shogun", "valkyrie", "all-seeing eye", "slime",
		"champion"
	];
	public static var unitIDs:Map<String, Int>;

	// different subsets of units
	public static var rangedUnits = ["archer", "mage", "sniper", "warlock", "bard", "bloodmancer", "ranger"];
	public static var arrowUnits = ["archer", "sniper", "bard", "ranger"];
	public static var magicUnits = ["mage", "warlock", "bloodmancer"];
	public static var unitToRanged:Array<Bool>;

	public static var basicUnits = ["warrior", "archer", "thief", "mage"];
	public static var advancedUnits = [
		"knight", "sniper", "rogue", "warlock", "bard", "priestess", "slayer", "ranger", "samurai", "duelist"
	];
	public static var masterUnits = [
		"paragon", "artillery", "assassin", "archmage", "laureate", "exarch", "bloodmancer", "commander", "shogun", "valkyrie"
	];
	public static var elites = ["all-seeing eye", "slime"];
	public static var bosses = ["champion"];
	public static var unitToRarity:Array<String>;

	public static function unitIDToBattleSpritePath(id:Int)
	{
		if (unitToRarity[id] == "elites" || unitToRarity[id] == "bosses")
		{
			unitIDToSpritePath(id);
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
				return new Stats(175, 100, 1, 2, 1, 2);
			case "knight":
				return new Stats(425, 100, 1, 1, 1, 1);
			case "sniper":
				return new Stats(175, 150, 3, 4, 1, 1);
			case "rogue":
				return new Stats(225, 150, 1, 1, 2, 4);
			case "warlock":
				return new Stats(225, 150, 1, 2, 1, 2);
			case "bard":
				return new Stats(200, 75, 1, 2, 1, 2);
			case "priestess":
				return new Stats(300, 100, 1, 1, 1, 0);
			case "slayer":
				return new Stats(200, 100, 1, 2, 2, 2);
			case "ranger":
				return new Stats(200, 150, 2, 3, 1, 2);
			case "samurai":
				return new Stats(250, 75, 1, 1, 2, 3);
			case "duelist":
				return new Stats(225, 125, 1, 2, 1, 2);
			case "all-seeing eye":
				return new Stats(1050, 125, 0, 100, 0, 1);
			case "slime":
				return new Stats(40, 7, 1, 1, 1, 1);
			case "champion":
				return new Stats(3000, 100, 1, 1, 3, 1);
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
					"Take 10% of Knight's health (" + Math.round(0.1 * unit.currStats.hp) + ") less damage from hits"
				];
			case "sniper":
				return ["Every 3rd attack deals double damage"];
			case "rogue":
				return ["Teleports behind the weakest enemy at the start of battle"];
			case "warlock":
				return ["Also deals 50% damage to all enemies within 1 block of target enemy"];
			case "bard":
				return [
					"Allies within 3 columns centered on unit also get 75% of Bard's attack (" + Math.round(unit.currStats.atk * 0.75) + ")"
				];
			case "priestess":
				return [
					"Every 2 turns, heal priestess and allies within 1 block for 50 + 25% of priestess's health (" + Math.round(50 + unit.currStats.atk / 4) + ")"
				];
			case "slayer":
				return [
					"Gain 40 attack this battle when an enemy dies. Gain 75 health this battle when an ally dies"
				];
			case "ranger":
				return ["33% chance to doge an attack"];
			case "samurai":
				return ["Strikes twice when Samurai attacks"];
			case "duelist":
				return ["Heals for 50% of damage dealt"];
			case "all-seeing eye":
				return ["Attacks the first unit in all columns"];
			case "slime":
				return ["Absorbs the max HP and attack of slimes that have been killed"];
			case "champion":
				return [
					"Every turn, Champion's attack increases by 10, max health by 50, and heals 50. Every 3rd turn, Champion's move increases by 1"
				];
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
		if (unitToRarity[id1] != unitToRarity[id2])
		{
			return {unit: null, error: "Cannot merge " + unitToRarity[id1] + " unit with " + unitToRarity[id2] + " unit."};
		}
		if (unitToRarity[id1] == "master")
		{
			return {unit: null, error: "Master units cannot be merged further."};
		}

		if (unitToRarity[id1] == "advanced")
		{
			if (id1 != id2)
			{
				return {unit: null, error: "Can only merge identical advanced units."};
			}
			return {unit: getAdvancedMerge(id1), error: null};
		}

		return {unit: getBasicMerge(id1, id2), error: null};
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
	}
}
