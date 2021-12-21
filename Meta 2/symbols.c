#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbols.h"

#include "y.tab.h"

/*

João Carlos Borges Silva Nº 2019216783
Pedro Afonso Ferreira Lopes Martins Nº 2019216826

*/

int nrChilds (ast_tree* node){
    int count=0;
    ast_tree* root = node;

    if(root->first_child==NULL || root ==NULL){
        return 0;
    }
    else{
        count++;
        while (root->next_sibling != NULL) {
            count++;
            root = root->next_sibling;
        }
        return count;
    }
}

ast_tree *ast_node(char *token, char* value) {
    ast_tree *node = (ast_tree *)malloc(sizeof(ast_tree));

    node->token = token;
    node->value = value;
    node->first_child = NULL;
    node->next_sibling = NULL;

    return node;
}

void add_childs(ast_tree *root, int nargs, ...){
    va_list args;                                                       //define uma lista de argumentos
    va_start(args, nargs);                                              //começa a lista de argumentos dos ...
    ast_tree* current = root->first_child = va_arg(args, ast_tree*);    //define que o first_child do nó dado passado como parametro 
                                                                        //tem o valor do 1º argumento dos ... e define o nó onde se encontra atualmente
    
    ast_tree* child = NULL;                                             //cria um nó auxiliar para criar o child

    for(int i=0; i<nargs-1; i++){
        child = va_arg(args, ast_tree*);                                //percorrer os proximos argumentos dos ...
        for(ast_tree* c = child; c; c = c->next_sibling){
            current->next_sibling = c;
            current = current->next_sibling;
        }
    }

    va_end(args);
}

void add_siblings(ast_tree *root, int nargs, ...){
    va_list args;
    va_start(args, nargs);
    ast_tree* sibling;
    ast_tree* current = root;

    while (current->next_sibling != NULL) {
        current = current->next_sibling;
    }

    for(int i=0; i<nargs; ++i){
        sibling = va_arg(args, ast_tree*);

        current->next_sibling = sibling;
        current = current->next_sibling;
    }
    
    va_end(args);
}

void print_tree(ast_tree *node, int level){
    for (int i = 0; i < level; i++){
        printf("..");
    }
    
    if (node->value != NULL){
        printf("%s(%s)\n", node->token, node->value);
    } else{
        printf("%s\n", node->token);
    }
    
    if (node->first_child != NULL){
        print_tree(node->first_child, level + 1);
    }
    if (node->next_sibling != NULL){
        print_tree(node->next_sibling, level);
    }
}

void free_tree(ast_tree *node){
    if (node == NULL){
        return;
    } else {
        if (node->first_child != NULL){
            free_tree(node->first_child);
        }
        if (node->next_sibling != NULL){
            free_tree(node->next_sibling);
        }
    }

    free(node);
}

