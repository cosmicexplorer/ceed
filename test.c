#include <stdio.h>

int main()
{
  /* struct a { */
  /*   int b; */
  /* }; */
  /* union a { */
  /*   int b; */
  /* }; */
  enum a { asdf };
  enum a e_var = 0;
  typedef int a;
  typedef int asdf;
  a b = 3;
  asdf c = 4;
  printf("%d\n", b);
  printf("%d\n", e_var);
  printf("%d\n", c);
}
