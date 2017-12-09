%{
#include <iostream>
#include <ctype.h>
#include <stdio.h>
#include <cstring>
#include <malloc.h>
#include <stdlib.h>

#include "myparser.h"

enum {StmtK,ExpK,DeclK};
enum {IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK};          //�������
enum {OpK,ConstK,IdK,TypeK};
enum {VarK};
enum {Void,Integer,Char,Boolean};//����
char hashtable[1000][10];//hash ���ű�  ����һ���ַ�������
int storeid(char *text);
int gethash(char*str);
#define MAXCHILDREN 4
char *Id=new char[10];                         //yytext�Ŀ��������ڷ��ű��Ĳ���
struct TreeNode
   { 
	struct TreeNode * child[MAXCHILDREN];
     struct TreeNode * sibling;
     int lineno;
     int nodekind;
     int kind;
     union{ int op;
       char* zf;
             int val;
           char *name; }attr;
 
     int type;/* for type checking of exps */ 
   } ;
   struct item
{
char *name;
int  type;
int value;
}temp;//��������ǰ
int getNUM(char *text,int leng);
extern YYSTYPE yylval;
extern int line;
%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

// lexical analyser name
%name mylexer

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
//%s COMMENTA
//%s COMMENTB
// place any declarations here
digit		[0-9]
num			{digit}+
newline     [\n]+
letter		[_A-Za-z]
identifier	{letter}({letter}|{digit})*
WS			[ \t\n]*
ZSA  "//"[^\n]*
ZSB  "/*"[^*]*[*]+([^*/][^*]*[*]+)*[*]*"/"  
zf '[A-Za-z]' 
%%

/////////////////////////////////////////////////////////////////////////////
// rules section

%{
	// extract yylval for use later on in actions
	YYSTYPE YYFAR& yylval = *(YYSTYPE YYFAR*)yyparserptr->yylvalptr;
%}

// place your Lex rules here
"if"			    {return IF;}
"else"			  {return ELSE;}
"for"			  {return FOR;}
"while"		    {return WHILE;}
"void"			{return VOID;}
"int"			  {return INT;}
"char"			{return CHAR;}
"input"        {return INPUT;}
"print"         {return PRINT;}
"main"		   {return MAIN;}
"+"			     {return PLUS;}	
"-"			      {return MINUS;}
"*"		          {return TIMES;}
"/"			      {return OVER;}
"%"			    {return REMI;}
"++"		   {return DPLUS;}
"--"			 {return DMINUS;}
">="		   {return GE;}
"<="		   {return LE;}
">"			     {return GT;}
"<"			     {return	LT;}
"!="			 {return NEQ;}
"&&"          {return AND;}
"||"               {return OR;}
"!"                {return NOT;}
"=="		   {return EQ;}
"="			     {return ASSIGN;}
","			       {return COMMA;}
";"			       {return SEMI;}		
"("			       {return LP;} 
")"			       {return RP;}
"{"		           {return LFP;} 
"}"			       {return RFP;}
{WS}			{/*do nothing*/}
{ZSA}             {}
{ZSB}             {}
//"//"              {
//                       cout<<" fucker";
//                      BEGIN COMMENTA;
 //                     }
//"/*"              {BEGIN COMMENTB;}
//<COMMENTA>\n     {BEGIN  INITIAL;}
//<COMMENTA>.         {}
//<COMMENTB>"*/"   {BEGIN  INITIAL;}
//<COMMENTB>.         {}
//<INITIAL> ��/*��     {BEGIN c_comment;}  
//<c_comment>��*/��   {BEGIN 0;}  
//<c_comment>.      {;}  
//����id�Ĵ���
{identifier}	{	
                    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//ID�ڵ�
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;//��ʼ�����ӽ��Ϊ��
                    t->sibling = NULL;
                    t->nodekind = ExpK;//�õ�id��num��ֻ�б���ʽ���������ࣩ
                    t->kind = IdK;//��exp�е�����
                    t->lineno = line++;
                    t->type = Void;
                   strcpy(hashtable[storeid(yytext)],yytext);//��hash���б���id��
                    t->attr.name=new char[10];//�����б���id��
                   strcpy(t->attr.name,yytext);
					yylval = t;//����ȫ�ֱ���
					return ID;
									}
				
{num}			{	TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//number�ڵ�
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
                    t->sibling = NULL;
                    t->nodekind = ExpK;//�õ�id��num��ֻ�б���ʽ
                    t->kind = ConstK;
                    t->lineno = line++;
                    t->type = Integer;
			        t->attr.val=getNUM(yytext,yyleng);	
			        yylval =t;	
					return NUM;
				}
{zf}             {
                     TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//�ַ��ڵ�
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
                    t->sibling = NULL;
                    t->nodekind = ExpK;//�õ��ַ���ֻ�б���ʽ
                    t->kind = ConstK;
                    t->lineno = line++;
                    t->type = Char;
			          t->attr.zf=new char[10];//�����б���id��
                   strcpy(t->attr.zf,yytext);
			        yylval =t;	
					return ZIFU;
					}
%%

/////////////////////////////////////////////////////////////////////////////
// programs section
int storeid(char *text);
int gethash(char*str);
int storeid(char *text)
{
   strcpy(Id,text);
    int index =gethash(Id)%1000;//index:id�ڷ��ű��е�λ��	
    if(hashtable[index][0]=='\0')	//��������ڸñ���
    {
        strcpy(hashtable[index],Id);//�����ñ���
    }
    else{
        while(hashtable[index][0]!='\0'&&strcmp(Id,hashtable[index])!=0)//index��Ϊ����id�����index�±겻���
//��û���ù���index����ֹ��� 
          {
            index++;
          }
    if(hashtable[index][0]=='\0')
    {
     strcpy(hashtable[index],Id);//�ҵ���λ�ڸ�λ�ô���
    }
        }
    return index;
}
int gethash(char* str)
{
    int hash = 0;  
    for (int i=0;str[i]!='\0';i++)//���ζ���idֱ������������
    {
        hash=hash+str[i]-'a';//ASC���ȥa�õ�����λ��
    }
    return hash;  
}
//��yytextת��Ϊ����
int getNUM(char *text,int leng){
    int value=0;
    for(int i=0;i<leng;i++)
    {
        value=value*10+*text-'0';//���ֽڱ����
        text++;
    }
    return value;
}
