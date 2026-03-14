%{
    int isNaveLigada = 0;   // Flag que verifica se a nave está ligada
    int isTakeOff = 0;       // Flag para verificar se a nave levantou voo
    int posX = 0, posY = 0, posZ = 0;  // Posições da nave nos eixos X, Y, Z
    char lastDirection = 'Y';          // Última direção definida (X ou Y)
%}

CONSOANTES [aeiouAEIOU]
ALFA [a-zA-Z]
NUM [0-9]
DIRECAO [LR]
GRAUS ([0-9]+)
HORIZONTAL ((-?[0-9]+))
VERTICAL ((-?[0-9]+))

%%

"<On--"{CONSOANTES}{ALFA}{NUM}{2,3}">" {
    if (isNaveLigada) {
        printf("Erro! A nave já está ligada.\n");
    } else {
        isNaveLigada = 1;
        printf("acao(ligar)\n");
    }
}

"<Off>" {
    if (isTakeOff) {
        printf("Erro! A nave precisa estar no solo para ser desligada.\n");
    } else if (!isNaveLigada) {
        printf("Erro! A nave já está desligada.\n");
    } else {
        isNaveLigada = 0;
        printf("acao(desligar)\n");
    }
}

"<Take-Off>" {
    if (isTakeOff) {
        printf("Erro! A nave já está no ar.\n");
    } else {
        isTakeOff = 1;
        printf("acao(levantar_voo)\n");
    }
}

"<Land>" {
    if (!isTakeOff) {
        printf("Erro! A nave já está no solo.\n");
    } else if (posZ != 0) {
        printf("Erro! A nave não pode aterrar enquanto não estiver na posição 0 no plano vertical.\n");
    } else {
        isTakeOff = 0;
        printf("acao(aterrar)\n");
    }
}

"<Turn--"{DIRECAO}"--"{GRAUS}">" {
    char dir = yytext[7];  // Obter direção (L ou R)
    int graus = atoi(yytext + 10);  // Obter os graus

    if (graus <= 0 || graus >= 360) {
        printf("Erro! O número de graus deve ser entre 1 e 359.\n");
    } else {
        //Eixo y
        if (dir == 'L') {
            printf("acao(virar esquerda %d graus)\n", graus);
            // Atualizar direção após girar à esquerda (90 graus no sentido anti-horário)
            lastDirection = (lastDirection == 'X') ? 'Y' : 'X';  // Alterna entre X e Y
        //Eixo x
        } else if (dir == 'R') {
            printf("acao(virar direita %d graus)\n", graus);
            // Atualizar direção após girar à direita (90 graus no sentido horário)
            lastDirection = (lastDirection == 'X') ? 'Y' : 'X';  // Alterna entre X e Y
        } 
    }
}

"<Move--"{HORIZONTAL}">" {
    int movimentos = atoi(yytext + 7);  // Extrair o número de movimentos

    if (lastDirection == 'Y') {
        posY += movimentos;  // Movimento no eixo X
    } else if (lastDirection == 'X') {
        posX += movimentos;  // Movimento no eixo Y
    }

    printf("move(%d, %d, %d)\n", posX, posY, posZ);
}

"<MoveX--"{HORIZONTAL}">" {
    int movimentos = atoi(yytext + 8);  // Extrair o número de movimentos

    if (isTakeOff) {
        posX += movimentos;  // Movimento no eixo X
    } else {
        posX += movimentos;  // Movimento no eixo X
    }
    printf("move(%d, %d, %d)\n", posX, posY, posZ);
}

"<MoveY--"{HORIZONTAL}">" {
    int movimentos = atoi(yytext + 8);  // Extrair o número de movimentos

    if (isTakeOff) {
        posY += movimentos;  // Movimento no eixo Y
    } else {
        posY += movimentos;  // Movimento no eixo Y
    }
    printf("move(%d, %d, %d)\n", posX, posY, posZ);
}

"<Fly--"{VERTICAL}">" {
    int movimentos = atoi(yytext + 6);  // Extrair o número de movimentos

    if (!isTakeOff) {
        printf("Erro! A nave precisa estar no ar para voar.\n");
    } else if (posZ + movimentos < 0) {
        printf("Erro! O comando resultaria em uma posição inválida no eixo Z (z = %d).\n", posZ + movimentos);
    } else {
        posZ += movimentos;  // Atualiza a posição vertical (Z)
        printf("move(%d, %d, %d)\n", posX, posY, posZ);
    }
}

 . ;  // Ignora qualquer outro caractere
%%

int main() {
    yylex();
    return 0;
}
