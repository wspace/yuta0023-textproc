begin
  patt = Regexp.new ARGV[0]
  file = open(ARGV[1])
  file.each{|line|
      if line =~ patt
        puts line
      end
  }
  file.close
rescue
  puts "egrep:" $!
  exit
end
