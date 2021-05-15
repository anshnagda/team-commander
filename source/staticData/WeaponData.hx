package staticData;

import battle.Point;
import haxe.ds.Map;

class WeaponData
{
	public static var weaponNames = [
		"sword", "shield", "bow", "spear", "handaxe", "swift greaves", "body armor", "gauntlet", "shortbow", "gun"
	];

	public static var commonWeapons = ["sword", "shield", "bow", "spear", "handaxe", "swift greaves", "body armor", "gauntlet", "shortbow"];

	public static var uncommonWeapons = [];

	public static var rareWeapons = ["gun"];

	public static var weaponIDs:Map<String, Int>;
	public static var weaponToRarity:Array<String>;

	public static function weaponIDToSpritePath(id:Int)
	{
		var root = "assets/images/weapons/";
		var path = root + weaponToRarity[id] + "/" + weaponNames[id] + "_sq.png";
		trace(path);
		return path;
	}

	public static function weaponIDToStats(id:Int):Stats
	{
		switch weaponNames[id]
		{ // hp, atk, rng, mv, spd
			case "sword":
				return Stats.WeaponStat(30, 30, 0, 0, 0);
			case "shield":
				return Stats.WeaponStat(75, 0, 0, 0, 0);
			case "bow":
				return Stats.WeaponStat(-30, 50, 0, 0, 0);
			case "spear":
				return Stats.WeaponStat(0, -40, 1, 0, 0);
			case "handaxe":
				return Stats.WeaponStat(-40, 0, 1, 0, 0);
			case "swift greaves":
				return Stats.WeaponStat(0, 0, 0, 1, 0);
			case "body armor":
				return Stats.WeaponStat(100, -15, 0, 0, 0);
			case "gauntlet":
				return Stats.WeaponStat(-20, 20, 0, 1, 0);
			case "shortbow":
				return Stats.WeaponStat(20, 20, -1, 0, 0);
			case "gun":
				return Stats.WeaponStat(0, 100, 2, 0, 0);
			case _:
				return Stats.WeaponStat(0, 0, 0, 0, 0);
		}
	}

	public static function init()
	{
		weaponIDs = new Map<String, Int>();
		for (i in 0...weaponNames.length)
		{
			weaponIDs.set(weaponNames[i], i);
		}

		weaponToRarity = new Array<String>();
		for (i in 0...weaponNames.length)
		{
			weaponToRarity.push("common");
		}
		for (weaponName in uncommonWeapons)
		{
			weaponToRarity[weaponIDs.get(weaponName)] = "uncommon";
		}
		for (weaponName in rareWeapons)
		{
			weaponToRarity[weaponIDs.get(weaponName)] = "rare";
		}
	}
}
