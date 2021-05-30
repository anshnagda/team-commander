package states;

import attachingMechanism.Snappable;
import attachingMechanism.SnappableInfo;
import entities.TutorialBox;
import entities.Unit;
import entities.Weapon;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import haxe.Timer;
import nape.geom.AABB;
import rewardCards.UnitCard;
import rewardCards.WeaponCard;
import staticData.Buttons;
import staticData.Font;

class ShopState extends BenchAndInventoryState
{
	public static inline var SHOP_X = 50 + 48;
	public static inline var SHOP_Y = 30;
	public static inline var SHOP_SIZE = 8 * 48;
	public static var PRICE = [100, 225, 700];

	public static var SELL_BOARD_X = SHOP_X;
	public static var SELL_BOARD_Y = 380;
	public static var SELL_BOARD_WIDTH = 240;
	public static var SELL_BOARD_HEIGHT = 96;

	var background:FlxSprite;

	var rerollOptions:Array<Int>;
	var purchased:Array<Unit>;

	var rerollBtn:FlxButtonPlus;
	var return_button:FlxButtonPlus;
	var open_merge_button:FlxButtonPlus;

	var sell_sprite:FlxSprite;
	var sell_text:FlxText;

	var playerGold:FlxText;

	var color:FlxColor;

	var big_box:FlxSprite;
	var currentInShop:Array<UnitCard>;

	public var tutorial_boxes:Array<TutorialBox>;

	public function new(playerState:PlayerState, backToLevel:Function, openMergeCallback:Function)
	{
		super(playerState, backToLevel);

		rerollOptions = [10, 25, 50, 100, 200, 400];
		purchased = new Array<Unit>();
		playerState.inShope = true;
		playerState.sellSlot.attachCallback = sell;

		this.return_button = Buttons.makeButton(playerState.inventory.x + 40, 400, 64, 32, return_to_level, "RETURN", 16);
		this.open_merge_button = Buttons.makeButton(playerState.inventory.x + 40, 450, 64, 32, function()
		{
			removeAll();
			openMergeCallback();
		}, "MERGE", 16);

		this.currentInShop = new Array<UnitCard>();

		this.sell_sprite = new FlxSprite(SELL_BOARD_X, SELL_BOARD_Y);
		sell_sprite.loadGraphic("assets/images/sell_board.png");
		this.sell_text = Font.makeText(SELL_BOARD_X + 10, SELL_BOARD_Y + 30, SELL_BOARD_WIDTH - 20, "DRAG UNIT/WEAPON HERE TO SELL", 32);
	}

	override function removeAll()
	{
		super.removeAll();
		for (i in 0...currentInShop.length)
		{
			var card = currentInShop[i];
			remove(card);
			remove(card.getUnit());
			remove(card.getUnit().healthBar);
			remove(card.getUnit().hover);
			remove(card.getTexts());
			remove(playerState.unitPriceInShop[i]);
		}

		for (unit in purchased)
		{
			remove(unit);
		}
		playerState.inShope = false;

		for (unit in playerState.allied_units)
		{
			var unit = cast(unit, Unit);
			remove(unit.price);
		}

		for (weapon in playerState.weapons)
		{
			var weapon = cast(weapon, Weapon);
			remove(weapon.price);
		}
	}

	function return_to_level()
	{
		removeAll();
		endLevel(true);
	}

	// populate the product section based on current stage
	private function populateProducts(stage:Int)
	{
		var t1 = 0;
		var t2 = 0;
		var t3 = 0;
		switch stage
		{
			case 1:
				t1 = 100;
			case 2:
				t1 = 90;
				t2 = 10;
			case 3:
				t1 = 75;
				t2 = 25;
				t3 = 0;
			case 4:
				t1 = 60;
				t2 = 30;
				t3 = 10;
			case 5:
				t1 = 50;
				t2 = 35;
				t3 = 15;
		}
		for (i in 0...3)
		{
			var card = new UnitCard(SHOP_X + 10 + i * (10 + SnappableInfo.IMAGE_WIDTH), SHOP_Y + 50 + SnappableInfo.IMAGE_HEIGHT / 2, t1, t2, t3, bought,
				false);
			this.playerState.unitInShop.push(card.getUnit().unitID);
			this.currentInShop.push(card);
		}

		for (i in 0...3)
		{
			var price = PRICE[currentInShop[i].getUnit().rarity];
			playerState.unitPriceInShop.push(Font.makeText(SHOP_X
				+ 10
				+ i * (10 + SnappableInfo.IMAGE_WIDTH)
				- SnappableInfo.IMAGE_WIDTH / 2,
				SHOP_Y
				+ 70
				+ SnappableInfo.IMAGE_HEIGHT, SnappableInfo.IMAGE_WIDTH, price
				+ " Gold", 32));
		}
	}

	override public function create()
	{
		// add in background
		background = new FlxSprite(-200, -150);
		background.loadGraphic("assets/images/shopbg.jpg");
		background.setGraphicSize(800, 700);
		background.alpha = 0.7;
		add(background);
		add(sell_sprite);
		add(sell_text);

		var currentLevelText = Font.makeText(SHOP_X, 50, (SnappableInfo.IMAGE_WIDTH + 10) * 3, "SHOP", 64);

		add(currentLevelText);
		add(return_button);
		if (playerState.current_level >= 4 || playerState.current_stage >= 2 || Main.DEV_ENABLED)
		{
			add(open_merge_button);
		}

		if (playerState.unitInShop == null)
		{
			playerState.rerollCost = 0;
			playerState.unitInShop = new Array<Int>();
			playerState.unitPriceInShop = new Array<FlxText>();
			populateProducts(playerState.current_stage);
		}
		else
		{
			buildProductFromID();
		}

		playerGold = Font.makeText(40, 20, 300, "GOLD: " + playerState.gold, 32, FlxColor.fromInt(0xFFD700), FlxTextAlign.LEFT);
		add(playerGold);

		this.rerollBtn = Buttons.makeButton(415, 400, 96, 48, reroll, "Reroll", 16);
		rerollBtn.textNormal = Font.makeText(415, 407, 96, "Reroll\n(" + rerollOptions[playerState.rerollCost] + " Gold)", 16, FlxColor.WHITE);
		rerollBtn.textHighlight = Font.makeText(415, 415, 96, rerollOptions[playerState.rerollCost] + " Gold", 16, FlxColor.WHITE);
		add(rerollBtn);

		displayProduct();
		super.create();

		if (this.playerState.firstTimeShop && PlayerState.tutorial)
		{
			this.playerState.firstTimeShop = false;
			this.tutorial_boxes = [
				new TutorialBox("Welcome to the Shop! You can buy and sell units here.", 300, 225, "assets/images/box.png"),
				new TutorialBox("The products will be rerolled after each level.", 300, 255, "assets/images/box.png"),
				new TutorialBox("You can also spend money to reroll the products.", 300, 255, "assets/images/box.png"),
				new TutorialBox("Be careful! Price of rerolling increases as you reroll more and more!", 300, 255, "assets/images/box.png")
			];
			big_box = new FlxSprite(0, 0);
			big_box.makeGraphic(800, 600, FlxColor.BLACK);
			big_box.alpha = 0.3;

			add(big_box);

			add(tutorial_boxes[0]);

			FlxMouseEventManager.add(big_box, onClickTutorial, null, null, null);
		}

		for (unit in playerState.allied_units)
		{
			var unit = cast(unit, Unit);
			add(unit.price);
		}
		for (weapon in playerState.weapons)
		{
			var weapon = cast(weapon, Weapon);
			add(weapon.price);
		}
	}

	function onClickTutorial(spr:FlxSprite):Void
	{
		var previous_box = tutorial_boxes.shift();
		remove(previous_box);
		if (tutorial_boxes.length > 0)
		{
			add(tutorial_boxes[0]);
		}
		else
		{
			remove(big_box);
			FlxMouseEventManager.remove(big_box);
		}
	}

	private function displayProduct()
	{
		// put up all cards
		for (i in 0...currentInShop.length)
		{
			var card = currentInShop[i];
			card.clickable = true;
			add(card);
			add(card.getUnit());
			add(card.getTexts());

			add(playerState.unitPriceInShop[i]);
		}
	}

	private function buildProductFromID()
	{
		playerState.unitPriceInShop = new Array<FlxText>();
		for (i in 0...this.playerState.unitInShop.length)
		{
			this.currentInShop.push(new UnitCard(SHOP_X + 10 + i * (10 + SnappableInfo.IMAGE_WIDTH), SHOP_Y + 50 + SnappableInfo.IMAGE_HEIGHT / 2, 0, 0, 0,
				bought, true, this.playerState.unitInShop[i]));

			var price = PRICE[currentInShop[i].getUnit().rarity];
			playerState.unitPriceInShop.push(Font.makeText(SHOP_X
				+ 10
				+ i * (10 + SnappableInfo.IMAGE_WIDTH)
				- SnappableInfo.IMAGE_WIDTH / 2,
				SHOP_Y
				+ 70
				+ SnappableInfo.IMAGE_HEIGHT, SnappableInfo.IMAGE_WIDTH, price
				+ " Gold", 32));
		}
	}

	// if the player decided to buy this unit
	private function bought()
	{
		var selected = null;
		var priceToBeRemoved = null;
		for (i in 0...currentInShop.length)
		{
			var card = currentInShop[i];
			if (card == null)
			{
				continue;
			}
			if (card.selected)
			{
				if (playerState.gold < PRICE[card.getUnit().rarity])
				{ // check if there's enough money
					// cannot buy
					card.selected = false;
					card.clickable = true;
					this.color = card.color;
					card.color = FlxColor.RED;
					Timer.delay(convertBack, 2000);
					var notice = new TutorialBox("Not enough money.", 300, 225, "assets/images/box.png");
					add(notice);
					Timer.delay(() -> remove(notice), 2000);
					continue;
				}

				if (playerState.allied_units.length >= 10)
				{
					card.selected = false;
					card.clickable = true;
					this.color = card.color;
					card.color = FlxColor.RED;
					Timer.delay(convertBack, 2000);
					var notice = new TutorialBox("Your bench is full. Try again after you sell a unit.", 300, 225, "assets/images/box.png");
					add(notice);
					Timer.delay(() -> remove(notice), 2000);
					continue;
				}

				selected = card;
				priceToBeRemoved = playerState.unitPriceInShop[i];

				// have enough money
				remove(card);
				remove(card.getTexts());
				remove(playerState.unitPriceInShop[i]);

				// put the new unit on the bench
				playerState.addUnit(card.getUnit());
				playerState.removeGold(PRICE[card.getUnit().rarity]);
				card.getUnit().findSlot = this.playerState.closestUnitSlotCoords;

				// log the unit purchase
				if (!Main.DEV_ENABLED)
				{
					playerState.log.logLevelAction(2, card.getUnit().unitName);
				}

				// makeUnitsHB(card.getUnit());   // causing problems at force attach
				// card.getUnit().clickable = true;
				// purchased.push(card.getUnit());
				super.removeAll();
				for (unit in playerState.allied_units)
				{
					var unit = cast(unit, Unit);
					remove(unit.price);
				}
				remove(card.getUnit());
				super.create();
				for (unit in playerState.allied_units)
				{
					var unit = cast(unit, Unit);
					add(unit.price);
				}
			}
		}
		if (selected == null)
		{
			return;
		}
		currentInShop.remove(selected);
		this.playerState.unitInShop.remove(selected.getUnit().unitID);
		playerState.unitPriceInShop.remove(priceToBeRemoved);
		updateGold();
	}

	// reroll the shop page
	private function reroll()
	{
		if (playerState.gold < rerollOptions[playerState.rerollCost])
		{ // no money to reroll
			rerollBtn.textNormal = Font.makeText(415, 415, 96, "NO $$", 16, FlxColor.RED);
			rerollBtn.textHighlight = Font.makeText(415, 415, 96, "NO $$", 16, FlxColor.RED);
			Timer.delay(convertBack, 1500);
		}
		else
		{
			// make reroll more expensive
			playerState.removeGold(rerollOptions[playerState.rerollCost]);
			if (playerState.rerollCost < rerollOptions.length - 1)
			{
				playerState.rerollCost++;
			}
			rerollBtn.textNormal = Font.makeText(415, 407, 96, "Reroll (" + rerollOptions[playerState.rerollCost] + " Gold)", 16, FlxColor.WHITE);
			rerollBtn.textHighlight = Font.makeText(415, 407, 96, "Reroll (" + rerollOptions[playerState.rerollCost] + " Gold)", 16, FlxColor.WHITE);

			// remove all cards on screen
			for (i in 0...currentInShop.length)
			{
				var card = currentInShop[i];
				remove(card);
				remove(card.getUnit());
				remove(card.getTexts());
				remove(playerState.unitPriceInShop[i]);
			}

			playerState.unitInShop = new Array<Int>();
			playerState.unitPriceInShop = new Array<FlxText>();
			currentInShop = new Array<UnitCard>();
			populateProducts(playerState.current_stage);
			displayProduct();
			updateGold();
		}
	}

	private function updateGold()
	{
		remove(playerGold);
		playerGold = Font.makeText(40, 20, 300, "GOLD: " + playerState.gold, 32, FlxColor.fromInt(0xFFD700), FlxTextAlign.LEFT);
		add(playerGold);
	}

	// change button texts back
	private function convertBack()
	{
		rerollBtn.textNormal = Font.makeText(415, 407, 96, "Reroll (" + rerollOptions[playerState.rerollCost] + " Gold)", 16, FlxColor.WHITE);
		rerollBtn.textHighlight = Font.makeText(415, 415, 96, rerollOptions[playerState.rerollCost] + " Gold", 16, FlxColor.WHITE);
		for (card in currentInShop)
		{
			card.color = this.color;
		}
	}

	private function sell(item:Snappable)
	{
		if (Std.is(item, Unit))
		{
			// sell a unit
			var unit = cast(item, Unit);
			playerState.removeUnit(unit);

			unit.isBeingHovered = false;
			unit.hideHover();
			remove(unit);
			remove(unit.healthBar);
			remove(unit.hover);
			remove(unit.price);
			unit.disable();

			playerState.addGold(Std.int(PRICE[unit.rarity] / 2));

			// log the unit sale
			if (!Main.DEV_ENABLED)
			{
				playerState.log.logLevelAction(3, unit.unitName);
			}
		}
		else
		{
			var weap = cast(item, Weapon);
			playerState.removeWeapon(weap);
			weap.disable();

			weap.isBeingHovered = false;
			weap.hideHover();
			remove(weap);
			remove(weap.hover);

			playerState.addGold(Std.int(PRICE[weap.rarity] / 4));

			// log the weapon sale
			if (!Main.DEV_ENABLED)
			{
				playerState.log.logLevelAction(4, weap.weaponName);
			}
		}
		this.playerState.sellSlot.detach();
		updateGold();
	}
}
