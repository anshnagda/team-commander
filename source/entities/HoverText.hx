package entities;

import attachingMechanism.SnappableInfo;
import entities.*;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import staticData.Font;

@:publicFields
class HoverText extends SnappableInfo
{
	// static inline var IMAGE_WIDTH:Int = 164; // card's width
	// static inline var IMAGE_HEIGHT:Int = 220; // card's height
	// static inline var PADDING_LEFT:Float = 64; // Padding to left
	// static inline var PADDING_UP:Float = 10; // Padding to top
	// static inline var LINE_GAP:Int = 10; // line gap between each line of text
	// var unit:Unit;
	// var weapon:Weapon;
	// var texts:FlxGroup; // card stats
	// public function new(x:Float, y:Float, ?unit:Unit, ?weapon:Weapon)
	// {
	// 	super(x, y);
	// 	loadGraphic("assets/images/card_border.png", false, IMAGE_WIDTH, IMAGE_HEIGHT);
	// 	this.unit = unit;
	// 	this.weapon = weapon;
	// 	updateHover();
	// }
	// // public function setFormat(text:FlxText)
	// // {
	// // 	Font.setFormat(text, 16, 0x142d36, FlxTextAlign.LEFT);
	// // }
	// public function getTexts():FlxGroup
	// {
	// 	return this.texts;
	// }
	// public function updateHover()
	// {
	// 	texts = new FlxGroup();
	// 	if (unit != null)
	// 	{
	// 		var curr_y = this.y + PADDING_UP * 5;
	// 		this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, unit.unitName.toUpperCase(), 16, FlxColor.BLACK,
	// 			FlxTextAlign.CENTER));
	// 		curr_y += LINE_GAP * 2;
	// 		var map = this.unit.currStats.toMap();
	// 		for (key in map.keys())
	// 		{
	// 			if (key == "Speed" || key == "Minimum Range" || key == "Maximum Range")
	// 			{
	// 				continue;
	// 			}
	// 			// get the stats and write to the screen
	// 			this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, key + " : " + map.get(key), 16, FlxColor.BLACK,
	// 				FlxTextAlign.LEFT));
	// 			curr_y += LINE_GAP * 2;
	// 		}
	// 		if (unit.currStats.minRng == 1)
	// 		{
	// 			this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, "Range : " + unit.currStats.maxRng, 16, FlxColor.BLACK,
	// 				FlxTextAlign.LEFT));
	// 		}
	// 		else
	// 		{
	// 			this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT,
	// 				"Range : " + unit.currStats.minRng + " - " + unit.currStats.maxRng, 16, FlxColor.BLACK, FlxTextAlign.LEFT));
	// 		}
	// 		// this.texts.forEachOfType(FlxText, this.setFormat);
	// 	}
	// 	if (weapon != null)
	// 	{
	// 		var curr_y = this.y + PADDING_UP * 5;
	// 		this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, weapon.weaponName.toUpperCase(), 16, FlxColor.BLACK,
	// 			FlxTextAlign.CENTER));
	// 		curr_y += LINE_GAP * 2;
	// 		var map = this.weapon.stats.toMapWeapon();
	// 		for (key in map.keys())
	// 		{
	// 			// get the stats and write to the screen
	// 			if (map.get(key) == 0)
	// 			{
	// 				continue;
	// 			}
	// 			var text = key + " : ";
	// 			if (map.get(key) > 0)
	// 			{
	// 				text += " +" + map.get(key);
	// 			}
	// 			else
	// 			{
	// 				text += map.get(key);
	// 			}
	// 			this.texts.add(Font.makeText(PADDING_LEFT / 2, curr_y, IMAGE_WIDTH - PADDING_LEFT, text, 16, FlxColor.BLACK, FlxTextAlign.CENTER));
	// 			curr_y += LINE_GAP * 2;
	// 		}
	// 		// this.texts.forEachOfType(FlxText, this.setFormat);
	// 	}
	// }
}
