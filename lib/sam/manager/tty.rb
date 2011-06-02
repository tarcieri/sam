module Sam
  # TTY functions for controlling colors
  module Tty
    extend self
    
    def blue; bold 34; end
    def white; bold 39; end
    def red; underline 31; end
    
    def reset; escape 0; end
    def bold(n); escape "1;#{n}" end
    def underline(n); escape "4;#{n}" end
    def escape(n); "\033[#{n}m" end
    
    # OHAI!!
    def ohai(something, tty = STDOUT)
      tty.puts "#{blue}*** #{white}#{something}#{Tty.reset}"
    end
    
    def yeow(something, tty = STDOUT)
      tty.puts "#{red}#{something}#{reset}"
    end
    
    def print(something, tty = STDOUT)
      tty.print something
    end
    
    def puts(something, tty = STDOUT)
      tty.puts something
    end
  end
end