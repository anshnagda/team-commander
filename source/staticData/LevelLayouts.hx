package staticData;

import battle.Point;
import entities.Unit;
import entities.Weapon;

@:publicFields
class LevelLayouts
{
	static function createEnemySetup(stage:Int, level:Int)
	{
		var enemy_list = [];
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
						enemy_list = [
							enemyCreate(2, 3, "warrior"),
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreate(4, 3, "warrior"),
							enemyCreate(3, 1, "archer")
						];
					case 2:
						enemy_list = [
							enemyCreate(2, 3, "warrior"),
							enemyCreateWithWeapon(3, 3, "warrior", "shield", null),
							enemyCreate(3, 2, "mage"),
							enemyCreateWithWeapon(6, 3, "thief", "sword", null)
						];
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
						enemy_list = [enemyCreate(2, 3, "rogue"), enemyCreate(2, 2, "rogue")];
					case 5:
						enemy_list = [enemyCreate(3, 3, "champion")];
					case _:
						enemy_list = [];
				}
			case _:
				enemy_list = [];
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
