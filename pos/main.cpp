#include <iostream>
#include <string>
#include <vector>
#include <random>
#include <fstream>
#include "fparser.hh"
using namespace std;

string FUNCTION = "100*(x-y^2)^2 + (16-y)^2";
double MAX_X = 100, MAX_Y = 100, MIN_X = -100, MIN_Y = -100;
double MAX_SPEED = 10;
double FI_LOCAL = 2, FI_GLOBAL = 2;
double SIZE_SWARM = 50;
double COUNT_ITERATION = 10000;

/*
 #bestx,besty,bestscore
 ;
 ...
 #x,y,score
 */
string RESULT_PATH = "log.log";

class Function {
private:
    FunctionParser fparser;
    
public:
    Function() {
        fparser.Parse(FUNCTION, "x,y");
    }
    
    double receive_value(const double *parameters) {
        return fparser.Eval(parameters);
    }
};

Function func;

class Particle {
private:
    vector<double> velocity;
    vector<double> current_position;
    double current_score;
    vector<double> local_best_position;
    double local_best_score;
    vector<double> global_best_position;
    
    vector<double> success;
    
    random_device rd;
    mt19937 gen;
    uniform_real_distribution<double> dis;
    
public:
    Particle() {
        gen = mt19937(rd());
        dis = uniform_real_distribution<double>(0.0, 1.0);
        
        velocity = {dis(gen) * MAX_SPEED, dis(gen) * MAX_SPEED};
        
        current_position = {dis(gen) * (MAX_X - MIN_X) + MIN_X, dis(gen) * (MAX_Y - MIN_Y) + MIN_Y};
        
        const double values[] = {current_position[0], current_position[1]};
        current_score = func.receive_value(values);
        
        local_best_position = current_position;
        local_best_score = current_score;
        global_best_position = {};
        success = {0, 0};
    }
    
    void set_global_best_position(vector<double>& position) {
        global_best_position = position;
    }
    vector<double> get_global_best_position() {
        return global_best_position;
    }
    
    vector<double> get_local_best_position() {
        return local_best_position;
    }
    
    double iterate(double& num_iterate) {
        double w = 0.4 + 0.5 * (1 - num_iterate / COUNT_ITERATION) / (1 + 10 * (num_iterate / COUNT_ITERATION));
        for (int i = 0; i < velocity.size(); i++) {
            velocity[i] = w * velocity[i] + FI_LOCAL * dis(gen) * (local_best_position[i] - current_position[i])
            + FI_GLOBAL * dis(gen) * (global_best_position[i] - current_position[i]);
            
            if (velocity[i] > MAX_SPEED) velocity[i] = MAX_SPEED;
            current_position[i] += velocity[i];
        }
        
        const double values[] = {current_position[0], current_position[1]};
        
        current_score = func.receive_value(values);
        if (current_score < local_best_score) {
            local_best_position = current_position;
            local_best_score = current_score;
            
        }
        
        return current_score;
    }
};

class Swarm {
public:
    Swarm() {
        swarm = {};
        for (int i = 0; i < SIZE_SWARM; i++) {
            Particle* particle = new Particle();
            swarm.push_back(particle);
        }
        global_best_position = {10000, 10000};
        const double values[] = {10000, 10000};
        global_best_score = func.receive_value(values);
    }
    
    void start() {
        ofstream result(RESULT_PATH);
        for (double i = 0; i < COUNT_ITERATION; i++) {
            for (Particle* particle : swarm) {
                particle->set_global_best_position(global_best_position);
                double score = particle->iterate(i);
                if (score < global_best_score) {
                    global_best_score = score;
                    global_best_position = particle->get_local_best_position();
                }
            }
//            cout << '#' << global_best_position[0] << ',' << global_best_position[1] << ','<< global_best_score << endl;
            result << '#' << global_best_position[0] << ',' << global_best_position[1] << ','<< global_best_score << endl;
            
        }
        cout << global_best_position[0] << ' ' << global_best_position[1] << endl;
        cout << global_best_score << endl;
        
    }
    
private:
    vector<Particle*> swarm;
    vector<double> global_best_position;
    double global_best_score;
};


int main(int argc, char** argv) {
    if (argc != 9) {
        cout << "Arguments count doesn't equals to 8\nContinue with default parameters\nGiven " << argc - 1 << " arguents\n";
    } else {
        cout << "Given 8 arguments\n";
        MAX_X = stod(argv[1]); cout << MAX_X << endl;
        MAX_Y = stod(argv[2]); cout << MAX_Y << endl;
        MIN_X = stod(argv[3]); cout << MIN_X << endl;
        MIN_Y = stod(argv[4]); cout << MIN_Y << endl;
        
        MAX_SPEED = stod(argv[5]); cout << MAX_SPEED << endl;
        SIZE_SWARM = stod(argv[6]); cout << SIZE_SWARM << endl;
        COUNT_ITERATION = stod(argv[7]); cout << COUNT_ITERATION << endl;
        FUNCTION = argv[8]; cout << FUNCTION << endl;
    }
    func = Function();
    Swarm swarm = Swarm();
    swarm.start();
}
