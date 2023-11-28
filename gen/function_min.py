from random import choices, random, randint
from typing import List, Tuple
import matplotlib.pyplot as plt

import tkinter as tk
from tkinter import ttk

import time
import os

FUNCTION: str = ""
POPULATION_SIZE: int = 250
GENERATION_MAX: int = 250
MUTATION_CHANCE: float = .1
MIN_X, MIN_Y, MAX_X, MAX_Y = -100, -100, 100, 100
FUNCTION = 'x**2 + 1'

class Organism:
    def __init__(self, x: float, y: float, not_calculate_value: bool=True) -> None:
        '''
        x: float – ген х
        y: float – ген y
        '''
        self.x: float = x
        self.y: float = y
        # показатель приспособленности – значение функции в точке (х, у)
        self.func_value: float = Helper.receive_function_value(x, y) if not not_calculate_value else -100_000

    def copy(self):
        newer = Organism(self.x, self.y, not_calculate_value=True)
        newer.func_value = self.func_value
        return newer

    def __repr__(self) -> str:
        return f'({self.x}, {self.y}, {self.func_value})'


class Population:
    def __init__(self, organisms: List[Organism]) -> None:
        '''
        organisms: list – особи в данной популяции
        '''
        self.organisms: List[Organism] = organisms

    @staticmethod
    def crossing(first: Organism, second: Organism) -> Organism:
        '''
        Скрещивание двух особей в виде (first.x + second.x) / 2 = new.x
        first, seconds – особи
        '''
        if first.func_value == second.func_value:
            return Organism(first.x, first.y, not_calculate_value=False)
        return Organism( (first.x + second.x) / 2, (first.y + second.y) / 2, not_calculate_value=False)

    def choice_part_crossing(self) -> List[Tuple]:
        '''
        Отбор особей. Выбор пар особей для скрещивания
        '''

        gifted: List[(Organism, Organism)] = []
        
        best_organisms = sorted(self.organisms, key=lambda organism: organism.func_value)[0:10]
        for best_organism in best_organisms:
            gifted.append((best_organism, best_organism))
        for _ in range(10,len(self.organisms)):
            # from 4 random organisms choice only 2 for crossing'em
            concurrents: List[Organism] = choices(self.organisms, k=3)
            concurrents.sort(key=lambda organism: organism.func_value)

            gifted.append((concurrents[0], concurrents[1]))

        return gifted
    
    @staticmethod
    def mutation(organism: Organism) -> None:
        '''
        Мутация
        organism – особь, подвергающая мутации
        '''
        if random() <= MUTATION_CHANCE:
            organism.x += random() * ((-1) * randint(0, 1))
            organism.y += random() * ((-1) * randint(0, 1))
            organism.func_value = Helper.receive_function_value(organism.x, organism.y)

    def __repr__(self) -> str:
        return repr(Organism)

 
class Helper:
    def __init__(self) -> None:
        pass

    @staticmethod
    def receive_function_value(x: float, y: float) -> float:
        x = x; y = y
        return eval(FUNCTION)

    @staticmethod
    def random_organism(minx: float, miny: float, maxx: float, maxy: float) -> Organism:
        return Organism( (maxx - minx) * random() + minx, (maxy - miny) * random() + miny, not_calculate_value=False )

    @staticmethod
    def random_population(minx: float, miny: float, maxx: float, maxy: float) -> Population:
        return Population([Helper.random_organism(minx, miny, maxx, maxy) for _ in range(POPULATION_SIZE)])


def main():
    population: Population = Helper.random_population(MIN_X, MIN_Y, MAX_X, MAX_Y)
    print(population.organisms)

    count_generation = 0
    func_values = []
    xs, ys = [], []

    while count_generation < GENERATION_MAX:
        count_generation += 1
        gifted = population.choice_part_crossing()
        for i in range(POPULATION_SIZE):
            gifted[i] = Population.crossing(gifted[i][0], gifted[i][1])
            Population.mutation(gifted[i])

        population = Population(gifted)
        xs.append(min(population.organisms, key=lambda organism:organism.func_value).x)
        ys.append(min(population.organisms, key=lambda organism:organism.func_value).y)
        func_values.append(min(population.organisms, key=lambda organism:organism.func_value).func_value)

    print(count_generation)
    print(len(population.organisms))
    print(min(population.organisms, key=lambda organism: organism.func_value))
    
    # for organism in population.organisms:
    #     xs.append(organism.x)
    #     ys.append(organism.y)

    # plt.scatter(xs, ys,color='green', s=1)
    # # plt.plot(func_values, color='red')
    # plt.xlabel('x')
    # plt.ylabel('y')
    # plt.show()

    return (xs, ys, func_values,)

def run_algorithm():
    global FUNCTION, MIN_X, MIN_Y, MAX_X, MAX_Y, GENERATION_MAX, POPULATION_SIZE, MUTATION_CHANCE
    for item in results_table.get_children():
        results_table.delete(item)

    minx_value = minx_entry.get().strip()
    if len(minx_value) == 0: MIN_X = -10
    else: MIN_X = float(minx_value)
    miny_value = miny_entry.get().strip()
    if len(miny_value) == 0: MIN_Y = -10
    else: MIN_Y = float(miny_value)
    maxx_value = maxx_entry.get().strip()
    if len(maxx_value) == 0: MAX_X = 10
    else: MAX_X = float(maxx_value)
    maxy_value = maxy_entry.get().strip()
    if len(maxy_value) == 0: MAX_Y = 10
    else: MAX_Y = float(maxy_value)
    iteration_count_value = iteration_count_entry.get().strip()
    if len(iteration_count_value) == 0: GENERATION_MAX = 10000
    else: GENERATION_MAX = int(iteration_count_value)
    population_size_value = population_size_entry.get().strip()
    if len(population_size_value) == 0: POPULATION_SIZE = 50
    else: POPULATION_SIZE = int(population_size_value)
    mutation_chance_value = mutation_chance_entry.get().strip()
    if len(mutation_chance_value) == 0: MUTATION_CHANCE = 0.1
    else: MUTATION_CHANCE = float(mutation_chance_value)
    function_value = function_entry.get().strip()
    if len(function_value) == 0: FUNCTION = '100*(x-y**2)**2 + (1-y)**2'
    else: FUNCTION = function_value
    
    start = time.time()
    values = main()
    end = time.time()
    print('TIME:', end - start)

    plt.scatter(values[0], values[1],color='green', s=1)
    # plt.plot(func_values, color='red')
    plt.xlabel('x')
    plt.ylabel('y')
    plt.show()
    min = (10000, 10000, 10000) 
    for i in range(len(values[0])):
        if float(values[2][i]) < float(min[2]):
            min = values[0][i], values[1][i],values[2][i]
        results_table.insert('', 'end', values=(str(i + 1), values[0][i], values[1][i], values[2][i]))
    results_table.insert('', 'end', values=('BEST', values[0][i], values[1][i], values[2][i]))
    # plt.plot(x, y)
    # plt.xlabel('x')
    # plt.ylabel('y')
    # plt.show()

root = tk.Tk()
root.title("Particle Swarm Optimization")

minx_label = ttk.Label(root, text="MINX")
minx_label.grid(row=0, column=0, padx=10, pady=5)
minx_entry = ttk.Entry(root)
minx_entry.grid(row=0, column=1, padx=10, pady=5)

miny_label = ttk.Label(root, text="MINY")
miny_label.grid(row=1, column=0, padx=10, pady=5)
miny_entry = ttk.Entry(root)
miny_entry.grid(row=1, column=1, padx=10, pady=5)

maxx_label = ttk.Label(root, text="MAXX")
maxx_label.grid(row=2, column=0, padx=10, pady=5)
maxx_entry = ttk.Entry(root)
maxx_entry.grid(row=2, column=1, padx=10, pady=5)

maxy_label = ttk.Label(root, text="MAXY")
maxy_label.grid(row=3, column=0, padx=10, pady=5)
maxy_entry = ttk.Entry(root)
maxy_entry.grid(row=3, column=1, padx=10, pady=5)

iteration_count_label = ttk.Label(root, text="ITERATION COUNT")
iteration_count_label.grid(row=0, column=2, padx=10, pady=5)
iteration_count_entry = ttk.Entry(root)
iteration_count_entry.grid(row=0, column=3, padx=10, pady=5)

population_size_label = ttk.Label(root, text="POPULATION SIZE")
population_size_label.grid(row=1, column=2, padx=10, pady=5)
population_size_entry = ttk.Entry(root)
population_size_entry.grid(row=1, column=3, padx=10, pady=5)

mutation_chance_label = ttk.Label(root, text="MUTATION CHANCE")
mutation_chance_label.grid(row=2, column=2, padx=10, pady=5)
mutation_chance_entry = ttk.Entry(root)
mutation_chance_entry.grid(row=2, column=3, padx=10, pady=5)

function_label = ttk.Label(root, text="FUNCTION")
function_label.grid(row=3, column=2, padx=10, pady=5)
function_entry = ttk.Entry(root)
function_entry.grid(row=3, column=3, padx=10, pady=5)

run_button = ttk.Button(root, text="Run Algorithm", command=run_algorithm)
run_button.grid(row=4, column=0, columnspan=4, pady=10)

columns = ('iter', 'x', 'y', 'score')
results_table = ttk.Treeview(root, columns=columns, show='headings')

for col in columns:
    results_table.heading(col, text=col)
    results_table.column(col, width=80)

results_table.grid(row=5, column=0, columnspan=4, padx=10, pady=10)

root.mainloop()