import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
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

	var started:Bool = false;

	// var shopState:ShopState;
	// var mergeState:MergeState;
	// var currentMainSequenceStage:FlxState; // stores the current main sequence stage (level, reward, event)

	override public function create()
	{
		super.create();
		FlxG.plugins.add(new FlxMouseEventManager());
		this.rand = new FlxRandom();
		playerState = new PlayerState();
		playButton = Buttons.makeButton(0, 0, 96, 96, clickPlayLog, "Play Game", 32, FlxColor.WHITE, FlxTextAlign.CENTER, true);
		// playButton = new FlxButtonPlus(0, 0, clickPlay, "Play Game", 96, 96);
		// playButton.borderColor = FlxColor.BLACK;
		// playButton.textNormal = Font.makeText(0, 25, 96, "Play Game", 32, FlxColor.WHITE, FlxTextAlign.CENTER);
		// playButton.textHighlight = Font.makeText(0, 25, 96, "Play Game", 32, FlxColor.WHITE, FlxTextAlign.CENTER);

		// playButton.screenCenter();
		add(playButton);
		if (Main.DEV_ENABLED)
		{
			clickPlay(true);
		}
	}

	function clickPlayLog()
	{
		if (started)
		{
			return;
		}
		started = true;
		remove(playButton);
		playerState.log.startNewSession(this.playerState.userID, clickPlay);
	}

	function clickPlay(go:Bool)
	{
		trace("game started");
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logLevelStart(this.playerState.current_level + (this.playerState.current_stage - 1) * 5);
		}
		remove(playButton);
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
			FlxG.switchState(new RewardState(playerState, endRewardCallBack));
			// toggle reward screen
		}
		else
		{
			FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
	}

	function closeShopOrMergeCallback(result:Bool, state:BenchAndInventoryState)
	{
		FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
	}

	function openShopCallback()
	{
		FlxG.switchState(new ShopState(playerState, closeShopOrMergeCallback, openMergeCallback));
	}

	function openMergeCallback()
	{
		FlxG.switchState(new MergeState(playerState, closeShopOrMergeCallback, openShopCallback));
	}

	function endRewardCallBack()
	{
		// after reward, hands back to level_state
		var currStage = this.playerState.current_stage;
		var currLevel = this.playerState.current_level;
		if (currStage == 2 && currLevel == 5)
		{
			FlxG.switchState(new EndGameState("END OF DEMO!"));
			return;
		}
		if (currStage == 1 && currLevel == 4 || currStage > 1 && currStage < MAX_STAGE && currLevel == 5)
		{
			this.playerState.changeLevel(currStage + 1, 1);
		}
		else if (currStage == MAX_STAGE && currLevel == 5)
		{
			// end game, game cleared
			FlxG.switchState(new EndGameState("You cleared the game!"));
			return;
		}
		else
		{
			this.playerState.changeLevel(currStage, currLevel + 1);
		}
		if (!Main.DEV_ENABLED)
		{
			playerState.log.logLevelStart(this.playerState.current_level + (this.playerState.current_stage - 1) * 5);
		}
		playerState.unitInShop = null;
		playerState.unitPriceInShop = null;
		playerState.rerollCost = 0;
		if (playerState.current_stage == 1)
		{
			FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
		else if (playerState.current_stage == 2 && playerState.current_level == 1)
		{
			FlxG.switchState(new LevelStateTutorial(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
		else
		{
			FlxG.switchState(new LevelState(playerState, endLevelCallback, openShopCallback, openMergeCallback));
		}
	}
}
