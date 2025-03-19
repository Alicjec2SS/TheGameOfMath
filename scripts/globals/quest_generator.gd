extends Node


#level 1
class Level1:
	var expression: Array = []

	func _init():
		expression = generate_single_expression()
	
	func generate_single_expression() -> Array:
		var operators = ["+", "-", "*", "/"]
		
		var a = randi() % 41 # a trong khoảng (0, 40)
		var b = randi() % 41 # b trong khoảng (0, 40)
		var operator = operators[randi() % operators.size()] # Chọn ngẫu nhiên dấu @

		if operator == "-":
			b = randi() % (a + 1) # b nhỏ hơn hoặc bằng a
		elif operator == "/":
			b = randi() % 40 + 1 # b > 0
			while a % b != 0:    # Lặp cho đến khi tìm được b là ước của a
				b = randi() % 40 + 1 # Đảm bảo b không bằng 0

		var expression_text = "{a} {operator} {b}".format({"a": a, "operator": operator, "b": b})
		var x = eval_expression(a, b, operator)
		return ["Caculate: " + expression_text, [x]]

	func eval_expression(a: int, b: int, operator: String) -> float:
		match operator:
			"+":
				return a + b
			"-":
				return a - b
			"*":
				return a * b
			"/":
				return float(a) / float(b) # Chia trả về kết quả float
		return 0

#level2
class Level2:
	var expression: Array = []

	func _init():
		expression = generate_multi_expression()

	func generate_multi_expression() -> Array:
		var operators = ["+", "-", "*", "/"]
		var nums = []
		var ops = []

		# Tạo 2-3 phép toán ngẫu nhiên
		var num_count = randi() % 2 + 2  # Số lượng số: 2 hoặc 3
		for j in range(num_count):
			nums.append(randi() % 20 + 1)  # Số trong khoảng (1, 20)

		for j in range(num_count - 1):
			ops.append(operators[randi() % operators.size()])

		# Đảm bảo phép chia là phép chia hết và phép nhân không vượt quá 10
		for j in range(ops.size()):
			if ops[j] == "/":
				var dividend = nums[j]  # Số bị chia
				var divisor_candidates = []
				for i in range(1, dividend + 1):
					if dividend % i == 0:  # Tìm tất cả ước số
						divisor_candidates.append(i)
				nums[j + 1] = divisor_candidates[randi() % divisor_candidates.size()]  # Chọn một ước số ngẫu nhiên
			elif ops[j] == "*":
				# Giới hạn cả hai số nhân không vượt quá 10
				nums[j] = randi() % 10 + 1
				nums[j + 1] = randi() % 10 + 1

		# Tạo biểu thức dạng chuỗi
		var expression_text = str(nums[0])
		for j in range(ops.size()):
			expression_text += " %s %s" % [ops[j], nums[j + 1]]

		# Tính toán theo thứ tự nhân chia trước
		var new_nums = [nums[0]]
		var new_ops = []
		for j in range(ops.size()):
			if ops[j] in ["*", "/"]:
				var last_num = new_nums.pop_back()
				if ops[j] == "*":
					new_nums.append(last_num * nums[j + 1])
				else:
					new_nums.append(int(last_num / nums[j + 1]))  # Chia lấy số nguyên
			else:
				new_nums.append(nums[j + 1])
				new_ops.append(ops[j])

		# Xử lý cộng trừ từ trái sang phải
		var result = new_nums[0]
		for j in range(new_ops.size()):
			if new_ops[j] == "+":
				result += new_nums[j + 1]
			else:
				result -= new_nums[j + 1]

		return ["Caculate: " + expression_text, [result]]

#level3 
class Level3:
	var expression: Array = []
	func _init():
		var x = randi() % 21 # x nằm trong khoảng 0 -> 20
		var operators = ["+", "-", "*", "/"]
		var op = operators[randi() % operators.size()]
		var num = randi() % 21 # số ngẫu nhiên trong khoảng 0 -> 20
		var question = ""
		var answer = x

		match op:
			"+":
				question = "x + %d = %d" % [num, x + num]
			"-":
				question = "x - %d = %d" % [num, x - num]
			"*":
				question = "x * %d = %d" % [num, x * num]
			"/":
			# Đảm bảo num là ước của x để phép chia hết
				num = randi() % 21
				var s = randi() % 11
				answer = s * num
				question = "x / %d = %d" % [num, s]
				
				
		expression = ["Find x of " + question, [answer]]
		
#level4
class Level4:
	var expression: Array = []
	func _init():
		var a = randi() % 21 - 10 # a trong khoảng -10 đến 10, tránh 0
		if a == 0:
			a = 1
		var x = randi() % 21 - 10 # x trong khoảng -10 đến 10
		var b = randi() % 21 - 10 # b trong khoảng -10 đến 10
		var y = a * x + b # Tính y để đảm bảo phương trình hợp lệ
		
		
		#form laị cái biểu thức cho nó giông người viết 
		var question = ""#= "%dx + %d = %d" % [a, b, y]
		if a == 1:
			question += "x"
		else:
			question += "%dx" % [a]
		
		if b < 0:
			question += " - %d" % [abs(b)]
		if b > 0:
			question += " + %d" % [abs(b)]
		question += " = %d" % y
		
		var answer = x
		
		expression = ["Find x of " + question, answer]



#level5:
class Level5:
	var expression:Array = []
	func _init():
		var a = randi() % 21 - 10 # a trong khoảng -10 đến 10, tránh 0
		if a == 0:
			a = 1
		var x = randi() % 21 - 10 # x trong khoảng -10 đến 10
		var b = randi() % 21 - 10 # b trong khoảng -10 đến 10
		var c = randi() % 21 - 10 # c trong khoảng -10 đến 10
		
		var y = a * x * x + b * x + c
		
		#form lại đáp án cho đẹp
		var ski = DaThuc.new()
		ski.x2 = a
		ski.x = b
		ski.free = c
		
		var question = "[center]Find one of the two answers of \n " + str(ski) + " = " + str(y) +  " (round to two decimal places for floats)[/center]"
		
		var answer = solve_quadratic(a,b,c,y)
		
		expression = [question, answer]
	#giải quyết vẫn đề phát sinh của level5: hai nghiệm
	func solve_quadratic(a: float, b: float, c: float, y: float) -> Array:
		# Đưa phương trình về dạng chuẩn ax^2 + bx + (c - y) = 0
		c -= y
	
		# Tính delta
		var delta = b * b - 4 * a * c
	
		# Kiểm tra delta
		if delta < 0:
			return [] # Không có nghiệm thực
		elif delta == 0:
			var x = -b / (2 * a)
			return [x] # Nghiệm kép
		else:
			var sqrt_delta = sqrt(delta)
			var x1 = (-b + sqrt_delta) / (2 * a)
			var x2 = (-b - sqrt_delta) / (2 * a)
			return [x1, x2] # Hai nghiệm phân biệt


#Level 6
class DaThuc:
	#Khai báo biến cho class
	var x2
	var y2
	var xy
	var x
	var y
	var free

	func _init():
		self.x2 = 0
		self.y2 = 0
		self.xy = 0
		self.x = 0
		self.y = 0
		self.free = 0
		#print('Created')
	func _add(dathuc2:DaThuc):
		var newDaThuc = DaThuc.new()
		newDaThuc.x2 = self.x2 + dathuc2.x2
		newDaThuc.y2 = self.y2 + dathuc2.y2
		newDaThuc.x = self.x + dathuc2.x
		newDaThuc.y = self.y + dathuc2.y
		newDaThuc.xy = self.xy + dathuc2.xy
		newDaThuc.free = self.free + dathuc2.free
		return newDaThuc
	func _subtract(dathuc2:DaThuc):
		# trả về self - dathuc2
		var newDaThuc = DaThuc.new()
		newDaThuc.x2 = self.x2 - dathuc2.x2
		newDaThuc.y2 = self.y2 - dathuc2.y2
		newDaThuc.x = self.x - dathuc2.x
		newDaThuc.y = self.y - dathuc2.y
		newDaThuc.xy = self.xy - dathuc2.xy
		newDaThuc.free = self.free - dathuc2.free
		return newDaThuc
	func _to_string():
		var returnString = ""
		if self.x2 != 0:
			if abs(self.x2) == 1:
				returnString += " x²"
			else:
				returnString += ' ' + str(self.x2) + "x²"
		
		if self.y2 != 0:
			if abs(self.y2) == 1:
				if self.y2 > 0:#Dương 
					returnString += " + y²"
				else:
					returnString += " - y²"
			elif self.y2 > 0:#Dương 
				returnString += ' + ' +  str(self.y2) + "y²"
			else:
				returnString +=' ' +  str(self.y2) + "y²"
		
		if self.x != 0:
			if abs(self.x) == 1:
				if self.x > 0:#Dương 
					returnString += " + x"
				else:
					returnString += " - x"
			elif self.x > 0:#Dương 
				returnString += ' + ' +  str(self.x) + "x"
			else:
				returnString += ' ' + str(self.x) + "x"
		
		if self.y != 0:
			if abs(self.y) == 1:
				if self.x > 0:#Dương 
					returnString += " + y"
				else:
					returnString += " - y"
			elif self.y > 0:#Dương 
				returnString += ' + ' +  str(self.y) + "y"
			else:
				returnString += ' ' + str(self.y) + "y"
		
		if self.xy != 0:
			if abs(self.xy) == 1:
				if self.x > 0:#Dương 
					returnString += " + xy"
				else:
					returnString += " - xy"
			elif self.xy > 0:#Dương 
				returnString += ' + ' +  str(self.xy) + "xy"
			else:
				returnString += ' ' + str(self.xy) + "xy"
		
		if self.free != 0:
			if self.free > 0:
				returnString += " +" 
			returnString += ' ' + str(self.free)  
		
		returnString = returnString.strip_edges()
		return returnString

class CreateDaThucMin:
	var l = 0
	var operatorForQuestions = []
	var comparationOperator = []
	var k = 0
	var randomMachine = RandomNumberGenerator.new()
	var expression: Array = []
	var ep = null
	
	func _init():
		print("Init CreateDaThucMin")
		self.randomMachine.randomize()
		self.l = self.randomMachine.randi_range(-20, 20)
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)

		for i in range(5):
			self.operatorForQuestions.append(["+","-"].pick_random())
			for _temp in range(10):
				continue#đợi một chút
			self.comparationOperator.append(["+","-"].pick_random())
			
		self.expression = [form2Question,form3Question,form4Question,form5Question].pick_random().call()
		self.expression[0] = "Find the minimum of " + self.expression[0]
	func form1Question():#toán cấp 3
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+ky)^
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.xy = -2*k
		else:
			daThuc2.xy = 2*k
		daThuc2.y2 = k**2
		
		daThuc1 = daThuc1._add(daThuc2)
		
		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
		
	func form2Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.x = -2*k
		else:
			daThuc2.x = 2*k
		daThuc2.free = k**2
		
		daThuc1 = daThuc1._add(daThuc2)
		

		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form3Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.y2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.y = -2*k
		else:
			daThuc2.y = 2*k
		daThuc2.free = k**2
		
		daThuc1 = daThuc1._add(daThuc2)
		

		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form4Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x@k)^2
		daThuc1.x2 = 1
		if self.operatorForQuestions[0] == "-":
			daThuc1.x = -2*k
		else:
			daThuc1.x = 2*k
		daThuc1.free = k**2
		
		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form5Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.x = -2*k
		else:
			daThuc2.x = 2*k
		daThuc2.free = k**2
		
		daThuc1 = daThuc1._add(daThuc2)
		
		
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(0, 10)
		var rand = [0,k]
		rand.shuffle()
		
		#nhiễu 
		daThuc1.x2 += rand[0]
		daThuc1.y2 += rand[1]
		
		daThuc1.free += l
	
		
		return [str(daThuc1),[l]]

class CreateDaThucMax:
	var l = 0
	var operatorForQuestions = []
	var comparationOperator = []
	var k = 0
	var randomMachine = RandomNumberGenerator.new()
	var expression: Array = []
	var ep = null
	var dathuc0 = DaThuc.new()
	
	func _init():
		print("Init CreateDaThucMin")
		self.randomMachine.randomize()
		self.l = self.randomMachine.randi_range(-20, 20)
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)

		for i in range(5):
			self.operatorForQuestions.append(["+","-"].pick_random())
			for _temp in range(10):
				continue#đợi một chút
			self.comparationOperator.append(["+","-"].pick_random())
			
		self.expression = [form1Question,form2Question,form3Question,form4Question,form5Question].pick_random().call()
		self.expression[0] = "Find the maximum of " + self.expression[0]
	func form1Question():#toán cấp 3
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		daThuc1 = dathuc0._subtract(daThuc1)
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+ky)^
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.xy = -2*k
		else:
			daThuc2.xy = 2*k
		daThuc2.y2 = k**2
		
		daThuc2 = dathuc0._subtract(daThuc2)
		
		daThuc1 = daThuc1._add(daThuc2)
		
		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
		
	func form2Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		daThuc1 = dathuc0._subtract(daThuc1)
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.x = -2*k
		else:
			daThuc2.x = 2*k
		daThuc2.free = k**2
		
		daThuc2 = dathuc0._subtract(daThuc2)
		
		daThuc1 = daThuc1._add(daThuc2)
		

		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form3Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		daThuc1 = dathuc0._subtract(daThuc1)
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.y2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.y = -2*k
		else:
			daThuc2.y = 2*k
		daThuc2.free = k**2
		
		daThuc2 = dathuc0._subtract(daThuc2)
		
		daThuc1 = daThuc1._add(daThuc2)
		

		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form4Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x@k)^2
		daThuc1.x2 = 1
		if self.operatorForQuestions[0] == "-":
			daThuc1.x = -2*k
		else:
			daThuc1.x = 2*k
		daThuc1.free = k**2
		
		daThuc1.free += l
		
		
		return [str(daThuc1),[l]]
	
	func form5Question():
		#dạng của đa thức:
		var daThuc1 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (kx@y)^2
		daThuc1.x2 = k**2
		if self.operatorForQuestions[0] == "-":
			daThuc1.xy = -2*k
		else:
			daThuc1.xy = 2*k
		daThuc1.y2 = 1
		
		daThuc1 = dathuc0._subtract(daThuc1)
		
		var daThuc2 = DaThuc.new()
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(-10, 10)
		#dạng (x+k)^2
		daThuc2.x2 = 1
		if self.operatorForQuestions[1] == "-":
			daThuc2.x = -2*k
		else:
			daThuc2.x = 2*k
		daThuc2.free = k**2
		
		daThuc2 = dathuc0._subtract(daThuc2)
		
		daThuc1 = daThuc1._add(daThuc2)
		
		
		self.randomMachine.randomize()
		self.k = self.randomMachine.randi_range(0, 10)
		var rand = [0,k]
		rand.shuffle()
		
		#nhiễu 
		daThuc1.x2 -= rand[0]
		daThuc1.y2 -= rand[1]
		
		daThuc1.free += l
	
		
		return [str(daThuc1),[l]]

class Level6:
	var expression: Array = []
	var prs = [CreateDaThucMin,CreateDaThucMax]
	
	func _init():
		var cache = prs.pick_random().new()
		self.expression = cache.expression
	

