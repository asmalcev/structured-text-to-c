%option noyywrap

%{

#include "../src/config.hpp"
#include <stdio.h>

#ifdef DEBUG_LEX
	#define LOG(...) printf(__VA_ARGS__)
#else
	#define LOG
#endif

void lexerror(const char * s);

extern int yylex();
extern FILE * yyin;

%}

digit          [0-9]
alpha          [a-zA-Z_]
digit_or_alpha [a-zA-Z0-9_]

type SINT|INT|DINT|LINT|USINT|UINT|LDINT|ULINT

%%

[ \t\n] ; // ignore all whitespaces and breaklines

"IF"    { LOG("IF ");    }
"THEN"  { LOG("THEN ");  }
"ELSE"  { LOG("ELSE ");  }

"DO" { LOG("DO "); }

"FOR"     { LOG("FOR ");     }
"TO"      { LOG("TO ");      }
"BY"      { LOG("BY ");      }
"END_FOR" { LOG("END_FOR "); }

"WHILE"     { LOG("WHILE ");     }
"END_WHILE" { LOG("END_WHILE "); }

"REPEAT"     { LOG("REPEAT ");     }
"UNTIL"      { LOG("UNTIL ");      }
"END_REPEAT" { LOG("END_REPEAT "); }

"VAR"     { LOG("VAR ");     }
"END_VAR" { LOG("END_VAR "); }

"PROGRAM"     { LOG("PROGRAM ");     }
"END_PROGRAM" { LOG("END_PROGRAM "); }

{type} { LOG("TYPE %s ", yytext); }

"+"   { LOG("PLUS ");     }
"-"   { LOG("MINUS ");    }
"*"   { LOG("MULTIPLY "); }
"/"   { LOG("DIVIDE ");   }
"MOD" { LOG("MOD ");      }

"(" { LOG("BRACKET OPEN ");  }
")" { LOG("BRACKET CLOSE "); }

"<"  { LOG("LESS ");           }
">"  { LOG("MORE ");           }
"<>" { LOG("ISN'T EQUALS ");   }
"<=" { LOG("LESS OR EQUALS "); }
">=" { LOG("MORE OR EQUALS "); }
"="  { LOG("EQUALS ");         }

":=" { LOG("ASSIGNMENT "); }
";"  { LOG("SEMICOLON ");  }
":"  { LOG("COLON ");      }

{alpha}{digit_or_alpha}* { LOG("ID %s ", yytext); }

{digit}+ { LOG("INTEGER %s ", yytext); }

. { lexerror("Unexpected character"); }

%%

void lexerror(const char * s) {
	fprintf(stderr, "Flex error: %s\n", s);
	exit(1);
}

int main(int argc, char *argv[]) {
	yyin = fopen("examples/ex0", "r");

	yylex();

	#ifdef DEBUG_LEX
		printf("\n");
	#endif

	fclose(yyin);
}