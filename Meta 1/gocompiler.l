/*

João Carlos Borges Silva Nº 2019216783
Pedro Afonso Ferreira Lopes Martins Nº 2019216826

*/

%{
#include <stdio.h>
#include <string.h>

int l=1;
int lcoment=1;
int c=1;
int ccoment=1;
int semicolon=0;
int cstr=1;

int flag=0;

%}
%X COMMENTS STRLIT ESCSEQ

id 									[_a-zA-Z][a-zA-Z0-9_]*
strlit							\"[^\"\n\r\\]*({esc_seq}[^\"\n\r\\]*)*\"
intlit							(0([xX](_?[0-9a-fA-F]+))*)|(0(_?[0-7]+)*)|(0|([1-9](_?[0-9]+)*))|(0[bB](_?[0-1]+)*)
reallit								(([0-9]+"."[0-9]*)((("e"|"E")("+"|"-")?)[0-9]+)?|[0-9]*((("e"|"E")("+"|"-")?)[0-9]+)|([0-9]*"."[0-9]+)((("e"|"E")("+"|"-")?)[0-9]+)?)
reserved  					"break"|"case"|"chan"|"const"|"continue"|"default"|"defer"|"fallthrough"|"go"|"goto"|"import"|"interface"|"map"|"range"|"select"|"struct"|"switch"|"type"|"++"|"--"
	
semicolon      			";"
comma								","
blankid							"_"
assign							"="
star								"*"
div									"/"
minus								"-"
plus								"+"
eq									"=="
ge									">="
gt									">"
lbrace							"{"
le									"<="
lpar								"("
lsq									"["
lt									"<"
mod									"%"
ne									"!="
not									"!"
and									"&&"
or									"||"
rbrace							"}"
rpar								")"
rsq									"]"
package							"package"
return							"return"
else								"else"
for									"for"
if									"if"
var									"var"
int									"int"
float32							"float32"
bool								"bool"
string							"string"
print								"fmt.Println"
parseint						"strconv.Atoi"
func								"func"
cmdargs							"os.Args"

invoctal							0(_?[0-7]*[8-9]+[0-7]*)*	
invescape						"\\"[^"f""n""r""t""\\"\"\n\r]
esc_seq							"\\"("f"|"n"|"r"|"t"|"\\"|\")

comments						"//"[^\n]*\n

%%
\"\"																						{if(flag==1) printf("STRLIT(\"\")\n"); c+=yyleng; semicolon=1;}

\"																							{BEGIN STRLIT; cstr=c; c+=yyleng; }
<STRLIT><<EOF>>																	{printf("Line %d, column %d: unterminated string literal\n", l, cstr); semicolon=0; return 0;}
<STRLIT>([^\"\n\r\\]*{esc_seq}*)*(\r)?\n				{printf("Line %d, column %d: unterminated string literal\n", l, cstr); c=1; l++; BEGIN 0;  semicolon=0;}
<STRLIT>([^\"\n\r\\]*{esc_seq}*)*"\\"						{printf("Line %d, column %d: invalid escape sequence (%s)\n", l, c+yyleng-1, &yytext[yyleng-1]); c+=yyleng; BEGIN ESCSEQ;  semicolon=0;}
<STRLIT>([^\"\n\r\\]*{esc_seq}*)*{invescape}		{printf("Line %d, column %d: invalid escape sequence (%s)\n", l, c+yyleng-2, &yytext[yyleng-2]); c+=yyleng; BEGIN ESCSEQ;  semicolon=0;}
<STRLIT>([^\"\n\r\\]*{esc_seq}*)*				 				{if(flag==1){ printf("STRLIT(\"%s\")\n", yytext); c+=yyleng;} semicolon=1;}
<STRLIT>\"																			{BEGIN 0; c+=1;}	


<ESCSEQ>"\\"																		{printf("Line %d, column %d: invalid escape sequence (%s)\n", l, c, &yytext[yyleng-1]); c+=yyleng;  semicolon=0;}
<ESCSEQ>{invescape}															{printf("Line %d, column %d: invalid escape sequence (%s)\n", l, c, &yytext[yyleng-2]); c+=yyleng;  semicolon=0;}	
<ESCSEQ>(\r)?\n																	{printf("Line %d, column %d: unterminated string literal\n", l, cstr); c=1; l++; BEGIN 0;  semicolon=0;}
<ESCSEQ><<EOF>>																	{printf("Line %d, column %d: unterminated string literal\n", l, cstr);  semicolon=0; return 0;}
<ESCSEQ>([^\"\n\r\\]*{esc_seq}*)*								{c+=yyleng;}
<ESCSEQ>\"																			{BEGIN 0;	c+=yyleng;}


"/*"																{BEGIN COMMENTS; lcoment=l; ccoment=c; c+=yyleng;}
<COMMENTS>"*/"											{BEGIN 0;  c+=yyleng;}
<COMMENTS><<EOF>>										{printf("Line %d, column %d: unterminated comment\n", lcoment, ccoment); BEGIN 0; return 0;}
<COMMENTS>(\r)?\n										{if(flag==1){ if(semicolon==1) printf("SEMICOLON\n");} l++; c=1; semicolon=0;}
<COMMENTS>.													{c+=yyleng;}
{comments}													{if(flag==1){ if(semicolon==1) printf("SEMICOLON\n");} l++; c=1; semicolon=0;}

(\r)?\n															{if(flag==1){ if(semicolon==1) printf("SEMICOLON\n");} l++;c=1; semicolon=0;}
<<EOF>>															{if(flag==1){ if(semicolon==1) printf("SEMICOLON\n");} return 0;}

{semicolon}         	{if(flag==1){ printf("SEMICOLON\n");} c+=yyleng; semicolon=0;}
{comma}								{if(flag==1){ printf("COMMA\n");} c+=yyleng; semicolon=0;}
{blankid}							{if(flag==1){ printf("BLANKID\n");} c+=yyleng; semicolon=0;}
{assign}							{if(flag==1){ printf("ASSIGN\n");} c+=yyleng; semicolon=0;}
{star}								{if(flag==1){ printf("STAR\n");} c+=yyleng; semicolon=0;}
{div}									{if(flag==1){ printf("DIV\n");} c+=yyleng; semicolon=0;}
{minus}								{if(flag==1){ printf("MINUS\n");} c+=yyleng; semicolon=0;}
{plus}								{if(flag==1){ printf("PLUS\n");} c+=yyleng; semicolon=0;}
{eq}									{if(flag==1){ printf("EQ\n");} c+=yyleng; semicolon=0;}
{ge}									{if(flag==1){ printf("GE\n");} c+=yyleng; semicolon=0;}
{gt}									{if(flag==1){ printf("GT\n");} c+=yyleng; semicolon=0;}
{lbrace}							{if(flag==1){ printf("LBRACE\n");} c+=yyleng; semicolon=0;}
{le}									{if(flag==1){ printf("LE\n");} c+=yyleng; semicolon=0;}
{lpar}								{if(flag==1){ printf("LPAR\n");} c+=yyleng; semicolon=0;}
{lsq}									{if(flag==1){ printf("LSQ\n");} c+=yyleng; semicolon=0;}
{lt}									{if(flag==1){ printf("LT\n");} c+=yyleng; semicolon=0;}
{mod}									{if(flag==1){ printf("MOD\n");} c+=yyleng; semicolon=0;}
{ne}									{if(flag==1){ printf("NE\n");} c+=yyleng; semicolon=0;}
{not}									{if(flag==1){ printf("NOT\n");} c+=yyleng; semicolon=0;}
{and}									{if(flag==1){ printf("AND\n");} c+=yyleng; semicolon=0;}
{or}									{if(flag==1){ printf("OR\n");} c+=yyleng; semicolon=0;}
{rbrace}							{if(flag==1){ printf("RBRACE\n");} c+=yyleng; semicolon=1;}				 	
{rpar}								{if(flag==1){ printf("RPAR\n");} c+=yyleng; semicolon=1;}				 	
{rsq}									{if(flag==1){ printf("RSQ\n");} c+=yyleng; semicolon=1;}				 	
{package}							{if(flag==1){ printf("PACKAGE\n");} c+=yyleng; semicolon=0;}
{return}							{if(flag==1){ printf("RETURN\n");} c+=yyleng; semicolon=1;} 	
{else}								{if(flag==1){ printf("ELSE\n");} c+=yyleng; semicolon=0;}
{for}									{if(flag==1){ printf("FOR\n");} c+=yyleng; semicolon=0;}
{if}									{if(flag==1){ printf("IF\n");} c+=yyleng; semicolon=0;}
{var}									{if(flag==1){ printf("VAR\n");} c+=yyleng; semicolon=0;}
{int}									{if(flag==1){ printf("INT\n");} c+=yyleng; semicolon=0;}
{float32}							{if(flag==1){ printf("FLOAT32\n");} c+=yyleng; semicolon=0;}
{bool}								{if(flag==1){ printf("BOOL\n");} c+=yyleng; semicolon=0;}
{string}							{if(flag==1){ printf("STRING\n");} c+=yyleng; semicolon=0;}
{print}								{if(flag==1){ printf("PRINT\n");} c+=yyleng; semicolon=0;}
{parseint}						{if(flag==1){ printf("PARSEINT\n");} c+=yyleng; semicolon=0;}
{func}								{if(flag==1){ printf("FUNC\n");} c+=yyleng; semicolon=0;}
{cmdargs}							{if(flag==1){ printf("CMDARGS\n");} c+=yyleng; semicolon=0;}	

{reserved}						{if(flag==1){ printf("RESERVED(%s)\n", yytext);} c+=yyleng; semicolon=0;}
{id} 									{if(flag==1){ printf("ID(%s)\n", yytext);} c+=yyleng; semicolon=1;}
	/* {strlit}				{printf("STRLIT(%s)\n", yytext); c+=strlen(yytext); semicolon=1;} */
{intlit}							{if(flag==1){ printf("INTLIT(%s)\n", yytext);} c+=yyleng; semicolon=1;}
{reallit}							{if(flag==1){ printf("REALLIT(%s)\n", yytext);} c+=yyleng; semicolon=1;}


" "|\t								{c+=yyleng;}



{invoctal}						{printf("Line %d, column %d: invalid octal constant (%s)\n", l, c, yytext); c+=yyleng; semicolon=0;}
.											{printf("Line %d, column %d: illegal character (%c)\n", l, c, yytext[0]); c+=yyleng; semicolon=0;}


%%
int main(int argc, char *argv[]){

if(argc==2 && strcmp(argv[1],"-l")==0){
	flag=1;
}

yylex();
//printf("\nlinhas: %d\n", l);
return 0;
}

int yywrap()
{
return 1;
}
