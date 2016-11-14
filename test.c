#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main(int argc, char* argv[])
{
  bool testBool = atoi(argv[1]);

  if (testBool == true)
    printf("Success!\n");
  else
    printf("Fuck.\n");


    return 0;
}
