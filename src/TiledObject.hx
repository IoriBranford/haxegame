import Tiled.Property;
import h2d.Bitmap;
import TiledTiles.Animation;
import hxd.res.DefaultFont;
import h2d.Text;
import h2d.Tile;
import h2d.Anim;
import h2d.Object;
import Tiled.ObjectData;

class TiledObject extends Object {
	public var id(default, null):Int;

	var sprite:Object;
	var text:Text;
	var properties:Map<String, Any>;

	public function new(?objectData:ObjectData, ?parent:Object) {
		super(parent);
		initFromData(objectData);
	}

	public function setSpriteAnim(animation:Animation) {
		if (sprite != null)
			removeChild(sprite);

		sprite = new Anim(animation.frames, animation.speed, this);
	}

	public function setSpriteTile(tile:Tile) {
		if (sprite != null)
			removeChild(sprite);

		sprite = new Bitmap(tile, this);
	}

	public function initFromData(objectData:ObjectData) {
		id = objectData.id;
		name = objectData.name;

		var gidOffset = 0;
		if (objectData.tileset != null)
			gidOffset = objectData.tileset.firstgid - 1;

		setPosition(objectData.x, objectData.y);
		rotation = objectData.rotation * Math.PI / 180.0;
		properties = objectData.propertyDict;

		var gid = objectData.gid;
		if (gid != 0) {
			var flags = gid & 0xe0000000;
			gid &= 0x1fffffff;
			gid += gidOffset;

			var animation = Tiled.tiles.getObjectAnimation(gid);
			if (animation != null) {
				setSpriteAnim(animation);
			} else {
				setSpriteTile(Tiled.tiles.getObjectTile(gid));
			}

			if (flags & 0x80000000 != 0)
				sprite.scaleX = -sprite.scaleX;
			if (flags & 0x40000000 != 0)
				sprite.scaleY = -sprite.scaleY;
		}

		var textData = objectData.text;
		if (textData != null) {
			var font = DefaultFont.get(); // TODO
			var text = new Text(font);
			text.text = textData.text;
			this.addChild(text);
		}
	}
}
