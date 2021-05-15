package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.input.mouse.FlxMouseEventManager;
import openfl.display.Sprite;
import staticData.*;

class Main extends Sprite
{
	public static var DEV_ENABLED = false;

	public function new()
	{
		super();
		UnitData.init();
		WeaponData.init();
		addChild(new FlxGame(0, 0, MainState));
	}
}
