module CodeTable
  module Config
    @@load_path = "config/code_tables"

    def self.load_path
      @@load_path
    end

    def self.load_path=(path)
      @@load_path = path
    end
  end
end
