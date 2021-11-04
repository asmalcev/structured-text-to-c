#include <iostream>
#include <stack>

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

	struct repeat_note {
		std::string expr;
		unsigned int nesting;
	};

	std::stack<repeat_note *> repeat_stack;

	unsigned int last_nesting = 0;
	bool is_last_step = false;
	for (auto it = statements.begin(); it != statements.end(); it++) {
		statement * p_s = *it;

		if (last_nesting > p_s->nesting) {
			if (!repeat_stack.empty() && p_s->nesting == repeat_stack.top()->nesting) {
				push_tabs(output, p_s->nesting + 1);
				output << "} while ( " << repeat_stack.top()->expr << ");" << std::endl;
				delete repeat_stack.top();
				repeat_stack.pop();
			} else {
				push_tabs(output, p_s->nesting + 1);
				output << "}" << std::endl;
			}
		}

		if (p_s->type == statement_type::_assign) {

			assignment_statement * p_as = (assignment_statement *) p_s;
			push_tabs(output, p_as->nesting + 1);
			output << p_as->id << " = " << p_as->expression << ";" << std::endl;

		} else if (p_s->type == statement_type::_if) {

			if_statement * p_is = (if_statement *) p_s;
			push_tabs(output, p_is->nesting + 1);
			output << "if ( " << p_is->condition << ") {" << std::endl;

		} else if (p_s->type == statement_type::_else) {

			else_statement * p_es = (else_statement *) p_s;
			push_tabs(output, p_es->nesting + 1);
			output << "else {" << std::endl;

		} else if (p_s->type == statement_type::_for) {

			for_statement * p_fs = (for_statement *) p_s;
			push_tabs(output, p_fs->nesting + 1);

			std::string to = p_fs->to;
			std::string by = p_fs->by;

			assignment_statement * p_as = (assignment_statement *) *(++it);

			output << "for ( "
			       << p_as->id << " = " << p_as->expression << "; "
						 << p_as->id << " < " << to << "; "
						 << p_as->id << " = " << p_as->id << " + " << by
						 << ") {" << std::endl;

		} else if (p_s->type == statement_type::_while) {

			while_statement * p_ws = (while_statement *) p_s;
			push_tabs(output, p_ws->nesting + 1);
			output << "while ( " << p_ws->condition << ") {" << std::endl;

		} else if (p_s->type == statement_type::_repeat) {

			repeat_statement * p_rs = (repeat_statement *) p_s;
			push_tabs(output, p_rs->nesting + 1);
			output << "do {" << std::endl;

			repeat_note * p_rp = new repeat_note();
			p_rp->expr = p_rs->condition;
			p_rp->nesting = p_rs->nesting;

			repeat_stack.push(p_rp);

		}
		last_nesting = p_s->nesting;
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