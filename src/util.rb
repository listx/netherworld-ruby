require 'parslet'

class ParserHelpers < Parslet::Parser
	# See https://github.com/kschiess/parslet/blob/master/example/string_parser.rb
	rule(:string_literal) do
		str('"') >>
		(
			(str('\\') >> any) |
			(str('"').absent? >> any)
		).repeat.as(:string_literal) >>
		str('"')
	end

	rule(:space) do
		match('[ \t\n]')
	end

	rule(:whitespace_) do
		((comment | space).repeat).maybe
	end

	# See https://github.com/kschiess/parslet/blob/master/example/comments.rb
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
end

# Convert dashes to underscores.
def no_dash(str)
	str.gsub(/-/,'_')
end
