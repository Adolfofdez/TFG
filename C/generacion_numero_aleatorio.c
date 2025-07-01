/* Generador de números pseudoaleatorios mediante el mapa logístico
 * x_{n+1} = r * x_n * (1 - x_n)
 * r en (3.57,4] para comportamiento caótico
 * La ejecución es .\a.exe parametro_r semilla_inicial valor_superior cantidad_numeros
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define DEFAULT_R 3.99
#define DEFAULT_SEED 0.5
#define DEFAULT_SKIP 1000

// Estructura del generador
typedef struct {
    double r;
    double x;
} LogisticMapRNG;

// Inicializa el generador con parámetro r y semilla x0
void init_rng(LogisticMapRNG *rng, double r, double seed) {
    rng->r = r;
    rng->x = seed;
    // Descartar iteraciones iniciales
    for(int i = 0; i < DEFAULT_SKIP; i++) {
        rng->x = rng->r * rng->x * (1.0 - rng->x);
    }
}

// Genera el siguiente número en [0,1)
double next_double(LogisticMapRNG *rng) {
    rng->x = rng->r * rng->x * (1.0 - rng->x);
    return rng->x;
}

// Genera un número entero en [0, max)
unsigned int next_uint(LogisticMapRNG *rng, unsigned int max) {
    return (unsigned int)(next_double(rng) * max);
}

int main(int argc, char *argv[]) {
    double r = DEFAULT_R;
    double seed = DEFAULT_SEED;
    unsigned int max = 100;
    unsigned long count = 10;
    clock_t inicio, fin;
    double tiempo_cpu;
    inicio = clock();
    // Parsear argumentos: ./prog r seed max count
    if(argc >= 2) r = atof(argv[1]);
    if(argc >= 3) seed = atof(argv[2]);
    if(argc >= 4) max = (unsigned int)atoi(argv[3]);
    if(argc >= 5) count = strtoul(argv[4], NULL, 10);

    LogisticMapRNG rng;
    init_rng(&rng, r, seed);

    for(unsigned long i = 0; i < count; i++) {
        printf("%u\n", next_uint(&rng, max));
    }
    fin = clock();

    tiempo_cpu = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
    printf("Tiempo de CPU: %f segundos\n", tiempo_cpu);

    return 0;
}
