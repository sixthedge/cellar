module Test::Casespace::TerminalColors
  extend ActiveSupport::Concern
  included do

    unless defined? PRINT_COLORS
      PRINT_COLORS = {
        clear:      "\e[0m",   # Embed in a String to clear all previous ANSI sequences.
        bold:       "\e[1m",   # The start of an ANSI bold sequence.
        black:      "\e[30m",  # Set the terminal's foreground ANSI color to black.
        red:        "\e[31m",  # Set the terminal's foreground ANSI color to red.
        green:      "\e[32m",  # Set the terminal's foreground ANSI color to green.
        yellow:     "\e[33m",  # Set the terminal's foreground ANSI color to yellow.
        blue:       "\e[34m",  # Set the terminal's foreground ANSI color to blue.
        magenta:    "\e[35m",  # Set the terminal's foreground ANSI color to magenta.
        cyan:       "\e[36m",  # Set the terminal's foreground ANSI color to cyan.
        white:      "\e[37m",  # Set the terminal's foreground ANSI color to white.
        on_black:   "\e[40m",  # Set the terminal's background ANSI color to black.
        on_red:     "\e[41m",  # Set the terminal's background ANSI color to red.
        on_green:   "\e[42m",  # Set the terminal's background ANSI color to green.
        on_yellow:  "\e[43m",  # Set the terminal's background ANSI color to yellow.
        on_blue:    "\e[44m",  # Set the terminal's background ANSI color to blue.
        on_magenta: "\e[45m",  # Set the terminal's background ANSI color to magenta.
        on_cyan:    "\e[46m",  # Set the terminal's background ANSI color to cyan.
        on_white:   "\e[47m",  # Set the terminal's background ANSI color to white.
      }
    end

    def color_line(line, color=nil, bold=nil)
      return line if @no_color
      return line unless color
      line = terminal_bold_line + line  if bold == :bold
      PRINT_COLORS[color] + line + terminal_clear_line
    end

    def terminal_clear_line; PRINT_COLORS[:clear]; end
    def terminal_bold_line;  PRINT_COLORS[:bold]; end

  end # included
end
