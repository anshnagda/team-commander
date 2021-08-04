package states;

import attachingMechanism.Slot;
import entities.HoverText;
import entities.TutorialBox;
import entities.Unit;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import grids.SlotGrid;
import haxe.Constraints.Function;
import js.Browser;
import js.html.Console;
import js.html.FontFaceSetLoadEvent;
import states.*;
import states.TutorialLevelState.LevelStateTutorial;
import staticData.*;

class RecipeState extends FlxSubState
{
	var titleText:FlxText;
	var currentPage:FlxText;
	var nextPageButton:FlxButton;
	var prevPageButton:FlxButton;

	var boundingBox:FlxSprite;
	var backButton:FlxButton;

	var playerState:PlayerState;
	var backCallback:Function;

	var unlocked_adv = new Array<String>();
	var unlocked_master = new Array<String>();
	var unlocked = new Array<String>();

	var numPages:Int = 0;
	var currPage:Int = 0;

	var slots:FlxSpriteGroup = new FlxSpriteGroup();
	var units:FlxSpriteGroup = new FlxSpriteGroup();
	var hovers:FlxSpriteGroup = new FlxSpriteGroup();

	public function new(backCallback:Function, playerState:PlayerState)
	{
		super();
		this.playerState = playerState;
		this.backCallback = backCallback;
		#if js
		for (unitName in UnitData.advancedUnits)
		{
			var temp = StoreData.tryLoad("merge" + Std.string(UnitData.unitIDs.get(unitName)));
			if (temp != null)
			{
				unlocked_adv.push(unitName);
			}
		}
		for (unitName in UnitData.masterUnits)
		{
			var temp = StoreData.tryLoad("merge" + Std.string(UnitData.unitIDs.get(unitName)));
			if (temp != null)
			{
				unlocked_master.push(unitName);
			}
		}
		#end
		unlocked = unlocked_adv.concat(unlocked_master);

		numPages = Math.ceil(unlocked.length / 4);
	}

	override public function create()
	{
		super.create();
		if (numPages == 0)
		{
			backCallback(false);
			return;
		}
		boundingBox = new FlxSprite();
		boundingBox.loadGraphic("assets/images/recipe_window.png");
		boundingBox.scale.set(1.5, 1.5);
		boundingBox.screenCenter();
		add(boundingBox);

		backButton = Buttons.makeImgButton(640, 70, "close", closeRecipe);
		titleText = Font.makeText(boundingBox.x, 60, boundingBox.width, "MERGE RECIPES", 32);

		currentPage = Font.makeText(boundingBox.x, 485, boundingBox.width, Std.string(currPage + 1) + "/" + Std.string(numPages), 24);
		prevPageButton = Buttons.makeImgButton(170, 485, "back", prevPage);
		nextPageButton = Buttons.makeImgButton(600, 485, "forward", nextPage);

		add(currentPage);
		add(backButton);
		add(titleText);
		add(slots);
		add(units);
		add(hovers);

		add(prevPageButton);
		add(nextPageButton);

		updatePage();
	}

	function prevPage()
	{
		if (currPage > 0)
		{
			currPage -= 1;
			updatePage();
		}
	}

	function nextPage()
	{
		if (currPage < numPages - 1)
		{
			currPage += 1;
			updatePage();
		}
	}

	function updatePage()
	{
		var units_to_draw = [];

		var min_idx = currPage * 4;
		var max_idx = Std.int(Math.min(min_idx + 4, unlocked.length));
		for (i in currPage * 4...max_idx)
		{
			units_to_draw.push(unlocked[i]);
		}

		units.clear();
		slots.clear();
		hovers.clear();

		for (i in 0...units_to_draw.length)
		{
			draw_merge_recipe(units_to_draw[i], 100 + i * 100);
		}

		remove(prevPageButton);
		remove(nextPageButton);
		if (currPage > 0)
		{
			add(prevPageButton);
		}
		if (currPage < numPages - 1)
		{
			add(nextPageButton);
		}

		currentPage.text = Std.string(currPage + 1) + "/" + Std.string(numPages);
	}

	function draw_merge_recipe(unit:String, y:Int)
	{
		var merge_ing = UnitData.getMergeIngredients(unit);
		if (merge_ing.length == 2)
		{
			var grid1 = new SlotGrid(1, 1, 48, 220, y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid1.sprites_arr[0][0]);
			create_unit_at_slot(merge_ing[0], grid1);

			var grid2 = new SlotGrid(1, 1, 48, Std.int(grid1.x + 150), y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid2.sprites_arr[0][0]);
			create_unit_at_slot(merge_ing[1], grid2);

			var grid3 = new SlotGrid(1, 1, 48, Std.int(grid2.x + 150), y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid3.sprites_arr[0][0]);
			create_unit_at_slot(unit, grid3);

			var plus_x = grid1.x + grid1.gridSize;
			slots.add(Font.makeText(plus_x, grid1.y, grid2.x - plus_x, "+", 64));

			var equals_x = grid2.x + grid2.gridSize;
			slots.add(Font.makeText(equals_x, grid2.y, grid3.x - equals_x, "=", 64));
		}
		else if (merge_ing.length == 3)
		{
			var grid1 = new SlotGrid(1, 1, 48, 220, y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid1.sprites_arr[0][0]);
			create_unit_at_slot(merge_ing[0], grid1);

			var grid2 = new SlotGrid(1, 1, 48, Std.int(grid1.x + 100), y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid2.sprites_arr[0][0]);
			create_unit_at_slot(merge_ing[1], grid2);

			var grid3 = new SlotGrid(1, 1, 48, Std.int(grid2.x + 100), y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid3.sprites_arr[0][0]);
			create_unit_at_slot(merge_ing[2], grid3);

			var grid4 = new SlotGrid(1, 1, 48, Std.int(grid3.x + 100), y, "assets/images/tiles/board.png", 1.0);
			slots.add(grid4.sprites_arr[0][0]);
			create_unit_at_slot(unit, grid4);

			var plus_x = grid1.x + grid1.gridSize;
			slots.add(Font.makeText(plus_x, grid1.y, grid2.x - plus_x, "+", 64));

			plus_x = grid2.x + grid2.gridSize;
			slots.add(Font.makeText(plus_x, grid2.y, grid3.x - plus_x, "+", 64));

			var equals_x = grid3.x + grid3.gridSize;
			slots.add(Font.makeText(equals_x, grid3.y, grid4.x - equals_x, "=", 64));
		}
	}

	function create_unit_at_slot(unitName:String, slot:SlotGrid)
	{
		var unit = new Unit(0, 0, UnitData.unitIDs.get(unitName), null);
		unit.disable();
		unit.clickable = false;

		units.add(unit);
		unit.attach(slot.slots[0][0]);
		unit.showHover = function()
		{
			this.addHover(unit.hover);
		}
		unit.hideHover = function()
		{
			this.removeHover(unit.hover);
		}
		FlxMouseEventManager.add(unit, unit.mouseDown, unit.mouseUp, unit.mouseOver, unit.mouseOut);
		slots.add(Font.makeText(slot.x - 30, slot.y + 48, 48 + 60, unitName, 16));
	}

	public function addHover(hover:HoverText)
	{
		removeHover(hover);
		hovers.add(hover);
		hovers.add(hover.getTexts());
	}

	public function removeHover(hover:HoverText)
	{
		hovers.remove(hover);
		hovers.remove(hover.getTexts());
	}

	function closeRecipe()
	{
		backCallback(true);
	}
}
