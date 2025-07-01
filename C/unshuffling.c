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

void print_matrix(const uint8_t *mat, int dim, const char *title) {
    printf("%s\n", title);
    for(int i = 0; i < dim; ++i) {
        for(int j = 0; j < dim; ++j) {
            printf("%3d ", mat[i*dim + j]);
        }
        printf("\n");
    }
    printf("\n");
}

/* Inversión de la lectura diagonal */
void inverse_diagonal_read(const uint8_t *in, uint8_t *out, int dim, int option) {
    int N = dim * dim;
    int *positions = malloc(N * sizeof(int));
    int idx = 0;
    switch(option) {
        case 0:
            for(int sum = 0; sum < 2*dim-1; ++sum)
                for(int i = 0; i < dim; ++i) {
                    int j = sum - i;
                    if(j >= 0 && j < dim) positions[idx++] = i*dim + j;
                }
            break;
        case 1:
            for(int sum = 0; sum < 2*dim-1; ++sum)
                for(int i = 0; i < dim; ++i) {
                    if(sum - i >= 0 && sum - i < dim) {
                        int j = (dim-1) - (sum - i);
                        positions[idx++] = i*dim + j;
                    }
                }
            break;
        case 2:
            for(int sum = 2*dim-2; sum >= 0; --sum)
                for(int i = 0; i < dim; ++i) {
                    int j = sum - i;
                    if(j >= 0 && j < dim) positions[idx++] = i*dim + j;
                }
            break;
        case 3:
            for(int sum = 2*dim-2; sum >= 0; --sum)
                for(int i = 0; i < dim; ++i) {
                    if(sum - i >= 0 && sum - i < dim) {
                        int j = (dim-1) - (sum - i);
                        positions[idx++] = i*dim + j;
                    }
                }
            break;
        default:
            for(int i = 0; i < N; ++i) positions[idx++] = i;
    }
    for(int k = 0; k < N; ++k) {
        out[ positions[k] ] = in[k];
    }
    free(positions);
}

/* Inversión de la permutación de sub-bloques */
void inverse_permute(const uint8_t *tmp, uint8_t *orig, int a, int b, int c, int seq) {
    const int N = 100;
    int lengths[4] = { a, b - a, c - b, N - c };
    int order[4][4] = {
        {3,0,1,2},
        {1,0,3,2},
        {2,0,3,1},
        {3,2,1,0}
    };

    uint8_t *subs[4];
    for(int i = 0; i < 4; ++i) subs[i] = malloc(lengths[i]);
    int pos = 0;
    for(int k = 0; k < 4; ++k) {
        int idx = order[seq][k];
        memcpy(subs[idx], tmp + pos, lengths[idx]);
        pos += lengths[idx];
    }

    memcpy(orig,        subs[0], lengths[0]);
    memcpy(orig + a,    subs[1], lengths[1]);
    memcpy(orig + b,    subs[2], lengths[2]);
    memcpy(orig + c,    subs[3], lengths[3]);

    for(int i = 0; i < 4; ++i) free(subs[i]);
}

int main() {
    const int dim = 10;
    const int N = dim * dim;
    double seed = 0.123456;
    double r = 3.99;

    // Matriz resultado definida aquí (dim x dim). Edita estos valores según tu salida.
    uint8_t diag[10][10] = {
        {19,18,29,17,28,39,16,27,38,6},
        {15,26,37,5,46,14,25,36,4,45},
        {56,13,24,35,3,44,55,66,12,23},
        {34,2,100,54,65,76,11,22,33,1},
        {99,53,64,75,86,10,21,32,43,98},
        {52,63,74,85,96,20,31,42,97,51},
        {62,73,84,95,30,41,9,50,61,72},
        {83,94,40,8,49,60,71,82,93,7},
        {48,59,70,81,92,47,58,69,80,91},
        {57,68,79,90,67,78,89,77,88,87}
    };

    // Aplanar la matriz para procesarla
    uint8_t flat_diag[N];
    for(int i = 0; i < dim; ++i)
        for(int j = 0; j < dim; ++j)
            flat_diag[i*dim + j] = diag[i][j];

    uint8_t tmp[N], orig[N];
    int cuts[3];

    // Calcular puntos de corte y secuencia caótica
    for(int i = 0; i < 3; ++i) {
        cuts[i] = 1 + (int)(next_chaotic(&seed, r) * (N - 2));
    }
    qsort(cuts, 3, sizeof(int), cmp_int);
    int a = cuts[0], b = cuts[1], c = cuts[2];
    int seq = (int)(next_chaotic(&seed, r) * 4) % 4;

    printf("Puntos de corte: a=%d, b=%d, c=%d\n", a, b, c);
    printf("Secuencia (seq) = %d\n\n", seq);

    inverse_diagonal_read(flat_diag, tmp, dim, seq);
    inverse_permute(tmp, orig, a, b, c, seq);

    print_matrix(orig, dim, "Matriz original recuperada:");
    return 0;
}