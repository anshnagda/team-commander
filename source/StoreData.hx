package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxSound;
import js.Browser;
import openfl.display.Sprite;
import staticData.*;

class StoreData
{
	static var localStore = new Map<String, String>();

	public static function tryStore(key:String, val:String)
	{
		try
		{
			Browser.window.localStorage.setItem("teamCommander:" + key, val);
		}
		catch (e:Dynamic)
		{
			localStore.set(key, val);
			return;
		}
	}

	public static function tryLoad(key:String):String
	{
		try
		{
			var ret = Browser.window.localStorage.getItem("teamCommander:" + key);
			return ret;
		}
		catch (e:Dynamic)
		{
			return localStore.get(key);
		}
	}
}
