package battle;

import attachingMechanism.Snappable;
import entities.*;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import grids.BattleGrid;
import haxe.Constraints.Function;
import haxe.Timer;
import haxe.ds.ListSort;
import haxe.ds.Vector;
import js.html.Console;
import js.html.svg.UnitTypes;
import staticData.UnitData;

// a static class that does battle calculation
// it simulates and moves the units as well
class BattleCalculator extends FlxSprite
{
	var frieNo:Int;
	var eneNo:Int;
	var eneBM:Int = 0;
	var fire_elem:Int = 0;
	var frieBM:Int = 0;

	var unitList:List<Unit>;
	var dead:Array<Unit>;

	var unitStates:Map<Unit, UnitBattleState>;

	var frieU:Array<Unit>;
	var eneU:Array<Unit>;

	var board:Vector<Vector<Unit>>;
	var battleGrid:BattleGrid;

	var eff:Array<Array<Int>>;

	var win:Bool;

	var call:Function;

	public function new(battle:BattleGrid, callBack:Function)
	{
		super();
		findUnits(battle);
		this.battleGrid = battle;
		this.board = battle.unitGrid;

		this.frieNo = frieU.length;
		this.eneNo = eneU.length;

		this.unitList = combineVectors(frieU, eneU);
		this.unitStates = mapCoor(board);
		this.win = false;
		this.call = callBack;

		this.dead = new Array<Unit>();
		Effect.startOfBattle(unitStates);
	}

	public function addEneU(unit:Unit)
	{
		this.eneU.push(unit);
		this.unitList.add(unit);
		eneNo++;
	}

	public function removeEneU(unit:Unit)
	{
		if (eneU.remove(unit))
		{
			eneNo--;
			unitList.remove(unit);
			unitStates.remove(unit);
			return true;
		}
		return false;
	}

	public function addFrieU(unit:Unit)
	{
		this.frieU.push(unit);
		this.unitList.add(unit);
		frieNo++;
	}

	public function removeFrieU(unit:Unit)
	{
		if (frieU.remove(unit))
		{
			frieNo--;
			unitList.remove(unit);
			unitStates.remove(unit);
			return true;
		}
		return false;
	}

	// find all units in the grid and put it into 2 arrays
	// one enemy array and one ally array
	private function findUnits(battleGrid:BattleGrid)
	{
		this.frieU = new Array<Unit>();
		this.eneU = new Array<Unit>();
		for (row in battleGrid.unitGrid)
		{
			for (unit in row)
			{
				if (unit != null)
				{
					if (unit.enemy)
					{
						eneU.push(unit);
						if (unit.unitID == 20)
						{
							eneBM++;
						}
						if (unit.unitID == 35)
						{
							this.fire_elem++;
						}
					}
					else
					{
						frieU.push(unit);
						if (unit.unitID == 20)
						{
							frieBM++;
						}
					}
				}
			}
		}
	}

	// Initiate battle
	// this function will be called recursively with some delay until battle is finished
	public function oneIter()
	{
		var unit = unitList.pop();
		if (unit == null || unitList.isEmpty())
		{
			onComplete();
			return;
		}
		// ---to do -----
		// if within range attack
		// move ability

		if (unitStates[unit].freeze > 0)
		{
			unitStates[unit].freeze--;
			unitList.add(unit);
			unitStates[unit].turnFinished();
			Timer.delay(onComplete, battleGrid.RANDOM_DELAY);
			return;
		}

		var moved = false;
		if (unitStates.get(unit).unit.enemy)
		{
			moved = Effect.moveWithAbilities(unitStates.get(unit), this.battleGrid, unitStates, frieU);
		}
		else
		{
			moved = Effect.moveWithAbilities(unitStates.get(unit), this.battleGrid, unitStates, eneU);
		}

		if (unitStates.get(unit).unit.unitID == 22 && unitStates.get(unit).turnCompleted == 0 && !unitStates.get(unit).isClone)
		{ // summon shogun
			// find target
			var target = new Point(unitStates.get(unit).getCoor().x, 7 - unitStates.get(unit).getCoor().y);
			var i = 0;
			while (battleGrid.unitGrid[target.x][target.y] != null)
			{
				var placeable = findReachablePlace(board, target, i, false);
				placeable.shift();
				if (placeable.length > 0)
				{
					target = placeable.shift();
					break;
				}
				i++;
			}
			var clone = battleGrid.summon_shogun(unit, target);
			unitList.push(clone);
			unitStates[clone] = new UnitBattleState(target, clone);
			unitStates[clone].isClone = true;
			unitStates[clone].weapon1 = unitStates[unit].weapon1;
			unitStates[clone].weapon2 = unitStates[unit].weapon2;
			if (unit.enemy)
			{
				eneNo++;
				eneU.push(clone);
			}
			else
			{
				frieNo++;
				frieU.push(clone);
			}
		}

		var enemy = findNearestEnemy(board, unitStates.get(unit).getCoor(), unit.enemy);
		var reachable = findReachablePlace(board, unitStates.get(unit).getCoor(), unit.currStats.mv, false);
		if (!moved
			&& (distance(unitStates.get(unit).getCoor(), enemy) > unit.currStats.maxRng
				|| distance(unitStates.get(unit).getCoor(), enemy) < unit.currStats.minRng))
		{
			// move first
			var qValueGrid = formQValue(unit, enemy);
			var destPt = findBestPtToMove(reachable, qValueGrid);
			// 1. move the unit to destPt
			moved = move(unitStates.get(unit).getCoor(), destPt, battleGrid);
			unitStates[unit].updateCoor(destPt);
		}

		if (moved)
		{
			Timer.delay(() -> applyBuff(unit, enemy), Std.int(battleGrid.MOVE_DURATION * 1000) + battleGrid.RANDOM_DELAY);
		}
		else
		{
			applyBuff(unit, enemy);
		}
	}

	private function applyBuff(unit:Unit, enemy:Point)
	{
		var buffed = Effect.buffPhase(unitStates[unit], unitStates, battleGrid, this);
		// decide if you want to attack
		if (unitStates.get(unit) != null && distance(unitStates.get(unit).getCoor(), enemy) <= unit.currStats.maxRng
			&& distance(unitStates.get(unit).getCoor(), enemy) >= unit.currStats.minRng)
		{
			if (buffed)
			{
				Timer.delay(() -> attack(enemy, unit), Std.int(battleGrid.ATTACK_DURATION * 1000) + battleGrid.RANDOM_DELAY);
			}
			else
			{
				attack(enemy, unit);
			}
		}
		else
		{
			// clean up units that are dead
			if (frieU.contains(unit) || eneU.contains(unit))
			{
				unitList.add(unit);
			}
			if (unitStates.get(unit) != null) {
				unitStates.get(unit).turnFinished();
			}
			if (buffed)
			{
				Timer.delay(onComplete, Std.int(battleGrid.ATTACK_DURATION * 1000) + battleGrid.RANDOM_DELAY);
			}
			else
			{
				Timer.delay(onComplete, battleGrid.RANDOM_DELAY);
			}
		}
	}

	// attack phase
	private function attack(enemy:Point, unit:Unit)
	{
		// attack !
		var ene = board[enemy.x][enemy.y];
		var oppoU:Array<Unit>;
		if (ene.enemy)
		{
			oppoU = eneU;
		}
		else
		{
			oppoU = frieU;
		}
		var affected = Effect.attackWithAbilities(0, unitStates.get(unit), unitStates.get(ene), oppoU, battleGrid, unitStates);

		Timer.delay(() -> damageCalcAndAfterAtt(affected, unit, ene), Std.int(battleGrid.ATTACK_DURATION * 1000));
	}

	private function damageCalcAndAfterAtt(affectedUnits:Map<Unit, BattleDamage>, unit:Unit, ene:Unit)
	{
		this.dead = Effect.damageCalc(affectedUnits, this.unitStates, unit, this.battleGrid);
		if (unit.unitID == 12 || unit.unitID == 22)
		{ // samurai attack twice
			this.dead = Effect.damageCalc(affectedUnits, unitStates, unit, this.battleGrid);
		}
		this.unitStates.get(unit).attacked();
		Effect.postAttack(unitStates[unit], this.battleGrid);
		if (this.dead.length > 0 && unit.unitID == 16)
		{
			unitList.push(unit);
		}
		else
		{
			unitList.add(unit);
		}
		if (ene.enemy)
		{
			eneNo -= dead.length;
		}
		else
		{
			frieNo -= dead.length;
		}
		unitStates.get(unit).turnFinished();
		Timer.delay(onComplete, Std.int(battleGrid.MOVE_DURATION * 1000));
	}

	// return a sorted list of units that has the fastest unit at the front
	private function combineVectors(v1:Array<Unit>, v2:Array<Unit>)
	{
		var units = new Array<Unit>();
		for (i in v1)
		{
			units.push(i);
		}
		for (i in v2)
		{
			units.push(i);
		}
		units.sort((a, b) -> return b.currStats.spd - a.currStats.spd);
		var res = new List<Unit>();
		for (i in units)
		{
			res.add(i);
		}
		return res;
	}

	private function mapCoor(board:Vector<Vector<Unit>>)
	{
		var res = new Map<Unit, UnitBattleState>();
		var j = 0;
		var i = 0;
		for (row in board)
		{
			for (curr in row)
			{
				if (curr != null)
				{
					res[curr] = new UnitBattleState(new Point(i, j), curr);
					if (curr.weaponSlot1.isOccupied && res[curr].weapon1 != null)
					{
						res[curr].weapon1 = cast(curr.weaponSlot1.attachedSnappable, Weapon).weaponID;
					}
					if (curr.weaponSlot2.isOccupied && res[curr].weapon2 != null)
					{
						res[curr].weapon2 = cast(curr.weaponSlot2.attachedSnappable, Weapon).weaponID;
					}
				}
				j++;
			}
			i++;
			j = 0;
		}
		return res;
	}

	public static function contains(arr:Array<Point>, p:Point)
	{
		for (pt in arr)
		{
			if (pt.x == p.x && pt.y == p.y)
			{
				return true;
			}
		}
		return false;
	}

	public static function findNearestEnemy(board:Vector<Vector<Unit>>, origin:Point, side:Bool)
	{
		var visited = new Array<Point>();
		var next = new Array<Point>();

		next.push(origin);
		visited.push(origin);
		while (next.length != 0)
		{
			var curr = next.shift();
			if (board[curr.x][curr.y] != null && (board[curr.x][curr.y].enemy != side))
			{
				return curr;
			}
			var p1 = new Point(curr.x, curr.y + 1);
			var p2 = new Point(curr.x, curr.y - 1);
			var p3 = new Point(curr.x + 1, curr.y);
			var p4 = new Point(curr.x - 1, curr.y);
			var options = new Array<Point>();
			options.push(p1);
			options.push(p2);
			options.push(p3);
			options.push(p4);
			for (p in options)
			{
				if (!contains(visited, p))
				{
					next.push(p);
					visited.push(p);
				}
			}
		}
		return null;
	}

	public static function findReachablePlace(board:Vector<Vector<Unit>>, origin:Point, speed:Int, considerUnits:Bool)
	{
		var reachable = new Array<Point>();
		var next = new Array<Point>();
		var visited = new Array<Point>();
		reachable.push(origin);
		visited.push(origin);

		next.push(origin);
		while (next.length != 0)
		{
			var curr = next.shift();
			if (distance(curr, origin) > speed)
			{
				break;
			}
			if (board[curr.x][curr.y] == null || considerUnits)
			{
				reachable.push(curr);
			}
			var p1 = new Point(curr.x, curr.y + 1);
			var p2 = new Point(curr.x, curr.y - 1);
			var p3 = new Point(curr.x + 1, curr.y);
			var p4 = new Point(curr.x - 1, curr.y);
			var options = new Array<Point>();
			options.push(p1);
			options.push(p2);
			options.push(p3);
			options.push(p4);
			for (p in options)
			{
				if (!contains(visited, p))
				{
					next.push(p);
					visited.push(p);
				}
			}
		}
		return reachable;
	}

	// a function that, given the current level layout and attacking unit, assigns a value to each empty grid. The closer
	// to the grids that are within range, the higher the value.
	private function formQValue(attacker:Unit, enePt:Point)
	{
		var enemies:Array<Unit>;
		if (attacker.enemy)
		{
			enemies = this.frieU;
		}
		else
		{
			enemies = this.eneU;
		}
		// create a QValue grid
		var qValueGrid = new Vector<Vector<Int>>(8);

		// initialize the QValuegrid
		for (i in 0...8)
		{
			qValueGrid[i] = new Vector<Int>(8);
			for (j in 0...8)
			{
				qValueGrid[i][j] = 0;
			}
		}

		// grid initialized update it
		for (enemy in enemies)
		{
			// update QValue until it converges
			var change = updateQValue(unitStates.get(enemy).getCoor(), qValueGrid, attacker, enePt);
			while (change != 0)
			{
				change = updateQValue(unitStates.get(enemy).getCoor(), qValueGrid, attacker, enePt);
			}
			// move on to the next enemy
		}
		return qValueGrid;
	}

	private function updateQValue(origin:Point, qValueGrid:Vector<Vector<Int>>, attacker:Unit, enePt:Point)
	{
		var visited = new Array<Point>();
		var next = new Array<Point>();
		var minRange = attacker.currStats.minRng;
		var maxRange = attacker.currStats.maxRng;

		var maxChange = 0;

		next.push(origin);
		visited.push(origin);
		while (next.length != 0)
		{
			var curr = next.shift();

			// get its surrounding points first
			var p1 = new Point(curr.x, curr.y + 1);
			var p2 = new Point(curr.x, curr.y - 1);
			var p3 = new Point(curr.x + 1, curr.y);
			var p4 = new Point(curr.x - 1, curr.y);

			var options = new Array<Point>();
			options.push(p1);
			options.push(p2);
			options.push(p3);
			options.push(p4);

			if (battleGrid.unitGrid[curr.x][curr.y] != null
				&& battleGrid.unitGrid[curr.x][curr.y] != attacker
				&& qValueGrid[curr.x][curr.y] != -1)
			{
				// if there is another unit at this place, set it to 0
				qValueGrid[curr.x][curr.y] = -1;
			}
			else if (distance(curr, origin) >= minRange && distance(curr, origin) <= maxRange && qValueGrid[curr.x][curr.y] != -1)
			{
				if (enePt.x == origin.x && enePt.y == origin.y)
				{
					qValueGrid[curr.x][curr.y] = 70;
				}
				else
				{
					// if it is within range of attack and does not have a unit
					qValueGrid[curr.x][curr.y] = 64;
				}
			}
			else if (distance(curr, origin) <= minRange && qValueGrid[curr.x][curr.y] != -1)
			{
				qValueGrid[curr.x][curr.y] = -1;
			}
			else if (qValueGrid[curr.x][curr.y] != -1)
			{ // if it is not within range of attack
				// set qValue to the max(surrouding points - 1, itself)
				var max = qValueGrid[curr.x][curr.y];
				for (pt in options)
				{
					if (qValueGrid[pt.x][pt.y] - 1 > max)
					{
						max = qValueGrid[pt.x][pt.y] - 1;
					}
				}
				if (maxChange < Std.int(Math.abs(max - qValueGrid[curr.x][curr.y])))
				{
					maxChange = max - qValueGrid[curr.x][curr.y];
				}
				qValueGrid[curr.x][curr.y] = max;
			}

			// move on to the next sets of possible points
			for (p in options)
			{
				if (!contains(visited, p))
				{
					next.push(p);
					visited.push(p);
				}
			}
		}
		return maxChange;
	}

	// move to the place with the highest qValue
	private function findBestPtToMove(reachable:Array<Point>, qValueGrid:Vector<Vector<Int>>)
	{
		var option = reachable[0];
		var best = qValueGrid[reachable[0].x][reachable[0].y];
		for (pt in reachable)
		{
			if (qValueGrid[pt.x][pt.y] >= best)
			{
				best = qValueGrid[pt.x][pt.y];
				option = pt;
			}
		}

		if (best == qValueGrid[reachable[0].x][reachable[0].y])
		{
			var rand = new FlxRandom();
			option = reachable[rand.int(0, reachable.length - 1)];
		}
		return option;
	}

	// calculate distance between 2 points
	public static function distance(p1:Point, p2:Point)
	{
		return cast(Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y), Int);
	}

	private function move(origin:Point, dest:Point, battleGrid:BattleGrid)
	{
		var currX = origin.x;
		var currY = origin.y;
		if (currX == dest.x && currY == dest.y)
		{
			return false;
		}
		this.battleGrid.moveUnit(currX, currY, dest.x, dest.y);
		return true;
	}

	// decide to go for another iter or callback to complete
	private function onComplete()
	{
		// kill dead units
		for (toBeKilled in dead)
		{
			unitList.remove(toBeKilled);
			var pt = unitStates[toBeKilled].getCoor();
			battleGrid.killUnit(pt.x, pt.y);
			if (toBeKilled.unitID != 37) {
				unitStates.remove(toBeKilled);
			}
			if (toBeKilled.enemy)
			{
				if (toBeKilled.unitID == 20)
				{
					eneBM--;
				}
			}
			else
			{
				if (toBeKilled.unitID == 20)
				{
					frieBM--;
				}
			}
			if ((toBeKilled.enemy && eneBM > 0 || !toBeKilled.enemy && frieBM > 0) && toBeKilled.unitID != UnitData.unitIDs.get("zombie"))
			{
				var zombie = battleGrid.summon_zombie(toBeKilled.enemy, Std.int(toBeKilled.currStats.atk / 4), Std.int(toBeKilled.maxHp / 4), pt);
				unitList.add(zombie);
				unitStates[zombie] = new UnitBattleState(pt, zombie);
				if (toBeKilled.enemy)
				{
					eneU.push(zombie);
					eneNo++;
				}
				else
				{
					frieU.push(zombie);
					frieNo++;
				}
			}
			if (toBeKilled.enemy)
			{
				eneU.remove(toBeKilled);
			}
			else
			{
				frieU.remove(toBeKilled);
			}
		}
		Effect.deathBuffs(dead, unitStates, battleGrid, this);
		dead.splice(0, dead.length);
		// decide if the game has ended
		if (this.frieNo == 0 || this.eneNo == 0)
		{
			for (unit in frieU)
			{
				unit.enable();
			}
			this.call(this.frieNo != 0);
		}
		else
		{
			Timer.delay(oneIter, battleGrid.RANDOM_DELAY);
		}
	}
}
