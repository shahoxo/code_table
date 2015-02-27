module CodeTable
  module Loader
    def self.load
      Dir.glob(Pathname(CodeTable::Config.load_path).join('*.yml').to_s).each do |target_file|
        _kinds = CodeTable::Source.new(target_file).load
        _kinds.each do |class_name, values|
          build_code_table_class(class_name: class_name.capitalize, values: values)
        end
      end
    end

    def self.build_code_table_class(class_name:, values:)
      return if Object.const_defined?(class_name)

      klass = Class.new do |code_table_class|
        include CodeTable::Model
        @kinds = values

        values.each do |name, value|
          define_singleton_method(name) { value }
        end
      end

      Object.const_set(class_name, klass)
    end

    def self.identifiable?(hash)
      return false if hash.empty?
      # {"red"=>1, "blue"=>2} || {"red"=>{code: 1}, "blue"=>{code: 2}}
      # TODO: add validations
      hash.first.last.is_a?(Integer) || (hash.first.last.is_a?(Hash) && hash.first.last['code'].is_a?(Integer))
    end

  end
end
