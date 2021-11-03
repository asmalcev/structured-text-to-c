#pragma once

#include <fstream>

#include "../statements/statements.hpp"

void translator(
	const char * output_filename,
	std::vector<declaration> &declarations,
	std::vector<statement *> &statements,
	bool is_math_in_use = false
);

void push_tabs(
	std::ofstream &output,
	unsigned int tabs_count = 1
);