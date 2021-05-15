package entities;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import staticData.Font;

class TutorialBox extends FlxSpriteGroup
{
	var img_sprite:FlxSprite;
	var text_sprite:FlxText;
	var click_text_sprite:FlxText;

	// All the tutorial boxes are 200x150
	public function new(text:String, x:Int, y:Int, graphics_location:String)
	{
		super();
		if (graphics_location == "assets/images/leftbox.png")
		{
			text_sprite = Font.makeText(x + 20 + 51, y + 5 + 26, 160, text, 24);
		}
		else
		{
			text_sprite = Font.makeText(x + 20, y + 5, 160, text, 24);
		}
		img_sprite = new FlxSprite(x, y);
		img_sprite.loadGraphic(graphics_location);

		if (graphics_location == "assets/images/leftbox.png")
		{
			click_text_sprite = Font.makeText(x + 20 + 51, y + 130 + 26, 160, "(click to advance)", 16, FlxColor.BLACK, FlxTextAlign.CENTER,
				FlxColor.TRANSPARENT);
		}
		else
		{
			click_text_sprite = Font.makeText(x + 20, y + 130, 160, "(click to advance)", 16, FlxColor.BLACK, FlxTextAlign.CENTER, FlxColor.TRANSPARENT);
		}
		add(img_sprite);
		add(text_sprite);
		add(click_text_sprite);
	}
}
