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
          {key => value}
        end
      end
    end
  end
end
