class Ed
  def initialize
    puts $size

    #@modestate
    #edit_mode: 0
    #cmd_mode: 1
    @mode = 1

    #if @view is true and @mode:1 then print *
    @view = false

    loop do
      read
      eval
      print
    end
  end

  #コマンド受付
  def read
    #puts @mode
    if(@mode==1 && @view) then printf '*'  end
    @cmd = STDIN.gets.chomp
    #puts @cmd.size
  end

  def eval

    @result = nil
    if (@cmd.match(/[acdi]/)) then @mode = 0 end
    if(@cmd.size < 2) then
      if(@cmd =~ /a/) then
      elsif(@cmd =~ /c/) then
      elsif(@cmd =~ /d/) then
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
          puts $buffer[$lines-1]
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
      elsif(@cmd =~ /r/) then
      elsif(@cmd =~ /s/) then
      elsif(@cmd =~ /t/) then
      elsif(@cmd =~ /u/) then
      elsif(@cmd =~ /w/) then
      elsif(@cmd =~ /W/) then
      elsif(@cmd =~ /z/) then
      elsif(@cmd =~ /\=/) then
      elsif(@cmd =~ /\=/) then
      elsif(@cmd =~ /\./) then
        @mode = 1
      else
        @result = "?"
      end
    else
      @result = "?"
    end
  end

  #出力
  def print
    puts @result
  end
end

#メイン処理
$size = 0
$lines = 0

begin
 $file = File.open(ARGV[0])
rescue
  puts $!
  exit
end

$buffer = []
$file.each do |line|
  $buffer.push(line)
  $size += line.bytesize
  $lines += 1 if line =~ /\n/
end
$file.close
Ed.new
