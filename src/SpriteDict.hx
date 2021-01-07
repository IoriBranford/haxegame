import TiledData.TilesetData;
import h2d.Tile;

typedef Animation = {
	frames:Array<Tile>,
	speed:Float
}

class SpriteDict {
	var objectTilesByGid = new Map<Int, Tile>();
	var objectAnimationsByGid = new Map<Int, Animation>();
	var layerTilesByGid = new Map<Int, Tile>();
	var layerAnimationsByGid = new Map<Int, Animation>();

	public var objectTiles(default, null) = new Map<String, Tile>();
	public var objectAnimations(default, null) = new Map<String, Animation>();
	public var layerTiles(default, null) = new Map<String, Tile>();
	public var layerAnimations(default, null) = new Map<String, Animation>();

	public var nextgid(default, null) = 1;

	public function new(?tilesets:Array<TilesetData>) {
		if (tilesets != null)
			addTilesets(tilesets);
	}

	public function addTilesets(tilesets:Array<TilesetData>) {
		for (tileset in tilesets) {
			addTileset(tileset);
		}
	}

	static final AlignmentOffsets = [
		"topleft" => [0.0, 0.0],
		"top" => [-0.5, 0.0],
		"topright" => [-1.0, 0.0],
		"left" => [0.0, -0.5],
		"center" => [-0.5, -0.5],
		"right" => [-1.0, -0.5],
		"bottomleft" => [0.0, -1.0],
		"bottom" => [-0.5, -1.0],
		"bottomright" => [-1.0, -1.0],
	];

	public function addTileset(tileset:TilesetData) {
		var firstgid = nextgid;
		var tilesetname = tileset.name;
		var tilewidth = tileset.tilewidth;
		var tileheight = tileset.tileheight;
		var tilecount = tileset.tilecount;
		var columns = tileset.columns;
		var rows = Math.floor(tilecount / columns);

		var objectalignment = tileset.objectalignment;
		objectalignment = if (objectalignment == null) "bottomleft" else objectalignment;
		var alignmentoffset = AlignmentOffsets[objectalignment];
		var offsetx = alignmentoffset[0] * tilewidth;
		var offsety = alignmentoffset[1] * tileheight;
		if (tileset.tileoffset != null) {
			offsetx += tileset.tileoffset.x;
			offsety += tileset.tileoffset.y;
		}

		// TODO margin, spacing
		var imageTile = hxd.Res.load(tileset.image).toTile();
		var objectTilesArray = new Array<Tile>();
		var layerTilesArray = new Array<Tile>();
		var tilesData = tileset.tiles;
		for (r in 0...rows) {
			for (c in 0...columns) {
				var layerTile = imageTile.sub(c * tilewidth, r * tileheight, tilewidth, tileheight, 0, -tileheight);
				layerTilesArray.push(layerTile);

				var objectTile = layerTile.clone();
				objectTile.dx = offsetx;
				objectTile.dy = offsety;
				objectTilesArray.push(objectTile);
			}
		}

		for (i in 0...tilesData.length) {
			var layerTile = layerTilesArray[i];
			var objectTile = objectTilesArray[i];
			var gid = nextgid++;
			var stringId = '$tilesetname/$i';

			var tileData = tilesData[i];
			if (tileData != null) {
				var properties = tileData.propertyDict;
				var stringIdProperty = if (properties != null) tileData.propertyDict["id"] else null;
				if (stringIdProperty != null)
					stringId = '$tilesetname/${stringIdProperty.value}';

				var animationData = tileData.animation;
				if (animationData != null) {
					var speed = 1000.0 / animationData[0].duration;

					var objectAnimationFrames = new Array<Tile>();
					var layerAnimationFrames = new Array<Tile>();
					for (frame in animationData) {
						objectAnimationFrames.push(objectTilesArray[frame.tileid]);
						layerAnimationFrames.push(layerTilesArray[frame.tileid]);
					}

					var objectAnimation = {frames: objectAnimationFrames, speed: speed};
					objectAnimationsByGid[gid] = objectAnimation;
					objectAnimations[stringId] = objectAnimation;
					var layerAnimation = {frames: layerAnimationFrames, speed: speed};
					layerAnimationsByGid[gid] = layerAnimation;
					layerAnimations[stringId] = layerAnimation;
				}
			}

			objectTilesByGid[gid] = objectTile;
			objectTiles[stringId] = objectTile;
			layerTilesByGid[gid] = layerTile;
			layerTiles[stringId] = layerTile;
		}
		return firstgid;
	}

	public function getLayerTile(gid:Int) {
		return getTile(layerTilesByGid, gid);
	}

	public function getObjectTile(gid:Int) {
		return getTile(objectTilesByGid, gid);
	}

	function getTile(tiles:Map<Int, Tile>, gid:Int) {
		if (gid == 0)
			return null;
		var tile = tiles[gid];
		if (tile == null) {
			var flags = gid & 0xe0000000;
			tile = objectTilesByGid[gid & 0x1fffffff];
			if (tile == null)
				throw "No tile with gid " + gid;

			tile = tile.clone();
			if (flags & 0x80000000 != 0)
				tile.flipX();
			if (flags & 0x40000000 != 0)
				tile.flipY();
			objectTilesByGid[gid] = tile;
		}
		return tile;
	}

	public function getObjectAnimation(gid:Int) {
		return getAnimation(objectAnimationsByGid, gid);
	}

	public function getLayerAnimation(gid:Int) {
		return getAnimation(layerAnimationsByGid, gid);
	}

	function getAnimation(animations:Map<Int, Animation>, gid:Int) {
		if (gid == 0)
			return null;
		return animations[gid & 0x1fffffff];
	}
}
