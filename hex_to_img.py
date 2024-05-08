import numpy as np
import matplotlib.pyplot as plt
data_matrix = []
# Read file
with open("bin_out.txt", "r") as file:
    row = []
    for line in file:
        hex_values = line.strip().split()
        int_values = [int(hex_value, 16) for hex_value in hex_values]
        row.extend(int_values)
        if len(row) == 639:
            data_matrix.append(row)
            row = []

image = np.array(data_matrix)

plt.imshow(image, cmap='gray')
plt.axis('off')  # 关闭坐标轴
plt.show()
