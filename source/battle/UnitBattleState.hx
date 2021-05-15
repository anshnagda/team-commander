package battle;

import entities.Unit;


class UnitBattleState {
    public var unit:Unit;
    public var coor:Point;
    public var numAttDone:Int;
    public var buff:Map<Stats, Int>;  // maps current buff ID to number of turns left
    public var firstRound = true;

    public function new(currCoor:Point, unit:Unit) {
        this.coor = currCoor;
        this.numAttDone = 0;
        this.buff = new Map<Stats, Int>();
        this.unit = unit;
    }

    public function updateCoor(newCoor:Point) {
        this.coor = newCoor;
    }

    public function attacked() {
        this.numAttDone++;
        for (b in buff.keys()) {
            buff[b]--;
            if (buff[b] == 0) {
                removeBuff(b);
            }
        }
    }

    public function getCoor() {
        return coor;
    }

    public function applyBuff(buf:Stats, duration:Int) {
        buff[buf] = duration;
        addBuff(buf);
    }

    private function removeBuff(buf:Stats) {
        unit.currStats.subtractStat(buf);
    }

    private function addBuff(buf:Stats) {
        unit.currStats.addStat(buf);
    }
}