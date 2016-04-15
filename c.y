/* adapted from https://www.lysator.liu.se/c/ANSI-C-grammar-y.html */

%nonassoc THEN
%nonassoc ELSE

%start translation_unit

/* https://github.com/zaach/jison/issues/313 */
%{
var Jison = require('jison');
var n = require('./ASTNode');
%}

%%

primary_expression
        : IDENTIFIER -> new n.NameRef($1)
        | INT_CONSTANT -> new n.IntegerLiteral(parseInt($1))
        | FLOAT_CONSTANT -> new n.FloatingPointLiteral(parseFloat($1))
        | CHAR_CONSTANT -> new n.CharLiteral($1.charCodeAt(0))
        | STRING_LITERAL -> new n.StringLiteral($1)
        | '(' expression ')' -> new n.ParenthesesOperator($2)
        ;

postfix_expression
        : primary_expression
        | postfix_expression '[' expression ']' -> new n.Subscript($1, $3)
        | postfix_expression '(' ')' -> new n.FunctionCall($1)
        | postfix_expression '(' argument_expression_list ')' -> new n.FunctionCall($1, $3)
        | postfix_expression '.' IDENTIFIER -> new n.DotOperator($1, $3)
        | postfix_expression PTR_OP IDENTIFIER -> new n.ArrowOperator($1, $3)
        | postfix_expression INC_OP -> new n.PostIncrementOperator($1)
        | postfix_expression DEC_OP -> new n.PostDecrementOperator($1)
        ;

argument_expression_list
        : assignment_expression -> [$1]
        | argument_expression_list ',' assignment_expression -> $1.concat($3)
        ;

unary_expression
        : postfix_expression
        | INC_OP unary_expression -> new n.PreIncrementOperator($2)
        | DEC_OP unary_expression -> new n.PreDecrementOperator($2)
        | '&' cast_expression -> new n.ReferenceOperator($2)
        | '*' cast_expression -> new n.DereferenceOperator($2)
        | '+' cast_expression -> new n.PlusUnaryOperator($2)
        | '-' cast_expression -> new n.MinusUnaryOperator($2)
        | '~' cast_expression -> new n.BinaryNotOperator($2)
        | '!' cast_expression -> new n.BooleanNotOperator($2)
        | SIZEOF unary_expression -> new n.SizeofOperator($2)
        | SIZEOF '(' type_name ')' -> new n.SizeofOperator($3)
        ;

cast_expression
        : unary_expression
        | '(' type_name ')' cast_expression -> new n.ExplicitCast($2, $4)
        ;

multiplicative_expression
        : cast_expression
        | multiplicative_expression '*' cast_expression -> new n.Multiplies($1, $3)
        | multiplicative_expression '/' cast_expression -> new n.Divides($1, $3)
        | multiplicative_expression '%' cast_expression -> new n.Mods($1, $3)
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression -> new n.Adds($1, $3)
        | additive_expression '-' multiplicative_expression -> new n.Subtracts($1, $3)
        ;

shift_expression
        : additive_expression
        | shift_expression LEFT_OP additive_expression -> new n.LeftShifts($1, $3)
        | shift_expression RIGHT_OP additive_expression -> new n.RightShifts($1, $3)
        ;

relational_expression
        : shift_expression
        | relational_expression '<' shift_expression -> new n.LessThanCompares($1, $3)
        | relational_expression '>' shift_expression -> new n.GreaterThanCompares($1, $3)
        | relational_expression LE_OP shift_expression -> new n.LessThanEqualCompares($1, $3)
        | relational_expression GE_OP shift_expression -> new n.GreaterThanEqualCompares($1, $3)
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression -> new n.Equals($1, $3)
        | equality_expression NE_OP relational_expression -> new n.NotEquals($1, $3)
        ;

and_expression
        : equality_expression
        | and_expression '&' equality_expression -> new n.BinaryAnds($1, $3)
        ;

exclusive_or_expression
        : and_expression
        | exclusive_or_expression '^' and_expression -> new n.BinaryXors($1, $3)
        ;

inclusive_or_expression
        : exclusive_or_expression
        | inclusive_or_expression '|' exclusive_or_expression -> new n.BinaryOrs($1, $3)
        ;

logical_and_expression
        : inclusive_or_expression
        | logical_and_expression AND_OP inclusive_or_expression -> new n.BooleanAnds($1, $3)
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression -> new n.BooleanOrs($1, $3)
        ;

conditional_expression
        : logical_or_expression
        | logical_or_expression '?' expression ':' conditional_expression
          { $$ = new n.TernaryOperator($1, $3, $5); }
        ;

assignment_expression
        : conditional_expression
        | unary_expression '=' assignment_expression -> new n.Assigns($1, $3)
        | unary_expression MUL_ASSIGN assignment_expression -> new n.MultipliesAssigns($1, $3)
        | unary_expression DIV_ASSIGN assignment_expression -> new n.DividesAssigns($1, $3)
        | unary_expression MOD_ASSIGN assignment_expression -> new n.ModsAssigns($1, $3)
        | unary_expression ADD_ASSIGN assignment_expression -> new n.AddsAssigns($1, $3)
        | unary_expression SUB_ASSIGN assignment_expression -> new n.SubtractsAssigns($1, $3)
        | unary_expression LEFT_ASSIGN assignment_expression -> new n.LeftShiftsAssigns($1, $3)
        | unary_expression RIGHT_ASSIGN assignment_expression -> new n.RightShiftsAssigns($1, $3)
        | unary_expression AND_ASSIGN assignment_expression -> new n.AndsAssigns($1, $3)
        | unary_expression XOR_ASSIGN assignment_expression -> new n.XorsAssigns($1, $3)
        | unary_expression OR_ASSIGN assignment_expression -> new n.OrsAssigns($1, $3)
        ;

expression
        : assignment_expression
        | expression ',' assignment_expression -> new n.Comma($1, $3)
        ;

declaration
        : declaration_specifiers ';' -> new n.ASTNode('Declaration', [$1])
        | declaration_specifiers init_declarator_list ';'
          { $$ = new n.ASTNode('Declaration', [$1, $2]); }
        ;

declaration_specifiers
        : storage_class_specifier
        | storage_class_specifier declaration_specifiers
          { $$ = new n.ASTNode('DeclarationSpecifiers', [$1, $2]); }
        | type_specifier
        | type_specifier declaration_specifiers
          { $$ = new n.ASTNode('DeclarationSpecifiers', [$1, $2]); }
        | type_qualifier
          { $$ = new n.ASTNode('DeclarationSpecifiers', [$1]); }
        | type_qualifier declaration_specifiers
          { $$ = new n.ASTNode('DeclarationSpecifiers', [$1, $2]); }
        ;

init_declarator_list
        : init_declarator
        | init_declarator_list ',' init_declarator -> new n.ASTNode('InitDeclaratorList', [$1, $3])
        ;

init_declarator
        : declarator
        | declarator '=' initializer -> new n.ASTNode('InitDeclarator', [$1, $3])
        ;

storage_class_specifier
        : TYPEDEF -> new n.ASTNode('StorageClassSpecifier', [$1])
        | EXTERN -> new n.ASTNode('StorageClassSpecifier', [$1])
        | STATIC -> new n.ASTNode('StorageClassSpecifier', [$1])
        | AUTO -> new n.ASTNode('StorageClassSpecifier', [$1])
        | REGISTER -> new n.ASTNode('StorageClassSpecifier', [$1])
        ;

/* TODO: allow for complex things like long/short/signed/unsigned primitives */
type_specifier
        : VOID -> new n.ASTNode('TypeSpecifier', [$1])
        | CHAR -> new n.ASTNode('TypeSpecifier', [$1])
        | SHORT -> new n.ASTNode('TypeSpecifier', [$1])
        | INT -> new n.ASTNode('TypeSpecifier', [$1])
        | LONG -> new n.ASTNode('TypeSpecifier', [$1])
        | FLOAT -> new n.ASTNode('TypeSpecifier', [$1])
        | DOUBLE -> new n.ASTNode('TypeSpecifier', [$1])
        | SIGNED -> new n.ASTNode('TypeSpecifier', [$1])
        | UNSIGNED -> new n.ASTNode('TypeSpecifier', [$1])
        | struct_or_union_specifier -> new n.ASTNode('TypeSpecifier', [$1])
        | enum_specifier -> new n.ASTNode('TypeSpecifier', [$1])
        | TYPE_NAME -> new n.ASTNode('TypeSpecifier', [$1])
        ;

struct_or_union_specifier
        : struct_or_union IDENTIFIER '{' struct_declaration_list '}'
          { $$ = new n.ASTNode('StructOrUnionSpecifier', [$1, $2, $4]); }
        | struct_or_union '{' struct_declaration_list '}'
          { $$ = new n.ASTNode('StructOrUnionSpecifier', [$1, $3]); }
        | struct_or_union IDENTIFIER
          { $$ = new n.ASTNode('StructOrUnionSpecifier', [$1, $2]); }
        ;

struct_or_union
        : STRUCT -> new n.ASTNode('StructOrUnion', [$1])
        | UNION -> new n.ASTNode('StructOrUnion', [$1])
        ;

struct_declaration_list
        : struct_declaration -> new n.ASTNode('StructDeclarationList', [$1])
        | struct_declaration_list struct_declaration
          { $$ = new n.ASTNode('StructDeclarationList', [$1, $2]); }
        ;

struct_declaration
        : specifier_qualifier_list struct_declarator_list ';'
          { $$ = new n.ASTNode('StructDeclaration', [$1, $2]); }
        ;

specifier_qualifier_list
        : type_specifier specifier_qualifier_list -> new n.ASTNode('SpecifierQualifierList', [$1, $2])
        | type_specifier
        | type_qualifier specifier_qualifier_list -> new n.ASTNode('SpecifierQualifierList', [$1, $2])
        | type_qualifier -> new n.ASTNode('SpecifierQualifierList', [$1])
        ;

struct_declarator_list
        : struct_declarator -> new n.ASTNode('StructDeclaratorList', [$1])
        | struct_declarator_list ',' struct_declarator
          { $$ = new n.ASTNode('StructDeclaratorList', [$1, $3]); }
        ;

struct_declarator
        : declarator -> new n.ASTNode('StructDeclarator', [$1])
        | ':' conditional_expression -> new n.ASTNode('StructDeclarator', [$2])
        | declarator ':' conditional_expression -> new n.ASTNode('StructDeclarator', [$1, $3])
        ;

enum_specifier
        : ENUM '{' enumerator_list '}' -> new n.ASTNode('EnumSpecifier', [$1, $3])
        | ENUM IDENTIFIER '{' enumerator_list '}' -> new n.ASTNode('EnumSpecifier', [$1, $3])
        | ENUM IDENTIFIER -> new n.ASTNode('EnumSpecifier', [$1])
        ;

enumerator_list
        : enumerator -> new n.ASTNode('EnumeratorList', [$1])
        | enumerator_list ',' enumerator -> new n.ASTNode('EnumeratorList', [$1, $3])
        ;

enumerator
        : IDENTIFIER -> new n.ASTNode('Enumerator', [$1])
        | IDENTIFIER '=' conditional_expression -> new n.ASTNode('Enumerator', [$1, $3])
        ;

type_qualifier
        : CONST -> new n.ASTNode('TypeQualifier', [$1])
        | VOLATILE -> new n.ASTNode('TypeQualifier', [$1])
        ;

declarator
        : pointer direct_declarator -> new n.ASTNode('Declarator', [$1, $2])
        | direct_declarator
        ;

direct_declarator
        : IDENTIFIER -> new n.ASTNode('DirectDeclarator', [$1])
        | '(' declarator ')' -> new n.ASTNode('DirectDeclarator', [$2])
        | direct_declarator '[' conditional_expression ']' -> new n.ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '[' ']' -> new n.ASTNode('DirectDeclarator', [$1])
        | direct_declarator '(' parameter_type_list ')' -> new n.ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '(' identifier_list ')' -> new n.ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '(' ')' -> new n.ASTNode('DirectDeclarator', [$1])
        ;

pointer
        : '*' -> new n.ASTNode('Pointer', [$1])
        | '*' type_qualifier_list -> new n.ASTNode('Pointer', [$1, $2])
        | '*' pointer -> new n.ASTNode('Pointer', [$1, $2])
        | '*' type_qualifier_list pointer -> new n.ASTNode('Pointer', [$1, $2])
        ;

type_qualifier_list
        : type_qualifier -> new n.ASTNode('TypeQualifierList', [$1])
        | type_qualifier_list type_qualifier -> new n.ASTNode('TypeQualifierList', [$1, $2])
        ;


parameter_type_list
        : parameter_list -> new n.ASTNode('ParameterTypeList', [$1])
        | parameter_list ',' ELLIPSIS -> new n.ASTNode('ParameterTypeList', [$1, $3])
        ;

parameter_list
        : parameter_declaration -> new n.ASTNode('ParameterList', [$1])
        | parameter_list ',' parameter_declaration -> new n.ASTNode('ParameterList', [$1, $3])
        ;

parameter_declaration
        : declaration_specifiers declarator -> new n.ASTNode('ParameterDeclaration', [$1, $2])
        | declaration_specifiers abstract_declarator -> new n.ASTNode('ParameterDeclaration', [$1, $2])
        | declaration_specifiers -> new n.ASTNode('ParameterDeclaration', [$1])
        ;

identifier_list
        : IDENTIFIER -> new n.ASTNode('IdentifierList', [$1])
        | identifier_list ',' IDENTIFIER -> new n.ASTNode('IdentifierList', [$1, $3])
        ;

type_name
        : specifier_qualifier_list
        | specifier_qualifier_list abstract_declarator -> new n.ASTNode('TypeName', [$1, $2])
        ;

abstract_declarator
        : pointer -> new n.ASTNode('AbstractDeclarator', [$1])
        | direct_abstract_declarator -> new n.ASTNode('AbstractDeclarator', [$1])
        | pointer direct_abstract_declarator -> new n.ASTNode('AbstractDeclarator', [$1])
        ;

direct_abstract_declarator
        : '(' abstract_declarator ')' -> new n.ASTNode('DirectAbstractDeclarator', [$2])
        | '[' ']' -> new n.ASTNode('DirectAbstractDeclarator', [])
        | '[' conditional_expression ']' -> new n.ASTNode('DirectAbstractDeclarator', [$2])
        | direct_abstract_declarator '[' ']' -> new n.ASTNode('DirectAbstractDeclarator', [$1])
        | direct_abstract_declarator '[' conditional_expression ']'
          { $$ = new n.ASTNode('DirectAbstractDeclarator', [$1, $3]); }
        | '(' ')' -> new n.ASTNode('DirectAbstractDeclarator', [])
        | '(' parameter_type_list ')' -> new n.ASTNode('DirectAbstractDeclarator', [$2])
        | direct_abstract_declarator '(' ')' -> new n.ASTNode('DirectAbstractDeclarator', [$1])
        | direct_abstract_declarator '(' parameter_type_list ')'
          { $$ = new n.ASTNode('DirectAbstractDeclarator', [$1, $3]); }
        ;

initializer
        : assignment_expression -> new n.ASTNode('Initializer', [$1])
        | '{' initializer_list '}' -> new n.ASTNode('Initializer', [$2])
        | '{' initializer_list ',' '}' -> new n.ASTNode('Initializer', [$2])
        ;

initializer_list
        : initializer -> new n.ASTNode('InitializerList', [$1])
/* TODO: flatten recursive list objects */
        | initializer_list ',' initializer
          { $$ = new n.ASTNode('InitializerList', [$1, $3]); }
        ;

/* this would best be done with straight inheritance, no need for -> at all */
statement
        : labeled_statement -> new n.ASTNode('Statement', [$1])
        | compound_statement -> new n.ASTNode('Statement', [$1])
        | expression_statement -> new n.ASTNode('Statement', [$1])
        | selection_statement -> new n.ASTNode('Statement', [$1])
        | iteration_statement -> new n.ASTNode('Statement', [$1])
        | jump_statement -> new n.ASTNode('Statement', [$1])
        ;

labeled_statement
        : IDENTIFIER ':' statement -> new n.ASTNode('LabeledStatement', [$1, $3])
        | CASE conditional_expression ':' statement
          { $$ = new n.ASTNode('LabeledStatement', [$1, $2, $3]); }
        | DEFAULT ':' statement -> new n.ASTNode('LabeledStatement', [$1, $3])
        ;


compound_statement
/* TODO: create empty statement class to hold just braces */
        : '{' '}' -> new n.ASTNode('CompoundStatement', [])
        | '{' statement_list '}' -> new n.ASTNode('CompoundStatement', [$2])
        | '{' declaration_list '}' -> new n.ASTNode('CompoundStatement', [$2])
        | '{' declaration_list statement_list '}'
          { $$ = new n.ASTNode('CompoundStatement', [$2, $3]); }
        ;

declaration_list
        : declaration -> new n.ASTNode('DeclarationList', [$1])
/* TODO: flatten recursive list objects */
        | declaration_list declaration -> new n.ASTNode('DeclarationList', [$1, $2])
        ;

statement_list
        : statement -> new n.ASTNode('StatementList', [$1]);
/* TODO: flatten recursive list objects */
        | statement_list statement -> new n.ASTNode('StatementList', [$1, $2])
        ;

expression_statement
/* TODO: create empty expression class to hold just semicolon */
        : ';' -> new n.ASTNode('ExpressionStatement', [])
        | expression ';' -> new n.ASTNode('ExpressionStatement', [$1])
        ;

selection_statement
        : IF '(' expression ')' statement %prec THEN
          { $$ = new n.ASTNode('SelectionStatement', [$1, $3, $5]); }
        | IF '(' expression ')' statement ELSE statement
          { $$ = new n.ASTNode('SelectionStatement', [$1, $3, $5, $6, $7]); }
        | SWITCH '(' expression ')' statement
          { $$ = new n.ASTNode('SelectionStatement', [$1, $3, $5]); }
        ;

/* TODO: move expression to child of WHILE node, and make specific subclass for
 * each type of iteration statement. this slightly modifies the AST produced
 * from the parse tree */
iteration_statement
        : WHILE '(' expression ')' statement
          { $$ = new n.ASTNode('IterationStatement', [$1, $3, $5]); }
        | DO statement WHILE '(' expression ')' ';'
          { $$ = new n.ASTNode('IterationStatement', [$1, $2, $3, $5]); }
        | FOR '(' expression_statement expression_statement ')' statement
          { $$ = new n.ASTNode('IterationStatement', [$1, $3, $4, $6]); }
        | FOR '(' expression_statement expression_statement expression ')' statement
          { $$ = new n.ASTNode('IterationStatement', [$1, $3, $4, $5, $7]); }
        ;

jump_statement
        : GOTO IDENTIFIER ';' -> new n.ASTNode('JumpStatement', [$1, $2])
        | CONTINUE ';' -> new n.ASTNode('JumpStatement', [$1])
        | BREAK ';' -> new n.ASTNode('JumpStatement', [$1])
        | RETURN ';' -> new n.ASTNode('JumpStatement', [$1])
        | RETURN expression ';' -> new n.ASTNode('JumpStatement', [$1, $2])
        ;

translation_unit
        : external_declaration { return new n.ASTNode('TranslationUnit', [$1]); }
        | translation_unit external_declaration
          { return new n.ASTNode('TranslationUnit', [$1, $2]); }
        | error { throw new Error('invalid parse: <' + $1 + '>'); }
        ;

external_declaration
        : function_definition -> new n.ASTNode('ExternalDeclaration', [$1])
        | declaration -> new n.ASTNode('ExternalDeclaration', [$1])
        ;

function_definition
        : declaration_specifiers declarator declaration_list compound_statement
          { $$ = new n.ASTNode('FunctionDefinition', [$1, $2, $3, $4]); }
        | declaration_specifiers declarator compound_statement
          { $$ = new n.ASTNode('FunctionDefinition', [$1, $2, $3]); }
        | declarator declaration_list compound_statement
          { $$ = new n.ASTNode('FunctionDefinition', [$1, $2, $3]); }
        | declarator compound_statement
          { $$ = new n.ASTNode('FunctionDefinition', [$1, $2]); }
        ;

%%
