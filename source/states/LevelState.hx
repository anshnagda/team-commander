package states;

import battle.BattleCalculator;
import entities.Unit;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxButtonPlus;
import flixel.group.*;
import flixel.input.FlxAccelerometer;
import flixel.input.FlxAccelerometer;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.*;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import haxe.Timer;
import js.lib.Uint8Array;
import staticData.Buttons;
import staticData.Font;
import staticData.LevelLayouts;

typedef EnemyPosition =
{
	x:Int,
	y:Int,
	enemy:Unit
};

class LevelState extends BenchAndInventoryState
{
	var enemyLayout:Array<EnemyPosition>;
	var enemyUnits:FlxGroup = new FlxGroup();

	var background:FlxSprite;

	var stage:Int;
	var level:Int;

	var battle_button:FlxButtonPlus;
	var shop_button:FlxButtonPlus;
	var merge_button:FlxButtonPlus;
	var inBattle = false;
	var currentLevelText:FlxText;

	var openShopCallback:Function;
	var openMergeCallback:Function;

	var open = true;

	public function new(playerState:PlayerState, endLevelCallback:Function, openShopCallback:Function, openMergeCallback:Function)
	{
		super(playerState, endLevelCallback);
		this.stage = playerState.current_stage;
		this.level = playerState.current_level;
		this.enemyLayout = LevelLayouts.createEnemySetup(stage, level);

		this.playerState.battle_grid.reset_battle();
		this.playerState.battle_grid.updateTextSprite();

		this.battle_button = Buttons.makeButton(playerState.inventory.x + 40, 400, 64, 32, initiate_battle, "BATTLE", 16);
		this.merge_button = Buttons.makeButton(playerState.inventory.x + 40, 450, 64, 32, open_merge, "MERGE", 16);
		this.shop_button = Buttons.makeButton(playerState.inventory.x + 40, 500, 64, 32, open_shop, "SHOP", 16);

		this.openShopCallback = openShopCallback;
		this.openMergeCallback = openMergeCallback;
	}

	override public function create()
	{
		// add the background
		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/background.png");
		background.setGraphicSize(800, 600);
		background.alpha = 0.7;
		add(background);
		// add the battle grid
		add(playerState.battle_grid);
		playerState.battle_grid.is_drawn = true;
		add(playerState.battle_grid.square_effects);
		// add unit capacity text
		add(playerState.numUnitsTextSprite);
		// add enemies
		for (pos in enemyLayout)
		{
			if (stage == 1)
			{
				pos.enemy.enemyStatMultiplier = 0.7;
			}
			pos.enemy.makeEnemy();
			enemyUnits.add(pos.enemy);
			pos.enemy.reset(pos.enemy.x, pos.enemy.y);
			pos.enemy.resetStats();
			add(pos.enemy.healthBar);
			pos.enemy.attach(playerState.battle_grid.slots[pos.x][pos.y]);
			pos.enemy.showHover = function()
			{
				this.addHover(pos.enemy.hover);
			}
			pos.enemy.hideHover = function()
			{
				this.removeHover(pos.enemy.hover);
			}
			FlxMouseEventManager.add(pos.enemy, pos.enemy.mouseDown, pos.enemy.mouseUp, pos.enemy.mouseOver, pos.enemy.mouseOut);
		}

		add(enemyUnits);
		// super.create() gets all allied weapons and units and draws bench and inventory
		super.create();

		// add all the enemies
		// TODO

		// add the buttons

		add(battle_button);
		if (stage >= 2 || Main.DEV_ENABLED)
		{
			add(shop_button);
		}
		if (level >= 4 || stage >= 2 || Main.DEV_ENABLED)
		{
			add(merge_button);
		}

		currentLevelText = Font.makeText(playerState.inventory.x, 10, playerState.inventory.gridSize * playerState.inventory.numRows,
			"LEVEL "
			+ stage
			+ "-"
			+ level, 48);

		add(currentLevelText);

		// add battlegrid projectiles
		add(playerState.battle_grid.projectiles);
	}

	function open_shop()
	{
		if (!this.open)
		{
			return;
		}
		this.open = false;
		trace("OPENING SHOP!");
		removeAll();
		openShopCallback();
	}

	function open_merge()
	{
		if (!this.open)
		{
			return;
		}
		this.open = false;
		removeAll();
		openMergeCallback();
	}

	function initiate_battle()
	{
		if (inBattle)
		{
			return;
		}
		if (playerState.battle_grid.numUnits == 0)
		{
			var error_text = Font.makeText(battle_button.x, battle_button.y, battle_button.width, "Place at least one unit on the grid!", 16, FlxColor.RED);
			add(error_text);
			Timer.delay(() -> remove(error_text), 1000);
			return;
		}
		remove(battle_button);
		remove(shop_button);
		remove(merge_button);
		inBattle = true;
		playerState.battle_grid.startBattle();
		this.playerState.logData.recordPlacement(playerState.battle_grid.unitGrid);
		var bc = new BattleCalculator(playerState.battle_grid, bcCallBack);
		bc.oneIter();

		// remove(button);
		// Doesnt fix them spamming the button
		// remove(button.group);
		// playerState.battle_grid.startBattle();
		// var bc = new BattleCalculator(playerState.battle_grid, bcCallBack);
		// bc.oneIter();
	}

	function bcCallBack(win:Bool)
	{
		// call back to main
		if (win)
		{
			var vicText = Font.makeText(0, 0, 0, "VICTORY", 80);
			vicText.screenCenter();
			vicText.borderColor = FlxColor.YELLOW;
			vicText.borderStyle = FlxTextBorderStyle.OUTLINE;
			add(vicText);
		}
		else
		{
			var vicText = Font.makeText(0, 0, 0, "DEFEAT", 80);
			vicText.screenCenter();
			vicText.borderColor = FlxColor.GRAY;
			vicText.borderStyle = FlxTextBorderStyle.OUTLINE;
			add(vicText);
		}
		Timer.delay(() -> endLevel(win), 1500);
	}

	override function removeAll()
	{
		playerState.battle_grid.reset_battle();
		playerState.battle_grid.is_drawn = false;
		remove(playerState.battle_grid);
		remove(playerState.numUnitsTextSprite);
		remove(background);
		remove(playerState.battle_grid.projectiles);
		remove(playerState.battle_grid.square_effects);
		remove(battle_button);
		remove(merge_button);
		remove(shop_button);
		remove(enemyUnits);
		remove(currentLevelText);
		for (enemy_unit in enemyUnits)
		{
			var enemy_unit = cast(enemy_unit, Unit);
			remove(enemy_unit.healthBar);
		}
		super.removeAll();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
