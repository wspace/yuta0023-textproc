class Whitespace

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

  def initialize
    @tokens = []
    @program = ARGF.read.tr("^ \t\n", "")
    tokenize
    p @tokens
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
Whitespace.new
