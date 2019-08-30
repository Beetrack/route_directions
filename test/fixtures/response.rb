class Response
  class << self
    def waypoints(options, provider)
      body = if options[:splited]
               if options[:split_count].zero?
                 first_half_body(provider)
               else
                 second_half_body(provider)
               end
             else
               full_body(provider)
             end
      body.to_json
    end

    def waypoints_with_optimize(number)
      
    end

    private

    def full_body(provider)
      read_file("./test/fixtures/#{provider.downcase}_full.json")
    end

    def first_half_body(provider)
      read_file("./test/fixtures/#{provider.downcase}_first_half.json")
    end

    def second_half_body(provider)
      read_file("./test/fixtures/#{provider.downcase}_second_half.json")
    end

    def read_file(path)
      JSON.parse(File.read(path))
    end
  end
end
