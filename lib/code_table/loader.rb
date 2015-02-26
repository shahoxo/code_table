module CodeTable
  module Loader
    def self.load
      Dir.glob(Pathname(CodeTable::Config.load_path).join('*.yml').to_s).each do |target_file|
        class_name = Pathname(target_file).basename.to_s.split('.').first.capitalize
        next if Object.const_defined?(class_name)

        _kinds = CodeTable::Source.new(target_file).load
        klass = Class.new do |code_table_class|
          include CodeTable::Model
          @kinds = _kinds

          _kinds.each do |name, value|
            define_singleton_method(name) { value }
          end
        end

        Object.const_set(class_name, klass)
      end
    end

  end
end
