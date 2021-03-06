import entities.Unit;
import entities.Weapon;
import haxe.ds.Vector;

class LoggingData
{
	// let me merge bastards
	/* Action log aid descriptors 
		1 -- UNIT MERGE --
		2 -- UNIT PURCHASE --
		3 -- UNIT SALE --
		4 -- WEAPON SALE --
		6 -- BATTLE W/O UNITS -- 
		7 -- BATTLE --
		11 -- TUTORIAL CLICK --
		21 -- SLOT ATTACH -- 
		22 -- SLOT DETACH --  
		100 -> click on Start
		200 -> click on load
		300 -> click on setting
		101 -> new game for player that cleared once
		102 -> skip stage 1
	 */
	private var units:Array<String>;
	private var weapons:Array<String>;
	private var win:Bool;
	private var friePlacement:Array<Dynamic>;
	private var enePlacement:Array<Dynamic>;
	private var player:PlayerState;
	private var numOfUnequipWeap:Map<Int, Int>;

	public function new(player:PlayerState)
	{
		this.player = player;
	}

	public function updateData(win:Bool)
	{
		if (Main.DEV_ENABLED)
		{
			return;
		}
		// update units
		units = new Array<String>();
		for (unit_ in player.allied_units)
		{
			var unit = cast(unit_, Unit);
			units.push(unit.unitName);
		}

		weapons = new Array<String>();
		numOfUnequipWeap = new Map<Int, Int>();
		for (weapon_ in player.weapons)
		{
			var weapon = cast(weapon_, Weapon);
			weapons.push(weapon.weaponName);
			if (weapon.slot.owner == null)
			{
				if (numOfUnequipWeap[weapon.rarity] == null)
				{
					numOfUnequipWeap[weapon.rarity] = 0;
				}
				numOfUnequipWeap[weapon.rarity]++;
			}
		}

		this.win = win;
	}

	public function recordPlacement(grid:Vector<Vector<Unit>>)
	{
		if (Main.DEV_ENABLED)
		{
			return;
		}
		friePlacement = new Array<Dynamic>();
		enePlacement = new Array<Dynamic>();
		for (i in 0...8)
		{
			for (j in 0...8)
			{
				if (grid[i][j] != null)
				{
					var unit = grid[i][j];
					var data = {
						unitID: unit.unitID,
						unitName: unit.unitName,
						x: i,
						y: j
					};
					if (!unit.enemy)
					{
						friePlacement.push(data);
					}
					else
					{
						enePlacement.push(data);
					}
				}
			}
		}
	}

	public function outputJSON()
	{
		return {
			version: this.player.versionPlayed,
			winMult: this.player.winMult,
			loseMult: this.player.loseMult,
			units: this.units,
			weapons: this.weapons,
			number_of_losses: this.player.numberOfLosses,
			won: this.win,
			friePlacement: this.friePlacement,
			enePlacement: this.enePlacement,
			number_of_unequiped: numOfUnequipWeap,
			lives_remaining: player.livesRemaining,
			runID: player.runID
		}
	}
}
