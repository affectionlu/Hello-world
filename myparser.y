%{
#include <iostream>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>
#include<fstream>
#include "mylexer.h"
enum {StmtK,ExpK,DeclK};//三种基本节点类型
enum {IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK};//stmt语句的类型
enum {OpK,ConstK,IdK,TypeK};//表达式子节点类型
enum {VarK};//变量声明
enum {Void,Integer,Char,Boolean};//类型
#define MAXCHILDREN 4//最多孩子数
int line=0;
int Num=0;//给ShowNode行数计数
struct TreeNode
   { 
	struct TreeNode * child[MAXCHILDREN];
     struct TreeNode * sibling;//兄弟节点 用在idlist中包含的id 和stmtlist中包含的stmt,没有进行实际的父子相连
     int lineno;
     int nodekind;                      //三个节点类型 stmt exp decl
	 //表达式(Expression)是运算符(operator)和操作数(operand)所构成的序列
	 //语句(Statement)包括 IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
	 //声明(Declarations)
	 
     int kind;                     //kind 对stmt来说可以是 IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
     
	                                    //kind 对exp来说可以是OpK（操作符）,ConstK（常量）,IdK（标志符）,TypeK（类型           
                                        //对应在输出"Expr," , "Const Declaration,", "ID Declaration,","Type Specifier," 的节点中
                                        
                                        //kind对decl来说只能是VarK  变量声明
     union{ int op;                     //算数表达式操作符
             char* zf;
             int val;                         //算数表达式常量
           char *name; }attr;         //算数表达式标志符
     int type;                              //用于表达式类型       以及语句返回类型
   } ;
TreeNode * newStmtNode(int kind)        //新建一个语句节点
//kind 可以是 IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
{ 
  TreeNode * t = new TreeNode ();
  int i;
  if (t==NULL)
   printf("Out of memory error at line %d\n",line);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind = kind;
    t->lineno = line++;
  }
  return t;  
}

TreeNode * newExpNode(int kind)
{
  TreeNode * t = new TreeNode ();
  int i;
  if (t==NULL)
    printf("Out of memory error at line %d\n",line);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind = kind;
    t->lineno = line++;
    t->type = Void;
  }
  return t;
}


TreeNode * newDeclNode(int kind)
{
  TreeNode * t = new TreeNode ();
  int i;
  if (t==NULL)
    printf("Out of memory error at line %d\n",line);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = DeclK;
    t->kind = kind;
    t->lineno = line++;
  }
  return t;
}
void Display(struct TreeNode *p);		//显示语法树
void ShowNode(struct TreeNode *p);		//显示某个节点
%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

// parser name
%name myparser

// class definition
{
	// place any extra class members here
}

// constructor
{
	// place any extra initialisation code here
}

// destructor
{
	// place any extra cleanup code here
}

// attribute type
%include {
#ifndef YYSTYPE
#define YYSTYPE TreeNode*
#endif
}

// place any declarations here
%token IF MAIN FOR WHILE INPUT PRINT
%token INT CHAR VOID 
%token ID NUM ZIFU
%token PLUS MINUS TIMES OVER REMI DPLUS DMINUS
%token LT LE GT GE EQ NEQ ASSIGN AND OR NOT
%token SEMI COMMA LP RP LFP RFP 
 
%left	COMMA
%right	ASSIGN
%left	EQ NEQ
%left	LT LE GT GE
%left	PLUS MINUS
%left   TIMES OVER REMI
%left   DPLUS DMINUS
%left	LP RP  LFP RFP 
%right	ELSE
%%

/////////////////////////////////////////////////////////////////////////////
// rules section

// place your YACC rules here (there must be at least one)		
start		:MAIN LP RP comp_stmt//main（）主函数体
			{ 
			    $$ = $4;
				Display($4);//自底向上构建语法树，当根节点形成，语法树构建完成，显示
			}
			;
comp_stmt	:LFP  stmt_list RFP//{函数表达式}
			{	
				$$ = newStmtNode(CompK);//建立新的语句节点：复合语句。
				$$->child[0]=$2;
			}
			;
stmt_list	:stmt stmt_list	   //递归		
			{
				$$->sibling=$2;//list内部用兄弟节点连接
				$$= $1;		
			}
			|stmt						
			{
				$$ = $1 ;
			}
			;
stmt		:var_dec	//具体表达式类型，变量声明，表达式，if，for，while、主函数				
			{	
				$$ = $1;
			}
			|exp_stmt					
			{	
				$$ = $1;
			}
			|if_stmt					
			{	
				$$ = $1;
			}
			|for_stmt
			{
				$$ = $1;
			}
			|while_stmt 
			{
				$$ = $1;
			}        
			|comp_stmt					
			{	
				$$ = $1;
			}
			|input_stmt
			{
			    $$ = $1;
			}
			|print_stmt
			{
			    $$ = $1;
			}
			;
input_stmt  :INPUT LP exp RP SEMI//input();
            {
               $$ = newStmtNode(InputK);
               $$ -> type =Boolean;
               $$ -> child[0] = $3;
            }
            ;
print_stmt  :PRINT LP exp RP SEMI//print();
            {
               $$ = newStmtNode(PrintK);
               $$ -> type =Boolean;
               $$ -> child[0] = $3;
            }
            ;			
type_spec	:INT	
			{
				$$ = newExpNode(TypeK);//int
                $$->type=Integer;
                   
			}	
			|CHAR	
			{
				$$ = newExpNode(TypeK);//char
                $$->type=Char;
			}
			|VOID	
			{
				$$ = newExpNode(TypeK);//void
                $$->type=Void;
			}
			;
id_list		:exp COMMA id_list//表达式，表达式
			{
				$$ = $1;
				$$->sibling=$3;
			}
			|exp
			;			             
var_dec		:type_spec id_list SEMI//变量声明 int/char a=/a;
			{	
				$$ = newDeclNode (VarK);//建立一个新的变量声明的节点
				$$->child[0]=$1;
				$$->child[1]=$2;
			}
			;

if_stmt     :IF LP exp RP stmt //if(表达式） 语句
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
      
            | IF LP exp RP  stmt ELSE stmt//if（表达式）语句 else 语句
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                   $$->child[2] = $7;
                 }
            ;
for_stmt	:FOR LP exp SEMI exp SEMI exp RP stmt//for(exp;exp;exp)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $5;
                $$->child[2] = $7;
                $$->child[3] = $9;
			}
			|FOR LP SEMI exp SEMI exp RP stmt//for(;exp;exp)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $4;
                $$->child[1] = $6;
                $$->child[2] = $8;
			}
			|FOR LP exp SEMI SEMI exp RP stmt//for(exp;;exp)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $6;
                $$->child[2] = $8;
			}
			|FOR LP exp SEMI exp SEMI RP stmt//for(exp;exp;)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $5;
                $$->child[2] = $8;
			}
			|FOR LP SEMI SEMI exp RP stmt//for(;;exp)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $5;
                $$->child[1] = $7;
			}
			|FOR LP SEMI exp SEMI RP stmt//for(;exp;)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $4;
                $$->child[1] = $7;
			}
			|FOR LP exp SEMI SEMI RP stmt//for(exp;;)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $7;
			}
			|FOR LP SEMI SEMI RP stmt//for(;;)语句
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $6;
			}
			;
while_stmt	:WHILE LP exp RP stmt//while()
			{
				$$ = newStmtNode(WhileK);
				$$->child[0] = $3;
                $$->child[1] = $5;
			}
			;
exp_stmt	:exp SEMI		//表达式语句；
			{
				$$ = $1;
			}
			|SEMI
			;
//表达式包括赋值，与或，算术，关系
exp			:exp ASSIGN exp//形如 a=b+c
			{
				$$ = newStmtNode(AssignK);
				$$->child[0]=$1;
				$$->child[1]=$3;
			}			
			|or_exp
			{
			    $$ = $1;
			}
			;
or_exp      :or_exp OR and_exp
            {
                $$ = newExpNode(OpK);
                $$ -> attr.op =OR;
                $$ ->child[0] = $1;
                $$ -> child[1] = $3;
            }
            |and_exp
            {
                $$ = $1;
            }
            ;
and_exp     :and_exp AND exp_equ
            {
                $$ = newExpNode(OpK);
                $$ -> attr.op = AND;
                $$ -> child[0] = $1;
                $$ -> child[1] = $3;
            }
            |exp_equ
            {
                $$ = $1;
            }
            ;
 //关系表达式
exp_equ     :exp_equ EQ simple_exp//==     
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=EQ;
			}
			|exp_equ LE simple_exp//<=
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=LE;
			}
			|exp_equ GE simple_exp//>=
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=GE;
			}
			|exp_equ LT simple_exp//<
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=LT;
			}
			|exp_equ GT simple_exp	//>
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=GT;
			}
			|exp_equ NEQ simple_exp	//!=
			{	
				$$ = newExpNode(OpK);
				$$->child[0]=$1;
				$$->child[1]=$3;
				$$->attr.op=NEQ;
			}
			|simple_exp
			{
				$$ = $1;
			}
			;
simple_exp  : simple_exp PLUS term //+ - * \ ++ --
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = PLUS;

                 }
            | simple_exp MINUS term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = MINUS;

                 } 
            | simple_exp TIMES term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = TIMES;
                 } 
            | simple_exp OVER term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = OVER;
                 } 
            | simple_exp REMI term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = REMI;
                 } 
            |simple_exp DPLUS 
			{
				$$ = newExpNode(OpK); 
				$$->child[0] = $1;
                $$->attr.op = DPLUS;

			}
			|simple_exp DMINUS 
			{
				$$ = newExpNode(OpK); 
				$$->child[0] = $1;
                $$->attr.op = DMINUS;

			}
            | term { $$ = $1; }
            ;
term		:LP exp RP				
			{
				$$ = $2;
			}
			|ID					
			{
				$$ = $1;
				
			}
			|NUM				
			{
				$$ = $1;
			}
			|ZIFU
			{
				$$ = $1;
			}
			|NOT term
			{
			   $$ = newExpNode(OpK);
			   $$ -> attr.op = NOT;
			   $$ -> child[0] =$2;
			}
			;
%%

/////////////////////////////////////////////////////////////////////////////
// programs section
void Display(struct TreeNode *p)//显示语法树
{
    TreeNode *temp =new TreeNode();
    for(int i=0;i<MAXCHILDREN;i++){
	   if(p->child[i] != NULL)
	   {
		Display(p->child[i]);//递归打印孩子结点，直到没有孩子结点
	   }
	}
	ShowNode(p);//输出孩子节点
	temp=p->sibling;
	if(temp!=NULL){
    	Display(temp);//打印兄弟节点
	}	
	return;		
}

void ShowNode(struct TreeNode *p)//显示某个节点
{
    p->lineno=Num++;
    TreeNode *temp =new TreeNode();
    cout<<p->lineno<<"    ";
	switch(p->nodekind)
	{
		case StmtK:
		{
			char *names[7] = {"If_statement,",  "While_statement," ,"Assign_statement," , "For_statement," , "Compound_statement,","Input_statement,","Print_statement," };
			cout<<names[p->kind]<<"     ";//可以直接从数组里面打印，一一对应
			break;
		}
			
		case ExpK:
		{
			char *names[4] = {"Expr," , "Const Declaration,", "ID Declaration,","Type Specifier," };
			char *types[3] = {"Void","Integer ","Char"};
				cout<<names[p->kind]<<"       ";
			switch( p->kind )
			{
				case OpK:
					{
					   switch(p->attr.op)
					   {
					       case PLUS:
					       {
					           cout<<"      op:+     ";
					           break;
					       }
					       case MINUS:
					       {
					          cout<<"      op:-     ";
					           break;
					       }
					       case TIMES:
					       {
					           cout<<"      op:*     ";
					           break;
					       }
					       case OVER:
					       {
					          cout<<"      op:/     ";
					           break;
					       }
					       case REMI:
					       {
					            cout<<"      op:%     ";
					           break;
					       }
					       case DPLUS:
					       {
					            cout<<"      op:++     ";
					           break;
					       }
					       case DMINUS:
					       {
					            cout<<"      op:--     ";
					           break;
					       }
					       case LT:
					       {
					          cout<<"      op:<     ";
					           break;
					       }
					       case LE:
					       {
					            cout<<"      op:<=     ";
					           break;
					       }
					       case GT:
					       {
					           cout<<"      op:>     ";
					           break;
					       }
					       case GE:
					       {
					            cout<<"      op:>=     ";
					           break;
					       }	
					       case EQ:
					       {
					           cout<<"      op:==     ";
					           break;
					       }
					       case NOT:
					       {
					            cout<<"      op:!=     ";
					           break;
					       }
					       case OR:
					       {
					            cout<<"      op:||     ";
					           break;
					           					       }
					       case AND:
					       {
					            cout<<"      op:&&     ";
					           break;
					       }
					   }
					   break;
					}
				case ConstK:
					{
						if(p->type==1)	cout<<"values:  "<<p->attr.val<<"   ";
						if(p->type==2)	cout<<"values:  "<<p->attr.zf<<"   ";
				break;
					}
				case IdK:
					{
					//将节点中的标志符信
				    	cout<<"symbol: "<<p->attr.name<<"  ";
						break;//字符
					}
				case TypeK:
					{
						cout<<"  "<<types[ p->type]<<"  ";
						break;//types[3]中存储的Integer
					}
			}
			break;
		}
		case DeclK:
		{
			char names[2][20] = { "Var Declaration, ", "other"};
			cout<<names[p->kind]<<"  ";
			break;//变量声明 int a,b;整体
		}
		
	}
	cout<<"children: ";
	for(int i=0;i<MAXCHILDREN;i++){
	    if(p->child[i] != NULL)
	    {
		    cout<<p->child[i]->lineno<<"  ";//输出所有孩子结点
		    temp = p->child[i]->sibling;
		
		    while(temp != NULL)//有兄弟打印兄弟节点
		    {
			   cout<<temp->lineno<<"  ";
			    temp = temp->sibling;
		    }
		
	    }
	}
	cout<<endl;
	return ;
}

int main(int argc,char*argv)
{
	int n = 1;
	mylexer lexer;
	myparser parser;
	if (parser.yycreate(&lexer)) {
		if (lexer.yycreate(&parser)) {
	   lexer.yyin=new std::ifstream("D:\\outputtest.txt");
			n = parser.yyparse();
		}
	}
	system("pause");
	return n;
}