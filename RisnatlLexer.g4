/*
 [The "BSD licence"]
 Copyright (c) 2014 Vlad Shlosberg
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

lexer grammar RisnatlLexer;

// Default Mode

// Whitespace -- ignored
WS: (' '|'\t'|'\n'|'\r'|'\r\n')+ -> skip;

// Single-line comments
SL_COMMENT: '//' (~('\n'|'\r'))* ('\n'|'\r'('\n')?) -> skip;

// multiple-line comments
ML_COMMENT: '/*' .*? '*/' -> skip;

LPAREN          : '(';
RPAREN          : ')';
LBRACE          : '{';
RBRACE          : '}';
LBRACK          : '[';
RBRACK          : ']';
GT              : '>';
TILDE           : '~';
COLON           : ':';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';
HASH            : '#';
COLONCOLON      : '::';
PLUS            : '+';
STAR            : '*';

EQUALS                 : '=';
STARTS_WTIH_WORD       : '|=';
CONTAINS_WORD          : '~=';
STARTS_WITH_STRING     : '^=';
ENDS_WITH_STRING       : '$=';
CONTAINS_SUBSTRING     : '*=';

NULL_LITERAL: 'null';

STRING_LITERAL
    : '"' (~('"'|'\n'|'\r'))* '"'
    | '\'' (~('\''|'\n'|'\r'))* '\''
    ;

NUMBER_LITERAL
    : '-' (('0'..'9')* '.')? ('0'..'9')+
    | (('0'..'9')* '.')? ('0'..'9')+
    ;

ARRAY_LITERAL
    : LBRACK STRING_LITERAL+ RBRACK
    | LBRACE NUMBER_LITERAL+ RBRACK
    ;   

fragment LEADING_CHARS: [_a-zA-Z\u0100-\ufffe];
fragment LEADING_CHARS_AND_DIGITS: [_a-zA-Z0-9\u0100-\ufffe];
fragment ATTR_NAME_VALID: ~[\u0000-\u0020\u007f-\u009f\u0022\u0027\u002f\u0034\u003d];

MAPPING: 'mapping' -> pushMode(MAPPING_MODE);

ATTR: 'attr' -> pushMode(ATTR_MODE);

QUERY: 'query' -> pushMode(QUERY_MODE);

TEXT: 'text' -> pushMode(CONTENT_MODE);
HTML: 'html' -> pushMode(CONTENT_MODE);
REPLACE: 'replace' -> pushMode(REPLACE_MODE);

// Lexing mode for mapping definitions
mode MAPPING_MODE;
MAPPING_RPAREN: ')' -> mode(QUERY_MODE), type(RPAREN);
MAPPING_LPAREN: '(' -> type(LPAREN);
MAPPING_ID : LEADING_CHARS LEADING_CHARS_AND_DIGITS*;    


// Lexing mode for attr bindings
mode ATTR_MODE;

ATTR_SEMI: SEMI -> popMode, type(SEMI);
ATTR_NAME
    // Attribute named as specified according to https://html.spec.whatwg.org/multipage/syntax.html#attributes-2
    : ATTR_NAME_VALID+
    // Alternatively, a string literal may be used...  
    //| STRING_LITERAL 
    ;

ATTR_VALUE
    : // TODO
    ;

ATTR_COLON: COLON -> type(COLON);


// Lexing mode for text/html binding
mode CONTENT_MODE;

CONTENT_SEMI: SEMI -> popMode, type(SEMI);


// Lexing mode for replace bindings
mode REPLACE_MODE;

REPLACE_SEMI: SEMI -> popMode, type(SEMI);


// Lexing mode for CSS queries
mode QUERY_MODE;
QUERY_LBRACE    : LBRACE -> mode(BLOCK_MODE), type(LBRACE);
SELECTORS
	: SELECTOR (COMMA SELECTOR)*
	;

SELECTOR
	: ELEMENT+ (SELECTOR_PREFIX ELEMENT)* ATTRIB* PSEUDO?
	;

SELECTOR_PREFIX
  : (GT | PLUS | TILDE)
  ;

ELEMENT
  : TAG_NAME
  | '#' ATTR_VALUE
  | '.' CLASS_NAME
  | '&'
  | '*'
	;

PESUDO
   : (COLON|COLONCOLON) TAG_NAME
   ;

ATTRIB
	: '[' ATTR_NAME (ATTR_RELATE (STRING_LITERAL | Identifier))? ']'
	;

ATTR_RELATE
	: '='
	| '~='
	| '|='
	;
SPACE           : WS -> more;


// Lexing mode for blocks
mode BLOCK_MODE;

BLOCK_RBRACE: RBRACE -> popMode, type(RBRACE);

//IdentifierAfter        : Identifier;
//DOT_ID                 : DOT -> popMode, type(DOT);

//LPAREN_ID                 : LPAREN -> popMode, type(LPAREN);
//RPAREN_ID                 : RPAREN -> popMode, type(RPAREN);

//COLON_ID                  : COLON -> popMode, type(COLON);
//COMMA_ID                  : COMMA -> popMode, type(COMMA);
//SEMI_ID                  : SEMI -> popMode, type(SEMI);

/*
MAPPING: 'mapping';
ATTR: ('attr'|'@');
CONTENT: 'content';

NULL              : 'null';

COMBINE_COMPARE : '&&' | '||';

Ellipsis          : '...';

InterpolationStart
  : HASH BlockStart -> pushMode(IDENTIFY)
  ;

//Separators
LPAREN          : '(';
RPAREN          : ')';
BlockStart      : '{';
BlockEnd        : '}';
LBRACK          : '[';
RBRACK          : ']';
GT              : '>';
TIL             : '~';

LT              : '<';
COLON           : ':';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';
DOLLAR          : '$';
AT              : '@';
AND             : '&';
HASH            : '#';
COLONCOLON      : '::';
PLUS            : '+';
STAR            : '*';
DIV             : '/';
MINUS           : '-';
PERC            : '%';

// Operators
EQEQ            : '==';
NOTEQ           : '!=';
EQ              : '=';
PIPE_EQ         : '|=';
TILD_EQ         : '~=';


fragment AllValidIdentifierCharacters
    : [\-_*0-9a-zA-Z\u0100-\ufffe] ;

fragment AllValidPathIdentifierCharacters
    : [\-._*0-9a-zA-Z\u0100-\ufffe] ;

Identifier
    : AllValidIdentifierCharacters+ -> pushMode(IDENTIFY);

/*
WildcardIdentifier
    : ('*'AllValidIdentifierCharacters) | (AllValidIdentifierCharacters'*') -> pushMode(IDENTIFY);


PathIdentifier
    : AllValidPathIdentifierCharacters+ -> pushMode(IDENTIFY);

WildcardPathIdentifier
	: '*'?AllValidPathIdentifierCharacters+'*'? -> pushMode(IDENTIFY);

fragment STRING
  	:	'"' (~('"'|'\n'|'\r'))* '"'
  	|	'\'' (~('\''|'\n'|'\r'))* '\''
  	;

// string literals
StringLiteral
	:	STRING
	;


Number
	:	'-' (('0'..'9')* '.')? ('0'..'9')+
	|	(('0'..'9')* '.')? ('0'..'9')+
	;

mode IDENTIFY;
BlockStart_ID          : BlockStart -> popMode, type(BlockStart);
SPACE                  : WS -> popMode, skip;
DOLLAR_ID              : DOLLAR -> type(DOLLAR);


InterpolationStartAfter  : InterpolationStart;
InterpolationEnd_ID    : BlockEnd -> type(BlockEnd);

IdentifierAfter        : Identifier;
Ellipsis_ID            : Ellipsis -> popMode, type(Ellipsis);
DOT_ID                 : DOT -> popMode, type(DOT);

LPAREN_ID                 : LPAREN -> popMode, type(LPAREN);
RPAREN_ID                 : RPAREN -> popMode, type(RPAREN);

COLON_ID                  : COLON -> popMode, type(COLON);
COMMA_ID                  : COMMA -> popMode, type(COMMA);
SEMI_ID                  : SEMI -> popMode, type(SEMI);

*/



