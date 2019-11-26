/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////
// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;
int rows=0;// nr of words in a row
int nr_rows;//nr of rows
int flag=0; // variable to check if i have a match
int index=0;//nr of overrall indexes
int x; // x-coordinate
int y; // y-coordinate

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
int containH(char *string, char *word)
{ 
  int a=0;
  while (1) {
    if(*string=='\n') string-=rows/nr_rows-1;  // if i have reached end of row go to first letter in the row
    if (*string != *word){
      return (*word == '\n');
    }
    if (a==rows/nr_rows-1) break;           // this is a routine check to prevent multiple wraparounds

    string++;                              // get next char in grid
    word++;                                // get next char in dictionary
  }

  return 0;
}


int containV(char *string,char *word,int row,int idx){
 
  
  while (1) {
    if (*string != *word) {
      return (*word == '\n'); 
    }
    if(idx+(rows/nr_rows) >=(rows/nr_rows)*(nr_rows)){ 
    
    idx-=(rows/nr_rows)*row;         // IF I AM ON THE LAST ROW GO BACK TO FIRST ROW
      string-=(rows/nr_rows)*row;
       row=0;
       word++;
    }
    else {
      string+=(rows/nr_rows);           // OTHERWISE GO TO NEXT ROW
       idx+=(rows/nr_rows);
       word++;
       row++;
    }
    
    
    
   
    
  }

  return 0;
}
int containD(char *string, char *word,int row,int idx,int x1)
{
  while (1) {
   if (*string != *word) {
      return (*word == '\n'); 
    }
    if(idx+(rows/nr_rows)+1<(rows/nr_rows)*(nr_rows)){  // if i am not in the last column
     if(x1==(rows/nr_rows)-2){              // if i am in the last column go back diagonally until i find first row or column
       while(row!=0 && x1!=0){
         row--;
         x1--;
         string-=(rows/nr_rows)+1;
         idx-=(rows/nr_rows)+1;

       }
       word++;
     }
    else{                                // if i am not in the last column just go diagonally updating accordingly the components
    string+=(rows/nr_rows)+1;
       idx+=(rows/nr_rows)+1;
       word++;
       row++;
       x1++;
    }}
    else {
       while(x1!=0 && row!=0){          // if i am in the last row go back diagonally until i find first row or column
       idx-=(rows/nr_rows)+1;
       string-=(rows/nr_rows)+1;
       row--;
       x1--;
       }

       word++;
    }
    
}
  return 0;
}

// this functions finds the first match in the grid
void strfind()
{

  int idx = 0;
  int grid_idx = 0;
  char *word;
  int y=-1;
  while(grid[grid_idx]!='\0'){
   y++;
   int x=0;
  while (grid[grid_idx] != '\n') {
    for(idx = 0; idx < dict_num_words; idx ++) {
      word = dictionary + dictionary_idx[idx];
      
      if (containH(grid + grid_idx, word)) {
        print_int(y);
        print_char(',');
        print_int(x);
        print_char(' ');
        print_char('H');
        print_char(' ');
        print_word(word);
        print_char('\n');
        flag=1;
      }
      if (containV(grid+grid_idx, word,y,grid_idx)) {
        print_int(y);
        print_char(',');
        print_int(x);
        print_char(' ');
        print_char('V');
        print_char(' ');
        print_word(word);
        print_char('\n');
        flag=1;
      }
     if (containD(grid + grid_idx, word,y,grid_idx,x)) {
        print_int(y);
        print_char(',');
        print_int(x);
        print_char(' ');
        print_char('D');
        print_char(' ');
        print_word(word);
        print_char('\n');
        flag=1;
      }
    }
    x++;
    grid_idx++;
    if(grid[grid_idx]=='\0') break;
  }
  grid_idx++;
  }
  if(flag==0)  print_string("-1\n");
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  int dict_idx = 0;
  int start_idx = 0;

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);
  
  // closing the grid file
  fclose(grid_file);
  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////

  // storing the starting index of each word in the dictionary
  idx = 0;
  do {
    c_input = dictionary[idx];
    if(c_input == '\0') {
      break;
    }
    if(c_input == '\n') {
      dictionary_idx[dict_idx ++] = start_idx;
      start_idx = idx + 1;
    }
    idx += 1;
  } while (1);

  idx=0;
  nr_rows=0;
    do {
    c_input = grid[idx];
    if(c_input == '\0') {
      break;
    }
    if(c_input == '\n') {
      nr_rows++;
    }
    idx += 1;
    rows++;
  } while (1);





  dict_num_words = dict_idx;

  strfind();

  return 0;
}
