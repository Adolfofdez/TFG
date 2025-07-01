#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* -------------------------------------------------------------
   Estado interno: X[0]=Xi1, X[1]=Xi2, X[2]=Xi3, cada uno 3×32 bits.
   También guardamos xₙ y r del mapa logístico.
   ------------------------------------------------------------- */
typedef struct {
    uint32_t X[3][3];
    double   logistic_x;
    double   logistic_r;
} InternalState;

/* -------------------------------------------------------------
   Mapa logístico: xₙ₊₁ = r·xₙ·(1–xₙ), escalado a 32 bits.
   ------------------------------------------------------------- */
static uint32_t chaotic_map(InternalState *st) {
    st->logistic_x = st->logistic_r * st->logistic_x * (1.0 - st->logistic_x);
    return (uint32_t)(st->logistic_x * 4294967295.0);
}

/* -------------------------------------------------------------
   Inicialización del estado interno con:
     - keys[4]      : K1..K4 (decimal)
     - constants[2] : C1, C2 (decimal)
     - s_init[3]    : S1..S3 en [0,1]
     - r            : parámetro logístico
   ------------------------------------------------------------- */
void init_internal_state(InternalState *st,
                         uint32_t keys[4],
                         uint32_t constants[2],
                         double   s_init[3],
                         double   r)
{
    st->X[0][0] = keys[0];
    st->X[0][1] = keys[1];
    st->X[0][2] = keys[2];

    st->X[1][0] = keys[3];
    st->X[1][1] = constants[0];
    st->X[1][2] = constants[1];

    for(int j = 0; j < 3; j++) {
        st->X[2][j] = (uint32_t)(s_init[j] * 4294967295.0);
    }

    st->logistic_x = s_init[0];
    st->logistic_r = r;
}

/* -------------------------------------------------------------
   Scrambling de un bloque:
     - data_in  : puntero a palabras de entrada
     - data_out : puntero a palabras de salida
     - words    : número total de palabras (32 bits)
   Procesa chunks de 9 palabras, y un chunk final parcial.
   ------------------------------------------------------------- */
void scramble_block(InternalState *st,
                    const uint32_t *data_in,
                    uint32_t *data_out,
                    size_t words)
{
    size_t full = words / 9;
    size_t rem  = words % 9;
    size_t idx  = 0;

    for(size_t chunk = 0; chunk < full; ++chunk) {
        uint32_t Y[3][3];
        // Eqs. (16)-(18)
        for(int j = 0; j < 3; ++j)
            Y[2][j] = st->X[2][j] ^ (st->X[0][j] + st->X[1][j]);
        for(int j = 0; j < 3; ++j)
            Y[1][j] = st->X[1][j] ^ (Y[2][j] + st->X[0][j]);
        for(int j = 0; j < 3; ++j)
            Y[0][j] = st->X[0][j] ^ (Y[1][j] + Y[2][j]);
        // Expansión de clave
        Y[0][0] += chaotic_map(st);
        Y[1][1] += chaotic_map(st);
        Y[2][2] += chaotic_map(st);
        // XOR con 9 palabras
        for(int j = 0; j < 3; ++j) {
            data_out[idx +     j] = data_in[idx +     j] ^ Y[0][j];
            data_out[idx + 3 + j] = data_in[idx + 3 + j] ^ Y[1][j];
            data_out[idx + 6 + j] = data_in[idx + 6 + j] ^ Y[2][j];
        }
        idx += 9;
        memcpy(st->X, Y, sizeof(Y));
    }

    if (rem > 0) {
        uint32_t Y[3][3], Yf[9];
        for(int j = 0; j < 3; ++j)
            Y[2][j] = st->X[2][j] ^ (st->X[0][j] + st->X[1][j]);
        for(int j = 0; j < 3; ++j)
            Y[1][j] = st->X[1][j] ^ (Y[2][j] + st->X[0][j]);
        for(int j = 0; j < 3; ++j)
            Y[0][j] = st->X[0][j] ^ (Y[1][j] + Y[2][j]);
        Y[0][0] += chaotic_map(st);
        Y[1][1] += chaotic_map(st);
        Y[2][2] += chaotic_map(st);
        // Aplanar Y
        for(int j = 0; j < 3; ++j)      Yf[j]     = Y[0][j];
        for(int j = 0; j < 3; ++j)      Yf[3 + j] = Y[1][j];
        for(int j = 0; j < 3; ++j)      Yf[6 + j] = Y[2][j];
        // XOR parcial
        for(size_t j = 0; j < rem; ++j)
            data_out[idx + j] = data_in[idx + j] ^ Yf[j];
        memcpy(st->X, Y, sizeof(Y));
    }
}

int main(void) {
    // Ejemplo de claves y constantes (decimal)
    uint32_t keys[4]      = { 19088743, 2309737967, 4275878552u, 1985229328 };
    uint32_t constants[2] = { 252645135, 4042322160u };
    double   seeds[3]     = { 0.123456, 0.654321, 0.111111 };
    double   r = 3.99;

    InternalState st;
    init_internal_state(&st, keys, constants, seeds, r);

    // Matriz 10×10 plain con valores 1..100
    uint32_t plain[10][10], cipher[10][10];
    for(int i = 0; i < 10; ++i)
        for(int j = 0; j < 10; ++j)
            plain[i][j] = i*10 + j + 1;

    // Scramble de los 100 elementos
    scramble_block(&st,
                   &plain[0][0],
                   &cipher[0][0],
                   100);

    // Imprimir resultado
    printf("Scrambled matrix:\n");
    for(int i = 0; i < 10; ++i) {
        for(int j = 0; j < 10; ++j) {
            printf("%12u", cipher[i][j]);
        }
        printf("\n");
    }

    return 0;
}
