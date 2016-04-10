require 'matrix'

def delete_zero(matrix, n, type, first, last, order)
	i = 0
	to_delete = []
	max = n
	while(i<max)		
		# puts "#{i} #{matrix[i].count('0')}"
		if matrix[i].count(0) == n
			if type == 'col'
				first << order[i]
				to_delete << i
			else
				last << order[i]
				to_delete << i
			end
			matrix.delete_at(i)
			order.delete_at(i)
			max -= 1
		else
			i += 1
		end
	end
	# zero col corresponding rows are deleted in a different loop as deleting them
	# in same loop might form additional zero cols which would disturb the order
	matrix = matrix.transpose
	to_delete.each do |j|
		matrix.delete_at(j)
	end
	n = max
	before_rows_deletion = matrix.size
	# delete r and c corresponding to the rows containing all zeros
	# if we have just deleted r and c corresponding to a zero column
	if type == 'col'
		matrix = delete_zero(matrix, before_rows_deletion, 'row', first, last, order)
	end
	# again check for column deletion
	# currently the matrix is in its transpose form
	if matrix.size < before_rows_deletion
		matrix = delete_zero(matrix, matrix.size, 'col', first, last, order)
	else
		matrix = matrix.transpose
	end

	return matrix
end

# occurence matrix
occ = []
# coefficient matrix, it will also be the jacobian matrix for linear equation
cof = []
# array constants
const = []
# initial guess
init = []
# input from file
input = IO.readlines('sample-input-3.txt')
n = input[0].to_i
n.times do |i|
	cof[i] = input[1+i].split(' ')
	const[i] = input[1+n+i].to_f
	init[i] = input[1+2*n+i].to_f
	# convert string to float
	cof[i] = cof[i].map(&:to_f)
	occ[i] = []
	# calculating occurence matrix
	cof[i].each do |coefficient|
		if coefficient == 0
			occ[i] << 0
		else
			occ[i] << 1
		end
	end
	# occ[i] = input[1+3*n+i].split(' ')
end

# sum of each row
sums = []
occ.each do |eq|
	sum = 0
	eq.each do |val|
		sum += val.to_f
	end
	sums << sum
end

puts 'occurence matrix: '
occ.each do |eq|
 p eq
end


# getting order of equations after rearranging rows
## finding equations index which has j-th variable present in it
order = []
occ.transpose.each do |variable|
	pe = []
	pe_sums = []	
	variable.each_with_index do |val, j|
		if !order.include?(j) && val.to_f == 1
			pe << j
			pe_sums << sums[j]
		end
	end
	# possible equation (pe) with smallest sum
	order << pe[pe_sums.index(pe_sums.min)]
end

# getting boolean matrix, assuming its equal to the
# transpose of occurence matrix only
# deleting the self or making diagonal elements 0 in the same step
boolean_matrix = []
n.times do |i|	
	boolean_matrix << occ[order[i]]
	boolean_matrix[i][i] = 0
end
boolean_matrix = boolean_matrix.transpose

# output
puts 'boolean matrix: '
boolean_matrix.each do |eq|
 p eq
end

# solving order
first = []
last = []
# deleting rows and columns corresponding to a column with all elements zero
reduced_mat = delete_zero(boolean_matrix.transpose, n, 'col', first, last, order)
p first
p last

puts 'reduced matrix: '
reduced_mat.each do |eq|
 p eq
end

# solving the equations in first array
soln = []
first.each do |i|
	cof[i].each do |coefficient|
		if coefficient.to_f != 0
			puts "#{i} #{coefficient} #{const[i]}"
			soln << const[i]/coefficient.to_f
		end
	end
end
p 'first soln'
p soln
# remove the deleted equations from the coefficient matrix
cof_mat = cof
const_mat = const
init_mat = init
removed = (first+last).sort
removed.each_with_index do |v, k|
	cof_mat.delete_at(v-k)
	const_mat.delete_at(v-k)
	init_mat.delete_at(v-k)
end

cof_mat = cof_mat.transpose
removed.each do |i|
	cof_mat.delete_at(i)
end
cof_mat = cof_mat.transpose

puts 'cof_mat matrix: '
cof_mat.each do |eq|
 p eq
end

# converting into matrix
cof_mat = Matrix.rows(cof_mat)
const_mat = Matrix[const_mat].transpose
init_mat = Matrix[init_mat].transpose

# now solving the remaining equations using newton-raphson method
# f[x(i+1)] = f[x(i)] + J_inv*f[x(0)]
inv_mat = cof_mat.inverse
f_x0 = cof_mat*init_mat - const_mat
x1 = init_mat - inv_mat*f_x0
soln = soln + x1.transpose.to_a[0]
puts 'nr'
p soln

# solve the equations that are in last array
last.reverse.each do |i|
	cof[i].each do |coefficient|
		if coefficient.to_f != 0
			soln << const[i]/coefficient.to_f
		end
	end
end

# output
# occ.each do |eq|
# boolean_matrix.each do |eq|
# reduced_mat.each do |eq|
# p eq
# end
puts 'final solution of equations: '
p soln.map(&:to_f)
