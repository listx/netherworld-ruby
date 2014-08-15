require 'pp'

require_relative 'util'

def err_msg(str)
	STDERR.print ("error: " + str)
end

def err_msgn(str)
	STDERR.puts ("error: " + str)
end

def file_exist_check(fp)
	file_exists = File.file?(fp)
	if file_exists
		return 0
	else
		err_msgn("file" + fp.squote_ + "does not exist")
		return 1
	end
end

def files_exist_check(fps)
	err_nos = fps.map {|fp| file_exist_check(fp)}
	return err_nos.reduce(:+) == 0 ? 0 : 1
end
