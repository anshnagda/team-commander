package states;

import haxe.Constraints.Function;
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
	var callBack:Function;

	public function new(text:String, callBack:Function)
	{
		super();
		this.text = text;
		this.callBack = callBack;
	}

	override public function create()
	{
		super.create();
		add(Font.makeText(0, 100, 800, text, 64));
		if (callBack != null) {
			add(Buttons.makeButton(100, 300, 200, 100, () -> FlxG.switchState(new MainState()), "NEW GAME", 32));
			add(Buttons.makeButton(500, 300, 200, 100, () -> callBack(), "CHALLENGE", 32));
		} else {
			add(Buttons.makeButton(0, 0, 200, 100, () -> FlxG.switchState(new MainState()), "NEW GAME", 32, FlxColor.WHITE, FlxTextAlign.CENTER, true));
		}
	}
}
