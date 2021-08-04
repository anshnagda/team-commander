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
				return Stats.WeaponStat(50, 70, -1, -1, 0, 0, 0, 0, 1);
			case "harpoon":
				return Stats.WeaponStat(20, 55, 1, 0, -1);
			case "plated boots":
				return Stats.WeaponStat(60, 0, 0, 1, 1, 0, 0, 15);
			case "reinforced armor":
				return Stats.WeaponStat(135, -30, 0, 0, -2, 0, 0, 25);
			case "silk steps":
				return Stats.WeaponStat(30, -30, 0, 2, 1, 15);
			case "spiked flail":
				return Stats.WeaponStat(65, 25, 1, 0, -1);
			case "tower shield":
				return Stats.WeaponStat(90, 0, 0, -1, -1, 7, 0, 7);
			case "greataxe":
				return Stats.WeaponStat(55, 60, 0, 0, 1);
			case "apollo's trail":
				return Stats.WeaponStat(80, 0, 0, 10, 10, 35);
			case "astral armor":
				return Stats.WeaponStat(250, -50, 0, 0, -3, 0, 0, 50);
			case "bloodthirster":
				return Stats.WeaponStat(125, 90, 0, 1, 1, 0, 50);
			case "bone ward":
				return Stats.WeaponStat(150, 35, 0, 0, -2);
			case "dragonslayer":
				return Stats.WeaponStat(75, 100, 2, 0, 0, 0, 15);
			case "exalted staff":
				return Stats.WeaponStat(75, 75, 0, 0, 2, 10, 0, 10);
			case "mugen cap":
				return Stats.WeaponStat(-50, 125, 2, 1, 0);
			case "sword of ruin":
				return Stats.WeaponStat(50, 75, 1, 0, -1);
			case "tempest bow":
				return Stats.WeaponStat(0, 75, 1, 1, 2, 50, 0, 0, 2);
			case "gun":
				return Stats.WeaponStat(0, 130, 4, 0, 2);
			case _:
				return Stats.WeaponStat(0, 0, 0, 0, 0);
		}
	}

	public static function weaponIdToAbility(id:Int):String
	{
		switch weaponNames[id]
		{
			case "bone ward":
				return "At the start of battle, grant all allies a 200HP shield";
			case "dragonslayer":
				return "Deal extra damage equal to 10% of the enemies current health";
			case "exalted staff":
				return "Each turn, heal all allies 15% of their max HP and grant them 1 move";
			case "mugen cap":
				return "Debuff enemies on attack causing them to explode when hit twice for 13% of their max health to nearby squares";
			case "sword of ruin":
				return "The first time you attack an enemy, stun it for 1 turn that battle";
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
