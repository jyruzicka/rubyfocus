module Rubyfocus
	module ConditionalExec
		def conditional_set(key, object, &blck)
			send("#{key}=", blck[object]) if object
		end
	end
end