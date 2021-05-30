package states;

import entities.TutorialBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import js.html.Console;
import js.html.FontFaceSetLoadEvent;
import states.*;
import states.TutorialLevelState.LevelStateTutorial;
import staticData.*;

class SettingsState extends FlxSubState
{
	var titleText:FlxText;

	var boundingBox:FlxSprite;

	var volumeBar:FlxBar;
	var volumeText:FlxText;
	var volumeAmountText:FlxText;
	var volumeDownButton:FlxButtonPlus;
	var volumeUpButton:FlxButtonPlus;

	var speedBar:FlxBar;
	var speedText:FlxText;
	var speedAmountText:FlxText;
	var speedDownButton:FlxButtonPlus;
	var speedUpButton:FlxButtonPlus;
	var backButton:FlxButton;

	var tutorialText:FlxText;
	var tutorialOnButton:FlxButtonPlus;
	var tutorialOffButton:FlxButtonPlus;

	var playerState:PlayerState;
	var backCallback:Function;

	public function new(backCallback:Function, playerState:PlayerState)
	{
		super();
		this.playerState = playerState;
		this.backCallback = backCallback;
	}

	override public function create()
	{
		super.create();
		boundingBox = new FlxSprite();
		boundingBox.loadGraphic("assets/images/settings_window.png");
		boundingBox.screenCenter();
		add(boundingBox);

		backButton = Buttons.makeImgButton(540, 170, "close", closeSettings);
		titleText = Font.makeText(boundingBox.x, boundingBox.y + 20, boundingBox.width, "OPTIONS", 48);

		volumeText = Font.makeText(boundingBox.x + 50, titleText.y + titleText.height + 10, 0, "Volume", 16);
		volumeDownButton = Buttons.makeButton(volumeText.x + 16, volumeText.y + volumeText.height + 2, 20, 20, clickVolumeDown, "-", 16);
		volumeBar = new FlxBar(volumeDownButton.x + volumeDownButton.width + 4, volumeDownButton.y, LEFT_TO_RIGHT, 200, Std.int(volumeDownButton.height));

		volumeUpButton = Buttons.makeButton(volumeBar.x + volumeBar.width + 8, volumeDownButton.y, 20, 20, clickVolumeUp, "+", 16);

		volumeAmountText = Font.makeText(boundingBox.x, volumeUpButton.y, boundingBox.width, (FlxG.sound.volume * 100) + "%", 16);

		speedText = Font.makeText(boundingBox.x + 50, volumeText.y + 60, 0, "Animation Speed", 16);
		speedDownButton = Buttons.makeButton(speedText.x + 16, speedText.y + speedText.height + 2, 20, 20, clickSpeedDown, "-", 16);
		speedBar = new FlxBar(speedDownButton.x + speedDownButton.width + 4, speedDownButton.y, LEFT_TO_RIGHT, 200, Std.int(speedDownButton.height));
		speedBar.setRange(0.5, 2.0);

		speedUpButton = Buttons.makeButton(speedBar.x + speedBar.width + 8, speedDownButton.y, 20, 20, clickSpeedUp, "+", 16);

		speedAmountText = Font.makeText(boundingBox.x, speedUpButton.y, boundingBox.width, (Std.int(playerState.battle_grid.animation_speed * 100)) + "%", 16);

		tutorialText = Font.makeText(boundingBox.x + 50, speedText.y + 60, 0, "Tutorial", 16);
		tutorialOnButton = Buttons.makeButton(tutorialText.x + 50, tutorialText.y + tutorialText.height + 2, 40, 40, tutorialOn, "on", 16);
		tutorialOffButton = Buttons.makeButton(tutorialText.x + 16 + 80, tutorialText.y + tutorialText.height + 2, 40, 40, tutorialOff, "off", 16);

		volumeBar.createFilledBar(0xFF90EE90, FlxColor.GREEN);
		speedBar.createFilledBar(0xFF90EE90, FlxColor.GREEN);

		add(volumeText);
		add(titleText);
		add(backButton);
		add(volumeBar);
		add(volumeDownButton);
		add(volumeUpButton);
		add(volumeAmountText);
		add(speedBar);
		add(speedDownButton);
		add(speedText);
		add(speedUpButton);
		add(speedAmountText);
		add(tutorialText);
		add(tutorialOnButton);
		add(tutorialOffButton);

		updateVolume();
		updateSpeed();
		updateTutorial();
	}

	function tutorialOn()
	{
		PlayerState.tutorial = true;
		updateTutorial();
	}

	function tutorialOff()
	{
		PlayerState.tutorial = false;
		updateTutorial();
	}

	function updateTutorial()
	{
		var enabled = PlayerState.tutorial;
		var disabled_button:FlxButtonPlus;
		var enabled_button:FlxButtonPlus;
		if (enabled)
		{
			disabled_button = tutorialOnButton;
			enabled_button = tutorialOffButton;
			tutorialText.text = "Tutorial: on";
		}
		else
		{
			disabled_button = tutorialOffButton;
			enabled_button = tutorialOnButton;
			tutorialText.text = "Tutorial: off";
		}
		disabled_button.updateInactiveButtonColors([0xFFA0A0A0, 0xFFA0A0A0]);
		disabled_button.updateActiveButtonColors([0xFFA0A0A0, 0xFFA0A0A0]);
		enabled_button.updateInactiveButtonColors([FlxColor.GREEN, FlxColor.GREEN]);
		enabled_button.updateActiveButtonColors([0xff718f00, 0xff718f00]);
	}

	function closeSettings()
	{
		backCallback();
	}

	function clickVolumeUp()
	{
		playerState.sound.volume += 0.1;
		updateVolume();
	}

	function clickVolumeDown()
	{
		playerState.sound.volume -= 0.1;
		updateVolume();
	}

	function updateVolume()
	{
		var volume:Int = Math.round(playerState.sound.volume* 100);
		volumeBar.value = volume;
		volumeAmountText.text = volume + "%";
	}

	function clickSpeedUp()
	{
		playerState.battle_grid.setSpeed(Math.min(2.0, playerState.battle_grid.animation_speed + 0.1));
		updateSpeed();
	}

	function clickSpeedDown()
	{
		playerState.battle_grid.setSpeed(Math.max(0.5, playerState.battle_grid.animation_speed - 0.1));

		updateSpeed();
	}

	public static function round(number:Float, ?precision = 2):Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}

	function updateSpeed()
	{
		var speed = round(playerState.battle_grid.animation_speed);
		speedBar.value = speed;
		speedAmountText.text = speed + "x";
	}
}
