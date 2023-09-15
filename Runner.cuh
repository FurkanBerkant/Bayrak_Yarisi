#ifndef RUNNER_CUH
#define RUNNER_CUH
#include <cstdlib>
#include <curand_kernel.h>
#include <iostream>
#include <curand.h>
class Runner {
public:
    Runner(int id);
    Runner();
    int getSpeed() const;
    int getId() const;
    int getPosition() const;
    void move();
    void incrementId();

    void updateSpeed();
    __device__ void updateSpeedGPU(curandState_t* state) {
        float random = curand_uniform(state);
        int newSpeed = (int)(random * 5) + 1;
        this->speed = newSpeed;
    }

private:
    int id;
    int speed;
    int position;
};

#endif
