# Compiladores

🛸 Alien Spaceship AnalyzerCompilers Project | 

UTAD 2024/2025

Este projeto consiste num analisador léxico e sintático desenvolvido para interpretar comandos de naves extraterrestres encontrados em "pergaminhos".

🚀 Funcionalidades
Análise de Instruções: Reconhece comandos como <On>, <Off>, <Move>, <Fly> e <Turn>.

Validação Sintática: Garante a estrutura correta dos blocos de comandos (START (ID) : ... : END).

Controlo de Estado: Monitoriza a posição $(x, y, z)$, direção e altitude da nave em tempo real.

Segurança: Deteta erros como voar sem descolar ou aterrar fora da altitude zero.

🛠️ TecnologiasLEX/FLEX: Processamento léxico.YACC/BISON: Gramática e processamento sintático.C: 

Lógica interna e gestão de variáveis globais.👥 

AutoresDiogo Macedo (al80981)Eduardo Gonçalves (al81756)
