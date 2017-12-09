%{
#include <iostream>
#include <ctype.h>
#include <stdio.h>
#include <cstring>
#include <malloc.h>
#include <stdlib.h>

#include "myparser.h"

enum {StmtK,ExpK,DeclK};
enum {IfK,WhileK,AssignK,ForK,CompK,InputK,PrintK};          //语句类型
enum {OpK,ConstK,IdK,TypeK};
enum {VarK};
enum {Void,Integer,Char,Boolean};//类型
char hashtable[1000][10];//hash 符号表  就是一个字符串数组
int storeid(char *text);
int gethash(char*str);
#define MAXCHILDREN 4
char *Id=new char[10];                         //yytext的拷贝，用于符号表的插入
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
}temp;//用来将当前
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
//<INITIAL> “/*”     {BEGIN c_comment;}  
//<c_comment>“*/”   {BEGIN 0;}  
//<c_comment>.      {;}  
//对于id的处理
{identifier}	{	
                    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//ID节点
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;//初始化孩子结点为空
                    t->sibling = NULL;
                    t->nodekind = ExpK;//用到id和num的只有表达式（所属大类）
                    t->kind = IdK;//在exp中的类型
                    t->lineno = line++;
                    t->type = Void;
                   strcpy(hashtable[storeid(yytext)],yytext);//在hash表中保存id名
                    t->attr.name=new char[10];//在树中保存id名
                   strcpy(t->attr.name,yytext);
					yylval = t;//保存全局变量
					return ID;
									}
				
{num}			{	TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//number节点
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
                    t->sibling = NULL;
                    t->nodekind = ExpK;//用到id和num的只有表达式
                    t->kind = ConstK;
                    t->lineno = line++;
                    t->type = Integer;
			        t->attr.val=getNUM(yytext,yyleng);	
			        yylval =t;	
					return NUM;
				}
{zf}             {
                     TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));//字符节点
                    for (int i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
                    t->sibling = NULL;
                    t->nodekind = ExpK;//用到字符的只有表达式
                    t->kind = ConstK;
                    t->lineno = line++;
                    t->type = Char;
			          t->attr.zf=new char[10];//在树中保存id名
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
    int index =gethash(Id)%1000;//index:id在符号表中的位置	
    if(hashtable[index][0]=='\0')	//如果不存在该变量
    {
        strcpy(hashtable[index],Id);//创建该变量
    }
    else{
        while(hashtable[index][0]!='\0'&&strcmp(Id,hashtable[index])!=0)//index不为空且id数组和index下标不相等
//找没有用过的index，防止溢出 
          {
            index++;
          }
    if(hashtable[index][0]=='\0')
    {
     strcpy(hashtable[index],Id);//找到空位在该位置创建
    }
        }
    return index;
}
int gethash(char* str)
{
    int hash = 0;  
    for (int i=0;str[i]!='\0';i++)//依次读入id直到遇到结束符
    {
        hash=hash+str[i]-'a';//ASC码减去a得到返回位置
    }
    return hash;  
}
//将yytext转化为数字
int getNUM(char *text,int leng){
    int value=0;
    for(int i=0;i<leng;i++)
    {
        value=value*10+*text-'0';//把字节变成数
        text++;
    }
    return value;
}

