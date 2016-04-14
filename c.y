/* adapted from https://www.lysator.liu.se/c/ANSI-C-grammar-y.html */

%nonassoc THEN
%nonassoc ELSE

%start translation_unit

/* https://github.com/zaach/jison/issues/313 */
%{
var Jison = require('jison');
var ASTNode = require('./ASTNode').ASTNode;
%}

%%

/* in general, don't have tokens as "children"; instead, make them attributes,
 * or make them a new type of subclass of the parse tree node */
primary_expression
        : IDENTIFIER -> new ASTNode('PrimaryExpression', [$1])
        | CONSTANT -> new ASTNode('PrimaryExpression', [$1])
        | STRING_LITERAL -> new ASTNode('PrimaryExpression', [$1])
        | '(' expression ')' -> new ASTNode('PrimaryExpression', [$2])
        ;

postfix_expression
        : primary_expression -> new ASTNode('PostfixExpression', [$1])
        | postfix_expression '[' expression ']'
          { $$ = new ASTNode('PostfixExpression', [$1, $3]); }
        | postfix_expression '(' ')'
          { $$ = new ASTNode('PostfixExpression', [$1]); }
        | postfix_expression '(' argument_expression_list ')'
          { $$ = new ASTNode('PostfixExpression', [$1, $3]); }
        | postfix_expression '.' IDENTIFIER
          { $$ = new ASTNode('PostfixExpression', [$1, $3]); }
        | postfix_expression PTR_OP IDENTIFIER
          { $$ = new ASTNode('PostfixExpression', [$1, $2, $3]); }
        | postfix_expression INC_OP
          { $$ = new ASTNode('PostfixExpression', [$1, $2]); }
        | postfix_expression DEC_OP
          { $$ = new ASTNode('PostfixExpression', [$1, $2]); }
        ;

argument_expression_list
        : assignment_expression -> new ASTNode('ArgumentExpressionList', [$1])
        | argument_expression_list ',' assignment_expression
          { $$ = new ASTNode('ArgumentExpressionList', [$1, $3]); }
        ;

unary_expression
        : postfix_expression -> new ASTNode('UnaryExpression', [$1])
        | INC_OP unary_expression -> new ASTNode('UnaryExpression', [$1, $2])
        | DEC_OP unary_expression -> new ASTNode('UnaryExpression', [$1, $2])
        | unary_operator cast_expression -> new ASTNode('UnaryExpression', [$1, $2])
        | SIZEOF unary_expression -> new ASTNode('UnaryExpression', [$1, $2])
        | SIZEOF '(' type_name ')' -> new ASTNode('UnaryExpression', [$1, $3])
        ;

unary_operator
        : '&' -> new ASTNode('UnaryOperator', [$1])
        | '*' -> new ASTNode('UnaryOperator', [$1])
        | '+' -> new ASTNode('UnaryOperator', [$1])
        | '-' -> new ASTNode('UnaryOperator', [$1])
        | '~' -> new ASTNode('UnaryOperator', [$1])
        | '!' -> new ASTNode('UnaryOperator', [$1])
        ;

cast_expression
        : unary_expression -> new ASTNode('CastExpression', [$1])
        | '(' type_name ')' cast_expression -> new ASTNode('UnaryOperator', [$2, $4])
        ;

multiplicative_expression
        : cast_expression -> new ASTNode('MultiplicativeExpression', [$1])
        | multiplicative_expression '*' cast_expression
          { $$ = new ASTNode('MultiplicativeExpression', [$1, $3]); }
        | multiplicative_expression '/' cast_expression
          { $$ = new ASTNode('MultiplicativeExpression', [$1, $3]); }
        | multiplicative_expression '%' cast_expression
          { $$ = new ASTNode('MultiplicativeExpression', [$1, $3]); }
        ;

additive_expression
        : multiplicative_expression
          { $$ = new ASTNode('AdditiveExpression', [$1]); }
        | additive_expression '+' multiplicative_expression
          { $$ = new ASTNode('AdditiveExpression', [$1, $3]); }
        | additive_expression '-' multiplicative_expression
          { $$ = new ASTNode('AdditiveExpression', [$1, $3]); }
        ;

shift_expression
        : additive_expression -> new ASTNode('ShiftExpression', [$1])
        | shift_expression LEFT_OP additive_expression
          { $$ = new ASTNode('ShiftExpression', [$1, $2, $3]); }
        | shift_expression RIGHT_OP additive_expression
          { $$ = new ASTNode('ShiftExpression', [$1, $2, $3]); }
        ;

relational_expression
        : shift_expression -> new ASTNode('RelationalExpression', [$1])
        | relational_expression '<' shift_expression
          { $$ = new ASTNode('RelationalExpression', [$1, $3]); }
        | relational_expression '>' shift_expression
          { $$ = new ASTNode('RelationalExpression', [$1, $3]); }
        | relational_expression LE_OP shift_expression
          { $$ = new ASTNode('RelationalExpression', [$1, $2, $3]); }
        | relational_expression GE_OP shift_expression
          { $$ = new ASTNode('RelationalExpression', [$1, $2, $3]); }
        ;

equality_expression
        : relational_expression -> new ASTNode('EqualityExpression', [$1])
        | equality_expression EQ_OP relational_expression
          { $$ = new ASTNode('EqualityExpression', [$1, $2, $3]); }
        | equality_expression NE_OP relational_expression
          { $$ = new ASTNode('EqualityExpression', [$1, $2, $3]); }
        ;

and_expression
        : equality_expression -> new ASTNode('AndExpression', [$1])
        | and_expression '&' equality_expression
          { $$ = new ASTNode('AndExpression', [$1, $3]); }
        ;

exclusive_or_expression
        : and_expression -> new ASTNode('ExclusiveOrExpression', [$1])
        | exclusive_or_expression '^' and_expression
          { $$ = new ASTNode('ExclusiveOrExpression', [$1, $3]); }
        ;

inclusive_or_expression
        : exclusive_or_expression -> new ASTNode('InclusiveOrExpression', [$1])
        | inclusive_or_expression '|' exclusive_or_expression
          { $$ = new ASTNode('InclusiveOrExpression', [$1, $3]); }
        ;

logical_and_expression
        : inclusive_or_expression -> new ASTNode('LogicalAndExpression', [$1])
        | logical_and_expression AND_OP inclusive_or_expression
          { $$ = new ASTNode('LogicalAndExpression', [$1, $2, $3]); }
        ;

logical_or_expression
        : logical_and_expression -> new ASTNode('LogicalOrExpression', [$1])
        | logical_or_expression OR_OP logical_and_expression
          { $$ = new ASTNode('LogicalOrExpression', [$1, $2, $3]); }
        ;

conditional_expression
        : logical_or_expression -> new ASTNode('ConditionalExpression', [$1])
        | logical_or_expression '?' expression ':' conditional_expression
          { $$ = new ASTNode('ConditionalExpression', [$1, $3, $5]); }
        ;

assignment_expression
        : conditional_expression -> new ASTNode('AssignmentExpression', [$1])
        | unary_expression assignment_operator assignment_expression
          { $$ = new ASTNode('AssignmentExpression', [$1, $2, $3]); }
        ;

assignment_operator
        : '=' -> new ASTNode('AssignmentOperator', [$1])
        | MUL_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | DIV_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | MOD_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | ADD_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | SUB_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | LEFT_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | RIGHT_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | AND_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | XOR_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        | OR_ASSIGN -> new ASTNode('AssignmentOperator', [$1])
        ;

expression
        : assignment_expression -> new ASTNode('Expression', [$1])
        | expression ',' assignment_expression -> new ASTNode('Expression', [$1, $3])
        ;

constant_expression
        : conditional_expression -> new ASTNode('ConstantExpression', [$1])
        ;

declaration
        : declaration_specifiers ';' -> new ASTNode('Declaration', [$1])
        | declaration_specifiers init_declarator_list ';'
          { $$ = new ASTNode('Declaration', [$1, $2]); }
        ;

declaration_specifiers
        : storage_class_specifier
          { $$ = new ASTNode('DeclarationSpecifiers', [$1]); }
        | storage_class_specifier declaration_specifiers
          { $$ = new ASTNode('DeclarationSpecifiers', [$1, $2]); }
        | type_specifier
          { $$ = new ASTNode('DeclarationSpecifiers', [$1]); }
        | type_specifier declaration_specifiers
          { $$ = new ASTNode('DeclarationSpecifiers', [$1, $2]); }
        | type_qualifier
          { $$ = new ASTNode('DeclarationSpecifiers', [$1]); }
        | type_qualifier declaration_specifiers
          { $$ = new ASTNode('DeclarationSpecifiers', [$1, $2]); }
        ;

init_declarator_list
        : init_declarator -> new ASTNode('InitDeclaratorList', [$1])
        | init_declarator_list ',' init_declarator -> new ASTNode('InitDeclaratorList', [$1, $3])
        ;

init_declarator
        : declarator -> new ASTNode('InitDeclarator', [$1])
        | declarator '=' initializer -> new ASTNode('InitDeclarator', [$1, $3])
        ;

storage_class_specifier
        : TYPEDEF -> new ASTNode('StorageClassSpecifier', [$1])
        | EXTERN -> new ASTNode('StorageClassSpecifier', [$1])
        | STATIC -> new ASTNode('StorageClassSpecifier', [$1])
        | AUTO -> new ASTNode('StorageClassSpecifier', [$1])
        | REGISTER -> new ASTNode('StorageClassSpecifier', [$1])
        ;

/* TODO: allow for complex things like long/short/signed/unsigned primitives */
type_specifier
        : VOID -> new ASTNode('TypeSpecifier', [$1])
        | CHAR -> new ASTNode('TypeSpecifier', [$1])
        | SHORT -> new ASTNode('TypeSpecifier', [$1])
        | INT -> new ASTNode('TypeSpecifier', [$1])
        | LONG -> new ASTNode('TypeSpecifier', [$1])
        | FLOAT -> new ASTNode('TypeSpecifier', [$1])
        | DOUBLE -> new ASTNode('TypeSpecifier', [$1])
        | SIGNED -> new ASTNode('TypeSpecifier', [$1])
        | UNSIGNED -> new ASTNode('TypeSpecifier', [$1])
        | struct_or_union_specifier -> new ASTNode('TypeSpecifier', [$1])
        | enum_specifier -> new ASTNode('TypeSpecifier', [$1])
        | TYPE_NAME -> new ASTNode('TypeSpecifier', [$1])
        ;

struct_or_union_specifier
        : struct_or_union IDENTIFIER '{' struct_declaration_list '}'
          { $$ = new ASTNode('StructOrUnionSpecifier', [$1, $2, $4]); }
        | struct_or_union '{' struct_declaration_list '}'
          { $$ = new ASTNode('StructOrUnionSpecifier', [$1, $3]); }
        | struct_or_union IDENTIFIER
          { $$ = new ASTNode('StructOrUnionSpecifier', [$1, $2]); }
        ;

struct_or_union
        : STRUCT -> new ASTNode('StructOrUnion', [$1])
        | UNION -> new ASTNode('StructOrUnion', [$1])
        ;

struct_declaration_list
        : struct_declaration -> new ASTNode('StructDeclarationList', [$1])
        | struct_declaration_list struct_declaration
          { $$ = new ASTNode('StructDeclarationList', [$1, $2]); }
        ;

struct_declaration
        : specifier_qualifier_list struct_declarator_list ';'
          { $$ = new ASTNode('StructDeclaration', [$1, $2]); }
        ;

specifier_qualifier_list
        : type_specifier specifier_qualifier_list -> new ASTNode('SpecifierQualifierList', [$1, $2])
        | type_specifier -> new ASTNode('SpecifierQualifierList', [$1])
        | type_qualifier specifier_qualifier_list -> new ASTNode('SpecifierQualifierList', [$1, $2])
        | type_qualifier -> new ASTNode('SpecifierQualifierList', [$1])
        ;

struct_declarator_list
        : struct_declarator -> new ASTNode('StructDeclaratorList', [$1])
        | struct_declarator_list ',' struct_declarator
          { $$ = new ASTNode('StructDeclaratorList', [$1, $3]); }
        ;

struct_declarator
        : declarator -> new ASTNode('StructDeclarator', [$1])
        | ':' constant_expression -> new ASTNode('StructDeclarator', [$2])
        | declarator ':' constant_expression -> new ASTNode('StructDeclarator', [$1, $3])
        ;

enum_specifier
        : ENUM '{' enumerator_list '}' -> new ASTNode('EnumSpecifier', [$1, $3])
        | ENUM IDENTIFIER '{' enumerator_list '}' -> new ASTNode('EnumSpecifier', [$1, $3])
        | ENUM IDENTIFIER -> new ASTNode('EnumSpecifier', [$1])
        ;

enumerator_list
        : enumerator -> new ASTNode('EnumeratorList', [$1])
        | enumerator_list ',' enumerator -> new ASTNode('EnumeratorList', [$1, $3])
        ;

enumerator
        : IDENTIFIER -> new ASTNode('Enumerator', [$1])
        | IDENTIFIER '=' constant_expression -> new ASTNode('Enumerator', [$1, $3])
        ;

type_qualifier
        : CONST -> new ASTNode('TypeQualifier', [$1])
        | VOLATILE -> new ASTNode('TypeQualifier', [$1])
        ;

declarator
        : pointer direct_declarator -> new ASTNode('Declarator', [$1, $2])
        | direct_declarator -> new ASTNode('Declarator', [$1])
        ;

direct_declarator
        : IDENTIFIER -> new ASTNode('DirectDeclarator', [$1])
        | '(' declarator ')' -> new ASTNode('DirectDeclarator', [$2])
        | direct_declarator '[' constant_expression ']' -> new ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '[' ']' -> new ASTNode('DirectDeclarator', [$1])
        | direct_declarator '(' parameter_type_list ')' -> new ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '(' identifier_list ')' -> new ASTNode('DirectDeclarator', [$1, $3])
        | direct_declarator '(' ')' -> new ASTNode('DirectDeclarator', [$1])
        ;

pointer
        : '*' -> new ASTNode('Pointer', [$1])
        | '*' type_qualifier_list -> new ASTNode('Pointer', [$1, $2])
        | '*' pointer -> new ASTNode('Pointer', [$1, $2])
        | '*' type_qualifier_list pointer -> new ASTNode('Pointer', [$1, $2])
        ;

type_qualifier_list
        : type_qualifier -> new ASTNode('TypeQualifierList', [$1])
        | type_qualifier_list type_qualifier -> new ASTNode('TypeQualifierList', [$1, $2])
        ;


parameter_type_list
        : parameter_list -> new ASTNode('ParameterTypeList', [$1])
        | parameter_list ',' ELLIPSIS -> new ASTNode('ParameterTypeList', [$1, $3])
        ;

parameter_list
        : parameter_declaration -> new ASTNode('ParameterList', [$1])
        | parameter_list ',' parameter_declaration -> new ASTNode('ParameterList', [$1, $3])
        ;

parameter_declaration
        : declaration_specifiers declarator -> new ASTNode('ParameterDeclaration', [$1, $2])
        | declaration_specifiers abstract_declarator -> new ASTNode('ParameterDeclaration', [$1, $2])
        | declaration_specifiers -> new ASTNode('ParameterDeclaration', [$1])
        ;

identifier_list
        : IDENTIFIER -> new ASTNode('IdentifierList', [$1])
        | identifier_list ',' IDENTIFIER -> new ASTNode('IdentifierList', [$1, $3])
        ;

type_name
        : specifier_qualifier_list -> new ASTNode('TypeName', [$1])
        | specifier_qualifier_list abstract_declarator -> new ASTNode('TypeName', [$1, $2])
        ;

abstract_declarator
        : pointer -> new ASTNode('AbstractDeclarator', [$1])
        | direct_abstract_declarator -> new ASTNode('AbstractDeclarator', [$1])
        | pointer direct_abstract_declarator -> new ASTNode('AbstractDeclarator', [$1])
        ;

direct_abstract_declarator
        : '(' abstract_declarator ')' -> new ASTNode('DirectAbstractDeclarator', [$2])
        | '[' ']' -> new ASTNode('DirectAbstractDeclarator', [])
        | '[' constant_expression ']' -> new ASTNode('DirectAbstractDeclarator', [$2])
        | direct_abstract_declarator '[' ']' -> new ASTNode('DirectAbstractDeclarator', [$1])
        | direct_abstract_declarator '[' constant_expression ']'
          { $$ = new ASTNode('DirectAbstractDeclarator', [$1, $3]); }
        | '(' ')' -> new ASTNode('DirectAbstractDeclarator', [])
        | '(' parameter_type_list ')' -> new ASTNode('DirectAbstractDeclarator', [$2])
        | direct_abstract_declarator '(' ')' -> new ASTNode('DirectAbstractDeclarator', [$1])
        | direct_abstract_declarator '(' parameter_type_list ')'
          { $$ = new ASTNode('DirectAbstractDeclarator', [$1, $3]); }
        ;

initializer
        : assignment_expression -> new ASTNode('Initializer', [$1])
        | '{' initializer_list '}' -> new ASTNode('Initializer', [$2])
        | '{' initializer_list ',' '}' -> new ASTNode('Initializer', [$2])
        ;

initializer_list
        : initializer -> new ASTNode('InitializerList', [$1])
/* TODO: flatten recursive list objects */
        | initializer_list ',' initializer
          { $$ = new ASTNode('InitializerList', [$1, $3]); }
        ;

/* this would best be done with straight inheritance, no need for -> at all */
statement
        : labeled_statement -> new ASTNode('Statement', [$1])
        | compound_statement -> new ASTNode('Statement', [$1])
        | expression_statement -> new ASTNode('Statement', [$1])
        | selection_statement -> new ASTNode('Statement', [$1])
        | iteration_statement -> new ASTNode('Statement', [$1])
        | jump_statement -> new ASTNode('Statement', [$1])
        ;

labeled_statement
        : IDENTIFIER ':' statement -> new ASTNode('LabeledStatement', [$1, $3])
        | CASE constant_expression ':' statement
          { $$ = new ASTNode('LabeledStatement', [$1, $2, $3]); }
        | DEFAULT ':' statement -> new ASTNode('LabeledStatement', [$1, $3])
        ;


compound_statement
/* TODO: create empty statement class to hold just braces */
        : '{' '}' -> new ASTNode('CompoundStatement', [])
        | '{' statement_list '}' -> new ASTNode('CompoundStatement', [$2])
        | '{' declaration_list '}' -> new ASTNode('CompoundStatement', [$2])
        | '{' declaration_list statement_list '}'
          { $$ = new ASTNode('CompoundStatement', [$2, $3]); }
        ;

declaration_list
        : declaration -> new ASTNode('DeclarationList', [$1])
/* TODO: flatten recursive list objects */
        | declaration_list declaration -> new ASTNode('DeclarationList', [$1, $2])
        ;

statement_list
        : statement -> new ASTNode('StatementList', [$1]);
/* TODO: flatten recursive list objects */
        | statement_list statement -> new ASTNode('StatementList', [$1, $2])
        ;

expression_statement
/* TODO: create empty expression class to hold just semicolon */
        : ';' -> new ASTNode('ExpressionStatement', [])
        | expression ';' -> new ASTNode('ExpressionStatement', [$1])
        ;

selection_statement
        : IF '(' expression ')' statement %prec THEN
          { $$ = new ASTNode('SelectionStatement', [$1, $3, $5]); }
        | IF '(' expression ')' statement ELSE statement
          { $$ = new ASTNode('SelectionStatement', [$1, $3, $5, $6, $7]); }
        | SWITCH '(' expression ')' statement
          { $$ = new ASTNode('SelectionStatement', [$1, $3, $5]); }
        ;

/* TODO: move expression to child of WHILE node, and make specific subclass for
 * each type of iteration statement. this slightly modifies the AST produced
 * from the parse tree */
iteration_statement
        : WHILE '(' expression ')' statement
          { $$ = new ASTNode('IterationStatement', [$1, $3, $5]); }
        | DO statement WHILE '(' expression ')' ';'
          { $$ = new ASTNode('IterationStatement', [$1, $2, $3, $5]); }
        | FOR '(' expression_statement expression_statement ')' statement
          { $$ = new ASTNode('IterationStatement', [$1, $3, $4, $6]); }
        | FOR '(' expression_statement expression_statement expression ')' statement
          { $$ = new ASTNode('IterationStatement', [$1, $3, $4, $5, $7]); }
        ;

jump_statement
        : GOTO IDENTIFIER ';' -> new ASTNode('JumpStatement', [$1, $2])
        | CONTINUE ';' -> new ASTNode('JumpStatement', [$1])
        | BREAK ';' -> new ASTNode('JumpStatement', [$1])
        | RETURN ';' -> new ASTNode('JumpStatement', [$1])
        | RETURN expression ';' -> new ASTNode('JumpStatement', [$1, $2])
        ;

translation_unit
        : external_declaration { return new ASTNode('TranslationUnit', [$1]); }
        | translation_unit external_declaration
          { return new ASTNode('TranslationUnit', [$1, $2]); }
        ;

external_declaration
        : function_definition -> new ASTNode('ExternalDeclaration', [$1])
        | declaration -> new ASTNode('ExternalDeclaration', [$1])
        ;

function_definition
        : declaration_specifiers declarator declaration_list compound_statement
          { $$ = new ASTNode('FunctionDefinition', [$1, $2, $3, $4]); }
        | declaration_specifiers declarator compound_statement
          { $$ = new ASTNode('FunctionDefinition', [$1, $2, $3]); }
        | declarator declaration_list compound_statement
          { $$ = new ASTNode('FunctionDefinition', [$1, $2, $3]); }
        | declarator compound_statement
          { $$ = new ASTNode('FunctionDefinition', [$1, $2]); }
        ;

%%
