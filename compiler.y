%{
	using namespace std;
	#include <iostream>
	#include <string.h>
	#include <limits>

    extern FILE *yyin;

	int yylex();
	int yyerror(const char *msg);

    int EsteCorecta = 1;
	char msg[500];
	int block = 0;
	bool if_exp = false;
	int ifFlag = 0;
	int elseFlag = 0;
	bool whileFlag=false;

	class TVAR
	{
	     char* nume;
	     double valoare;
	     TVAR* next;
		 int myblock;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, double v = -1);
	     TVAR();
	     int exists(char* n);
         void add(char* n, double v = -1);
         double getValue(char* n);
	     void setValue(char* n, double v);
		 void printVars();

    	void deleteVariablesInBlock();
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, double v)
	{
		this->nume = new char[strlen(n)+1];
		strcpy(this->nume,n);
		this->valoare = v;
		this->next = NULL;
		this->myblock=block;
	}

	TVAR::TVAR()
	{
		TVAR::head = NULL;
		TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
		TVAR* tmp = TVAR::head;
		while(tmp != NULL) 
		{ 
			if(strcmp(tmp->nume,n) == 0)
	      		return 1;
        	tmp = tmp->next;
	  	}
	  	return 0;
	}

    void TVAR::add(char* n, double v)
	{
		TVAR* elem = new TVAR(n, v);
		if(TVAR::head == NULL)
		{ 
			TVAR::head = TVAR::tail = elem;
		}
		else 
		{
			TVAR::tail->next = elem;
			TVAR::tail = elem;
		}
	}

    double TVAR::getValue(char* n)
	{
		TVAR* tmp = TVAR::head;
		while(tmp != NULL)
		{
			if(strcmp(tmp->nume,n) == 0)
				return tmp->valoare;
	     	tmp = tmp->next;
	    }
		return -1;
	}

	void TVAR::setValue(char* n, double v)
	{
		TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
			if(strcmp(tmp->nume,n) == 0)
			{
				tmp->valoare = v;
			}
			tmp = tmp->next;
	    }
	}

	void TVAR::printVars()
	{
		cout<<"\nPrinting table of variables...\n";
		TVAR* tmp = TVAR::head;
		while(tmp != NULL)
		{
			cout<<tmp->nume<<"="<<tmp->valoare<<"\n";
			tmp = tmp->next;
		}	  
	}

	void TVAR::deleteVariablesInBlock()
	{
	    TVAR *tmp = TVAR::head;
	    TVAR *prev = NULL;

	    while (tmp != NULL)
	    {
	        if (tmp->myblock > 1)
	        {
	            TVAR *next = tmp->next;

	            if (prev != NULL)
	            {
	                prev->next = next;
	                delete tmp;
	                tmp = next;
	            }
	            else
	            {
	                TVAR::head = next;
	                delete tmp;
	                tmp = next;
	            }
	        }
	        else
	        {
	            prev = tmp;
	            tmp = tmp->next;
	        }
	    }
		while(prev->next!=NULL){
			prev=prev->next;
		}
		TVAR::tail=prev;
	}
//pt while:
	int var1;
	int var2;
	char op;

	TVAR* ts = NULL;
%}

%union { char* sir; double val; }

%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_ERROR TOK_BRACE_LEFT TOK_BRACE_RIGHT
%token <sir> TOK_DECLARE
%token <val> TOK_NUMBER
%token <sir> TOK_VARIABLE
%token <sir> TOK_STRING_LITERAL
%token TOK_SCANF TOK_PRINTF
%token TOK_IF TOK_ELSE TOK_WHILE
%token TOK_GT TOK_EQ TOK_NEQ TOK_LT

%type <val> E

%start start_program

%left TOK_EQ TOK_NEQ 
%left TOK_LT TOK_GT
%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%
start_program 	: TOK_DECLARE TOK_VARIABLE TOK_LEFT TOK_RIGHT BLOCK 
				| TOK_ERROR { EsteCorecta = 0; }
				;
BLOCK 			: TOK_BRACE_LEFT {block++;} S TOK_BRACE_RIGHT { ts->deleteVariablesInBlock();block--;} 
				|
				;
S 				: I S
				|
    			;
I : TOK_VARIABLE TOK_PLUS TOK_PLUS
	{
		if(whileFlag==true){
			if(op == '<'){   
				while(var1<var2){ // merge while ul doar cu o instructiune inauntru, 
								  // l am pus doar aici ca model pt ca nu cred ca e cea mai optima rezolvare
					if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
						if(ts != NULL)
						{
							if(ts->exists($1) == 1)
							{
								ts->setValue($1, ts->getValue($1)+1);
								var1++;
							}
							else 
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    						yyerror(msg);
	    						YYERROR;
	  						}
						}
						else
						{
	  						sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  						yyerror(msg);
	  						YYERROR;
						}
					}			
				}
			}
			else if(op == '>'){
				while(var1>var2){
					if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
						if(ts != NULL)
						{
							if(ts->exists($1) == 1)
							{
								ts->setValue($1, ts->getValue($1)+1);
								var1++;
							}
							else 
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    						yyerror(msg);
	    						YYERROR;
	  						}
						}
						else
						{
	  						sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  						yyerror(msg);
	  						YYERROR;
						}
					}			
				}
			}
			else if(op == '='){
				while(var1==var2){
					if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
						if(ts != NULL)
						{
							if(ts->exists($1) == 1)
							{
								ts->setValue($1, ts->getValue($1)+1);
								var1++;
							}
							else 
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    						yyerror(msg);
	    						YYERROR;
	  						}
						}
						else
						{
	  						sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  						yyerror(msg);
	  						YYERROR;
						}
					}
				}
			}
			else if(op == '!'){
				while(var1!=var2){
					if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
						if(ts != NULL)
						{
							if(ts->exists($1) == 1)
							{
								ts->setValue($1, ts->getValue($1)+1);
								var1++;
							}
							else 
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    						yyerror(msg);
	    						YYERROR;
	  						}
						}
						else
						{
	  						sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  						yyerror(msg);
	  						YYERROR;
						}
					}
				}
			}
		}else{
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
			if(ts != NULL)
			{
				if(ts->exists($1) == 1)
				{
					ts->setValue($1, ts->getValue($1)+1);
				}
				else 
				{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    			yyerror(msg);
	    			YYERROR;
	  			}
			}
			else
			{
	  			sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  			yyerror(msg);
	  			YYERROR;
			}
		}
		}
	}
	| TOK_VARIABLE TOK_MINUS TOK_MINUS
	{
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
			if(ts != NULL)
			{
				if(ts->exists($1) == 1)
				{
					ts->setValue($1, ts->getValue($1)+1);
				}
				else 
				{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    			yyerror(msg);
	    			YYERROR;
	  			}
			}
			else
			{
	  			sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  			yyerror(msg);
	  			YYERROR;
			}
		}
	}
	| TOK_VARIABLE '=' E
    {
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
			if(ts != NULL)
			{
				if(ts->exists($1) == 1)
				{
					ts->setValue($1, $3);
				}
				else 
				{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    			yyerror(msg);
	    			YYERROR;
	  			}
			}
			else
			{
	  			sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  			yyerror(msg);
	  			YYERROR;
			}
		}
    }
    | TOK_DECLARE TOK_VARIABLE
    {
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
			if(ts != NULL)
			{
				if(ts->exists($2) == 0)
				{
					ts->add($2);
				}
				else
				{
					sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $2);
					yyerror(msg);
					YYERROR;
				}
			}
			else
			{
				ts = new TVAR();
				ts->add($2);
			}
		}
    }
    |TOK_DECLARE TOK_VARIABLE '=' E
    {
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||(if_exp==false)){
			if(ts != NULL)
        	{
        	    if(ts->exists($2) == 0)
        	    {
        	        ts->add($2, $4);
        	    }
        	    else
        	    {
        	        sprintf(msg,"%d:%d Eroare semantica: Variabila %s a fost deja declarata!", @1.first_line, @1.first_column, $2);
        	        yyerror(msg);
        	        YYERROR;
        	    }
        	}
        	else
        	{
        	    ts = new TVAR();
        	    ts->add($2, $4);
        	}
		}
    }
    | TOK_SCANF TOK_VARIABLE TOK_RIGHT
    {
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
        	if (ts != NULL)
        	{
        	    if (ts->exists($2) == 1)
        	    {
        	        double inputValue;
        	        cin >> inputValue;

        	        if (cin.fail())
        	        {
        	            sprintf(msg, "%d:%d Input invalid pentru variabila %s", @1.first_line, @1.first_column, $2);
        	            yyerror(msg);
        	            YYERROR;
        	        }

        	        ts->setValue($2, inputValue);
        	    }
        	    else
        	    {
        	        sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $2);
        	        yyerror(msg);
        	        YYERROR;
        	    }
        	}
        	else
        	{
        	    sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $2);
        	    yyerror(msg);
        	    YYERROR;
        	}
		}
    }
    | TOK_PRINTF TOK_STRING_LITERAL TOK_RIGHT
    {
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
        	cout<<$2<<endl;
		}
    }
	| TOK_PRINTF TOK_STRING_LITERAL TOK_VARIABLE TOK_RIGHT
	{
		  if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||if_exp==false){
			cout<<$2;
			if (ts != NULL)
        	{
        	    if (ts->exists($3) == 1)
        	    {
        	        cout<<ts->getValue($3)<<endl;
        	    }
        	    else
        	    {
        	        sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
        	        yyerror(msg);
        	        YYERROR;
        	    }
        	}
        	else
        	{
        	    sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
        	    yyerror(msg);
        	    YYERROR;
        	}
		}
	}
	| ';'
	| IfStatement 
	| WhileStatement
    ;
IfStatement : TOK_IF TOK_LEFT E TOK_RIGHT {if_exp=true;if($3!=0){ifFlag=1;}else{elseFlag=1;ifFlag=1;}} BLOCK {ifFlag=0;} ElseStatement
    ;
ElseStatement : TOK_ELSE BLOCK {ifFlag=0;elseFlag=0;if_exp=false;}
			  |  {ifFlag=0;elseFlag=0;if_exp=false;}
			  ;
WhileStatement : TOK_WHILE TOK_LEFT E TOK_RIGHT {whileFlag=true;} BLOCK {whileFlag=false;}
			   ;
E : E TOK_PLUS E {$$ = $1 + $3;}
    | E TOK_MINUS E { $$ = $1 - $3; }
    | E TOK_MULTIPLY E { $$ = $1 * $3; }
    | E TOK_DIVIDE E 
	{
		if($3 == 0)
		{
			sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      	yyerror(msg);
	      	YYERROR;
	    } 
	  	else 
		{ 
			$$ = $1 / $3; 
		} 
	}
    | TOK_LEFT E TOK_RIGHT { $$ = $2; }
    | TOK_NUMBER { 
		/*int intValue = static_cast<int>($1);
        if (intValue > std::numeric_limits<int>::max() || intValue < std::numeric_limits<int>::min()) {  ///nu prea merge
            sprintf(msg, "%d:%d Eroare semantica: Depasirea limitelor pentru tipul int!", @1.first_line, @1.first_column);
            yyerror(msg);
            YYERROR;
        }*/
        $$ = $1;}
    | TOK_VARIABLE { $$ = ts->getValue($1); } 
	| TOK_LEFT TOK_DECLARE TOK_RIGHT TOK_VARIABLE
    {
		if((ifFlag==1 && elseFlag==0)||(ifFlag==0 && elseFlag==1)||(if_exp==false)){
			if (ts != NULL)
        	{
        	    if (ts->exists($4) == 1)
        	    {
        	        if(strcmp($2,"int")==0){
        				$$ = static_cast<int>(ts->getValue($4));
					}
					else if(strcmp($2,"double")==0){
        				$$ = static_cast<double>(ts->getValue($4));
					}
					else if(strcmp($2,"float")==0){
        				$$ = static_cast<float>(ts->getValue($4));
					}
        	    }
        	    else
        	    {
        	        sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $4);
        	        yyerror(msg);
        	        YYERROR;
        	    }
        	}
        	else
        	{
        	    sprintf(msg, "%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $4);
        	    yyerror(msg);
        	    YYERROR;
        	}
		}
    }
	| E TOK_GT E { var1=$1; var2=$3; op='>'; $$ = ($1 > $3) ? 1 : 0; }
    | E TOK_EQ E { var1=$1; var2=$3; op='='; $$ = ($1 == $3) ? 1 : 0; }
    | E TOK_NEQ E { var1=$1; var2=$3; op='!'; $$ = ($1 != $3) ? 1 : 0; }
    | E TOK_LT E { var1=$1; var2=$3; op='<'; $$ = ($1 < $3) ? 1 : 0; }
    ;

    ;
%%

int main(int argc, char**argv)
{
    if(argc > 1){
        yyin = fopen(argv[1],"r");
    }
    else{
        yyin = stdin;
    }
	yyparse();
	
	if(EsteCorecta == 1)
	{
		cout<<"CORECT\n";	
	}	

	ts->printVars();
	return 0;
}

int yyerror(const char *msg)
{
	cout<<"EROARE: "<<msg<<endl;	
	return 1;
}
