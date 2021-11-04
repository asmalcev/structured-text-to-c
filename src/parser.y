%{

/************************
---      includes     ---
************************/

#include <vector>
#include <sstream>

#include <stdio.h>
#include <string.h>

#include "../src/config.hpp"
#include "../src/statements/statements.hpp"
#include "../src/translator/translator.hpp"

/************************
---       bison       ---
************************/
extern int yylex();
extern int yyparse();
extern FILE * yyin;

void yyerror(const char * s);

/************************
---      output       ---
************************/
FILE * parser_output;

bool is_math_in_use = false;

unsigned int nesting = 0;

std::vector<declaration> declarations;
std::vector<statement *> statements;
std::stringstream expression;

const char * transfer_st_type_to_c(char * type);
void fix_pow();

%}

%union {
	char c_value[CVAL_LENGTH];
}

%token IF THEN ELSE END_IF DO FOR TO BY END_FOR WHILE END_WHILE REPEAT UNTIL END_REPEAT VAR END_VAR PROGRAM END_PROGRAM SEMICOLON COLON ASSIGNMENT
%token PLUS MINUS POW MULTIPLY DIVIDE MOD BR_OPEN BR_CLOSE LESS MORE nEQUALS EQUALS LESSoE MOREoE

%token<c_value> ID TYPE NUMBER

%start prog

%%

prog:
	PROGRAM ID stmts END_PROGRAM
;

stmts:
|	stmt SEMICOLON stmts
|	declarations   stmts
|	condition      stmts
|	repeat         stmts
|	while          stmts
|	for            stmts
;

stmt:
|	assignment_stmt
|	expression { expression.str(""); }
;

assignment_stmt:
	ID ASSIGNMENT {
		assignment_statement * p_as = new assignment_statement(nesting);
		p_as->id = $1;

		statements.push_back(p_as);
	} expression {
		assignment_statement * p_as = (assignment_statement *) statements.back();

		p_as->expression = expression.str();
		expression.str("");
	}
;

declarations:
	VAR declaration END_VAR
;

declaration:
|	ID COLON TYPE SEMICOLON {
	struct declaration tmp;
	strncpy(tmp.id, $1, CVAL_LENGTH);
	tmp.type = transfer_st_type_to_c($3);

	declarations.push_back(tmp);
} declaration;

condition:
	IF {
		if_statement * p_is = new if_statement(nesting++);
		statements.push_back(p_is);
	} expression {
		if_statement * p_is = (if_statement *) statements.back();

		p_is->condition = expression.str();
		expression.str("");
	} THEN stmts else_of_condition END_IF {
		nesting--;
		statements.push_back(new end_statement(nesting, statement_type::_end_if));
	}
;

else_of_condition:
|	ELSE {
		else_statement * p_es = new else_statement(nesting - 1);
		statements.push_back(p_es);
	} stmts {
		nesting--;
		statements.push_back(new end_statement(nesting, statement_type::_end_else));
	}
;

for:
	FOR {
		for_statement * p_fs = new for_statement(nesting++);
		statements.push_back(p_fs);
	} assignment_stmt TO expression {
		auto iterator = statements.rbegin();
		iterator++;
		for_statement * p_fs = (for_statement *) (*iterator);

		p_fs->to = expression.str();
		expression.str("");
	} BY expression {
		auto iterator = statements.rbegin();
		iterator++;
		for_statement * p_fs = (for_statement *) (*iterator);

		p_fs->by = expression.str();
		expression.str("");
	} DO stmts END_FOR {
		nesting--;
		statements.push_back(new end_statement(nesting, statement_type::_end_for));
	}
;

while:
	WHILE {
		while_statement * p_ws = new while_statement(nesting++);
		statements.push_back(p_ws);
	} expression {
		while_statement * p_ws = (while_statement *) statements.back();

		p_ws->condition = expression.str();
		expression.str("");
	} DO stmts END_WHILE {
		nesting--;
		statements.push_back(new end_statement(nesting, statement_type::_end_while));
	}
;

repeat:
	REPEAT {
		repeat_statement * p_rs = new repeat_statement(nesting++);
		statements.push_back(p_rs);
	} stmts UNTIL expression {
		for (auto p_s = statements.rbegin(); p_s != statements.rend(); p_s++) {
			if (
				(*p_s)->type == statement_type::_repeat &&
				( (repeat_statement *) (*p_s) )->condition == ""
			) {
				( (repeat_statement *) (*p_s) )->condition = expression.str();
				expression.str("");
				break;
			}
		}
	} END_REPEAT {
		nesting--;
		statements.push_back(new end_statement(nesting, statement_type::_end_repeat));
	}
;

expression:
	ID { expression << $1 << " "; }
|	NUMBER { expression << $1 << " "; }
|	BR_OPEN { expression << "( "; } expression BR_CLOSE { expression << ") "; }
|	expression POW { expression << "** "; } expression {
	fix_pow();
}
|	expression operator expression
|	MINUS { expression << "- "; } expression
;

operator:
	MOD      { expression << "% ";  }
|	PLUS     { expression << "+ ";  }
|	LESS     { expression << "< ";  }
|	MORE     { expression << "> ";  }
|	MINUS    { expression << "- ";  }
|	DIVIDE   { expression << "/ ";  }
|	EQUALS   { expression << "== "; }
|	LESSoE   { expression << "<= "; }
|	MOREoE   { expression << ">= "; }
|	nEQUALS  { expression << "!= "; }
|	MULTIPLY { expression << "* ";  }
;

%%

int main(int argc, char *argv[]) {
	if (argc < 2) {
		fprintf(stderr, "Input file name not specified\n");
		exit(1);
	}

	yyin = fopen(argv[1], "r");
	if (yyin == NULL) {
		fprintf(stderr, "Can't open input file\n");
		exit(1);
	}

	yyparse();

	#ifdef DEBUG_LEX
		printf("\n");
	#endif

	if (argc == 3) {
		translator(argv[2], declarations, statements, is_math_in_use);
	} else {
		translator("output.cpp", declarations, statements, is_math_in_use);
	}

	fclose(yyin);
}

void yyerror(const char* s) {
	fprintf(stderr, "Bison error: %s\n", s);
	fprintf(stderr, "Turn on DEBUG_LEX flag in config.hpp to see, where is problem\n");
	exit(1);
}

const char * transfer_st_type_to_c(char * type) {
	if ( !strncmp(type, "SINT", CVAL_LENGTH) ) { 
		return "short int";
	} else if ( !strncmp(type, "INT", CVAL_LENGTH) ) {
		return "int";
	} else if ( !strncmp(type, "DINT", CVAL_LENGTH) ) {
		return "long int";
	} else if ( !strncmp(type, "LINT", CVAL_LENGTH) ) {
		return "long long int";
	} else if ( !strncmp(type, "USINT", CVAL_LENGTH) ) {
		return "unsigned short int";
	} else if ( !strncmp(type, "UINT", CVAL_LENGTH) ) {
		return "unsigned int";
	} else if ( !strncmp(type, "LDINT", CVAL_LENGTH) ) {
		return "unsigned long int";
	} else if ( !strncmp(type, "ULINT", CVAL_LENGTH) ) {
		return "unsigned long long int";
	}
}

void fix_pow() {
	if ( !is_math_in_use ) is_math_in_use = true;

	std::string expr = expression.str();
	std::size_t pos = expr.find("**");

	std::string part1 = expr.substr(0, pos - 1);
	std::string part2 = expr.substr(pos + 3);

	std::string word1;
	std::size_t word_length = 0;
	std::size_t br_depth = 0;

	if (part1[pos - 2] == ')') {
		for (
			auto it = part1.rbegin();
			( br_depth != 0 && it != part1.rend() ) || word_length == 0;
			it++
		) {
			word_length++;

			if (*it == ')') {
				br_depth++;
			} else if (*it == '(') {
				br_depth--;
			}
		}

		word1 = part1.substr( pos - 1 - word_length );
	} else {
		word1 = part1.substr( part1.rfind(" ") + 1 );
	}

	std::string word2;
	word_length = 0;
	br_depth = 0;

	if (part2[0] == '(') {
		for (
			auto it = part2.begin();
			( br_depth != 0 && it != part2.end() ) || word_length == 0;
			it++
		) {
			word_length++;

			if (*it == ')') {
				br_depth--;
			} else if (*it == '(') {
				br_depth++;
			}
		}

		word2 = part2.substr( 0, word_length );
	} else {
		word2 = part2.substr( 0, part2.find(" ") );
	}

	expression.str(
		expr.replace(
			pos - word1.size() - 1,
			word1.size() + word2.size() + 4,
			"pow( " + word1 + " , " + word2 + " ) "
		)
	);
}