package states;

import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import entities.Unit;
import entities.Weapon;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import haxe.Timer;
import js.html.NodeList;
import nape.geom.AABB;
import rewardCards.UnitCard;
import rewardCards.WeaponCard;
import staticData.Buttons;
import staticData.Font;
import staticData.UnitData;

class MergeState extends BenchAndInventoryState
{
	var return_button:FlxButtonPlus;
	var open_shop_button:FlxButtonPlus;
	var confirm_merge_button:FlxButtonPlus;
	var adv_confirm_merge_button:FlxButtonPlus;

	var background:FlxSprite;

	var current_pair:{unit1:Unit, unit2:Unit};
	var current_unit:Unit = null;

	var adv_current_pair:{unit1:Unit, unit2:Unit, unit3:Unit};
	var adv_current_unit:Unit = null;

	var error_text:FlxText;
	var adv_error_text:FlxText;

	var merge_ongoing = false;

	public function new(playerState:PlayerState, backToLevel:Function, openShopCallback:Function)
	{
		super(playerState, backToLevel);
		playerState.inMerge = true;
		current_pair = {unit1: null, unit2: null};
		var error_width = playerState.mergeResultSlot.x + 48 - playerState.mergeSlot1.x;
		error_text = Font.makeText(playerState.mergeSlot1.x, playerState.mergeSlot1.y + 80, error_width, "Merge any two basic units!", 32);
		var adv_error_width = error_width + 200;
		adv_error_text = Font.makeText(playerState.advMergeSlot1.x - 100, playerState.advMergeSlot1.y + 80, adv_error_width,
			"Merge 3 identical advanced units!", 32);

		this.open_shop_button = Buttons.makeButton(playerState.inventory.x + 40, 450, 64, 32, function()
		{
			removeAll();
			openShopCallback();
		}, "SHOP", 16);
		this.return_button = Buttons.makeButton(playerState.inventory.x + 40, 400, 64, 32, return_to_level, "RETURN", 16);
		this.confirm_merge_button = Buttons.makeButton(playerState.mergeResultSlot.x + 64, playerState.mergeSlot1.y + 12, 64, 32, confirm_merge, "MERGE!", 16);
		this.adv_confirm_merge_button = Buttons.makeButton(playerState.advMergeResultSlot.x + 64, playerState.advMergeSlot1.y + 12, 64, 32, adv_confirm_merge,
			"MERGE!", 16);
	}

	override public function create()
	{
		// add in background
		background = new FlxSprite(-100, 0);
		background.loadGraphic("assets/images/mergebg.png");
		// background.setGraphicSize(800, 700);
		// background.alpha = 0.7;
		add(background);
		add(playerState.mergeSlot1);
		add(playerState.mergeSlot2);
		add(playerState.mergeResultSlot);

		add(Font.makeText(playerState.mergeSlot1.x, playerState.mergeSlot1.y + 48, 48, "basic", 16));
		add(Font.makeText(playerState.mergeSlot2.x, playerState.mergeSlot2.y + 48, 48, "basic", 16));
		add(Font.makeText(playerState.mergeResultSlot.x - 30, playerState.mergeResultSlot.y + 48, 48 + 60, "advanced", 16));

		var plus_x = playerState.mergeSlot1.x + playerState.mergeSlot1.gridSize;
		add(Font.makeText(plus_x, playerState.mergeSlot1.y, playerState.mergeSlot2.x - plus_x, "+", 64));

		var equals_x = playerState.mergeSlot2.x + playerState.mergeSlot2.gridSize;
		add(Font.makeText(equals_x, playerState.mergeSlot2.y, playerState.mergeResultSlot.x - equals_x, "=", 64));

		playerState.mergeSlot1.slots[0][0].detachCallback = slot_updated;
		playerState.mergeSlot2.slots[0][0].detachCallback = slot_updated;
		playerState.mergeSlot1.slots[0][0].attachCallback = slot_updated;
		playerState.mergeSlot2.slots[0][0].attachCallback = slot_updated;
		add(error_text);

		if (Main.DEV_ENABLED || playerState.current_stage >= 3)
		{
			add(playerState.advMergeSlot1);
			add(playerState.advMergeSlot2);
			add(playerState.advMergeSlot3);
			add(playerState.advMergeResultSlot);

			add(Font.makeText(playerState.advMergeSlot1.x - 30, playerState.advMergeSlot1.y + 48, 48 + 60, "advanced", 16));
			add(Font.makeText(playerState.advMergeSlot2.x - 30, playerState.advMergeSlot2.y + 48, 48 + 60, "advanced", 16));
			add(Font.makeText(playerState.advMergeSlot3.x - 30, playerState.advMergeSlot3.y + 48, 48 + 60, "advanced", 16));
			add(Font.makeText(playerState.advMergeResultSlot.x - 30, playerState.advMergeResultSlot.y + 48, 48 + 60, "master", 16));

			plus_x = playerState.advMergeSlot1.x + playerState.advMergeSlot1.gridSize;
			add(Font.makeText(plus_x, playerState.advMergeSlot1.y, playerState.advMergeSlot2.x - plus_x, "+", 64));

			plus_x = playerState.advMergeSlot2.x + playerState.advMergeSlot2.gridSize;
			add(Font.makeText(plus_x, playerState.advMergeSlot2.y, playerState.advMergeSlot3.x - plus_x, "+", 64));

			var equals_x = playerState.advMergeSlot3.x + playerState.advMergeSlot3.gridSize;
			add(Font.makeText(equals_x, playerState.advMergeSlot3.y, playerState.advMergeResultSlot.x - equals_x, "=", 64));

			playerState.advMergeSlot1.slots[0][0].detachCallback = adv_slot_updated;
			playerState.advMergeSlot2.slots[0][0].detachCallback = adv_slot_updated;
			playerState.advMergeSlot3.slots[0][0].detachCallback = adv_slot_updated;
			playerState.advMergeSlot1.slots[0][0].attachCallback = adv_slot_updated;
			playerState.advMergeSlot2.slots[0][0].attachCallback = adv_slot_updated;
			playerState.advMergeSlot3.slots[0][0].attachCallback = adv_slot_updated;
			add(adv_error_text);
		}

		super.create();

		var currentLevelText = Font.makeText(0, 50, 800, "MERGE YOUR UNITS", 64);

		add(currentLevelText);
		add(return_button);
		if (playerState.current_stage != 1)
		{
			add(open_shop_button);
		}
	}

	function confirm_merge()
	{
		if (current_unit != null)
		{
			current_unit.detach();
			remove(current_unit);
			remove(current_unit.healthBar);
			var new_unit_id = current_unit.unitID;
			FlxMouseEventManager.remove(current_unit);
			current_unit = null;

			var new_unit = new Unit(0, 600, new_unit_id, playerState.closestUnitSlotCoords); // change it so he is attached to bench
			playerState.addUnit(new_unit);

			// log the unit merge
			if (!Main.DEV_ENABLED)
			{
				playerState.log.logLevelAction(1, new_unit.unitName);
			}

			merge_ongoing = true;
			playerState.inMerge = false;
			for (unit in [current_pair.unit1, current_pair.unit2])
			{
				if (unit != null)
				{
					playerState.removeUnit(unit);
					unit.isBeingHovered = false;
					unit.detach();
					unit.hideHover();
					remove(unit);
					remove(unit.healthBar);
					remove(unit.hover);
					if (unit.weaponSlot1.isOccupied)
					{
						unit.weaponSlot1.attachedSnappable.detach();
					}
					if (unit.weaponSlot2.isOccupied)
					{
						unit.weaponSlot2.attachedSnappable.detach();
					}
					unit.disable();
				}
			}
			super.removeAll();
			super.create();
			playerState.inMerge = true;

			error_text.text = "Merge completed!";
			error_text.color = FlxColor.GREEN;
			remove(confirm_merge_button);
			merge_ongoing = false;
		}
	}

	function adv_confirm_merge()
	{
		if (adv_current_unit != null)
		{
			adv_current_unit.detach();
			remove(adv_current_unit);
			remove(adv_current_unit.healthBar);
			var new_unit_id = adv_current_unit.unitID;
			FlxMouseEventManager.remove(adv_current_unit);
			adv_current_unit = null;

			var new_unit = new Unit(0, 600, new_unit_id, playerState.closestUnitSlotCoords); // change it so he is attached to bench
			playerState.addUnit(new_unit);

			// log the unit merge
			if (!Main.DEV_ENABLED)
			{
				playerState.log.logLevelAction(1, new_unit.unitName);
			}

			merge_ongoing = true;
			playerState.inMerge = false;
			for (unit in [adv_current_pair.unit1, adv_current_pair.unit2, adv_current_pair.unit3])
			{
				if (unit != null)
				{
					playerState.removeUnit(unit);
					unit.isBeingHovered = false;
					unit.detach();
					unit.hideHover();
					remove(unit);
					remove(unit.healthBar);
					remove(unit.hover);
					if (unit.weaponSlot1.isOccupied)
					{
						unit.weaponSlot1.attachedSnappable.detach();
					}
					if (unit.weaponSlot2.isOccupied)
					{
						unit.weaponSlot2.attachedSnappable.detach();
					}
					unit.disable();
				}
			}
			super.removeAll();
			super.create();
			playerState.inMerge = true;

			adv_error_text.text = "Merge completed!";
			adv_error_text.color = FlxColor.GREEN;
			remove(adv_confirm_merge_button);
			merge_ongoing = false;
		}
	}

	function slot_updated(snap:Snappable)
	{
		if (merge_ongoing)
		{
			return;
		}
		remove(confirm_merge_button);
		current_pair = {
			unit1: cast(playerState.mergeSlot1.slots[0][0].attachedSnappable, Unit),
			unit2: cast(playerState.mergeSlot2.slots[0][0].attachedSnappable, Unit)
		};
		if (current_pair.unit1 == null || current_pair.unit2 == null)
		{
			if (current_unit != null)
			{
				current_unit.detach();
				remove(current_unit);
				remove(current_unit.healthBar);
				current_unit = null;
			}
			error_text.text = "Merge any two basic units!";
			error_text.color = FlxColor.WHITE;
		}
		else
		{
			// make a new unit
			var merge_result = UnitData.mergeResult(current_pair.unit1.unitID, current_pair.unit2.unitID);
			if (merge_result.unit == null)
			{
				error_text.text = merge_result.error;
				error_text.color = FlxColor.RED;
			}
			else
			{
				error_text.text = "will merge into " + UnitData.unitNames[merge_result.unit].toUpperCase();
				error_text.color = FlxColor.GREEN;
				add(confirm_merge_button);

				current_unit = new Unit(0, 0, merge_result.unit, null);
				current_unit.disable();
				current_unit.reset(current_unit.x, current_unit.y);
				current_unit.resetStats();
				current_unit.detach();
				add(current_unit);
				add(current_unit.healthBar);
				current_unit.showHover = function()
				{
					this.addHover(current_unit.hover);
				}
				current_unit.hideHover = function()
				{
					this.removeHover(current_unit.hover);
				}
				current_unit.force_attach(function()
				{
					return {dist: 0, slot: playerState.mergeResultSlot.slots[0][0]}
				});
				FlxMouseEventManager.add(current_unit, current_unit.mouseDown, current_unit.mouseUp, current_unit.mouseOver, current_unit.mouseOut);
			}
		}
	}

	function adv_slot_updated(snap:Snappable)
	{
		if (merge_ongoing)
		{
			return;
		}
		remove(adv_confirm_merge_button);
		adv_current_pair = {
			unit1: cast(playerState.advMergeSlot1.slots[0][0].attachedSnappable, Unit),
			unit2: cast(playerState.advMergeSlot2.slots[0][0].attachedSnappable, Unit),
			unit3: cast(playerState.advMergeSlot3.slots[0][0].attachedSnappable, Unit)
		};
		if (adv_current_pair.unit1 == null || adv_current_pair.unit2 == null || adv_current_pair.unit3 == null)
		{
			if (adv_current_unit != null)
			{
				adv_current_unit.detach();
				remove(adv_current_unit);
				remove(adv_current_unit.healthBar);
				adv_current_unit = null;
			}
			adv_error_text.text = "Merge 3 identical advanced units!";
			adv_error_text.color = FlxColor.WHITE;
		}
		else
		{
			// make a new unit
			var merge_result = UnitData.mergeResultAdv(adv_current_pair.unit1.unitID, adv_current_pair.unit2.unitID, adv_current_pair.unit3.unitID);
			if (merge_result.unit == null)
			{
				adv_error_text.text = merge_result.error;
				adv_error_text.color = FlxColor.RED;
			}
			else
			{
				adv_error_text.text = "will merge into " + UnitData.unitNames[merge_result.unit].toUpperCase();
				adv_error_text.color = FlxColor.GREEN;
				add(adv_confirm_merge_button);

				adv_current_unit = new Unit(0, 0, merge_result.unit, null);
				adv_current_unit.disable();
				adv_current_unit.reset(adv_current_unit.x, adv_current_unit.y);
				adv_current_unit.resetStats();
				adv_current_unit.detach();
				add(adv_current_unit);
				add(adv_current_unit.healthBar);
				adv_current_unit.showHover = function()
				{
					this.addHover(adv_current_unit.hover);
				}
				adv_current_unit.hideHover = function()
				{
					this.removeHover(adv_current_unit.hover);
				}
				adv_current_unit.force_attach(function()
				{
					return {dist: 0, slot: playerState.advMergeResultSlot.slots[0][0]}
				});
				FlxMouseEventManager.add(adv_current_unit, adv_current_unit.mouseDown, adv_current_unit.mouseUp, adv_current_unit.mouseOver,
					adv_current_unit.mouseOut);
			}
		}
	}

	override function removeAll()
	{
		playerState.inMerge = false;
		if (playerState.mergeSlot1.slots[0][0].isOccupied)
		{
			playerState.mergeSlot1.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.mergeSlot2.slots[0][0].isOccupied)
		{
			playerState.mergeSlot2.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.mergeResultSlot.slots[0][0].isOccupied)
		{
			playerState.mergeResultSlot.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.advMergeSlot1.slots[0][0].isOccupied)
		{
			playerState.advMergeSlot1.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.advMergeSlot2.slots[0][0].isOccupied)
		{
			playerState.advMergeSlot2.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.advMergeSlot3.slots[0][0].isOccupied)
		{
			playerState.advMergeSlot3.slots[0][0].attachedSnappable.detach();
		}
		if (playerState.advMergeResultSlot.slots[0][0].isOccupied)
		{
			playerState.advMergeResultSlot.slots[0][0].attachedSnappable.detach();
		}

		remove(playerState.mergeSlot1);
		remove(playerState.mergeSlot2);
		remove(playerState.mergeResultSlot);
		remove(playerState.advMergeSlot1);
		remove(playerState.advMergeSlot2);
		remove(playerState.advMergeSlot3);
		remove(playerState.advMergeResultSlot);
		super.removeAll();
	}

	function return_to_level()
	{
		removeAll();
		endLevel(true);
	}
}
