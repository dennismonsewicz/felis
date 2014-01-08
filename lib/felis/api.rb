module Felis
  class API
    include HTTParty
    
    default_timeout 30
    
    attr_accessor :account_id, :private_key, :public_key, :base_uri, :debug, :timeout
    
    def initialize(options = {})
      @base_uri = options.fetch(:base_uri, "https://api.e2ma.net")
      @account_id = options.fetch(:account_id, ENV['EMMA_ACCOUNT_ID'] || nil)
      @private_key = options.fetch(:private_key, ENV['EMMA_PRIVATE_KEY'] || nil)
      @public_key = options.fetch(:public_key, ENV['EMMA_PUBLIC_KEY'] || nil)
      @debug = options.fetch(:debug, false)
      @timeout = options.fetch(:timeout, 30)
      
      @defaults = { basic_auth: { username: @public_key, password: @private_key } }
      
      setup_base_uri
    end
    
    # HTTP GET Request
    def get(path, query = {})
      request(:get, path, query)
    end
    
    # HTTP POST Request
    def post(path, params = {})
      request(:post, path, params)
    end
    
    # HTTP PUT Request
    def put(path, params = {})
      request(:put, path, params)
    end
    
    # HTTP DELETE Request
    def delete(path, query = {})
      request(:delete, path, query)
    end
    
    private
    
      def request(method, path, params = {})
        self.class.debug_output($stderr) if @debug
        uri = "#{self.class.base_uri}#{path}"
        
        setup_http_body(method, params)
        
        begin
          response = self.class.send(method.to_sym, uri, @defaults)
        
          @parsed_response = nil
        
          if response.body
            @parsed_response = MultiJson.load(response.body)
          
            if should_raise_error?
              error = EmmaError.new(@parsed_response["error"])
              raise error
            end
          end 
        
          @parsed_response
        rescue MultiJson::LoadError => e
          error = EmmaError.new(e)
          raise error
        end
      end
      
      def setup_http_body(method, params)
        unless params.empty?
          @defaults.merge!({query: params}).tap { |h| h.delete(:body) } if [:get, :delete].include? method.to_sym
          @defaults.merge!({body: MultiJson.dump(params)}).tap { |h| h.delete(:query) } if [:put, :post].include? method.to_sym
        end
        @defaults.merge!({timeout: @timeout})
      end
      
      def setup_base_uri
        self.class.base_uri "#{@base_uri}/#{@account_id}"
      end
      
      def should_raise_error?
        @parsed_response.is_a?(Hash) && @parsed_response['error']
      end
  end
end