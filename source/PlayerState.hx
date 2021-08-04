package;

import CapstoneLogger;
import attachingMechanism.Slot;
import entities.*;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.plugin.FlxScrollingText.ScrollingTextData;
import flixel.group.*;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import grids.*;
import haxe.display.Display.Package;
import js.html.Console;
import js.lib.Math;
import openfl.display.Sprite;
import rewardCards.UnitCard;
import states.ShopState;
import staticData.Font;
import staticData.UnitData;
import staticData.WeaponData;

@:publicFields
class PlayerState
{
	public static var tutorial = true;

	// var allied_units:FlxGroup = new FlxGroup();
	var allied_units:FlxGroup = new FlxGroup();
	var weapons:FlxGroup = new FlxGroup();
	var gold:Int = 0;
	var current_stage = 1;
	var current_level = 1;
	var unit_capcity = 1;

	var battle_grid:BattleGrid;
	var bench:SlotGrid;
	var inventory:SlotGrid;
	var numUnitsTextSprite:FlxText;

	var sellSlot:Slot;

	var unitInShop:Array<Int>;
	var unitPriceInShop:Array<FlxText>;
	var rerollCost:Int;
	var inShope = false;
	var firstTimeShop:Bool = true;

	var firstTimeLose:Bool = true;

	// var tutorial = true;
	var mergeSlot1:SlotGrid;
	var mergeSlot2:SlotGrid;
	var mergeResultSlot:SlotGrid;

	var advMergeSlot1:SlotGrid;
	var advMergeSlot2:SlotGrid;
	var advMergeSlot3:SlotGrid;
	var advMergeResultSlot:SlotGrid;

	var inMerge = false;

	var log:CapstoneLogger;
	var logData:LoggingData;
	var sectionStarted = false;
	var runID:Int = 0;

	var userID:String;

	var livesRemaining = 3;
	var numberOfLosses = 0;

	var loseMult = 0;
	var winMult = 0;
	var clearedOnce = false;

	var versionPlayed:Int; // note: 0 = Static   1 = Adaptive

	var difficulty:Int = 0;

	public function new()
	{
		var unit = new Unit(20, 20, UnitData.unitIDs.get("warrior"), closestUnitSlotCoords); // change it so he is attached to bench
		allied_units.add(unit);

		if (Main.DEV_ENABLED)
		{
			// for (i in 9...WeaponData.weaponNames.length)
			// {
			// 	var weapon = new Weapon(0, 0, i, closestWeaponSlotCoords);
			// 	weapons.add(weapon);
			// }

			// for (i in 14...24)
			// {
			// 	var unit = new Unit(20, 20, i, closestUnitSlotCoords);
			// 	allied_units.add(unit);
			// }
			// var unit = new Unit(20, 20, 5, closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, 5, closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, 5, closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, 5, closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, 5, closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);

			gold = 999999999;
			current_stage = 1;
			current_level = 2;
			// var unit = new Unit(20, 20, UnitData.unitIDs.get("warrior"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);

			// var unit = new Unit(20, 20, UnitData.unitIDs.get("bard"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);

			// var unit = new Unit(20, 20, UnitData.unitIDs.get("bard"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);

			// var unit = new Unit(20, 20, UnitData.unitIDs.get("bard"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, UnitData.unitIDs.get("warlock"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);
			// var unit = new Unit(20, 20, UnitData.unitIDs.get("archer"), closestUnitSlotCoords); // change it so he is attached to bench
			// allied_units.add(unit);

			// var weapon = new Weapon(0, 0, WeaponData.weaponIDs.get("bow"), closestWeaponSlotCoords);
			// weapons.add(weapon);
			// var weapon = new Weapon(0, 0, WeaponData.weaponIDs.get("bow"), closestWeaponSlotCoords);
			// weapons.add(weapon);
			// var weapon = new Weapon(0, 0, WeaponData.weaponIDs.get("shield"), closestWeaponSlotCoords);
			// weapons.add(weapon);
			// var weapon = new Weapon(0, 0, WeaponData.weaponIDs.get("sword"), closestWeaponSlotCoords);
			// weapons.add(weapon);
			// var weapon = new Weapon(0, 0, WeaponData.weaponIDs.get("tower shield"), closestWeaponSlotCoords);
			// weapons.add(weapon);
		}
		try
		{
			log = new CapstoneLogger(202103, "teamcom", "a084a2b104ca9f35a535f65ed467d3c9", 8); // 7 for the next release
			userID = log.getSavedUserId();
		}
		catch (e)
		{
			userID = null;
			trace("error in localstorage");
		}

		if (userID == null)
		{
			userID = log.generateUuid();
		}
		logData = new LoggingData(this);
		try
		{
			log.setSavedUserId(userID);
		}
		catch (e)
		{
			trace("error in localstorage");
		}
		versionPlayed = 0;

		// var weapon = new Weapon(100, 20, 2, closestWeaponSlotCoords);
		// weapons.add(weapon);
		// var weapon = new Weapon(120, 20, 3, closestWeaponSlotCoords);
		// weapons.add(weapon);
		battle_grid = new BattleGrid(48, 50 + 48, 30, this.disableEverything, "assets/images/tiles/board.png", this);
		bench = new SlotGrid(10, 1, 48, 48, 500, "assets/images/tiles/board.png");
		inventory = new SlotGrid(3, 6, 48, 600, 100, "assets/images/tiles/inventory.png", 1.0);

		sellSlot = new Slot(() -> {x: 100, y: 400}, null);

		mergeSlot1 = new SlotGrid(1, 1, 48, 100, 360, "assets/images/tiles/board.png", 1.0);
		mergeSlot2 = new SlotGrid(1, 1, 48, 250, 360, "assets/images/tiles/board.png", 1.0);
		mergeResultSlot = new SlotGrid(1, 1, 48, 400, 360, "assets/images/tiles/board.png", 1.0);

		advMergeSlot1 = new SlotGrid(1, 1, 48, 100, 150, "assets/images/tiles/board.png", 1.0);
		advMergeSlot2 = new SlotGrid(1, 1, 48, 200, 150, "assets/images/tiles/board.png", 1.0);
		advMergeSlot3 = new SlotGrid(1, 1, 48, 300, 150, "assets/images/tiles/board.png", 1.0);
		advMergeResultSlot = new SlotGrid(1, 1, 48, 400, 150, "assets/images/tiles/board.png", 1.0);

		numUnitsTextSprite = Font.makeText(battle_grid.x, 450, 384, "", 32, FlxColor.WHITE, FlxTextAlign.CENTER);
	}

	public function setDifficulty(diff:Int)
	{
		this.difficulty = diff;
		if (difficulty == 1)
		{
			livesRemaining = 3;
		}
		if (difficulty == 2)
		{
			livesRemaining = 1;
		}
	}

	function disableEverything()
	{
		for (unit in this.allied_units)
		{
			var unit = cast(unit, Unit);
			unit.disable();
		}

		for (weapon in this.weapons)
		{
			var weapon = cast(weapon, Weapon);
			weapon.disable();
		}
	}

	function enableEverything()
	{
		// should enable all allied units and weapons, and snap them to inventory/grid.
		for (unit in this.allied_units)
		{
			var unit = cast(unit, Unit);
			unit.enable();
		}

		for (weapon in this.weapons)
		{
			var weapon = cast(weapon, Weapon);
			weapon.enable();
		}
	}

	public function addUnit(unit:Unit)
	{
		unit.findSlot = closestUnitSlotCoords;
		allied_units.add(unit);
		// do something so it attaches to bench
	}

	public function removeUnit(unit:Unit)
	{
		allied_units.remove(unit, true);
	}

	public function addWeapon(weapon:Weapon)
	{
		weapon.findSlot = closestWeaponSlotCoords;
		weapons.add(weapon);
		// do something so it attaches to bench
	}

	public function mergePossible()
	{
		var basicUnits:Array<String> = [];
		var advancedUnits:Array<String> = [];
		for (unit in allied_units)
		{
			var unit = cast(unit, Unit);
			switch UnitData.unitToRarity[unit.unitID]
			{
				case "basic":
					basicUnits.push(unit.unitName);
				case "advanced":
					advancedUnits.push(unit.unitName);
			}
		}

		var adv_map:Map<String, Int> = new Map<String, Int>();
		for (adv in advancedUnits)
		{
			if (adv_map.get(adv) == null)
			{
				adv_map[adv] = 0;
			}
			adv_map[adv] += 1;
			if (adv_map[adv] >= 3)
			{
				return {unit1: adv, unit2: null, type: "master"};
			}
		}

		if (basicUnits.length >= 2)
		{
			return {unit1: basicUnits[0], unit2: basicUnits[1], type: "basic"};
		}
		return null;
	}

	public function removeWeapon(weapon:Weapon)
	{
		if (!weapon.attached || inShope)
		{
			weapons.remove(weapon, true);
		}
	}

	public function changeLevel(stage:Int, level:Int)
	{
		current_stage = stage;
		current_level = level;
	}

	// Add gold when player earns gold
	public function addGold(amount:Int)
	{
		gold += amount;
	}

	public function addUnitCapacity()
	{
		unit_capcity++;
	}

	// Remove gold when player spends/loses gold
	public function removeGold(amount:Int)
	{
		gold = Math.max(0, gold - amount);
	}

	function closestInventoryCoords(weapon:Weapon)
	{
		var closest_info_inventory = inventory.closest_grid_slot(weapon.x, weapon.y);
		var closest_dist = Std.int(closest_info_inventory.dist);
		var closest_slot = closest_info_inventory.slot;
		return {dist: closest_dist, slot: closest_slot};
	}

	function closestWeaponSlotCoords(weapon:Weapon)
	{
		var closest_dist = 10000;
		var closest_slot = null;
		// for (unit in playerState.allied_units.members)
		if (inShope)
		{
			if (weapon.x < 415 && weapon.y < 450)
			{
				return {dist: 0, slot: sellSlot};
			}
		}
		for (unit in this.allied_units)
		{
			var unit = cast(unit, Unit);
			if (closest_dist > FlxMath.distanceToMouse(unit))
			{
				if (unit.is_weapon_slot_free())
				{
					closest_dist = FlxMath.distanceToMouse(unit);
					closest_slot = unit.weapon_slot();
				}
			}
		}

		var closest_info_inventory = inventory.closest_grid_slot(weapon.x, weapon.y);
		if (closest_info_inventory.dist < closest_dist || closest_dist > 200)
		{
			closest_dist = Std.int(closest_info_inventory.dist);
			closest_slot = closest_info_inventory.slot;
		}
		return {dist: closest_dist, slot: closest_slot};
	}

	function closestBenchSlotCoords(unit:Unit)
	{
		return bench.closest_grid_slot(unit.x, unit.y);
	}

	function closestUnitSlotCoords(unit:Unit)
	{
		if (inShope)
		{
			if (unit.x >= ShopState.SELL_BOARD_X
				&& unit.x <= ShopState.SELL_BOARD_X + ShopState.SELL_BOARD_WIDTH
				&& unit.y >= ShopState.SELL_BOARD_Y
				&& unit.y <= ShopState.SELL_BOARD_Y + ShopState.SELL_BOARD_HEIGHT)
			{
				// only sell if it is within the rectangle
				return {slot: sellSlot, dist: 0.0};
			}
			else
			{
				return bench.closest_grid_slot(unit.x, unit.y);
			}
		}

		var closest_info = bench.closest_grid_slot(unit.x, unit.y);
		var closest_info_battle = battle_grid.closest_grid_slot(unit.x, unit.y);

		if (closest_info_battle.dist < closest_info.dist)
		{
			closest_info = closest_info_battle;
		}

		if (inMerge)
		{
			var slot1_info = mergeSlot1.closest_grid_slot(unit.x, unit.y);
			var slot2_info = mergeSlot2.closest_grid_slot(unit.x, unit.y);
			if (slot1_info.dist < closest_info.dist)
			{
				closest_info = slot1_info;
			}
			if (slot2_info.dist < closest_info.dist)
			{
				closest_info = slot2_info;
			}
			if (current_stage >= 3 || Main.DEV_ENABLED)
			{
				var slot1_info = advMergeSlot1.closest_grid_slot(unit.x, unit.y);
				var slot2_info = advMergeSlot2.closest_grid_slot(unit.x, unit.y);
				var slot3_info = advMergeSlot3.closest_grid_slot(unit.x, unit.y);
				if (slot1_info.dist < closest_info.dist)
				{
					closest_info = slot1_info;
				}
				if (slot2_info.dist < closest_info.dist)
				{
					closest_info = slot2_info;
				}
				if (slot3_info.dist < closest_info.dist)
				{
					closest_info = slot3_info;
				}
			}
		}

		return closest_info;
	}

	public function lose()
	{
		this.loseMult++;
		this.winMult--;
		this.winMult--;
		loseMult = Math.round(Math.min(5, loseMult));
		winMult = Math.round(Math.max(0, winMult));
	}

	public function win()
	{
		this.loseMult--;
		loseMult = Math.round(Math.max(0, loseMult));
		if (loseMult == 0 && current_stage != 1)
		{
			winMult++;
			winMult = Math.round(Math.min(6, winMult));
		}
	}

	function getLoseMultiplier()
	{
		if (difficulty == 0)
		{
			return Math.max(0.6, -loseMult * 0.1 + 1);
		}
		return 1.0;
	}

	function getWinMultiplier()
	{
		if (difficulty == 0)
		{
			return Math.min(1.24, winMult * 0.04 + 1);
		}
		if (difficulty == 1)
		{
			return 1.0;
		}
		return 1.24;
	}

	public static function hashString(str:String)
	{
		var result = 0;
		var p = 31;
		var m = 1000000001;
		var powerOfP = 1;
		for (i in 0...str.length)
		{
			result = (result + (str.charCodeAt(i) - 'a'.charCodeAt(0) + 1) * powerOfP) % m;
			powerOfP = (powerOfP * p) % m;
		}
		return result;
	}
}
