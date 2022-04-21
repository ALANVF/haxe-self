package lexing;

import haxe.io.Bytes;

enum Token {
	TDot;
	TColon;
	TBar;
	TReturn;

	TLParen;
	TLBracket;
	TLBrace;
	TRParen;
	TRBracket;
	TRBrace;

	TName(name: String);
	TLabel(name: String);
	TULabel(name: String);
	TOp(op: String);

	TInt(int: Int);
	TFloat(float: Float);
	TString(string: Bytes);
}