package attachingMechanism;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import openfl.display.Sprite;

// "abstract" class of slots that snappables can snap to.
@:publicFields
class Slot
{
	var isOccupied = false; // whether the slot has a snappable currently attached to it
	var attachedSnappable:Snappable = null; // snappable currently attached to the slot (ex. if the slot is a weapon slot, then it will be a weapon)

	var coordinates:Function = null; // function that takes in no arguments and returns a javascript-style object with x and y fields.

	// the purpose of coordinates is to inform the attachedSnappable what its x and y coordinates should be at every point of time.
	var owner:Snappable = null; // if this Slot is a weapon slot, then owner stores the identity of the unit whose weapon slot this is.

	var attachCallback:Function = null; // called by the slot whenever something is attached
	var detachCallback:Function = null; // called by the slot whenever something is detached

	public function new(coordinates:Function, ?attachCallback:Function, ?detachCallback:Function)
	{
		this.coordinates = coordinates;
		if (attachCallback != null)
		{
			this.attachCallback = attachCallback;
		}
		else
		{
			this.attachCallback = function(snappable:Snappable) {};
		}

		if (detachCallback != null)
		{
			this.detachCallback = detachCallback;
		}
		else
		{
			this.detachCallback = function(snappable:Snappable) {};
		}
	}

	// a Snappable should call this function passing itself as the argument when it wants to attach to this Slot.
	function attachTo(obj:Snappable)
	{
		if (obj == null)
		{
			return false;
		}
		if (!isOccupied)
		{
			isOccupied = true;
			attachedSnappable = obj;
			attachCallback(attachedSnappable);
			return true;
		}

		return false;
	}

	// the attached Snappable should call this function when it detaches itself from this Slot.
	function detach()
	{
		if (isOccupied)
		{
			isOccupied = false;
			var snap = attachedSnappable;

			attachedSnappable = null;
			detachCallback(snap);
			return true;
		}

		return false;
	}
}
