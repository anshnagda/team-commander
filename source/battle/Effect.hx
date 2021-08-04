package battle;

import entities.Unit;
import flixel.math.FlxRandom;
import grids.BattleGrid;
import lime.utils.PackedAssetLibrary;
import nape.geom.AABB;
import staticData.Buff;
import staticData.WeaponData;

// This class applies effect on units during battle
// Static function call
class Effect
{
	// abilities to be called at the start of battle
	public static function startOfBattle(unitStates:Map<Unit, UnitBattleState>)
	{
		for (unit in unitStates.keys())
		{
			if (unitStates[unit].weapon1 == WeaponData.weaponIDs.get("bone ward")
				|| unitStates[unit].weapon2 == WeaponData.weaponIDs.get("bone ward"))
			{ // bone ward skill
				for (tar in unitStates.keys())
				{
					if (tar.enemy == unit.enemy)
					{
						tar.addShield(200);
					}
				}
			}
		}
	}

	public static function attackWithAbilities(effID:Int, attacker:UnitBattleState, victim:UnitBattleState, eneU:Array<Unit>, grid:BattleGrid,
			unitStates:Map<Unit, UnitBattleState>)
	{
		var affectedUnits:Map<Unit, BattleDamage> = new Map<Unit, BattleDamage>();
		var finalDamage = attacker.unit.currStats.atk;
		// crit damage
		if (percentageChance(attacker.unit.currStats.crit))
		{
			finalDamage = Std.int(finalDamage * 1.5);
		}
		// attack phase
		switch attacker.unit.unitID
		{
			case 5: // sniper: Every 3rd Attack deals (1.75x) damage
				if ((attacker.numAttDone + 1) % 3 == 0)
				{
					finalDamage = Math.round(finalDamage * 1.75);
				}
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);

			case 7: // warlock: Also deals (50%) dmg to all enemies within 1 block of target
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);
				aoeRoundTargets(affectedUnits, victim.getCoor(), 1, Std.int(finalDamage / 2), attacker.unit.enemy, grid);

			case 15: // artillery: every 3rd attack deals (2x) damage
				// fires a projectile to a random unit
				if ((attacker.numAttDone + 1) % 3 == 0)
				{
					finalDamage = Math.round(finalDamage * 2.5);
				}
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);

				// second ability
				var rand = new FlxRandom();
				var victim2 = eneU[rand.int(0, eneU.length - 1)];
				affectedUnits[victim2] = affectedUnits[victim.unit] = new BattleDamage(Std.int((0.5 + Math.max((attacker.unit.currStats.atk - 450) / 100,
					0)) * finalDamage));

			case 17: // archmage: all enemies within 3x3 blocks receive 100% atk
				// reduces these enemies' atk by 25% and move by 1
				// 1st aoe damage
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);
				squareAOE(affectedUnits, victim.getCoor(), 3, 3, finalDamage, grid, victim.unit.enemy);

				// apply debuff: 25% damage reduction + -1 move
				for (ene in affectedUnits.keys())
				{
					unitStates.get(ene).applyBuff(Buff.DEBUFFS[0](ene), 2);
				}

			case 24: // All-Seeing Eye
				firstColoumn(affectedUnits, finalDamage, grid, attacker.unit.enemy);

			case 31: // wind spirit
				affectedUnits.remove(victim.unit);
				if (attacker.turnCompleted % 2 == 0)
				{
					aoeRoundTargets(affectedUnits, attacker.getCoor(), 3, Math.round(attacker.unit.currStats.atk / 2), attacker.unit.enemy, grid);
				}
				else
				{
					// find furthest unit
					var furthest = furthest(attacker.getCoor(), eneU, unitStates);
					if (affectedUnits[furthest] == null)
					{
						affectedUnits[furthest] = new BattleDamage();
					}
					affectedUnits[furthest].normDamage += Math.round(1.5 * attacker.unit.currStats.atk);
				}

			case 34: // Fire Elemental
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);
				for (unit in eneU)
				{
					if (unitStates[unit].bomb)
					{
						var currRound = new Map<Unit, BattleDamage>();
						squareAOE(currRound, unitStates[unit].getCoor(), 3, 3, 0, grid, victim.unit.enemy);
						if (currRound[unit] == null)
						{
							currRound[unit] = new BattleDamage();
						}
						// 25% of current health
						for (tar in currRound.keys())
						{
							currRound[tar].trueDamage += Math.round(tar.maxHp * 0.13);
							grid.archmage_attack(unitStates[tar].getCoor());
							if (affectedUnits[tar] == null)
							{
								affectedUnits[tar] = new BattleDamage(0, currRound[tar].trueDamage);
							}
							else
							{
								affectedUnits[tar].trueDamage += currRound[tar].trueDamage;
							}
						}
					}
					else
					{
						unitStates[unit].bomb = true;
					}
				}

			case 37: // overlord
				if ((attacker.turnCompleted + 1) % 2 == 0)
				{
					firstColoumn(affectedUnits, finalDamage, grid, attacker.unit.enemy);
				}
				else
				{
					affectedUnits[victim.unit] = new BattleDamage(finalDamage);
				}

			case 38: // withering soul
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);
				victim.applyBuff(new Stats(0, Math.round(-victim.unit.currStats.atk / 4), 0, -1, -1, 0), 1);

			default:
				affectedUnits[victim.unit] = new BattleDamage(finalDamage);
		}
		weapAtt(attacker.weapon1, attacker, affectedUnits, grid, unitStates);
		weapAtt(attacker.weapon2, attacker, affectedUnits, grid, unitStates);
		grid.attack(attacker.getCoor(), victim.getCoor(), attacker, affectedUnits);
		return affectedUnits;
	}

	private static function weapAtt(weap:Int, attacker:UnitBattleState, unitsAffected:Map<Unit, BattleDamage>, grid:BattleGrid,
			unitStates:Map<Unit, UnitBattleState>)
	{
		if (weap == WeaponData.weaponIDs.get("dragonslayer"))
		{
			for (unit in unitsAffected.keys())
			{
				unitsAffected[unit].trueDamage += Math.round(unit.currStats.hp * 0.1);
			}
		}
		else if (weap == WeaponData.weaponIDs.get("mugen cap"))
		{
			var unitsAttacked = new Array<Unit>();
			for (unit in unitsAffected.keys())
			{
				unitsAttacked.push(unit);
			}
			for (unit in unitsAttacked)
			{
				unitStates[unit].mugenCap++;
				if (unitStates[unit].mugenCap != 0 && unitStates[unit].mugenCap % 2 == 0)
				{
					unitsAffected[unit].normDamage += Math.round(unit.maxHp * 0.13);
					aoeRoundTargets(unitsAffected, unitStates[unit].getCoor(), 1, Math.round(unit.maxHp * 0.1), attacker.unit.enemy, grid);
					grid.warlock_attack(unitStates[unit].getCoor());
				}
			}
		}
		else if (weap == WeaponData.weaponIDs.get("sword of ruin"))
		{
			for (unit in unitsAffected.keys())
			{
				if (!unitStates[unit].sor)
				{
					unitStates[unit].sor = true;
					unitStates[unit].freeze += 1;
				}
			}
		}
	}

	// apply buff accordingly
	public static function buffPhase(attacker:UnitBattleState, unitStates:Map<Unit, UnitBattleState>, grid:BattleGrid, battleCalc:BattleCalculator)
	{
		var buffed = false;
		// buff phase
		// check weapon abilities
		buffed = buffed || weaponBUFF(attacker, attacker.weapon1, unitStates, grid);
		buffed = buffed || weaponBUFF(attacker, attacker.weapon2, unitStates, grid);
		switch attacker.unit.unitID
		{
			case 8: // bard increase allies damage
				// find buff affected units
				var buffedUnits = new Map<Unit, BattleDamage>();
				aoeRoundTargets(buffedUnits, attacker.getCoor(), 3, 0, !attacker.unit.enemy, grid);
				// apply buff to affected Units
				for (unit in buffedUnits.keys())
				{
					unitStates[unit].applyBuff(Buff.BUFFS[0](attacker.unit), 1);
					grid.buff([unitStates[unit].getCoor()]);
				}
				buffed = true;

			case 9: // cleric heal 25% of cleric's current health
				aoeHeal(attacker, unitStates, grid, Std.int(attacker.unit.currStats.hp * 0.25), 2);
				buffed = true;

			case 18: // Laureate: bard's buff + range + 1 and move + 1
				var buffedUnits = new Map<Unit, BattleDamage>();
				aoeRoundTargets(buffedUnits, attacker.getCoor(), 3, 0, !attacker.unit.enemy, grid);
				// apply buff to affected Units
				for (unit in buffedUnits.keys())
				{
					unitStates[unit].applyBuff(Buff.BUFFS[1](attacker.unit), 1);
					grid.buff([unitStates[unit].getCoor()]);
				}
				buffed = true;

			case 19: // Exarch: Every 2 turns heals all allies and me within 2 spaces
				// Add a 15% of currHP shield
				aoeHeal(attacker, unitStates, grid, Std.int(attacker.unit.currStats.hp * 0.3), 3);

				// apply shield, need to consult unit designer
				buffed = true;

			case 28: // pawn
				var currPt = unitStates[attacker.unit].getCoor();
				// if reaches the end of the board
				if (currPt.y == 7)
				{
					grid.killUnit(unitStates[attacker.unit].coor.x, unitStates[attacker.unit].coor.y);
					battleCalc.removeEneU(attacker.unit);

					// summon queen
					var queen = grid.summon_queen(currPt);
					unitStates[queen] = new UnitBattleState(currPt, queen);
					battleCalc.addEneU(queen);
					buffed = true;
				}

			case 32: // mother ship
				if (attacker.turnCompleted % 2 == 0)
				{
					// summon alien
					// 1. find all possible places
					var possiblePlaces = squareEmptyCoors(attacker.getCoor(), 3, 3, grid, 1);
					for (pt in possiblePlaces)
					{
						var alien = grid.summon_alien(pt);
						unitStates[alien] = new UnitBattleState(pt, alien);
						battleCalc.addEneU(alien);
					}
				}
				buffed = true;

			case 34: // Ashen one
				if (attacker.turnCompleted == 0)
				{
					// implant bombs
					for (unit in unitStates.keys())
					{
						if (unit.enemy != attacker.unit.enemy)
						{
							unitStates[unit].bomb = true;
						}
					}
				}

				// add stats
				var firePresent = false;
				for (unit in unitStates.keys())
				{
					if (unit.unitID == 35)
					{
						firePresent = true;
						break;
					}
				}

				if (!firePresent)
				{
					attacker.unit.currStats.eva = 0;
					attacker.applyBuff(new Stats(0, attacker.unit.baseStats.atk, 0, 0, 0, 0), 1);
				}

			case 36: // joker
				Buff.joker(attacker);
				buffed = true;
				grid.buff([attacker.getCoor()]);

			case 37: // overlord
				if ((attacker.turnCompleted + 1) % 2 == 1)
				{
					trace("Summon withering");
					var possiblePlaces = squareEmptyCoors(attacker.getCoor(), 5, 5, grid, 2);
					trace(possiblePlaces);
					for (pt in possiblePlaces)
					{
						var withering = grid.summon_withering(pt);
						unitStates[withering] = new UnitBattleState(pt, withering);
						battleCalc.addEneU(withering);
					}
				}

			case 39: // exalted one, summon copies
				trace(attacker.turnCompleted);
				if ((attacker.turnCompleted + 1) % 3 == 0)
				{
					var possiblePlaces = squareEmptyCoors(attacker.getCoor(), 5, 5, grid, 1);
					for (pt in possiblePlaces)
					{
						var withering = grid.summon_exalted_copy(Math.round(attacker.unit.currStats.hp / 2), pt);
						unitStates[withering] = new UnitBattleState(pt, withering);
						battleCalc.addEneU(withering);
					}
				}
		}
		return buffed;
	}

	// apply weapon buff
	private static function weaponBUFF(attacker:UnitBattleState, weap:Int, unitStates:Map<Unit, UnitBattleState>, grid:BattleGrid)
	{
		if (weap == WeaponData.weaponIDs.get("exalted staff"))
		{
			var affectedAlly = new Map<Unit, BattleDamage>();
			affectedAlly[attacker.unit] = new BattleDamage();
			aoeRoundTargets(affectedAlly, attacker.getCoor(), 2, 0, !attacker.unit.enemy, grid);
			var coorToHeal = new Array<Point>();
			for (unit in affectedAlly.keys())
			{
				unit.heal(Math.round(unit.maxHp * 0.15));
				coorToHeal.push(unitStates[unit].getCoor());
				unitStates[unit].applyBuff(new Stats(0, 0, 0, 0, 1, 0), 2);
			}
			grid.heal(coorToHeal);
			return true;
		}
		return false;
	}

	// does damage calculation, apply damage, and update health
	public static function damageCalc(affectedUnits:Map<Unit, BattleDamage>, unitStates:Map<Unit, UnitBattleState>, attacker:Unit, grid:BattleGrid)
	{
		var dead = new Array<Unit>();

		// check if there's a paragon to abosrt damage
		// check if it is a pawn and has a king to absorb damage
		for (enemy in affectedUnits.keys())
		{
			if (enemy.unitID == 28)
			{ // ask King to absorb damage
				var unitsNextToMe = new Map<Unit, BattleDamage>();
				aoeRoundTargets(unitsNextToMe, unitStates.get(enemy).getCoor(), 2, 0, !enemy.enemy, grid);
				for (ally in unitsNextToMe.keys())
				{
					if (ally.unitID == 29)
					{
						ally.takeDamage(affectedUnits[enemy].normDamage + affectedUnits[enemy].trueDamage);
						affectedUnits[enemy].normDamage = 0;
						affectedUnits[enemy].trueDamage = 0;
					}
				}
				continue;
			}
			var unitsNextToMe = new Map<Unit, BattleDamage>();
			aoeRoundTargets(unitsNextToMe, unitStates.get(enemy).getCoor(), 1, 0, !enemy.enemy, grid);
			for (ally in unitsNextToMe.keys())
			{
				if (ally.unitID == 14)
				{ // damage reduction
					affectedUnits[enemy].normDamage = Std.int(affectedUnits[enemy].normDamage * 0.75);
				}
			}
		}

		// damage calculation phase
		for (enemy in affectedUnits.keys())
		{
			if (unitStates.get(enemy).invinsible)
			{
				affectedUnits[enemy].normDamage = 0;
				affectedUnits[enemy].trueDamage = 0;
			}

			// calculate damage reduction
			affectedUnits[enemy].normDamage = Math.round(Math.max(0,
				affectedUnits[enemy].normDamage - Math.round(enemy.maxHp * (enemy.currStats.damageReductionMaxHp / 100.0))));
			affectedUnits[enemy].normDamage = Math.round(affectedUnits[enemy].normDamage * (1.0 - enemy.currStats.damageReduction / 100.0));

			if (enemy.currStats.eva > 0)
			{
				if (percentageChance(enemy.currStats.eva))
				{ // tempest and ranger ability
					affectedUnits[enemy].trueDamage = 0;
					affectedUnits[enemy].normDamage = 0;
					if (enemy.unitID == 21)
					{
						enemy.heal(125);
						grid.heal([unitStates.get(enemy).getCoor()]);
					}
					else if (enemy.unitID == 11)
					{
						enemy.heal(75);
						grid.heal([unitStates.get(enemy).getCoor()]);
					}
				}
			}
			var damageDealt = affectedUnits[enemy].normDamage + affectedUnits[enemy].trueDamage;
			enemy.takeDamage(damageDealt);
			attacker.heal(Math.round(attacker.currStats.lifeSteal / 100 * damageDealt)); // lifesteal
			if (attacker.currStats.lifeSteal > 0 && damageDealt > 0)
			{
				grid.heal([unitStates[attacker].getCoor()]);
			}
			// if damage > 0 and the attacker is tempest
			if (damageDealt > 0 && (attacker.unitID == 21 || attacker.currStats.pushbackPerAtt > 0))
			{
				// move the enemy
				var destPt = pushBack(unitStates[attacker].coor, unitStates[enemy].coor, attacker.currStats.pushbackPerAtt, grid);
				if (destPt != null && (destPt.x != unitStates[enemy].getCoor().x || destPt.y != unitStates[enemy].getCoor().y))
				{
					grid.moveUnit(unitStates[enemy].coor.x, unitStates[enemy].coor.y, destPt.x, destPt.y);
					unitStates[enemy].updateCoor(destPt);
				}
			}

			// if this unit is killed
			if (enemy.currStats.hp <= 0 && !unitStates[enemy].invinsible)
			{
				if (enemy.unitID == 23 && unitStates.get(enemy).firstTimeDie)
				{ // if it is Valkyrie, stay alive with 0 hp and invulnerable
					Buff.BUFFS[2](unitStates.get(enemy), 2);
					trace(unitStates.get(enemy).invinsibleTurn);
					unitStates.get(enemy).firstTimeDie = false;
				}
				else
				{
					dead.push(enemy);
				}
			}
		}
		return dead;
	}

	// for any units that have special move abilities
	public static function moveWithAbilities(unitMoved:UnitBattleState, grid:BattleGrid, unitStates:Map<Unit, UnitBattleState>, eneU:Array<Unit>)
	{
		if ((unitMoved.unit.unitID == 6 || unitMoved.unit.unitID == 16) && unitMoved.turnCompleted == 0)
		{ // rogue and assassin: Teleports behind the weakest enemy unit at the start of battle
			var hittableUnits = new Array<Unit>();
			for (target in eneU)
			{
				var coor = unitStates[target].getCoor();
				if (findEmptySlotNext(coor, grid, unitMoved.unit.enemy) != null)
				{
					hittableUnits.push(target);
				}
			}
			var weakestUnit = hittableUnits[0];
			for (target in hittableUnits)
			{
				if (target.currStats.hp < weakestUnit.currStats.hp)
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
		else if (unitMoved.unit.unitID == 28)
		{ // pawned
			var max = 2;
			var target:Point = null;
			for (i in 1...max + 1)
			{
				var nextPt = new Point(unitMoved.getCoor().x, unitMoved.getCoor().y + i);
				if (grid.unitGrid[nextPt.x][nextPt.y] != null)
				{
					break;
				}
				else
				{
					target = nextPt;
				}
			}
			if (target != null)
			{
				grid.moveUnit(unitMoved.getCoor().x, unitMoved.getCoor().y, target.x, target.y);
				unitMoved.updateCoor(target);
				return true;
			}
		}
		else if (unitMoved.unit.unitID == 36)
		{
			var destPt = randomEmptySpot(grid);
			grid.teleportUnit(unitMoved.getCoor().x, unitMoved.getCoor().y, destPt.x, destPt.y);
			unitMoved.updateCoor(destPt);
		}
		return false;
	}

	private static function randomEmptySpot(grid:BattleGrid)
	{
		var dest:Point = null;
		var r = new FlxRandom();
		while (dest == null)
		{
			var x = r.int(0, 7);
			var y = r.int(0, 7);
			if (grid.unitGrid[x][y] == null)
			{
				dest = new Point(x, y);
			}
		}
		return dest;
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
	public static function deathBuffs(dead:Array<Unit>, unitStates:Map<Unit, UnitBattleState>, grid:BattleGrid, cal:BattleCalculator)
	{
		// death buff
		if (dead.length == 0)
		{
			return;
		}
		for (unit in unitStates.keys())
		{
			if (unit.unitID == 10 || unit.unitID == 20)
			{ // Bloodmancer/Slayer
				if (dead[0].enemy == unit.enemy)
				{
					unit.maxHp += 75 * dead.length;
					unit.heal(75 * dead.length);
				}
				else
				{
					unit.currStats.addStat(Buff.BUFFS[3](dead.length));
				}
			}
			else if (unit.unitID == 25)
			{ // slime
				for (d in dead)
				{
					if (d.unitID == unit.unitID)
					{
						Buff.BUFFS[4](unit, d);
						var coorToHeal = [unitStates.get(unit).getCoor()];
						grid.heal(coorToHeal);
					}
				}
			}
		}

		var overlord = null;

		for (unit in dead)
		{
			if (unit.unitID == 35)
			{ // disable all other bombs
				for (unit in unitStates.keys())
				{
					unitStates[unit].bomb = false;
				}
				break;
			}
			else if (unit.unitID == 37) // overlord turn into exalted
			{
				var coor = unitStates[unit].getCoor();
				cal.removeEneU(unit);
				overlord = unit;

				var exalted = grid.summon_exalted(coor);
				cal.addEneU(exalted);
				unitStates[exalted] = new UnitBattleState(coor, exalted);
				unitStates.remove(unit);
			}
		}
		if (overlord != null)
		{
			dead.remove(overlord);
		}
	}

	// buffs/abilities to be called after an attack
	public static function postAttack(attacker:UnitBattleState, grid:BattleGrid)
	{
		if (attacker.unit.unitID == 26)
		{ // champion
			// increases max hp by 50 and att by 25
			Buff.BUFFS[5](attacker, grid);
		}
	}

	// find all enemies that are affected by the aoe
	private static function aoeRoundTargets(affectedUnits:Map<Unit, BattleDamage>, origin:Point, range:Int, damage:Int, side:Bool, grid:BattleGrid,
			trueDamage:Int = 0)
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
				if (affectedUnits[grid.unitGrid[pt.x][pt.y]] == null)
				{
					affectedUnits[grid.unitGrid[pt.x][pt.y]] = new BattleDamage();
				}
				affectedUnits[grid.unitGrid[pt.x][pt.y]].normDamage += damage;
				affectedUnits[grid.unitGrid[pt.x][pt.y]].trueDamage += trueDamage;
			}
		}
	}

	// find first enemy in each column
	private static function firstColoumn(affectedUnits:Map<Unit, BattleDamage>, damage:Int, grid:BattleGrid, side:Bool)
	{
		for (col in grid.unitGrid)
		{
			for (unit in col)
			{
				if (unit != null && unit.enemy != side)
				{
					affectedUnits[unit] = new BattleDamage(damage);
					break;
				}
			}
		}
	}

	// find all empty grids within the square of dimension (l * w) with origin to be the center
	private static function squareEmptyCoors(origin:Point, length:Int, width:Int, grid:BattleGrid, max:Int)
	{
		var empty = new Array<Point>();
		var lLimits = Std.int(length / 2);
		var wLimits = Std.int(width / 2);
		for (i in -lLimits...lLimits + 1)
		{
			for (j in -wLimits...wLimits + 1)
			{
				if (i == 0 && j == 0)
				{
					continue;
				}
				var pt = new Point(origin.x + i, origin.y + j);
				if (grid.unitGrid[pt.x][pt.y] == null && !BattleCalculator.contains(empty, pt))
				{
					empty.push(pt);
				}
			}
		}
		var rand = new FlxRandom();
		var result = new Array<Point>();
		for (i in 0...max)
		{
			if (empty.length == 0)
			{
				break;
			}
			var r = empty[rand.int(0, empty.length - 1)];
			result.push(r);
			empty.remove(r);
		}
		return result;
	}

	// find all units affected by a square aoe
	private static function squareAOE(affectedUnits:Map<Unit, BattleDamage>, origin:Point, length:Int, width:Int, damage:Int, grid:BattleGrid, side:Bool,
			trueDamage:Int = 0)
	{
		var visited = new Array<Point>();
		var lLimits = Std.int(length / 2);
		var wLimits = Std.int(width / 2);
		for (i in -lLimits...lLimits + 1)
		{
			for (j in -wLimits...wLimits + 1)
			{
				if (i == 0 && j == 0)
				{
					continue;
				}

				var pt = new Point(origin.x + i, origin.y + j);
				if (BattleCalculator.contains(visited, pt))
				{
					continue;
				}
				else
				{
					visited.push(pt);
				}
				if (grid.unitGrid[pt.x][pt.y] != null && grid.unitGrid[pt.x][pt.y].enemy == side)
				{
					if (affectedUnits[grid.unitGrid[pt.x][pt.y]] == null)
					{
						affectedUnits[grid.unitGrid[pt.x][pt.y]] = new BattleDamage();
					}
					affectedUnits[grid.unitGrid[pt.x][pt.y]].normDamage = damage;
					affectedUnits[grid.unitGrid[pt.x][pt.y]].trueDamage = trueDamage;
				}
			}
		}
	}

	private static function aoeHeal(attacker:UnitBattleState, unitStates:Map<Unit, UnitBattleState>, grid:BattleGrid, amount:Int, range:Int)
	{
		if (attacker.turnCompleted % 2 == 0)
		{
			var buffedUnits = new Map<Unit, BattleDamage>();
			buffedUnits[attacker.unit] = new BattleDamage(amount);
			aoeRoundTargets(buffedUnits, attacker.getCoor(), range, amount, !attacker.unit.enemy, grid);
			var coorToHeal = new Array<Point>();
			for (unit in buffedUnits.keys())
			{
				unit.heal(buffedUnits[unit].normDamage);
				coorToHeal.push(unitStates.get(unit).getCoor());
				// to be implemented
				// heal animation?

				// if exarch apply shield as well
				if (attacker.unit.unitID == 19)
				{
					unit.addShield(Math.round(0.15 * attacker.unit.currStats.hp));
				}
			}
			grid.heal(coorToHeal);
		}
	}

	private static function percentageChance(chance:Int)
	{
		var r = new FlxRandom();
		var cutOff = Math.round(100 * (1 - 1 / (1 + chance / 100)));
		return r.int(1, 100) <= cutOff;
	}

	private static function furthest(location:Point, eneU:Array<Unit>, unitStates:Map<Unit, UnitBattleState>)
	{
		var furthest = eneU[0];
		var maxDist = BattleCalculator.distance(location, unitStates[furthest].getCoor());
		for (ene in eneU)
		{
			if (BattleCalculator.distance(location, unitStates[ene].getCoor()) > maxDist)
			{
				furthest = ene;
				maxDist = BattleCalculator.distance(location, unitStates[ene].getCoor());
			}
		}
		return furthest;
	}

	private static function pushBack(attacker:Point, victim:Point, dist:Int, grid:BattleGrid)
	{
		var xDiff = attacker.x - victim.x;
		var yDiff = attacker.y - victim.y;

		var target = null;

		for (i in 1...dist + 1)
		{
			if (Math.abs(xDiff) > Math.abs(yDiff))
			{
				if (xDiff < 0)
				{
					if (victim.x + i <= 7 && grid.unitGrid[victim.x + i][victim.y] != null)
					{
						break;
					}
					target = new Point(victim.x + i, victim.y);
				}
				else
				{
					if (victim.x - i >= 0 && grid.unitGrid[victim.x - i][victim.y] != null)
					{
						break;
					}
					target = new Point(victim.x - i, victim.y);
				}
			}
			else
			{
				if (yDiff < 0)
				{
					if (victim.y + i <= 7 && grid.unitGrid[victim.x][victim.y + i] != null)
					{
						break;
					}
					target = new Point(victim.x, victim.y + i);
				}
				else
				{
					if (victim.y - i >= 0 && grid.unitGrid[victim.x][victim.y - i] != null)
					{
						break;
					}
					target = new Point(victim.x, victim.y - i);
				}
			}
		}
		trace(target);
		return target;
	}
}
