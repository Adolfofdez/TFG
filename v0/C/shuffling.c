#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

/* Mapa logístico: x_{n+1} = r * x_n * (1 - x_n) */
static double logistic(double x, double r) {
    return r * x * (1.0 - x);
}

double next_chaotic(double *x, double r) {
    *x = logistic(*x, r);
    return *x;
}

int cmp_int(const void *a, const void *b) {
    return (*(int*)a - *(int*)b);
}

/* Imprime una matriz dim×dim almacenada en arr[] */
void print_matrix(const uint8_t *arr, int dim, const char *title) {
    printf("%s\n", title);
    for(int i = 0; i < dim; ++i) {
        for(int j = 0; j < dim; ++j) {
            printf("%3d ", arr[i*dim + j]);
        }
        printf("\n");
    }
    printf("\n");
}

/* Lectura diagonal de una matriz dim×dim almacenada en in[] */
void diagonal_read(const uint8_t *in, uint8_t *out, int dim, int option) {
    int idx = 0;
    switch(option) {
        case 0:
            for(int sum=0; sum<2*dim-1; ++sum)
                for(int i=0; i<dim; ++i) {
                    int j = sum - i;
                    if(j>=0 && j<dim) out[idx++] = in[i*dim + j];
                }
            break;
        case 1:
            for(int sum=0; sum<2*dim-1; ++sum)
                for(int i=0; i<dim; ++i) {
                    int j = (dim-1) - (sum - i);
                    if(sum-i>=0 && sum-i<dim) out[idx++] = in[i*dim + j];
                }
            break;
        case 2:
            for(int sum=2*dim-2; sum>=0; --sum)
                for(int i=0; i<dim; ++i) {
                    int j = sum - i;
                    if(j>=0 && j<dim) out[idx++] = in[i*dim + j];
                }
            break;
        case 3:
            for(int sum=2*dim-2; sum>=0; --sum)
                for(int i=0; i<dim; ++i) {
                    int j = (dim-1) - (sum - i);
                    if(sum-i>=0 && sum-i<dim) out[idx++] = in[i*dim + j];
                }
            break;
        default:
            memcpy(out, in, dim*dim);
    }
}

void shuffle_block_verbose(uint8_t *block, size_t block_size, double *seed, double r) {
    int dim = (int)sqrt((double)block_size);
    if((size_t)dim*dim != block_size) {
        fprintf(stderr, "Error: tamaño de bloque no cuadrado\n");
        exit(EXIT_FAILURE);
    }

    /* Paso 1: imprimir estado inicial */
    print_matrix(block, dim, "Paso 1: Estado inicial de la matriz:");

    /* Paso 2: generar tres cortes caóticos */
    int cuts[3];
    for(int i=0; i<3; ++i) {
        cuts[i] = 1 + (int)(next_chaotic(seed, r) * (block_size - 2));
    }
    qsort(cuts, 3, sizeof(int), cmp_int);
    printf("Paso 2: Puntos de corte ordenados: a=%d, b=%d, c=%d\n\n", cuts[0], cuts[1], cuts[2]);
    int a = cuts[0], b = cuts[1], c = cuts[2];

    /* Paso 3: dividir en P1..P4 */
    uint8_t *P1 = malloc(a), *P2 = malloc(b-a), *P3 = malloc(c-b), *P4 = malloc(block_size-c);
    memcpy(P1, block, a);
    memcpy(P2, block + a, b - a);
    memcpy(P3, block + b, c - b);
    memcpy(P4, block + c, block_size - c);
    printf("Paso 3: Sub-bloques P1..P4 lineales:\n");
    for(int i=0;i<a;i++) printf("%2d ", P1[i]); printf("(P1)\n");
    for(int i=0;i<b-a;i++) printf("%2d ", P2[i]); printf("(P2)\n");
    for(int i=0;i<c-b;i++) printf("%2d ", P3[i]); printf("(P3)\n");
    for(int i=0;i<block_size-c;i++) printf("%2d ", P4[i]); printf("(P4)\n\n");

    /* Paso 4: permutar según secuencia */
    int seq = (int)(next_chaotic(seed, r) * 4) % 4;
    printf("Paso 4: Secuencia de permutación seleccionada: %d\n\n", seq);
    uint8_t *tmp = malloc(block_size);
    uint8_t *subs[4] = {P1, P2, P3, P4};
    int lengths[4] = {a, b-a, c-b, (int)block_size - c};
    int order[4][4] = {{3,0,1,2},{1,0,3,2},{2,0,3,1},{3,2,1,0}};
    int pos = 0;
    for(int i=0; i<4; ++i) {
        int idx = order[seq][i];
        memcpy(tmp + pos, subs[idx], lengths[idx]);
        pos += lengths[idx];
    }
    print_matrix(tmp, dim, "Paso 4: Matriz lineal tras permutar sub-bloques:");

    /* Paso 5: lectura diagonal */
    uint8_t *diag = malloc(block_size);
    diagonal_read(tmp, diag, dim, seq);
    print_matrix(diag, dim, "Paso 5: Matriz tras lectura diagonal:");

    /* Copiar resultado final */
    memcpy(block, diag, block_size);

    /* Liberar memoria */
    free(P1); free(P2); free(P3); free(P4);
    free(tmp); free(diag);
}

int main() {
    double seed = 0.123456;
    double r = 3.99;

    uint8_t matrix[10][10] = {
        {1,2,3,4,5,6,7,8,9,10},
        {11,12,13,14,15,16,17,18,19,20},
        {21,22,23,24,25,26,27,28,29,30},
        {31,32,33,34,35,36,37,38,39,40},
        {41,42,43,44,45,46,47,48,49,50},
        {51,52,53,54,55,56,57,58,59,60},
        {61,62,63,64,65,66,67,68,69,70},
        {71,72,73,74,75,76,77,78,79,80},
        {81,82,83,84,85,86,87,88,89,90},
        {91,92,93,94,95,96,97,98,99,100}
    };
    size_t block_size = 100;

    shuffle_block_verbose((uint8_t*)matrix, block_size, &seed, r);

    return 0;
}
