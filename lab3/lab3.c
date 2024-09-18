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


#define STDIN_FD  0
#define STDOUT_FD 1


void initializateStrings(char *bin, char *dec, char *decSwaped, char *hex, char *hexSwaped) {
  for (int i = 0; i < 34; i++) {
    bin[i] = '0';
  }
  bin[1] = 'b';
  bin[34] = '\n';
  bin[35] = '\0';

  for (int j = 0; j < 11; j++) {
    dec[j] = '0';
    decSwaped[j] = '0';
  }
  dec[11] = '\n';
  dec[12] = '\0';
  
  decSwaped[11] = '\n';
  decSwaped[12] = '\0';

  for (int k = 0; k < 10; k++) {
    hex[k] = '0';
    hexSwaped[k] = '0';
  }
  hex[1] = 'x';
  hex[10] = '\n';
  hex[11] = '\0';

  hexSwaped[1] = 'x';
  hexSwaped[10] = '\n';
  hexSwaped[11] = '\0';
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

unsigned int swapEndian(char *hex, char *hexSwaped) {
  int strLength = length(hex);

  for (int i = 2; i < strLength; i++) {
    hexSwaped[i] = hex[strLength - i + 1];
  }

  for (int i = 2; i <= 8; i += 2) {
    char temp = hexSwaped[i+1];
    hexSwaped[i+1] = hexSwaped[i];
    hexSwaped[i] = temp;
  }

  unsigned int intDec = 0;
  int number = 0;

  for (int i = 9; hexSwaped[i] != 'x'; i--) {
    if (hexSwaped[i] < 97) {
      number = hexSwaped[i] - 48;
    } else {
      number = hexSwaped[i] - 87; 
    }
    intDec += number * power (16, (9-i));
  }

  return intDec;
}

void twoComplement(char *bin) {
  for (int i = 2; i < 34; i++) { // one's complement
    if (bin[i] == '1') {
      bin[i] = '0';
    } else {
      bin[i] = '1';
    }
  }

  // adding 1 to get two's complement
  if (bin[33] == '1') {
    bin[33] = '0';
    int carry = 1;

    for (int j = 32; bin[j] != 'b'; j--) {
      if (bin[j] == '1' && carry) {
        bin[j] = '0';
      } else if (bin[j] == '1' && !carry){
        break;
      } else {
        bin[j] = '1';
        carry = 0;
        break;
      }
    }
  } else {
    bin[33] = '1';
  }
  
}

int firstNonZero(char *str) {
  int i, strLength = length(str);
  for (i = 0; i < strLength; i++) {
    if (str[i] != '0') {
      return i;
    }
  }
  return --i;
}

char hexDigit(char *bin) {
  int intDec = 0;

  for (int i = 3; i >= 0; i--) {
    intDec += (bin[i] - 48) * power(2, 3 - i);
  }

  char digit;
  if (intDec <= 9) {
    digit = '0';
  } else {
    intDec -= 10;
    digit = 'a';
  }
  return digit + intDec;
}


int toDec(char *oldBase, int base) {
  int intDec = 0, number = 0, oldBaseLength = length(oldBase);

  for (int i = oldBaseLength - 1; (oldBase[i] != 'x' && oldBase[i] != 'b') && i >= 0; i--) {
    if (oldBase[i] < 97) {
      number = oldBase[i] - 48;
    } else {
      number = oldBase[i] - 87; 
    }
    intDec += number * power (base, (oldBaseLength - 1 -i));
  }

  return intDec;

}

void fromDec(int intDec, char *newBase, int base) {
  int rest, i = 0, newBaseLength = length(newBase);

  int signal = intDec < 0 ? 1 : 0;

  while (intDec != 0) {
    rest = intDec % base;
    rest *= rest < 0 ? (-1) : 1;
    newBase[newBaseLength - 1 - i] = rest + '0';
    intDec /= base;
    i++;
  }

  if (signal && base == 10) {
    newBase[newBaseLength - 1 - i] = '-';
  }
}

void binToHex(char *bin, char *hex){
  int index = 9;
  for (int i = 30; i >= 0; i -= 4) {
    char digit = hexDigit(&bin[i]);
    hex[index] = digit;
    index--;
  }  
}


void output(char *bin, char *dec, char *hex, char *decSwaped) {
  char output[100];

  int i, temp, index;
  
  index = firstNonZero(&bin[2]);
  index += 2;

  output[0] = '0';
  output[1] = 'b';
  
  for (i = 2; bin[index - 2 + i] != '\0'; i++) {
    output[i] = bin[index - 2 + i];
  }
  output[i++] = '\n';
  
  index = firstNonZero(dec);

  for (temp = i; dec[index - temp + i] != '\0'; i++) {
    output[i] = dec[index - temp + i];
  }
  output[i++] = '\n';

  index = firstNonZero(&hex[2]);
  index += 2;

  output[i++] = '0';
  output[i++] = 'x';

  for (temp = i; hex[index - temp + i] != '\0'; i++) {
    output[i] = hex[index - temp + i];
  }
  output[i++] = '\n';

  index = firstNonZero(decSwaped);

  for (temp = i; decSwaped[index - temp + i] != '\0'; i++) {
    output[i] = decSwaped[index - temp + i];
  }
  output[i++] = '\n';
  output[i] = '\0';

  /* Write n bytes from the str buffer to the standard output */
  write(STDOUT_FD, output, i);
}


int main() {
  char str[20];
  /* Read up to 20 bytes from the standard input into the str buffer */
  int n = read(STDIN_FD, str, 20);

  int strLength = length(str);

  char bin[36];

  char dec[13];
  int intDec = 0;

  char decSwaped[13];
  unsigned int intDecSwaped = 0;

  char hex[12];
  char hexSwaped[12];

  initializateStrings(bin, dec, decSwaped, hex, hexSwaped);
  
  if (strLength >= 2 && str[1] == 'x') { /*str is in hexadecimal format*/
    
    intDec = toDec(str, 16); // converting hexadecimal to decimal

    fromDec(intDec, bin, 2); // conversion from decimal to binary
    intDec < 0 ? twoComplement(bin) : 0; // take the two's complement if the number is negative
    
    intDecSwaped = swapEndian(str, hexSwaped); // number with endian swaped

    int j = 0;
    for (int i = strLength - 1; str[i] != 'x'; i--) { // copying the str to hex
      hex[9 - j] = str[i];
      j++;
    }

    fromDec(intDec, dec, 10); // int to string

  } else if (str[0] == '-'){ /*str is a negative number in decimal format*/
    
    intDec = toDec(&str[1], 10); // converting a string to an int

    fromDec(intDec, bin, 2); // from decimal to binary
    twoComplement(bin);
    
    binToHex(bin, hex); // binary to hexadecimal
    
    intDecSwaped = swapEndian(hex, hexSwaped);

    int j = 0;
    for (int i = strLength - 1; i >= 0; i--) { // copying the str to dec
      dec[10 - j] = str[i];
      j++;
    }
  
  } else { /*str is a positive number in decimal format*/

    intDec = toDec(str, 10);

    fromDec(intDec, bin, 2); // from decimal to binary

    binToHex(bin, hex); // from binary to hexadecimal

    intDecSwaped = swapEndian(hex, hexSwaped);

    int j = 0;
    for (int i = strLength - 1; i >= 0; i--) { // copying the str to dec
      dec[10 - j] = str[i];
      j++;
    }

  }

  int i = 0;
  while (intDecSwaped > 0) {
    int rest = intDecSwaped % 10;
    decSwaped[10 - i] = rest + '0';
    intDecSwaped /= 10;
    i++;
  }

  output(bin, dec, hex, decSwaped);
  
  return 0;
}
