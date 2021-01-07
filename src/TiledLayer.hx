import h2d.Layers;
import h2d.Tile;
import h2d.SpriteBatch;
import h2d.SpriteBatch.BatchElement;
import h2d.Bitmap;
import h2d.Object;
import TiledData.MapData;
import TiledData.LayerData;

class TiledLayer extends Object {
	public var id(default, null):Int;
	public var layers(default, null):Map<Int, TiledLayer>;
	public var objects(default, null):Map<Int, TiledObject>;

	var stack:Layers;
	var bitmap:Bitmap;
	var spriteBatch:SpriteBatch;
	var chunkGrid:Array<SpriteBatch>;
	var elementGrid:Array<BatchElement>;
	var ysort = false;

	public function new(?layerData:LayerData, ?mapData:MapData, ?spriteDict:SpriteDict, ?parent:Object) {
		super(parent);
		initFromData(layerData, mapData, spriteDict);
	}

	public static function spriteBatchFromData(columns:Int, rows:Int, data:Array<Int>, mapData:MapData, spriteDict:SpriteDict) {
		if (rows * columns > data.length)
			throw "rows*columns > data.length";
		var spritebatch:SpriteBatch = null;
		for (gid in data) {
			var tile = spriteDict.getLayerTile(gid);
			if (tile != null) {
				spritebatch = new SpriteBatch(Tile.fromTexture(tile.getTexture()));
				break;
			}
		}

		if (spritebatch == null)
			return null;

		var cellWidth = mapData.tilewidth;
		var cellHeight = mapData.tileheight;
		var i = 0;
		for (r in 1...rows + 1) {
			for (c in 0...columns) {
				var element = new BatchElement(null);
				element.x = c * cellWidth;
				element.y = r * cellHeight;
				var gid = data[i++];
				var tile = spriteDict.getLayerTile(gid);
				if (tile != null) {
					tile = tile.clone();
					tile.dx = 0;
					tile.dy = -tile.height;
				}
				element.t = tile;
				element.visible = tile != null;
				spritebatch.add(element);
			}
		}
		return spritebatch;
	}

	public function initFromData(layerData:LayerData, mapData:MapData, spriteDict:SpriteDict) {
		id = layerData.id;
		this.x = layerData.offsetx;
		this.y = layerData.offsety;

		if (layerData.layers != null) {
			layers = new Map<Int, TiledLayer>();
			stack = new Layers(this);
			for (layerData in layerData.layers) {
				var layer = new TiledLayer(layerData, mapData, spriteDict);
				layers[layer.id] = layer;
				stack.add(layer, 0);
			}
		}

		if (layerData.image != null) {
			var tile = hxd.Res.load(layerData.image).toTile();
			bitmap = new Bitmap(tile, this);
		}

		if (layerData.chunks != null) {
			for (chunk in layerData.chunks) {
				var spritebatch = spriteBatchFromData(chunk.width, chunk.height, chunk.data, mapData, spriteDict);
				if (spritebatch != null) {
					spritebatch.x = chunk.x * mapData.tilewidth;
					spritebatch.y = chunk.y * mapData.tileheight;
					this.addChild(spritebatch);
				}
			}
		} else if (layerData.data != null) {
			var data:Array<Int> = layerData.data;
			var spritebatch = spriteBatchFromData(mapData.width, mapData.height, data, mapData, spriteDict);
			if (spritebatch != null) {
				this.addChild(spritebatch);
			}
		}

		if (layerData.objects != null) {
			ysort = layerData.draworder == "topdown";
			objects = new Map<Int, TiledObject>();
			stack = new Layers(this);
			for (objectData in layerData.objects) {
				var object = new TiledObject(objectData, spriteDict);
				objects[object.id] = object;
				stack.add(object, 0);
			}
		}
	}
}
