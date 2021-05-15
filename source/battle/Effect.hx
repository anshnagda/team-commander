package battle;

import entities.Unit;
import flixel.math.FlxRandom;
import grids.BattleGrid;
import lime.utils.PackedAssetLibrary;

// This class applies effect on units during battle
// Static function call
class Effect
{
	public static function attackWithAbilities(effID:Int, attacker:UnitBattleState, victim:UnitBattleState, grid:BattleGrid,
			unitStates:Map<Unit, UnitBattleState>)
	{
		var affectedUnits:Map<Unit, Int> = new Map<Unit, Int>();
		var finalDamage = attacker.unit.currStats.atk;
		// attack phase
		trace(attacker.unit.unitID);
		switch attacker.unit.unitID
		{
			case 5: // sniper: Every 3rd Attack deals (2x) damage
				if ((attacker.numAttDone + 1) % 3 == 0)
				{
					finalDamage = finalDamage * 2;
				}
				affectedUnits[victim.unit] = finalDamage;
			case 7: // warlock: Also deals (50%) dmg to all enemies within 1 block of target
				affectedUnits[victim.unit] = finalDamage;
				aoeRoundTargets(affectedUnits, victim.getCoor(), 1, Std.int(finalDamage / 2), attacker.unit.enemy, grid);

			// case 11: // Ranger: Attacks hit all enemies in a column, with damage decreasing by (30%) per hit
			// on hold

			case 24: // All-Seeing Eye
				firstColoumn(affectedUnits, finalDamage, grid, attacker.unit.enemy);
				trace(affectedUnits);

			default:
				affectedUnits[victim.unit] = finalDamage;
		}

		// buff phase
		switch attacker.unit.unitID
		{
			case 8: // bard increase allies damage
				// find buff affected units
				var buffedUnits = new Map<Unit, Int>();
				aoeRoundTargets(buffedUnits, attacker.getCoor(), 3, 0, !attacker.unit.enemy, grid);
				// apply buff to affected Units
				for (unit in buffedUnits.keys())
				{
					unitStates[unit].applyBuff(new Stats(0, Std.int(attacker.unit.currStats.atk / 4 * 3), 0, 0, 0, 0), 1);
				}

			case 9: // cleric heal 25% of cleric's current health
				if (attacker.numAttDone % 2 == 0)
				{
					attacker.unit.heal(Std.int(50 + attacker.unit.currStats.hp / 4));
					var buffedUnits = new Map<Unit, Int>();
					aoeRoundTargets(buffedUnits, attacker.getCoor(), 1, 0, !attacker.unit.enemy, grid);
					var coorToHeal = new Array<Point>();
					coorToHeal.push(attacker.getCoor());
					for (unit in buffedUnits.keys())
					{
						unit.heal(Std.int(attacker.unit.currStats.hp / 4));
						coorToHeal.push(unitStates.get(unit).getCoor());
						// to be implemented
						// heal animation?
					}
					grid.heal(coorToHeal);
				}
		}

		for (enemy in affectedUnits.keys())
		{
			grid.attack(attacker.getCoor(), unitStates.get(enemy).getCoor(), attacker, affectedUnits);
		}
		return affectedUnits;
	}

	// does damage calculation, apply damage, and update health
	public static function damageCalc(affectedUnits:Map<Unit, Int>, unitStates:Map<Unit, UnitBattleState>, attacker:Unit, grid:BattleGrid)
	{
		var dead = new Array<Unit>();

		// damage calculation phase
		for (enemy in affectedUnits.keys())
		{
			if (enemy.unitID == 4)
			{ // if it is a Knight damage reduction
				affectedUnits[enemy] = affectedUnits[enemy] - Std.int(enemy.currStats.hp / 10);
			}
			else if (enemy.unitID == 11)
			{
				var rand = new FlxRandom();
				if (rand.int(0, 2) == 0)
				{
					affectedUnits[enemy] = 0;
				}
			}
			enemy.takeDamage(affectedUnits[enemy]);
			if (attacker.unitID == 13)
			{ // duelist heal 33% damage dealt
				attacker.heal(Std.int(affectedUnits[enemy] / 3));
				var coords = unitStates.get(attacker).getCoor();
				var coorToHeal = [coords];
				grid.heal(coorToHeal);
			}
			// if this unit is killed
			if (enemy.currStats.hp <= 0)
			{
				dead.push(enemy);
			}
		}
		return dead;
	}

	// for assassin and rogue
	public static function moveWithAbilities(unitMoved:UnitBattleState, grid:BattleGrid, unitStates:Map<Unit, UnitBattleState>, eneU:Array<Unit>)
	{
		if (unitMoved.unit.unitID == 6)
		{ // rogue: Teleports behind the weakest enemy unit at the start of battle
			var weakestUnit = eneU[0];
			for (target in eneU)
			{
				var coor = unitStates[target].getCoor();
				if (target.currStats.hp < weakestUnit.currStats.hp && findEmptySlotNext(coor, grid, unitMoved.unit.enemy) != null)
				{
					weakestUnit = target;
				}
			}
			var destPt = findEmptySlotNext(unitStates[weakestUnit].getCoor(), grid, unitMoved.unit.enemy);

			// move unitMoved to destPt;
			grid.teleportUnit(unitMoved.getCoor().x, unitMoved.getCoor().y, destPt.x, destPt.y);
			unitMoved.updateCoor(destPt);
			return true;
		}
		return false;
	}

	private static function findEmptySlotNext(curr:Point, grid:BattleGrid, enemy:Bool)
	{
		var p1 = new Point(curr.x, curr.y + 1);
		var p2 = new Point(curr.x, curr.y - 1);
		var p3 = new Point(curr.x + 1, curr.y);
		var p4 = new Point(curr.x - 1, curr.y);
		var options = new Array<Point>();
		if (enemy)
		{
			options.push(p1);
			options.push(p2);
			options.push(p3);
			options.push(p4);
		}
		else
		{
			options.push(p2);
			options.push(p3);
			options.push(p4);
			options.push(p1);
		}
		for (p in options)
		{
			if (grid.unitGrid[p.x][p.y] == null)
			{
				return p;
			}
		}
		return null;
	}

	// buffs/abilities that are to be called if any unit is killed
	public static function deathBuffs(dead:Array<Unit>, unitStates:Map<Unit, UnitBattleState>, grid:BattleGrid)
	{
		// death buff
		if (dead.length == 0)
		{
			return;
		}
		for (unit in unitStates.keys())
		{
			if (unit.unitID == 10)
			{ // Bloodmancer/Slayer
				if (dead[0].enemy == unit.enemy)
				{
					unit.maxHp += 75 * dead.length;
					unit.heal(75 * dead.length);
				}
				else
				{
					unit.currStats.addStat(new Stats(0, 40 * dead.length, 0, 0, 0, 0));
				}
			}
			else if (unit.unitID == 25)
			{ // slime
				for (d in dead)
				{
					if (d.unitID == unit.unitID)
					{
						unit.maxHp += d.maxHp;
						unit.heal(unit.maxHp);
						unit.currStats.addStat(new Stats(0, d.currStats.atk, 0, 0, 0, 0));
						var coorToHeal = [unitStates.get(unit).getCoor()];
						grid.heal(coorToHeal);
					}
				}
			}
		}
	}

	// buffs/abilities to be called after an attack
	public static function postAttack(attacker:UnitBattleState)
	{
		if (attacker.unit.unitID == 26)
		{ // champion
			// increases max hp by 50 and att by 25
			attacker.unit.maxHp += 50;
			// also heal 50
			attacker.unit.heal(50 * 2);
			attacker.unit.currStats.addStat(new Stats(0, 25, 0, 0, 0, 0));
			// after every 3rd attack increases move by 1
			if (attacker.numAttDone % 3 == 0)
			{
				attacker.unit.currStats.addStat(new Stats(0, 0, 0, 0, 1, 0));
			}
		}
	}

	// find all enemies that are affected by the aoe
	private static function aoeRoundTargets(affectedUnits:Map<Unit, Int>, origin:Point, range:Int, damage:Int, side:Bool, grid:BattleGrid)
	{
		var affectedArea = BattleCalculator.findReachablePlace(grid.unitGrid, origin, range, true);
		for (pt in affectedArea)
		{
			if (pt.x == origin.x && pt.y == origin.y)
			{
				continue;
			}
			if (grid.unitGrid[pt.x][pt.y] != null && grid.unitGrid[pt.x][pt.y].enemy != side)
			{
				affectedUnits[grid.unitGrid[pt.x][pt.y]] = damage;
			}
		}
	}

	// for ranger, need to be reworked
	private static function aoeColumnAttack(affectedUnits:Map<Unit, Int>, origin:Point, target:Point, damage:Int, side:Bool, grid:BattleGrid) {}

	// find first enemy in each column
	private static function firstColoumn(affectedUnits:Map<Unit, Int>, damage:Int, grid:BattleGrid, side:Bool)
	{
		for (col in grid.unitGrid)
		{
			for (unit in col)
			{
				if (unit != null && unit.enemy != side)
				{
					affectedUnits[unit] = damage;
					break;
				}
			}
		}
	}
}
