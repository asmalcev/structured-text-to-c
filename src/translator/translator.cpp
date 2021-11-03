#include <iostream>

#include "translator.hpp"

void translator(
	const char * output_filename,
	std::vector<declaration> &declarations,
	std::vector<statement *> &statements,
	bool is_math_in_use
) {
	std::ofstream output(output_filename);

	if ( !output.is_open() ) {
		std::cout << "Can't open file " << output_filename << std::endl;
		exit(1);
	}

	if (is_math_in_use) {
		output << "#include <cmath>" << std::endl << std::endl;
	}

	output << "int main() {" << std::endl;

	for (declaration tmp : declarations) {
		push_tabs(output);
		output << tmp.type << " " << tmp.id << ";" << std::endl;
	}

	for (statement * p_s : statements) {
		if (p_s->type == statement_type::_assign) {

			assignment_statement * p_as = (assignment_statement *) p_s;
			push_tabs(output, p_as->nesting + 1);
			output << p_as->id << " = " << p_as->expression << ";" << std::endl;

		} else if (p_s->type == statement_type::_if) {

			if_statement * p_is = (if_statement *) p_s;
			push_tabs(output, p_is->nesting + 1);
			output << "if ( " << p_is->condition << " ) {" << std::endl;

		} else if (p_s->type == statement_type::_else) {

			else_statement * p_es = (else_statement *) p_s;
			push_tabs(output, p_es->nesting + 1);
			output << "else {" << std::endl;

		} else if (p_s->type == statement_type::_for) {

			for_statement * p_fs = (for_statement *) p_s;
			push_tabs(output, p_fs->nesting + 1);
			output << "for ( " << "; " << p_fs->to << "; " << p_fs->by << " ) {" << std::endl;

		} else if (p_s->type == statement_type::_while) {

			while_statement * p_ws = (while_statement *) p_s;
			push_tabs(output, p_ws->nesting + 1);
			output << "while ( " << p_ws->condition << " ) {" << std::endl;

		} else if (p_s->type == statement_type::_repeat) {

			repeat_statement * p_rs = (repeat_statement *) p_s;
			push_tabs(output, p_rs->nesting + 1);
			output << "repeat ( " << p_rs->condition << " ) {" << std::endl;

		}
	}

	output << "}" << std::endl;
}

void push_tabs(
	std::ofstream &output,
	unsigned int tabs_count
) {
	for (unsigned int i = 0; i < tabs_count; i++) {
		output << "\t";
	}
}