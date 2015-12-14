#まだ途中です...
#対応できていません

class Ed
  def initialize
    begin
     @file = File.open(ARGV[0])
     @size = 0
     @currentline = 0
     @maxline = 0
     @buffer = []
    rescue

    end
    if(!@file.nil?) then
      @file.each do |line|
        @buffer.push(line)
        @size += line.bytesize
      end
      @currentline = @buffer.length
      @maxline = @buffer.length
      puts @size
      puts @buffer.length
      # puts @buffer
    elsif(!ARGV[0].nil?) then
      @filename = ARGV[0]
      puts ARGV[0] + ": No such file or directory"
    end
    #必要な変数
    #@address
    #@command
    #@parameters

    #modestate
    #edit_mode: 0
    #cmd_mode: 1
    @mode = 1
    #puts @buffer

    #if @view is true and @mode:1 then print *
    @view = false
    @mark = "*"

    loop do
      read
      eval
      print
    end

  end

  #コマンド受付
  def read
    #puts @mode
    if(@mode==1 && @view) then printf @mark  end
    @cmd = STDIN.gets.chomp
    #puts @cmd.size
  end

  #コマンド評価
  # ed_ver.1
  #   add q,p(n),a,d,return
  def eval

    @size = 0
    # @file.each do |line|
    #   @size += line.bytesize
    # end

    #コマンド正規表現
    #/\A(adress(,adress)?)?command(parameters)?\z
    #adress -> (?:\d+|[.$,;]|\/.*\/)
    #command -> (wq|[acdefgijkmnpqrsw]|\z)
    #parameters -> (.*)
    #後方参照をうまく利用する
    #式展開も利用
    #/\A((\d+|[.$,;]|\/.*\/)(,(\d+|[.$,;]|\/.*\/))?)?(wq|[acdefgijkmnpqrsw]|\z)((.*))?\z/

    @maxline = @buffer.length
    @result = nil
    if(@cmd.match(/[0-9]/)) then
      @currentline = @cmd[0,1]
      if(!@buffer[@cmd.to_i-1].nil? && @mode == 1) then puts @buffer[@cmd.to_i-1] end
    end
    if (@cmd.match(/[a]/)) then @mode = 0 end
    if(@cmd.size < 2) then
      if(@cmd =~ /a/) then
        loop do
          @message = STDIN.gets
          if(@message =~ /\./) then break end
          @buffer.insert(@currentline,@message)
          @currentline += 1
        end
      elsif(@cmd =~ /c/) then
      elsif(@cmd =~ /d/) then
        @buffer.delete_at(@currentline-1)
        if(@currentline > 0) then @currentline -= 1 end
        puts @currentline
      elsif(@cmd =~ /e/) then
      elsif(@cmd =~ /E/) then
      elsif(@cmd =~ /f/) then
      elsif(@cmd =~ /h/) then
      elsif(@cmd =~ /i/) then
      elsif(@cmd =~ /j/) then
      elsif(@cmd =~ /l/) then
      elsif(@cmd =~ /m/) then
      elsif(@cmd =~ /n/) then
      elsif(@cmd =~ /p/) then
        if (@mode == 1) then
          if(@currentline <= @maxline)
            @result =  @buffer[@currentline-1]
            puts @currentline
          end
        end
      elsif(@cmd =~ /P/) then
        if (@mode == 1) then
          if(!@view) then @view = true
          elsif (@view) then @view = false end
        end
      elsif(@cmd =~ /q/) then
        if(@mode == 1)
          exit
        end
      elsif(@cmd =~ /Q/) then
        if(@mode == 1)
          exit
        end
      elsif(@cmd =~ /r/) then
      elsif(@cmd =~ /s/) then
      elsif(@cmd =~ /t/) then
      elsif(@cmd =~ /u/) then
      elsif(@cmd =~ /w/) then
        File.open(ARGV[0],"w") do |file|
          @buffer.each do |line|
            file.write(line)
            @size += line.bytesize
          end
        end
        puts @size
      elsif(@cmd =~ /W/) then
      elsif(@cmd =~ /z/) then
      elsif(@cmd =~ /\=/) then
      elsif(@cmd =~ /\./) then
        @mode = 1
      elsif(@cmd.empty?) then
        if(@currentline < @maxline)
          @currentline += 1
          puts @currentline
        else
          @result ="?"
        end
      else
        @result = "?"
      end
    else
      @result = "?"
    end
  end

  #出力
  def print
    if(!@result.nil?) then puts @result end
  end

end
Ed.new
