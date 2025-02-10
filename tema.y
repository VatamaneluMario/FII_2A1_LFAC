%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
int fd;
int fd1;
char buffer[100];


struct node {

   char tip[100];
   char nume[100];
   int intval;
   char sir[100];
   float floatval;
   struct node *next;
};

struct node *head = NULL;
struct node *current = NULL;
struct node *headfct = NULL;
struct node *currentfct = NULL;

void insert(char tip[], char nume[],int intval, char sir[], float floatval) {

   if(find(nume)==1){printf("'%s' A FOST FOLOSIT DEJA MAN, SCHIMBA SI TU NUMELE CA NU I GREU (LINIA '%d') \n",nume,yylineno); }//exit(1);}
   else
   {
   struct node *link = (struct node*) malloc(sizeof(struct node));
	
   strcpy(link->tip,tip);
   strcpy(link->nume,nume);
   link->intval=intval;
   strcpy(link->sir,sir);
   link->floatval=floatval;

   link->next = head;
	
   head = link;
   }
}

void insertfct(char tip[], char nume[],int intval, char sir[], float floatval) {

   if(findfct(nume)==1){printf("'%s' A FOST FOLOSIT DEJA MAN, SCHIMBA SI TU NUMELE CA NU I GREU (LINIA '%d') \n",nume,yylineno); }//exit(1);}
   else
   {
   struct node *link = (struct node*) malloc(sizeof(struct node));
	
   strcpy(link->tip,tip);
   strcpy(link->nume,nume);
   link->intval=intval;
   strcpy(link->sir,sir);
   link->floatval=floatval;

   link->next = headfct;
	
   headfct = link;
   }
}


int delete(char nume[]) {

   struct node* current = head;
   struct node* previous = NULL;

   if(head == NULL) {
      return 0;
   }

   while(strcmp(current->nume,nume)!=0) {

      if(current->next == NULL) {
         return 0;
      } 
      else {
         previous = current;
         current = current->next;
      }
   }

   if(current == head) {
      head = head->next;
   } 
   else {
      previous->next = current->next;
   }    
	
   return 0;
}

int find(char nume[]) {

   struct node* current = head;

   if(head == NULL) {
      return NULL;
   }

   while(strcmp(current->nume,nume)!=0) {

      if(current->next == NULL) {
         return NULL;
      } else {
         current = current->next;
      }
   }      
	
   return 1;
}

int findfct(char nume[]) {

   struct node* currentfct = headfct;

   if(headfct == NULL) {
      return NULL;
   }

   while(strcmp(currentfct->nume,nume)!=0) {

      if(currentfct->next == NULL) {
         return NULL;
      } else {
         currentfct = currentfct->next;
      }
   }      
	
   return 1;
}

void printList() {
   struct node *ptr = head;
   printf("\n[ ");
	
   //start from the beginning
   while(ptr != NULL) {
      printf("(%s) ",ptr->nume);
      ptr = ptr->next;
   }
	
   printf(" ]");
}

void printListfct() {
   struct node *ptr = headfct;
   printf("\n[ ");
	
   //start from the beginning
   while(ptr != NULL) {
      printf("(%s) ",ptr->nume);
      ptr = ptr->next;
   }
	
   printf(" ]");
}


%}
%union {
int intval;
char* strval;
}
%token EV TO <strval>ID STARTCLASS ENDCLASS STARTFCT ENDFCT BGIN END CLASS <intval>NR String LOOP <strval>TIP <strval>ARRAYTYPE STARTSTR ENDSTR RET <strval>ASSIGN PLUS OR AND MULTIPLY DIVIDE MODULO MINUS DECL FUNC CTRL LOOPF LOOPW OPR; 

%type<intval>e


%left '+' '-'
%left '*' '/'
%start program


%%
program: structblock mainblock {printf("\nE CORECT SINTACTIC SEFULE, TE PWP\n");}
       ;

structblock: STARTSTR interior ENDSTR
           ;

interior: clase
        | functii
        | clase interior
        | functii interior
        ;

clase: STARTCLASS class ENDCLASS
	 ;

class: clasa
     | clasa class
     ;

clasa: CLASS ID '{' interior_clasa '}'
     ;

interior_clasa: DECL ':' var
		   | FUNC ':' fct
		   | DECL ':' var interior_clasa
		   | FUNC ':' fct interior_clasa
		   ;

fct: ID '(' TIP ID ')' { snprintf(buffer,100,"%s (%s %s) \n",$1,$3,$4); write(fd1, buffer, strlen(buffer));}
   | ID '(' ')' { snprintf(buffer,100,"%s() \n",$1); write(fd1, buffer, strlen(buffer));}
   | EV '(' TIP ID ')' { snprintf(buffer,100,"Eval (%s %s) \n",$3,$4); write(fd1, buffer, strlen(buffer));}
   | EV '(' ')' { snprintf(buffer,100,"Eval() \n"); write(fd1, buffer, strlen(buffer));}
   | TO '(' TIP ID ')' { snprintf(buffer,100,"TypeOf (%s %s) \n",$3,$4); write(fd1, buffer, strlen(buffer));}
   | TO '(' ')' { snprintf(buffer,100,"TypeOf() \n"); write(fd1, buffer, strlen(buffer));}
   ;

functii: STARTFCT func_block ENDFCT
	   ;

func_block: fct '{' int_func_block '}' {headfct = NULL; currentfct = NULL;}
		      | fct '{' int_func_block '}' {headfct = NULL; currentfct = NULL;} func_block 
		      ;

int_func_block: varfct
    | fct
    | RET NR
    | RET ID
    | varfct int_func_block
    | fct_main int_func_block
    | iffct
    | whilefct
    | forfct
    | iffct int_func_block
    | whilefct int_func_block
    | forfct int_func_block
    ;

mainblock: BGIN main END
         ;

main: var
    | fct
    | RET NR
    | RET ID
    | var main
    | fct_main main
    | if
    | while
    | for
    | if main
    | while main
    | for main
    ;

mainfct: varfct
    | fct
    | RET NR
    | RET ID
    | varfct mainfct
    | fct_main mainfct
    | iffct
    | whilefct
    | forfct
    | iffct mainfct
    | whilefct mainfct
    | forfct mainfct
    ;

fct_main: ID '(' ID ')' { snprintf(buffer,100,"%s (%s) \n",$1,$3); write(fd1, buffer, strlen(buffer));}
   | ID '(' ')' { snprintf(buffer,100,"%s() \n",$1); write(fd1, buffer, strlen(buffer));}
   ;

var: TIP ID {snprintf(buffer,100,"%s %s \n",$1,$2); write(fd, buffer, strlen(buffer)); insert($1,$2,0,"",0);}
   | TIP ID ASSIGN NR { snprintf(buffer,100,"%s %s %s %d \n",$1,$2,$3,$4); write(fd, buffer, strlen(buffer)); insert($1,$2,$4,"",0);}
   | TIP ID ASSIGN ID { snprintf(buffer,100,"%s %s %s %s \n",$1,$2,$3,$4); write(fd, buffer, strlen(buffer)); insert($1,$2,0,$4,0);} 
   | TIP ID ASSIGN '{' e '}' {snprintf(buffer,100,"%s %s %s %d\n",$1,$2,$3,$5); write(fd, buffer, strlen(buffer)); insert($1,$2,$5,"",0);}
   | TIP ID ',' var {snprintf(buffer,100,"%s %s \n",$1,$2); write(fd, buffer, strlen(buffer)); insert($1,$2,0,"",0);}
   | ARRAYTYPE ID ASSIGN { snprintf(buffer,100,"%s %s %s ",$1,$2,$3); write(fd, buffer, strlen(buffer));} '[' arrays ']' {write(fd, "\n", 1);}
   ;

varfct: TIP ID {snprintf(buffer,100,"%s %s \n",$1,$2); write(fd, buffer, strlen(buffer)); insertfct($1,$2,0,"",0);}
   | TIP ID ASSIGN NR { snprintf(buffer,100,"%s %s %s %d \n",$1,$2,$3,$4); write(fd, buffer, strlen(buffer)); insertfct($1,$2,$4,"",0);}
   | TIP ID ASSIGN ID { snprintf(buffer,100,"%s %s %s %s \n",$1,$2,$3,$4); write(fd, buffer, strlen(buffer)); insertfct($1,$2,0,$4,0);} 
   | TIP ID ASSIGN '{' e '}' {snprintf(buffer,100,"%s %s %s %d\n",$1,$2,$3,$5); write(fd, buffer, strlen(buffer)); insertfct($1,$2,$5,"",0);}
   | TIP ID ',' var {snprintf(buffer,100,"%s %s \n",$1,$2); write(fd, buffer, strlen(buffer)); insertfct($1,$2,0,"",0);}
   | ARRAYTYPE ID ASSIGN { snprintf(buffer,100,"%s %s %s ",$1,$2,$3); write(fd, buffer, strlen(buffer));} '[' arrays ']' {write(fd, "\n", 1);}
   ;


e : e '+' e   {$$=$1+$3;}
  | e '-' e   {$$=$1-$3;}
  | e '*' e   {$$=$1*$3;}
  | e '/' e   {$$=$1/$3;}
  | NR {$$=$1;}
  ;

arrays : array
       | array ',' arrays
       ;

array : NR { snprintf(buffer,100,"[%d] ",$1); write(fd, buffer, strlen(buffer));}
      | ID { snprintf(buffer,100,"[%s] ",$1); write(fd, buffer, strlen(buffer));}
      ;

if: CTRL '(' ID OPR ID ')' '{' main '}'
  | CTRL '(' NR OPR NR ')' '{' main '}'
  | CTRL '(' ID OPR NR ')' '{' main '}'
  | CTRL '(' NR OPR ID ')' '{' main '}'
  ;

for: LOOPF ID ':' NR ',' NR '{' main '}'
   | LOOPF ID ':' ID ',' NR '{' main '}'
   | LOOPF ID ':' NR ',' ID '{' main '}'
   | LOOPF ID ':' ID ',' ID '{' main '}'
   ;

while: LOOPW '(' ID OPR ID ')' '{' main '}'
     | LOOPW '(' NR OPR NR ')' '{' main '}'
     | LOOPW '(' ID OPR NR ')' '{' main '}'
     | LOOPW '(' NR OPR ID ')' '{' main '}'
     ;

iffct: CTRL '(' ID OPR ID ')' '{' mainfct '}'
  | CTRL '(' NR OPR NR ')' '{' mainfct '}'
  | CTRL '(' ID OPR NR ')' '{' mainfct '}'
  | CTRL '(' NR OPR ID ')' '{' mainfct '}'
  ;

forfct: LOOPF ID ':' NR ',' NR '{' mainfct '}'
   | LOOPF ID ':' ID ',' NR '{' mainfct '}'
   | LOOPF ID ':' NR ',' ID '{' mainfct '}'
   | LOOPF ID ':' ID ',' ID '{' mainfct '}'
   ;

whilefct: LOOPW '(' ID OPR ID ')' '{' mainfct '}'
     | LOOPW '(' NR OPR NR ')' '{' mainfct '}'
     | LOOPW '(' ID OPR NR ')' '{' mainfct '}'
     | LOOPW '(' NR OPR ID ')' '{' mainfct '}'
     ;


%%
int yyerror(char * s){
printf("EROARE BOSS: %s LA LINIA:%d , FII MAI ATENT BRO\n",s,yylineno);
}

int main(int argc, char** argv){
fd = open ("symbol_table.txt", O_RDWR);
fd1= open ("symbol_table_functions.txt", O_RDWR);
yyin=fopen(argv[1],"r");
yyparse();

} 