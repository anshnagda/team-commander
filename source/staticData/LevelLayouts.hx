package staticData;

import battle.Point;
import entities.Unit;
import entities.Weapon;
import flixel.math.FlxRandom;

@:publicFields
class LevelLayouts
{
	static function createEnemySetup(stage:Int, level:Int, sessionId:String)
	{
		var enemy_list = [];
		var enemies_list:Array<Array<
			{
				x:Int,
				y:Int,
				id:Int,
				weapon1ID:Int,
				weapon2ID:Int
			}>> = [];

		switch stage
		{
			case 1:
				switch level
				{
					case 1:
						enemy_list = [enemyCreate(3, 2, "warrior")];
					case 2:
						enemy_list = [enemyCreate(3, 3, "warrior"), enemyCreate(4, 3, "warrior")];
					case 3:
						enemy_list = [
							enemyCreate(1, 3, "warrior"),
							enemyCreate(3, 2, "warrior"),
							enemyCreate(4, 2, "warrior")
						];
					case 4:
						enemy_list = [enemyCreate(3, 2, "all-seeing eye")];
					case _:
						enemy_list = [];
				}
			case 2:
				switch level
				{
					case 1:
						enemies_list.push([enemyCreate(5, 3, "slayer"), enemyCreate(5, 2, "bard")]);
						enemies_list.push([enemyCreate(3, 3, "warlock"), enemyCreate(3, 1, "bard")]);
						enemies_list.push([enemyCreate(0, 3, "samurai"), enemyCreate(0, 2, "bard")]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreate(3, 2, "mage"),
							enemyCreateWithWeapon(6, 3, "thief", "sword", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreateWithWeapon(0, 1, "archer", "bow", null),
							enemyCreate(7, 3, "warrior")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "mage", "shield", null),
							enemyCreateWithWeapon(0, 1, "mage", "bow", null),
							enemyCreate(1, 3, "thief"),
						]);
					case 3:
						enemy_list = [
							enemyCreate(1, 1, "slime"),
							enemyCreate(1, 2, "slime"),
							enemyCreate(2, 2, "slime"),
							enemyCreate(5, 2, "slime"),
							enemyCreate(6, 1, "slime"),
							enemyCreate(6, 2, "slime")
						];
					case 4:
						enemies_list.push([
							enemyCreate(2, 3, "thief"),
							enemyCreateWithWeapon(3, 3, "knight", "shield", null),
							enemyCreate(3, 1, "rogue")
						]);
						enemies_list.push([
							enemyCreate(2, 2, "thief"),
							enemyCreateWithWeapon(3, 1, "slayer", "bow", null),
							enemyCreate(2, 3, "rogue")
						]);
						enemies_list.push([
							enemyCreate(1, 1, "thief"),
							enemyCreateWithWeapon(6, 3, "ranger", "sword", null),
							enemyCreate(1, 3, "rogue")
						]);
					case 5:
						enemy_list = [enemyCreate(3, 3, "champion")];
					case _:
						enemy_list = [];
				}
			case 3:
				switch level
				{
					case 1:
						enemies_list.push([
							enemyCreate(1, 1, "rogue"),
							enemyCreateWithWeapon(2, 0, "slayer", "spear", null),
							enemyCreateWithWeapon(3, 0, "slayer", "handaxe", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(6, 3, "duelist", "greataxe", null),
							enemyCreateWithWeapon(1, 3, "samurai", "bladed cuffs", null),
							enemyCreateWithWeapon(0, 0, "rogue", "silk steps", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(2, 2, "slayer", "spiked flail", null),
							enemyCreateWithWeapon(7, 3, "ranger", "plated boots", null),
							enemyCreateWithWeapon(1, 3, "priestess", "reinforced armor", null)
						]);

					case 2:
						enemies_list.push([
							enemyCreate(3, 2, "ranger"),
							enemyCreateWithWeapon(2, 2, "bard", "compound bow", null),
							enemyCreateWithWeapon(3, 3, "knight", "tower shield", null),
							enemyCreate(2, 3, "mage")
						]);
						enemies_list.push([
							enemyCreate(0, 2, "bard"),
							enemyCreateWithWeapon(1, 2, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(1, 3, "knight", "tower shield", null),
							enemyCreate(0, 3, "sniper")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(1, 3, "samurai", "harpoon", null),
							enemyCreateWithWeapon(0, 3, "priestess", "reinforced armor", null),
							enemyCreateWithWeapon(0, 0, "rogue", "silk steps", null),
							enemyCreate(1, 0, "thief")
						]);
					case 3:
						enemy_list = [
							enemyCreate(3, 3, "mothership"),
							enemyCreate(4, 2, "alien"),
							enemyCreate(2, 2, "alien")
						];
					case 4:
						enemies_list.push([
							enemyCreateWithWeapon(3, 2, "bloodmancer", "reinforced armor", "greataxe"),
							enemyCreateWithWeapon(3, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(4, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(5, 3, "thief", "bladed cuffs", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(6, 2, "enforcer", "harpoon", null),
							enemyCreateWithWeapon(3, 3, "warrior", "reinforced armor", null),
							enemyCreateWithWeapon(4, 3, "warrior", "reinforced armor", null),
							enemyCreateWithWeapon(5, 3, "warrior", "reinforced armor", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(6, 3, "paragon", "tower shield", "greataxe"),
							enemyCreateWithWeapon(5, 1, "archer", "compound bow", null),
							enemyCreateWithWeapon(6, 1, "archer", "compound bow", null),
							enemyCreateWithWeapon(7, 1, "archer", "compound bow", null)
						]);
					case 5:
						enemy_list = [
							enemyCreate(0, 1, "pawn"),
							enemyCreate(1, 1, "pawn"),
							enemyCreate(2, 1, "pawn"),
							enemyCreate(3, 1, "pawn"),
							enemyCreate(4, 3, "pawn"),
							enemyCreate(5, 1, "pawn"),
							enemyCreate(6, 1, "pawn"),
							enemyCreate(7, 1, "pawn"),
							enemyCreate(4, 1, "king")
						];
					case _:
						enemy_list = [];
				}
			case 4:
				switch level
				{
					case 1:
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "exarch", "bone ward", "spiked flail"),
							enemyCreateWithWeapon(4, 3, "slayer", "plated boots", "compound bow"),
							enemyCreateWithWeapon(2, 3, "ranger", "silk steps", null),
							enemyCreateWithWeapon(3, 1, "sniper", "spiked flail", "compound bow")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "enforcer", "bloodthirster", null),
							enemyCreateWithWeapon(1, 1, "rogue", "spiked flail", null),
							enemyCreateWithWeapon(6, 1, "rogue", "spiked flail", null),
							enemyCreateWithWeapon(3, 0, "rogue", "spiked flail", null),

						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "paragon", "astral armor", "harpoon"),
							enemyCreateWithWeapon(4, 1, "bard", "harpoon", "harpoon"),
							enemyCreateWithWeapon(2, 2, "warlock", "compound bow", null),
							enemyCreateWithWeapon(4, 2, "warlock", "compound bow", null),
						]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(3, 0, "assassin", "bloodthirster", null),
							enemyCreateWithWeapon(4, 0, "assassin", "bloodthirster", null),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "bloodmancer", "silk steps", "plated boots"),
							enemyCreateWithWeapon(4, 1, "bloodmancer", "silk steps", "plated boots"),
							enemyCreateWithWeapon(3, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(4, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(5, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(2, 3, "thief", "bladed cuffs", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 2, "shogun", "astral armor", "greataxe"),
							enemyCreateWithWeapon(7, 3, "shogun", "tempest bow", "body armor")
						]);
					case 3:
						enemy_list = [enemyCreate(3, 1, "thunder spirit")];
					case 4:
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "laureate", "exalted staff", "harpoon"),
							enemyCreateWithWeapon(4, 2, "priestess", "tower shield", null),
							enemyCreateWithWeapon(2, 2, "priestess", "tower shield", null),
							enemyCreateWithWeapon(3, 3, "paragon", "sword of ruin", "swift greaves")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(4, 2, "archmage", "mugen cap", "shield"),
							enemyCreateWithWeapon(3, 3, "valkyrie", "silk steps", null),
							enemyCreateWithWeapon(4, 3, "valkyrie", "silk steps", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "paragon", "sword of ruin", "apollo's trail"),
							enemyCreateWithWeapon(0, 0, "artillery", "gun", null),
							enemyCreateWithWeapon(7, 0, "artillery", "gun", null),
							enemyCreateWithWeapon(3, 0, "artillery", "gun", null)
						]);
					case 5:
						enemy_list = [
							enemyCreate(3, 1, "ashen lord"),
							enemyCreate(0, 3, "fire elemental"),
							enemyCreate(7, 3, "fire elemental"),
							enemyCreate(2, 2, "fire elemental"),
							enemyCreate(5, 2, "fire elemental"),
						];
					case _:
						enemy_list = [];
				}
			case 5:
				switch level
				{
					case 1:
						enemies_list.push([
							enemyCreateWithWeapon(1, 1, "bloodmancer", "sword of ruin", "bladed cuffs"),
							enemyCreateWithWeapon(6, 1, "bloodmancer", "sword of ruin", "bladed cuffs"),
							enemyCreateWithWeapon(3, 3, "knight", "reinforced armor", "tower shield"),
							enemyCreateWithWeapon(4, 3, "knight", "reinforced armor", "tower shield"),
							enemyCreateWithWeapon(5, 3, "knight", "reinforced armor", "tower shield"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(1, 2, "shogun", "apollo's trail", "greataxe"),
							enemyCreateWithWeapon(3, 2, "shogun", "apollo's trail", "greataxe"),
							enemyCreateWithWeapon(5, 2, "shogun", "apollo's trail", "greataxe"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(1, 0, "enforcer", "tempest bow", null),
							enemyCreateWithWeapon(6, 0, "enforcer", "tempest bow", null),
							enemyCreateWithWeapon(3, 3, "exarch", "bone ward", "handaxe"),
							enemyCreateWithWeapon(4, 3, "exarch", "bone ward", "handaxe"),
						]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(4, 0, "bloodmancer", "gun", "greataxe"),
							enemyCreateWithWeapon(1, 1, "enforcer", "harpoon", "reinforced armor"),
							enemyCreateWithWeapon(6, 1, "enforcer", "reinforced armor", "spiked flail"),
							enemyCreateWithWeapon(3, 3, "samurai", "bladed cuffs", "plated boots"),
							enemyCreateWithWeapon(4, 3, "samurai", "bladed cuffs", "plated boots"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "laureate", "harpoon", "reinforced armor"),
							enemyCreateWithWeapon(4, 0, "archmage", "exalted staff", "harpoon"),
							enemyCreateWithWeapon(3, 3, "paragon", "tower shield", "bladed buffs"),
							enemyCreateWithWeapon(4, 3, "priestess", "astral armor", "spiked flail"),
							enemyCreateWithWeapon(2, 3, "priestess", "astral armor", "harpoon"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "assassin", "sword of ruin", "apollo's trail"),
							enemyCreateWithWeapon(7, 0, "assassin", "sword of ruin", "apollo's trail"),
							enemyCreateWithWeapon(3, 3, "slayer", "greataxe", "body armor"),
							enemyCreateWithWeapon(4, 3, "slayer", "greataxe", "body armor"),
						]);
					case 3:
						enemy_list = [
							enemyCreate(0, 0, "joker"),
							enemyCreate(7, 0, "joker"),
							enemyCreate(0, 3, "joker"),
							enemyCreate(7, 3, "joker"),
						];
					case 4:
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "assassin", "dragonslayer", "silk steps"),
							enemyCreateWithWeapon(7, 0, "assassin", "dragonslayer", "silk steps"),
							enemyCreateWithWeapon(3, 0, "assassin", "dragonslayer", "silk steps"),
							enemyCreateWithWeapon(3, 2, "archmage", "harpoon", "plated boots"),
							enemyCreateWithWeapon(4, 2, "archmage", "spiked flail", "bladed cuffs"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "artillery", "gun", "body armor"),
							enemyCreateWithWeapon(4, 1, "artillery", "gun", "body armor"),
							enemyCreateWithWeapon(3, 3, "paragon", "tower shield", "plated boots"),
							enemyCreateWithWeapon(4, 3, "paragon", "reinforced armor", "plated boots"),
							enemyCreateWithWeapon(3, 2, "laureate", "mugen cap", "greataxe"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(2, 3, "paragon", "bone ward", "body armor"),
							enemyCreateWithWeapon(5, 3, "exarch", "astral armor", "body armor"),
							enemyCreateWithWeapon(2, 1, "ranger", "mugen cap", "harpoon"),
							enemyCreateWithWeapon(5, 1, "ranger", "mugen cap", "harpoon"),
							enemyCreateWithWeapon(1, 2, "samurai", "bladed cuffs", "reinforced armor"),
							enemyCreateWithWeapon(6, 2, "samurai", "bladed cuffs", "reinforced armor"),
						]);

					case 5:
						enemy_list = [enemyCreate(3, 2, "overlord"),];
					case _:
						enemy_list = [];
				}
			case 6:
				switch level
				{
					case 1:
						enemies_list.push([
							enemyCreate(0, 0, "all-seeing eye"),
							enemyCreate(1, 0, "all-seeing eye"),
							enemyCreate(6, 0, "all-seeing eye"),
							enemyCreate(7, 0, "all-seeing eye"),
							enemyCreateWithWeapon(3, 0, "champion", "sword of ruin", "bloodthirster"),
							enemyCreateWithWeapon(4, 0, "champion", "tempest bow", "apollo's trail"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "mothership", "gun", null), enemyCreateWithWeapon(7, 0, "mothership", "gun", null),
							enemyCreateWithWeapon(3, 2, "mothership", "gun", null), enemyCreateWithWeapon(4, 2, "mothership", "gun", null),
							enemyCreate(2, 2, "alien"), enemyCreate(5, 2, "alien"), enemyCreate(3, 3, "alien"), enemyCreate(4, 3, "alien"),
							enemyCreate(2, 3, "alien"), enemyCreate(5, 3, "alien"),
						]);
					case 3:
						enemies_list.push([
							enemyCreateWithWeapon(3, 2, "ashen lord", "apollo's trail", "tempest bow"),
							enemyCreate(0, 3, "fire elemental"),
							enemyCreate(7, 3, "fire elemental"),
							enemyCreateWithWeapon(3, 0, "overlord", "exalted staff", null),
						]);
						enemies_list.push([
							enemyCreate(2, 3, "thunder spirit"), enemyCreate(3, 2, "thunder spirit"), enemyCreate(4, 3, "thunder spirit"),
							enemyCreate(5, 2, "thunder spirit"), enemyCreate(0, 0, "slime"), enemyCreate(0, 1, "slime"), enemyCreate(0, 2, "slime"),
							enemyCreate(0, 3, "slime"), enemyCreate(7, 0, "slime"), enemyCreate(7, 1, "slime"), enemyCreate(7, 2, "slime"),
							enemyCreate(7, 3, "slime"),
						]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(2, 2, "queen", "mugen cap", null), enemyCreateWithWeapon(5, 2, "queen", "mugen cap", null),
							enemyCreateWithWeapon(2, 2, "queen", "mugen cap", null), enemyCreateWithWeapon(5, 2, "queen", "mugen cap", null),
							enemyCreateWithWeapon(3, 2, "king", "bone ward", null), enemyCreateWithWeapon(4, 2, "king", "bone ward", null),
							enemyCreate(0, 2, "pawn"), enemyCreate(1, 2, "pawn"), enemyCreate(6, 2, "pawn"), enemyCreate(7, 2, "pawn"),
							enemyCreate(2, 3, "pawn"), enemyCreate(3, 3, "pawn"), enemyCreate(4, 3, "pawn"), enemyCreate(5, 3, "pawn"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "joker", "mugen cap", null), enemyCreateWithWeapon(7, 0, "joker", "sword of ruin", null),
							enemyCreateWithWeapon(0, 3, "joker", "dragonslayer", null), enemyCreateWithWeapon(7, 3, "joker", "gun", null),
							enemyCreate(3, 3, "king"), enemyCreate(4, 3, "king"), enemyCreate(1, 2, "pawn"), enemyCreate(2, 2, "pawn"),
							enemyCreate(5, 2, "pawn"), enemyCreate(6, 2, "pawn"), enemyCreate(7, 2, "pawn"), enemyCreate(0, 2, "pawn"),
						]);
					case _:
						enemy_list = [];
				}
			case _:
				enemy_list = [];
		}

		if (enemies_list.length > 0)
		{
			var hash_value = PlayerState.hashString(sessionId + Std.string(stage) + Std.string(level));
			var rand = new FlxRandom(Std.int(Math.abs(hash_value)));
			var throw_away = rand.int();
			var rand_int = rand.int(0, enemies_list.length - 1);
			enemy_list = enemies_list[rand_int];
		}

		return createEnemySetupFromList(enemy_list);
	}

	private static var null_func = function()
	{
		return null;
	};

	static function enemyCreateWithWeapon(x:Int, y:Int, enemyName:String, weapon1:String, weapon2:String)
	{
		return {
			x: x,
			y: y,
			id: UnitData.unitIDs.get(enemyName),
			weapon1ID: WeaponData.weaponIDs.get(weapon1),
			weapon2ID: WeaponData.weaponIDs.get(weapon2)
		};
	}

	static function enemyCreate(x:Int, y:Int, enemyName:String)
	{
		return enemyCreateWithWeapon(x, y, enemyName, null, null);
	}

	public static function createEnemySetupFromList(enemyList:Array<
		{
			x:Int,
			y:Int,
			id:Int,
			weapon1ID:Int,
			weapon2ID:Int
		}>)
	{
		var retList = new Array<{x:Int, y:Int, enemy:Unit}>();
		for (struct in enemyList)
		{
			var enemy = new Unit(0, 0, struct.id, null_func);
			enemy.disable();

			if (struct.weapon1ID != null)
			{
				var weap1 = new Weapon(0, 0, struct.weapon1ID, null_func);
				weap1.disable();
				weap1.attach(enemy.weaponSlot1);
			}

			if (struct.weapon2ID != null)
			{
				var weap2 = new Weapon(0, 0, struct.weapon2ID, null_func);
				weap2.disable();
				weap2.attach(enemy.weaponSlot2);
			}
			retList = retList.concat([{x: struct.x, y: struct.y, enemy: enemy}]);
		}
		return retList;
	}
}
