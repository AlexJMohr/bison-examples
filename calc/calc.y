/* Infix Notation Calculator */

%{
    #include <stdio.h>
    #include <math.h>
    #include <ctype.h>
    int yylex(void);
    void yyerror(char const*);
%}

%define api.value.type {double}
%token NUM

/* Operator precedence, in order of lowest to highest precedence. */
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'

%%

input:
    %empty
|   input line
;

line:
    '\n'
|   exp '\n'    { printf("=%.10g\n", $1); }
|   error '\n'  { yyerrok; }
;

exp:
    NUM
|   exp '+' exp         { $$ = $1 + $3; }
|   exp '-' exp         { $$ = $1 - $3; }
|   exp '*' exp         { $$ = $1 * $3; }
|   exp '/' exp         { $$ = $1 / $3; }
|   '-' exp %prec NEG   { $$ = -$2; }
|   exp '^' exp         { $$ = pow($1, $3); }
|   '(' exp ')'         { $$ = $2; }
;

%%

int yylex(void)
{
    int c = getchar();
    // Skip whitespace
    while (c == ' ' || c == '\t')
        c = getchar();
    
    // process numbers
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &yylval);
        return NUM;
    }

    // return end-of-input
    else if (c == EOF)
        return YYEOF;
    
    // return a single char
    else
        return c;
}

void yyerror(char const *s)
{
    fprintf(stderr, "%s\n", s);
}

int main(void)
{
    return yyparse();
}