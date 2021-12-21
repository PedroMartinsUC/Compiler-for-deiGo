#ifndef SYMBOLS_H
#define SYMBOLS_H

typedef struct ast_node ast_tree;
struct ast_node{
    char* token;
    char* value;
    ast_tree* first_child;
    ast_tree* next_sibling;
};

int nrChilds (ast_tree* node);
ast_tree *ast_node(char *token, char* value);
void add_childs(ast_tree *root, int nargs, ...);
void add_siblings(ast_tree *root, int nargs, ...);
void print_tree(ast_tree *node, int level);
void free_tree(ast_tree *node);
ast_tree *null_check(ast_tree *node);

#endif
