#include "Runner.cuh"
#include <curand.h>
#include <cstdlib>
Runner::Runner(int id) : id(id), position(0), speed(0)
{

}

Runner::Runner()
{
    id = 0;
    position = 0;
    speed = 0;
}

int Runner::getSpeed() const
{
    return speed;
}

int Runner::getId() const
{
    return id;
}

int Runner::getPosition() const
{
    return position;
}

void Runner::move()
{
    position += speed;
}

void Runner::incrementId()
{
    id++;
}

void Runner::updateSpeed()
{
    int newSpeed = (rand() % 5) + 1;
    this->speed = newSpeed;
}
