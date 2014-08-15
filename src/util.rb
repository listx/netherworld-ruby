require 'parslet'

# Some of the parsers here come from the following resources:

# https://github.com/kschiess/parslet/blob/master/example/string_parser.rb
# https://github.com/kschiess/parslet/blob/master/example/comments.rb
class ParserHelpers < Parslet::Parser
	rule(:string_literal) do
		(str('"') >>
		(
			(str('\\') >> any) |
			(str('"').absent? >> any)
		).repeat >>
		str('"')).as(:string_literal)
	end

	rule(:space) do
		match('[ \t\n]')
	end

	rule(:whitespace) do
		(space.repeat).maybe
	end

	rule(:whitespace_) do
		((comment | space).repeat).maybe
	end

	rule(:comment) do
		(str('#') >> (newline.absent? >> any).repeat)#.as(:comment)
	end

	# We only look for UNIX file endings.
	rule(:newline) do
		str("\n") # >> str("\r").maybe
	end

	rule(:integer) do
		match('\d').repeat(1)
	end

	rule(:hex) do
		match('\h').repeat(1)
	end

	rule(:hex_single) do
		match('\h')
	end

	def braces(atom)
		whitespace_.maybe >>
			str('{') >>
			whitespace_.maybe >>
			atom >>
			whitespace_.maybe >>
			str('}') >>
			whitespace_.maybe
	end

	def brackets(atom)
		whitespace_.maybe >>
			str('[') >>
			whitespace_.maybe >>
			atom >>
			whitespace_.maybe >>
			str(']') >>
			whitespace_.maybe
	end
end

class String
	# Convert dashes to underscores.
	def undash
		self.gsub(/-/,'_')
	end

	def enclose(a, b)
		a + self + b
	end

	def squote()
		self.enclose("`","'")
	end

	def squote_()
		self.enclose(" `","' ")
	end

	# Remove quotes
	def unquote
		match = /"(.*)"/.match(self)
		match ?  match[1] : self
	end
end
