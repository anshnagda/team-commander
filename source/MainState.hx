import entities.TutorialBox;
import entities.Unit;
import entities.Weapon;
import entities.Weapon;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import haxe.Timer;
import js.html.Console;
import js.html.FontFaceSetLoadEvent;
import states.*;
import states.TutorialLevelState.LevelStateTutorial;
import staticData.*;

class MainState extends FlxState
{
	public static inline var MAX_STAGE = 5;

	var playButton:FlxButtonPlus;
	var playerState:PlayerState;
	var rand:FlxRandom;
	var startTime:Float;

	var started:Bool = false;
	var existedImg:Array<FlxSprite> = new Array<FlxSprite>();
	var extedButtons:Array<FlxButtonPlus> = new Array<FlxButtonPlus>();

	var save:LoadAndSave;
	var diff:Int = 0;

	// var shopState:ShopState;
	// var mergeState:MergeState;
	// var currentMainSequenceStage:FlxState; // stores the current main sequence stage (level, reward, event)

	override public function create()
	{
		super.create();
		FlxG.plugins.add(new FlxMouseEventManager());
		this.rand = new FlxRandom();
		playerState = new PlayerState();
		// Initialize sound
		Main.sound.volume = 0.2;
		var background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/coverpage.jpg");
		add(background);

		var logo = new FlxSprite(70, 10);
		logo.loadGraphic("assets/images/logo.png");
		add(logo);
		save = new LoadAndSave(playerState);
		trace(playerState.runID);
		if (!playerState.sectionStarted && !Main.DEV_ENABLED)
		{
			playerState.log.startNewSession(this.playerState.userID, initCover);
			playerState.sectionStarted = true;
		}
		else
		{
			initCover(true);
		}

		var ret = StoreData.tryLoad("volume");
		if (ret != null)
		{
			Main.sound.volume = Std.parseFloat(ret);
		}

		var ret = StoreData.tryLoad("tutorial");
		if (ret != null)
		{
			if (ret == "false")
			{
				PlayerState.tutorial = false;
			}
		}
	}

	function initCover(suc:Bool)
	{
		makeImgButtonPlus(50, 300, gameStart, "START", 32);

		makeImgButtonPlus(50, 400, load, "LOAD", 32);

		makeImgButtonPlus(50, 500, setting, "SETTINGS", 32);
	}

	function removeAllButtons()
	{
		for (i in extedButtons)
		{
			remove(i);
			i.destroy();
		}
		for (i in existedImg)
		{
			remove(i);
		}
		existedImg = new Array<FlxSprite>();
		extedButtons = new Array<FlxButtonPlus>();
	}

	function gameStart()
	{
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logActionWithNoLevel(100, "GAME START");
		}
		selectDifficulty();
	}

	function load()
	{
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logActionWithNoLevel(200, "LOAD");
		}
		removeAllButtons();
		trace("tried load");
		try
		{
			if (save.load())
			{
				clickPlay();
			}
			else
			{
				loadMsg("No saved data found.");
			}
		}
		catch (e)
		{
			loadMsg("Cannot Load Saved Data.");
			trace(e);
		}
	}

	function loadMsg(msg:String)
	{
		var notice = new TutorialBox(msg, 300, 225, "assets/images/box.png", false);
		add(notice);
		Timer.delay(() -> remove(notice), 2000);
		initCover(true);
	}

	function setting()
	{
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logActionWithNoLevel(300, "SETTING");
		}
		var mouseEventManager = FlxG.plugins.get(FlxMouseEventManager);
		trace(mouseEventManager);
		FlxG.plugins.remove(mouseEventManager);

		openSubState(new SettingsState(function()
		{
			resetSubState();
			FlxG.plugins.add(mouseEventManager);
		}, playerState));
	}

	function selectDifficulty()
	{
		removeAllButtons();
		var button = makeImgButtonPlus(294, 300, easyDiff, "Easy", 24, "Unlimited Lives");

		var button = makeImgButtonPlus(294, 400, normalDiff, "Normal", 24, "3 lives/stage");

		if (playerState.clearedOnce || Main.DEV_ENABLED)
		{
			var button = makeImgButtonPlus(294, 500, hardDiff, "Hard", 24, "1 life, stronger enemies");
		}
	}

	function easyDiff()
	{
		this.playerState.setDifficulty(0);
		selectMode();
	}

	function normalDiff()
	{
		this.playerState.setDifficulty(1);
		selectMode();
	}

	function hardDiff()
	{
		this.playerState.setDifficulty(2);
		selectMode();
	}

	function selectMode()
	{
		removeAllButtons();
		if (playerState.clearedOnce)
		{
			makeImgButtonPlus(294, 300, startFresh, "NEW GAME", 24);

			makeImgButtonPlus(294, 400, skipStage, "SKIP STAGE 1", 24);

			makeImgButtonPlus(294, 500, back, "BACK", 24);
		}
		else
		{
			clickPlay();
		}
	}

	function startFresh()
	{
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logActionWithNoLevel(101, "START FROM STAGE 1");
		}
		clickPlay();
	}

	function skipStage()
	{
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logActionWithNoLevel(102, "SKIPPING STAGE 1");
		}
		this.playerState.firstTimeLose = false;
		this.playerState.firstTimeShop = false;
		PlayerState.tutorial = false;
		this.playerState.addUnit(new Unit(0, 0, 2, this.playerState.closestUnitSlotCoords));
		this.playerState.addGold(220);
		var r = new FlxRandom();
		this.playerState.addWeapon(new Weapon(0, 0, r.int(0, WeaponData.commonWeapons.length - 1), null));
		this.playerState.current_stage = 2;
		this.playerState.current_level = 1;
		this.playerState.unit_capcity = 3;
		save.save();
		clickPlay();
	}

	function back()
	{
		removeAllButtons();
		initCover(true);
	}

	function clickPlay()
	{
		if (started)
		{
			return;
		}
		started = true;
		trace("game started");
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logLevelStart(this.playerState.current_level + (this.playerState.current_stage - 1) * 5);
		}
		removeAllButtons();
		startTime = Date.now().getTime();
		playMusic("assets/music/BATTLE.wav");
		FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
	}

	function endLevelCallback(won:Bool, state:BenchAndInventoryState)
	{
		this.playerState.logData.updateData(won);
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logLevelEnd(this.playerState.logData.outputJSON());
		}
		// remove all sprites
		// if current state is a levelstate, then do the following:
		if (won)
		{
			playerState.win();
			playerState.numberOfLosses = 0;
			if (playerState.current_stage == MAX_STAGE && playerState.current_level == 5)
			{
				// end game, game cleared
				FlxG.switchState(new EndGameState("You cleared the game!\nWould you like to test your team against a final challenge stage?", finalChallenge));
				this.playerState.clearedOnce = true;
				save.save();
				return;
			}
			else if (playerState.current_stage == MAX_STAGE + 1 && playerState.current_level == 3)
			{
				FlxG.switchState(new EndGameState("You Cleared Everything!", null));
				save.save();
				return;
			}
			else if (playerState.current_stage == 3 && playerState.current_level == 5)
			{
				this.playerState.clearedOnce = true;
				save.save();
			}
			FlxG.switchState(new RewardState(playerState, endRewardCallBack));
			// toggle reward screen
		}
		else
		{
			if (playerState.difficulty != 0)
			{
				playerState.livesRemaining -= 1;
			}
			playerState.numberOfLosses++;
			playerState.lose();
			save.save();
			if (playerState.livesRemaining <= 0 && playerState.difficulty != 0)
			{
				FlxG.switchState(new EndGameState("Game Over (no more lives remaining)", null));
			}
			else
			{
				FlxG.switchState(new LoseState(newGameCallback, retryLevelCallback, playerState));
			}
		}
	}

	function finalChallenge()
	{
		FlxG.switchState(new RewardState(playerState, endRewardCallBack));
	}

	function newGameCallback()
	{
		Main.sound.stop();
		FlxG.switchState(new MainState());
	}

	function retryLevelCallback()
	{
		playMusic("assets/music/BATTLE.wav");
		FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
	}

	function closeShopOrMergeCallback(result:Bool, state:BenchAndInventoryState)
	{
		playMusic("assets/music/BATTLE.wav");
		save.save();
		FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
	}

	function openShopCallback()
	{
		playMusic("assets/music/SHOP.wav");
		FlxG.switchState(new ShopState(playerState, closeShopOrMergeCallback, openMergeCallback));
	}

	function openMergeCallback()
	{
		playMusic("assets/music/MERGE.wav");
		FlxG.switchState(new MergeState(playerState, closeShopOrMergeCallback, openShopCallback));
	}

	function endRewardCallBack()
	{
		// after reward, hands back to level_state
		var currStage = this.playerState.current_stage;
		var currLevel = this.playerState.current_level;
		// if (currStage == 2 && currLevel == 5)
		// {
		// 	FlxG.switchState(new EndGameState("END OF DEMO!"));
		// 	return;
		// }
		if (currStage == 1 && currLevel == 4 || currStage > 1 && currStage <= MAX_STAGE && currLevel == 5)
		{
			this.playerState.livesRemaining = 3;
			this.playerState.changeLevel(currStage + 1, 1);
		}
			// else if (currStage == MAX_STAGE && currLevel == 5)
			// {
			// 	// end game, game cleared
			// 	save.save();
			// 	FlxG.switchState(new EndGameState("You cleared the game!"));
			// 	return;
		// }
		else
		{
			this.playerState.changeLevel(currStage, currLevel + 1);
		}
		playerState.unitInShop = null;
		playerState.unitPriceInShop = null;
		playerState.rerollCost = 0;
		save.save();
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logLevelStart(this.playerState.current_level + (this.playerState.current_stage - 1) * 5);
		}
		if (playerState.current_stage == 1)
		{
			FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
		else if (playerState.current_stage == 2 && playerState.current_level == 1)
		{
			FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
		else if (playerState.current_stage == 3 && playerState.current_level == 1)
		{
			FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
		else
		{
			FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
	}

	private function makeImgButtonPlus(x:Int, y:Int, callBack, text:String, size:Int, width:Int = 51, ?textHighlight:String)
	{
		if (textHighlight == null)
		{
			textHighlight = text;
		}
		var button = Buttons.makeButton(x, y, 211, width, callBack, text, size);
		button.textNormal.setFormat("assets/font/Montserrat-ExtraBold.ttf", size);
		button.textNormal.borderColor = FlxColor.BLACK;
		button.textNormal.borderStyle = FlxTextBorderStyle.OUTLINE;
		button.textNormal.y -= 5;
		button.textHighlight.setFormat("assets/font/Montserrat-ExtraBold.ttf", size);
		button.textHighlight.borderColor = FlxColor.BLACK;
		button.textHighlight.borderStyle = FlxTextBorderStyle.OUTLINE;
		button.textHighlight.y -= 5;
		button.textHighlight.text = textHighlight;
		var button_up = new FlxSprite(x, y);
		var button_down = new FlxSprite(x, y);
		button_up.loadGraphic("assets/images/buttons/button_up.png");
		button_down.loadGraphic("assets/images/buttons/button_down.png");
		button.loadButtonGraphic(button_up, button_down);
		add(button_down);
		add(button_up);
		add(button);
		extedButtons.push(button);
		existedImg.push(button_down);
		existedImg.push(button_up);
		return button;
	}

	function playMusic(path:String)
	{
		var volume = Main.sound.volume;
		var time = Date.now().getTime();
		var time_start = (time - startTime) % Main.sound.length;
		trace(time_start);

		Main.sound.loadEmbedded(path, true);
		Main.sound.volume = volume;
		Main.sound.persist = true;
		Main.sound.play(false, time_start);
	}
}
