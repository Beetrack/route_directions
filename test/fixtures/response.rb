class Response
  class << self
    def waypoints(options, provider)
      body = if options[:splited]
               if options[:split_count].zero?
                 first_half_body(provider, options[:optimized])
               else
                 second_half_body(provider, options[:optimized])
               end
             else
               full_body(provider, options[:optimized])
             end
      body.to_json
    end

    private

    def full_body(provider, optimized)
      read_file(file_path(provider, optimized, 'full'))
    end

    def first_half_body(provider, optimized)
      read_file(file_path(provider, optimized, 'first_half'))
    end

    def second_half_body(provider, optimized)
      read_file(file_path(provider, optimized, 'second_half'))
    end

    def file_path(provider, optimized, aditional_path)
      "./test/fixtures/#{provider.downcase}#{optimized ? '_optimized' : ''}"\
      "_#{aditional_path}.json"
    end

    def read_file(path)
      JSON.parse(File.read(path))
    end
  end
end
