%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>


// Declarações 

int yylex(void);
void yyerror(const char *s);
int valid = 1; // Flag para arquivo válido ou inválido

int estado_nave = 0, voo_nave = 0, x = 0, y = 0, z = 0, min_x = 0, min_y = 0, min_z = 0, max_x = 100, max_y = 100, max_z = 100;
int angulo_atual = 90 , distancia_atual = 0 , altura = 0;

void exibir_erro(const char* mensagem);
void calcular_movimento(int distancia);
void executar_voo(int alt);
void processar_movimentos();

FILE *output_file;
char movement_buffer[1024] = "";
char block_buffer[4096] = "";

%}

%union {
    struct {
        char direction;
        int value;
    } cmd;

    struct {
        int num1;
        int num2;
        int num3;
        int num4;
        int state; 
    } set_ship_t;

    struct {
        int num1;
        int num2;
        int num3;
        int num4;
        int num5;
    } set_space_t;
}

%token START_BLOCK END_BLOCK ON_COMMAND OFF_COMMAND TAKEOFF_COMMAND LAND_COMMAND PV
%token <set_ship_t> SETSHIP_COMMAND 
%token <cmd> TURN_COMMAND MOVE_COMMAND FLY_COMMAND
%token <set_space_t> SETSPACE_COMMAND


%%

program:
    blocks
    {
        if (valid) {
            printf("Arquivo válido.\n");
        } else {
            printf("Arquivo inválido.\n");
        }
    }
    ;

blocks:
    block_list
    ;

block_list:
    block_list block
    | block
    ;

block:
    START_BLOCK instruction_list END_BLOCK
    {
        if (valid) {
            processar_movimentos(); // Garante que todos os movimentos sejam adicionados ao buffer
            fprintf(output_file, "%s\n", block_buffer); // Grava o conteúdo do buffer e pula para a próxima linha
            block_buffer[0] = '\0'; // Limpa o buffer para o próximo bloco
            printf("Bloco START validado com sucesso.\n");
        }
    }
    | START_BLOCK error END_BLOCK
    {
        yyerror("Erro dentro do bloco.");
        valid = 0;
    }
    ;

instruction_list:
    instruction_list PV instruction
    | instruction
    ;

instruction:
    ON_COMMAND
    {
        processar_movimentos();
        if (estado_nave == 1)
            exibir_erro("A nave já se encontra-se ligada");
        else
        {
            estado_nave = 1;
            printf("ação(ligar)\n");
            fprintf(output_file, "ação(ligar) ");
        }
        
    }
    | OFF_COMMAND
    {
        processar_movimentos();
        if (estado_nave == 0)
            exibir_erro("A nave já se encontra-se desligada");
        else
        {
            estado_nave = 0;
            printf("ação(desligar)\n");
            fprintf(output_file, "ação(desligar) ");
        }
    }
    | TAKEOFF_COMMAND
    {
        processar_movimentos();
        if (voo_nave == 1)
            exibir_erro("A nave já se encontra-se no ar");
        else
        {
            voo_nave = 1;
            printf("ação(Levantar Nave)\n");
            fprintf(output_file, "ação(Levantar Nave) ");
        }
    }
    | LAND_COMMAND
    {
        processar_movimentos();
         if (voo_nave == 0)
            exibir_erro("A nave já se encontra-se em terra");
        else
        {
            voo_nave = 0;
            printf("ação(Aterrar Nave)\n");
            fprintf(output_file, "ação(Aterrar Nave) ");
        }
    }
    | TURN_COMMAND
    {
        processar_movimentos();
        if (estado_nave == 0)
            exibir_erro("A nave deve estar ligada para girar.");

        angulo_atual = $1.value;

        if (angulo_atual < 0 || angulo_atual >= 360)
            exibir_erro("Ângulo inválido para virar (0 ou >= 360 graus).");

        char dir = $1.direction; 
    
        if (dir == 'L') {
            printf("Virar para a esquerda %d graus. ", angulo_atual);
            fprintf(output_file, "turn(L,%d) ", angulo_atual);
        } 
        else if (dir == 'R') 
        {
            printf("Virar para a direita %d graus. ", angulo_atual);
            fprintf(output_file, "turn (R,%d) ", angulo_atual);
            angulo_atual = -(angulo_atual) + 360;
        } 
        else
        {
            exibir_erro("Direção inválida. Use 'L' para esquerda ou 'R' para direita.");
        }
    }
    | MOVE_COMMAND
    {
        if (estado_nave == 0)
            exibir_erro("A nave não pode ser mover quando está desligada");
        else
        {
            distancia_atual = $1.value;
            calcular_movimento(distancia_atual);
        }

    }
    | FLY_COMMAND
    {
        processar_movimentos();
        if (estado_nave == 0)
            exibir_erro("A nave não pode ser mover quando está desligada");
        if (voo_nave == 0)
            exibir_erro("A nave não pode mover se no ar sem levantar voo");
        else
            altura = $1.value;
            executar_voo(altura);
    }
    | SETSHIP_COMMAND
    {
        processar_movimentos();
        x = $1.num1;
        y = $1.num2;
        z = $1.num3;
        angulo_atual = $1.num4;
        estado_nave = $1.state;
        fprintf(output_file, "init(%d, %d, %d, %d, %d) ", x, y, z, angulo_atual, estado_nave);
    }
    | SETSPACE_COMMAND
    {
        processar_movimentos();
        min_x = $1.num1;
        min_y = $1.num2;
        max_x = $1.num3;
        max_y = $1.num4;
        max_z = $1.num5;
        fprintf(output_file, "initspace(%d, %d, %d, %d, %d) ", min_x, min_y, max_x, max_y, max_z);
    }
    ;

%%

int main() {
    output_file = fopen("output.txt", "w");
    if (output_file == NULL) {
        perror("Erro ao abrir arquivo de saída");
        exit(EXIT_FAILURE);
    }

    if (yyparse() == 0 && valid) {
        printf("Parsing completo: Arquivo válido.\n");
    } else {
        printf("Parsing completo: Arquivo inválido.\n");
    }

    fclose(output_file);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
    valid = 0; // Indica que o arquivo contém erros
}

void exibir_erro(const char* mensagem) {
    printf("Erro: %s\n", mensagem);
    exit(1);
}

void calcular_movimento(int distancia) {
    printf("Posição Atual: (%d, %d, %d) ", x, y, z);

    double radianos = angulo_atual * (M_PI / 180.0);
    int delta_x = (int)(distancia * cos(radianos));
    int delta_y = (int)(distancia * sin(radianos));

    int tmp_x = x + delta_x;
    int tmp_y = y + delta_y;

    if (tmp_x >= min_x && tmp_y >= min_z && tmp_x <= max_x && tmp_y <= max_y)
    {
        x = tmp_x;
        y = tmp_y;
    }
    else
        exibir_erro("Movimento fora dos limites impostos, as coordenadas permanecem as mesmas");

    char temp[64];
    snprintf(temp, sizeof(temp), "(%d, %d, %d) ", x, y, z);
    strcat(movement_buffer, temp);

    printf("Movimento: Distância %d, Δx: %d, Δy: %d \n", distancia, delta_x, delta_y);
    printf("Posição Após Movimento: (%d, %d, %d) \n", x, y, z);
}
void processar_movimentos() {
    if (strlen(movement_buffer) > 0) {
        fprintf(output_file, "move %s ", movement_buffer);
        movement_buffer[0] = '\0';
    }
}
void executar_voo(int alt) {
    if ((z + alt) < 0)
        exibir_erro("A nave não pode passar do limite da superfície da terra.");
    if ((z + alt) > max_z)
        exibir_erro("A nave não pode passar do limite máximo imposto");
    printf("Altura Atual: %d\n", z);
    z += alt;
    printf("Altura Final: %d \n", z);
    printf("Posição Atual: (%d,%d,%d) ", x, y, z);
}
