#include <stdio.h>
#include <stdlib.h>

char * str = "hey\n";

void f()
{
  int a;
  scanf("%d", &a);
  switch (a) {
  case 3:
    printf("hello\n");
    break;
  default:
    printf("sup\n");
  }
}

int main()
{
  int * b = malloc(sizeof(int));
  f();
  int c = 1;
  c |= 512;
  printf("%d\n", c);
  printf("%s\n", str);
  return 0;
}
