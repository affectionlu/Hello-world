%{
#include <iostream>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>
#include<fstream>
#include "mylexer.h"
enum {StmtK,ExpK,DeclK};//���ֻ����ڵ�����
enum {IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK};//stmt��������
enum {OpK,ConstK,IdK,TypeK};//���ʽ�ӽڵ�����
enum {VarK};//��������
enum {Void,Integer,Char,Boolean};//����
#define MAXCHILDREN 4//��ຢ����
int line=0;
int Num=0;//��ShowNode��������
struct TreeNode
   { 
	struct TreeNode * child[MAXCHILDREN];
     struct TreeNode * sibling;//�ֵܽڵ� ����idlist�а�����id ��stmtlist�а�����stmt,û�н���ʵ�ʵĸ�������
     int lineno;
     int nodekind;                      //�����ڵ����� stmt exp decl
	 //���ʽ(Expression)�������(operator)�Ͳ�����(operand)�����ɵ�����
	 //���(Statement)���� IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
	 //����(Declarations)
	 
     int kind;                     //kind ��stmt��˵������ IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
     
	                                    //kind ��exp��˵������OpK����������,ConstK��������,IdK����־����,TypeK������           
                                        //��Ӧ�����"Expr," , "Const Declaration,", "ID Declaration,","Type Specifier," �Ľڵ���
                                        
                                        //kind��decl��˵ֻ����VarK  ��������
     union{ int op;                     //�������ʽ������
             char* zf;
             int val;                         //�������ʽ����
           char *name; }attr;         //�������ʽ��־��
     int type;                              //���ڱ��ʽ����       �Լ���䷵������
   } ;
TreeNode * newStmtNode(int kind)        //�½�һ�����ڵ�
//kind ������ IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK
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
void Display(struct TreeNode *p);		//��ʾ�﷨��
void ShowNode(struct TreeNode *p);		//��ʾĳ���ڵ�
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
start		:MAIN LP RP comp_stmt//main������������
			{ 
			    $$ = $4;
				Display($4);//�Ե����Ϲ����﷨���������ڵ��γɣ��﷨��������ɣ���ʾ
			}
			;
comp_stmt	:LFP  stmt_list RFP//{�������ʽ}
			{	
				$$ = newStmtNode(CompK);//�����µ����ڵ㣺������䡣
				$$->child[0]=$2;
			}
			;
stmt_list	:stmt stmt_list	   //�ݹ�		
			{
				$$->sibling=$2;//list�ڲ����ֵܽڵ�����
				$$= $1;		
			}
			|stmt						
			{
				$$ = $1 ;
			}
			;
stmt		:var_dec	//������ʽ���ͣ��������������ʽ��if��for��while��������				
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
id_list		:exp COMMA id_list//���ʽ�����ʽ
			{
				$$ = $1;
				$$->sibling=$3;
			}
			|exp
			;			             
var_dec		:type_spec id_list SEMI//�������� int/char a=/a;
			{	
				$$ = newDeclNode (VarK);//����һ���µı��������Ľڵ�
				$$->child[0]=$1;
				$$->child[1]=$2;
			}
			;

if_stmt     :IF LP exp RP stmt //if(���ʽ�� ���
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
      
            | IF LP exp RP  stmt ELSE stmt//if�����ʽ����� else ���
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                   $$->child[2] = $7;
                 }
            ;
for_stmt	:FOR LP exp SEMI exp SEMI exp RP stmt//for(exp;exp;exp)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $5;
                $$->child[2] = $7;
                $$->child[3] = $9;
			}
			|FOR LP SEMI exp SEMI exp RP stmt//for(;exp;exp)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $4;
                $$->child[1] = $6;
                $$->child[2] = $8;
			}
			|FOR LP exp SEMI SEMI exp RP stmt//for(exp;;exp)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $6;
                $$->child[2] = $8;
			}
			|FOR LP exp SEMI exp SEMI RP stmt//for(exp;exp;)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $5;
                $$->child[2] = $8;
			}
			|FOR LP SEMI SEMI exp RP stmt//for(;;exp)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $5;
                $$->child[1] = $7;
			}
			|FOR LP SEMI exp SEMI RP stmt//for(;exp;)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $4;
                $$->child[1] = $7;
			}
			|FOR LP exp SEMI SEMI RP stmt//for(exp;;)���
			{
				$$ = newStmtNode(ForK);
				$$->child[0] = $3;
                $$->child[1] = $7;
			}
			|FOR LP SEMI SEMI RP stmt//for(;;)���
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
exp_stmt	:exp SEMI		//���ʽ��䣻
			{
				$$ = $1;
			}
			|SEMI
			;
//���ʽ������ֵ�������������ϵ
exp			:exp ASSIGN exp//���� a=b+c
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
 //��ϵ���ʽ
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
void Display(struct TreeNode *p)//��ʾ�﷨��
{
    TreeNode *temp =new TreeNode();
    for(int i=0;i<MAXCHILDREN;i++){
	   if(p->child[i] != NULL)
	   {
		Display(p->child[i]);//�ݹ��ӡ���ӽ�㣬ֱ��û�к��ӽ��
	   }
	}
	ShowNode(p);//������ӽڵ�
	temp=p->sibling;
	if(temp!=NULL){
    	Display(temp);//��ӡ�ֵܽڵ�
	}	
	return;		
}

void ShowNode(struct TreeNode *p)//��ʾĳ���ڵ�
{
    p->lineno=Num++;
    TreeNode *temp =new TreeNode();
    cout<<p->lineno<<"    ";
	switch(p->nodekind)
	{
		case StmtK:
		{
			char *names[7] = {"If_statement,",  "While_statement," ,"Assign_statement," , "For_statement," , "Compound_statement,","Input_statement,","Print_statement," };
			cout<<names[p->kind]<<"     ";//����ֱ�Ӵ����������ӡ��һһ��Ӧ
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
					//���ڵ��еı�־����
				    	cout<<"symbol: "<<p->attr.name<<"  ";
						break;//�ַ�
					}
				case TypeK:
					{
						cout<<"  "<<types[ p->type]<<"  ";
						break;//types[3]�д洢��Integer
					}
			}
			break;
		}
		case DeclK:
		{
			char names[2][20] = { "Var Declaration, ", "other"};
			cout<<names[p->kind]<<"  ";
			break;//�������� int a,b;����
		}
		
	}
	cout<<"children: ";
	for(int i=0;i<MAXCHILDREN;i++){
	    if(p->child[i] != NULL)
	    {
		    cout<<p->child[i]->lineno<<"  ";//������к��ӽ��
		    temp = p->child[i]->sibling;
		
		    while(temp != NULL)//���ֵܴ�ӡ�ֵܽڵ�
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