module Meta

	PROG_NAME = "NetherWorld-Ruby"
	PROG_VERSION = "0.0.1"
	PROG_INFO = PROG_NAME + " version " + PROG_VERSION
	PROG_INFO_ = PROG_NAME + " " + PROG_VERSION
	PROG_SUMMARY = "a simple RPG game"
	COPYRIGHT = "(C) Linus Arver 2014"

	def about_msg()
		x = "linux"
		y = "ucla"
		z = "edu"
		[ PROG_INFO_\
		, COPYRIGHT\
		, "<" + x + "@" + y + "." + z + ">"\
		].join("\n")
	end
end
