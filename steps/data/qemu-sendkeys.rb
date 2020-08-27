#!/usr/bin/env ruby
# Translate a string to "sendkey" commands for QEMU.
# Martin Vidner, MIT License

# https://en.wikibooks.org/wiki/QEMU/Monitor#sendkey_keys
# sendkey keys
#
# You can emulate keyboard events through sendkey command.
# The syntax is: sendkey keys. To get a list of keys, type sendkey [tab].
# Examples:
#
#     sendkey a
#     sendkey shift-a
#     sendkey ctrl-u
#     sendkey ctrl-alt-f1
#
# As of QEMU 0.12.5 there are:
# shift 	shift_r 	alt 	alt_r 	altgr 	altgr_r
# ctrl 	ctrl_r 	menu 	esc 	1 	2
# 3 	4 	5 	6 	7 	8
# 9 	0 	minus 	equal 	backspace 	tab
# q 	w 	e 	r 	t 	y
# u 	i 	o 	p 	ret 	a
# s 	d 	f 	g 	h 	j
# k 	l 	z 	x 	c 	v
# b 	n 	m 	comma 	dot 	slash
# asterisk 	spc 	caps_lock 	f1 	f2 	f3
# f4 	f5 	f6 	f7 	f8 	f9
# f10 	num_lock 	scroll_lock 	kp_divide 	kp_multiply 	kp_subtract
# kp_add 	kp_enter 	kp_decimal 	sysrq 	kp_0 	kp_1
# kp_2 	kp_3 	kp_4 	kp_5 	kp_6 	kp_7
# kp_8 	kp_9 	< 	f11 	f12 	print
# home 	pgup 	pgdn 	end 	left 	up
# down 	right 	insert 	delete

require "optparse"

UPCASE_PAIRS = ("A".."Z").map do |i|
  [i, "shift-#{i.downcase}"]
end

KEYS = {
  # ASCII-sorted
  " "  => "spc",
  "!"  => "shift-1",
  '"'  => "shift-apostrophe",
  "#"  => "shift-3",
  "$"  => "shift-4",
  "%"  => "shift-5",
  "&"  => "shift-7",
  "'"  => "apostrophe",
  "("  => "shift-9",
  ")"  => "shift-0",
  "*"  => "shift-8",
  "+"  => "shift-equal",
  ","  => "comma",
  "-"  => "minus",
  "."  => "dot",
  "/"  => "slash",
  # 0..9 work as literals
  ":"  => "shift-semicolon",
  ";"  => "semicolon",
  "<"  => "shift-comma",
  "="  => "equal",
  ">"  => "shift-dot",
  "?"  => "shift-slash",
  "@"  => "shift-2",
  # A..Z via UPCASE_PAIRS
  "["  => "bracket_left",
  "\\" => "backslash",
  "]"  => "bracket_right",
  "^"  => "shift-6",
  "_"  => "shift-minus",
  "`"  => "grave_accent",
  # a..z work as literals
  "{"  => "shift-bracket_left",
  "|"  => "shift-backslash",
  "}"  => "shift-bracket_right",
  "~"  => "shift-grave_accent"
}.merge Hash[UPCASE_PAIRS]

class Main
  attr_accessor :command
  attr_accessor :keystring

  def initialize
    self.command = nil

    OptionParser.new do |opts|
      opts.banner = "Usage: sendkeys [-c command_to_pipe_to] STRING\n" \
        "Where STRING can be 'ls<ret>ls<gt>/dev/null<ret>'\n" \
        "and a <delay> delays 1s instead of sending a key"

      opts.on("-c", "--command COMMAND",
        "Pipe sendkeys to this commands, individually") do |v|
        self.command = v
      end
    end.parse!
    self.keystring = ARGV[0] || ""
  end

  def sendkey(qemu_key_name)
    qemu_cmd = "sendkey #{qemu_key_name}"
    if command
      system "echo '#{qemu_cmd}' | #{command}"
    else
      puts qemu_cmd
      $stdout.flush # important when we are piped
    end
    sleep 0.1
  end

  PATTERN = /
              \G  # where last match ended
              < [^>]+ >
            |
              \G
              .
            /x
  def run
    keystring.scan(PATTERN) do |match|
      if match[0] == "<"
        key_name = match.slice(1..-2)

        if key_name == "delay"
          sleep 1
          next
        end

        sendkey case key_name
                when "lt" then "shift-comma"
                when "gt" then "shift-dot"
                else key_name
                end
      else
        sendkey KEYS.fetch(match, match)
      end
    end
  end
end

Main.new.run
