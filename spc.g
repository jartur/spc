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

block	:	label_declarations
		const_definitions
		type_definitions
		var_declarations
		proc_func_declarations
		compound_statement;

label_declarations
	:	(LABEL UNSIGNED_INTEGER (',' UNSIGNED_INTEGER)* ';')?;

const_definitions
	:	(CONST (const_definition ';')+)?;

type_definitions
	:	(TYPE (type_definition ';')+)?;

var_declarations
	:	(VAR (var_declaration ';')+)?;
	
proc_func_declarations
	:	((proc_declaration | func_declaration) ';')*;
	
const_definition
	:	ID '=' constant;
	
constant:	(SIGN)? (unsigned_number | ID)
	|	STRING;

type_definition
	:	ID '=' type_denoter;

type_denoter
	:	ID | new_type;

new_type:	new_ord_type | new_struct_type | new_pointer_type;

ord_type
	:	new_ord_type | ID;
	
new_ord_type
	:	enum_type | subrange_type;
	
enum_type
	:	'(' id_list ')';
	
id_list	:	ID (',' ID)*;

subrange_type
	:	constant '..' constant;
	
struct_type
	:	new_struct_type | ID;
	
new_struct_type
	:	(PACKED)? unpacked_struct_type;

unpacked_struct_type
	:	array_type | record_type | set_type | file_type;
	
array_type
	:	ARRAY '[' ord_type (',' ord_type)* ']' OF type_denoter;
	
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
	
set_type:	SET OF ord_type;
	
file_type
	:	FILE OF type_denoter;
	
pointer_type
	:	new_pointer_type | ID;
	
new_pointer_type
	:	'^' ID;
	
var_declaration
	:	id_list ':' type_denoter;

var_access
	:	ID var_access_rest*;

var_access_rest
	:	'[' expr (',' expr)* ']' | '.' ID | '^'	;

proc_declaration
	:	proc_heading ';' (ID | block);
	
proc_heading
	:	PROCEDURE ID (formal_parameter_list)*;

func_declaration
	:	func_heading ';' (ID | block)
	|	func_identification ';' block;

func_heading
	:	FUNCTION ID (formal_parameter_list)* ':' ID;
	
func_identification
	:	FUNCTION ID;
	
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
	
factor	:	ID (var_access_rest | ('(' expr (',' expr)* ')'))
	|	unsigned_const
	|	set_constructor
	|	'(' expr ')'
	|	NOT factor;

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

multop	:	'*' | '/' | (D I V) | MOD | AND;

addop	:	'+' | '-' | OR;

relop	:	'=' | '<>' | '<' | '>' | '<=' | '>=' | IN;

func_designator
	:	ID ('(' expr (',' expr)* ')')?;

simple_statement
	:	empty_statement
	|	assign_statement
	|	proc_statement
	| 	goto_statement;
	
empty_statement
	:	;
	
assign_statement
	:	var_access ':=' expr;
	
proc_statement
	:	ID ( '(' expr (':' expr (':' expr)?)? ( (',' expr (':' expr (':' expr)?)?)*) ')')?;
			
goto_statement
	:	GOTO UNSIGNED_INTEGER;
	
struct_statement
	:	compound_statement
	|	cond_statement
	| 	repetitive_statement
	|	with_statement;
	
statement_sequence
	:	statement (';' statement)*;
	
compound_statement
	:	BEGIN statement_sequence END;
	
cond_statement
	:	if_statement 
	| 	case_statement;
	
if_statement
	:	IF expr THEN statement (else_part)?;

else_part
	:	ELSE statement;
	
case_statement
	:	CASE expr OF case_list_element (';' case_list_element)* (';')? END;

case_list_element
	:	case_const_list ':' statement;
	
repetitive_statement
	:	repeat_statement
	|	while_statement
	|	for_statement;
	
repeat_statement
	:	REPEAT statement_sequence UNTIL expr;

while_statement
	:	WHILE expr DO statement;
	
for_statement
	:	FOR ID ':=' expr ( TO | DOWNTO ) expr DO statement;
	
with_statement
	:	WITH record_var_list DO statement;
	
record_var_list
	:	var_access (',' var_access)*;
	
program	:	program_heading ';' block '.';

program_heading
	:	PROGRAM ID ('(' id_list ')')?;	

// TODO: Strings, comments;

statement
	:	( UNSIGNED_INTEGER ':' )? ( simple_statement | struct_statement );

signed_number
	:	SIGNED_INTEGER | SIGNED_REAL | unsigned_number;
SIGNED_REAL
	:	SIGN UNSIGNED_REAL;
SIGNED_INTEGER
	:	SIGN UNSIGNED_INTEGER;
unsigned_number
	:	UNSIGNED_INTEGER | UNSIGNED_REAL;
fragment SIGN	:	'+' | '-';
UNSIGNED_REAL
	:	DIGITSEQ '.' FRAC_PART (E SCALE_FACTOR)
	|	DIGITSEQ E SCALE_FACTOR;
UNSIGNED_INTEGER
	:	DIGITSEQ;
fragment FRAC_PART
	:	DIGITSEQ;
fragment SCALE_FACTOR
	:	(SIGN)? DIGITSEQ;
fragment DIGITSEQ:	('0'..'9')+;

STRING	:	'\'' (STRING_ELEMENT)+ '\'';
fragment STRING_ELEMENT
	:	APOSTROPHE_IMAGE | STRING_CHAR;
fragment APOSTROPHE_IMAGE
	:	'\'\'';
fragment STRING_CHAR
	:	'a';

// ANTLR doesn't support case-insensitive languages.
AND	:	A N D;
ARRAY	:	A R R A Y;
BEGIN	:	B E G I N;
CASE	:	C A S E;
CONST	:	C O N S T;
DIV 	:	 D I V;
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

ID	:	LETTER (LETTER | '0'..'9')*;

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
