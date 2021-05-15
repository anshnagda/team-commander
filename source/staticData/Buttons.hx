package staticData;

import flixel.addons.ui.FlxButtonPlus;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Buttons
{
	public static function makeButton(x, y, width, height, callback, text:String, size:Int, color:Int = FlxColor.WHITE,
			align:FlxTextAlign = FlxTextAlign.CENTER, screenCenter:Bool = false)
	{
		var button = new FlxButtonPlus(x, y, callback, text, width, height);
		button.borderColor = FlxColor.BLACK;
		if (screenCenter)
		{
			button.screenCenter();
		}
		button.textNormal = Font.makeText(button.x, button.y + Std.int((height - size) / 2), width, text, size, color, align, FlxColor.TRANSPARENT);
		button.textHighlight = button.textNormal;
		button.updateInactiveButtonColors([0x7e89fc00, 0x7e89fc00]);
		button.updateActiveButtonColors([0xf5718f00, 0xf5718f00]);
		return button;
	}
}
