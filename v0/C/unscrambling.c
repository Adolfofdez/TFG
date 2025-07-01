#include <stdio.h>
#include <stdint.h>
#include <string.h>

/* -------------------------------------------------------------
   Estado interno: X[0]=Xi1, X[1]=Xi2, X[2]=Xi3, cada uno 3×32 bits.
   También guardamos logistic_x y logistic_r.
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
   Inicialización (idéntica al scrambling)
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

    for(int j = 0; j < 3; j++)
        st->X[2][j] = (uint32_t)(s_init[j] * 4294967295.0);

    st->logistic_x = s_init[0];
    st->logistic_r = r;
}

/* -------------------------------------------------------------
   Scramble (y su inverso, XOR involutivo)
   ------------------------------------------------------------- */
void scramble_block(InternalState *st,
                    const uint32_t *data_in,
                    uint32_t       *data_out,
                    size_t          words)
{
    size_t full = words / 9;
    size_t rem  = words % 9;
    size_t idx  = 0;

    for(size_t chunk = 0; chunk < full; ++chunk) {
        uint32_t Y[3][3];
        for(int j = 0; j < 3; ++j)
            Y[2][j] = st->X[2][j] ^ (st->X[0][j] + st->X[1][j]);
        for(int j = 0; j < 3; ++j)
            Y[1][j] = st->X[1][j] ^ (Y[2][j] + st->X[0][j]);
        for(int j = 0; j < 3; ++j)
            Y[0][j] = st->X[0][j] ^ (Y[1][j] + Y[2][j]);

        Y[0][0] += chaotic_map(st);
        Y[1][1] += chaotic_map(st);
        Y[2][2] += chaotic_map(st);

        for(int j = 0; j < 3; ++j) {
            data_out[idx +     j] = data_in[idx +     j] ^ Y[0][j];
            data_out[idx + 3 + j] = data_in[idx + 3 + j] ^ Y[1][j];
            data_out[idx + 6 + j] = data_in[idx + 6 + j] ^ Y[2][j];
        }
        idx += 9;
        memcpy(st->X, Y, sizeof(Y));
    }

    if (rem) {
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

        for(int j = 0; j < 3; ++j)      Yf[j]     = Y[0][j];
        for(int j = 0; j < 3; ++j)      Yf[3 + j] = Y[1][j];
        for(int j = 0; j < 3; ++j)      Yf[6 + j] = Y[2][j];

        for(size_t j = 0; j < rem; ++j)
            data_out[idx + j] = data_in[idx + j] ^ Yf[j];
        memcpy(st->X, Y, sizeof(Y));
    }
}

/* -------------------------------------------------------------
   Unscramble = misma función
   ------------------------------------------------------------- */
static inline void unscramble_block(InternalState *st,
                                    const uint32_t *cipher_in,
                                    uint32_t       *plain_out,
                                    size_t          words)
{
    scramble_block(st, cipher_in, plain_out, words);
}

int main(void) {
    InternalState st;

    /* Usa exactamente las mismas claves, constantes y semillas */
    uint32_t keys[4]      = { 19088743, 2309737967u, 4275878552u, 1985229328u };
    uint32_t constants[2] = { 252645135u, 4042322160u };
    double   seeds[3]     = { 0.123456, 0.654321, 0.111111 };
    double   r            = 3.99;

    /* Copia aquí la matriz “cipher” que generó tu programa de scrambling */
    uint32_t cipher[10][10] = {
          {4070224291  ,2391321709,   150663917 ,  474271712 , 3263376093   , 40491449 , 1760409738 , 1060849737  , 147734311 , 2772892755},
            {585346263  , 445497779 , 1149773124 ,  357102494  , 248266689 , 1714567451  ,1848680215 , 2363967123  ,2727839705 , 3778081672},
            {1858715579 , 1909207133 , 1971539648,  3464967965 , 2415728816 , 1444691824 , 3286725328 , 3007064332 , 1949452538  ,3480504363},
            {1341790418 , 2353654969 , 2735108866,  2610864286 ,   11042106 ,  501265645 , 2637073676 , 2383514995 , 3302390884 ,   69145236},
            {4079558480 , 2617779407 ,2561204554  ,  13912245 , 2274156482 , 3900418750 , 3943292502 , 3550814917 , 3540719904 , 3352559917},
            {807460828 ,  971341488,  2179916898 , 1220357643 , 3305880784 , 3860171111,  2849938998  ,3117711006 ,  319122528  , 788566045},
            {2187574552 ,  858995697 , 4236533229 , 2344066862 , 2339472154,  2890623999 , 2019245426  , 615196285 , 3778707861 , 4236478184},
            {3391737394  , 598692817 , 2176810029  , 271759351 , 3309047267 , 4229154018 ,  731794730 , 3142363215 , 4170275454 , 2050320305},
            {3600048956  ,2310392513 , 2875133252  , 856501965 , 4212282236 , 2012430727 , 2685684794 , 2235702139 , 1105486492 , 1550259486},
            {276645179  ,2009311625 , 3263369276 , 1882030661 , 3527190881 , 1648873686  ,  25822974 , 1656106063 , 1981651757 , 3442359144}
    };

    uint32_t recovered[10][10];

    /* 1) Inicializa UNA sola vez, igual que en el scrambling */
    init_internal_state(&st, keys, constants, seeds, r);

    /* 2) Descifra TODO el bloque de 100 palabras de una vez */
    unscramble_block(&st,
                     &cipher[0][0],
                     &recovered[0][0],
                     100);

    /* 3) Imprime la matriz recuperada */
    printf("Recovered plain matrix:\n");
    for(int i = 0; i < 10; i++) {
        for(int j = 0; j < 10; j++)
            printf("%4u ", recovered[i][j]);
        printf("\n");
    }

    return 0;
}
