package util;

import haxe.io.Bytes;

@:publicFields
class BytesTools {
	static function copy(self: Bytes) {
		final len = self.length;
		final res = Bytes.alloc(len);

		res.blit(0, self, 0, len);

		return res;
	}
}