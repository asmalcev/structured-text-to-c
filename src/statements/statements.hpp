#pragma once

#include <queue>
#include <string>

#include "../config.hpp"

struct declaration {
	char id[CVAL_LENGTH];
	const char * type;
};

enum statement_type {
	_statement,

	_assign,

	_if,
	_else,

	_for,
	_while,
	_repeat
};

struct statement {
	statement_type type;
	unsigned int nesting;

	statement();
	statement(unsigned int _nesting);
};

struct assignment_statement : public statement {
	std::string id;
	std::string expression;

	assignment_statement(
		unsigned int _nesting
	);
};

struct if_statement : public statement {
	std::string condition;

	if_statement(
		unsigned int _nesting
	);
};

struct else_statement : public statement {
	else_statement(
		unsigned int _nesting
	);
};

struct for_statement : public statement {
	std::string to;
	std::string by;

	for_statement(
		unsigned int _nesting
	);
};

struct while_statement : public statement {
	std::string condition;

	while_statement(
		unsigned int _nesting
	);
};

struct repeat_statement : public statement {
	std::string condition;

	repeat_statement(
		unsigned int _nesting
	);
};