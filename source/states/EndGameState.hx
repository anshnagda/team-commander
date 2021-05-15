package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import js.html.Console;
import js.html.FontFaceSetLoadEvent;
import states.*;
import states.TutorialLevelState.LevelStateTutorial;
import staticData.*;

class EndGameState extends FlxState
{
	var text:String;

	public function new(text:String)
	{
		super();
		this.text = text;
	}

	override public function create()
	{
		super.create();
		add(Font.makeText(0, 100, 800, text, 64));
		add(Buttons.makeButton(0, 0, 200, 100, () -> FlxG.switchState(new MainState()), "NEW GAME", 32, FlxColor.WHITE, FlxTextAlign.CENTER, true));
	}
}
