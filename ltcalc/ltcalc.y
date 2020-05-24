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
|   exp '/' exp
        {
            if ($3 != 0)
                $$ = $1 / $3;
            else {
                $$ = 1;
                fprintf(stderr, "%d.%d-%d.%d: division by zero\n", @3.first_line, @3.first_column, @3.last_line, @3.last_column);
            }
        }
|   '-' exp %prec NEG   { $$ = -$2; }
|   exp '^' exp         { $$ = pow($1, $3); }
|   '(' exp ')'         { $$ = $2; }
;

%%

int yylex(void)
{
    int c;
    // Skip whitespace
    while ((c = getchar()) == ' ' || c == '\t')
        ++yylloc.last_column;
    
    // Step
    yylloc.first_line = yylloc.last_line;
    yylloc.first_column = yylloc.last_column;
    
    // process numbers
    if (isdigit(c)) {
        yylval = c - '0';
        ++yylloc.last_column;
        while (isdigit(c = getchar())) {
            ++yylloc.last_column;
            yylval = yylval * 10 + c - '0';
        }
        ungetc(c, stdin);
        return NUM;
    }

    // return end-of-input
    else if (c == EOF)
        return YYEOF;
    
    // return a single char
    else if (c == '\n') {
        ++yylloc.last_line;
        yylloc.last_column = 0;
    }

    else
        ++yylloc.last_column;
    return c;
}

void yyerror(char const *s)
{
    fprintf(stderr, "%s\n", s);
}

int main(void)
{
    yylloc.first_line = yylloc.last_line = 1;
    yylloc.first_column = yylloc.last_column = 0;
    return yyparse();
}