package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HealthBar extends FlxSpriteGroup
{
    // Class variables
    var parent:Unit;
    var min:Int = 0;
    var max:Int = 100;
    public var currHP:Int;
    public var shield:Int;

    // Sprite info
	var baseBar:FlxSprite;
	var currBar:FlxSprite;
    var shieldBar:FlxSprite;
    var border:FlxSprite;
    var thickness:Int = 3;

    // Bar size variables
    var barWidth:Int;
    var barHeight:Int;
    var currWidth:Int;

    // Offset from parent
    var xOffset:Int;
    var yOffset:Int;

    public function new(x:Int, y:Int, parent:Unit, width:Int, height:Int, xOffset:Int, yOffset:Int, min:Int, max:Int)
    {
        super(x, y);
        this.parent = parent;
        this.barWidth = width;
        this.barHeight = height;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
        this.min = min;
        this.max = max;

        // Draw bar sprites
        baseBar = new FlxSprite(x, y);
        currBar = new FlxSprite(x, y);
        shieldBar = new FlxSprite(x, y);
        border = new FlxSprite();
		border.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(baseBar);
        add(currBar);
		add(shieldBar);
        add(border);
        baseBar.makeGraphic(barWidth, barHeight, FlxColor.RED);
        currBar.makeGraphic(barWidth, barHeight, FlxColor.GREEN);
        //shieldBar.makeGraphic(barWidth, barHeight, FlxColor.WHITE);
        // Draw border
		var lineStyle:LineStyle = {color: FlxColor.BLACK, thickness: this.thickness};
        border.drawRect(x, y, width, height, FlxColor.TRANSPARENT,lineStyle);
    }

    public function setRange(min:Int, max:Int)
    {
        this.min = min;
        this.max = max;
    }

	override public function update(elapsed:Float):Void
	{
        var percent:Int;
        percent = Math.round((currHP / max) * 100);
        // If currHP has changed redraw the curr health bar graphic
        if (currHP <= 0) {
            currBar.kill();
        }
        if (Math.round((currWidth / barWidth) * 100) != percent) 
        {
			currWidth = Math.round(barWidth * (percent / 100));
            currBar.makeGraphic(currWidth, barHeight, FlxColor.GREEN);
        }

        
        // Handle shield graphic
        var shieldPercent:Int;
        shieldPercent = Math.round((shield / max) * 100);
        if (shield <= 0) {
            shieldBar.makeGraphic(1, barHeight, FlxColor.WHITE);
        } else {

			shieldBar.makeGraphic(Math.round(barWidth * (Math.min(shieldPercent, 100) / 100)), barHeight, FlxColor.WHITE);
        }

        x = parent.x + xOffset;
        y = parent.y + yOffset;

		super.update(elapsed);
	}

	public static function round(number:Float, ?precision = 2):Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}


	override function reset(x:Float, y:Float):Void
	{
        super.reset(x, y);
        currHP = max;
		baseBar.makeGraphic(barWidth, barHeight, FlxColor.RED);
		currBar.makeGraphic(barWidth, barHeight, FlxColor.GREEN);
		//shieldBar.makeGraphic(barWidth, barHeight, FlxColor.WHITE);
    }
}