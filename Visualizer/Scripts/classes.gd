
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


# Domain class
class Domain:
	
	var domain_name
	var elements
	var distinguishable
	func _init(_name : String, _elements : Array, _distinguishable = true):
		
		domain_name = _name
		elements = _elements
		distinguishable = _distinguishable
	
	# Get a list containing all elements
	func get_elements() -> Array:
		return elements
	
	
	# Get domain size
	func get_size():
		return len(self.elements)
	

	# Translates to cola expression
	func to_cola() -> String:
		
		var tmp = str(elements).replace("[","{").replace("]","}").replace(" ","")
		if is_interval():
			tmp = get_interval().string().replace(",",":").replace(" ","")
		var cola = "{d} = {e}".format({"d" : domain_name, "e" : tmp})
		return cola
	
	
	# Returns the intersection with the specified domain
	func inter(domain : Domain) -> Domain:
		return domain
	
	
	# Returns the union with the specified domain
	func union(domain : Domain) -> Domain:
		return domain
	
	
	# Checks if this domain is an interval
	func is_interval() -> bool:
		#UNFINISHED
		if typeof(elements) != TYPE_INT_ARRAY:# && typeof(elements) != TYPE_ARRAY:
			return false
		var hi = elements.max()
		var lo = elements.min()
		elements.sort()
		if elements == range(lo,hi+1):
			return true
		return false
	
	
	# Return interval object
	func get_interval():
		
		if is_interval():
			var hi = elements.max()
			var lo = elements.min()
			return Interval.new(lo,hi)
		return -1
	
	
	func is_distinguishable() -> bool:
		return distinguishable


class Configuration:
	
	var size
	var config_name
	var type
	
	func _init(_name, _type, _size = 1):
		
		config_name = _name
		size = _size
		type = _type
		
	
	func set_size(_size: int):
		size = _size
	
	
	func get_size() -> int:
		return size
	
	
	func get_name():
		return config_name


class Problem:
	
	var universe
	var domains
	var configuration
	var entity_map
	var count_formulas
	
	func _init():
		domains = {}
		entity_map = {}
		count_formulas = []
	
	
	func add_domain():
		pass



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
