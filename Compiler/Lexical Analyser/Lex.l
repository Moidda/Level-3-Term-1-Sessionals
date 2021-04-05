%option noyywrap

%x CHAR_STATE
%x STRING_STATE
%x LINE_COMMENT_STATE
%x MULTI_LINE_COMMENT_STATE

%{
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
using namespace std;

#include"SymbolTable.h"

SymbolTable symbolTable(7);
SymbolInfo* symbolInfo;

ofstream logOut;
ofstream tokenOut;

int lineCount = 1, errorCount = 0;
string multiLineComment = "";

const string unterminatedCharacter = "Unterminated character";
const string multiCharacter = "Multi character constant error";
const string emptyCharacter = "Empty character constant error";
const string unknownSequenceCharacter = "Unknown escape sequence";
const string idError = "Invalid prefix on ID or invalid suffix on Number ";
const string unterminatedString = "Unterminated string";

void printLog(string tokenString, string lexemeString) {
	logOut << "Line no " << lineCount << ": ";
	logOut << "Token <" << tokenString << "> ";
	logOut << "Lexeme " << lexemeString << " found\n\n";
}

void printToken(string tokenString, string symbolString = "") {
	tokenOut << "<" << tokenString;
	if(symbolString == "") {
		tokenOut << ">";
		return;
	}
	tokenOut << "," << symbolString << ">";
}

void printError(string errorMsg) {
	logOut << "Error at line no " << lineCount << ": ";
	logOut << errorMsg << "\n\n";
	errorCount++;
}

void processCharacter(string ch) {
	if(ch.size() == 1) {
		string errorMsg = emptyCharacter;
		errorMsg += " '";
		errorMsg += ch;
		printError(errorMsg);
		return;
	}
	if(ch.size() > 3 or (ch.size() == 3 and ch[0] != '\\')) {
		string errorMsg = multiCharacter;
		errorMsg += " '";
		errorMsg += ch;
		printError(errorMsg);
		return;
	}
	if(ch.size() == 3) {
		char specialChar = ch[1];
		if(specialChar == 'n') {
			printLog("CONST_CHAR", "'\\n'");
			printToken("CONST_CHAR", "\n");
			symbolInfo = new SymbolInfo("'\\n'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);
		} 
		else if(specialChar == 't') {
			printLog("CONST_CHAR", "'\\t'");
			printToken("CONST_CHAR", "\t");
			symbolInfo = new SymbolInfo("'\\t'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);
		}
		else if(specialChar == '\\') {
			printLog("CONST_CHAR", "'\\'");
			printToken("CONST_CHAR", "\\");
			symbolInfo = new SymbolInfo("'\\'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);
		}
		else if(specialChar == '\'') {
			printLog("CONST_CHAR", "\\'");
			printToken("CONST_CHAR", "'");
			symbolInfo = new SymbolInfo("\\'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);		
		}
		else if(specialChar == 'a') {
			printLog("CONST_CHAR", "'\\a'");
			printToken("CONST_CHAR", "\a");
			symbolInfo = new SymbolInfo("'\\a'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);			
		}
		else if(specialChar == 'f') {
			printLog("CONST_CHAR", "'\\f'");
			printToken("CONST_CHAR", "\f");
			symbolInfo = new SymbolInfo("'\\f'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);						
		}
		else if(specialChar == 'r') {
			printLog("CONST_CHAR", "'\\r'");
			printToken("CONST_CHAR", "\r");
			symbolInfo = new SymbolInfo("'\\r'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);						
		}
		else if(specialChar == 'b') {
			printLog("CONST_CHAR", "'\\b'");
			printToken("CONST_CHAR", "\b");
			symbolInfo = new SymbolInfo("'\\b'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);						
		}
		else if(specialChar == 'v') {
			printLog("CONST_CHAR", "'\\v'");
			printToken("CONST_CHAR", "\v");
			symbolInfo = new SymbolInfo("'\\v'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);						
		}
		else if(specialChar == '0') {
			printLog("CONST_CHAR", "'\\0'");
			printToken("CONST_CHAR", "\0");
			symbolInfo = new SymbolInfo("'\\0'", "CONST_CHAR");
			if(symbolTable.insertIntoTable(symbolInfo, logOut))
				symbolTable.printAllScope(logOut);						
		}
		else {
			string errorMsg = unknownSequenceCharacter;
			errorMsg += " '";
			errorMsg += ch; 
			printError(errorMsg);
		}
		return;
	} 
	
	if(ch[0] == '\\') {
		string errorMsg = unterminatedCharacter;
		errorMsg += " '";
		errorMsg += ch;
		printError(errorMsg);
		return;
	}
	
	// printing the character with '' wrapped in logs
	string symbol = "'";
	symbol += ch[0];
	symbol += "'";
	printLog("CONST_CHAR", symbol);
	
	// printing the literal character (ASCII) in token
	symbol = "";
	symbol += ch[0];
	printToken("CONST_CHAR", symbol);
	
	// inserting the character with '' wrapped in symbol table
	symbol = "'";
	symbol += ch[0];
	symbol += "'";
	symbolInfo = new SymbolInfo(symbol, "CONST_CHAR");
	if(symbolTable.insertIntoTable(symbolInfo, logOut))
		symbolTable.printAllScope(logOut);
}

void processString(string str) {
	string res = "";
	bool ok = true;
	int n = str.size();
	
	int newlines = 0;
	for(int i = 0; i+1 < n and ok; i++) {
		if(str[i] == '\\') {							// found in string "...\..."
			if(i+1 == n-1) ok = false;					// "...\"
			else if(str[i+1] == '\n') newlines++;		// "...\NEWLINE
			else if(str[i+1] == 'n') res += '\n';		// "...\n..."
			else if(str[i+1] == 't') res += '\t';
			else if(str[i+1] == '\\') res += '\\';
			else if(str[i+1] == '\'') res += '\'';
			else if(str[i+1] == 'a') res += '\a';
			else if(str[i+1] == 'f') res += '\f';
			else if(str[i+1] == 'r') res += '\r';
			else if(str[i+1] == 'b') res += '\b';
			else if(str[i+1] == 'v') res += '\v';
			else if(str[i+1] == '0') res += '\0';
			else if(str[i+1] == '\"') res += '\"';
			else ok = false;
			i++;
		}
		else {
			res += str[i];
		}
	}
	
	if(!ok) {
		string errorMsg = unknownSequenceCharacter;
		errorMsg += " in string ";
		errorMsg += res;
		printError(errorMsg);
		lineCount += newlines;
		return;
	}
	
	res = "\"" + res + "\"";
	string lexeme = "\"" + str;
	
	logOut << "Line no " << lineCount << ": ";
	logOut << "Token <STRING> Lexeme " << lexeme << " found --> ";
	logOut << "<STRING, " << res << ">\n\n";
	
	printToken("STRING", res);
	lineCount += newlines;
}

// lexeme for line comment has a new line as the last character
// remove it to retrieve the actual lexeme
void processLineComment(string lexeme) {
	lexeme.pop_back();
	lexeme = "//" + lexeme;
	printLog("COMMENT", lexeme);
	for(int i = 0; i < lexeme.size(); i++) lineCount += (lexeme[i]=='\n');
	lineCount++; // lexeme for line comment has a new line as the last character
}

%}
 
 
WHITESPACE [ \t\f\r\v]+
NEWLINE [\n]
LETTER [a-zA-Z]
DIGIT [0-9]
ALPHANUMERIC [a-zA-Z0-9]
INTEGER ([1-9]{DIGIT}*)|[0]

POWER_OF_TEN [Ee][-]?{INTEGER}
FRACTION {INTEGER}?[.]{DIGIT}+

FLOAT {FRACTION}|{FRACTION}{POWER_OF_TEN}|{INTEGER}{POWER_OF_TEN}
FLOAT_ERROR {FRACTION}[.]({FLOAT}|{INTEGER})*

ILL {INTEGER}[Ee][-]?{FLOAT}({FLOAT}|{FLOAT_ERROR}|{INTEGER})*
ILL_NUMBER {ILL}[Ee]({ILL}|{FLOAT_ERROR}|{FLOAT}|{POWER_OF_TEN}|{INTEGER})*

IDENTIFIER ({LETTER}|[_])({ALPHANUMERIC}|[_])*
PREFIX_ERROR ({INTEGER}|{FLOAT}|{FLOAT_ERROR})+{IDENTIFIER}({FLOAT}|{FLOAT_ERROR})*
SUFFIX_ERROR ({INTEGER}|{FLOAT}|{FLOAT_ERROR})*{IDENTIFIER}({FLOAT}|{FLOAT_ERROR})+
ID_ERROR {PREFIX_ERROR}|{SUFFIX_ERROR}
		

SINGLE_QUOTE [\\]["]
STRING_BODY ([^\n"]|{SINGLE_QUOTE})*
NORMAL_STRING {STRING_BODY}["]
MULTI_STRING_BODY {STRING_BODY}[\\][\n] 
MULTI_STRING {MULTI_STRING_BODY}*{NORMAL_STRING}
UNTERMINATED_STRING {MULTI_STRING_BODY}*([\n]|[^\n"]*[^\\"][\n])

%%
{WHITESPACE}	{}
{NEWLINE} 		{lineCount++;}

"if"			{printLog("IF", yytext); 		printToken("IF");}
"else"			{printLog("ELSE", yytext); 		printToken("ELSE");}
"for"			{printLog("FOR", yytext); 		printToken("FOR");}
"while"			{printLog("WHILE", yytext); 	printToken("WHILE");}
"do"			{printLog("DO", yytext); 		printToken("DO");}
"break"			{printLog("BREAK", yytext); 	printToken("BREAK");}
"int"			{printLog("INT", yytext); 		printToken("INT");}
"char"			{printLog("CHAR", yytext); 		printToken("CHAR");}
"float"			{printLog("FLOAT", yytext); 	printToken("FLOAT");}
"double"		{printLog("DOUBLE", yytext); 	printToken("DOUBLE");}
"void"			{printLog("VOID", yytext); 		printToken("VOID");}
"return"		{printLog("RETURN", yytext); 	printToken("RETURN");}
"switch"		{printLog("SWITCH", yytext); 	printToken("SWITCH");}
"case"			{printLog("CASE", yytext); 		printToken("CASE");}
"default"		{printLog("DEFAULT", yytext); 	printToken("DEFAULT");}
"continue"		{printLog("CONTINUE", yytext); 	printToken("CONTINUE");}

{INTEGER}		{
					printLog("CONST_INT", yytext);	
					printToken("CONST_INT", yytext);							
					symbolInfo = new SymbolInfo(yytext, "CONST_INT");
					if(symbolTable.insertIntoTable(symbolInfo, logOut))
						symbolTable.printAllScope(logOut);
				}
{FLOAT}			{
					printLog("CONST_FLOAT",yytext);
					printToken("CONST_FLOAT", yytext);
					symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
					if(symbolTable.insertIntoTable(symbolInfo, logOut))
						symbolTable.printAllScope(logOut);
				}
{FLOAT_ERROR}	{
					string errorMsg = "Too many decimal points ";
					errorMsg += yytext;
					printError(errorMsg);
				}
{ILL_NUMBER}	{
					string errorMsg = "Ill formed number ";
					errorMsg += yytext;
					printError(errorMsg);
				}
				
"'"										{	BEGIN CHAR_STATE;	}
<CHAR_STATE>[^'\n]*[\n]					{
											string errorMsg = unterminatedCharacter;
											errorMsg += " '";
											errorMsg += yytext;
											errorMsg.pop_back();
											printError(errorMsg);
											lineCount++;
											BEGIN INITIAL;
										}
<CHAR_STATE>[^'\n]*[']					{	
											processCharacter(yytext);
											BEGIN INITIAL;
										}


{ID_ERROR}		{
					string errorMsg = idError;
					errorMsg += yytext;
					printError(errorMsg);					
				}
{IDENTIFIER}	{
					printLog("ID", yytext);		
					printToken("ID", yytext);
					symbolInfo = new SymbolInfo(yytext, "ID");
					if(symbolTable.insertIntoTable(symbolInfo, logOut))
						symbolTable.printAllScope(logOut);								
				}

"+"				{printLog("ADDOP", yytext);		printToken("ADDOP", yytext);}
"-"				{printLog("ADDOP", yytext);		printToken("ADDOP", yytext);}

"*"				{printLog("MULOP", yytext);		printToken("MULOP", yytext);}
"/"				{printLog("MULOP", yytext);		printToken("MULOP", yytext);}
"%"				{printLog("MULOP", yytext);		printToken("MULOP", yytext);}

"++"			{printLog("INCOP", yytext);		printToken("INCOP", yytext);}
"--"			{printLog("INCOP", yytext);		printToken("INCOP", yytext);}

"<"				{printLog("RELOP", yytext);		printToken("RELOP", yytext);}
"<="			{printLog("RELOP", yytext);		printToken("RELOP", yytext);}
">"				{printLog("RELOP", yytext);		printToken("RELOP", yytext);}
">="			{printLog("RELOP", yytext);		printToken("RELOP", yytext);}
"=="			{printLog("RELOP", yytext);		printToken("RELOP", yytext);}
"!="			{printLog("RELOP", yytext);		printToken("RELOP", yytext);}

"="				{printLog("ASSIGNOP", yytext);	printToken("ASSIGNOP", yytext);}

"&&"			{printLog("LOGICOP", yytext);	printToken("LOGICOP", yytext);}
"||"			{printLog("LOGICOP", yytext);	printToken("LOGICOP", yytext);}
"!"				{printLog("NOT", yytext);		printToken("NOT", yytext);}

"("				{printLog("LPAREN", yytext);	printToken("LPAREN", yytext);}
")"				{printLog("RPAREN", yytext);	printToken("RPAREN", yytext);}
"{"				{printLog("LCURL", yytext);		printToken("LCURL", yytext);	symbolTable.enterScope();}
"}"				{printLog("RCURL", yytext);		printToken("RCURL", yytext);	symbolTable.exitScope();}
"["				{printLog("LTHIRD", yytext);	printToken("LTHIRD", yytext);}
"]"				{printLog("RTHIRD", yytext);	printToken("RTHIRD", yytext);}

","				{printLog("COMMA", yytext);		printToken("COMMA", yytext);}
";"				{printLog("SEMICOLON", yytext);	printToken("SEMICOLON", yytext);}


["]										{BEGIN STRING_STATE;}
<STRING_STATE>{UNTERMINATED_STRING}		{
											string errorMsg = unterminatedString;
											errorMsg += " \"";
											errorMsg += yytext;
											printError(errorMsg);
											lineCount++;
											BEGIN INITIAL;
										}
<STRING_STATE>{MULTI_STRING}			{processString(yytext); BEGIN INITIAL;}


"//"													{ BEGIN LINE_COMMENT_STATE;}
<LINE_COMMENT_STATE>([^\n]*[\\][\n])*([^\n]*[\n])		{ processLineComment(yytext);	BEGIN INITIAL; }



"/*"										{
												multiLineComment = "/*"; 
												BEGIN MULTI_LINE_COMMENT_STATE;
											}
<MULTI_LINE_COMMENT_STATE>[*][\/]			{
												multiLineComment += yytext;
												printLog("COMMENT", multiLineComment);
												multiLineComment = "";
												BEGIN INITIAL;
											}
<MULTI_LINE_COMMENT_STATE>.					{	multiLineComment += yytext;	}
<MULTI_LINE_COMMENT_STATE>[\n]				{	multiLineComment += yytext;	lineCount++; }
<MULTI_LINE_COMMENT_STATE><<EOF>>			{
												string errorMsg = "Unterminated Comment ";
												errorMsg += multiLineComment;
												printError(errorMsg);
												multiLineComment = "";
												logOut << "Total lines: " << lineCount << "\n";
												logOut << "Total errors: " << errorCount << "\n";
												return 0;
											}
											
<<EOF>>			{
					logOut << "Total lines: " << lineCount << "\n";
					logOut << "Total errors: " << errorCount << "\n";
					return 0;
				}


.				{printError("Unrecognized character");}
%%



int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logOut.open("1705085_log.txt");
	tokenOut.open("1705085_token.txt");

	yyin= fin;
	yylex();
	fclose(yyin);
	
	logOut.close();
	tokenOut.close();
	
	return 0;
}



