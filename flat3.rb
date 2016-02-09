# 文列　= 文
# 文 = 代入文 | if文 | print文 | while文 |　'{' 文列 '}'
# 代入文 = 変数 '=' 式
# if文 = 'if' 式 'then' 文 'else' 文 'end'
# input文 = 'in' 変数
# output文 = 'out' 式
# while文 = 'while'式 '{' 文 '}'
# 式 = 項 (('+'|'-')項)*
# 項 = 因子(('*'|'/')因子)*
# 因子 = '-'?(リテラル|'('式')')
# input文とif文は実装できませんでした。

class Flat
  @@keywords = {
    '+' => :add,
    '-' => :sub,
    '*' => :mul,
    '/' => :div,
    '%' => :mod,
    '(' => :lpar,
    ')' => :rpar,
    'if' => :if,
    'then' => :then,
    'else' => :else,
    'end' => :end,
    'in' => :input,
    'out' => :output,
    'while' => :while,
    '"' => :doublequot,
  }

  attr_accessor :code

#初期化
  def initialize()
    @code = ''
    @space = {}
  end

#構文解析

  def get_token()
    if @code =~ /\A\s*(#{@@keywords.keys.map { |t| Regexp.escape(t) } .join('|')})/
      @code = $'
      return @@keywords[$1]
    elsif @code =~ /\A\s*([0-9.]+)/
      @code = $'
      return $1.to_f
    elsif @code =~ /\A\s*([a-zA-z]\w*)/
      @code = $'
      return $1.to_s
    elsif @code =~ /\A\s*(\w+)/
      @code = $'
      return $1.to_s
    elsif @code =~ /\A\s*\z/
      return nil
    end
    return :bad_token
  end

  def unget_token(token)
    return if token == :bad_token || token == nil
    if token.is_a? Numeric
      @code = token.to_s + @code
    else
      @code = @@keywords.key(token) ? @@keywords.key(token) + @code : token + @code
    end
  end

  def expression()
    result = term()
    while true
      token = get_token()
      unless token == :add || token == :sub
        unget_token(token)
        break
      end
      result = [token, result, term()]
    end
    return result
  end

  def term()
    result = factor()
    while true
      token = get_token()
      unless token == :mul || token == :sub
        unget_token(token)
        break
      end
      result = [token, result, factor()]
    end
    return result
  end

  def check()
    fail Exception, "'('が見つからないよ" unless get_token() == :lpar
    token1 = get_token()
    token2 = get_token
    unget_token(token2)

    if token1 == :doublequot
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, '`"`が見つからないよ' unless get_token() == :doublequot
    elsif token1.is_a?(Numeric) || token2 == :add || token2 == :sub || token2 == :mul || token2 == :div
      unget_token(token1)
      result = sentence()
    else
      result = [:variable, token1]
    end

    fail Exception, "')'が見つからないよ" unless get_token() == :rpar
    return result
  end

  def factor()
    token = get_token()
    minusflg = 1

    if token == :sub
      minusflg = -1
      token = get_token()
    end

    if token.is_a? Numeric
      return token * minusflg
    elsif token == :lpar
      result = expression()
      fail Exception, 'unexpected token' unless get_token() == :rpar
      return [:mul, minusflg, result]
    elsif token == :doublequot  # 文字列の計算
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, '`"`が見つからないよ' unless get_token == :doublequot
      return result
    else  # 変数の計算
      return [:variable, token]
    end
  end

  def assign()
    var = get_token()
    if @code =~ /\A\s*(=)/
      @code = $'
    else
      fail Exception, "'='が見つからないよ"
    end

    token1 = get_token()
    if token1 == :doublequot
      if @code =~ /\A\s*(.+)(")/
        @code = $2 + $'
        result = $1.to_s
      end
      fail Exception, '`"`が見つからないよ' unless get_token() == :doublequot
      return [:assignment, [var, result]]
    end

    if token1.to_s =~ /\A\s*(\d+|\d+\.\d+)\z/
      unget_token(token1)
      return [:assignment, [var, sentence()]]
    else
      token2 = get_token()
      unget_token(token2)
      if token2 == %i(add sub mul div)
        unget_token(token1)
        return [:assignment, [var, sentence()]]
      end
      return [:assignment, [var, [:variable, token1]]]
    end
  end


  # blockの中身
  def in_block()
    block = ''
    if @code =~ /(?<paren>{(?:[^{}]|\g<paren>)*})/
      block = $1
      @code = $'

      if block =~ /({)/
        block = $'
      else
        fail Exception, "'{'が見つからないよ"
      end

      if block =~ /\A\s*(.+)(})/m
        block = $1
      else
        fail Exception, "'}'が見つからないよ"
      end

    else
      fail Exception, "'{}'が見つからないよ"
    end

    code, result = @code, @result
    @code = block
    sentences()
    block = @result
    @code, @result = code, result
    block.unshift(:block)
  end

  def par_while()
    num = get_token()
    if num.is_a? Numeric
      num.to_i
      block = in_block()
      return [:while,num,block]
    else
      raise Exception,"ループ回数を指定してください。"
    end
  end

  def sentences()
    @result = []
    while true
      break if @code =~ /\A\s+\z/ || @code == ''
      @result << sentence()
    end
  end

  def sentence()
    token1 = get_token()
    token2 = get_token()
    unget_token(token2)

    # if token1.is_a?(Numeric) || token2 == %i(add sub mul div)
     if token1.is_a?(Numeric)  || token2 == :add || token2 == :sub || token2 == :mul || token2 == :div
      unget_token(token1)
      return expression()
    end

    # 変数
    if token1 =~ /\A\s*([a-zA-z]\w*)/ && !token1.instance_of?(Symbol)
      unget_token(token1)
      return assign()
    end

    case token1
      when :output
        return [:output, check()]
      when :if
        return par_if()
      when :while
        return par_while()
      when :read
        return pre_read()
    end
  end


#解釈実行



  def evaluate()
     p @result
    @result.each { |e|
      eval(e)
    }
    # p @space
  end

  def eval(exp)
    if exp.instance_of?(Array)
      case exp[0]
        when :add
          return eval(exp[1]) + eval(exp[2])
        when :sub
          return eval(exp[1]) - eval(exp[2])
        when :mul
          return eval(exp[1]) * eval(exp[2])
        when :div
          return eval(exp[1]) / eval(exp[2])
        when :input
          print "->"
        when :output
          puts eval(exp[1])
        when :while
          #回数とblock
          flt_while(exp[1],exp[2])
        when :assignment
          @space[exp[1][0]] = eval(exp[1][1])
        when :variable
          return @space[exp[1]] ? eval(@space[exp[1]]) : '0'
        when :block
          flt_block(exp)
      end
    else
      return exp
    end
  end


  def flt_block(block)
    block.each { |b|
      eval(b)
    }
  end

  def flt_while(num,block)
    start = 1
    fin = num
    while true
      eval(block)
      break if start == fin
      start += 1
    end
  end
end


flt = Flat.new
begin
  File.open(ARGV[0]) { |file|
    flt.code = file.read
  }
rescue
  puts 'file not open'
  exit
end

flt.sentences()
flt.evaluate()
