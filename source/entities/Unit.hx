package entities;

import attachingMechanism.Slot;
import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import states.ShopState;
import staticData.*;

@:publicFields
class Unit extends Snappable
{
	// merge conflicts are pain
	// Unit details
	var unitName:String;
	var rarity:Int;
	var unitID:Int;
	var healthBar:HealthBar;
	var maxHp:Int;

	// Enemy details
	var enemyStatMultiplier:Float = 1.0;
	var enemy:Bool;

	var weaponSlot1:Slot = null;
	var weaponSlot2:Slot = null;

	var baseStats:Stats;
	var currStats:Stats;
	var hover:HoverText;

	var showHover:Function;
	var hideHover:Function;

	var price:FlxText;

	var hoverShown = false;
	var isBeingHovered = false;

	var original_image:BitmapData;

	public function new(x:Float, y:Float, unitID:Int, closestSlotCoords, enemyStatMultiplier = 1.0):Void
	{
		super(x, y, true, closestSlotCoords);
		// Base info
		enemy = false;
		this.unitID = unitID;
		this.unitName = UnitData.unitNames[unitID];
		this.enemyStatMultiplier = enemyStatMultiplier;

		// Graphics
		this.clicked_graphics = function() {};
		this.unitName = UnitData.unitNames[unitID];
		loadGraphic(UnitData.unitIDToSpritePath(unitID));
		trace(UnitData.unitIDToSpritePath(unitID));
		setGraphicSize(48, 48);
		original_image = pixels.clone();
		this.pixels = UnitData.allyOutlineEffect(this.pixels);
		updateHitbox();

		this.price = Font.makeText(x, y + 36, 48, "", 16);
		if (UnitData.unitToRarity[unitID] == "basic")
		{
			price.text = Std.string(Std.int(ShopState.PRICE[0] / 2));
		}
		else if (UnitData.unitToRarity[unitID] == "advanced")
		{
			price.text = Std.string(Std.int(ShopState.PRICE[1] / 2));
		}
		else if (UnitData.unitToRarity[unitID] == "master")
		{
			price.text = Std.string(Std.int(ShopState.PRICE[1] / 2));
		}

		// Initialize weapon slots
		var slot1_coord = function()
		{
			return {x: this.x, y: this.y + 24};
		};
		var slot2_coord = function()
		{
			return {x: this.x + 24, y: this.y + 24};
		};
		weaponSlot1 = new Slot(slot1_coord);
		weaponSlot2 = new Slot(slot2_coord);
		weaponSlot1.owner = this;
		weaponSlot2.owner = this;

		// Intialize stats and render image depending on unit name
		baseStats = UnitData.unitIDToStats(unitID);

		currStats = baseStats.copy();
		this.hover = new HoverText(0, 0, this);

		if (unitID <= 3)
		{
			rarity = 0;
		}
		else if (unitID <= 13)
		{
			rarity = 1;
		}
		else
		{
			rarity = 2;
		}

		// Set health bar
		healthBar = new HealthBar(0, 0, this, 40, 10, 4, -10, 0, currStats.hp);

		this.updateStats();
	}

	public function makeEnemy()
	{
		this.enemy = true;
		baseStats.atk = Math.round(baseStats.atk * enemyStatMultiplier);
		this.pixels = UnitData.enemyOutlineEffect(this.original_image);
		updateStats();
	}

	// Sets the unit's current stats to be those of base stats + both weapons
	public function resetStats()
	{
		currStats = baseStats.copy();
		if (weaponSlot1.attachedSnappable != null)
		{
			var weapon1 = cast(weaponSlot1.attachedSnappable, Weapon);
			currStats.addStat(weapon1.stats);
		}
		if (weaponSlot2.attachedSnappable != null)
		{
			var weapon2 = cast(weaponSlot2.attachedSnappable, Weapon);
			currStats.addStat(weapon2.stats);
		}
		healthBar.setRange(0, this.currStats.hp);
		maxHp = this.currStats.hp;
	}

	public function enableBattleSprites()
	{
		loadGraphic(UnitData.unitIDToBattleSpritePath(unitID));
		setGraphicSize(48, 48);
		if (this.enemy)
		{
			this.pixels = UnitData.enemyOutlineEffect(this.pixels);
		}
		else
		{
			this.pixels = UnitData.allyOutlineEffect(this.pixels);
		}
		updateHitbox();
	}

	public function disableBattleSprites()
	{
		loadGraphic(UnitData.unitIDToSpritePath(unitID));
		setGraphicSize(48, 48);
		if (this.enemy)
		{
			this.pixels = UnitData.enemyOutlineEffect(this.pixels);
		}
		else
		{
			this.pixels = UnitData.allyOutlineEffect(this.pixels);
		}
		updateHitbox();
	}

	// Used to lower the hp of the unit
	public function takeDamage(hp:Int)
	{
		lowerStats(Math.round(Math.max(0, hp)), 0, 0, 0, 0);
	}

	// Heals a unit up to at most full
	public function heal(hp:Int)
	{
		if (currStats.hp + hp > maxHp)
		{
			raiseStats(maxHp - currStats.hp, 0, 0, 0, 0);
		}
		else
		{
			raiseStats(hp, 0, 0, 0, 0);
		}
	}

	// Lowers corresponding current stats of a unit
	public function lowerStats(hp:Int, atk:Int, rng:Int, mv:Int, spd:Int)
	{
		currStats.subtractStat(new Stats(hp, atk, 0, rng, mv, spd));
		hover.updateHover();
	}

	// Raises corresponding current stats of a unit
	public function raiseStats(hp:Int, atk:Int, rng:Int, mv:Int, spd:Int)
	{
		currStats.addStat(new Stats(hp, atk, 0, rng, mv, spd));
		hover.updateHover();
	}

	public function isAlive():Bool
	{
		return currStats.hp > 0;
	}

	public function is_weapon_slot_free()
	{
		if (!weaponSlot1.isOccupied)
		{
			return true;
		}

		if (!weaponSlot2.isOccupied)
		{
			return true;
		}
		return false;
	}

	public function weapon_slot()
	{
		if (!weaponSlot1.isOccupied)
		{
			return weaponSlot1;
		}

		if (!weaponSlot2.isOccupied)
		{
			return weaponSlot2;
		}
		return null;
	}

	override function rendering_order()
	{
		if (clicked)
		{
			return 1;
		}
		return 0;
	}

	override function reset(x:Float, y:Float):Void
	{
		super.reset(this.x, this.y);
		healthBar.reset(healthBar.x, healthBar.y);
		if (weaponSlot1.isOccupied)
		{
			weaponSlot1.attachedSnappable.reset(weaponSlot1.attachedSnappable.x, weaponSlot1.attachedSnappable.y);
		}

		if (weaponSlot2.isOccupied)
		{
			weaponSlot2.attachedSnappable.reset(weaponSlot2.attachedSnappable.x, weaponSlot2.attachedSnappable.y);
		}
	}

	// called when this snappable was hovered over. Used to display stats about this snappable.
	override function mouseOver(object:FlxSprite)
	{
		trace("mouse over");
		isBeingHovered = true;
		// showHover(this.hover);
	}

	// called when this snappable stopped being hovered over. Used to stop displaying stats about this snappable.
	override function mouseOut(object:FlxSprite)
	{
		isBeingHovered = false;
		// hideHover(this.hover);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		this.healthBar.currHP = currStats.hp;
		healthBar.setRange(0, maxHp);

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
			this.hover.x = Math.min(this.x + 48 + 20 + 48 * this.currStats.maxRng, 528);
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

	override public function kill():Void
	{
		super.kill();
		if (weaponSlot1.isOccupied)
		{
			weaponSlot1.attachedSnappable.kill();
		}

		if (weaponSlot2.isOccupied)
		{
			weaponSlot2.attachedSnappable.kill();
		}

		healthBar.kill();
	}

	public function updateStats()
	{
		resetStats();
		hover.updateHover();
	}

	override public function getInfo()
	{
		var title = unitName.toUpperCase() + " (" + UnitData.unitToRarity[unitID] + ")";
		var body = "";
		body = body + "Health: " + currStats.hp + "/" + maxHp + "\n";
		body = body + "Attack: " + currStats.atk + "\n";
		body = body + "Moves: " + currStats.mv + "\n";
		if (currStats.minRng == 1)
		{
			body = body + "Range: " + currStats.maxRng + "\n";
		}
		else
		{
			body = body + "Range: " + currStats.minRng + "-" + currStats.maxRng + "\n";
		}
		var abilities = UnitData.unitIdToAbility(unitID, this);
		if (abilities.length > 0)
		{
			for (i in 0...abilities.length)
			{
				body += (i + 1) + ". " + abilities[i] + "\n";
			}
		}
		return {title: title, body: body, rarity: UnitData.unitToRarity[unitID]};
	}
}
