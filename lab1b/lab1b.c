int read(int __fd, const void *__buf, int __n) {
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)                   // Output list
    : "r"(__fd), "r"(__buf), "r"(__n) // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n) {
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :                                   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code) {
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :             // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

/* Buffer to store the data read */
char input_buffer[10];

int main() {
  int n = read(0, (void*) input_buffer, 10);

  char sp1, op, sp2;
  sp1 = input_buffer[0];
  op = input_buffer[2];
  sp2 = input_buffer[4];
  
  int result = 0;

  switch (op) {
  case '+':
  result = (sp1 - '0') + (sp2 - '0');
    break;

  case '-':
  result = (sp1 - '0') - (sp2 - '0');
    break;

  case '*':
  result = (sp1 - '0') * (sp2 - '0');
    break;
  
  default:
    break;
  }

  input_buffer[0] = result + '0';
  input_buffer[1] = '\n';

  write(1, (void*) input_buffer, 2);

  return 0;
}

void _start() {
  int ret_code = main();
  exit(ret_code);
}
