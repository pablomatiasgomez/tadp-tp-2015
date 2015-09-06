class Aspect

  def self.find_origins(*args)

    args_regexps = args.grep(Regexp)
    regexp_origins = []

    args_regexps.each do |one_regexp|
      regexp_origins += Object.constants.grep(one_regexp).map {|regex_symbol| Object.const_get(regex_symbol)}
    end

    (args - args_regexps + regexp_origins).uniq

  end

  def self.on(*args, &block)

    origins = find_origins(*args)

  end

end