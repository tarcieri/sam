require 'optparse'
require 'sam/manager'

module Sam
  class Cli
    #################
    # Class Methods #
    #################
  
    module ClassMethods
      # Things Sam can do
      def commands
        @commands ||= {}
      end
    
      # Have Sam do something
      def command(name, description, &block)
        commands[name.to_s] = [description, block]
      end
    end
    extend ClassMethods
  
    ############
    # Commands #
    ############
    
    command :update, "Update source indexes" do
      Sam::Indexes.setup
    
      Sam::Indexes.sources.each do |source|
        Sam::Indexes.update source
      end
    end
  
    ###########
    # Methods #
    ###########

    def initialize
      execute
    end
  
    def execute
      name = ARGV.shift
      usage unless name
    
      command = Cli.commands[name]
      usage unless command
    
      instance_eval(&command.last)
    end
  
    def usage
      Tty.puts "sam: Ruby package manager"
      Tty.puts "\nUsage:"
      
      commands = Cli.commands.keys.sort
      commands.each do |name|
        description, _ = Cli.commands[name]
        Tty.puts "  sam #{name}\t\t#{description}"
      end
      
      exit 1
    end
  end
end

Sam::Cli.new