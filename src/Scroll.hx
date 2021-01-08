class Scroll {
	public var width = 1.0;

	var layers:Array<TiledLayer>;

	public function new(width:Float, layers:Array<TiledLayer>) {
		this.width = width;
		this.layers = layers;
	}

	public function fixedUpdate() {
		if (layers == null)
			return;
		for (layer in layers) {
			var dx:Null<Float> = layer.properties["dx"];
			layer.x += if (dx == null) 0 else dx;
			if (layer.x < -width) {
				layer.x += 2 * width;
			}
		}
	}
}
