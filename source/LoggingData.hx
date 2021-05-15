import entities.Unit;
import entities.Weapon;
import haxe.ds.Vector;

class LoggingData
{
	/* Action log aid descriptors 
		1 -- UNIT MERGE --
		2 -- UNIT PURCHASE --
		3 -- UNIT SALE --
		4 -- WEAPON SALE -- 
	 */
	private var units:Array<String>;
	private var weapons:Array<String>;
	private var win:Bool;
	private var placement:Array<Dynamic>;
	private var player:PlayerState;
	private var numOfUnequipWeap:Map<Int, Int>;

	public function new(player:PlayerState)
	{
		this.player = player;
	}

	public function updateData(win:Bool)
	{
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
		placement = new Array<Dynamic>();
		for (i in 0...8)
		{
			for (j in 0...8)
			{
				if (grid[i][j] != null && !grid[i][j].enemy)
				{
					var unit = grid[i][j];
					var data = {
						unitID: unit.unitID,
						x: i,
						y: j
					};
					placement.push(data);
				}
			}
		}
	}

	public function outputJSON()
	{
		return {
			units: this.units,
			weapons: this.weapons,
			won: this.win,
			placement: this.placement,
			number_of_unequiped: numOfUnequipWeap
		}
	}
}
