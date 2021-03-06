module Alfred
  ##
  # Holds all information about a scenario.
  #
  class Scenario

    attr_accessor :name, :setups, :method, :controller, :action, :params, :identifier, :response

    ##
    # Initialize a new Alfred scenario.
    #
    # @param name [String] the name of the scenario
    # @example
    #   Scenario.new('admin permissions')
    #
    def initialize(name)
      @name   = name.downcase.gsub(' ', '_')
      @setups = []
    end

    ##
    # Returns the controller name based on controller class name.
    #
    # @return [String] the name of the controller
    # @example
    #   scenario = Scenario.new('test')
    #   scenario.controller = Api::V1::UserController
    #
    #   scenario.controller_name #=> 'api/v1/users_controller'
    #
    def controller_name
      controller.name.underscore
    end

    ##
    # Runs the scenario.
    #
    def run
      setup_request
      perform_setup
      perform_request

      ## Persist response to disk
      file.save
    ensure
      # Make sure to teardown mocks
      @request.teardown_mocks
    end

    ##
    # Initialize or return existing file instance.
    #
    # @return [Alfred::FixtureFile] instance of FixtureFile
    #
    def file
      @file ||= FixtureFile.new(@response, controller_name, action, name)
    end

    private

      ##
      # Initialize a new Request.
      #
      def setup_request
        controller.send(:include, ::Rails.application.routes.url_helpers)

        ## Setup request
        @request = Request.new(name)
        @request.setup_mocks
        @request.set_controller(controller)
        @request.setup_controller_request_and_response
      end

      ##
      # Perform global and scenario setups to request.
      #
      def perform_setup
        ## Run global setup before example
        Alfred.configuration.setup.each do |setup|
          @request.perform_setup(&setup)
        end

        ## Run setup blocks for scenario
        setups.each { |setup| @request.perform_setup(&setup) }
      end

      ##
      # Perform request and assign response.
      #
      def perform_request
        ## Perform request
        @request.send(method, action, params)

        ## Set response
        @response = @request.response
      end

  end # Scenario
end # Alfred
