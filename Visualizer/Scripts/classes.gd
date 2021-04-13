class SolverStep extends Problem:
	
	var next : SolverStep
	var prev : SolverStep
	var depth
	
	func _init(depth).():
		
		self.depth = depth
	
	
	func next() -> SolverStep:
		return self.next
	
	
	func prev() -> SolverStep:
		return self.prev
	

class Problem:
	
	
	var domains: Array
	var config = g.Configuration.new()
	var entity_map: Dictionary
	var count_formulas: Array
	var pos_constraints: Dictionary
	var solution: int
	var solver_step: SolverStep
	var universe = g.Domain.new("uni")
	var universe_formula : String
	var child_problems : Array
	var parent_problem : Problem
	
	
	func _init():
		
		domains = []
		entity_map = {}
		count_formulas = []
		child_problems = []
		universe_formula = universe.get_name()
	
	
	func add_child_problem(problem : Problem) -> void:
		self.child_problems.append(problem)
	
	
	func set_parent_problem(problem : Problem) -> void:
		self.parent_problem = problem
	
	
	func add_domain(domain : Domain) -> void:
		domains.append(domain)
		update_universe_formula()
	
	func add_to_universe(element : int) -> void:
		universe.add_element(element)
		update_universe_formula()
	
	
	func add_elements(no_elements : int) -> void:
		
		var new_elements = []
		for i in no_elements:
			var elem_count = universe.get_size()
			for j in range(1, elem_count+2):
				if !universe.get_elements().has(j):
					universe.add_elements([j])
					
		update_universe_formula()
	
	
	func add_pos_constraint(pos: int, domain_name: String) -> void:
		
		if domain_name == "uni":
			pos_constraints[pos] = universe
		else:
			pos_constraints[pos] = get_domain(domain_name)
	
	
	func add_to_domain(domain_name, _element : int) -> void:
		
		for dom in domains:
			if dom.get_name() == domain_name:
				dom.add_element(_element)
				
		update_universe_formula()
	
	
	func check_empty_domains() -> void:
	
		for i in domains:
			if i.get_elements().empty():
				remove_domain(domains.find(i))
	
	
	func clear_domains():
		
		domains = []
		universe.clear()
		update_universe_formula()
	
	
	func erase_elements(elements_ids : PoolIntArray):
		
		for i in elements_ids:
			universe.erase_elem(i)
			for domain in domains:
				domain.erase_elem(i)
		check_empty_domains()
		update_universe_formula()
	
	
	func get_config() -> Configuration:
		return config
	
	
	func get_elem_count() -> int:
		return universe.get_size()
	
	
	func get_domain(domain_name: String) -> Domain:
		
		if domain_name == "uni":
			return universe
		for i in get_domains():
			if i.get_name() == domain_name:
				return i
		return null
	
	
	func get_domain_elements() -> Array:
		
		var domains_elements = []
		for i in get_domains():
			domains_elements.append(i.get_elements())
		return domains_elements
	
	
	# no_domains == 1, return = [A]
	# no_domains == 2, return = [A, B, AB]
	# no_domains == 3, return = [A, B, C, AB, BC, AC, ABC]
	func get_domain_intersections() -> PoolIntArray:
		
		var domain_elements = get_domain_elements()
		var intersections = []
		for i in domain_elements:
			intersections.append(i)
		
		# intersections if there are at least 2 domains
		match len(domain_elements):
			2:
				intersections.append(g.intersection(domain_elements[0], domain_elements[1]))
			3:
				intersections.append(g.intersection(domain_elements[0], domain_elements[1]))
				intersections.append(g.intersection(domain_elements[0], domain_elements[2]))
				intersections.append(g.intersection(domain_elements[1], domain_elements[2]))
				intersections.append(g.intersection(
					g.intersection(domain_elements[0], domain_elements[1]), domain_elements[2])
				)
		return intersections
	
	
	func get_domain_sizes() -> PoolIntArray:
		return g.lengths(get_domain_elements())
	
	
	func get_domains():
		return domains
	
	
	func get_domains_strict() -> Array:
	
		var domains_strict = get_domain_elements()
		var intersections = get_domain_intersections()
		for i in domains_strict:
			for j in range(len(domains), len(intersections)):
				i = g.exclude(i, intersections[j])
		return domains_strict
	
	
	func get_domain_name_from_elements(elements : Array) -> String:
		for domain in domains:
			if elements.sort() == domain.get_elements().sort():
				return domain.get_name()
		return ""
	
	
	func get_universe():
		return universe
	
	
	func group(elements: PoolIntArray, group_name: String, is_dist : bool) -> void:
		
		if !is_domain(group_name):
			var new_domain = g.Domain.new(group_name, elements, is_dist)
			domains.append(new_domain)
			update_universe_formula()
		else:
			get_domain(group_name).add_elements(elements)
	
	
	func is_dist_elem(elem_id: int) -> bool:
		
		for i in get_domains():
			if elem_id in i && !i.is_distinct:
				return false
		return true
	
	
	func is_domain(group_name) -> bool:
		return get_domain(group_name) != null
	
	
	func remove_domain(index : int) -> void:
		domains.remove(index)
	
	
	func reset():
		
		entity_map = {}
		count_formulas = []
		config = null
		clear_domains()
	
	
	func set_config(_name : String, _size : int, _type : String, _domain = get_universe()) -> void:
		
		_name = _name.strip_edges()
		if _name != "":
			self.config.set_name(_name)
		else:
			self.config.set_name("config")
		self.config.set_size(_size)
		self.config.set_type(_type)
		self.config.set_domain(_domain)
		pos_constraints = Dictionary()
	
	
	func set_size_constraint(domain_name: String, operator: String, size: int) -> void:
		get_domain(domain_name).size_constraint.init(operator, size)
	
	
	func set_universe(size: int) -> void:
		
		g.problem.clear_domains()
		add_elements(size)
		update_universe_formula()
	
	
	func to_cola() -> String:
		
		# Domains
		var cola = ""
		
		if universe_formula == universe.get_name():
			cola += universe.to_cola()
			cola += "\n"
		
		
		for dom in domains:
			cola += dom.to_cola()
			cola += "\n"
		
		# Configs
		config.set_formula(universe_formula)
		cola += config.to_cola()
		
		# Pos Constraints
		var flag = 1
		for i in pos_constraints:
			cola += "\n{name}[{i}] = {domain};".format({"name" : config.get_name(), "i" : int(i), "domain" : pos_constraints[i].get_name().to_lower()})
#			if flag != pos_constraints.size():
#				cola += ";"
#			flag += 1
		
		# Size Constraints
		for domain in domains:
			if domain.size_constraint.operator != "":
				cola += "\n#{d} {op} {i};".format({"d":domain.get_name().to_lower(), "op" : domain.size_constraint.operator, "i" : domain.size_constraint.size})
		
		
		#cola.erase(cola.length() - 1, 1)
		cola += "\n"
		
		return cola
	
	
	func update_universe_formula():
		
		if g.Union(domains).get_size() == universe.get_size():
			var tmp = ""
			var size = domains.size()
			for domain in domains:
				tmp += domain.get_name().to_lower()
				if domains.find(domain)+1 != size:
					tmp += " + "
			
			self.universe_formula = tmp
		else:
			self.universe_formula = universe.get_name()
	
	
	func _print():
		return [universe.get_elements(), domains, config]


class Domain:
	
	
	var domain_name: String
	var elements: Array
	var is_distinct: bool
	var size_constraint = g.SizeConstraint.new()
	
	
	func _init(_name : String, _elements = [], _is_distinct = true):
		
		domain_name = _name
		elements = _elements
		is_distinct = _is_distinct
	
	
	func clear() -> void:
		elements = Array()
	
	
	func get_name() -> String:
		return domain_name
	
	
	func set_name(_name) -> void:
		domain_name = _name
	
	
	# Get a list containing all elements
	func get_elements() -> Array:
		return elements
	
	
	func add_elements(new_elements : Array) -> void:
		elements = g.union(elements, new_elements)
	
	
	func erase_elem(element : int):
		elements.erase(element)
	
	
	# Get domain size
	func get_size():
		return len(self.elements)
	

	# Translates to cola expression
	func to_cola() -> String:
		
		var tmp = str(elements).replace("[","{").replace("]","}").replace(" ","")
		if is_interval():
			tmp = get_interval().string().replace(",",":").replace(" ","")
		var cola = "{d} = {e};".format({"d" : domain_name.to_lower(), "e" : tmp})
		return cola
	
	
	# Returns the intersection with the specified domain
	func inter(domain : Domain) -> Domain:
		return domain
	
	
	# Returns the union with the specified domain
	func union(domain : Domain) -> Domain:
		return domain
	
	
	# Checks if this domain is an interval
	func is_interval() -> bool:
		
		Array(elements).sort()
		for i in range(len(elements)):
			if elements[i] != elements[0] + i:
				return false 
		return true
	
	
	# Return interval object
	func get_interval() -> Interval:
		
		if is_interval():
			# sorted by is_interval()
			var lo = elements[0]
			var hi = elements[-1]
			var interval = g.Interval.new(lo, hi)
			return interval
		return null
	
	
# warning-ignore:function_conflicts_variable
	func is_distinct() -> bool:
		return is_distinct


class DomainFormula:
	
	
	var arguments : Array
	var operator : String
	
	
	func _init(universe : Domain):
		
		self.universe = universe
		


class Configuration:
	
	var size
	var config_name
	var type
	var type_string_list = ["","",""]
	var formula
	var domain : Domain
	
	func _init(_name = "config", _size = 1, _type = "", _domain = null):
		
		config_name = _name
		size = _size
		domain = _domain
		set_type(_type)
	
	
	func set_size(_size: int):
		size = _size
	
	
	func get_size() -> int:
		return size
	
	
	func get_name():
		return config_name
	
	
	func set_name(_name : String):
		config_name = _name
	
	
	func get_type():
		return type
	
	
	func set_type(_type : String):
		type = _type
		
		match type:
			
			"sequence":
				type_string_list = ["[", "|| ", "]"]
				
			"permutation":
				type_string_list = ["[", "| ", "]"]
				
			"subset":
				type_string_list = ["{", "| ", "}"]
			
			"multisubset":
				type_string_list = ["{", "|| ", "}"]
			
			"partition":
				type_string_list = ["partitions", "(", ")"]
			
			"composition":
				type_string_list = ["compositions", "(", ")"]
	
	
	func get_domain():
		return domain
	
	
	func set_domain(_domain : Domain):
		domain = _domain
	
	
	func get_formula() -> String:
		return formula
	
	
	func set_formula(f : String):
		self.formula = f
	
	
	func to_cola() -> String:
		
		var cola = "{c} in {h0}{h1}{u}{h2};".format({"c":config_name,"u":formula, "h0":type_string_list[0], "h1":type_string_list[1], "h2":type_string_list[2]})
		cola += "\n#{c} = {s};".format({"c":config_name, "s":size})
		
		return cola


class PosConstraint:
	
	var configuration
	var domain
	var position
	
	func _init(_config : Configuration, _position : int, _domain : Domain):
		
		configuration = _config
		position = _position
		domain = _domain
	
	
class SizeConstraint:
	
	
	var operator = ""
	var size = 0
	
	
	func init(operator : String, size : int):
		
		self.operator = operator
		self.size = size


# Class for CoLa Expressions
class CoLaExpression:
	
	var type = ""
	var global_type
	var cola_string
	
	func _init(expression : String):
		
		cola_string = expression
		
		# Comment
		if "%" in expression:
			type = "comment"
		
		#Counts
		elif "#" in expression:
			if "(" in expression:
				type = "constraint_count"
			else:
				type = "config_size"
		
		# Domain or  positionconstraint
		elif "=" in expression:
			# Domain
			if "[" in expression:
				type = "domain_interval"
			elif "{" in expression:
				type = "domain_enum"
		
		# Coniguration
		elif "in" in expression:
			
			if "[" in expression:
				
				if "||" in expression:
					type = "config_sequence"
				elif "|" in expression:
					type = "config_permutation"
					
			elif "{" in expression:
				
				if "||" in expression:
					type = "config_multisubset"
				elif "|" in expression:
					type = "config_subset"
			
			elif "partitions" in  expression:
				type = "config_partition"
			
			elif "compositions" in expression:
				type = "config_composition"
		
		global_type = type.split("_")[0] + "s"
	
	
	func get_type() -> String:
		return type
	
	
	func is_type(string : String) -> bool:
		return type == string
	
	
	func get_global_type() -> String:
		return global_type
	
	
	func is_global_type(string : String) -> bool:
		return global_type == string
	
		
	func get_string() -> String:
		return cola_string
	
	
	#translates CoLa string to func string
	func translate() -> String:
		
		var tmp = "0"
		
		match type:
			
			"comment":
				pass
			
			"domain_interval":
				
				var dist = true
				var list = cola_string.split("=")
				if "ïndist" in list[0]:
					dist = false
					list[0].replace("indist","")
					list[0].replace(" ","")
				list[1].replace(" ","")
				var _name = list[0]
				var interval_string = list[1].replace(":",",")
				tmp = "domain_interval('{n}','{s}','{d}')".format({"n" : _name, "s" : interval_string,"d" : dist})
			
			"domain_enum":
				
				tmp = "1"
			
			"config_sequence":
				
				tmp = "seq"
			
			"config_permutation":
				tmp = "perm"
			
			"config_mulitsubset":
				tmp = "msubset"
			
			"config_subset":
				tmp = "subset"
			
			"config_partition":
				tmp = "part"
				
			"config_composition":
				tmp = "composition"
			
			"config_size":
				tmp = "config_size"
			
			"constraint_count":
				tmp = "constraint_count"
				
		return tmp

# Interval class
class Interval extends IntervalString:
	
	func _init(start, end).("[{s},{e}]".format({"s" : start, "e" : end})):
		pass


# Base interval class
class IntervalString:
	
	var str_interval
	var values = []
	
	func _init(interval : String):
		
		str_interval = interval
		var tmp = interval.replace("[","").replace("]","")
		tmp = tmp.split_floats(",")
		for i in range(tmp[0],tmp[1]+1):
			values.append(i)
	
	
	# Get the string version of the interval 
	# --ex: "[0,1]"
	func string() -> String:
		return str_interval
	
	
	# Get a list of all values within the interval
	func get_values() -> Array:
		return values

