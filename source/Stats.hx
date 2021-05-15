package;

import openfl.utils.IAssetCache;

@:publicFields
class Stats
{
	var hp:Int = 0;
	var atk:Int = 0;
	var minRng:Int = 0;
	var maxRng:Int = 0;
	var mv:Int = 0;
	var spd:Int = 0;

	public function new(hp:Int, atk:Int, minRng:Int, maxRng:Int, mv:Int, spd:Int)
	{
		this.hp = hp;
		this.atk = atk;
		this.minRng = minRng;
		this.maxRng = maxRng;
		this.mv = mv;
		this.spd = spd;
	}

	public function copy()
	{
		return new Stats(hp, atk, minRng, maxRng, mv, spd);
	}

	public static function WeaponStat(hp:Int, atk:Int, rng:Int, mv:Int, spd:Int)
	{
		return new Stats(hp, atk, 0, rng, mv, spd);
	}

	public function addStat(other:Stats)
	{
		hp += other.hp;
		atk += other.atk;
		minRng += other.minRng;
		maxRng += other.maxRng;
		mv += other.mv;
		spd += other.spd;
	}

	public function subtractStat(other:Stats)
	{
		hp -= other.hp;
		hp = cast(Math.max(0, hp), Int);
		atk -= other.atk;
		atk = cast(Math.max(0, atk), Int);
		minRng -= other.minRng;
		minRng = cast(Math.max(0, minRng), Int);
		maxRng -= other.maxRng;
		maxRng = cast(Math.max(0, maxRng), Int);
		mv -= other.mv;
		mv = cast(Math.max(1, mv), Int);
		spd -= other.spd;
		spd = cast(Math.max(0, spd), Int);
	}

	public function toMap()
	{
		var map = new Map<String, Int>();
		map.set("HP", hp);
		map.set("Attack", atk);
		if (minRng != 0)
		{
			map.set("Minimum Range", minRng);
		}
		map.set("Maximum Range", maxRng);
		map.set("Moves", mv);
		map.set("Speed", spd);

		return map;
	}

	public function toMapWeapon()
	{
		var map = new Map<String, Int>();
		map.set("HP", hp);
		map.set("Attack", atk);
		map.set("Range", maxRng);
		map.set("Moves", mv);
		map.set("Speed", spd);

		return map;
	}
}
