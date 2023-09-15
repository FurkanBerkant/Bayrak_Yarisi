// Runner.cu kaynak dosyası
#include "Team.cuh"
#include <curand.h>
#include <cstdlib>

Team::Team(int id, int numRunners) : id(id) {
    for (int i = 0; i < numRunners; i++) {
        runners.push_back(Runner(i + 1));
    }
}


std::vector<Runner>& Team::getRunners()
{
    return runners;
}

void Team::run()
{
    for (int i = 0; i < runners.size(); i++) {
        runners[i].move();
    }
}


int Team::getId() const
{
    return id;
}
