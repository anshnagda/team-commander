package states;

import attachingMechanism.Snappable;
import entities.*;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.*;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.*;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxSort;
import haxe.Constraints.Function;
import js.lib.Uint8Array;
import rewardCards.WeaponCard;

class BenchAndInventoryState extends FlxState
{
	var playerState:PlayerState;
	var endLevelCallback:Function;

	public function new(playerState:PlayerState, endLevelCallback:Function)
	{
		super();
		this.endLevelCallback = endLevelCallback;
		this.playerState = playerState;
	}

	override public function create()
	{
		super.create();
		// playerState.battle_grid.disable(); // if battlegrid has some leftover units, detach them and deactivate the grid
		playerState.enableEverything();
		// draw bench and inventory
		add(playerState.bench);
		add(playerState.inventory);

		// get all allied weapons and units from playerState
		// also snap all the unattached units and weapons to the bench and inventory
		add(playerState.allied_units);

		for (allied_unit_ in playerState.allied_units.members)
		{
			var allied_unit = cast(allied_unit_, Unit);

			makeUnitsHB(allied_unit);

			FlxMouseEventManager.add(allied_unit, allied_unit.mouseDown, allied_unit.mouseUp, allied_unit.mouseOver, allied_unit.mouseOut);
		}

		add(playerState.weapons);

		for (weapon_ in playerState.weapons.members)
		{
			var weapon = cast(weapon_, Weapon);

			// Enable hover functionality
			weapon.showHover = function()
			{
				this.addHover(weapon.hover);
			}
			weapon.hideHover = function()
			{
				this.removeHover(weapon.hover);
			}

			weapon.enable();
			// Add weapons to the inventory
			if (!weapon.attached)
			{
				weapon.x = playerState.inventory.x;
				weapon.y = playerState.inventory.y;
			}
			weapon.force_attach(playerState.closestInventoryCoords); // any unattached weapons should go to the inventory
			FlxMouseEventManager.add(weapon, weapon.mouseDown, weapon.mouseUp, weapon.mouseOver, weapon.mouseOut);
		}
	}

	public function makeUnitsHB(allied_unit:Unit)
	{
		add(allied_unit.healthBar);
		allied_unit.reset(allied_unit.x, allied_unit.y);
		allied_unit.updateStats();
		// Enable hover functionality
		allied_unit.showHover = function()
		{
			this.addHover(allied_unit.hover);
		}
		allied_unit.hideHover = function()
		{
			this.removeHover(allied_unit.hover);
		}

		// Add units to the bench
		allied_unit.enable();
		allied_unit.x = 0;
		allied_unit.y = 400;
		allied_unit.force_attach(playerState.closestBenchSlotCoords); // any unattached units should go to the bench
	}

	public function removeAll()
	{
		remove(playerState.allied_units);
		for (allied_unit_ in playerState.allied_units)
		{
			var allied_unit = cast(allied_unit_, Unit);
			remove(allied_unit.healthBar);
			if (allied_unit.hideHover != null)
			{
				allied_unit.hideHover();
			}
			allied_unit.hoverShown = false;
			allied_unit.isBeingHovered = false;
		}

		for (weap in playerState.weapons)
		{
			var weapon = cast(weap, Weapon);
			if (weapon.hideHover != null)
			{
				weapon.hideHover();
			}
			weapon.hoverShown = false;
			weapon.isBeingHovered = false;
		}
		remove(playerState.weapons);

		remove(playerState.bench);
		remove(playerState.inventory);
	}

	public function addHover(hover:HoverText)
	{
		this.add(hover);
		this.add(hover.getTexts());
	}

	public function removeHover(hover:HoverText)
	{
		this.remove(hover);
		this.remove(hover.getTexts());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// update weapon and unit groups in playerState so that the weapon/unit that is currently being clicked appears on the top
		playerState.allied_units.sort(snappable_order, FlxSort.ASCENDING);
		playerState.weapons.sort(snappable_order, FlxSort.ASCENDING);
	}

	function endLevel(res:Bool)
	{
		removeAll();
		endLevelCallback(res, this);
	}

	function snappable_order(order:Int, basic1:FlxBasic, basic2:FlxBasic)
	{
		var snappable1 = cast(basic1, Snappable);
		var snappable2 = cast(basic2, Snappable);
		return FlxSort.byValues(order, snappable1.rendering_order(), snappable2.rendering_order());
	}
}
