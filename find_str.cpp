#include <iostream>
using namespace std;
inline size_t get_length(char* p)
{
  int i=0;
  while(*p!='\0')
  {
    i++;
	p++;
  }
  return i;
}
inline void strip_space_ht(char* a)
{
   char *p=a;
   char c[101];
   char* begin;//begin:inclusive,end:exclusive
   char* end;
   while(*p==' ')
    p++;
   begin=p;
   while(*p!='\0')
	 p++;
   p--;
   while(*p==' ')
    p--;
   end=p+1;
   char * temp=begin;
   int i=0;
   for(;temp!=end;temp++,i++)
   {
	   c[i]=*temp;
   }
   c[i]='\0';
   for(i=0;c[i]!='\0';i++)
   {
     a[i]=c[i];
   }
   a[i]='\0';

}
int main()
{
  char a[101];
  char b[101];
  char c[101];
  char* p_a=&a[0];
  char* p_b=&b[0];
  char* p_c=&c[0];
  
  //get input strings;
  cin.getline(p_a,101,'\n');
  cin.getline(p_b,101,'\n');

  size_t len_a=get_length(p_a);
  size_t len_b=get_length(p_b);
  

  //check if input string is valid;
  if(len_b>len_a)
  {
    cout<<"Not found"<<endl;
	return -1;
  }

  char* p_temp;

  while(*p_a!='\0')
  {
     if(*p_a==*p_b)
	 {
	    p_temp=p_b;
        while(*p_b!='\0')
	   { 
         if(*p_a!=*p_b)
		 {
		   p_b=p_temp;
		   p_a--;
		   break;
		 }
		 p_a++,p_b++;
	   }
		if(*p_b=='\0')
		{
		  p_temp=p_a;
		  break;
		}
	 }
		
	  p_a++;
  }

if(*p_b=='\0')
{
  while(len_b>0)
  {
    p_temp--;
	len_b--;
  }
  if(p_temp==&a[0])
	cout<<a<<endl;
  else
  {
     p_a=&a[0];
	 while(p_a!=p_temp)
	 {
	   cout<<*p_a;
	   p_a++;

	 }
	 cout<<endl;
  }
  return 0;
}
else
{
  cout<<"Not found"<<endl;
  return -1;
}

}
