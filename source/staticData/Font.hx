package staticData;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class Font
{
	public static function setFormat(text:FlxText, size:Int, color:Int = FlxColor.WHITE, align:FlxTextAlign = FlxTextAlign.CENTER,
			border:FlxColor = FlxColor.TRANSPARENT)
	{
		text.setFormat("assets/font/monogram_extended.ttf", size, FlxColor.fromInt(color), align, FlxTextBorderStyle.OUTLINE, border);
	}

	public static function makeText(x, y, width, text:String, size:Int, color:Int = FlxColor.WHITE, align:FlxTextAlign = FlxTextAlign.CENTER,
			border:FlxColor = FlxColor.BLACK)
	{
		var flxtext = new FlxText(x, y, width, text, size);
		setFormat(flxtext, size, color, align, border);
		return flxtext;
	}
}
