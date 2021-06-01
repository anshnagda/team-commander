package states;

import battle.BattleCalculator;
import entities.TutorialBox;
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

class LevelStateTutorial extends LevelState
{
	public var tutorial_boxes:Array<TutorialBox>;

	var big_box:FlxSprite;

	public function new(playerState:PlayerState, endLevelCallback:Function, openShopCallback:Function, openMergeCallback:Function)
	{
		super(playerState, endLevelCallback, openShopCallback, openMergeCallback);
		if (PlayerState.tutorial)
		{
			tutorial_boxes = new Array<TutorialBox>();
			big_box = new FlxSprite(0, 0);
			big_box.makeGraphic(800, 600, FlxColor.BLACK);
			big_box.alpha = 0.3;
		}
	}

	override public function create()
	{
		super.create();
		if (PlayerState.tutorial)
		{
			if (stage == 1)
			{
				if (level == 1)
				{
					s1l1_create();
				}
				if (level == 2)
				{
					s1l2_create();
				}
				if (level == 3)
				{
					s1l3_create();
				}
				if (level == 4)
				{
					s1l4_create();
				}
			}

			if (stage == 2)
			{
				if (level == 1)
				{
					s2l1_create();
				}
			}

			if (stage == 3)
			{
				if (level == 1)
				{
					s3l1_create();
				}
			}

			add(big_box);
			FlxMouseEventManager.add(big_box, onClickTutorial, null, null, null);

			add(tutorial_boxes[0]);
		}
	}

	function onClickTutorial(spr:FlxSprite):Void
	{
		var previous_box = tutorial_boxes.shift();
		remove(previous_box);
		playerState.log.logLevelAction(11, tutorial_boxes.length);

		if (tutorial_boxes.length > 0)
		{
			add(tutorial_boxes[0]);
		}
		else
		{
			remove(big_box);
			FlxMouseEventManager.remove(big_box);
			if (stage == 1 && level == 4)
			{
				open_merge();
			}
			else if (stage == 2 && level == 1)
			{
				open_shop();
			}
		}
	}

	function s1l1_create()
	{
		remove(playerState.inventory);
		tutorial_boxes = [
			new TutorialBox("Drag units from your bench to your half of the battle grid", 300, 360, "assets/images/box.png"),
			new TutorialBox("Wipe out all enemies to win the battle. Allies respawn after battle", 300, 225, "assets/images/box.png"),
			new TutorialBox("Press battle to begin the fight!", 400, 335, "assets/images/rightbox.png")
		];
	}

	function s1l2_create()
	{
		remove(playerState.inventory);
		tutorial_boxes = [
			new TutorialBox("You got a new unit! Hover over the unit to check out its stats", 48, 330, "assets/images/box.png"),
			new TutorialBox("Remember to hover over and check out enemies as well", 192, 10, "assets/images/box.png")
		];
	}

	function s1l3_create()
	{
		tutorial_boxes = [
			new TutorialBox("Drag weapons onto your units to equip them! Each unit can hold up to 2 weapons", 350, 48, "assets/images/rightbox.png"),
			new TutorialBox("You can move weapons by dragging them between units or to your inventory", 350, 48, "assets/images/rightbox.png")
		];
	}

	function s1l4_create()
	{
		tutorial_boxes = [
			new TutorialBox("You can currently use at most 2 of your 3 owned units on the board.", 400, 375, "assets/images/leftbox.png"),
			new TutorialBox("It will be difficult to defeat the powerful enemy with 2 of your basic units!", 0, 10, "assets/images/rightbox.png"),

			new TutorialBox("Use the merge tool to combine a pair of your basic units into a powerful advanced unit!", 400, 385, "assets/images/rightbox.png")
		];
	}

	function s2l1_create()
	{
		tutorial_boxes = [
			new TutorialBox("You now have access to the shop!", 400, 435, "assets/images/rightbox.png")
		];
	}

	function s3l1_create()
	{
		tutorial_boxes = [
			new TutorialBox("You have unlocked the next rarity of units - master units!", 300, 300, "assets/images/box.png"),
			new TutorialBox("In order to obtain one, you must merge together three identical advanced units.", 300, 300, "assets/images/box.png"),
			new TutorialBox("Once you collect three advanced units of the same type, head into the merge tool to combine them!", 400, 385,
				"assets/images/rightbox.png"),
			new TutorialBox("Remember: you can hover over the enemy's units to see their stats and special abilities.", 200, 0, "assets/images/leftbox.png"),
		];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
