#
# converting string like ruby's hash into Hash
#
# input example:
#
#    {
#      name => MyName,
#      id => MyIdent
#    }
#

class HashParser
rule

hash    : '{' contents '}'   { result = val[1] }
        | '{' '}'            { result = Hash.new }
         
contents: IDENT '=>' IDENT   # Racc can handle string over 2 bytes.
            {
              result = { val[0] => val[2] }
            }
        | contents ',' IDENT '=>' IDENT
            {
              result[ val[2] ] = val[4]
            }

end

---- inner

  def parse( str )
    @q = []

    until str.empty? do
      case str
      when /\A\s+/
        ;
      when /\A\w+/
        @q.push [:IDENT, $&]
      when /\A=>/
        @q.push ['=>', '=>']
      else
        c = str[0,1]
        @q.push [c, c]
        str = str[1..-1]
        next
      end
      str = $'
    end
    @q.push [false, '$']   # DO NOT FORGET THIS!!!

    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

p HashParser.new.parse <<S
{
  name => MyName,
  id => MyIdent
}
S