%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char* message) {
    printf("syntax error\n");
};

void syntax_error(){
    printf("syntax error\n");
    exit(1);
}

void type_error(){
    printf("Type error!\n");
    exit(1);
}

// 用gcc的話這邊會爆，請使用g++編譯
struct Node{
    char data_type;
    int number;
    char* name;
    int inFun;
    int isbool;
    Node *left_node;
    Node *right_node;
    Node *mid_node;// 給if用
    // 快速宣告用的啦哈哈
	Node(char ch_data, Node * left, Node * right) : number(0), data_type(ch_data), left_node(left), mid_node(NULL), right_node(right), name(""), inFun(0), isbool(0) {}
    Node(char ch_data, Node * left, Node * right, int is_bool) : number(0), data_type(ch_data), left_node(left), mid_node(NULL), right_node(right), name(""), inFun(0), isbool(is_bool) {}
};

struct Table{
    char* name;
    int value;
    int inFun;
};

Node *root=NULL; // 根結點
Node *fun_table[50]; // store functions node's pointer
struct Table var_table[50], param_table[50];

void traverse(Node *node);
void freeTree(Node* node);
void add_op(Node *node);
void multiply_op(Node *node);
void equal_op(Node *node);
void and_op(Node *node);
void or_op(Node *node);
void store_params(Node *node);
void bind_params(Node *node);

// create new node
Node *newNode(Node *Left_pointer, Node *Right_pointer, char data) {
    Node *node = new Node(data, Left_pointer, Right_pointer);
    return node;
}

Node *newNode(Node *Left_pointer, Node *Right_pointer, char data, int is_bool) {
    Node *node = new Node(data, Left_pointer, Right_pointer, is_bool);
    return node;
}

%}

%union {
    int intval, boolval;
    char* strval;
    struct Node *nodeval;
}

%token <strval> ID
%token <intval> NUMBER 
%token <boolval> BOOL
%token PRINTNUM 
%token PRINTBOOL

%type <nodeval> EXP DEF_STMT NUM_OP PROGRAM STMTS STMT PRINT_STMT 
%type <nodeval> FUN_EXP FUN_ids FUN_BODY FUN_CALL FUN_NAME 
%type <nodeval> VARIABLE ids EXPS PARAM
%type <nodeval> PLUS MINUS MULTIPLY DIVIDE MODULES GREATER SMALLER EQUAL
%type <nodeval> IF_EXP LOGICAL_OP AND_OP OR_OP NOT_OP

%%

PROGRAM : STMTS {root = $1;}
    ;
STMTS
    : STMT STMTS {$$ = newNode($1, $2,'S');}
    | STMT {$$ = $1;}
    ;
STMT
    : EXP {$$ = $1;}
    | DEF_STMT {$$ = $1;}
    | PRINT_STMT {$$ = $1;}
    ;
PRINT_STMT
    : '(' PRINTNUM EXP ')' {$$ = newNode($3, NULL, 'P');}
    | '(' PRINTBOOL EXP ')' {$$ = newNode($3, NULL, 'p');}
    ;
EXP
    : BOOL {
        $$ = newNode(NULL, NULL, 'B', 1); 
        $$->number = $1;
    }
    | NUMBER {
        $$ = newNode(NULL, NULL, 'N'); 
        $$->number = $1;
    }
    | VARIABLE {$$ = $1;}
    | NUM_OP {$$ = $1;}
    | LOGICAL_OP {$$ = $1;}
    | FUN_EXP {$$ = $1;}
    | FUN_CALL {$$ = $1;}
    | IF_EXP {$$ = $1;}
    ;
NUM_OP
    : PLUS {$$ = $1;}
    | MINUS {$$ = $1;}
    | MULTIPLY {$$ = $1;}
    | DIVIDE {$$ = $1;}
    | MODULES {$$ = $1;}
    | GREATER {$$ = $1;}
    | SMALLER {$$ = $1;}
    | EQUAL {$$ = $1;}
    ;
PLUS
    : '(' '+' EXP EXPS ')' {
        $$ = newNode($3, $4, '+');
    }
    ;
MINUS
    : '(' '-' EXP EXP ')' {
        $$ = newNode($3, $4, '-');
    } 
    ;
MULTIPLY
    : '(' '*' EXP EXPS ')' {
        $$ = newNode($3, $4, '*');
    }
    ;
DIVIDE
    : '(' '/' EXP EXP ')' {
        $$ = newNode($3, $4, '/');
    }
    ;
MODULES
    : '(' '%' EXP EXP ')' {
        $$ = newNode($3, $4, '%');
    }
    ;
GREATER
    : '(' '>' EXP EXP ')' {
        $$ = newNode($3, $4, '>',1);
    }
    ;
SMALLER
    : '(' '<' EXP EXP ')' {
        $$ = newNode($3, $4, '<',1);
    }
    ;
EQUAL
    : '(' '=' EXP EXPS ')' {
        $$ = newNode($3, $4, '=',1);
    }
    ;
EXPS
    : EXP EXPS {
        $$ = newNode($1, $2, 'E');
    }
    | EXP {$$ = $1;}
    ;
LOGICAL_OP
    : AND_OP {$$ = $1;}
    | OR_OP {$$ = $1;}
    | NOT_OP {$$ = $1;}
    ;
AND_OP 
    : '(' '&' EXP EXPS ')' {
        $$ = newNode($3, $4, '&', 1);
    }
    ;
OR_OP
    : '(' '|' EXP EXPS ')' {
        $$ = newNode($3, $4, '|', 1);
    }
    ;
NOT_OP
    : '(' '!' EXP ')' {
        $$ = newNode($3, NULL, '~', 1);
    }
    ;
DEF_STMT
    : '(' 'd' VARIABLE EXP ')' {
        $$ = newNode($3, $4, 'D');
    }
    ;
IF_EXP
    : '(' 'i' EXP EXP EXP ')' {
        $$ = newNode($3, $5, 'I'); 
        $$->mid_node = $4;
    }
    ;
VARIABLE
    : ID {
        $$ = newNode(NULL, NULL, 'V'); 
        $$->name = $1;
    }
    ;
FUN_EXP
    : '(' 'l' FUN_ids FUN_BODY ')' {
        $$ = newNode($3, $4, 'F');
    }
    ;
FUN_ids
    : '(' ids ')' {
        $$ = $2;
    }
    ;
ids
    : ids VARIABLE {    
        $$ = newNode($1, $2, 'E'); 
    }
    | {
        $$ = newNode(NULL, NULL, 'n');
    }
    ;
FUN_CALL
    : '(' FUN_EXP PARAM ')' {
        $$ = newNode($2, $3, 'c');
    }
    | '(' FUN_NAME PARAM ')' {
        $$ = newNode($2, $3, 'C');
    }
    ;
FUN_BODY
    : EXP {
        $$ = $1;
    }
    ;
PARAM
    : EXP PARAM {
        $$ = newNode($1, $2, 'E');
    }
    | {
        $$ = newNode(NULL, NULL, 'n');
    }
    ;
FUN_NAME
    : ID {
        $$ = newNode(NULL, NULL, 'f'); 
        $$->name = $1;
    }
    ;

%%

// 遍歷時用，幫助運算的temp
int ans;
int fun_count=0,var_count=0,param_count=0;
int first_number,equal_number,i,temp,temp2;

// 工人智慧把AST遍歷，媽的不准再搞事了
void traverse(Node *node){
    if(node == NULL) 
        return;

    if(node->data_type == '+'){// plus
        traverse(node->left_node);
        traverse(node->right_node);
        ans=0;
        add_op(node);
        node->number=ans;

        if(node->left_node->isbool||node->right_node->isbool){
            type_error();
        }
    } else if(node->data_type == '-'){// minus
        traverse(node->left_node);
        traverse(node->right_node);
        node->number = node->left_node->number - node->right_node->number;

        if(node->left_node->isbool||node->right_node->isbool){
            type_error();
        }
    } else if(node->data_type == '*'){// multiply
        traverse(node->left_node);
        traverse(node->right_node);
        ans=1;
        multiply_op(node);
        node->number=ans;

        if(node->left_node->isbool||node->right_node->isbool){
            type_error();
        }
    } else if(node->data_type == '/'){// div
        traverse(node->left_node);
        traverse(node->right_node);
        if(node->left_node != NULL && node->right_node != NULL)
            node->number = node->left_node->number / node->right_node->number;
        else syntax_error();

        if(node->left_node->isbool||node->right_node->isbool){
            type_error();
        }
    } else if(node->data_type == '%'){// mod
        traverse(node->left_node);
        traverse(node->right_node);
        if(node->left_node != NULL && node->right_node != NULL)
            node->number = node->left_node->number % node->right_node->number;
        else syntax_error();

        if(node->left_node->isbool||node->right_node->isbool){
            type_error();
        }
    } else if(node->data_type == '<'){// smaller
        traverse(node->left_node);
        traverse(node->right_node);
        if(node->left_node != NULL && node->right_node != NULL){
            if(node->left_node->number < node->right_node->number)
                node->number = 1;
            else
                node->number = 0;
        }
        node->isbool = 1;
    } else if(node->data_type == '='){// equal
        traverse(node->left_node);
        traverse(node->right_node);
        first_number=0;
        ans=1;
        equal_op(node);
        node->number=ans;
        node->isbool = 1;
    } else if(node->data_type == '>'){// greater
        traverse(node->left_node);
        traverse(node->right_node);
        if(node->left_node != NULL && node->right_node != NULL){
            if(node->left_node->number > node->right_node->number)
                node->number = 1;
            else
                node->number = 0;
        }
        node->isbool = 1;
    } else if(node->data_type == '&'){// and
        traverse(node->left_node);
        traverse(node->right_node);
        ans=1;
        and_op(node);
        node->number=ans;
        node->isbool = 1;
    } else if(node->data_type == '|'){// or
        traverse(node->left_node);
        traverse(node->right_node);
        ans=0;
        or_op(node);
        node->number=ans;
        node->isbool = 1;
    } else if(node->data_type == '~'){// not
        traverse(node->left_node);
        node->number = !node->left_node->number;
        node->isbool = 1;
    } else if(node->data_type == 'P'){// print number 
        traverse(node->left_node);
        printf("%d\n", node->left_node->number);
    } else if(node->data_type == 'p'){// print boolean
        traverse(node->left_node);
        if(node->left_node->number)
            printf("#t\n"); 
        else 
            printf("#f\n");
    } else if(node->data_type == 'I'){// if
        traverse(node->left_node);
        traverse(node->mid_node);
        traverse(node->right_node);
        if(node->left_node->number == 1){
            node->number = node->mid_node->number;
            node->isbool = node->mid_node->isbool;
        }else{
            node->number = node->right_node->number;
            node->isbool = node->right_node->isbool;
        }
    } else if(node->data_type == 'D'){// define
        if(node->right_node->data_type == 'F'){// function
            if(node->right_node->left_node->data_type == 'n'){// 沒有id
                var_table[var_count].name = node->left_node->name;
                var_table[var_count].value = node->right_node->right_node->number;
                var_table[var_count++].inFun = 0;
            }
            else// 有id
                fun_table[fun_count++] = node;
        }
        // variables
        else{
            traverse(node->left_node);
            traverse(node->right_node);
            var_table[var_count].name = node->left_node->name;
            var_table[var_count++].value = node->right_node->number;
        }
    } else if(node->data_type == 'V'){// variables，搜尋字典並做代換
        for(i=0; i<var_count; i++){
            if(var_table[i].inFun == node->inFun && strcmp(var_table[i].name, node->name) == 0){
                node->number = var_table[i].value;
                break;
            }
        }
    } else if(node->data_type == 'F'){// 不用管，define會做
        traverse(node->left_node);
        traverse(node->right_node);
        node->isbool = node->right_node->isbool;
    } else if(node->data_type == 'c'){// define and call function 
        param_count=0; 
        store_params(node);
        temp=param_count;
        param_count=0; 
        bind_params(node);
        traverse(node->left_node);
        traverse(node->right_node);
        var_count = var_count - temp; 
        node->number = node->left_node->right_node->number;
        node->isbool = node->left_node->right_node->isbool;
    } else if(node->data_type == 'C'){// function name
        if(node->right_node->left_node->data_type == 'C'){
            node->right_node->left_node->data_type = 'N';// NUMBER
            for(i=0; i<var_count; i++){
                if (var_table[i].inFun == 0 && strcmp(var_table[i].name, node->right_node->left_node->left_node->name) == 0){
                    node->right_node->left_node->number = var_table[i].value;
                    break;
                }
            }
        }

        // temp 存 fun_table 當中東西的位置
        temp=0;
        for(i=0; i<fun_count; i++){
            if(node->left_node->name == fun_table[i]->name){
                temp=i;
                break;
            }
        }
       
        param_count=0; 
        store_params(node->right_node); 
        temp2 = param_count;
        param_count=0; 
        bind_params(fun_table[temp]->right_node); 
        traverse(fun_table[temp]->left_node);
        traverse(fun_table[temp]->right_node);
        var_count = var_count - temp2; 

        node->number = fun_table[temp]->right_node->right_node->number;
        node->isbool = fun_table[temp]->right_node->right_node->isbool;
    } else{ // STMTS 等等，不用處理
        traverse(node->left_node);
        traverse(node->right_node);
    }
}

// 把要遞迴的運算子拉出來做
void add_op(Node *node){
    if(node->left_node != NULL){
        node->isbool = node->left_node->isbool == 1 ? 1 : node->isbool;
        if(node->isbool) type_error();
        ans = ans + node->left_node->number;
        if(node->left_node->data_type == 'E')
            add_op(node->left_node);
    }
    if(node->right_node != NULL){
        node->isbool = node->right_node->isbool == 1 ? 1 : node->isbool;
        if(node->isbool) type_error();
        ans = ans + node->right_node->number;
        if(node->right_node->data_type == 'E')
            add_op(node->right_node);
    }
}

void multiply_op(Node *node){
    if(node->left_node != NULL){
        node->isbool = node->left_node->isbool == 1 ? 1 : node->isbool;
        if(node->isbool) type_error();
        if(node->left_node->data_type != 'E')
            ans = ans * node->left_node->number;
        else
            multiply_op(node->left_node);
    }
    if(node->right_node != NULL){
        node->isbool = node->right_node->isbool == 1 ? 1 : node->isbool;
        if(node->isbool) type_error();
        if(node->right_node->data_type != 'E')
            ans = ans * node->right_node->number;
        else
            multiply_op(node->right_node);
    }
}

void equal_op(Node *node){
    if(node->left_node != NULL){
        if(node->left_node->data_type != 'E'){
            if(first_number==0){
                equal_number=node->left_node->number;
                first_number=1;
            }
            else{
                if(node->left_node->number != equal_number)
                    ans=0;
            }
        } 
        else
            equal_op(node->left_node);
    }
    if(node->right_node != NULL){
        if(node->right_node->data_type != 'E'){
            if(first_number==0){
                equal_number=node->right_node->number;
                first_number=1;
            }
            else{
                if(node->right_node->number != equal_number)
                    ans=0;
            }
        } 
        else
            equal_op(node->right_node);
    }
}

void and_op(Node *node){
    if(node->left_node != NULL){
        if(node->left_node->data_type != 'E')
            ans = ans & node->left_node->number;
        else
            and_op(node->left_node);
    }
    if(node->right_node != NULL){
        if (node->right_node->data_type != 'E')
            ans = ans & node->right_node->number;
        else
            and_op(node->right_node);
    }
}

void or_op(Node *node){
    if(node->left_node != NULL){
        if(node->left_node->data_type != 'E')
            ans = ans | node->left_node->number;
        else
            or_op(node->left_node);
    }
    if(node->right_node != NULL){
        if(node->right_node->data_type != 'E')
            ans = ans | node->right_node->number;
        else
            or_op(node->right_node);
    }
}

void store_params(Node * node){// 存function中的變數值進 param_table
    if(node->left_node != NULL && node->left_node->data_type != 'F'){
        if(node->left_node->data_type == 'N')
            param_table[param_count++].value = node->left_node->number;
        store_params(node->left_node);
    }
    if(node->right_node != NULL && node->right_node->data_type != 'F'){
        if(node->right_node->data_type == 'N')
            param_table[param_count++].value = node->right_node->number;
        store_params(node->right_node);    
    }
}

void bind_params(Node * node){// 對function中的變數賦值
    if(node->left_node != NULL){
        if (node->left_node->data_type == 'V'){
            var_table[var_count].name = node->left_node->name;
            var_table[var_count].value = param_table[param_count++].value;
            var_table[var_count++].inFun = 1;

            node->left_node->inFun=1;
        }
        bind_params(node->left_node);
    }
    if(node->right_node != NULL){
        if(node->right_node->data_type == 'V'){
            var_table[var_count].name = node->right_node->name;
            var_table[var_count].value = param_table[param_count++].value;
            var_table[var_count++].inFun = 1;

            node->right_node->inFun=1;
        }
        bind_params(node->right_node);
    }
}

int main(){
    yyparse();
    traverse(root);
    return 0;
}