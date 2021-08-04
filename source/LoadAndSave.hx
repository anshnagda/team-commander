import attachingMechanism.SnappableInfo;
import entities.Unit;
import entities.Weapon;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import js.Browser;
import states.ShopState;
import staticData.Font;

class LoadAndSave
{
	private var player:PlayerState;
	private var sav:FlxSave;

	public function new(player:PlayerState)
	{
		this.player = player;
		sav = new FlxSave();
		sav.bind("TCSaveFile");
		if (sav.data.runID != null)
		{
			this.player.runID = sav.data.runID + 1;
		}
		else
		{
			this.player.runID = 0;
		}
		if (sav.data.cleared != null && sav.data.cleared)
		{
			this.player.clearedOnce = true;
		}
	}

	public function save()
	{
		var units = new Array<Int>();
		var weapons = new Array<Int>();

		player.allied_units.forEach((u) -> units.push(cast(u, Unit).unitID));
		player.weapons.forEach((w) -> weapons.push(cast(w, Weapon).weaponID));

		sav.data.stage = player.current_stage;
		sav.data.level = player.current_level;
		sav.data.units = units;
		sav.data.weapons = weapons;
		sav.data.gold = player.gold;
		sav.data.unit_capacity = player.unit_capcity;
		sav.data.unitInShop = player.unitInShop;
		sav.data.rerollCost = player.rerollCost;
		sav.data.firstTimeLose = player.firstTimeLose;
		sav.data.firstTimShop = player.firstTimeShop;
		sav.data.numberOfLosses = player.numberOfLosses;
		sav.data.livesRemaining = player.livesRemaining;
		sav.data.loseMult = player.loseMult;
		sav.data.winMult = player.winMult;
		sav.data.cleared = player.clearedOnce;
		sav.data.runID = player.runID;
		// var serializer = new Serializer();
		// serializer.serialize(sav.data);
		StoreData.tryStore("SaveInfo", Serializer.run(sav.data));
		// Browser.window.localStorage.setItem("teamCommanderSaveInfo", Serializer.run(sav.data));
		// sav.flush();
	}

	public function load()
	{
		var ser = StoreData.tryLoad("SaveInfo");
		if (ser == null)
		{
			return false;
		}

		var data = Unserializer.run(ser);

		this.player.allied_units.clear();
		this.player.weapons.clear();

		player.current_level = data.level;
		player.current_stage = data.stage;

		var units:Array<Int> = data.units;
		for (uid in units)
		{
			player.addUnit(new Unit(0, 0, uid, player.closestUnitSlotCoords));
		}

		var weapons:Array<Int> = data.weapons;
		for (wid in weapons)
		{
			player.addWeapon(new Weapon(0, 0, wid, player.closestWeaponSlotCoords));
		}

		player.gold = data.gold;

		player.unit_capcity = data.unit_capacity;

		var uInShop:Array<Int> = data.unitInShop;

		if (uInShop != null)
		{
			player.unitInShop = new Array<Int>();
			for (uid in uInShop)
			{
				player.unitInShop.push(uid);
			}
			var i = 0;
			player.unitPriceInShop = new Array<FlxText>();
			for (uid in player.unitInShop)
			{
				var unit = new Unit(0, 0, uid, null);
				var price = ShopState.PRICE[unit.rarity];
				player.unitPriceInShop.push(Font.makeText(ShopState.SHOP_X
					+ 10
					+ i * (10 + SnappableInfo.IMAGE_WIDTH)
					- SnappableInfo.IMAGE_WIDTH / 2,
					ShopState.SHOP_Y
					+ 70
					+ SnappableInfo.IMAGE_HEIGHT, SnappableInfo.IMAGE_WIDTH, price
					+ " Gold", 32));
				i++;
			}
		}

		player.rerollCost = data.rerollCost;
		player.firstTimeLose = data.firstTimeLose;
		player.firstTimeShop = data.firstTimeShop;
		player.numberOfLosses = data.numberOfLosses;
		player.livesRemaining = data.livesRemaining;
		player.loseMult = data.loseMult;
		player.winMult = data.winMult;
		player.clearedOnce = data.cleared;
		player.runID = data.runID;
		return true;
	}
}
