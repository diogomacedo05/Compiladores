/* Analisador Léxico (Lex) */
%{
#include "versao1.tab.h"
#include <stdio.h>
#include <string.h>
%}

%%

";"     { return PV; }

START[ \t]*\(([AEIOUaeiou][A-Za-z][0-9]{2,3})\)[ \t]*: { printf("Bloco START detectado com ID: %s\n", yytext); return START_BLOCK; }

:[ \t]*END { printf("Bloco END detectado\n"); return END_BLOCK; }

\<On--([AEIOUaeiou][A-Za-z][0-9]{2,3})\> {
    // Extrair valor e configurar se necessário
    printf("Comando On reconhecido: %s\n", yytext);
    return ON_COMMAND;
}

\<Off\> { 
    printf("Comando Off reconhecido.\n");
    return OFF_COMMAND;
}

\<Take-Off\> { 
    printf("Comando Take-Off reconhecido.\n");
    return TAKEOFF_COMMAND;
}

\<Land\> { 
    printf("Comando Land reconhecido.\n");
    return LAND_COMMAND;
}

\<Turn--([LR])--([0-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9])\> {
    yylval.cmd.direction = yytext[7];  // 'L' ou 'R'
    yylval.cmd.value = atoi(yytext + 10); // Valor numérico do ângulo
    printf("Comando Turn reconhecido: %s\n", yytext);
    return TURN_COMMAND;
}

\<Move--([0-9]+)\> {
    yylval.cmd.value = atoi(yytext + 7);
    printf("Comando Move reconhecido: %s\n", yytext);
    return MOVE_COMMAND;
}

\<Fly--([-]?[0-9]+)\> {
    yylval.cmd.value = atoi(yytext + 6);
    printf("Comando Fly reconhecido: %s\n", yytext);
    return FLY_COMMAND;
}

\<Set-Ship--[0-9]+--[0-9]+--[0-9]+--[0-9]+--[01]\> {
    int num1 = atoi(yytext + 11); 
    int num2 = atoi(strstr(yytext + 11, "--") + 2); 
    int num3 = atoi(strstr(strstr(yytext + 11, "--") + 2, "--") + 2); 
    int num4 = atoi(strstr(strstr(strstr(yytext + 11, "--") + 2, "--") + 2, "--") + 2); 
    int state = atoi(strstr(strstr(strstr(strstr(yytext + 11, "--") + 2, "--") + 2, "--") + 2, "--") + 2); 
    
    yylval.set_ship_t.num1 = num1;
    yylval.set_ship_t.num2 = num2;
    yylval.set_ship_t.num3 = num3;
    yylval.set_ship_t.num4 = num4;
    yylval.set_ship_t.state = state;
    printf("Comando Set-Ship reconhecido: %s\n", yytext);
    return SETSHIP_COMMAND;
}

\<Set-Space--[0-9]+--[0-9]+--[0-9]+--[0-9]+--[0-9]+\> {
    int num1 = atoi(yytext + 12); 
    int num2 = atoi(strstr(yytext + 12, "--") + 2); 
    int num3 = atoi(strstr(strstr(yytext + 12, "--") + 2, "--") + 2); 
    int num4 = atoi(strstr(strstr(strstr(yytext + 12, "--") + 2, "--") + 2, "--") + 2); 
    int num5 = atoi(strstr(strstr(strstr(strstr(yytext + 12, "--") + 2, "--") + 2, "--") + 2, "--") + 2); 
    
    yylval.set_space_t.num1 = num1;
    yylval.set_space_t.num2 = num2;
    yylval.set_space_t.num3 = num3;
    yylval.set_space_t.num4 = num4;
    yylval.set_space_t.num5 = num5;
    printf("Comando Set-Space reconhecido: %s\n", yytext);
    return SETSPACE_COMMAND;
}

[ \t\n]+ ; // Ignorar espaços, tabs e quebras de linha

. { printf("Token inválido: %s\n", yytext); return 0; }

%%

int yywrap() { return 1; }