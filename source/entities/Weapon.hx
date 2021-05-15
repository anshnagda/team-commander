package entities;

import attachingMechanism.Slot;
import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import battle.Point;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import haxe.display.Display.Package;
import openfl.display.Sprite;
import states.ShopState;
import staticData.*;

@:publicFields
class Weapon extends Snappable
{
	var weaponName:String;
	var weaponID:Int;
	var rarity:Int;
	var spriteLoc:Point;

	var stats:Stats;

	var showHover:Function;
	var hideHover:Function;
	var hover:HoverText;

	var price:FlxText;

	var hoverShown = false;
	var isBeingHovered = false;

	public function new(x:Float, y:Float, weaponID:Int, closestSlotCoords:Function):Void
	{
		super(x, y, true, closestSlotCoords);
		this.SNAP_DIST = 2000;

		this.weaponName = WeaponData.weaponNames[weaponID];
		this.weaponID = weaponID;

		loadGraphic(WeaponData.weaponIDToSpritePath(weaponID));
		// this.color = FlxColor.YELLOW;  why yellow?
		this.price = Font.makeText(x, y + 36, 48, "50", 16);

		this.clicked_graphics = function() {};
		this.detached_graphics = function()
		{
			setGraphicSize(48, 48);
			updateHitbox();
		};
		this.attached_graphics = function()
		{
			if (slot.owner != null)
			{
				setGraphicSize(24, 24);
				price.text = "";
				updateHitbox();
			}
			else
			{
				setGraphicSize(48, 48);
				price.text = "50";
				updateHitbox();
			}
		};

		// Initialize stats and hover box
		stats = WeaponData.weaponIDToStats(weaponID);
		this.hover = new HoverText(0, 0, this);

		if (weaponID < 50)
		{
			rarity = 0;
		}
		else if (weaponID < 100)
		{
			rarity = 1;
		}
		else
		{
			rarity = 2;
		}
	}

	override function rendering_order()
	{
		if (clicked)
		{
			return 1;
		}
		if (attached)
		{
			if (slot.owner != null)
			{
				if (slot.owner.clicked)
				{
					return -1;
				}
			}
		}

		return 0;
	}

	override function detach()
	{
		var s = slot;
		super.detach();
		if (s == null)
		{
			return;
		}
		if (s.owner != null)
		{
			var unit = cast(s.owner, Unit);
			unit.updateStats();
		}
	}

	override function attach(s:Slot):Bool
	{
		var ret = super.attach(s);
		if (s == null)
		{
			return false;
		}
		if (s.owner != null)
		{
			var unit = cast(s.owner, Unit);
			unit.updateStats();
		}
		return ret;
	}

	// called when this snappable was hovered over. Used to display stats about this snappable.
	override function mouseOver(object:FlxSprite)
	{
		isBeingHovered = true;
	}

	// called when this snappable stopped being hovered over. Used to stop displaying stats about this snappable.
	override function mouseOut(object:FlxSprite)
	{
		isBeingHovered = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isBeingHovered && !clicked && !hoverShown)
		{
			showHover(this.hover);
			hoverShown = true;
		}

		if ((clicked || !isBeingHovered) && hoverShown)
		{
			hideHover(this.hover);
			hoverShown = false;
		}
		if (this.x + 48 + SnappableInfo.IMAGE_WIDTH > 800 - 20)
		{
			this.hover.x = this.x - SnappableInfo.IMAGE_WIDTH - 20;
		}
		else
		{
			this.hover.x = this.x + 48 + 20;
		}
		if (this.y + 48 + SnappableInfo.IMAGE_HEIGHT / 2 > 600 - 20)
		{
			this.hover.y = 600 - SnappableInfo.IMAGE_HEIGHT - 20;
		}
		else if (this.y - SnappableInfo.IMAGE_HEIGHT / 2 < 0)
		{
			this.hover.y = 20;
		}
		else
		{
			this.hover.y = this.y - SnappableInfo.IMAGE_HEIGHT / 2;
		}

		this.price.x = x;
		this.price.y = y + 36;
	}

	override public function getInfo()
	{
		trace(weaponName);
		trace(weaponID);
		var title = weaponName.toUpperCase();
		var body = "";
		var map = this.stats.toMapWeapon();
		for (key in map.keys())
		{
			if (map.get(key) == 0)
			{
				continue;
			}
			var text = key + ": ";
			if (map.get(key) > 0)
			{
				text += " +" + map.get(key);
			}
			else
			{
				text += map.get(key);
			}
			body += text + "\n";
		}
		return {title: title, body: body, rarity: "basic"};
	}

	override function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		var square_size = 48;
		if (slot != null)
		{
			if (slot.owner != null)
			{
				square_size = 24;
			}
		}
		if (point.x < x || point.x > x + square_size)
		{
			return false;
		}
		if (point.y < y || point.y > y + square_size)
		{
			return false;
		}
		return true;
	}
}
