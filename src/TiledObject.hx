import h2d.Bitmap;
import SpriteDict.Animation;
import hxd.res.DefaultFont;
import h2d.Text;
import h2d.Tile;
import h2d.Anim;
import h2d.Object;
import TiledData.ObjectData;

class TiledObject extends Object {
	public var id(default, null):Int;

	var sprite:Object;
	var text:Text;

	public function new(?objectData:ObjectData, ?spriteDict:SpriteDict, ?parent:Object) {
		super(parent);
		initFromData(objectData, spriteDict);
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

	public function initFromData(objectData:ObjectData, spriteDict:SpriteDict) {
		id = objectData.id;
		var templatefirstgid = 0;
		if (objectData.template != null) {
			var template = TiledData.loadTemplate(objectData.template);
			if (template != null) {
				templatefirstgid = spriteDict.addTileset(template.tileset);
			}
		}

		this.setPosition(objectData.x, objectData.y);
		this.rotation = objectData.rotation * Math.PI / 180.0;

		var gid = objectData.gid;
		if (gid != 0) {
			var flags = gid & 0xe0000000;
			if (flags & 0x80000000 != 0)
				this.scaleX = -this.scaleX;
			if (flags & 0x40000000 != 0)
				this.scaleY = -this.scaleY;

			gid &= 0x1fffffff;
			gid += templatefirstgid - 1;
			objectData.gid = gid;

			var animation = spriteDict.getObjectAnimation(gid);
			if (animation != null) {
				setSpriteAnim(animation);
			} else {
				setSpriteTile(spriteDict.getObjectTile(gid));
			}
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
