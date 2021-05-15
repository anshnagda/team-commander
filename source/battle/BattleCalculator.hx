package battle;

import flixel.math.FlxRandom;
import attachingMechanism.Snappable;
import entities.*;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import grids.BattleGrid;
import haxe.Constraints.Function;
import haxe.Timer;
import haxe.ds.ListSort;
import haxe.ds.Vector;
import js.html.Console;

// a static class that does battle calculation
// it simulates and moves the units as well
class BattleCalculator extends FlxSprite
{
	var frieNo:Int;
	var eneNo:Int;

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
					}
					else
					{
						frieU.push(unit);
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

		var moved = false;
		if (unitStates.get(unit).firstRound)
		{
			if (unitStates.get(unit).unit.enemy)
			{
				moved = Effect.moveWithAbilities(unitStates.get(unit), this.battleGrid, unitStates, frieU);
			}
			else
			{
				moved = Effect.moveWithAbilities(unitStates.get(unit), this.battleGrid, unitStates, eneU);
			}
			unitStates.get(unit).firstRound = false;
		}
		var enemy = findNearestEnemy(board, unitStates.get(unit).getCoor(), unit.enemy);
		var reachable = findReachablePlace(board, unitStates.get(unit).getCoor(), unit.currStats.mv, false);
		if (!moved
			&& (distance(unitStates.get(unit).getCoor(), enemy) > unit.currStats.maxRng
				|| distance(unitStates.get(unit).getCoor(), enemy) < unit.currStats.minRng))
		{
			// move first
			var qValueGrid = formQValue(unit);
			trace(qValueGrid);
			var destPt = findBestPtToMove(reachable, qValueGrid);
			// 1. move the unit to destPt
			moved = move(unitStates.get(unit).getCoor(), destPt, battleGrid);
			unitStates[unit].updateCoor(destPt);
		}

		// decide if you want to attack
		if (distance(unitStates.get(unit).getCoor(), enemy) <= unit.currStats.maxRng
			&& distance(unitStates.get(unit).getCoor(), enemy) >= unit.currStats.minRng)
		{
			if (moved)
			{
				Timer.delay(() -> attack(enemy, unit), Std.int(BattleGrid.MOVE_DURATION * 1000) + BattleGrid.RANDOM_DELAY);
			}
			else
			{
				attack(enemy, unit);
			}
		}
		else
		{
			// clean up units that are dead
			unitList.add(unit);
			Timer.delay(onComplete, Std.int(BattleGrid.MOVE_DURATION * 1000) + BattleGrid.RANDOM_DELAY);
		}
	}

	// attack phase
	private function attack(enemy:Point, unit:Unit)
	{
		// attack !
		var ene = board[enemy.x][enemy.y];
		var affected = Effect.attackWithAbilities(0, unitStates.get(unit), unitStates.get(ene), battleGrid, unitStates);

		Timer.delay(() -> damageCalcAndAfterAtt(affected, unit, ene), Std.int(BattleGrid.ATTACK_DURATION * 1000));
	}

	private function damageCalcAndAfterAtt(affectedUnits:Map<Unit, Int>, unit:Unit, ene:Unit)
	{
		this.dead = Effect.damageCalc(affectedUnits, this.unitStates, unit, this.battleGrid);
		if (unit.unitID == 12)
		{ // samurai attack twice
			this.dead = Effect.damageCalc(affectedUnits, unitStates, unit, this.battleGrid);
		}
		this.unitStates.get(unit).attacked();
		Effect.postAttack(unitStates[unit]);
		unitList.add(unit);
		if (ene.enemy)
		{
			eneNo -= dead.length;
		}
		else
		{
			frieNo -= dead.length;
		}
		Timer.delay(onComplete, BattleGrid.RANDOM_DELAY);
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
				}
				j++;
			}
			i++;
			j = 0;
		}
		return res;
	}

	private static function contains(arr:Array<Point>, p:Point)
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
		trace("Should not reach here " + board[origin.x][origin.y].unitName);
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
	private function formQValue(attacker:Unit)
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
			var change = updateQValue(unitStates.get(enemy).getCoor(), qValueGrid, attacker);
			while (change != 0)
			{
				trace("Not converged yet");
				trace("Change = " + change);
				change = updateQValue(unitStates.get(enemy).getCoor(), qValueGrid, attacker);
			}
			// move on to the next enemy
		}
		return qValueGrid;
	}

	private function updateQValue(origin:Point, qValueGrid:Vector<Vector<Int>>, attacker:Unit)
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

			if (battleGrid.unitGrid[curr.x][curr.y] != null && battleGrid.unitGrid[curr.x][curr.y] != attacker && qValueGrid[curr.x][curr.y] != -1) {
				// if there is another unit at this place, set it to 0
				qValueGrid[curr.x][curr.y] = -1; 
			} else if (distance(curr, origin) >= minRange && distance(curr, origin) <= maxRange && qValueGrid[curr.x][curr.y] != -1) {
				// if it is within range of attack and does not have a unit
				qValueGrid[curr.x][curr.y] = 64;
			} else if (distance(curr, origin) <= minRange && qValueGrid[curr.x][curr.y] != -1) {
				qValueGrid[curr.x][curr.y] = -1;
			} else if (qValueGrid[curr.x][curr.y] != -1){ // if it is not within range of attack
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
		trace("One iteration done");
		return maxChange;
	}

	// move to the place with the highest qValue
	private function findBestPtToMove(reachable:Array<Point>, qValueGrid:Vector<Vector<Int>>)
	{
		var option = reachable[0];
		var best = qValueGrid[reachable[0].x][reachable[0].y];
		for (pt in reachable)
		{
			if (qValueGrid[pt.x][pt.y] > best)
			{
				best = qValueGrid[pt.x][pt.y];
				option = pt;
			}
		}

		if (best == qValueGrid[reachable[0].x][reachable[0].y]) {
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
			unitStates.remove(toBeKilled);
			if (toBeKilled.enemy)
			{
				eneU.remove(toBeKilled);
			}
			else
			{
				frieU.remove(toBeKilled);
			}
		}
		Effect.deathBuffs(dead, unitStates, battleGrid);
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
			Timer.delay(oneIter, BattleGrid.RANDOM_DELAY);
		}
	}
}
