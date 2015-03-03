module CodeTable
  module Loader
    def self.load
      Dir.glob(Pathname(CodeTable::Config.load_path).join('*.yml').to_s).each do |target_file|
        _kinds = CodeTable::Source.new(target_file).load
        _kinds.each do |class_name, records|
          build_code_table_class(class_name: class_name.capitalize, records: records)
        end
      end
    end

    def self.build_code_table_class(class_name:, records:)
      CodeTable::Builder.new(class_name: class_name, records: records).build
      # TODO: add to built code table list
    end

    def self.identifiable?(hash)
      return false if hash.empty?
      # {"red"=>1, "blue"=>2} || {"red"=>{code: 1}, "blue"=>{code: 2}}
      # TODO: add validations
      hash.first.last.is_a?(Integer) || (hash.first.last.is_a?(Hash) && hash.first.last['code'].is_a?(Integer))
    end

  end
end
