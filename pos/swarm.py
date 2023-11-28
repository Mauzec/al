import tkinter as tk
from tkinter import ttk
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter

import time
import os

def run_algorithm():
    for item in results_table.get_children():
        results_table.delete(item)

    minx_value = minx_entry.get().strip()
    if len(minx_value) == 0: minx_value = '-100'
    miny_value = miny_entry.get().strip()
    if len(miny_value) == 0: miny_value = '-100'
    maxx_value = maxx_entry.get().strip()
    if len(maxx_value) == 0: maxx_value = '100'
    maxy_value = maxy_entry.get().strip()
    if len(maxy_value) == 0: maxy_value = '100'
    iteration_count_value = iteration_count_entry.get().strip()
    if len(iteration_count_value) == 0: iteration_count_value = '10000'
    swarm_size_value = swarm_size_entry.get().strip()
    if len(swarm_size_value) == 0: swarm_size_value = '50'
    max_speed_value = max_speed_entry.get().strip()
    if len(max_speed_value) == 0: max_speed_value = '10'
    function_value = function_entry.get().strip()
    if len(function_value) == 0: function_value = '100*(x-y^2)^2 + (16-y)^2'
    
    start = time.time()
    os.system(f'./main {maxx_value}, {maxy_value}, {minx_value}, {miny_value}, {max_speed_value}, {swarm_size_value}, {iteration_count_value}, "{function_value}"')
    end = time.time()
    print('TIME:', end - start)

    # x, y = [], []   
    min = (10000, 10000, 10000) 
    with open('log.log', 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            values = line.strip()[1:].split(',')
            # x.append(values[0])
            # y.append(values[1])
            if float(values[2]) < float(min[2]):
                min = values
            results_table.insert('', 'end', values=(str(i + 1), values[0], values[1], values[2]))

    results_table.insert('', 'end', values=('BEST', min[0], min[1], min[2]))
    # plt.scatter(x, y, color='green', s=1)
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

swarm_size_label = ttk.Label(root, text="SWARM SIZE")
swarm_size_label.grid(row=1, column=2, padx=10, pady=5)
swarm_size_entry = ttk.Entry(root)
swarm_size_entry.grid(row=1, column=3, padx=10, pady=5)

max_speed_label = ttk.Label(root, text="MAX SPEED")
max_speed_label.grid(row=2, column=2, padx=10, pady=5)
max_speed_entry = ttk.Entry(root)
max_speed_entry.grid(row=2, column=3, padx=10, pady=5)

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
