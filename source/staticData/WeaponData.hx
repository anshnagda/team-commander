package staticData;

import battle.Point;
import haxe.ds.Map;

class WeaponData
{
	public static var weaponNames = [
		"sword", "shield", "bow", "spear", "handaxe", "swift greaves", "body armor", "gauntlet", "shortbow", "bladed cuffs", "compound bow", "greataxe",
		"harpoon", "plated boots", "reinforced armor", "silk steps", "spiked flail", "tower shield", "apollo's trail", "astral armor", "bloodthirster",
		"bone ward", "dragonslayer", "exalted staff", "mugen cap", "sword of ruin", "tempest bow", "gun"
	];

	public static var commonWeapons = [
		"sword",
		"shield",
		"bow",
		"spear",
		"handaxe",
		"swift greaves",
		"body armor",
		"gauntlet",
		"shortbow"
	];

	public static var uncommonWeapons = [
		"bladed cuffs",
		"compound bow",
		"greataxe",
		"harpoon",
		"plated boots",
		"reinforced armor",
		"silk steps",
		"spiked flail",
		"tower shield"
	];

	public static var rareWeapons = [
		"apollo's trail", "astral armor", "bloodthirster", "bone ward", "dragonslayer", "exalted staff", "mugen cap", "sword of ruin", "tempest bow", "gun"
	];

	public static var weaponIDs:Map<String, Int>;
	public static var weaponToRarity:Array<String>;

	public static function weaponIDToSpritePath(id:Int)
	{
		var root = "assets/images/weapons/";
		var path = root + weaponToRarity[id] + "/" + weaponNames[id] + "_sq.png";
		return path;
	}

	public static function weaponIDToStats(id:Int):Stats
	{
		switch weaponNames[id]
		{ // hp, atk, rng, mv, spd
			case "sword":
				return Stats.WeaponStat(30, 35, 0, 0, 0);
			case "shield":
				return Stats.WeaponStat(75, 0, 0, 0, 0);
			case "bow":
				return Stats.WeaponStat(-25, 55, 0, 0, 1);
			case "spear":
				return Stats.WeaponStat(0, 25, 1, 0, -1);
			case "handaxe":
				return Stats.WeaponStat(25, 0, 1, 0, -1);
			case "swift greaves":
				return Stats.WeaponStat(0, 0, 0, 1, 1);
			case "body armor":
				return Stats.WeaponStat(100, -20, 0, 0, -1);
			case "gauntlet":
				return Stats.WeaponStat(-30, 25, 0, 1, 1);
			case "shortbow":
				return Stats.WeaponStat(20, 40, -1, 0, 1);
			case "bladed cuffs":
				return Stats.WeaponStat(-20, 80, 0, 1, 2, 0, 25);
			case "compound bow":
				return Stats.WeaponStat(55, 75, -1, -1, 0, 0, 0, 0, 1);
			case "harpoon":
				return Stats.WeaponStat(25, 60, 1, 0, -1);
			case "plated boots":
				return Stats.WeaponStat(65, 0, 0, 1, 1, 0, 0, 8);
			case "reinforced armor":
				return Stats.WeaponStat(150, -30, 0, 0, -2, 0, 0, 20);
			case "silk steps":
				return Stats.WeaponStat(30, -30, 0, 2, 1, 15);
			case "spiked flail":
				return Stats.WeaponStat(70, 30, 1, 0, -1);
			case "tower shield":
				return Stats.WeaponStat(100, 0, 0, -1, -1, 10, 0, 10);
			case "greataxe":
				return Stats.WeaponStat(60, 65, 0, 0, 1);
			case "apollo's trail":
				return Stats.WeaponStat(75, 0, 0, 10, 10, 20);
			case "astral armor":
				return Stats.WeaponStat(300, -50, 0, 0, -3, 0, 0, 35);
			case "bloodthirster":
				return Stats.WeaponStat(150, 100, 0, 1, 1, 0, 50);
			case "bone ward":
				return Stats.WeaponStat(175, 35, -1, 0, -2);
			case "dragonslayer":
				return Stats.WeaponStat(100, 125, 2, 0, 0);
			case "exalted staff":
				return Stats.WeaponStat(75, 75, 0, 0, 2, 10, 0, 10);
			case "mugen cap":
				return Stats.WeaponStat(-50, 175, 2, 1, 0);
			case "sword of ruin":
				return Stats.WeaponStat(0, 150, 1, 0, -1);
			case "tempest bow":
				return Stats.WeaponStat(50, 100, 1, 1, 2, 25, 0, 0, 2);
			case "gun":
				return Stats.WeaponStat(0, 150, 5, 0, 3);
			case _:
				return Stats.WeaponStat(0, 0, 0, 0, 0);
		}
	}

	public static function weaponIdToAbility(id:Int):String
	{
		switch weaponNames[id]
		{
			case "bone ward":
				return "At the start of battle, grant all allies a 250HP shield";
			case "dragonslayer":
				return "Deal extra damage equal to 10% of the enemies current health";
			case "exalted staff":
				return "Each turn, heal all allies 15% of their max HP and grant them 1 move";
			case "mugen cap":
				return "Debuff enemies on attack causing them to explode when hit twice for 10% of their max health to nearby squares";
			case "sword of ruin":
				return "The first time you attack an enemy, prevent it from moving or attacking for 2 turns that battle";
			case _:
				return "";
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
