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
	# zero col corresponding rows are deleted in a diff loop as deleting them
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

# this will linear eqations; takes other variables from ancestors
def solve_one_eq(indexes, cof, const, sums, boolean_mat, order, soln)
	indexes.each do |i|
		other = 0
		if sums[i] > 1
			boolean_mat.transpose[order.index(i)].each_with_index do |anc, j|
				if anc == 1
					other += soln[j]*cof[i][j]
				end
			end
		end
		soln[order.index(i)] = (const[i] - other)/cof[i][order.index(i)]
		# puts "last eq:#{i+1} x#{order.index(i)+1}:#{soln[order.index(i)]}, #{const[i]} #{other} #{cof[i][order.index(i)]}"
	end
	# p "soln: #{soln}"
	return soln
end

# order.index(i) or j  in boolean matrix
# equation of other variable order[j]