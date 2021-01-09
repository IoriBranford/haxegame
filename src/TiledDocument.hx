import h2d.SpriteBatch;
import h2d.TileGroup;
import haxe.io.BytesInput;
import haxe.zip.Uncompress;
import haxe.crypto.Base64;
import haxe.io.Path;
import haxe.Json;
import h2d.Font;
import h2d.Text.Align;
import h2d.Tile;

typedef Position = {
	x:Float,
	y:Float,
}

typedef Chunk = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	tiles:Array<Tile>,
}

typedef Text = {
	font:Font,
	text:String,
	halign:Align,
	valign:Align,
	wrap:Bool,
	color:Int,
}

typedef Object = {
	id:Int,
	name:String,
	type:String,
	width:Float,
	height:Float,
	x:Float,
	y:Float,
	rotation:Float,
	tile:TilesetTile,
	flipX:Bool,
	flipY:Bool,
	shape:String,
	points:Array<Position>,
	properties:Map<String, Any>,
}

typedef Layer = {
	id:Int,
	x:Float,
	y:Float,
	chunks:Array<Chunk>,
	objects:Array<Object>,
	image:Tile,
	sublayers:Array<Layer>,
	name:String,
	properties:Map<String, Any>,
}

typedef PropertyData = {
	name:String,
	type:String,
	value:Any,
}

typedef TileFrame = {tile:Tile, duration:Int}

typedef TilesetTile = {
	tile:Tile,
	animation:Array<TileFrame>,
	objects:Array<Object>,
	properties:Map<String, Any>,
}

typedef Tileset = {
	name:String,
	tiles:Array<TilesetTile>,
	properties:Map<String, Any>,
}

typedef TextData = {
	bold:Bool,
	// Whether to use a bold font (default: false)
	color:String,
	//	Hex-formatted color (#RRGGBB or #AARRGGBB) (default: #000000)
	fontfamily:String,
	//	Font family (default: sans-serif)
	halign:String,
	//	Horizontal alignment (center, right, justify or left (default))
	italic:Bool,
	// Whether to use an italic font (default: false)
	kerning:Bool,
	// Whether to use kerning when placing characters (default: true)
	pixelsize:Int,
	// Pixel size of font (default: 16)
	strikeout:Bool,
	// Whether to strike out the text (default: false)
	text:String,
	//	Text
	underline:Bool,
	// Whether to underline the text (default: false)
	valign:String,
	//	Vertical alignment (center, bottom or top (default))
	wrap:Bool,
	// Whether the text is wrapped within the object bounds (default: false)
}

typedef ObjectData = {
	ellipse:Bool,
	// Used to mark an object as an ellipse
	gid:Int,
	// Global tile ID, only if object represents a tile
	height:Float,
	//	Height in pixels.
	id:Int,
	// Incremental ID, unique across all objects
	name:String,
	//	String assigned to name field in editor
	point:Bool,
	// Used to mark an object as a point
	polygon:Array<Position>,
	// Array of Points, in case the object is a polygon
	polyline:Array<Position>,
	// Array of Points, in case the object is a polyline
	properties:Array<PropertyData>,
	// Array of Properties
	rotation:Float,
	//	Angle in degrees clockwise
	template:String,
	//	Reference to a template file, in case object is a template instance
	text:TextData,
	// Only used for text objects
	type:String,
	//	String assigned to type field in editor
	visible:Bool,
	// Whether object is shown in editor.
	width:Float,
	//	Width in pixels.
	x:Float,
	//	X coordinate in pixels
	y:Float,
	//	Y coordinate in pixels
}

typedef ChunkData = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	data:Any,
}

typedef LayerData = {
	chunks:Array<ChunkData>,
	// Array of chunks (optional). tilelayer only.
	compression:String,
	//	zlib, gzip, zstd (since Tiled 1.3) or empty (default). tilelayer only.
	data:Any,
	// Array of unsigned int (GIDs) or base64-encoded data. tilelayer only.
	draworder:String,
	//	topdown (default) or index. objectgroup only.
	encoding:String,
	//	csv (default) or base64. tilelayer only.
	height:Int,
	// Row count. Same as map height for fixed-size maps.
	id:Int,
	// Incremental ID - unique across all layers
	image:String,
	//	Image used by this layer. imagelayer only.
	layers:Array<LayerData>,
	// Array of layers. group only.
	name:String,
	//	Name assigned to this layer
	objects:Array<ObjectData>,
	// Array of objects. objectgroup only.
	offsetx:Float,
	//	Horizontal layer offset in pixels (default: 0)
	offsety:Float,
	//	Vertical layer offset in pixels (default: 0)
	opacity:Float,
	//	Value between 0 and 1
	properties:Array<PropertyData>,
	// Array of Properties
	startx:Int,
	// X coordinate where layer content starts (for infinite maps)
	starty:Int,
	// Y coordinate where layer content starts (for infinite maps)
	tintcolor:String,
	//	Hex-formatted color (#RRGGBB or #AARRGGBB) that is multiplied with any graphics drawn by this layer or any child layers (optional).
	transparentcolor:String,
	//	Hex-formatted color (#RRGGBB) (optional). imagelayer only.
	type:String,
	//	tilelayer, objectgroup, imagelayer or group
	visible:Bool,
	// Whether layer is shown or hidden in editor
	width:Int,
	// Column count. Same as map width for fixed-size maps.
	x:Int,
	// Horizontal layer offset in tiles. Always 0.
	y:Int,
	// Vertical layer offset in tiles. Always 0.
}

typedef TileData = {
	animation:Array<{tileid:Int, duration:Int}>,
	// Array of Frames
	id:Int,
	// Local ID of the tile
	image:String,
	// Image representing this tile (optional)
	imageheight:Int,
	// Height of the tile image in pixels
	imagewidth:Int,
	// Width of the tile image in pixels
	objectgroup:LayerData,
	// Layer with type objectgroup, when collision shapes are specified (optional)
	probability:Float,
	// Percentage chance this tile is chosen when competing with others in the editor (optional)
	properties:Array<PropertyData>,
	// Array of Properties
	// terrain:Array,
	// Index of terrain for each corner of tile (optional)
	type:String,
	// The type of the tile (optional)
}

typedef TilesetData = {
	backgroundcolor:String,
	//	Hex-formatted color (#RRGGBB or #AARRGGBB) (optional)
	columns:Int,
	// The number of tile columns in the tileset
	firstgid:Int,
	// GID corresponding to the first tile in the set
	// grid:Grid,
	// (optional)
	image:String,
	//	Image used for tiles in this set
	imageheight:Int,
	// Height of source image in pixels
	imagewidth:Int,
	// Width of source image in pixels
	margin:Int,
	// Buffer between image edge and first tile (pixels)
	name:String,
	//	Name given to this tileset
	objectalignment:String,
	//	Alignment to use for tile objects (unspecified (default), topleft, top, topright, left, center, right, bottomleft, bottom or bottomright) (since 1.4)
	properties:Array<PropertyData>,
	// Array of Properties
	source:String,
	//	The external file that contains this tilesets data
	spacing:Int,
	// Spacing between adjacent tiles in image (pixels)
	// terrains:Array,
	// Array of Terrains (optional)
	tilecount:Int,
	// The number of tiles in this tileset
	tiledversion:String,
	//	The Tiled version used to save the file
	tileheight:Int,
	// Maximum height of tiles in this set
	tileoffset:{x:Int, y:Int},
	//	(optional)
	tiles:Array<TileData>,
	// Array of Tiles (optional)
	tilewidth:Int,
	// Maximum width of tiles in this set
	transparentcolor:String,
	//	Hex-formatted color (#RRGGBB) (optional)
	type:String,
	//	tileset (for tileset files, since 1.0)
	version:Float,
	//	The JSON format version
	// wangsets:Array,
	// Array of Wang sets (since 1.1.5)
}

typedef TiledData = {
	> TilesetData,
	backgroundcolor:String,
	//	Hex-formatted color (#RRGGBB or #AARRGGBB) (optional)
	compressionlevel:Int,
	// The compression level to use for tile layer data (defaults to -1, which means to use the algorithm default)
	height:Int,
	// Number of tile rows
	hexsidelength:Int,
	// Length of the side of a hex tile in pixels (hexagonal maps only)
	infinite:Bool,
	// Whether the map has infinite dimensions
	layers:Array<LayerData>,
	// Array of Layers
	nextlayerid:Int,
	// Auto-increments for each layer
	nextobjectid:Int,
	// Auto-increments for each placed object
	orientation:String,
	//	orthogonal, isometric, staggered or hexagonal
	properties:Array<PropertyData>,
	// Array of Properties
	renderorder:String,
	//	right-down (the default), right-up, left-down or left-up (currently only supported for orthogonal maps)
	staggeraxis:String,
	//	x or y (staggered / hexagonal maps only)
	staggerindex:String,
	//	odd or even (staggered / hexagonal maps only)
	tiledversion:String,
	//	The Tiled version used to save the file
	tileheight:Int,
	// Map grid height
	tilesets:Array<TilesetData>,
	// Array of Tilesets
	tilewidth:Int,
	// Map grid width
	type:String,
	//	map, tileset, or template
	version:Float,
	//	The JSON format version
	width:Int,
	// Number of tile columns
	tileset:TilesetData,
	// for template
	object:ObjectData
	// for template
}

class TiledDocument {
	public var name(default, null) = "";
	public var cellWidth(default, null) = 1;
	public var cellHeight(default, null) = 1;
	public var layers(default, null):Array<Layer>;
	public var namedLayers(default, null):Map<String, Layer>;
	public var tiles(default, null):Array<TilesetTile>;
	public var tilesets(default, null):Array<TiledDocument>;
	public var object(default, null):Object;
	public var properties(default, null):Map<String, Any>;

	public function new(filename:String) {
		var text = hxd.Res.load(filename).toText();
		var fileData:TiledData = Json.parse(text);
		tiles = new Array<TilesetTile>();
		switch (fileData.type) {
			case "map":
				initMap(fileData, Path.directory(filename));
			case "tileset":
				initTileset(fileData, Path.directory(filename));
			case "template":
				initTemplate(fileData, Path.directory(filename));
		}
	}

	public function makeLayerTileGroups(layer:Layer, ?parent:h2d.Object) {
		if (layer.chunks == null)
			return null;
		var tileGroups = new Array<TileGroup>();
		for (chunk in layer.chunks) {
			var tileGroup = makeChunkTileGroup(chunk, parent);
			if (tileGroup != null)
				tileGroups.push(tileGroup);
		}
		return tileGroups;
	}

	public function makeLayerSpriteBatches(layer:Layer, ?parent:h2d.Object) {
		if (layer.chunks == null)
			return null;
		var spriteBatches = new Array<SpriteBatch>();
		for (chunk in layer.chunks) {
			var spriteBatch = makeChunkSpriteBatch(chunk, parent);
			if (spriteBatch != null)
				spriteBatches.push(spriteBatch);
		}
		return spriteBatches;
	}

	function makeChunkTileGroup(chunk:Chunk, ?parent:h2d.Object) {
		var tileGroup:TileGroup = null;
		var chunkTiles = chunk.tiles;
		for (t in chunkTiles) {
			if (t != null) {
				tileGroup = new TileGroup(Tile.fromTexture(t.getTexture()), parent);
				break;
			}
		}

		if (tileGroup == null)
			return null;

		tileGroup.x = chunk.x * cellWidth;
		tileGroup.y = chunk.y * cellHeight;

		var i = 0;
		for (r in 1...chunk.height + 1) {
			for (c in 0...chunk.width) {
				var t = chunkTiles[i++];
				if (t != null)
					tileGroup.add(c * cellWidth, r * cellHeight, t);
			}
		}

		return tileGroup;
	}

	function makeChunkSpriteBatch(chunk:Chunk, ?parent:h2d.Object) {
		var spriteBatch:SpriteBatch = null;
		var chunkTiles = chunk.tiles;
		for (t in chunkTiles) {
			if (t != null) {
				spriteBatch = new SpriteBatch(Tile.fromTexture(t.getTexture()), parent);
				break;
			}
		}

		if (spriteBatch == null)
			return null;

		spriteBatch.x = chunk.x * cellWidth;
		spriteBatch.y = chunk.y * cellHeight;

		var i = 0;
		for (r in 1...chunk.height + 1) {
			for (c in 0...chunk.width) {
				var t = chunkTiles[i++];
				if (t != null) {
					var e = new BatchElement(t);
					e.x = c * cellWidth;
					e.y = r * cellHeight;
					spriteBatch.add(e);
				}
			}
		}

		return spriteBatch;
	}

	function initMap(mapData:TiledData, cwd:String) {
		properties = propertyDict(mapData.properties);
		cellWidth = mapData.tilewidth;
		cellHeight = mapData.tileheight;

		tiles.push({
			tile: Tile.fromColor(0xFF0000, mapData.tilewidth, mapData.tileheight),
			animation: null,
			properties: null,
			objects: null
		});

		for (tilesetData in mapData.tilesets) {
			loadTileset(tilesetData, cwd);
		}

		layers = new Array<Layer>();
		namedLayers = new Map<String, Layer>();
		for (layerData in mapData.layers) {
			var layer = makeLayer(layerData, cwd);
			layers.push(layer);
			if (!namedLayers.exists(layer.name))
				namedLayers[layer.name] = layer;
		}

		return mapData;
	}

	function loadTileset(tilesetData:TilesetData, cwd) {
		var source = tilesetData.source;
		if (source == null)
			throw "Tilesets embedded in maps are not supported";

		if (tilesets == null)
			tilesets = new Array<TiledDocument>();

		var tileset = new TiledDocument(Path.join([cwd, source]));
		tilesets.push(tileset);

		for (tile in tileset.tiles) {
			tiles.push(tile);
		}
	}

	function initTileset(tilesetData:TilesetData, cwd:String) {
		name = tilesetData.name;
		properties = propertyDict(tilesetData.properties);

		var image = hxd.Res.load(Path.join([cwd, tilesetData.image]));
		var imageTile = image.toTile();

		var tilecount = tilesetData.tilecount;
		var tilewidth = tilesetData.tilewidth;
		var tileheight = tilesetData.tileheight;
		var columns = tilesetData.columns;
		var rows = Math.floor(tilecount / columns);
		var i = 0;
		for (r in 0...rows) {
			for (c in 0...columns) {
				var tile = imageTile.sub(c * tilewidth, r * tileheight, tilewidth, tileheight, 0, -tileheight);
				tiles.push({
					tile: tile,
					animation: null,
					properties: null,
					objects: null,
				});
			}
		}

		var tilesData = tilesetData.tiles;
		if (tilesData != null) {
			for (tile in tilesData) {
				var tilesetTile = tiles[tile.id];
				tilesetTile.properties = propertyDict(tile.properties);

				var objectgroup = makeLayer(tile.objectgroup, cwd);
				if (objectgroup != null) {
					layers = new Array<Layer>();
					layers.push(objectgroup);
				}

				var animationData = tile.animation;
				if (animationData != null) {
					var animation = new Array<TileFrame>();
					tilesetTile.animation = animation;
					for (frame in animationData) {
						animation.push({
							tile: tiles[frame.tileid].tile,
							duration: frame.duration
						});
					}
				}
			}
		}
	}

	function initTemplate(templateData:TiledData, cwd:String) {
		object = makeObject(templateData.object, cwd);
		if (templateData.tileset != null) {
			tiles.push(null);
			loadTileset(templateData.tileset, cwd);
		}
	}

	function makeChunkTiles(columns:Int, rows:Int, data:Array<Int>) {
		var chunkTiles = new Array<Tile>();
		chunkTiles.resize(rows * columns);
		var i = 0;
		for (r in 1...rows + 1) {
			for (c in 0...columns) {
				var gid = data[i];
				if (gid != 0) {
					var flags = gid & 0xe0000000;
					gid = gid & 0x1fffffff;
					var tile = tiles[gid].tile;
					tile = tile.clone();
					if (flags & 0x80000000 != 0)
						tile.flipX();
					if (flags & 0x40000000 != 0)
						tile.flipY();
					chunkTiles[i] = tile;
				}
				i++;
			}
		}
		return chunkTiles;
	}

	function makeLayer(layerData:LayerData, cwd:String) {
		if (layerData == null)
			return null;

		var layer = {
			id: layerData.id,
			x: layerData.offsetx,
			y: layerData.offsety,
			name: layerData.name,
			properties: propertyDict(layerData.properties),
			chunks: null,
			objects: null,
			image: null,
			sublayers: null,
		};

		if (layerData.chunks != null) {
			var chunks:Array<Chunk> = new Array<Chunk>();
			layer.chunks = chunks;

			if (layerData.encoding == "base64") {
				for (chunkData in layerData.chunks) {
					chunkData.data = decodeData(chunkData.data, layerData.compression);
				}
			}

			for (chunkData in layerData.chunks) {
				var chunk = {
					x: chunkData.x,
					y: chunkData.y,
					width: chunkData.width,
					height: chunkData.height,
					tiles: makeChunkTiles(chunkData.width, chunkData.height, chunkData.data)
				};
				chunks.push(chunk);
				trace(chunkData.data);
				trace(chunk.tiles);
			}
		} else if (layerData.data != null) {
			var chunks:Array<Chunk> = new Array<Chunk>();
			layer.chunks = chunks;

			if (layerData.encoding == "base64")
				layerData.data = decodeData(layerData.data, layerData.compression);

			chunks.push({
				x: 0,
				y: 0,
				width: layerData.width,
				height: layerData.height,
				tiles: makeChunkTiles(layerData.width, layerData.height, layerData.data)
			});
		}

		if (layerData.objects != null) {
			var objects:Array<Object> = new Array<Object>();
			layer.objects = objects;
			for (object in layerData.objects) {
				objects.push(makeObject(object, cwd));
			}
		}

		if (layerData.image != null) {
			layerData.image = Path.join([cwd, layerData.image]);
			layer.image = hxd.Res.load(layerData.image).toTile();
		}

		if (layerData.layers != null) {
			var sublayers:Array<Layer> = new Array<Layer>();
			layer.sublayers = sublayers;
			for (l in layerData.layers) {
				sublayers.push(makeLayer(l, cwd));
			}
		}

		return layer;
	}

	function makeObject(objectData:ObjectData, cwd:String) {
		if (objectData == null)
			return null;

		var object:Object = {
			id: objectData.id,
			name: objectData.name,
			type: objectData.type,
			width: objectData.width,
			height: objectData.height,
			x: objectData.x,
			y: objectData.y,
			rotation: objectData.rotation * Math.PI / 180.0,
			properties: propertyDict(objectData.properties),
			tile: null,
			flipX: false,
			flipY: false,
			shape: "",
			points: null,
		};

		var gid = objectData.gid;
		if (gid != 0) {
			var flags = gid & 0xe0000000;
			gid &= 0x1fffffff;

			object.tile = tiles[gid];
			object.flipX = flags & 0x80000000 != 0;
			object.flipY = flags & 0x40000000 != 0;
		}

		// TODO text

		return object;
	}

	static function propertyDict(propertiesArray:Array<PropertyData>) {
		var properties = new Map<String, Any>();
		if (propertiesArray != null) {
			for (property in propertiesArray) {
				properties[property.name] = property.value;
			}
		}
		return properties;
	}

	static function decodeData(data:Any, compression:String) {
		var string:String = data;
		var bytes = Base64.decode(string);
		switch (compression) {
			case "zlib":
				bytes = Uncompress.run(bytes);
			case "gzip":
				bytes = new format.gz.Reader(new BytesInput(bytes)).read().data;
			case null:

			default:
				throw compression + " not yet supported";
		}
		var array = new Array<Int>();
		for (i in 0...bytes.length >> 2) {
			array.push(bytes.getInt32(i << 2));
		}
		return array;
	}
}
