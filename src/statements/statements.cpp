#include <iostream>

#include "statements.hpp"

statement::statement()
: nesting(0) {
	type = statement_type::_statement;
}

statement::statement(unsigned int _nesting)
: nesting(_nesting) {
	type = statement_type::_statement;
}

assignment_statement::assignment_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_assign;
}

if_statement::if_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_if;
}

else_statement::else_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_else;
}

for_statement::for_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_for;
}

while_statement::while_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_while;
}

repeat_statement::repeat_statement(
	unsigned int _nesting
) : statement(_nesting) {
	type = statement_type::_repeat;
}