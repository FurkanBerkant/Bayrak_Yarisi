#ifndef TEAM_CUH
#define TEAM_CUH
#include "Runner.cuh"
#include <vector>
#include <iostream>
class Team {
public:
    Team(int id, int numRunners);
    int getId() const;
    std::vector<Runner>& getRunners();
    void run();

private:
    int id;
    std::vector<Runner> runners;
};

#endif