from pylab import *
from numpy import *
import numpy
# target = open('./target.txt','w')
# result = open('./result.txt','w')

def load_data(path,path_ar,path_cr):
	f = open(path)
	box = f.readlines()
	data = []
	for line in box[1:]:
		arr = []
		lines = line.strip().split(",")
		for x in lines:
			arr.append(float(x))
		#print arr
		data.append(arr)
	#print data
	ar = open(path_ar)
	box_ar = ar.readlines()
	data_ar = []
	for line_2 in box_ar[1:]:
		arr_2 = []
		lines = line_2.strip().split(",")
		for x in lines:
			arr_2.append(float(x))
		#print arr
		data_ar.append(arr_2)
	cr = open(path_cr)
	box_cr = cr.readlines()
	data_cr = []
	for line_3 in box_ar[1:]:
		arr_3 = []
		lines = line_3.strip().split(",")
		for x in lines:
			arr_3.append(float(x))
		#print arr
		data_cr.append(arr_3)
	return data,data_ar,data_cr

def gradAscent(data,cr,K):
	dataMat = mat(data)
	crMat = mat(cr)
	print dataMat,crMat
	m, n = shape(dataMat)
	p = mat(random.random((m, K)))
	q = mat(random.random((K, n)))
	M = mat(random.random((m,1)))
	# for i in xrange(m):
	# 	if W[i,0] + M[i,0] > 1:
	# 		M[i,0] = 1 - W[i,0]
	alpha = 0.0006
	beta = 0.02
	maxCycles = 5000
	lossArr = []
	for step in xrange(maxCycles):
		for i in xrange(m):
			for j in xrange(n):
				if dataMat[i,j] > 0:
					#print dataMat[i,j]
					error = 0.0
					pq = 0.0
					for k in xrange(K):
						pq = pq + p[i,k]*q[k,j]
					error = (1-M[i,0])*pq +  M[i,0] * crMat[i,j]
					error = dataMat[i,j] - error
					for k in xrange(K):
						p[i,k] = p[i,k] - alpha * (2 * error * (-1+M[i,0]) * q[k,j] + beta * p[i,k])
						q[k,j] = q[k,j] - alpha * (2 * error * (-1+M[i,0]) * p[i,k] + beta * q[k,j])
					M[i,0] = M[i,0] - alpha * (2 * error * (pq - crMat[i,j]) + beta * M[i,0])

		loss = 0.0
		for i in xrange(m):
			for j in xrange(n):
				if dataMat[i,j] > 0:
					error = 0.0
					for k in xrange(K):
						error = error + p[i,k]*q[k,j]
					error = (1-M[i,0])*error + M[i,0] * crMat[i,j]
					loss = loss + (dataMat[i,j] - error) * (dataMat[i,j] - error)
					for k in xrange(K):
						loss = loss + beta * (p[i,k] * p[i,k] + q[k,j] * q[k,j]) / 2
					loss = loss + beta * (M[i,0] * M[i,0]) / 2

		if loss < 0.001:
			break
		print step
		print loss
		if step % 1000 == 0:
			print loss
		lossArr.append(float(loss))


	return p, q, M, lossArr


if __name__ == "__main__":
	dataMatrix,arMatrix,crMatrix = load_data("./model_input_rate.csv","model_input_ar.csv","model_input_cr.csv")
	p, q, M, lossArr = gradAscent(dataMatrix,crMatrix,50)
	'''
	p = mat(ones((4,10)))
	print p
	q = mat(ones((10,5)))
	'''
	crMat = mat(crMatrix)
	dataMat = p * q
	m, n = shape(dataMat)
	for i in xrange(m):
		for j in xrange(n):
			dataMat[i,j] = (1-M[i,0]) * dataMat[i,j] +  M[i,0] * crMat[i,j]
	result = dataMat
	#print p
	#print q

	print result
	print M

	numpy.savetxt("result_3.csv", result, delimiter = ',');
	numpy.savetxt("cr_m_3.csv", M, delimiter = ',');

	data = lossArr
	# writer.writerows(data)
	n = len(data)
	print n
	x = range(n)
	plot(x, data, color='r',linewidth=3)
	plt.title('Convergence curve_3')
	plt.xlabel('generation')
	plt.ylabel('loss')
	show()