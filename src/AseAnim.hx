import h2d.SpriteBatch;
import h2d.RenderContext;
import h2d.Object;
import h2d.TileGroup;

class AseAnim extends Object {
	public var document(default, set):AseDocument;
	public var frame(default, set) = 0;
	public var anim(default, set):String;

	var tileGroup:TileGroup;
	var spriteBatch:SpriteBatch;
	var spriteBatchElements:Map<String, BatchElement>;

	var animIndex = 0;
	var animSeq:Array<Int>;
	var animTimerMs = 0.0;

	public function new(document:AseDocument, nodeType:String, ?parent:Object) {
		super(parent);
		switch (nodeType) {
			case "TileGroup":
				tileGroup = new TileGroup(document.imageTile, this);
			case "SpriteBatch":
				spriteBatch = new SpriteBatch(document.imageTile, this);
				spriteBatchElements = new Map<String, BatchElement>();
			default:
				throw 'Unknown ase node type $nodeType';
		}
		this.document = document;
		frame = 0;
	}

	function set_document(document:AseDocument) {
		this.document = document;
		anim = null;
		frame = 0;
		return document;
	}

	function set_anim(anim:String) {
		this.anim = anim;
		if (anim != null) {
			animSeq = document.anims[anim];
			animIndex = 0;
			animTimerMs = document.frames[frame].millis;
			frame = animSeq[0];
		}
		return anim;
	}

	function set_frame(frameIndex:Int) {
		this.frame = frameIndex;
		var frame = document.frames[frame];

		if (tileGroup != null) {
			tileGroup.clear();
			for (cel in frame.cels)
				tileGroup.add(cel.x, cel.y, cel.tile);
		}

		if (spriteBatch != null) {
			spriteBatch.clear();
			spriteBatchElements.clear();
			for (cel in frame.cels) {
				var e = new BatchElement(cel.tile);
				e.x = cel.x;
				e.y = cel.y;
				spriteBatch.add(e);
				spriteBatchElements[cel.name] = e;
			}
		}

		return frameIndex;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		if (anim != null) {
			animTimerMs -= ctx.elapsedTime * 1000;
			if (animTimerMs <= 0) {
				animIndex++;
				animIndex %= animSeq.length;
				frame = (animSeq[animIndex]);
				animTimerMs += document.frames[frame].millis;
			}
		}
	}
}
