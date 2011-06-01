module Sam
  # TTY functions for controlling colors
  module Tty
    # Add all functions to self
    module_function
    
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
  end
end