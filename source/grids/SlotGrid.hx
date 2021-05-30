package grids;

import attachingMechanism.Slot;
import attachingMechanism.Snappable;
import entities.*;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Constraints.Function;
import haxe.ds.Vector;
import js.lib.Math;
import openfl.display.Sprite;

@:publicFields
class SlotGrid extends FlxSpriteGroup
{
	var numRows = 0;
	var numCols = 0;
	var gridSize = 0;
	var slots:Vector<Vector<Slot>>;
	var sprites_arr:Vector<Vector<FlxSprite>>;

	var graphicsSource:String;
	var tileSource:String;

	var lineStyle:LineStyle = {thickness: 2, color: FlxColor.BLACK};

	var slotAttachFunction:Function;
	var slotDetachFunction:Function;

	public function new(numRows:Int, numCols:Int, gridSize:Int, x:Int, y:Int, graphicsSource:String, opacity:Float = 0.85)
	{
		super(x, y);
		this.numRows = numRows;
		this.numCols = numCols;
		this.gridSize = gridSize;
		this.graphicsSource = graphicsSource;

		slots = new Vector<Vector<Slot>>(numRows);
		sprites_arr = new Vector<Vector<FlxSprite>>(numRows);
		for (i in 0...numRows)
		{
			slots[i] = new Vector<Slot>(numCols);
			sprites_arr[i] = new Vector<FlxSprite>(numCols);
			for (j in (0...numCols))
			{
				var coord = square_coords(i, j);
				slots[i][j] = new Slot(function()
				{
					return coord;
				}, slotAttachFunction, slotDetachFunction);
				sprites_arr[i][j] = new FlxSprite();
				add(sprites_arr[i][j]);
				sprites_arr[i][j].loadGraphic(this.graphicsSource);
				sprites_arr[i][j].setGraphicSize(48, 48);
				sprites_arr[i][j].updateHitbox();
				sprites_arr[i][j].x = coord.x;
				sprites_arr[i][j].y = coord.y;
				sprites_arr[i][j].alpha = opacity;
				// FlxSpriteUtil.drawRect(sprites_arr[i][j], 0, 0, gridSize, gridSize, FlxColor.TRANSPARENT, lineStyle);
			}
		}
	}

	function square_coords(row:Int, col:Int)
	{
		return {x: x + row * gridSize, y: y + col * gridSize};
	}

	function count_nonempty()
	{
		var ret = 0;
		for (i in 0...numRows)
		{
			for (j in 0...numCols)
			{
				if (slots[i][j].isOccupied)
				{
					ret += 1;
				}
			}
		}

		return ret;
	}

	function square_coords_point(row:Int, col:Int)
	{
		var coord = square_coords(row, col);
		return new FlxPoint(coord.x, coord.y);
	}

	function square_coords_inverse(x_query:Float, y_query:Float)
	{
		var ret = {row: Std.int((x_query - x) / gridSize), col: Std.int((y_query - y) / gridSize)};
		if (ret.row < 0 || ret.col < 0 || ret.row >= numRows || ret.col >= numCols)
		{
			return null;
		}
		return ret;
	}

	function get_unit(row:Int, col:Int)
	{
		if (slots[row][col].isOccupied)
		{
			var snap = slots[row][col].attachedSnappable;
			var unit = cast(snap, Unit);
			return unit;
		}

		return null;
	}

	function closest_grid_slot(query_x:Float, query_y:Float)
	{
		var closest_dist = 10000.0;
		var closest_slot = null;
		for (i in 0...numRows)
		{
			for (j in 0...numCols)
			{
				if (!slots[i][j].isOccupied)
				{
					var coord = square_coords(i, j);
					var dist = Math.sqrt((query_x - coord.x) * (query_x - coord.x) + (query_y - coord.y) * (query_y - coord.y));
					if (dist < closest_dist)
					{
						closest_dist = dist;
						closest_slot = slots[i][j];
					}
				}
			}
		}

		return {slot: closest_slot, dist: closest_dist};
	}
}
