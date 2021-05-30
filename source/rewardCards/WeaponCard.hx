package rewardCards;

import staticData.WeaponData;
import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import attachingMechanism.SnappableInfo;
import entities.*;
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

class WeaponCard extends Card
{
	/**
		It outputs a randomly generated card that has unit image and unit description populated
		t1: % of getting a tier 1 unit
		t2: % of getting a tier 2 unit
		t3: % of getting a teir 3 unit
		select: a call back function to call when this card is selected
	**/
	public function new(x:Float, y:Float, t1:Int, t2:Int, t3:Int, select:Function)
	{
		rand = new FlxRandom();
		var rarity = rand.int(1, 100);
		if (rarity <= t1)
		{
			var randID = rand.int(0, WeaponData.commonWeapons.length - 1);
			snappable = new Weapon(0, 0, randID, null);
		}
		else if (rarity <= t2 + t1) {
			var randID = rand.int(WeaponData.commonWeapons.length, WeaponData.commonWeapons.length + WeaponData.uncommonWeapons.length - 1);
			snappable = new Weapon(0, 0, randID, null);
		}
		else {
			var randID = rand.int(WeaponData.commonWeapons.length + WeaponData.uncommonWeapons.length, WeaponData.commonWeapons.length + WeaponData.uncommonWeapons.length + WeaponData.rareWeapons.length - 1);
			snappable = new Weapon(0, 0, randID, null);
		}

		super(x, y, select, snappable);
	}

	// getter function that get the weapon
	public function getWeapon()
	{
		return cast(this.snappable, Weapon);
	}
}
