#!/bin/python
'''
Date:20160411
@author: zhaozhiyong
'''
from pylab import *
from numpy import *
import numpy
import csv

# resulttarget = file('./result.csv','w')

def load_data(path):
	f = open(path)
	box = f.readlines()
	data = []
	for line in box[1:]:
		arr = []
		lines = line.strip().split(",")
		for x in lines:
			if x != "-":
				arr.append(float(x))
			else:
				arr.append(float(0))
		#print arr
		data.append(arr)
	#print data
	return data

def gradAscent(data, K):
	dataMat = mat(data)
	print dataMat
	m, n = shape(dataMat)
	p = mat(random.random((m, K)))
	q = mat(random.random((K, n)))
	# print p * q
	alpha = 0.0006
	beta = 0.02
	maxCycles = 5000
	lossArr = []

	for step in xrange(maxCycles):
		for i in xrange(m):
			for j in xrange(n):
				if dataMat[i,j] > 0:
					#print dataMat[i,j]
					error = dataMat[i,j]
					for k in xrange(K):
						error = error - p[i,k]*q[k,j]
					for k in xrange(K):
						p[i,k] = p[i,k] + alpha * (2 * error * q[k,j] - beta * p[i,k])
						q[k,j] = q[k,j] + alpha * (2 * error * p[i,k] - beta * q[k,j])

		loss = 0.0
		for i in xrange(m):
			for j in xrange(n):
				if dataMat[i,j] > 0:
					error = 0.0
					for k in xrange(K):
						error = error + p[i,k]*q[k,j]
					loss = loss + (dataMat[i,j] - error) * (dataMat[i,j] - error)
					for k in xrange(K):
						loss = loss + beta * (p[i,k] * p[i,k] + q[k,j] * q[k,j]) / 2

		if loss < 0.001:
			break
		print step
		print loss
		if step % 1000 == 0:
			print loss
			# print p * q
		lossArr.append(float(loss))
	return p, q, lossArr


if __name__ == "__main__":
	dataMatrix = load_data("./model_input_rate.csv")

	p, q, lossArr = gradAscent(dataMatrix, 50)
	'''
	p = mat(ones((4,10)))
	print p
	q = mat(ones((10,5)))
	'''
	result = p * q
	#print p
	#print q
	print result
	numpy.savetxt("result_0.csv", result, delimiter = ',');

	# print type(result)
	# numpy.savetxt("result.csv", result, delimiter = ',');
	# writer = csv.writer(resulttarget)
	data = lossArr
	# writer.writerows(data)
	n = len(data)
	print n
	x = range(n)
	plot(x, data, color='r',linewidth=3)
	plt.title('Convergence curve_0')
	plt.xlabel('generation')
	plt.ylabel('loss')
	show()