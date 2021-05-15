package states;

import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import entities.*;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeVelocity;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import grids.*;
import haxe.Constraints.Function;
import js.html.Console;
import rewardCards.Card;
import rewardCards.UnitCard;
import rewardCards.WeaponCard;
import staticData.Font;

// Class that will render the reward page
class RewardState extends FlxState
{
	public static inline var CARD_LEFT_PADDING:Int = 150;
	public static inline var CARD_UP_PADDING:Int = 50;
	public static inline var CARD_GAP:Int = 50;
	public static inline var CARD_X_CENTER:Int = 364;
	public static inline var CARD_Y:Int = CARD_UP_PADDING + 184;

	var endRewardCallBack:Function;
	var player:PlayerState;
	var unitToChoose:Array<UnitCard>;
	var weaponToChoose:Array<WeaponCard>;
	var unitChosen:Unit;
	var weaponChosen:Weapon;

	public function new(playerState:PlayerState, endRewardCallBack:Function)
	{
		super();
		this.player = playerState;
		this.endRewardCallBack = endRewardCallBack;
	}

	override public function create()
	{
		super.create();
		// check the current stage
		var stage = this.player.current_stage;
		var level = this.player.current_level;
		unitToChoose = new Array<UnitCard>();
		weaponToChoose = new Array<WeaponCard>();

		var text = Font.makeText(0, 50, 800, "Pick a Reward", 64);
		Font.setFormat(text, 64, 0xd2ed05, FlxTextAlign.CENTER);
		add(text);
		// call populate
		populate(unitToChoose, weaponToChoose, stage, level);
		// testing
		//--------- start --------------
		//---------- end ------------

		var returnButton = new FlxButton(650, 550, "Next Stage", returnToLevel);
		add(returnButton);
	}

	function returnToLevel()
	{
		remove(unitChosen);
		remove(weaponChosen);
		endRewardCallBack();
	}

	// for unit selection
	// remove other unselected cards, I'll find a way to factorize unit and weapon cards
	function selectedUnit()
	{
		var i = 1;
		for (card in unitToChoose)
		{
			if (card.isSelected())
			{
				card.getUnit().findSlot = this.player.closestUnitSlotCoords;
				card.getUnit().enable();
				this.player.addUnit(card.getUnit());
				unitChosen = card.getUnit();
				var targetX = card.x + (2 - i) * 204;
				var targetY = card.y;
				FlxTween.tween(card, {x: targetX, y: targetY}, 0.5);
			}
			else
			{
				remove(card);
				remove(card.getUnit());
				remove(card.getTexts());
			}
			i++;
		}
	}

	// for weapon selection
	// remove other unselected cards, I'll find a way to factorize unit and weapon cards
	function selectedWeapon()
	{
		var i = 1;
		for (card in weaponToChoose)
		{
			var card = cast(card, WeaponCard);
			if (card.isSelected())
			{
				card.getWeapon().findSlot = this.player.closestUnitSlotCoords;
				card.getWeapon().enable();
				this.player.addWeapon(card.getWeapon());
				weaponChosen = card.getWeapon();
				var targetX = card.x + (2 - i) * 204;
				var targetY = card.y;
				FlxTween.tween(card, {x: targetX, y: targetY}, 0.5);
			}
			else
			{
				remove(card);
				remove(card.getWeapon());
				remove(card.getTexts());
			}
			i++;
		}
	}

	// populate 3 weapons onto the screen to let the player to choose
	private function populateWeapon(rewardToChoose:Array<WeaponCard>, t1:Int, t2:Int, t3:Int)
	{
		for (i in 0...3)
		{
			var card = new WeaponCard(i * (SnappableInfo.IMAGE_WIDTH + CARD_GAP) + CARD_LEFT_PADDING, CARD_Y, 100, 0, 0, selectedWeapon);
			rewardToChoose.push(card);
			add(card);
			add(card.getWeapon());
			add(card.getTexts());
		}
	}

	// populate 3 units onto the screen to let the player to choose
	private function populateUnit(rewardToChoose:Array<UnitCard>, t1:Int, t2:Int, t3:Int)
	{
		for (i in 0...3)
		{
			var card = new UnitCard(i * (SnappableInfo.IMAGE_WIDTH + CARD_GAP) + CARD_LEFT_PADDING, CARD_Y, 100, 0, 0, selectedUnit, false);
			rewardToChoose.push(card);
			add(card);
			add(card.getUnit());
			add(card.getTexts());
		}
	}

	private function populateStaticReward(goldReceived:Int)
	{
		var text = new flixel.text.FlxText(150, 400, 0, goldReceived + " Gold Received");
		Font.setFormat(text, 32, 0xffffff);
		text.borderColor = FlxColor.YELLOW;
		text.borderStyle = FlxTextBorderStyle.OUTLINE;
		this.player.addGold(goldReceived);
		add(text);
	}

	private function increaseUnitCap()
	{
		var text1 = new flixel.text.FlxText(150, 450, 0, "Unit Capcity + 1");
		Font.setFormat(text1, 32, 0xffffff);
		text1.borderColor = FlxColor.CYAN;
		text1.borderStyle = FlxTextBorderStyle.OUTLINE;
		this.player.addUnitCapacity();
		add(text1);
	}

	// for weapon selection
	// similar to selectedUnit
	// fixedReward: like +50 gold, + 1 unit capacity etc (no need to choose)
	// rewardToChoose: those that need players to choose among 3 options
	// This function will randomly generate (based on current stage and level) the rewards that player could choose from.
	// It will also give out the correct static reward for each stage.
	private function populate(unitToChoose:Array<UnitCard>, weaponToChoose:Array<WeaponCard>, stage:Int, level:Int)
	{
		switch stage
		{
			case 1:
				switch level
				{
					case 1:
						var newUnit = new UnitCard(CARD_X_CENTER, CARD_Y, 100, 0, 0, selectedUnit, true);
						add(newUnit);
						add(newUnit.getTexts());
						add(newUnit.getUnit());
						this.player.addUnit(newUnit.getUnit());
						unitChosen = newUnit.getUnit();
						increaseUnitCap();
					case 2:
						populateWeapon(weaponToChoose, 100, 0, 0);
					case 3:
						// unit cards to choose
						populateUnit(unitToChoose, 100, 0, 0);
						var text2 = new flixel.text.FlxText(150, 500, 0, "Merge Tool Unlocked!");
						Font.setFormat(text2, 32, 0xffffff);
						text2.borderColor = FlxColor.CYAN;
						text2.borderStyle = FlxTextBorderStyle.OUTLINE;
						add(text2);

					case 4:
						// unit capacity++
						populateUnit(unitToChoose, 100, 0, 0);
						populateStaticReward(100);
						increaseUnitCap();
						var text2 = new flixel.text.FlxText(150, 500, 0, "Shop Unlocked!");
						Font.setFormat(text2, 32, 0xffffff);
						text2.borderColor = FlxColor.CYAN;
						text2.borderStyle = FlxTextBorderStyle.OUTLINE;
						add(text2);
						trace(this.player.allied_units);
				}
			case 2:
				if (level <= 2)
				{
					// weapon cards (100, 0, 0)
					// fixed Gold + 50
					populateWeapon(weaponToChoose, 100, 0, 0);
					populateStaticReward(50);
				}
				else if (level == 3)
				{
					// random unit fixed card
					// fixed Gold + 100
					// weapon cards(100, 0, 0)
					populateWeapon(weaponToChoose, 100, 0, 0);
					populateStaticReward(100);
				}
				else
				{ // BOSS
					// random weapon(0, 100, 0) fixed card
					// fixed gold + 200
					// unit capacity++
					populateStaticReward(200);
					increaseUnitCap();
					populateWeapon(weaponToChoose, 0, 100, 0);
				}
			case 3: // to be added
			case 4: // to be added
			case 5: // to be added
			case _:
				return false;
		}
		return true;
	}
}
