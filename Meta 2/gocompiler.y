/*

João Carlos Borges Silva Nº 2019216753
Pedro Afonso Ferreira Lopes Martins Nº 2019216826

*/

%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "symbols.h"
    #include "y.tab.h"

    int yylex (void);
    void yyerror(char* s);
    int yylex_destroy(void);

    int flagL=0;
    int flagT=0;  
    int flagTerror=0;
    int flagErrorEOF=0;
    int flagErrorNL=0;

    ast_tree *program;

    #define givetype(nodes, type)\
        ast_tree* auxnode = NULL;\
		for (ast_tree *current = nodes; current; current = current->next_sibling){\
            auxnode=ast_node(type->token, NULL);\
            auxnode->next_sibling=current->first_child;\
            current->first_child=auxnode;\
        }

%}


%union {
    char* token;
    ast_tree *node;
}

%token <token> SEMICOLON COMMA BLANKID 
%token <token> ASSIGN STAR DIV MINUS PLUS MOD
%token <token> EQ GE GT LE LT NE NOT AND OR
%token <token> LBRACE LSQ LPAR RPAR RSQ RBRACE
%token <token> PACKAGE RETURN 
%token <token> IF ELSE FOR
%token <token> VAR INT FLOAT32 BOOL STRING
%token <token> ID INTLIT REALLIT STRLIT
%token <token> PRINT PARSEINT FUNC CMDARGS RESERVED


%left COMMA
%right ASSIGN 
%left OR 
%left AND 
%left EQ NE GT GE LT LE
%left MINUS PLUS 
%left STAR DIV MOD
%right NOT

%nonassoc NO_ELSE
%nonassoc ELSE
%nonassoc RPAR LPAR LSQ RSQ

%type <node> Program Declarations VarDeclaration VarSpec_Rep Type
%type <node> FuncDeclaration 
%type <node> Parameters Parameters_Rep FuncBody VarsAndStatements 
%type <node> Statement   Statement_Rep
%type <node> ParseArgs FuncInvocation  FuncInvocation_Rep Expr
%type <node> Parameters_Decl

%%

Program:
    PACKAGE ID SEMICOLON Declarations                                       {$$ = program = ast_node("Program", NULL); add_childs(program, 1, $4);}    
    ;

Declarations:   
      FuncDeclaration SEMICOLON Declarations                                {$$ = $1; add_siblings($$, 1, $3);}
    | VarDeclaration SEMICOLON Declarations                                 {$$ = $1; add_siblings($$, 1, $3);}
    |                                                                       {$$ = NULL;}
    ;

VarDeclaration:
    VAR ID VarSpec_Rep Type                                                 {$$ = ast_node("VarDecl", NULL); 
                                                                            add_childs($$, 2, $4, ast_node("Id", $2)); 
                                                                            givetype($3, $4); add_siblings($$, 1, $3);}

    | VAR LPAR ID VarSpec_Rep Type SEMICOLON RPAR                           {$$ = ast_node("VarDecl", NULL); 
                                                                            add_childs($$, 2, $5, ast_node("Id", $3)); 
                                                                            givetype($4, $5); add_siblings($$, 1, $4);}
    ;

VarSpec_Rep:
     COMMA ID VarSpec_Rep                                                   {$$ = ast_node("VarDecl", NULL); 
                                                                            add_childs($$, 1, ast_node("Id", $2)); 
                                                                            add_siblings($$, 1, $3);}

    |                                                                       {$$ = NULL;}
    ;

Type:
    INT                                                                     {$$ = ast_node("Int", NULL);}
    | FLOAT32                                                               {$$ = ast_node("Float32", NULL);}
    | BOOL                                                                  {$$ = ast_node("Bool", NULL);}
    | STRING                                                                {$$ = ast_node("String", NULL);}
    ;

FuncDeclaration:
    FUNC ID LPAR Parameters RPAR Type FuncBody                              {$$ = ast_node("FuncDecl", NULL); 
                                                                            ast_tree* aux=ast_node("FuncHeader", NULL); add_childs(aux, 3, ast_node("Id", $2), $6, $4); 
                                                                            add_childs($$, 2, aux, $7);}

    | FUNC ID LPAR RPAR Type FuncBody                                       {$$ = ast_node("FuncDecl", NULL); 
                                                                            ast_tree* aux=ast_node("FuncHeader", NULL); add_childs(aux, 3, ast_node("Id", $2),  $5, ast_node("FuncParams", NULL));
                                                                            add_childs($$, 2, aux, $6);}

    | FUNC ID LPAR Parameters RPAR FuncBody                                 {$$ = ast_node("FuncDecl", NULL); 
                                                                            ast_tree* aux=ast_node("FuncHeader", NULL); add_childs(aux, 2, ast_node("Id", $2), $4); 
                                                                            add_childs($$, 2, aux, $6);}

    | FUNC ID LPAR RPAR FuncBody                                            {$$ = ast_node("FuncDecl", NULL); 
                                                                            ast_tree* aux=ast_node("FuncHeader", NULL); add_childs(aux, 2, ast_node("Id", $2), ast_node("FuncParams", NULL)); 
                                                                            add_childs($$, 2, aux, $5);}
    ;
    
Parameters:
    Parameters_Decl Parameters_Rep                                          {$$ = ast_node("FuncParams", NULL); add_childs($$, 2, $1, $2);}
    ;

Parameters_Rep:
    COMMA Parameters_Decl Parameters_Rep                                    {$$ = $2; add_siblings($$, 1, $3);}
    |                                                                       {$$ = NULL;}
    ;

Parameters_Decl:
    ID Type                                                                 {$$ = ast_node("ParamDecl", NULL); add_childs($$, 2, $2, ast_node("Id", $1));}

FuncBody:
    LBRACE VarsAndStatements RBRACE                                         {$$ = ast_node("FuncBody", NULL); add_childs($$, 1, $2);}
    ;

VarsAndStatements:
    VarDeclaration  SEMICOLON  VarsAndStatements                            {if($$!=NULL){$$ = $1; add_siblings($$, 1, $3);} else { $$=$3;}}
    | Statement  SEMICOLON  VarsAndStatements                               {if($$!=NULL){$$ = $1; add_siblings($$, 1, $3);} else { $$=$3;}}
    | SEMICOLON  VarsAndStatements                                          {$$ = $2;}
    |                                                                       {$$ = NULL;}
    ;


Statement:
    ID ASSIGN Expr                                                          {$$ = ast_node("Assign", NULL); 
                                                                            if($2!=NULL) add_childs($$, 2, ast_node("Id", $1), $3);}

    | LBRACE Statement_Rep RBRACE                                           {if($2!=NULL){
                                                                                if(nrChilds($2)>=2){
                                                                                    $$ = ast_node("Block", NULL); add_childs($$, 1, $2);
                                                                                }  
                                                                                else {
                                                                                    $$ = $2;
                                                                                } 
                                                                             }  
                                                                             else{
                                                                                $$ = NULL; 
                                                                             }
                                                                            } 
                                                                            
    | IF Expr LBRACE Statement_Rep RBRACE %prec NO_ELSE                     {$$ = ast_node("If", NULL);
                                                                            ast_tree* block=ast_node("Block",NULL); add_childs(block, 1, $4); 
                                                                            ast_tree* block2=ast_node("Block",NULL); 
                                                                            if($2!=NULL) add_childs($$, 3, $2, block, block2);}
    
    | IF Expr LBRACE Statement_Rep RBRACE ELSE LBRACE Statement_Rep RBRACE  {$$ = ast_node("If", NULL); 
                                                                            ast_tree* block=ast_node("Block",NULL); add_childs(block, 1, $4);
                                                                            ast_tree* block2=ast_node("Block",NULL); add_childs(block2, 1, $8);  
                                                                            if($2!=NULL) add_childs($$, 3, $2, block, block2);}

    | FOR Expr LBRACE Statement_Rep RBRACE                                  {$$ = ast_node("For", NULL); 
                                                                            ast_tree* block=ast_node("Block",NULL); add_childs(block, 1, $4); 
                                                                            if($2!=NULL) add_childs($$, 2, $2, block);}

    | FOR LBRACE Statement_Rep RBRACE                                       {$$ = ast_node("For", NULL); 
                                                                            ast_tree* block=ast_node("Block",NULL); add_childs(block, 1, $3); 
                                                                            if($2!=NULL) add_childs($$, 1, block);}

    | RETURN Expr                                                           {$$ = ast_node("Return", NULL); add_childs($$, 1, $2);}
    | RETURN                                                                {$$ = ast_node("Return", NULL);}
    | FuncInvocation                                                        {$$ = ast_node("Call", NULL); add_childs($$, 1, $1);}
    | ParseArgs                                                             {$$ = ast_node("ParseArgs", NULL); add_childs($$, 1, $1);}
    | PRINT LPAR Expr RPAR                                                  {$$ = ast_node("Print", NULL); add_childs($$, 1, $3);}
    | PRINT LPAR STRLIT RPAR                                                {$$ = ast_node("Print", NULL); add_childs($$, 1, ast_node("StrLit", $3));}
    | error                                                                 {$$ = NULL;}



Statement_Rep:
      Statement SEMICOLON Statement_Rep                                     {if($$ != NULL){ $$ = $1; add_siblings($1, 1, $3);}else{ $$ = $3;}}
    |                                                                       {$$ = NULL;}
    ;

ParseArgs:
    ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR         {$$ = ast_node("Id",$1); add_siblings($$, 1, $9);}
    | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                      {$$ = NULL;}
    ;

FuncInvocation:
    ID LPAR Expr FuncInvocation_Rep RPAR                                    {$$ = ast_node("Id", $1); add_siblings($$, 2, $3, $4);}
    | ID LPAR RPAR                                                          {$$ = ast_node("Id", $1); }
    | ID LPAR error RPAR                                                    {$$ = NULL;}
    ;

FuncInvocation_Rep:
    COMMA Expr FuncInvocation_Rep                                           {$$ = $2; add_siblings($$, 1, $3);}
    |                                                                       {$$ = NULL;}
    ;

Expr:
     Expr OR Expr                                                           {$$ = ast_node("Or", NULL); add_childs($$, 2, $1, $3);}
    | Expr AND Expr                                                         {$$ = ast_node("And", NULL); add_childs($$, 2, $1, $3);}
    | Expr LT Expr                                                          {$$ = ast_node("Lt", NULL); add_childs($$, 2, $1, $3);}
    | Expr GT Expr                                                          {$$ = ast_node("Gt", NULL); add_childs($$, 2, $1, $3);}
    | Expr EQ Expr                                                          {$$ = ast_node("Eq", NULL); add_childs($$, 2, $1, $3);}
    | Expr NE Expr                                                          {$$ = ast_node("Ne", NULL); add_childs($$, 2, $1, $3);}
    | Expr LE Expr                                                          {$$ = ast_node("Le", NULL); add_childs($$, 2, $1, $3);}
    | Expr GE Expr                                                          {$$ = ast_node("Ge", NULL); add_childs($$, 2, $1, $3);}
    | Expr PLUS Expr                                                        {$$ = ast_node("Add", NULL); add_childs($$, 2, $1, $3);}
    | Expr MINUS Expr                                                       {$$ = ast_node("Sub", NULL); add_childs($$, 2, $1, $3);}
    | Expr STAR Expr                                                        {$$ = ast_node("Mul", NULL); add_childs($$, 2, $1, $3);}
    | Expr DIV Expr                                                         {$$ = ast_node("Div", NULL); add_childs($$, 2, $1, $3);}
    | Expr MOD Expr                                                         {$$ = ast_node("Mod", NULL); add_childs($$, 2, $1, $3);}
    | NOT Expr %prec NOT                                                    {$$ = ast_node("Not", NULL); add_childs($$, 1, $2);}
    | MINUS Expr %prec NOT                                                  {$$ = ast_node("Minus", NULL); add_childs($$, 1, $2);}
    | PLUS Expr %prec NOT                                                   {$$ = ast_node("Plus", NULL); add_childs($$, 1, $2);}
    | INTLIT                                                                {$$ = ast_node("IntLit", $1);}
    | REALLIT                                                               {$$ = ast_node("RealLit", $1);}
    | ID                                                                    {$$ = ast_node("Id", $1);}
    | FuncInvocation                                                        {$$ = ast_node("Call", NULL); add_childs($$, 1, $1);}
    | LPAR Expr RPAR                                                        {$$ = $2;}
    | LPAR error RPAR                                                       {$$ = NULL;}
    ;



%%

int main(int argc, char *argv[]) {
	if(argc==2){
		if(strcmp(argv[1],"-l")==0){
			flagL=1;
			flagT=0;
			yylex();
		}
		else if(strcmp(argv[1],"-t")==0){
			flagT=1;
			flagL=0;

			yyparse();

            if( flagTerror==0){
                print_tree(program, 0);
            }
		}
	}


	free_tree(program);
    yylex_destroy();

	return 0;
}




