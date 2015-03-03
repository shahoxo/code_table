=begin
weapon:
  sword:
    one_hand:
      muramasa:
        code: 100
        strength: 123
      kamui:
        code: 200
        strength: 115
    niren: 10

#=>

[{name: muramasa, code: 100, strength: 123, scopes: [:sword]}, {...}]

#<Weapon name: muramasa, code: 100, strength: 123, scopes: [:sword]>
=end

module CodeTable
  class Builder
    def initialize(class_name:, records:)
      @class_name, @records = class_name.capitalize, records
    end
    
    def build
      return if Object.const_defined?(@class_name)

      built_records = Records.new(records: @records).build
      properties = built_records.map(&:keys).map(&:to_set).inject(&:+)
      scopes = built_records.map{|hash| hash["scopes"] || []}.inject(&:+).to_set

      klass = Class.new(Hashie::Dash) do |code_table_class|
        include CodeTable::Model
        properties.each do |prop|
          property prop.to_sym
        end

        built_records.each do |hash|
          define_singleton_method(hash["name"]) { hash["code"] }
        end
      end

      Object.const_set(@class_name, klass)
      klass.instance_variable_set(:@all, built_records.map{|record| klass.new(record.map{|k, v| [k.to_sym, v]}.to_h)})


      scoped_class_name = "Scoped" + @class_name
      scoped_module_name = "Scopable" + @class_name
      return if Object.const_defined?(scoped_class_name)
      return if Object.const_defined?(scoped_module_name)

      scoped_class = Object.const_set(scoped_class_name, Class.new)

      scoped_module = Object.const_set(scoped_module_name, Module.new do |m|
        scopes.each do |scope|
          define_method scope do
            if self.is_a? scoped_class
              self << scope
            else
              scoped_class.new(scope)
            end
          end
        end
      end
      )

      scoped_class.class_eval do
        include scoped_module

        def initialize(scope)
          @scopes = Set[scope]
        end

        def <<(scope)
          @scopes << scope
          self
        end

        def all
          unscoped_class.all.select{|record| record.scopes.to_set.superset? @scopes}
        end

        def method_missing(*args)
          all.send(*args)
        end

        define_method :unscoped_class do
          klass
        end
      end

      klass.send(:extend, scoped_module)
    end

    class Records
      def initialize(records:, scopes: [])
        @formatted = []
        @naive_records = {}
        @records, @scopes = records, scopes
      end

      def build
        @scopes += @records.delete("scopes") if @records["scopes"]
        @records.each do |k, v|
          if tuple?(v)
            @formatted << format_to_code_table_tuple(k, v)
          else
            @naive_records[k] = v
          end
        end
        add_scopes

        if !@naive_records.empty?
          @naive_records.each do |k, v|
            @formatted += Records.new(records: v, scopes: [k]).build
          end
        end
        @formatted
      end

      def add_scopes
        return if @scopes.empty?
        @formatted.each do |tuple|
          tuple["scopes"] ? tuple["scopes"] += @scopes : tuple["scopes"] = @scopes
        end

        @naive_records.each do |k, v|
          v["scopes"] ? v["scopes"] += @scopes : v["scopes"] = @scopes
        end
      end
      
      def scoped?(record)
        !tuple?(record) && record.values.count > 0
      end
      
      def tuple?(value)
        # return true if {name: XXX} or {name: {code: XXX}}
        value.is_a?(Integer) or (value.is_a?(Hash) && value["code"].is_a?(Integer))
      end

      def format_to_code_table_tuple(key, value)
        if value.is_a? Hash
          value.merge("name" => key)
        else
          {"name" => key, "code" => value}
        end
      end
    end
  end
end
