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
int main()
{
  char a[101];
  char b[101];
  char c[101];
  char* p_a=&a[0];
  char* p_b=&b[0];
  char* p_c=&c[0];
  
  //get input strings;
  cout<<"please input two strings!"<<endl;
  cin.getline(p_a,101,'\n');
  cin.getline(p_b,101,'\n');

  size_t len_a=get_length(p_a);
  size_t len_b=get_length(p_b);

  //check if input string is valid;
  if(len_b>len_a)
  {
    cout<<"wrong input,str2 is longer than str1"<<endl;
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
  cout<<"Not Found"<<endl;
  return -1;
}

}
