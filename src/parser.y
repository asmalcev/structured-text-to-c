%{

/************************
---      includes     ---
************************/

#include <queue>
#include <stack>

#include <stdio.h>
#include <string.h>

#include "../src/config.hpp"

/************************
---       bison       ---
************************/
extern int yylex();
extern int yyparse();
extern FILE * yyin;

void yyerror(const char * s);

/************************
---       debug       ---
************************/
#ifdef DEBUG_YACC
	#define LOGy(...) printf(__VA_ARGS__)
#else
	#define LOGy
#endif

/************************
---      output       ---
************************/
FILE * parser_output;

typedef long unsigned size_t;

struct declaration {
	char id[CVAL_LENGTH];
	const char * type;
};

std::stack<declaration> declarations;

const char * transfer_st_type_to_c(char * type);
void output_declarations();

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
|	expression
;

assignment_stmt:
	ID ASSIGNMENT expression
;

declarations:
	VAR declaration END_VAR
;

declaration:
|	ID COLON TYPE SEMICOLON declaration {
	struct declaration tmp;
	strncpy(tmp.id, $1, CVAL_LENGTH);
	tmp.type = transfer_st_type_to_c($3);

	declarations.push(tmp);
}
;

condition:
	IF expression THEN stmts else_of_condition END_IF
;

else_of_condition:
|	ELSE stmts
;

for:
	FOR assignment_stmt TO expression BY expression DO stmts END_FOR
;

while:
	WHILE expression DO stmts END_WHILE
;

repeat:
	REPEAT stmts UNTIL expression END_REPEAT
;

expression:
	NUMBER
| ID
|	expression operator expression
|	BR_OPEN expression BR_CLOSE
;

operator:
	PLUS
|	MINUS
|	MULTIPLY
|	DIVIDE
|	MOD
|	LESS
|	MORE
|	nEQUALS
|	EQUALS
|	LESSoE
|	MOREoE
|	POW
;

%%

int main(int argc, char *argv[]) {
	yyin = fopen("examples/ex0", "r");
	parser_output = stdout;

	yyparse();

	#ifdef DEBUG_LEX
		printf("\n");
	#endif

	output_declarations();

	fclose(yyin);
}

void yyerror(const char* s) {
	fprintf(stderr, "Bison error: %s\n", s);
	exit(1);
}

void output_declarations() {
	struct declaration tmp;
	while ( !declarations.empty() ) {
		tmp = declarations.top();
		declarations.pop();
		fprintf(parser_output, "%s %s\n", tmp.type, tmp.id);
	}
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