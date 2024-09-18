int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}


int length(char *str) {
  int i;
  for (i = 0; str[i] != '\0' && str[i] != '\n'; i++) {}
  return i;
}

int power(int base, int exp) {
  int result = 1;
  for (int i = 0; i < exp; i++) {
    result *= base;
  }
  return result;
}

int toDec(char *oldBase, int base) {
  int intDec = 0, number = 0;

  for (int i = 3; i >= 0; i--) {
    number = oldBase[i] - 48;
    intDec += number * power (base, (3 - i));
  }

  return intDec;
}


void hexCode(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

int pack(char *input) {

  int result = 0b0;

  for (int i = 0; i < 5; i++) {
    int signal = input[24 - 6*i] == '-' ? 1 : 0;
    int val = toDec(&input[25 - 6*i], 10);
    int aux = 0b0, mask = 0b0;

    val = signal ? (~val + 1) : val;

    switch (i) {
      case 0:
        mask = 0b11111111111;
        aux = mask & val;
        result |= aux;
        result <<= 5;
        break;

      case 1:
        mask = 0b11111;
        aux = mask & val;
        result |= aux;
        result <<= 5;
        break;

      case 2:
        mask = 0b11111;
        aux = mask & val;
        result |= aux;
        result <<= 8;
        break;

      case 3:
        mask = 0b11111111;
        aux = mask & val;
        result |= aux;
        result <<= 3;
        break;

      case 4:
        mask = 0b111;
        aux = mask & val;
        result |= aux;
        break;

      default:
        break;
    }
  }

  return result;
}


int main() {
  char input[30];
  /* Read up to 20 bytes from the standard input into the str buffer */
  int n = read(0, input, 30);
  
  int val = pack(input);
  hexCode(val);

  return 0;
}