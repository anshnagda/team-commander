package grids;

import attachingMechanism.Snappable;
import battle.BattleDamage;
import battle.Point;
import battle.UnitBattleState;
import entities.*;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import haxe.Constraints.Function;
import haxe.Timer;
import haxe.ds.Vector;
import js.lib.webassembly.Table;
import nape.geom.Vec2;
import staticData.Font;
import staticData.UnitData;

@:publicFields
class BattleGrid extends SlotGrid
{
	// animation durations
	public static inline var ATTACK_DURATION_BASE = 0.2;
	public static inline var MOVE_DURATION_BASE = 0.2;
	public static inline var KILL_DURATION_BASE = 0.0;
	public static inline var RANDOM_DELAY_BASE = 150;

	public var ATTACK_DURATION = ATTACK_DURATION_BASE;
	public var MOVE_DURATION = MOVE_DURATION_BASE;
	public var KILL_DURATION = KILL_DURATION_BASE;
	public var RANDOM_DELAY = RANDOM_DELAY_BASE;

	public var animation_speed:Float = 1.0;

	var is_drawn = false;

	// accessing the units on the grid
	var unitGrid:Vector<Vector<Unit>>;

	// whether the battle is on
	var battleStarted:Bool = false;

	// called when the battle starts to lock all of the units
	var disableEverything:Function;

	// reference to global playerState object
	var playerState:PlayerState;

	// number of units currently on the board
	var numUnits:Int = 0;

	var numBattlingUnits:Int = 0;

	// sprites for attack projectiles and other non-unit, non-weapon entities
	var projectiles:FlxGroup = new FlxGroup();
	var square_effects:FlxGroup = new FlxGroup();
	var summoned_units:FlxGroup = new FlxGroup();
	var arrow:FlxSprite;
	var fireball:FlxSprite;

	var currently_drawn_square:{row:Int, col:Int};

	function setSpeed(mult:Float)
	{
		animation_speed = mult;
		ATTACK_DURATION = ATTACK_DURATION_BASE / mult;
		MOVE_DURATION = MOVE_DURATION_BASE / mult;
		KILL_DURATION = KILL_DURATION_BASE / mult;
		RANDOM_DELAY = Std.int(RANDOM_DELAY_BASE / mult);
	}

	public function new(gridSize:Int, x:Int, y:Int, disableEverything:Function, graphicsSource:String, playerState:PlayerState)
	{
		this.playerState = playerState;

		// all the slots in this battlegrid will update this.numUnits after being attached
		this.slotAttachFunction = function(snap:Snappable)
		{
			var snap = cast(snap, Unit);
			if (!snap.enemy)
			{
				this.numUnits += 1;
				this.updateTextSprite();
			}
		}

		// all the slots in this battlegrid will update this.numUnits after being detached
		this.slotDetachFunction = function(snap:Snappable)
		{
			var snap = cast(snap, Unit);
			if (!snap.enemy)
			{
				this.numUnits -= 1;
				this.updateTextSprite();
			}
		}

		numRows = 8;
		numCols = 8;
		super(numRows, numCols, gridSize, x, y, graphicsSource);

		unitGrid = new Vector<Vector<Unit>>(numRows);
		for (i in 0...numRows)
		{
			unitGrid[i] = new Vector<Unit>(numCols);
		}

		this.disableEverything = disableEverything;

		// Code for "your side"/"enemy's side" text
		var allied_side_text = Font.makeText(0, 0 + numCols * gridSize, numRows * gridSize, "your side", 24, FlxColor.BLUE, FlxColor.WHITE);
		add(allied_side_text);
		var enemy_side_text = Font.makeText(0, -28, numRows * gridSize, "enemy's side", 24, FlxColor.RED, FlxColor.WHITE);
		add(enemy_side_text);

		// Creates projectiles
		this.arrow = new FlxSprite();
		this.fireball = new FlxSprite();
		arrow.loadGraphic("assets/images/projectiles/arrow.png");
		fireball.loadGraphic("assets/images/projectiles/fireball.png");
		projectiles.add(arrow);
		projectiles.add(fireball);
		arrow.kill();
		fireball.kill();

		redrawColors();
	}

	// Updates text reading "numUnits/unitcapacity units on the field". Must be called every time the field is updated.
	function updateTextSprite()
	{
		var numUnitsText = numUnits + "/" + playerState.unit_capcity + " UNITS ON BOARD";
		playerState.numUnitsTextSprite.text = numUnitsText;
		if (numUnits == playerState.unit_capcity)
		{
			playerState.numUnitsTextSprite.color = FlxColor.RED;
		}
		else
		{
			playerState.numUnitsTextSprite.color = FlxColor.WHITE;
		}
	}

	function redrawColors()
	{
		// Changes color of grid squares to reflect the two halves of the board
		for (i in 0...numRows)
		{
			for (j in 0...4)
			{
				sprites_arr[i][j].color = 0xf5718f;
				// sprites_arr[i][j].alpha = 0.85;
			}
			for (j in 4...numCols)
			{
				sprites_arr[i][j].color = 0x7e89fc;
				// sprites_arr[i][j].alpha = 0.85;
			}
		}
	}

	// Must be called when the battle is started. Locks all the units.
	function startBattle()
	{
		arrow.kill();
		redrawColors();
		battleStarted = true;
		numBattlingUnits = numUnits;
		for (i in 0...numRows)
		{
			for (j in 0...numCols)
			{
				if (slots[i][j].isOccupied)
				{
					unitGrid[i][j] = cast(slots[i][j].attachedSnappable, Unit);
					unitGrid[i][j].enableBattleSprites();
					unitGrid[i][j].detach();
				}
				else
				{
					unitGrid[i][j] = null;
				}
			}
		}
		disableEverything();
	}

	// Returns unit on row,col.
	override function get_unit(row:Int, col:Int)
	{
		if (battleStarted)
		{
			return unitGrid[row][col];
		}
		return super.get_unit(row, col);
	}

	// Moves unit in row1, col1 to row2, col2. Returns true if it was successfully moved.
	// The animation takes BattleGrid.move_duration seconds to complete.
	public function moveUnit(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		if (battleStarted)
		{
			if (unitGrid[row1][col1] == null)
			{
				return false;
			}

			FlxTween.tween(unitGrid[row1][col1], square_coords(row2, col2), MOVE_DURATION);
			unitGrid[row2][col2] = unitGrid[row1][col1];
			unitGrid[row1][col1] = null;

			return true;
		}
		return false;
	}

	// shoots a projectile of type projectileType from row1,col1 to row2,col2. takes BattleGrid.attack_duration time.
	function rangedAttack(row1:Int, col1:Int, row2:Int, col2:Int, projectile:FlxSprite)
	{
		var init_coords = square_coords(row1, col1);
		var end_coords = square_coords(row2, col2);

		projectile.reset(init_coords.x, init_coords.y);

		var angle = FlxAngle.angleBetweenPoint(projectile, new FlxPoint(end_coords.x, end_coords.y), true) + 90;
		projectile.angle = angle;

		FlxTween.tween(projectile, square_coords(row2, col2), ATTACK_DURATION, {
			onComplete: function(tween:FlxTween)
			{
				projectile.kill();
			}
		});
	}

	function projectileColumnDownward(row:Int, col:Int, projectile:FlxSprite)
	{
		if (col >= 7)
		{
			projectile.kill();
			projectiles.remove(projectile);
			return;
		}
		if (unitGrid[row][col] != null)
		{
			if (unitGrid[row][col].enemy == false)
			{
				projectile.kill();
				projectiles.remove(projectile);
				return;
			}
		}
		FlxTween.tween(projectile, square_coords(row, col + 1), ATTACK_DURATION / 12, {
			onComplete: function(tween:FlxTween)
			{
				projectileColumnDownward(row, col + 1, projectile);
			}
		});
	}

	function eyeAttack()
	{
		for (row in 0...8)
		{
			var proj = new FlxSprite();
			proj.loadGraphic("assets/images/projectiles/fireball.png");
			var coords = square_coords(row, 0);
			proj.x = coords.x;
			proj.y = coords.y;
			projectiles.add(proj);
			projectileColumnDownward(row, 0, proj);
		}
	}

	// the unit at row1,col1 does a melee attack to row2,col2. takes BattleGrid.attack_duration time.
	function meleeAttack(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var unit = unitGrid[row1][col1];

		FlxTween.tween(unit, square_coords(row2, col2), ATTACK_DURATION / 2, {
			onComplete: function(tween:FlxTween)
			{
				FlxTween.tween(unit, square_coords(row1, col1), ATTACK_DURATION / 2);
			}
		});
	}

	function doubleAttack(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var unit = unitGrid[row1][col1];
		var start_coords = square_coords(row1, col1);
		var end_coords = square_coords(row2, col2);
		var mid_coords = {x: 0.1 * start_coords.x + 0.9 * end_coords.x, y: 0.1 * start_coords.y + 0.9 * end_coords.y};

		FlxTween.tween(unit, end_coords, ATTACK_DURATION / 3, {
			onComplete: function(tween:FlxTween)
			{
				FlxTween.tween(unit, mid_coords, ATTACK_DURATION / 6, {
					onComplete: function(tween:FlxTween)
					{
						FlxTween.tween(unit, end_coords, ATTACK_DURATION / 6, {
							onComplete: function(tween:FlxTween)
							{
								FlxTween.tween(unit, square_coords(row1, col1), ATTACK_DURATION / 3);
							}
						});
					}
				});
			}
		});
	}

	private function summon_unit(summoned_unit:Unit, location:Point)
	{
		if (unitGrid[location.x][location.y] != null)
		{
			return null;
		}
		summoned_unit.enableBattleSprites();
		summoned_unit.detach();
		summoned_unit.disable();
		var coordinates = this.square_coords(location.x, location.y);
		summoned_unit.x = coordinates.x;
		summoned_unit.y = coordinates.y;
		summoned_unit.alpha = 0;

		summoned_units.add(summoned_unit);
		summoned_units.add(summoned_unit.healthBar);
		unitGrid[location.x][location.y] = summoned_unit;

		FlxTween.tween(summoned_unit, {alpha: 1.0}, 0.15);
		return summoned_unit;
	}

	public function summon_zombie(isEnemy:Bool, atk:Int, hp:Int, location:Point)
	{
		var zombie = new Unit(0, 0, UnitData.unitIDs.get("zombie"), null);
		if (isEnemy)
		{
			zombie.enemyStatMultiplier = playerState.getMultiplier();
			zombie.makeEnemy();
		}
		zombie.baseStats.atk = atk;
		zombie.baseStats.hp = hp;
		zombie.updateStats();

		return summon_unit(zombie, location);
	}

	public function summon_shogun(shogun_to_copy:Unit, location:Point)
	{
		var new_shogun = new Unit(0, 0, UnitData.unitIDs.get("shogun"), null);
		if (shogun_to_copy.enemy)
		{
			new_shogun.enemyStatMultiplier = playerState.getMultiplier();
			new_shogun.makeEnemy();
		}
		if (shogun_to_copy.weaponSlot1.isOccupied)
		{
			var weapon1 = new Weapon(0, 0, cast(shogun_to_copy.weaponSlot1.attachedSnappable, Weapon).weaponID, null);
			weapon1.attach(new_shogun.weaponSlot1);
		}
		if (shogun_to_copy.weaponSlot2.isOccupied)
		{
			var weapon2 = new Weapon(0, 0, cast(shogun_to_copy.weaponSlot2.attachedSnappable, Weapon).weaponID, null);
			weapon2.attach(new_shogun.weaponSlot2);
		}
		new_shogun.updateStats();
		return summon_unit(new_shogun, location);
	}

	public function summon_exalted_copy(health:Int, location:Point)
	{
		var new_exalted = new Unit(0, 0, UnitData.unitIDs.get("the exalted one"), null);
		new_exalted.baseStats.hp = health;
		new_exalted.updateStats();
		new_exalted.makeEnemy();

		return summon_unit(new_exalted, location);
	}

	public function summon_queen(location:Point)
	{
		var queen = new Unit(0, 0, UnitData.unitIDs.get("queen"), null);
		queen.enemyStatMultiplier = playerState.getMultiplier();
		queen.makeEnemy();
		return summon_unit(queen, location);
	}

	public function summon_alien(location:Point)
	{
		var alien = new Unit(0, 0, UnitData.unitIDs.get("alien"), null);
		alien.enemyStatMultiplier = playerState.getMultiplier();
		alien.makeEnemy();
		return summon_unit(alien, location);
	}

	public function summon_withering(location:Point)
	{
		var alien = new Unit(0, 0, UnitData.unitIDs.get("withering soul"), null);
		alien.enemyStatMultiplier = playerState.getMultiplier();
		alien.makeEnemy();
		return summon_unit(alien, location);
	}

	public function summon_exalted(location:Point)
	{
		var alien = new Unit(0, 0, UnitData.unitIDs.get("the exalted one"), null);
		alien.enemyStatMultiplier = playerState.getMultiplier();
		alien.makeEnemy();
		return summon_unit(alien, location);
	}

	// public function summon(unitID:Int, locations:Array<Point>, isEnemy:Bool)
	// {
	// 	for (location in locations)
	// 	{
	// 		if (unitGrid[location.x][location.y] == null)
	// 		{
	// 			trace("REACHED HERE");
	// 			var summoned_unit = new Unit(0, 0, unitID, null);
	// 			if (isEnemy)
	// 			{
	// 				summoned_unit.makeEnemy();
	// 			}
	// 			summoned_unit.enableBattleSprites();
	// 			summoned_unit.detach();
	// 			summoned_unit.disable();
	// 			var coordinates = this.square_coords(location.x, location.y);
	// 			summoned_unit.x = coordinates.x;
	// 			summoned_unit.y = coordinates.y;
	// 			summoned_unit.alpha = 0;
	// 			summoned_units.add(summoned_unit);
	// 			summoned_units.add(summoned_unit.healthBar);
	// 			unitGrid[location.x][location.y] = summoned_unit;
	// 			FlxTween.tween(summoned_unit, {alpha: 1.0}, 0.15);
	// 		}
	// 	}
	// }

	public function heal(locations:Array<Point>)
	{
		for (location in locations)
		{
			var heal_sprite = new FlxSprite();
			heal_sprite.loadGraphic("assets/images/projectiles/heal_sq.png");
			heal_sprite.alpha = 0.7;
			var coords = square_coords(location.x, location.y);
			heal_sprite.x = coords.x;
			heal_sprite.y = coords.y;
			projectiles.add(heal_sprite);
			Timer.delay(() -> projectiles.remove(heal_sprite), Std.int(ATTACK_DURATION * 1000));
		}
	}

	public function buff(locations:Array<Point>)
	{
		for (location in locations)
		{
			var heal_sprite = new FlxSprite();
			heal_sprite.loadGraphic("assets/images/projectiles/buff_sq.png");
			heal_sprite.alpha = 0.7;
			var coords = square_coords(location.x, location.y);
			heal_sprite.x = coords.x;
			heal_sprite.y = coords.y;
			projectiles.add(heal_sprite);
			Timer.delay(() -> projectiles.remove(heal_sprite), Std.int(ATTACK_DURATION * 1000));
		}
	}

	public function warlock_attack(location:Point)
	{
		var x = location.x;
		var y = location.y;
		var aoe_lst = [
			{x: x, y: y},
			{x: x - 1, y: y},
			{x: x + 1, y: y},
			{x: x, y: y + 1},
			{x: x, y: y - 1}
		];
		for (loc in aoe_lst)
		{
			if (0 <= loc.x && 0 <= loc.y && loc.x < 8 && loc.y < 8)
			{
				var aoe_sprite = new FlxSprite();
				aoe_sprite.loadGraphic("assets/images/projectiles/flame.png");
				var coords = square_coords(loc.x, loc.y);
				aoe_sprite.x = coords.x;
				aoe_sprite.y = coords.y;
				square_effects.add(aoe_sprite);
				Timer.delay(() -> square_effects.remove(aoe_sprite), Std.int(ATTACK_DURATION * 1000));
			}
		}
	}

	public function archmage_attack(location:Point)
	{
		for (x in location.x - 1...location.x + 2)
		{
			for (y in location.y - 1...location.y + 2)
			{
				if (0 <= x && 0 <= y && x < 8 && y < 8)
				{
					var aoe_sprite = new FlxSprite();
					aoe_sprite.loadGraphic("assets/images/projectiles/flame.png");
					var coords = square_coords(x, y);
					aoe_sprite.x = coords.x;
					aoe_sprite.y = coords.y;
					square_effects.add(aoe_sprite);
					Timer.delay(() -> square_effects.remove(aoe_sprite), Std.int(ATTACK_DURATION * 1000));
				}
			}
		}
	}

	function mothershipAttack(attacker:Point, victim:Point)
	{
		var beam = new FlxSprite();
		beam.loadGraphic("assets/images/projectiles/beam.png");
		var init_coords = square_coords(attacker.x, attacker.y);
		var end_coords = square_coords(victim.x, victim.y);
		beam.reset(init_coords.x, init_coords.y);
		projectiles.add(beam);
		var angle = FlxAngle.angleBetweenPoint(beam, new FlxPoint(end_coords.x, end_coords.y), true) + 80;
		beam.angle = angle;

		FlxTween.tween(beam, end_coords, ATTACK_DURATION, {
			onComplete: function(tween:FlxTween)
			{
				projectiles.remove(beam);
				beam.kill();
			}
		});
	}

	function thunderAttack(attacker:Point, affectedUnits:Map<Unit, BattleDamage>)
	{
		var init_coords = square_coords(attacker.x, attacker.y);

		for (unit in affectedUnits.keys())
		{
			var beam = new FlxSprite();
			beam.loadGraphic("assets/images/projectiles/lightening.png");
			var init_coords = square_coords(attacker.x, attacker.y);
			var end_coords = {x: unit.x, y: unit.y};
			beam.reset(init_coords.x, init_coords.y);
			projectiles.add(beam);
			var angle = FlxAngle.angleBetweenPoint(beam, new FlxPoint(end_coords.x, end_coords.y), true) + 90;
			beam.angle = angle;

			FlxTween.tween(beam, end_coords, ATTACK_DURATION, {
				onComplete: function(tween:FlxTween)
				{
					projectiles.remove(beam);
					beam.kill();
				}
			});
		}
	}

	// the unit at attacker does an attack to the victim.
	public function attack(attacker:Point, victim:Point, attacker_battlestate:UnitBattleState, affectedUnits:Map<Unit, BattleDamage>)
	{
		var unitA = unitGrid[attacker.x][attacker.y];
		var unitB = unitGrid[victim.x][victim.y];
		if (unitA == null)
		{
			return false;
		}
		if (unitA.unitName == "all-seeing eye" || unitA.unitName == "overlord")
		{
			eyeAttack();
		}
		else if (unitA.unitName == "thunder spirit")
		{
			thunderAttack(attacker, affectedUnits);
		}
		else if (unitA.unitName == "mothership" || unitA.unitName == "alien")
		{
			mothershipAttack(attacker, victim);
		}
		else if (UnitData.unitToRanged[unitA.unitID])
		{
			if (UnitData.arrowUnits.contains(unitA.unitName))
			{
				rangedAttack(attacker.x, attacker.y, victim.x, victim.y, arrow);
			}
			else if (UnitData.magicUnits.contains(unitA.unitName))
			{
				rangedAttack(attacker.x, attacker.y, victim.x, victim.y, fireball);
				if (unitA.unitName == "warlock")
				{
					Timer.delay(() -> warlock_attack(victim), Std.int(ATTACK_DURATION * 500));
				}
				if (unitA.unitName == "archmage")
				{
					Timer.delay(() -> archmage_attack(victim), Std.int(ATTACK_DURATION * 500));
				}
			}
			else
			{
				rangedAttack(attacker.x, attacker.y, victim.x, victim.y, arrow);
			}
		}
		else
		{
			if (unitA.unitName == "samurai" || unitA.unitName == "shogun")
			{
				doubleAttack(attacker.x, attacker.y, victim.x, victim.y);
			}
			else
			{
				meleeAttack(attacker.x, attacker.y, victim.x, victim.y);
			}
		}
		for (unit in affectedUnits.keys())
		{
			FlxTween.tween(unit, {x: unit.x, y: unit.y}, ATTACK_DURATION / 2, {
				onComplete: function(tween:FlxTween)
				{
					FlxTween.tween(unit, {x: unit.x + 10, y: unit.y}, ATTACK_DURATION / 4, {
						onComplete: function(tween:FlxTween)
						{
							FlxTween.tween(unit, {x: unit.x - 10, y: unit.y}, ATTACK_DURATION / 4);
						}
					});
				}
			});
		}
		return true;
	}

	// teleport a unit from (r1, c1) to (r2, c2)
	public function teleportUnit(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var unit = unitGrid[row1][col1];

		unitGrid[row2][col2] = unitGrid[row1][col1];
		unitGrid[row1][col1] = null;

		unit.x = square_coords(row2, col2).x;
		unit.y = square_coords(row2, col2).y;
	}

	// kills the unit at row,col. Work in progress.
	public function killUnit(row:Int, col:Int)
	{
		var unit = unitGrid[row][col];
		if (unit == null)
		{
			return false;
		}

		unitGrid[row][col] = null;
		unit.kill();
		return true;
	}

	// to be called after the battle.
	function reset_battle()
	{
		updateTextSprite();
		projectiles.clear();
		projectiles.add(arrow);
		projectiles.add(fireball);
		arrow.kill();
		fireball.kill();
		numUnits = 0;
		battleStarted = false;
		for (i in 0...numRows)
		{
			for (j in 0...numCols)
			{
				if (slots[i][j].isOccupied)
				{
					slots[i][j].attachedSnappable.detach();
				}
			}
		}
		summoned_units.forEach(function(unit:FlxBasic)
		{
			unit.kill();
		});

		for (unit in playerState.allied_units)
		{
			var allied_unit = cast(unit, Unit);
			allied_unit.disableBattleSprites();
		}
	}

	// returns the closest available grid slot on the player's side to the input query.
	override function closest_grid_slot(query_x:Float, query_y:Float)
	{
		if (!is_drawn)
		{
			return {slot: null, dist: 100000.0};
		}
		if (numUnits >= playerState.unit_capcity && !Main.DEV_ENABLED)
		{
			return {slot: null, dist: 10000.0};
		}
		var closest_dist = 10000.0;
		var closest_slot = null;
		for (i in 0...numRows)
		{
			for (j in 4...numCols)
			{
				if (!slots[i][j].isOccupied)
				{
					var coord = square_coords(i, j);
					var dist = Math.sqrt((query_x - coord.x) * (query_x - coord.x) + (query_y - coord.y) * (query_y - coord.y));
					if (dist < closest_dist)
					{
						closest_dist = dist;
						closest_slot = slots[i][j];
					}
				}
			}
		}

		return {slot: closest_slot, dist: closest_dist};
	}

	function unitCapacityExceededNotification() {}

	function draw_range(coords:{row:Int, col:Int})
	{
		redrawColors();
		if (coords != null)
		{
			var unit = slots[coords.row][coords.col].attachedSnappable;
			if (battleStarted)
			{
				unit = unitGrid[coords.row][coords.col];
			}
			if (unit != null)
			{
				var unit = cast(unit, Unit);
				var minRng = unit.currStats.minRng;
				var maxRng = unit.currStats.maxRng;
				for (i in 0...numRows)
				{
					for (j in 0...4)
					{
						var dist = Math.abs(coords.row - i) + Math.abs(coords.col - j);
						if (dist <= maxRng && dist >= minRng)
						{
							sprites_arr[i][j].color = 0x8f0a29;
						}
					}
					for (j in 4...numCols)
					{
						var dist = Math.abs(coords.row - i) + Math.abs(coords.col - j);
						if (dist <= maxRng && dist >= minRng)
						{
							sprites_arr[i][j].color = 0x041095;
						}
					}
				}

				if (unit.unitName == "shogun" && !battleStarted)
				{
					sprites_arr[coords.row][7 - coords.col].color = 0xC0C0C0;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		var current_moused_square = this.square_coords_inverse(FlxG.mouse.x, FlxG.mouse.y);
		// if (current_moused_square != currently_drawn_square)
		// {
		// update the drawing
		draw_range(current_moused_square);
		// }
		super.update(elapsed);
	}
}
