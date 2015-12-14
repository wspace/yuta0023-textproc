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
    @input = STDIN.gets.chomp
    #puts @cmd.size
  end

  #コマンド評価
  # ed_ver.1
  #   add q,p(n),a,d,return
  def eval
    # regex_addr = '(?:\d+|[.$,;]|\/.*\/)'
    # regex_cmnd = '(wq|[acdefgijkmnpqrsw]|\z)'
    # regex_prmt = '(.*)'


    @size = 0
    @maxline = @buffer.length
    @result = nil
    @addr = @currentline

    if(@input =~ /\A((?:\d+|[.$,;]|\/.*\/)(,(\d+|[.$,;]|\/.*\/))?)?(wq|[acdefgijkmnpqrswP]|\z)((.*))?\z/) then
      if(!$~[1].nil?)
        if($~[1].size > 1) then
          @addr = $~[1].split(",")
          @currentline = @addr[0].to_s
        else
          @addr = $~[1]
          @currentline = @addr
        end
      end
          @cmnd = $~[4]
      # @prmt = $~[6]
      # puts @addr
      # puts @cmnd
      # puts @prmt

      self.send("#{@cmnd}")
      @result = "ok"
      # p $~.to_a
      p @addr
      # p @addr[1]
      p @cmnd

    else
      @result = "?"
    end

    @maxline = @buffer.length

  end

  #command
  private
  def q
    exit
  end

  def w
    File.open(ARGV[0],"w") do |file|
      @buffer.each do |line|
        file.write(line)
        @size += line.bytesize
      end
    end
  end

  def p
      @result =  "slected -> p"
  end

  def a
    loop do
      @message = STDIN.gets
      if(@message =~ /\./) then break end
      @buffer.insert(@currentline,@message)
      @currentline += 1
    end
  end

  #出力
  def print
    if(!@result.nil?) then puts @result end
  end

end
Ed.new
