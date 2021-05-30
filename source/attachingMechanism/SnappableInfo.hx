package attachingMechanism;

import entities.*;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.display.Sprite;
import staticData.Font;

@:publicFields
class SnappableInfo extends FlxSpriteGroup
{
	static inline var IMAGE_WIDTH:Int = 164; // card's width
	static inline var IMAGE_HEIGHT:Int = 220; // card's height

	static inline var PADDING_LEFT:Float = 32; // Padding to left
	static inline var PADDING_UP:Float = 12; // Padding to top
	static inline var LINE_GAP:Int = 20; // line gap between each line of text

	var snappable:Snappable;

	var title:FlxText;
	var body:FlxText;
	var background_graphic:FlxSprite;

	public function new(x:Float, y:Float, snappable:Snappable)
	{
		super(x, y);
		this.snappable = snappable;

		background_graphic = new FlxSprite(0, 0);
		var info = snappable.getInfo();

		if (info.rarity == "advanced" || info.rarity == "uncommon")
		{
			background_graphic.loadGraphic("assets/images/card_border_advanced.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
		}
		else if (info.rarity == "master" || info.rarity == "rare")
		{
			background_graphic.loadGraphic("assets/images/card_border_master.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
		}
		else if (info.rarity == "boss")
		{
			background_graphic.loadGraphic("assets/images/card_border_boss.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
		}
		else if (info.rarity == "elite")
		{
			background_graphic.loadGraphic("assets/images/card_border_elite.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
		}
		else
		{
			background_graphic.loadGraphic("assets/images/card_border.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
		}
		var curr_y = PADDING_UP;
		var info = snappable.getInfo();

		title = Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, "", 16, FlxColor.BLACK, FlxTextAlign.CENTER, FlxColor.TRANSPARENT);
		if (info.title.length > 20)
		{
			curr_y += LINE_GAP * 2;
		}
		else
		{
			curr_y += LINE_GAP;
		}
		body = Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, "", 16, FlxColor.BLACK, FlxTextAlign.LEFT, FlxColor.TRANSPARENT);
		updateHover();

		add(background_graphic);
		add(title);
		add(body);
	}

	// public function setFormat(text:FlxText)
	// {
	// 	Font.setFormat(text, 16, 0x142d36, FlxTextAlign.LEFT);
	// }

	public function getTexts()
	{
		return this;
	}

	public function updateHover()
	{
		var info = snappable.getInfo();

		title.text = info.title;
		body.text = info.body;
	}
}
