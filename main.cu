#include <iostream>
#include <vector>
#include <sstream>
#include <chrono>
#include <thread>
#include "Runner.cuh"
#include "Team.cuh"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "kernel.cu"
#include "curand.h"

const int TAKIM_SAYISI = 400;
const int KOSUCU_SAYISI = 4;
const int YARIS_UZUNLUGU = 400;
const int BITIS_NOKTASI = YARIS_UZUNLUGU;
const int NUM_BLOCKS = 400;
const int THREADS_PER_BLOCK = 4;

int main() {
    std::srand(static_cast<unsigned>(std::time(nullptr)));
    std::vector<Team*> teams;
    cudaError_t cudaStatus = cudaSuccess;
    for (int i = 0; i < TAKIM_SAYISI; ++i) {
        Team* team = new Team(i + 1, KOSUCU_SAYISI);
        teams.push_back(team);
    }


    int time_elapsed = 0;
    bool race_finished = false;

    std::cout << "Hangi takimlarin bilgilerini gormek istersiniz? (Ornek: '1 3'): ";
    std::string secilen_takimlar;
    std::getline(std::cin, secilen_takimlar);

    std::vector<int> secilen_takimlar_indeks;
    std::istringstream iss(secilen_takimlar);
    int takim_no;

    while (iss >> takim_no) {
        takim_no--;
        if (takim_no >= 0 && takim_no < TAKIM_SAYISI) {
            secilen_takimlar_indeks.push_back(takim_no);
        }
    }
    std::cout << "Yaris basladi!" << std::endl;
    Runner* d_runners;
    cudaMalloc((void**)&d_runners, TAKIM_SAYISI * KOSUCU_SAYISI * sizeof(Runner));
    curandState_t* d_states;
    cudaMalloc((void**)&d_states, TAKIM_SAYISI * KOSUCU_SAYISI * sizeof(curandState_t));

    int seed = time(NULL);
    initCurand <<<NUM_BLOCKS, THREADS_PER_BLOCK >>> (d_states, seed);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "initCurand launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    updateSpeedKernel << <NUM_BLOCKS, THREADS_PER_BLOCK >> > (d_runners, d_states);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "updateSpeedKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    while (!race_finished) {

        std::cout << "Zaman: " << time_elapsed << " saniye" << std::endl;
        for (int i = 0; i < secilen_takimlar_indeks.size(); i++) {
            int teamIndex = secilen_takimlar_indeks[i];
            teams[teamIndex]->run();
            std::cout << "Takim " << teamIndex + 1 << ":" << std::endl;

            bool all_runners_finished = true;
            for (int j = 0; j < KOSUCU_SAYISI; j++) {
                Runner& runner = teams[teamIndex]->getRunners()[j];
                //d_runners[teamIndex * KOSUCU_SAYISI + j].updateSpeedGPU(&d_states[teamIndex * KOSUCU_SAYISI + j]);
                runner.move();
                if (runner.getPosition() % 100 == 0 && runner.getPosition() > 0) {
                    runner.incrementId();
                }
                std::cout << "   Kosucu " << runner.getId()
                    << ": Pozisyon = " << runner.getPosition()
                    << "m, Hiz = " << runner.getSpeed() << "m/s" << std::endl;
                if (runner.getPosition() <= BITIS_NOKTASI) {
                    all_runners_finished = false;
                    break;
                }
            }
            if (all_runners_finished) {
                race_finished = true;
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
        }
        time_elapsed++;
    }
    for (int i = 0; i < TAKIM_SAYISI; i++) {
        delete teams[i];
    }
Error:
    cudaFree(d_runners);
    cudaFree(d_states);

    return 0;
}
