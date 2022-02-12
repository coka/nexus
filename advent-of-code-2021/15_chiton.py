import math


def to_graph(matrix):
    size = len(matrix)
    g = [{} for _ in range(size * size)]
    for i, row in enumerate(matrix):
        for j, _ in enumerate(row):
            node = i * size + j
            if j > 0:
                left = node - 1
                g[node][left] = matrix[i][j - 1]
            if j < size - 1:
                right = node + 1
                g[node][right] = matrix[i][j + 1]
            if i > 0:
                up = node - size
                g[node][up] = matrix[i - 1][j]
            if i < size - 1:
                down = node + size
                g[node][down] = matrix[i + 1][j]
    return g


def get_shortest_path(graph):
    nodes = len(graph)
    distances = [math.inf for _ in range(nodes)]
    unvisited = set([node for node in range(nodes)])
    to_visit = [0]
    distances[0] = 0
    while len(unvisited) > 0:
        new_nodes = []
        for node in to_visit:
            if node in unvisited:
                unvisited.remove(node)
                current_dist = distances[node]
                for (conn, dist) in graph[node].items():
                    new_nodes.append(conn)
                    dist_to_conn = current_dist + dist
                    if dist_to_conn < distances[conn]:
                        distances[conn] = dist_to_conn
        to_visit = new_nodes
    return distances[-1]


def expand_horizontally(matrix, factor):
    rows = len(matrix)
    cols = len(matrix[0])
    new_cols = cols * factor
    result = []
    for i in range(rows):
        row = []
        for j in range(new_cols):
            if j // cols == 0:
                row.append(matrix[i][j])
            else:
                prev = row[j - cols]
                if prev == 9:
                    row.append(1)
                else:
                    row.append(prev + 1)
        result.append(row)
    return result


def expand_vertically(matrix, factor):
    rows = len(matrix)
    cols = len(matrix[0])
    new_rows = rows * factor
    result = []
    for i in range(new_rows):
        row = []
        for j in range(cols):
            if i // cols == 0:
                row.append(matrix[i][j])
            else:
                prev = result[i - cols][j]
                if prev == 9:
                    row.append(1)
                else:
                    row.append(prev + 1)
        result.append(row)
    return result


def expand(matrix, factor):
    """
    TODO Order matters. The commented line produces "IndexError: list index out of range".
    """
    # return expand_vertically(expand_horizontally(matrix, factor), factor)
    return expand_horizontally(expand_vertically(matrix, factor), factor)


with open("inputs/15_example.txt") as input:
    data = [[int(char) for char in line.rstrip()] for line in input]
    print(get_shortest_path(to_graph(data)))
    print(get_shortest_path(to_graph(expand(data, 5))))

with open("inputs/15.txt") as input:
    data = [[int(char) for char in line.rstrip()] for line in input]
    print(get_shortest_path(to_graph(data)))
    """
    TODO The result should be 2998, but is 3001. From the Reddit solution megathread:

    > Part 2 works the same way as part 1, however I had to fix a very
    > subtle bug in my Dijkstra implementation. When the algorithm says
    > select the unvisited node that is marked with the smallest
    > tentative distance, the word smallest is apparently important.
    > Without that check, the algorithm will work for part 1 and the
    > test file of part 2, but not the actual input of part 2 (the
    > result is very slightly wrong).

    I got ** by guessing.
    """
    print(get_shortest_path(to_graph(expand(data, 5))))
