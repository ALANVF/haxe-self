package util;

@:publicFields
class Strings {
	static function escape(str: String, exceptWs = false, exceptQuote = false) {
		str = str.replaceAll("\\", "\\\\");
		if(!exceptQuote) str = str.replaceAll("\"", "\\\"");
		if(!exceptWs) str = str.replaceAll("\t", "\\t").replaceAll("\n", "\\n").replaceAll("\r", "\\r");
		// TODO: other control chars
		return str;
	}
}