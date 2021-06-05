#### THE GRAMMER

expression : logic
    | variable = logic


		arg_list used while calling a function
		refer to the rule
				factor: id(arg_list)
		Example
				foo(5, x+y)
				foo() 
-----------------------------------------------------------------
arg_list: args              |		5, x+y
    |                       |		
							
args: args,logic        	|		one or more logic
    | logic             	|		seperated by ,
-----------------------------------------------------------------



        logic is the bap of all expressions/
        covers all types of expression
-----------------------------------------------------------------
logic: rel                  |
    | rel && rel            |       x+y<3 && z>5
-----------------------------------------------------------------
rel:    simple              |
    | simple <= simple      |       x+y <= 5-z*4
-----------------------------------------------------------------
simple: term                |
    | simple + term         |       x+3*y-(5/x)
-----------------------------------------------------------------
term: unary                 |
    | term * unary          |       3.14 * -arr[exp]
-----------------------------------------------------------------
unary: factor               |
    | -unary/ !unary        |       !x, -arr[exp]   
-----------------------------------------------------------------
            smallest block of an expression
-----------------------------------------------------------------
factor: variable            |       x, arr[exp]
    | id(arg_list)          |       foo(arg_list)
    | (expression)          |       (exp)
    | const_int             |       23
    | const_float           |       3.14
    | variable++            |       x++, arr[exp]++         
-----------------------------------------------------------------






#### WHEN TO ENTER NEW SCOPES:

A new scope is entered at the beginning of a new compound statement.
Before entering a new scope, we DON'T have to check whether any new
variables were declared right at the beginning of this scope.
	
	Example:
		for(int i = 1; i < 3; i++)
			// new scope is entered here, 
			// right before reading '{'
		{
			...
		}
		
Refer to 'compound_statement' rule for full understanding.

However, due to entering a scope at this position, we are considering
the variable i to NOT be included in this new-scope.
Yet, this will not be a problem, since our language does not 
support such form of variable declaration.

		NOT ALLOWED:				Correct:				
	for(int i=1;i<3;i++){..}	for(i=1;i<3;i++){..}
	   while(int x=1){..}			while(x=1)

Refer to 'statement' rule and visualize the limits of the final
form of 'expression' for full understanding as to why the above
are not allowed


    
    
    
  
