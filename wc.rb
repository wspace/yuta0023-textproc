require 'optparse'
#OptionParserオブジェクトの生成
opt = OptionParser.new
option_state = {}

#オプションを取り扱うブロックをoptに登録
opt.on('-l') {|state| option_state[:l] = state }
opt.on('-w') {|state| option_state[:w] = state }
opt.on('-c') {|state| option_state[:c] = state }

opt.parse!(ARGV)

#トータル用の変数
total_lines = 0
total_words = 0
total_size = 0

#複数ファイル対応
ARGV.size.times do |num|
  file = open(ARGV[num])
  lines = 0
  words = 0
  size = 0
  file_name = ARGV[num].split("/").pop

  file.each{|line|
    #wcは\nで判定する
    lines += 1 if line =~ /\n/
    size += line.bytesize
    words += line.split.size
  }

  total_lines += lines
  total_words += words
  total_size += size

  #option対応
  print " #{lines.to_s.rjust(7)}" if option_state[:l]
  print " #{words.to_s.rjust(7)}" if option_state[:w]
  print " #{size.to_s.rjust(7)}" if option_state[:c]
  puts " #{file_name}" unless option_state.empty?

  #option無し
  puts " #{lines.to_s.rjust(7)} #{words.to_s.rjust(7)} #{size.to_s.rjust(7)} #{file_name}" if option_state.empty?
  file.close
end

#複数対応出力
puts " #{total_lines.to_s.rjust(7)} #{total_words.to_s.rjust(7)} #{total_size.to_s.rjust(7)} total" if ARGV.size > 1
