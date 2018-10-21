'''
Date:20160411
@author: zhaozhiyong
'''

from pylab import *
from numpy import *

data = []

f = open("result")
for line in f.readlines():
    lines = line.strip()
    data.append(lines)

n = len(data)
x = range(n)
plot(x, data, color='r',linewidth=3)
plt.title('Convergence curve')
plt.xlabel('generation')
plt.ylabel('loss')
show()