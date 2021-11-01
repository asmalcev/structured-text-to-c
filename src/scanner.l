%option noyywrap

%{

#include <stdio.h>

#include "../src/config.hpp"
#include "parser.tab.h"

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

"IF"     { LOG("IF ");     return IF;     }
"THEN"   { LOG("THEN ");   return THEN;   }
"ELSE"   { LOG("ELSE ");   return ELSE;   }
"END_IF" { LOG("END_IF "); return END_IF; }

"DO" { LOG("DO "); return DO; }

"FOR"     { LOG("FOR ");     return FOR;     }
"TO"      { LOG("TO ");      return TO;      }
"BY"      { LOG("BY ");      return BY;      }
"END_FOR" { LOG("END_FOR "); return END_FOR; }

"WHILE"     { LOG("WHILE ");     return WHILE; }
"END_WHILE" { LOG("END_WHILE "); return END_WHILE; }

"REPEAT"     { LOG("REPEAT ");     return REPEAT;     }
"UNTIL"      { LOG("UNTIL ");      return UNTIL;      }
"END_REPEAT" { LOG("END_REPEAT "); return END_REPEAT; }

"VAR"     { LOG("VAR ");     return VAR;     }
"END_VAR" { LOG("END_VAR "); return END_VAR; }

"PROGRAM"     { LOG("PROGRAM ");     return PROGRAM;     }
"END_PROGRAM" { LOG("END_PROGRAM "); return END_PROGRAM; }

{type} {
	LOG("TYPE %s ", yytext);
	sscanf(yytext, "%s", yylval.c_value);
	return TYPE;
}

"+"   { LOG("PLUS ");     return PLUS;     }
"-"   { LOG("MINUS ");    return MINUS;    }
"**"  { LOG("POW ");      return POW;      }
"*"   { LOG("MULTIPLY "); return MULTIPLY; }
"/"   { LOG("DIVIDE ");   return DIVIDE;   }
"MOD" { LOG("MOD ");      return MOD;      }

"(" { LOG("BRACKET OPEN ");  return BR_OPEN; }
")" { LOG("BRACKET CLOSE "); return BR_CLOSE; }

"<"  { LOG("LESS ");           return LESS;    }
">"  { LOG("MORE ");           return MORE;    }
"<>" { LOG("ISN'T EQUALS ");   return nEQUALS; }
"<=" { LOG("LESS OR EQUALS "); return LESSoE;  }
">=" { LOG("MORE OR EQUALS "); return MOREoE;  }
"="  { LOG("EQUALS ");         return EQUALS;  }

":=" { LOG("ASSIGNMENT "); return ASSIGNMENT; }
";"  { LOG("SEMICOLON ");  return SEMICOLON;  }
":"  { LOG("COLON ");      return COLON;      }

{alpha}{digit_or_alpha}* {
	LOG("ID %s ", yytext);
	sscanf(yytext, "%s", yylval.c_value);
	return ID;
}

{digit}+ {
	LOG("INTEGER %s ", yytext);
	sscanf(yytext, "%s", yylval.c_value);
	return NUMBER;
}

. { lexerror("Unexpected character"); }

%%

void lexerror(const char * s) {
	fprintf(stderr, "Flex error: %s\n", s);
	exit(1);
}