class Tokenizer

  @@imps = {
    " " => :stack,
    "\t " => :arithmatic,
    "\t\t" => :heap,
    "\n" => :flow,
    "\t\n" => :io
  }

  @@command = {
    :stack => {
      " " => :push,
      "\n " => :dup,
      "\n\t" => :swap,
      "\n\n" => :discard
    },
    :arithmatic => {
      "  " => :add,
      " \t" => :sub,
      " \n" => :mul,
      "\t " => :div,
      "\t\t" => :mod,
    },
    :heap => {
      " " => :store,
      "\t" => :retrive,
    },
    :flow => {
      "  " => :label,
      " \t" => :call,
      " \n" => :jump,
      "\t " => :jz,
      "\t\t" => :jn,
      "\t\n" => :ret,
      "\n\n" => :exit,
    },
    :io => {
      "  " => :outchar,
      " \t" =>:outnum ,
      "\t " => :readchar,
      "\t\t" => :readnum,
    }
  }

  @@parameter = [:push, :label, :call, :jump, :jz, :jn]

  attr_reader :tokens

  def initialize
    @tokens = []
    @program = ARGF.read.tr("^ \t\n", "")
    tokenize
    # p @tokens
  end

  def tokenize
    while @program != ""
      #imp
      if @program =~ /\A(#{@@imps.keys.join('|')})/
        imp = @@imps[$1]
        # p imp
        @program.sub!(/\A(#{@@imps.keys.join('|')})/,"")
      else
        raise Exception, "undifined imp"
      end

      #command
      if @program =~ /\A(#{@@command[imp].keys.join('|')})/
        command = @@command[imp][$1]
        # p command
        @program.sub!(/\A(#{@@command[imp].keys.join('|')})/,"")

        #parameter
        if @@parameter.include?(command)
          if $' =~ /\A([ \t]+)\n/
            parameter = eval("0b#{$1.tr(" \t", '01')}")
            @program.sub!(/\A([ \t]+)\n/,"")
          else
            raise Exception, "undifined parameters"
          end
        end
      else
        raise Exception, "undifined command"
      end

      @tokens << [imp,command,parameter]
    end
  end
end
class Executor
  def initialize(tokens)
    @tokens = tokens
  end

  def run
    @pc = 0
    @stack = []
    @heap = {}
    @call = []
    loop do
      imp, cmd, prm = @tokens[@pc]
      @pc += 1
      exit if @tokens.count < @pc
      case cmd
      when :push then @stack.push prm
      when :dup then @stack.push @stack[-1]
      when :swap then @stack[-1],@stack[-2] = @stack[-2], @stack[-1]
      when :discard then @stack.pop

      when :add then math('+')
      when :sub then math('-')
      when :mul then math('*')
      when :div then math('/')
      when :mod then math('%')

      when :store
        value = @stack.pop
        address = @stack.pop
        @heap[address] = value
      when :retrive then @stack.push @heap[@stack.pop]

      when :label
      when :call
        @call.push(@pc)
        jump(prm)
      when :jump then jump(prm)
      when :jz then jump(prm) if @stack.pop == 0
      when :jn then jump(prm) if @stack.pop < 0
      when :ret then @pc = @call.pop
      when :exit then exit

      when :outchar then print @stack.pop.chr
      when :outnum then print @stack.pop
      when :readchar then @heap[@stack.pop] = $stdin.gets
      when :randum then @heap[@stack.pop] = $sdin.gets.to_i
      else raise Exception, 'Executor faild'
      end
    end
  end

  def math(op)
    b = @stack.pop
    a = @stack.pop
    @stack.push eval("a #{op} b")
  end

  def jump(label)
    @tokens.each_with_index do |token,i|
      if token == [:flow, :label, label]
        @pc = i
        break
      end
    end
  end
end
Executor.new(Tokenizer.new.tokens).run
