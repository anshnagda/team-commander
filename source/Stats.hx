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

	var eva:Int = 0;
	var shield:Int = 0;
	var crit:Int = 0;
	var lifeSteal:Int = 0;
	var damageReductionMaxHp:Int = 0;
	var damageReduction:Int = 0;

	var pushbackPerAtt:Int = 0;

	public function new(hp:Int, atk:Int, minRng:Int, maxRng:Int, mv:Int, spd:Int, eva:Int = 0, lifesteal:Int = 0, damageReduction:Int = 0,
			pushbackPerAtt:Int = 0, damageReductionMaxHp:Int = 0)
	{
		this.hp = hp;
		this.atk = atk;
		this.minRng = minRng;
		this.maxRng = maxRng;
		this.mv = mv;
		this.spd = spd;
		this.eva = eva;
		this.lifeSteal = lifesteal;
		this.damageReduction = damageReduction;
		this.damageReductionMaxHp = damageReductionMaxHp;
		this.pushbackPerAtt = pushbackPerAtt;
	}

	public function copy()
	{
		var res = new Stats(hp, atk, minRng, maxRng, mv, spd, eva, lifeSteal, damageReduction, pushbackPerAtt, damageReductionMaxHp);
		res.shield = this.shield;
		res.crit = this.crit;
		return res;
	}

	public static function WeaponStat(hp:Int, atk:Int, rng:Int, mv:Int, spd:Int, eva:Int = 0, lifesteal:Int = 0, damageReduction:Int = 0,
			pushbackPerAtt:Int = 0)
	{
		return new Stats(hp, atk, 0, rng, mv, spd, eva, lifesteal, damageReduction, pushbackPerAtt);
	}

	public function addStat(other:Stats)
	{
		hp += other.hp;
		atk += other.atk;
		minRng += other.minRng;
		maxRng += other.maxRng;
		mv += other.mv;
		spd += other.spd;

		eva *= other.eva;
		shield += other.shield;
		crit += other.crit;
		lifeSteal += other.lifeSteal;
		damageReduction *= other.damageReduction;
		//damageReduction = Std.int(Math.min(damageReduction, 90));
		damageReductionMaxHp *= other.damageReductionMaxHp;
		//damageReductionMaxHp = Std.int(Math.min(damageReductionMaxHp, 90));
		this.pushbackPerAtt += other.pushbackPerAtt;
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

		eva -= other.eva;
		eva = cast(Math.max(0, eva), Int);
		shield -= other.shield;
		shield = cast(Math.max(0, shield), Int);
		crit -= other.crit;
		crit = cast(Math.max(0, crit), Int);
		lifeSteal -= other.lifeSteal;
		lifeSteal = cast(Math.max(0, lifeSteal), Int);
		damageReduction -= other.damageReduction;
		damageReduction = cast(Math.max(0, damageReduction), Int);

		damageReductionMaxHp -= other.damageReductionMaxHp;
		damageReductionMaxHp = cast(Math.max(0, damageReductionMaxHp), Int);
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
		map.set("Dmg Reduction", damageReduction);
		map.set("Knockback", pushbackPerAtt);
		map.set("Evasion %", eva);
		map.set("Critical %", crit);
		map.set("Lifesteal %", lifeSteal);

		return map;
	}
}
