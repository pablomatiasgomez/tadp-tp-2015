require_relative 'origin.rb'


class Aspects

  def self.find_origins(*args)

    origins = []

    args.map do |arg|
      if arg.is_a?(Regexp)
        origins+= Object.constants.grep(arg).map {|regex_symbol| Object.const_get(regex_symbol)}
      else
        origins+= [arg]
      end
    end

    if origins.empty?
      raise 'Error: Empty Origin'
    else
      origins.uniq
    end
    # Abajo otra opcion para hacer esto
=begin
    args_regexps = args.grep(Regexp)
    regexp_origins = []

    args_regexps.each do |one_regexp|
      regexp_origins += Object.constants.grep(one_regexp).map {|regex_symbol| Object.const_get(regex_symbol)}
    end

    origins =(args - args_regexps + regexp_origins)

    if origins.empty?
      raise 'Error: Empty origin'
    else
      origins.uniq
    end
=end
  end

  def self.on(*args, &block)
    origin = Origin.new
    origin.origins= find_origins(*args)

    origin.instance_eval &block
  end

end