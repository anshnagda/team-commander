package attachingMechanism;

import entities.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import openfl.display.Sprite;

// "abstract" class of objects that can be dragged via mouse and "attached" to slots.
@:publicFields
class Snappable extends FlxSprite
{
	var SNAP_DIST = 100;
	// the findSlot function (implemented by the client that creates the snappable) should have the following behavior: calling it
	// should return the closest eligible Slot that this Snappable can attach to. If there is no such slot, it should return null.
	var findSlot:Function = function()
	{
		return null;
	};

	var attached = false; // whether this Snappable is attached to a slot
	var slot:Slot = null; // if attached, contains the slot that this Snappable is attached to

	var previous_slot:Slot = null; // if not currently attached, contains the previous slot it was attached to

	// The X_graphics functions are supposed to be implemented by the client that creates this snappable.
	// They determine the graphics transformations that this sprite undergoes upon changing its state between attached/clicked/detached.
	var attached_graphics:Function = function()
	{
		return;
	};

	var detached_graphics:Function = function()
	{
		return;
	};

	var clicked_graphics:Function = function()
	{
		return;
	};

	var can_click:Function = function()
	{
		return true;
	}; // tells this whether it can be dragged or not right now

	var clicked = false; // whether this Snappable is clicked right now
	var relative_mouse_x = 0.0; // relative x coordinate of the mouse pointer that is currently clicking on this
	var relative_mouse_y = 0.0; // relative y coordinate of the mouse pointer that is currently clicking on this

	var clickable = true; // whether

	public function new(x:Float, y:Float, isActive:Bool, ?shouldAttachFn:Function, ?attached_graphics:Function, ?detached_graphics:Function,
			?clicked_graphics:Function):Void
	{
		super(x, y);

		if (shouldAttachFn != null)
		{
			this.findSlot = shouldAttachFn;
		}
		if (attached_graphics != null)
		{
			this.attached_graphics = attached_graphics;
		}
		if (detached_graphics != null)
		{
			this.detached_graphics = detached_graphics;
		}
		if (clicked_graphics != null)
		{
			this.clicked_graphics = clicked_graphics;
		}
		this.clickable = isActive;
	}

	function disable()
	{
		this.clickable = false;
		release_click();
	}

	function enable()
	{
		this.clickable = true;
	}

	override function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		if (point.x < x || point.x > x + 48)
		{
			return false;
		}
		if (point.y < y || point.y > y + 48)
		{
			return false;
		}
		return true;
	}

	// detach the snappable from its current slot.
	function detach()
	{
		detached_graphics();
		if (attached)
		{
			attached = false;
			previous_slot = slot;
			slot.detach();
			slot = null;
		}
	}

	// helper function for arranging sprites on the screen.
	function rendering_order()
	{
		return 0;
	}

	function attach(s:Slot):Bool
	{
		if (attached)
		{
			return false;
		}
		if (s == null)
		{
			return false;
		}
		if (s.isOccupied)
		{
			return false;
		}

		attached = true;
		slot = s;
		s.attachTo(this);
		attached_graphics();
		return true;
	}

	function try_to_attach()
	{
		if (attached)
		{
			return;
		}

		var attach_details = findSlot(this);
		if (attach_details.dist < this.SNAP_DIST || previous_slot == null)
		{
			attach(attach_details.slot);
		}
		else
		{
			if (!previous_slot.isOccupied)
			{
				attach(previous_slot);
			}
			else // There is no eligible slot to attach
			{
				detach();
			}
		}
	}

	function force_attach(customFindSlot:Function)
	{
		if (attached)
		{
			return;
		}
		var attach_details = customFindSlot(this);
		attach(attach_details.slot);
	}

	// called whenever the mouse button is released from the snappable
	function release_click()
	{
		if (clicked)
		{
			// The snappable should call findSlot to find the closest slot it can attach to, then attach to it.
			clicked = false;
			try_to_attach();
		}
	}

	// called when this snappable was successfully clicked
	function click()
	{
		detach();
		clicked_graphics();
		clicked = true;
		relative_mouse_x = this.x - FlxG.mouse.x;
		relative_mouse_y = this.y - FlxG.mouse.y;
	}

	// called when this snappable was clicked
	function mouseDown(object:FlxSprite)
	{
		if (clickable)
		{
			click();
		}
	}

	// called when this snappable was hovered over. Used to display stats about this snappable.
	function mouseOver(object:FlxSprite) {}

	// called when this snappable stopped being hovered over. Used to stop displaying stats about this snappable.
	function mouseOut(object:FlxSprite) {}

	// called whenever the mouse button was released on this snappable
	function mouseUp(object:FlxSprite)
	{
		return;
	}

	// called every x fraction of a second.
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// if this snappable is no longer clicked, call release_click
		if (clicked && !FlxG.mouse.pressed)
		{
			release_click();
		}

		// if this snappable is currently being clicked, set its position to the mouse position
		if (clicked)
		{
			this.x = FlxG.mouse.x + relative_mouse_x;
			this.y = FlxG.mouse.y + relative_mouse_y;
		}

		// if this snappable is attached to a slot, set its position to be the position dictated by the slot
		if (attached)
		{
			var coords = slot.coordinates();
			this.x = coords.x;
			this.y = coords.y;
		}
	}

	override public function destroy():Void
	{
		// Make sure that this object is removed from the FlxMouseEventManager for GC
		FlxMouseEventManager.remove(this);
		super.destroy();
	}

	public function getInfo()
	{
		return {title: "SNAPPABLE", body: "NULL", rarity: "basic"};
	}
}
