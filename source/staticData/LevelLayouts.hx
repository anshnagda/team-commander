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
						enemies_list.push([
							enemyCreate(2, 3, "warrior"),
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreate(4, 3, "warrior"),
							enemyCreate(3, 1, "archer")
						]);
						enemies_list.push([
							enemyCreate(2, 2, "warrior"),
							enemyCreateWithWeapon(3, 1, "archer", "bow", null),
							enemyCreate(3, 2, "mage"),
							enemyCreate(2, 3, "mage")
						]);
						enemies_list.push([
							enemyCreate(2, 1, "archer"),
							enemyCreateWithWeapon(6, 3, "thief", "sword", null),
							enemyCreate(3, 1, "archer"),
							enemyCreate(1, 3, "thief")
						]);
					case 2:
						enemies_list.push([
							enemyCreate(2, 3, "warrior"),
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreate(3, 2, "mage"),
							enemyCreateWithWeapon(6, 3, "thief", "sword", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreateWithWeapon(0, 1, "archer", "bow", null),
							enemyCreate(4, 2, "mage"),
							enemyCreate(7, 3, "warrior")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "archer", "spear", null),
							enemyCreateWithWeapon(0, 1, "archer", "bow", null),
							enemyCreate(1, 3, "thief"),
							enemyCreate(1, 2, "mage")
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
						enemies_list.push([enemyCreate(2, 3, "rogue"), enemyCreate(2, 2, "rogue")]);
						enemies_list.push([enemyCreate(2, 3, "warlock"), enemyCreate(7, 1, "rogue")]);
						enemies_list.push([enemyCreate(0, 3, "knight"), enemyCreate(0, 2, "bard")]);
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
							enemyCreateWithWeapon(2, 0, "slayer", "harpoon", null),
							enemyCreateWithWeapon(3, 0, "slayer", "spiked flail", null)
						]);
						enemies_list.push([
							enemyCreate(6, 3, "duelist"),
							enemyCreateWithWeapon(1, 3, "samurai", "bladed cuffs", null),
							enemyCreateWithWeapon(0, 0, "rogue", "silk steps", null)
						]);
						enemies_list.push([
							enemyCreate(2, 2, "slayer"),
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
							enemyCreateWithWeapon(1, 2, "sniper", "bladed cuffs", null),
							enemyCreateWithWeapon(1, 3, "knight", "tower shield", null),
							enemyCreate(0, 3, "thief")
						]);
						enemies_list.push([
							enemyCreate(1, 3, "samurai"),
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
							enemyCreateWithWeapon(3, 2, "bloodmancer", "reinforced armor", null),
							enemyCreateWithWeapon(3, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(4, 3, "thief", "bladed cuffs", null),
							enemyCreateWithWeapon(5, 3, "thief", "bladed cuffs", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(6, 2, "enforcer", "harpoon", null),
							enemyCreateWithWeapon(3, 3, "warrior", "bladed cuffs", null),
							enemyCreateWithWeapon(4, 3, "warrior", "bladed cuffs", null),
							enemyCreateWithWeapon(5, 3, "warrior", "bladed cuffs", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(6, 3, "paragon", "tower shield", null),
							enemyCreateWithWeapon(5, 2, "archer", "bladed cuffs", null),
							enemyCreateWithWeapon(6, 2, "archer", "bladed cuffs", null),
							enemyCreateWithWeapon(7, 2, "archer", "bladed cuffs", null)
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
							enemyCreateWithWeapon(4, 3, "slayer", "plated boots", null),
							enemyCreateWithWeapon(2, 3, "ranger", "silk steps", null),
							enemyCreateWithWeapon(3, 1, "sniper", "bow", "bow")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 3, "paragon", "astral armor", null),
							enemyCreateWithWeapon(1, 1, "rogue", "greataxe", null),
							enemyCreateWithWeapon(6, 1, "rogue", "greataxe", null),
							enemyCreateWithWeapon(3, 0, "rogue", "greataxe", null),

						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "enforcer", "bloodthirster", null),
							enemyCreateWithWeapon(4, 1, "bard", "harpoon", null),
							enemyCreateWithWeapon(2, 2, "warlock", "compound bow", null),
							enemyCreateWithWeapon(4, 2, "warlock", "compound bow", null),
						]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(3, 0, "assassin", "bloodthirster", null),
							enemyCreateWithWeapon(4, 0, "assassin", "dragonslayer", null),
							enemyCreateWithWeapon(2, 2, "warlock", "harpoon", null)
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "bloodmancer", null, null),
							enemyCreateWithWeapon(4, 1, "bloodmancer", null, null),
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
							enemyCreateWithWeapon(3, 1, "laureate", "exalted staff", null),
							enemyCreateWithWeapon(3, 2, "priestess", "tower shield", null),
							enemyCreateWithWeapon(4, 2, "priestess", "tower shield", null),
							enemyCreateWithWeapon(3, 3, "paragon", "sword of ruin", "swift greaves")
						]);
						enemies_list.push([
							enemyCreateWithWeapon(4, 2, "archmage", "mugen cap", "shield"),
							enemyCreateWithWeapon(3, 3, "valkyrie", "silk steps", "greataxe"),
							enemyCreateWithWeapon(4, 3, "valkyrie", "silk steps", "greataxe")
						]);
						enemies_list.push([
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
							enemyCreateWithWeapon(1, 1, "bloodmancer", "sword of ruin", null),
							enemyCreateWithWeapon(6, 1, "bloodmancer", "sword of ruin", null),
							enemyCreateWithWeapon(2, 3, "knight", "reinforced armor", null),
							enemyCreateWithWeapon(3, 3, "knight", "reinforced armor", null),
							enemyCreateWithWeapon(4, 3, "knight", "reinforced armor", null),
							enemyCreateWithWeapon(5, 3, "knight", "reinforced armor", null),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(1, 2, "shogun", "apollo's trail", "greataxe"),
							enemyCreateWithWeapon(3, 2, "shogun", "apollo's trail", "greataxe"),
							enemyCreateWithWeapon(5, 2, "shogun", "apollo's trail", "greataxe"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(1, 0, "enforcer", "tempest bow", null),
							enemyCreateWithWeapon(6, 0, "enforcer", "tempest bow", null),
							enemyCreateWithWeapon(3, 3, "exarch", "bone ward", null),
							enemyCreateWithWeapon(4, 3, "exarch", "bone ward", null),
						]);
					case 2:
						enemies_list.push([
							enemyCreateWithWeapon(4, 0, "bloodmancer", "gun", "sword"),
							enemyCreateWithWeapon(1, 1, "enforcer", "harpoon", "reinforced armor"),
							enemyCreateWithWeapon(6, 1, "enforcer", "reinforced armor", "spiked flail"),
							enemyCreateWithWeapon(3, 3, "warrior", "sword", "shield"),
							enemyCreateWithWeapon(3, 4, "warrior", "sword", "shield"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "laureate", "harpoon", "reinforced armor"),
							enemyCreateWithWeapon(4, 0, "archmage", "exalted staff", "harpoon"),
							enemyCreateWithWeapon(3, 3, "paragon", "tower shield", "bladed buffs"),
							enemyCreateWithWeapon(4, 3, "warrior", "tower shield", "spiked flail"),
							enemyCreateWithWeapon(2, 3, "warrior", "tower shield", "harpoon"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(0, 0, "assassin", "sword of ruin", "greataxe"),
							enemyCreateWithWeapon(7, 0, "assassin", "sword of ruin", "greataxe"),
							enemyCreateWithWeapon(3, 3, "knight", "greataxe", "plated boots"),
							enemyCreateWithWeapon(4, 3, "knight", "greataxe", "greataxe"),
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
							enemyCreateWithWeapon(0, 0, "assassin", "dragonslayer", null),
							enemyCreateWithWeapon(7, 0, "assassin", "dragonslayer", null),
							// enemyCreateWithWeapon(3, 0, "assassin", "dragonslayer", null),
							enemyCreateWithWeapon(3, 2, "archmage", "harpoon", "plated boots"),
							enemyCreateWithWeapon(4, 2, "archmage", "spiked flail", "bladed cuffs"),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(3, 1, "artillery", "gun", null),
							enemyCreateWithWeapon(4, 1, "artillery", "gun", null),
							enemyCreateWithWeapon(3, 3, "paragon", "tower shield", null),
							enemyCreateWithWeapon(4, 3, "paragon", "reinforced armor", null),
							enemyCreateWithWeapon(3, 2, "bard", "greataxe", null),
						]);
						enemies_list.push([
							enemyCreateWithWeapon(2, 3, "paragon", "bone ward", null),
							enemyCreateWithWeapon(5, 3, "exarch", "astral armor", null),
							enemyCreateWithWeapon(2, 1, "ranger", "mugen cap", null),
							enemyCreateWithWeapon(5, 1, "ranger", "mugen cap", null),
							enemyCreateWithWeapon(1, 2, "samurai", "bladed cuffs", "shield"),
							enemyCreateWithWeapon(5, 2, "samurai", "bladed cuffs", "shield"),
						]);

					case 5:
						enemy_list = [enemyCreate(3, 2, "overlord"),];
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
