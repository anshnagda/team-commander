package states;

import entities.TutorialBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import js.html.Console;
import js.html.FontFaceSetLoadEvent;
import states.*;
import states.TutorialLevelState.LevelStateTutorial;
import staticData.*;

class LoseState extends FlxState
{
	var text:String;
	var playerState:PlayerState;
	var retryLevelCallback:Function;
	var newGameCallback:Function;

	var tutorial_boxes:Array<TutorialBox>;
	var big_box:FlxSprite;

	public function new(newGameCallback:Function, retryLevelCallback:Function, playerState:PlayerState)
	{
		super();
		this.playerState = playerState;
		this.retryLevelCallback = retryLevelCallback;
		this.newGameCallback = newGameCallback;
	}

	override public function create()
	{
		super.create();
		// if (this.playerState.versionPlayed == 0)
		// {
		// 	add(Font.makeText(0, 50, 800, "DEFEAT! -1 life", 128));
		// 	add(Font.makeText(0, 200, 800, "Lives remaining on stage " + playerState.current_stage + ": " + (playerState.livesRemaining + 1) + "/3", 32,
		// 		FlxColor.RED));
		// }
		// else
		// {
		add(Font.makeText(0, 50, 800, "DEFEAT!", 128));
		add(Buttons.makeButton(150, 400, 180, 80, retry, "Retry Level", 32));
		add(Buttons.makeButton(470, 400, 180, 80, newgame, "New Game", 32));
		if (playerState.difficulty == 0)
		{
			add(Font.makeText(0, 200, 800,
				"Number of Losses at "
				+ playerState.current_stage
				+ "-"
				+ playerState.current_level
				+ ": "
				+ playerState.numberOfLosses, 32, FlxColor.RED));
		}
		else if (playerState.difficulty == 1)
		{
			add(Font.makeText(0, 200, 800, "Lives remaining on stage " + playerState.current_stage + ": " + (playerState.livesRemaining) + "/3", 32,
				FlxColor.RED));
		}
		if (playerState.difficulty != 2)
		{
			var tip_message = "";
			if (playerState.battle_grid.numBattlingUnits < playerState.unit_capcity)
			{
				tip_message = "You can have up to " + playerState.unit_capcity + " of your units on the board, don't forget to use all of your capacity!";
			}
			else if ((playerState.gold > 99 && playerState.current_stage == 2) || playerState.gold > 199)
			{
				tip_message = "You have " + playerState.gold + " gold! Don't forget to spend it to strengthen your team!";
			}
			else if ((playerState.inventory.count_nonempty() > 0 && playerState.current_stage <= 2)
				|| playerState.inventory.count_nonempty() > 2)
			{
				tip_message = "You have "
					+ playerState.inventory.count_nonempty()
					+ " unused weapons! To make use of them, you can either equip them on your units, or sell them in the shop.";
			}
			else if ((playerState.allied_units.length > playerState.unit_capcity) && playerState.mergePossible() != null)
			{
				var merge_result = playerState.mergePossible();
				if (merge_result.type == "basic")
				{
					tip_message = "Remember, you can merge your " + merge_result.unit1 + " and " + merge_result.unit2 + " into a powerful advanced unit.";
				}
				else
				{
					tip_message = "Remember, you can merge three copies of " + merge_result.unit1 + " into a powerful master unit.";
				}
			}
			else if ((playerState.current_stage == 1 && playerState.current_level == 4)
				|| playerState.current_level == 5
				|| playerState.current_level == 3)
			{
				tip_message = "Remember to read the enemies' unique abilities and position your units accordingly.";
			}
			if (tip_message != "")
			{
				add(Font.makeText(50, 280, 700, "Tip: " + tip_message, 32));
			}
		}
		// }

		if (playerState.versionPlayed == 0)
		{
			if (this.playerState.firstTimeLose && PlayerState.tutorial && playerState.difficulty == 0)
			{
				this.playerState.firstTimeLose = false;
				// if (this.playerState.versionPlayed == 0)
				// {
				// 	this.tutorial_boxes = [
				// 		new TutorialBox("You lost this battle! No need to worry - as you have not yet lost this run!", 300, 225, "assets/images/box.png"),
				// 		new TutorialBox("As long as you have lives remaining, you may spend a life to retry a lost battle.", 320, 355,
				// 			"assets/images/leftbox.png"),
				// 		new TutorialBox("Every stage, the number of lives remaining resets to 3!", 300, 255, "assets/images/box.png")
				// 	];
				// }
				// else
				// {
				this.tutorial_boxes = [
					new TutorialBox("Too hard isn't it?", 300, 225, "assets/images/box.png"),
					new TutorialBox("Take a look on enemies' stats and abilities!", 320, 355, "assets/images/leftbox.png"),
					new TutorialBox("We have made the level easier~ Good Luck", 300, 255, "assets/images/box.png")
				];
				// }
				big_box = new FlxSprite(0, 0);
				big_box.makeGraphic(800, 600, FlxColor.BLACK);
				big_box.alpha = 0.3;
				add(big_box);
				add(tutorial_boxes[0]);
				FlxMouseEventManager.add(big_box, onClickTutorial, null, null, null);
			}
		}
	}

	function onClickTutorial(spr:FlxSprite):Void
	{
		var previous_box = tutorial_boxes.shift();
		remove(previous_box);
		if (tutorial_boxes.length > 0)
		{
			add(tutorial_boxes[0]);
		}
		else
		{
			remove(big_box);
			FlxMouseEventManager.remove(big_box);
		}
	}

	function retry()
	{
		this.retryLevelCallback();
	}

	function newgame()
	{
		this.newGameCallback();
	}
}
