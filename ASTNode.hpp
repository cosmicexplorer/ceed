#ifndef ___CEED_ASTNODE___
#define ___CEED_ASTNODE___

#include <string>
#include <vector>
#include <optional>

namespace ceed
{
struct ASTNode {
  virtual std::string print() = 0;
};

struct Name : public ASTNode {
  std::string name;
  Name(const std::string &);
};

struct Scope;

struct UniqueName : public Name {
  Scope enclosingScope;
  UniqueName(const std::string &, Scope &);
};

struct FunctionDefinition;

struct UniqueLabel : public Name {
  FunctionDefinition enclosingDefinition;
  UniqueLabel(const std::string &, const FunctionDefinition &);
};

struct NameRef : public ASTNode {
  std::string name;
  NameRef(const std::string &);
};

struct ValueRef : public NameRef {
  Scope enclosingScope;
  ValueRef(const std::string &, const Scope &);
};

struct LabelRef : public NameRef {
  FunctionDefinition enclosingDefinition;
  LabelRef(const std::string &, const FunctionDefinition &);
};

struct TypeRef : public ASTNode {
  std::vector<std::string> modifiers;
  TypeRef(const std::vector<std::string> &);
};

struct NamedTypeRef : public TypeRef {
  ValueRef name;
  NamedTypeRef(const ValueRef &, const std::vector<std::string> &);
};

struct TypeDeclaration;

struct AnonymousTypeRef : public TypeRef {
  TypeDeclaration impl;
  AnonymousTypeRef(const TypeDeclaration &, const std::vector<std::string> &);
};

struct Declaration : public ASTNode {
};

struct TypeDeclaration : public Declaration, public Statement {
};

struct Typedef : public TypeDeclaration {
  TypeRef fromType;
  UniqueName toType;
  Typedef(const TypeRef &, const UniqueName &);
};

struct NewTypeDeclaration : public TypeDeclaration {
};

struct NameAndType {
  Name name;
  TypeRef type;
};

struct StructDeclaration : public NewTypeDeclaration {
  std::optional<UniqueName> name;
  std::vector<NameAndType> members;
  StructDeclaration(const std::optional<UniqueName> &,
                    const std::vector<NameAndType> &);
};

struct UniqueNameAndMaybeNum {
  UniqueName name;
  std::optional<int> num;
};

struct EnumDeclaration : public NewTypeDeclaration {
  std::optional<UniqueName> name;
  std::vector<UniqueNameAndMaybeNum> members;
  EnumDeclaration(const std::optional<UniqueName> &,
                  const std::vector<UniqueNameAndMaybeNum> &);
};

struct ValueDeclaration : public Declaration {
  virtual bool isDefinition();
};

struct TopLevelVariable : public ValueDeclaration {
  TypeRef type;
  UniqueName name;
  /* make these enums for safety? makes it less flexible later on though */
  std::vector<std::string> specifiers;
  TopLevelVariable(const TypeRef &,
                   const UniqueName &,
                   const std::vector<std::string> &);

  /* FIXME: use code generation / boost::hana / other metaprogramming to make
     this available to something like selectree without having to do silly
     things!  but make sure whatever is used allows for query generation at
     runtime */
  virtual bool isDefinition();
};

struct Expression;

struct TopLevelVariableDefinition : public TopLevelVariable {
  Expression value;
  TopLevelVariableDefinition(const TypeRef &,
                             const UniqueName &,
                             const std::vector<std::string> &,
                             Expression &);
  virtual bool isDefinition();
};

struct TopLevelFunction : public ValueDeclaration {
  TypeRef returnType;
  std::vector<TypeRef> argTypes;
  std::vector<std::string> specifiers;
  TopLevelFunction(const TypeRef &,
                   const UniqueName &,
                   const std::vector<std::string> &);

  virtual bool isDefinition();
};

struct LocalVariable;
struct OpenScope;

struct FunctionDefinition {
  std::vector<LocalVariable> arguments;
  OpenScope definition;
};

struct TopLevelFunctionDefinition : public TopLevelFunction {
  FunctionDefinition defn;
  TopLevelFunctionDefinition(const TypeRef &,
                             const UniqueName &,
                             const std::vector<std::string> &);

  virtual bool isDefinition();
};

struct GotoDeclaration : public Declaration {
  UniqueLabel label;
  GotoDeclaration(const UniqueLabel &);
};

struct Statement : public ASTNode {
  Scope enclosingScope;
  Statement(const Scope &);
};

struct SimpleStatement : public Statement {
};

struct Expression : public SimpleStatement {
};

struct RealExpression : public Expression {
};

struct FunctionCall : public RealExpression {
  ValueRef functionName;
  std::vector<RealExpression> arguments;
  FunctionCall(const ValueRef &,
               const std::vector<RealExpression> &,
               const Scope &);
};

struct Literal : public RealExpression {
};

struct StringLiteral : public Literal {
  std::string content;
  StringLiteral(const std::string &, const Scope &);
};

/* represents numeric constants of any type */
struct NumericConstant {
};

struct NumericLiteral : public Literal {
  NumericConstant content;
  NumericLiteral(const NumericConstant &, const Scope &);
};

struct ReferenceLiteral : public Literal {
  ValueRef content;
  ReferenceLiteral(const ValueRef &, const Scope &);
};

struct BinaryOperator : public RealExpression {
  RealExpression left;
  RealExpression right;
  BinaryOperator(const RealExpression &, const RealExpression &);
};

struct PlusBinaryOperator : public BinaryOperator {
  PlusBinaryOperator(const RealExpression &, const RealExpression &);
};

struct MinusBinaryOperator : public BinaryOperator {
  MinusBinaryOperator(const RealExpression &, const RealExpression &);
};

struct AsteriskBinaryOperator : public BinaryOperator {
  AsteriskBinaryOperator(const RealExpression &, const RealExpression &);
};

struct SlashOperator : public BinaryOperator {
  SlashOperator(const RealExpression &, const RealExpression &);
};

struct AssignmentOperator : public BinaryOperator {
  AssignmentOperator(const RealExpression &, const RealExpression &);
};

struct IncrementAssignOperator : public BinaryOperator {
  IncrementAssignOperator(const RealExpression &, const RealExpression &);
};

struct DecrementAssignOperator : public BinaryOperator {
  DecrementAssignOperator(const RealExpression &, const RealExpression &);
};

struct CommaOperator : public BinaryOperator {
  CommaOperator(const RealExpression &, const RealExpression &);
};

struct EqualityOperator : public BinaryOperator {
  EqualityOperator(const RealExpression &, const RealExpression &);
};

struct InEqualityOperator : public BinaryOperator {
  InEqualityOperator(const RealExpression &, const RealExpression &);
};

struct DoubleAmpersandOperator : public BinaryOperator {
  DoubleAmpersandOperator(const RealExpression &, const RealExpression &);
};

struct DoublePipeOperator : public BinaryOperator {
  DoublePipeOperator(const RealExpression &, const RealExpression &);
};

struct BitwiseAndOperator : public BinaryOperator {
  BitwiseAndOperator(const RealExpression &, const RealExpression &);
};

struct BitwiseXorOperator : public BinaryOperator {
  BitwiseXorOperator(const RealExpression &, const RealExpression &);
};

struct BitwiseOrOperator : public BinaryOperator {
  BitwiseOrOperator(const RealExpression &, const RealExpression &);
};

struct UnaryOperator : public RealExpression {
  RealExpression expr;
  UnaryOperator(const RealExpression &);
};

struct AsteriskUnaryOperator : public UnaryOperator {
  AsteriskUnaryOperator(const RealExpression &);
};

struct AmpersandUnaryOperator : public UnaryOperator {
  AmpersandUnaryOperator(const RealExpression &);
};

struct PreincrementOperator : public UnaryOperator {
  PreincrementOperator(const RealExpression &);
};

struct PostincrementOperator : public UnaryOperator {
  PostincrementOperator(const RealExpression &);
};

struct PredecrementOperator : public UnaryOperator {
  PredecrementOperator(const RealExpression &);
};

struct PostdecrementOperator : public UnaryOperator {
  PostdecrementOperator(const RealExpression &);
};

struct PlusUnaryOperator : public UnaryOperator {
  PlusUnaryOperator(const RealExpression &);
};

struct MinusUnaryOperator : public UnaryOperator {
  MinusUnaryOperator(const RealExpression &);
};

struct NegationOperator : public UnaryOperator {
  NegationOperator(const RealExpression &);
};

struct TildeOperator : public UnaryOperator {
  TildeOperator(const RealExpression &);
};

struct TernaryOperator : public RealExpression {
  RealExpression test;
  RealExpression ifTrue;
  RealExpression ifFalse;
  TernaryOperator(const RealExpression &,
                  const RealExpression &,
                  const RealExpression &);
};

struct ParenthesesOperator : public RealExpression {
  RealExpression expr;
  ParenthesesOperator(const RealExpression &);
};

struct ExplicitCast : public RealExpression {
  TypeRef castingType;
  RealExpression expr;
  ExplicitCast(const TypeRef &, const RealExpression &);
};

struct SometimesExpression : public Expression {
};

struct LocalVariable : public SometimesExpression {
  TypeRef type;
  UniqueName name;
  std::optional<RealExpression> value;
  std::vector<std::string> specifiers;
  LocalVariable(const TypeRef &,
                const UniqueName &,
                const std::optional<RealExpression> &,
                const std::vector<std::string> &);
};

struct ControlStatement : public Statement {
};

struct ReturnStatement : public ControlStatement {
  std::optional<RealExpression> expr;
  ReturnStatement(const std::optional<RealExpression> &);
};

struct BreakStatement : public ControlStatement {
};

struct ContinueStatement : public ControlStatement {
};

struct GotoStatement : public ControlStatement {
  LabelRef label;
  GotoStatement(const LabelRef &);
};

struct EmptyStatement : public ControlStatement {
};

struct Scope : public Statement {
  std::vector<Statement> body;
  Scope(const std::vector<Statement> &);
};

struct ForLoop : public Scope {
  Expression setupClause;
  Expression conditionClause;
  RealExpression advanceClause;
  ForLoop(const Expression &,
          const Expression &,
          const RealExpression &,
          const std::vector<Statement> &);
};

struct WhileLoop : public Scope {
  Expression conditionClause;
  WhileLoop(const Expression &, const std::vector<Statement> &);
};

struct DoWhileLoop : public Scope {
  Expression conditionClause;
  DoWhileLoop(const Expression &, const std::vector<Statement> &);
};

struct IfBlock : public Scope {
  Expression conditionClause;
  IfBlock(const Expression &, const std::vector<Statement> &);
};

struct ElseBlock : public Scope {
  ElseBlock(const std::vector<Statement> &);
};

struct OpenScope : public Scope {
  OpenScope(const std::vector<Statement> &);
};
}

#endif /* ___CEED_ASTNODE___ */
