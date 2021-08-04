package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxSound;
import openfl.display.Sprite;
import staticData.*;

class Main extends Sprite
{
	public static var DEV_ENABLED = false;
	public static var sound = new FlxSound();

	public function new()
	{
		// Initialize sound and data
		super();
		UnitData.init();
		WeaponData.init();
		// Run game
		addChild(new FlxGame(0, 0, MainState));
	}
}
