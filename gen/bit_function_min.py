from random import choices, random, randint
from typing import List, Tuple
import matplotlib.pyplot as plt

import tkinter as tk
from tkinter import ttk

import time
import os

FUNCTION: str = ""
POPULATION_SIZE: int = 10
GENERATION_MAX: int = 250
MUTATION_CHANCE: float = .1
MIN_X, MIN_Y, MAX_X, MAX_Y = -100, -100, 100, 100
FUNCTION = 'x**2 + 1'
SCALING_FACTOR = 10**7

class Organism:
    def __init__(self, x: list, y: list, not_calculate_value: bool=True) -> None:
        self.x: list = Helper.binary_to_gray(x)
        self.y: list = Helper.binary_to_gray(y)
        self.func_value: float = Helper.receive_function_value(x, y) if not not_calculate_value else -100_000
    
    def __repr__(self) -> str:
        return f'({self.x}, {self.y}, {self.func_value})'


class Population:
    def __init__(self, organisms: List[Organism]) -> None:
        self.organisms: List[Organism] = organisms

    @staticmethod
    def crossing(first: Organism, second: Organism) -> Organism:
        if first.func_value == second.func_value:
            return Organism(first.x, first.y, not_calculate_value=False)
        
        cross_point = randint(1, len(first.x) - 1)
        fx = Helper.gray_to_binary(first.x)
        fy = Helper.gray_to_binary(first.y)
        sx = Helper.gray_to_binary(second.x)
        sy = Helper.gray_to_binary(second.y)

        return Organism( fx[:cross_point] + sx[cross_point:], fy[:cross_point] + sy[cross_point:], not_calculate_value=False)

    def choice_part_crossing(self) -> List[Tuple]:
        gifted: List[(Organism, Organism)] = []
        
        best_organism = sorted(self.organisms, key=lambda organism: organism.func_value)[0]
        gifted.append((best_organism, best_organism))
        for _ in range(1,len(self.organisms)):
            # from 4 random organisms choice only 2 for crossing'em
            concurrents: List[Organism] = choices(self.organisms, k=3)
            concurrents.sort(key=lambda organism: organism.func_value)

            gifted.append((concurrents[0], concurrents[1]))

        return gifted
    
    @staticmethod
    def mutation(organism: Organism) -> None:
        # print(len(organism.x), len(organism.y))
        for i in range(len(organism.x)):
            if random() < MUTATION_CHANCE:
                organism.x[i] = 1 - organism.x[i]
                organism.y[i] = 1 - organism.y[i]
        organism.func_value = Helper.receive_function_value(Helper.gray_to_binary(organism.x),
                                                            Helper.gray_to_binary(organism.y))

    def __repr__(self) -> str:
        return repr(Organism)

 
class Helper:
    def __init__(self) -> None:
        pass

    @staticmethod
    def binary_to_gray(binary: list) -> list:
        gray = [binary[0]] 

        for i in range(1, len(binary)):
            gray_bit = binary[i] ^ binary[i - 1]
            gray.append(gray_bit)

        return gray

    @staticmethod
    def gray_to_binary(gray: list) -> list:
        binary = [gray[0]]

        for i in range(1, len(gray)):
            binary_bit = binary[i - 1] ^ gray[i]
            binary.append(binary_bit)

        return binary

    @staticmethod
    def binary_to_float(x: list) -> float:
        x = int(''.join(map(str, x)), 2)
        x /= SCALING_FACTOR
        return x

    @staticmethod
    def receive_function_value(x: list, y: list) -> float:
        x = int(''.join(map(str, x)), 2)
        y = int(''.join(map(str, y)), 2)

        x /= SCALING_FACTOR
        y /= SCALING_FACTOR

        return eval(FUNCTION)

    @staticmethod
    def random_organism(minx: float, miny: float, maxx: float, maxy: float) -> Organism:
        x = (maxx - minx) * random() + minx
        y = (maxy - miny) * random() + miny
        x = bin(int(x * SCALING_FACTOR))[2:]
        y = bin(int(y * SCALING_FACTOR))[2:]

        if x.startswith('b'):
            x = x[1:]
        if y.startswith('b'):
            y = y[1:]

        x = list(map(int, x))
        y = list(map(int, y))

        diff = 32 - len(x)
        if diff < 0: 
            print("WARNING X")
            return -1
        if diff > 0:
            for i in range(diff):
                x = [0] + x
        diff = 32 - len(y)
        if diff < 0: 
            print("WARNING Y")
            return -1
        if diff > 0:
            for i in range(diff):
                y = [0] + y

        # print(len(x), len(y))
        # print(x, y)

        return Organism(x, y, not_calculate_value=False)

    @staticmethod
    def random_population(minx: float, miny: float, maxx: float, maxy: float) -> Population:
        return Population([Helper.random_organism(minx, miny, maxx, maxy) for _ in range(POPULATION_SIZE)])


def main():
    population: Population = Helper.random_population(MIN_X, MIN_Y, MAX_X, MAX_Y)
    # print(population.organisms)

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
        xs.append(Helper.binary_to_float(Helper.gray_to_binary(min(population.organisms, key=lambda organism:organism.func_value).x)))
        ys.append(Helper.binary_to_float(Helper.gray_to_binary(min(population.organisms, key=lambda organism:organism.func_value).y)))
        func_values.append(min(population.organisms, key=lambda organism:organism.func_value).func_value)

    print(count_generation)
    print(len(population.organisms))
    print(min(func_values))
    
    print(len(xs), len(ys), len(func_values))
    # # plt.plot(xs, ys)
    # plt.scatter(xs, ys, s=5)
    # # # plt.plot(func_values, color='red')
    # plt.xlabel('x')
    # plt.ylabel('y')
    # plt.xlim(0, 5)
    # plt.ylim(0, 5)
    # plt.show()

    return (xs, ys, func_values,)

def run_algorithm():
    global FUNCTION, MIN_X, MIN_Y, MAX_X, MAX_Y, GENERATION_MAX, POPULATION_SIZE, MUTATION_CHANCE
    for item in results_table.get_children():
        results_table.delete(item)

    minx_value = minx_entry.get().strip()
    if len(minx_value) == 0: MIN_X = 0
    else: MIN_X = float(minx_value)
    miny_value = miny_entry.get().strip()
    if len(miny_value) == 0: MIN_Y = 0
    else: MIN_Y = float(miny_value)
    maxx_value = maxx_entry.get().strip()
    if len(maxx_value) == 0: MAX_X = 400
    else: MAX_X = float(maxx_value)
    maxy_value = maxy_entry.get().strip()
    if len(maxy_value) == 0: MAX_Y = 400
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
    if len(function_value) == 0: FUNCTION = '100*(x-y**2)**2 + (4-y)**2'
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

    for i in range(len(values[0])):
        results_table.insert('', 'end', values=(str(i + 1), values[0][i], values[1][i], values[2][i]))

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
