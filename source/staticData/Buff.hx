package staticData;

import flixel.math.FlxRandom;
import battle.UnitBattleState;
import entities.Unit;
import grids.BattleGrid;
import haxe.Constraints.Function;

class Buff
{
	public static var BUFFS:Array<Function> = [bard, laureate, invulnerable, bloodmancerAtt, slime, champion];
	public static var DEBUFFS:Array<Function> = [archmage];

	public static function bard(unit:Unit)
	{
		return new Stats(0, Std.int(unit.currStats.atk * 0.5), 0, 0, 0, 0);
	}

	public static function laureate(unit:Unit)
	{
		return new Stats(0, Std.int(unit.currStats.atk * 0.75), 0, 1, 1, 0);
	}

	public static function invulnerable(unitStates:UnitBattleState, turns:Int)
	{
		unitStates.invinsible = true;
		unitStates.invinsibleTurn = turns;
	}

	public static function archmage(unit:Unit)
	{
		return new Stats(0, -Std.int(0.25 * unit.currStats.atk), 0, 0, -1, 0);
	}

	public static function bloodmancerAtt(deadCount:Int)
	{
		return new Stats(0, 40 * deadCount, 0, 0, 0, 0);
	}

	public static function slime(unit:Unit, d:Unit)
	{
		unit.maxHp += d.maxHp;
		unit.heal(d.maxHp);
		unit.currStats.addStat(new Stats(0, d.currStats.atk, 0, 0, 0, 0));
	}

	public static function champion(attacker:UnitBattleState, grid:BattleGrid)
	{
		grid.buff([attacker.getCoor()]);
		attacker.unit.maxHp += 50;
		// also heal 50
		attacker.unit.heal(50 + 50);
		attacker.unit.currStats.addStat(new Stats(0, Std.int(30 * attacker.unit.enemyStatMultiplier), 0, 0, 0, 0));
		// after every 3rd attack increases move by 1
		if (attacker.numAttDone % 3 == 0)
		{
			attacker.unit.currStats.addStat(new Stats(0, 0, 0, 0, 1, 0));
		}
	}

	public static function joker(attacker:UnitBattleState) {
		var rand = new FlxRandom();
		var buffs = [
			new Stats(0, 0, 0, 0, 0, 0, 50),
			new Stats(0, 0, 0, 0, 0, 0, 0, 100),
			new Stats(0, 0, 0, 0, 0, 0, 0, 0, 0, 2)
		];
		var toput = rand.int(0, buffs.length);
		if (toput == 3) {
			attacker.unit.addShield(400);
		} else if (toput != 0) {
			attacker.applyBuff(buffs[toput], 1);
		} else {
			attacker.applyBuff(buffs[toput], 2);
		}
	}
}
