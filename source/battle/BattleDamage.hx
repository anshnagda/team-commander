package battle;

// a data class that keeps track the type of damage dealt during battle
class BattleDamage {
    public var normDamage = 0;
    public var trueDamage = 0;

    public function new(damageNorm:Int = 0, trueDamage:Int = 0) {
        this.normDamage = damageNorm;
        this.trueDamage = trueDamage;
    }
}