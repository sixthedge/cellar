DEFAULT_COLOR = :light_cyan

PRINT_COLORS = {
  clear:            "\e[0m",   # Embed in a String to clear all previous ANSI sequences.
  bold:             "\e[1m",   # The start of an ANSI bold sequence.
  black:            "\e[30m",
  red:              "\e[31m",
  green:            "\e[32m",
  yellow:           "\e[33m",
  blue:             "\e[34m",
  magenta:          "\e[35m",
  cyan:             "\e[36m",
  gray:             "\e[90m",
  white:            "\e[97m",
  light_gray:       "\e[37m",
  light_red:        "\e[91m",
  light_green:      "\e[92m",
  light_yellow:     "\e[93m",
  light_blue:       "\e[94m",
  light_magenta:    "\e[95m",
  light_cyan:       "\e[96m",
  on_black:         "\e[40m",
  on_red:           "\e[41m",
  on_green:         "\e[42m",
  on_yellow:        "\e[43m",
  on_blue:          "\e[44m",
  on_magenta:       "\e[45m",
  on_cyan:          "\e[46m",
  on_light_gray:    "\e[47m",
  on_gray:          "\e[100m",
  on_light_red:     "\e[101m",
  on_light_green:   "\e[102m",
  on_light_yellow:  "\e[103m",
  on_light_blue:    "\e[104m",
  on_light_magenta: "\e[105m",
  on_light_cyan:    "\e[106m",
  on_white:         "\e[107m",
}

public

def print_line(line, color=nil, bold=nil); $stdout.print color_line(line, color, bold) + "\n"; end

def print_inline(line, color=nil, bold=nil); $stdout.print color_line(line, color, bold); end

def print_new_line; $stdout.print "\n"; end

def color_line(line, color=DEFAULT_COLOR, bold=nil)
  return line if @no_color
  return line unless color
  if color == :bold
    color = DEFAULT_COLOR
    bold  = :bold
  end
  line = bold_line + line  if bold == :bold
  prt_color = PRINT_COLORS[color]
  print_error "Print color '#{color.inspect}' is not supported." if prt_color.blank?
  prt_color + line + clear_line
end

def clear_line; PRINT_COLORS[:clear]; end
def bold_line;  PRINT_COLORS[:bold]; end

def print_error(message)
  print_line message, :red
  exit
end

def ask_prompt(message='', color=nil, bold=nil)
  print_line message, color, bold
  (STDIN.gets.chomp || '').strip
end

def ask_inline_prompt(message='', color=nil, bold=nil)
  print_inline message, color, bold
  (STDIN.gets.chomp || '').strip
end

def clear_console; system('clear') or system('cls'); end
