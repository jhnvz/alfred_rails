require 'rr'

module Alfred
  module MockingAdapters
    module RR

      def self.framework_name; :rr end

      include ::RR::Extensions::InstanceMethods

      def setup_mocks
        ::RR::Space.instance.reset
      end

      def verify_mocks
        ::RR::Space.instance.verify_doubles
      end

      def teardown_mocks
        ::RR::Space.instance.reset
      end

    end # RR
  end # MockingAdapters
end # Alfred
