import typing
from dataclasses import dataclass
from enum import IntEnum

class Token_Kind(IntEnum):
	END_OF_INPUT = 128
	IDENTIFIER = 129
	NUMBER = 130
	STRING = 131

	KEYWORD_IF = 148
	KEYWORD_ELSE = 149

	DOUBLE_EQUALS = 192
	NOT_EQUALS = 193

def token_kind_as_str(kind: int) -> str: return Token_Kind(kind).name if kind in Token_Kind else f"'{chr(kind)}'"

@dataclass
class Token:
	offset: int
	length: int
	kind: int

	def next(self) -> int: return self.offset + self.length
	def text(self, s: str) -> str: return s[self.offset:self.offset + self.length]

class Token_Error(Exception):
	def __init__(self, message: str, location: int) -> None:
		super().__init__(message)
		self.location = location

def token_at(s: str, p: int) -> Token:
	while p < len(s) and s[p].isspace(): p += 1
	if p >= len(s): return Token(p, 0, Token_Kind.END_OF_INPUT)
	start = p
	if p + 1 < len(s):
		if s[p:p + 2] == "==": return Token(start, 2, Token_Kind.DOUBLE_EQUALS)
		elif s[p:p + 2] == "!=": return Token(start, 2, Token_Kind.NOT_EQUALS)
	if s[p] in "+-*/%!:=.,;#(){}[]": return Token(p, 1, ord(s[p]))
	if s[p] == "\"":
		p += 1
		while p < len(s) and (s[p - 1] == "\\" or s[p] == "\""): p += 1
		if p >= len(s) or s[p] != "\"": raise Token_Error("You have an unterminated string literal.", start)
		p += 1
		return Token(start, p - start, Token_Kind.STRING)
	if s[p].isdigit():
		while p < len(s) and s[p].isdigit(): p += 1
		return Token(start, p - start, Token_Kind.NUMBER)
	if s[p].isalpha() or s[p] == "_":
		while p < len(s) and (s[p].isalnum() or s[p] == "_"): p += 1
		token = Token(start, p - start, Token_Kind.IDENTIFIER)
		if token.text(s) == "if": token.kind = Token_Kind.KEYWORD_IF
		elif token.text(s) == "else": token.kind = Token_Kind.KEYWORD_ELSE
		return token
	raise NotImplementedError(s[p])

@dataclass
class ZNode: pass
@dataclass
class ZIdentifier(ZNode):
	token: Token
@dataclass
class ZLiteral(ZNode):
	data: int | str
@dataclass
class ZDeclaration(ZNode):
	identifier: ZIdentifier
	constant: bool
	type_expr: ZNode | None
	value_expr: ZNode | None
@dataclass
class ZUnaryOp(ZNode):
	op: Token
	rhs: ZNode
@dataclass
class ZBinaryOp(ZNode):
	lhs: ZNode
	op: Token
	rhs: ZNode
@dataclass
class ZAssign(ZNode):
	lhs: ZNode
	rhs: ZNode
@dataclass
class ZCall(ZNode):
	expr: ZNode
	args: list[ZNode]
@dataclass
class ZAccessor(ZNode):
	expr: ZNode
	identifier: ZIdentifier

class Parse_Error(Exception):
	def __init__(self, message: str, token: Token) -> None:
		super().__init__(message)
		self.token = token

class Parser:
	def __init__(self, s: str) -> None: self.s = s; self.p = 0; self.previous_token: Token | None = None

	def peek(self, n: int = 1) -> Token:
		token: Token | None = None
		p = self.p
		for _ in range(n):
			token = token_at(self.s, p)
			p = token.next()
		assert token is not None
		return token

	def eat(self, expect: int) -> Token:
		token = token_at(self.s, self.p)
		if expect != token.kind: raise Parse_Error(f"Expected {token_kind_as_str(expect)}, got {token_kind_as_str(token.kind)}.", token)
		self.previous_token = token
		self.p = token.next()
		return token

	def parse_factor(self) -> ZNode:
		node: ZNode | None = None
		if self.peek().kind == ord("("):
			self.eat(ord("("))
			node = self.parse_expression()
			self.eat(ord(")"))
		elif self.peek().kind in (ord("!"), ord("+"), ord("-")):
			op = self.eat(self.peek().kind)
			rhs = self.parse_expression()
			node = ZUnaryOp(op, rhs)
		elif self.peek().kind == Token_Kind.IDENTIFIER:
			node = ZIdentifier(self.eat(Token_Kind.IDENTIFIER))
		elif self.peek().kind == Token_Kind.NUMBER:
			node = ZLiteral(int(self.eat(Token_Kind.NUMBER).text(self.s), base=0))
		assert node is not None
		while True:
			if self.peek().kind == ord("("):
				self.eat(ord("("))
				args: list[ZNode] = []
				while self.peek().kind != ord(")"):
					args.append(self.parse_expression())
					if self.peek().kind == ord(","): self.eat(ord(","))
					else: break
				self.eat(ord(")"))
				node = ZCall(node, args)
				continue
			if self.peek().kind == ord("."):
				self.eat(ord("."))
				identifier = ZIdentifier(self.eat(Token_Kind.IDENTIFIER))
				node = ZAccessor(node, identifier)
				continue
			break
		return node

	def parse_term(self) -> ZNode:
		node = self.parse_factor()
		while self.peek().kind in (ord("*"), ord("/"), ord("%")):
			op = self.eat(self.peek().kind)
			rhs = self.parse_factor()
			node = ZBinaryOp(node, op, rhs)
		return node

	def parse_conjugate(self) -> ZNode:
		node = self.parse_term()
		while self.peek().kind in (ord("+"), ord("-")):
			op = self.eat(self.peek().kind)
			rhs = self.parse_term()
			node = ZBinaryOp(node, op, rhs)
		return node

	def parse_expression(self) -> ZNode:
		node = self.parse_conjugate()
		while self.peek().kind in (Token_Kind.DOUBLE_EQUALS, Token_Kind.NOT_EQUALS):
			op = self.eat(self.peek().kind)
			rhs = self.parse_conjugate()
			node = ZBinaryOp(node, op, rhs)
		return node

	def parse_assignment(self) -> ZAssign:
		lhs = self.parse_expression()
		self.eat(ord("="))
		rhs = self.parse_expression()
		return ZAssign(lhs, rhs)

	def parse_declaration(self) -> ZDeclaration:
		identifier = ZIdentifier(self.eat(Token_Kind.IDENTIFIER))
		self.eat(ord(":"))
		type_expr: ZNode | None = None
		if self.peek().kind not in (ord(":"), ord("=")):
			type_expr = self.parse_expression()
		constant = False
		value_expr: ZNode | None = None
		if self.peek().kind in (ord(":"), ord("=")):
			constant = self.eat(self.peek().kind).kind == ord(":")
			value_expr = self.parse_expression()
		assert type_expr is not None or value_expr is not None
		return ZDeclaration(identifier, constant, type_expr, value_expr)

	def parse_top_level(self) -> ZNode:
		node: ZNode | None = None
		if self.peek().kind == Token_Kind.IDENTIFIER:
			if self.peek(2).kind == ord(":"):
				node = self.parse_declaration()
			else:
				node = self.parse_assignment()
		if node is None: node = self.parse_expression()
		if self.previous_token is None or self.previous_token.kind != ord("}"): self.eat(ord(";"))
		return node

class Visitor:
	def __init__(self, s: str) -> None: self.s = s
	def visit(self, node: ZNode) -> typing.Any: return getattr(self, f"visit_{node.__class__.__name__}")(node)

class SourceToSource(Visitor):
	def visit_ZIdentifier(self, node: ZIdentifier) -> str: return node.token.text(self.s)
	def visit_ZLiteral(self, node: ZLiteral) -> str: return str(node.data)
	def visit_ZUnaryOp(self, node: ZUnaryOp) -> str: return f"{node.op.text(self.s)}{self.visit(node.rhs)}"
	def visit_ZBinaryOp(self, node: ZBinaryOp) -> str: return f"({self.visit(node.lhs)} {node.op.text(self.s)} {self.visit(node.rhs)})"
	def visit_ZCall(self, node: ZCall) -> str: return f"{self.visit(node.expr)}({", ".join(map(self.visit, node.args))})"
	def visit_ZAccessor(self, node: ZAccessor) -> str: return f"{self.visit(node.expr)}.{self.visit(node.identifier)}"
	def visit_ZAssign(self, node: ZAssign) -> str: return f"{self.visit(node.lhs)} = {self.visit(node.rhs)};"
	def visit_ZDeclaration(self, node: ZDeclaration) -> str: return f"{self.visit(node.identifier)} :{" " + self.visit(node.type_expr) + (" " if node.value_expr is not None else "") if node.type_expr is not None else ""}{(": " if node.constant else "= ") + self.visit(node.value_expr) if node.value_expr is not None else ""};"

if __name__ == "__main__":
	import sys
	file = sys.argv[1]
	with open(file) as f: src = f.read()
	parser = Parser(src)
	s2s = SourceToSource(src)
	while parser.peek().kind != Token_Kind.END_OF_INPUT:
		try: node = parser.parse_top_level()
		except Token_Error as e: print(f"{file}[{e.location}] token error: {e}"); break
		except Parse_Error as e: print(f"{file}[{e.token.offset}] parse error: {e}"); break
		print(s2s.visit(node))
