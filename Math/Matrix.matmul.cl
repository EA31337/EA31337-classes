#define WIDTH 1
#define TSM 128                // The tile-size in dimension M
#define TSN 128                // The tile-size in dimension N
#define TSK 16                 // The tile-size in dimension K
#define WPTM 8                 // The work-per-thread in dimension M
#define WPTN 8                 // The work-per-thread in dimension N
#define RTSM (TSM/WPTM)        // The reduced tile-size in dimension M
#define RTSN (TSN/WPTN)        // The reduced tile-size in dimension N
#define LPTA ((TSK*TSM)/(RTSM*RTSN)) // Loads-per-thread for A
#define LPTB ((TSK*TSN)/(RTSM*RTSN)) // Loads-per-thread for B
__kernel void matmul(const int M, const int N, const int K,
                      const __global double* A,
                      const __global double* B,
                      __global float* C) {

    // Thread identifiers
    const int tidm = get_local_id(0); // Local row ID (max: TSM/WPTM)
    const int tidn = get_local_id(1); // Local col ID (max: TSN/WPTN)
    const int offsetM = TSM*get_group_id(0); // Work-group offset
    const int offsetN = TSN*get_group_id(1); // Work-group offset

    // Local memory to fit a tile of A and B
    __local float Asub[TSK][TSM];
    __local float Bsub[TSK][TSN];

    // Allocate register space
    float Areg;
    float Breg[WPTN];
    float acc[WPTM][WPTN];

    // Initialise the accumulation registers
    for (int wm=0; wm<WPTM; wm++) {
        for (int wn=0; wn<WPTN; wn++) {
            acc[wm][wn] = 0.0f;
        }
    }

    // Loop over all tiles
    int numTiles = K/TSK;
    for (int t=0; t<numTiles; t++) {

        // Load one tile of A and B into local memory
        for (int la=0; la<LPTA/WIDTH; la++) {
            int tid = tidn*RTSM + tidm;
            int id = la*RTSN*RTSM + tid;
            int row = id % (TSM/WIDTH);
            int col = id / (TSM/WIDTH);

            // Load the values (wide vector load)
            int tiledIndex = TSK*t + col;
            double vecA = A[tiledIndex*(M/WIDTH) + offsetM/WIDTH + row];
            double vecB = B[tiledIndex*(N/WIDTH) + offsetN/WIDTH + row];

            // Store the loaded vectors into local memory
            #if WIDTH == 1
                Asub[col][row] = vecA;
                Asub[col][row] = vecA;
            #elif WIDTH == 2
                Asub[col][WIDTH*row + 0] = vecA.x;
                Asub[col][WIDTH*row + 1] = vecA.y;
            #elif WIDTH == 4
                Asub[col][WIDTH*row + 0] = vecA.x;
                Asub[col][WIDTH*row + 1] = vecA.y;
                Asub[col][WIDTH*row + 2] = vecA.z;
                Asub[col][WIDTH*row + 3] = vecA.w;
            #endif
            #if WIDTH == 1
                Bsub[col][row] = vecB;
                Bsub[col][row] = vecB;
            #elif WIDTH == 2
                Bsub[col][WIDTH*row + 0] = vecB.x;
                Bsub[col][WIDTH*row + 1] = vecB.y;
            #elif WIDTH == 4
                Bsub[col][WIDTH*row + 0] = vecB.x;
                Bsub[col][WIDTH*row + 1] = vecB.y;
                Bsub[col][WIDTH*row + 2] = vecB.z;
                Bsub[col][WIDTH*row + 3] = vecB.w;
            #endif
        }

        // Synchronise to make sure the tile is loaded
        barrier(CLK_LOCAL_MEM_FENCE);

        // Loop over the values of a single tile
        for (int k=0; k<TSK; k++) {

            // Cache the values of Bsub in registers
            for (int wn=0; wn<WPTN; wn++) {
                int col = tidn + wn*RTSN;
                Breg[wn] = Bsub[k][col];
            }

            // Perform the computation
            for (int wm=0; wm<WPTM; wm++) {
                int row = tidm + wm*RTSM;
                Areg = Asub[k][row];
                for (int wn=0; wn<WPTN; wn++) {
                    acc[wm][wn] += Areg * Breg[wn];
                }
            }
        }

        // Synchronise before loading the next tile
        barrier(CLK_LOCAL_MEM_FENCE);
    }

    // Store the final results in C
    for (int wm=0; wm<WPTM; wm++) {
        int globalRow = offsetM + tidm + wm*RTSM;
        for (int wn=0; wn<WPTN; wn++) {
            int globalCol = offsetN + tidn + wn*RTSN;
            C[globalCol*M + globalRow] = acc[wm][wn];
        }
    }
}
