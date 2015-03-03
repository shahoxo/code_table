module CodeTable
  module Model
    class InvalidKindError < StandardError; end

    # attr_accessor :code, :type
    # alias id code
    #
    # def initialize(code: nil, type: nil)
    #   @code, @type = code, type
    # end

    def ==(other)
      return false if !(other.respond_to?(:code) && other.respond_to?(:type))
      (code == other.code) && (type == other.type)
    end

    module ClassMethods
      def build(code: nil, type: nil)
        raise InvalidKindError, 'need code or type for searching' if code.nil? && type.nil?
        case
        when code
          type ||= fetch_by_code(code)
        when type
          code ||= fetch_by_type(type)
        end
        raise InvalidKindError, "unknown type #{type}" unless kinds.key?(type)
        raise InvalidKindError, 'do not match combination of code and type' if code && type && code != fetch_by_type(type)
        new(code: code, type: type)
      end

      def kinds
        @kinds || {}
      end

      def fetch_by_code(code)
        kinds.key(code)
      end

      def fetch_by_type(type)
        # TODO: consider to use ActiveSupport::IndifferentAccess
        kinds[type]
      end

      def all
        @all || []
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
