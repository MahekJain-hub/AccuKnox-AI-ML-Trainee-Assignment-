#Sugarscape Model (1) - Project 
import random
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

#grid with random number of agents 
G = 250
N = 800

#generating N agents with random (uniform probability) distribution of v,m,w
agents = {}
agents_vision = {}
lifespan = {}

for i in range(N): 
    vision = random.choices(list(range(1,7)), weights = [0.1667]*6)[0]
    metabolism = random.choices(list(range(1,5)), weights = [0.25]*4,k=1)[0]
    wealth = random.choices(list(range(5,26)), weights = [0.0476]*21,k=1)[0]
    agents[i] = [vision, metabolism, wealth]
    agents_vision[i] = vision
    lifespan[i] = 0 

#grid[cell1] = [sugar capacity, sugar]
#initial grid
grid = {}
agentsloc = {}
for k in range(G):
    for l in range(G):
        center_x, center_y = G // 2, G // 2
        distance = abs(k - center_x) + abs(l - center_y)

        if distance <= 6:
            sugarcapacity = random.choices([1, 2, 3, 4], weights=[0.1, 0.2, 0.3, 0.4])[0]
        else:
            sugarcapacity = random.choices([1, 2, 3, 4], weights=[0.4, 0.3, 0.2, 0.1])[0]

        sugar = sugarcapacity
        grid[k, l] = [sugarcapacity, sugar]


#each cell is unoccupied initially
unoccupied = grid.copy()

#giving each agent random locations
agentsloc = {}
availablecoords = [(x, y) for x in range(G+1) for y in range(G+1)]
random.shuffle(availablecoords)

for agent in agents:
    agentsloc[agent] = availablecoords.pop()


#moving to the cell with the most sugar, harvesting the sugar, leaving the cell empty & looping

occupied = list(agentsloc.values())

def movement():

    #surveying the neighbouring cells, adding them to a dict
    agent_vision_cells = {} #((x,y), sugarcapacity)
    
    agents_list = list(agents.keys())
    random.shuffle(agents_list)

    for chosen_agent in agents_list:

        nbcells = []

        k = agents[chosen_agent][0] #vison

        x,y = agentsloc[chosen_agent]

        for i in range(1, k+1):
            if (x, y-i) in grid:
                nbcells.append(((x, y - i), grid[(x, y - i)][1]))
            if (x, y+i) in grid:
                nbcells.append(((x, y + i), grid[(x, y + i)][1]))
            if (x-i, y) in grid:
                nbcells.append(((x - i, y), grid[(x - i, y)][1]))
            if (x+i,y) in grid:
                nbcells.append(((x + i, y), grid[(x + i, y)][1]))
        
        nbcells.sort(key=lambda item: item[1], reverse=True) #sorting cells with the most sugar
        agent_vision_cells[chosen_agent] = nbcells
        
        #moving to the cell
        movement = {}
        for cell in agent_vision_cells[chosen_agent]: #((x,y), sugarcapacity)
            coord = cell[0] #the coordinate with the most sugarcapcity in the sorted list
            if coord not in occupied:
                movement[chosen_agent] = coord
                occupied.remove(agentsloc[chosen_agent])
                agentsloc[chosen_agent] = coord #(x,y)
                occupied.append(coord)
                break
            
        if chosen_agent in movement:
            coord = movement[chosen_agent]
            sugaravailable = grid[coord][1]
            agents[chosen_agent][2] = (agents[chosen_agent][2] + sugaravailable) - agents[chosen_agent][1]
            grid[coord][1] = 0
            if agents[chosen_agent][2] <= 0:
                    old_location = agentsloc[chosen_agent]
                    agents.pop(chosen_agent)
                    agentsloc.pop(chosen_agent)
                    occupied.remove(old_location)
            else:
                lifespan[chosen_agent] += 1

#iterating for t steps
for _ in range(1000):
    movement()
    #updating sugar in each cell after each round
    for k, l in grid:
        if grid[k, l][1] < grid[k, l][0]:
            grid[k, l][1] += 1
    
#plot
data = pd.DataFrame({
    'Agent': list(agents_vision.keys()),
    'Vision': list(agents_vision.values()),
    'Lifespan': list(lifespan.values())
})

data = data[data['Vision'].between(1, 6)]
data['Vision'] = data['Vision'].astype(int)

#Compute average lifespan
avg_lifespan = data.groupby('Vision')['Lifespan'].mean().reset_index()
avg_lifespan['Vision'] = avg_lifespan['Vision'].astype(int)
avg_lifespan = avg_lifespan.sort_values(by='Vision')

print("\nAverage Lifespan per Vision:")
print(avg_lifespan)

plt.figure(figsize=(12, 7))

# Stripplot 
sns.stripplot(x='Vision', y='Lifespan', data=data, jitter=True, alpha=0.5)

# Red average dots
plt.scatter(
    x=avg_lifespan['Vision'].astype(str),
    y=avg_lifespan['Lifespan'],
    color='red',
    s=100,
    label='Average'
)

plt.xticks(ticks=[1, 2, 3, 4, 5, 6])  # force x-axis to be integers
plt.title('Lifespan vs Vision with Averages (in Red)')
plt.xlabel('Vision')
plt.ylabel('Lifespan')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

for v in range(1, 7):
    plt.axvline(x=v, color='gray', linestyle='--', alpha=0.2)
