require 'json'
require 'matrix'
# requiring helper file giving relative path
require_relative 'helper.rb'

# occurence matrix
occ = []
# coefficient matrix, it will also be the jacobian matrix for linear equation
cof = []
# array constants
const = []
# initial guess
init = []
# input from file
input = IO.readlines('sample-input.txt')
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
# the array order will be modified inside the fn call, so copying it marshal
order_copy = order.to_json
# deleting rows and columns corresponding to a column with all elements zero

reduced_mat = delete_zero(boolean_matrix.transpose, n, 'col', first, last, order)

puts 'reduced matrix: '
reduced_mat.each do |eq|
 p eq
end

# solving the equations in first array
soln = []
soln = solve_one_eq(first, cof, const, sums, boolean_matrix, JSON::parse(order_copy), soln)

# remove the deleted equations from the coefficient matrix
cof_json = cof.to_json
const_json = const.to_json
init_json = init.to_json
removed = (first+last).sort
removed.each_with_index do |v, k|
	cof.delete_at(v-k)
	const.delete_at(v-k)
	init.delete_at(v-k)
end

cof = cof.transpose
removed.each_with_index do |v, k|
	cof.delete_at(v-k)
end
cof = cof.transpose

# converting into matrix
cof = Matrix.rows(cof)
const = Matrix[const].transpose
init = Matrix[init].transpose

# now solving the remaining equations using newton-raphson method
# f[x(i+1)] = f[x(i)] + J_inv*f[x(0)]
inv_mat = cof.inverse
f_x0 = cof*init - const
x1 = init - inv_mat*f_x0
soln = soln + x1.transpose.to_a[0]

# solving the equations in last array
soln = solve_one_eq(last, JSON::parse(cof_json), JSON::parse(const_json), sums, boolean_matrix, JSON::parse(order_copy), soln)

# output
# occ.each do |eq|
# boolean_matrix.each do |eq|
# reduced_mat.each do |eq|
# p eq
# end
puts 'final solution of equations: '
puts soln.map(&:to_f)
