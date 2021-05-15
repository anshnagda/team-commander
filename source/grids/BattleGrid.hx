package grids;

import attachingMechanism.Snappable;
import battle.Point;
import battle.UnitBattleState;
import entities.*;
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
	public static inline var ATTACK_DURATION = 0.2;
	public static inline var MOVE_DURATION = 0.2;
	public static inline var KILL_DURATION = 0.0;
	public static inline var RANDOM_DELAY = 100;

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

	// sprites for attack projectiles and other non-unit, non-weapon entities
	var projectiles:FlxGroup = new FlxGroup();
	var square_effects:FlxGroup = new FlxGroup();
	var arrow:FlxSprite;
	var fireball:FlxSprite;

	var currently_drawn_square:{row:Int, col:Int};

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

			// update range indicator for
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
		var init_coords = square_coords(row1, col1);
		var end_coords = square_coords(row2, col2);

		var vect = {x: end_coords.x - init_coords.x, y: end_coords.y - init_coords.y};
		end_coords = {x: init_coords.x + Std.int(vect.x * 0.5), y: init_coords.y + Std.int(vect.y * 0.5)};

		FlxTween.tween(unit, square_coords(row2, col2), ATTACK_DURATION / 2, {
			onComplete: function(tween:FlxTween)
			{
				FlxTween.tween(unit, square_coords(row1, col1), ATTACK_DURATION / 2);
			}
		});
	}

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
			square_effects.add(heal_sprite);
			Timer.delay(() -> square_effects.remove(heal_sprite), Std.int(ATTACK_DURATION * 1000));
		}
	}

	public function buff(location:Point) {}

	// the unit at attacker does an attack to the victim.
	public function attack(attacker:Point, victim:Point, attacker_battlestate:UnitBattleState, affectedUnits:Map<Unit, Int>)
	{
		var unitA = unitGrid[attacker.x][attacker.y];
		var unitB = unitGrid[victim.x][victim.y];
		if (unitA == null)
		{
			return false;
		}
		if (unitA.unitName == "all-seeing eye")
		{
			eyeAttack();
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
			}
			else
			{
				rangedAttack(attacker.x, attacker.y, victim.x, victim.y, arrow);
			}
		}
		else
		{
			meleeAttack(attacker.x, attacker.y, victim.x, victim.y);
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
		arrow.kill();
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
