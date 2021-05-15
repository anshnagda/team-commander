package rewardCards;

import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeVelocity;
import flixel.addons.text.FlxTextField;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import js.html.svg.AnimatedBoolean;
import staticData.Font;

// An "abstact" class that represents reward cards
// This class should not be created.
class Card extends SnappableInfo
{
	var selected:Bool; // if the player picked this
	var clickable = true; // allow to click this card

	var rand:FlxRandom; // random number generator

	var selectFunction:Function;

	/**
		It outputs a randomly generated card that has unit image and unit description populated
		t1: % of getting a tier 1 unit
		t2: % of getting a tier 2 unit
		t3: % of getting a teir 3 unit
		select: a call back function to call when this card is selected
	**/
	public function new(x:Float, y:Float, select:Function, snappable:Snappable)
	{
		super(x - Std.int(SnappableInfo.IMAGE_WIDTH / 2), y - Std.int(SnappableInfo.IMAGE_WIDTH / 2), snappable);
		// createRectangularBody(IMAGE_WIDTH, IMAGE_HEIGHT);
		snappable.x = this.x + Std.int((SnappableInfo.IMAGE_WIDTH - snappable.width) / 2);
		snappable.y = this.y - SnappableInfo.PADDING_UP;
		snappable.disable();

		rand = new FlxRandom();

		selectFunction = select;

		makeClickable();
		background_graphic.color = 0xadadad;
	}

	public function setFormat(text:FlxText)
	{
		Font.setFormat(text, 16, 0x142d36, FlxTextAlign.LEFT);
	}

	public function makeClickable()
	{
		FlxMouseEventManager.add(this, onDown, null, onOver, onOut);
	}

	function onOver(_)
	{
		if (clickable)
		{
			background_graphic.color = 0xcfcccc;
		}
	}

	function onOut(_)
	{
		if (clickable)
		{
			background_graphic.color = 0xadadad;
		}
	}

	function onDown(_)
	{
		if (!clickable)
		{
			return;
		}
		background_graphic.color = FlxColor.WHITE;
		this.selected = true;
		this.clickable = false;
		selectFunction();
	}

	public function isSelected():Bool
	{
		this.clickable = false;
		return selected;
	}

	override function update(elapsed:Float)
	{
		snappable.x = this.x + Std.int((SnappableInfo.IMAGE_WIDTH - snappable.width) / 2);
		snappable.y = this.y - SnappableInfo.PADDING_UP;
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		// Make sure that this object is removed from the FlxMouseEventManager for GC
		FlxMouseEventManager.remove(this);
		super.destroy();
	}
}
