grammar spc;
/*
* Pascal grammar. Adopted directly from Pascal ISO/IEC 7185:1990 standard.
* This is a practical AST-bulding version. This part of grammar is concerned
* only with Syntax not Semantics. For Semantical parts look at base_grammar.g
* and ast.g
* 2009, Ilya 'jartur' Pavlenkov
*/

options
{
	language=Python;
	output=AST;
}

// 6.2.1 Blocks
block	:	label_declarations
		const_definitions
		type_definitions
		var_declarations
		proc_func_declarations
		compound_statement;

label_declarations
	:	(LABEL LABELT (',' LABELT)* ';')?;

const_definitions
	:	(CONST (const_definition ';')+)?;

type_definitions
	:	(TYPE (type_definition ';')+)?;

var_declarations
	:	(VAR (var_declaration ';')+)?;
	
proc_func_declarations
	:	((proc_declaration | func_declaration) ';')*;
	
// 6.3 Constant-definitions
const_definition
	:	ID '=' constant;
	
constant:	(SIGN)? (unsigned_number | ID)
	|	STRING;

// 6.4.1 General type-definitions
type_definition
	:	ID '=' type_denoter;

type_denoter
	:	ID | new_type;

new_type:	new_ord_type | new_struct_type | new_pointer_type;

// 6.4.2.1 General simple-types

ord_type
	:	new_ord_type | ID;
	
new_ord_type
	:	enum_type | subrange_type;
	
	
// 6.4.2.3 Enumerated-types
enum_type
	:	'(' id_list ')';
	
id_list	:	ID (',' ID)*;

// 6.4.2.4 Subrange-types
subrange_type
	:	constant '..' constant;
	
// 6.4.3.1 General structured-types
struct_type
	:	new_struct_type | ID;
	
new_struct_type
	:	(PACKED)? unpacked_struct_type;

unpacked_struct_type
	:	array_type | record_type | set_type | file_type;
	
// 6.4.3.2 Array-types
array_type
	:	ARRAY '[' ord_type (',' ord_type)* ']' OF type_denoter;
	
// 6.4.3.3 Record-types
record_type
	:	RECORD field_list END;
	
field_list
	:	( ( (fixed_part (';' variant_part)?) | variant_part) (';')?)?; 
	
fixed_part
	:	record_section (';' record_section)*;

record_section
	:	id_list ':' type_denoter;

variant_part
	:	CASE variant_selector OF variant (';' variant)*;
	
variant_selector
	:	(ID ':')? ID;
	
variant	:	case_const_list ':' '(' field_list ')';

case_const_list
	:	constant (',' constant)*;
	
// 6.4.3.4 Set-types
set_type:	SET OF ord_type;
	
// 6.4.3.5 File-types
file_type
	:	FILE OF type_denoter;
	
// 6.4.4 Pointer-types
pointer_type
	:	new_pointer_type | ID;
	
new_pointer_type
	:	'^' ID;
	
// 6.5.1 Variable-declarations
var_declaration
	:	id_list ':' type_denoter;

var_access
	:	ID | component_var | id_var | buffer_var;
	
id_var	:	var_access '^';

// 6.5.3.1 General component-variables
component_var
	:	indexed_var | field_designator;
	
// 6.5.3.2 Indexed-variables
indexed_var
	:	var_access '[' expr (',' expr)* ']';

// 6.5.3.3 Field-designators
field_designator
	:	var_access '.' ID
	|	ID;
	
// 6.5.5 Buffer-variables
buffer_var
	:	var_access '^';

// 6.6.1 Procedure-declarations
proc_declaration
	:	proc_heading ';' (ID | block);
	
proc_heading
	:	PROCEDURE ID (formal_parameter_list)*;

// 6.6.2 Function-declarations
func_declaration
	:	func_heading ';' (ID | block)
	|	func_identification ';' block;

func_heading
	:	FUNCTION ID (formal_parameter_list)* ':' ID;
	
func_identification
	:	FUNCTION ID;
	
// 6.6.3.1 General parameters
formal_parameter_list
	:	'(' formal_parameter_section (';' formal_parameter_section)* ')';
	
formal_parameter_section
	:	value_parameter_spec
	|	var_parameter_spec
	|	proc_heading
	|	func_heading
	|	conformant_array_parameter_spec;
	
value_parameter_spec
	:	id_list ':' ID;
	
var_parameter_spec
	:	VAR id_list ':' ID;

// 6.6.3.7.1 General conformant array parameters
conformant_array_parameter_spec
	:	value_conf_array_spec
	|	var_conf_array_spec;
	
value_conf_array_spec
	:	id_list ':' conf_array_schema;
	
var_conf_array_spec
	:	VAR id_list ':' conf_array_schema;
	
conf_array_schema
	:	packed_conf_array_schema
	|	unpacked_conf_array_schema;
	
packed_conf_array_schema
	:	PACKED ARRAY '[' index_type_spec ']' OF ID;
	
unpacked_conf_array_schema
	:	ARRAY '[' index_type_spec (';' index_type_spec)* ']' OF (ID | conf_array_schema);
	
index_type_spec
	:	ID '..' ID ':' ID;
	
factor	:	ID
	|	var_access
	|	unsigned_const
	|	func_designator
	|	set_constructor
	|	'(' expr ')'
	|	NOT factor;

// 6.7.1 General expressions
expr	:	simple_expr (relop simple_expr)?;

simple_expr
	:	(SIGN)? term (addop term)*;
	
term	:	factor (multop factor)*;

unsigned_const
	:	unsigned_number
	|	STRING
	|	ID
	|	NIL;
	
set_constructor
	:	'[' (member_designator (',' member_designator)*)? ']';
	
member_designator
	:	expr ('..' expr)?;

// 6.7.2.1 General operators
multop	:	'*' | '/' | DIV | MOD | AND;

addop	:	'+' | '-' | OR;

relop	:	'=' | '<>' | '<' | '>' | '<=' | '>=' | IN;

// 6.7.3 Function-designators
func_designator
	:	ID (actual_param_list)?;
	
actual_param_list
	:	'(' actual_param (',' actual_param)* ')';

actual_param
	:	expr
	|	var_access
	|	ID;
	
// 6.8.2.1 General simple-statements
simple_statement
	:	empty_statement
	|	assign_statement
	|	proc_statement
	| 	goto_statement;
	
empty_statement
	:	;
	
// 6.8.2.2 Assignment-statements
assign_statement
	:	(var_access | ID) ':=' expr;
	
// 6.8.2.3 Procedure-statements
proc_statement
	:	ID ( (actual_param_list)? 
			| read_param_list
			| readln_param_list
			| write_param_list
			| writeln_param_list );
			
// 6.8.2.4 Goto-statements
goto_statement
	:	GOTO LABELT;
	
// 6.8.3.1 General structured-statements
struct_statement
	:	compound_statement
	|	cond_statement
	| 	repetitive_statement
	|	with_statement;
	
statement_sequence
	:	statement (';' statement)*;
	
// 6.8.3.2 Compound-statements
compound_statement
	:	BEGIN statement_sequence END;
	
// 6.8.3.3 Conditional-statements
cond_statement
	:	if_statement 
	| 	case_statement;
	
// 6.8.3.4 If-statements
if_statement
	:	IF expr THEN statement (else_part)?;

else_part
	:	ELSE statement;
	
// 6.8.3.5 Case-statements
case_statement
	:	CASE expr OF case_list_element (';' case_list_element)* (';')? END;

case_list_element
	:	case_const_list ':' statement;
	
// 6.8.3.6 Repetitive-statements
repetitive_statement
	:	repeat_statement
	|	while_statement
	|	for_statement;
	
// 6.8.3.7
repeat_statement
	:	REPEAT statement_sequence UNTIL expr;

// 6.8.3.8 While-statements
while_statement
	:	WHILE expr DO statement;
	
// 6.8.3.9 For-statements
for_statement
	:	FOR ID ':=' expr ( TO | DOWNTO ) expr DO statement;
	
// 6.8.3.10 With-statements
with_statement
	:	WITH record_var_list DO statement;
	
record_var_list
	:	var_access (',' var_access)*;
	
// 6.9.1 The procedure read
read_param_list
	:	'(' (var_access ',')? var_access (',' var_access)* ')';

// 6.9.2 The procedure readln
readln_param_list
	:	( '(' ( var_access | var_access ) (',' var_access)* )?;
	
// 6.9.3 The procedure write
write_param_list
	:	'(' (var_access ',')? write_param (',' write_param)* ')';
	
write_param
	:	expr (':' expr (':' expr)?)?;
	
// 6.9.4 The procedure writeln
writeln_param_list
	:	( '(' (var_access | write_param) (',' write_param)* ')' )?;
	
// 6.10 Programs
program	:	program_heading ';' block '.';

program_heading
	:	PROGRAM ID ('(' id_list ')')?;	

// TODO: Strings, comments;

statement
	:	( LABELT ':' )? ( simple_statement | struct_statement );

// 6.1.3 Identifiers
ID	:	LETTER (LETTER | '0'..'9')*;

// 6.1.5 Numbers
signed_number
	:	SIGNED_INTEGER | SIGNED_REAL;
SIGNED_REAL
	:	(SIGN)? UNSIGNED_REAL;
SIGNED_INTEGER
	:	(SIGN)? UNSIGNED_INTEGER;
unsigned_number
	:	UNSIGNED_INTEGER | UNSIGNED_REAL;
SIGN	:	'+' | '-';
UNSIGNED_REAL
	:	DIGITSEQ '.' FRAC_PART (E SCALE_FACTOR)
	|	DIGITSEQ E SCALE_FACTOR;
UNSIGNED_INTEGER
	:	DIGITSEQ;
FRAC_PART
	:	DIGITSEQ;
SCALE_FACTOR
	:	(SIGN)? DIGITSEQ;
DIGITSEQ:	('0'..'9')+;

// 6.1.6 Labels
LABELT	:	DIGITSEQ;

// 6.1.7 Character-strings
STRING	:	'\'' (STRING_ELEMENT)+ '\'';
STRING_ELEMENT
	:	APOSTROPHE_IMAGE | STRING_CHAR;
APOSTROPHE_IMAGE
	:	'\'\'';
STRING_CHAR
	:	'a';


// Symbols may be needed for the lexer output. May not.
// 6.1.2 Special-symbols
SPSYMBOL:	  '+' | '-' | '*' | '/' | '=' | '<' | '>' | '[' | ']'
		| '.' | ',' | ':' | ';' | '^' | '(' | ')'
		| '<>'| '<='| '>='| ':='| '..'| WORDSYMBOL;

WORDSYMBOL
	:	AND | ARRAY | BEGIN | CASE | CONST | DO | DOWNTO | ELSE | END | FILE
	|	FOR | FUNCTION | GOTO | IF | IN | LABEL | MOD | NIL | NOT | OF | OR
	|	PACKED | PROCEDURE | PROGRAM | RECORD | REPEAT | SET | THEN | TO
	|	TYPE | UNTIL | VAR | WHILE | WITH | DIV;

// ANTLR doesn't support case-insensitive languages.
DIV 	: 	D I V;
AND	:	A N D;
ARRAY	:	A R R A Y;
BEGIN	:	B E G I N;
CASE	:	C A S E;
CONST	:	C O N S T;
DO	:	D O;
DOWNTO	:	D O W N T O;
ELSE	:	E L S E;
END	:	E N D;
FILE	:	F I L E;
FOR	:	F O R;
FUNCTION:	F U N C T I O N;
GOTO	:	G O T O;
IF	:	I F;
IN	:	I N;
LABEL	:	L A B E L;
MOD	:	M O D;
NIL	:	N I L;
NOT	:	N O T;
OF	:	O F;
OR	:	O R;
PACKED	:	P A C K E D;
PROCEDURE :	P R O C E D U R E;
PROGRAM	:	P R O G R A M;
RECORD	:	R E C O R D;
REPEAT	:	R E P E A T;
SET	:	S E T;
THEN	:	T H E N;
TO	:	T O;
TYPE	:	T Y P E;
UNTIL	:	U N T I L;
VAR	:	V A R;
WHILE	:	W H I L E;
WITH	:	W I T H;		

// Fragments a.k.a. named regexes
fragment LETTER
	:	(A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z);

fragment A:('a'|'A');
fragment B:('b'|'B');
fragment C:('c'|'C');
fragment D:('d'|'D');
fragment E:('e'|'E');
fragment F:('f'|'F');
fragment G:('g'|'G');
fragment H:('h'|'H');
fragment I:('i'|'I');
fragment J:('j'|'J');
fragment K:('k'|'K');
fragment L:('l'|'L');
fragment M:('m'|'M');
fragment N:('n'|'N');
fragment O:('o'|'O');
fragment P:('p'|'P');
fragment Q:('q'|'Q');
fragment R:('r'|'R');
fragment S:('s'|'S');
fragment T:('t'|'T');
fragment U:('u'|'U');
fragment V:('v'|'V');
fragment W:('w'|'W');
fragment X:('x'|'X');
fragment Y:('y'|'Y');
fragment Z:('z'|'Z');
