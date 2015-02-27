require 'yaml'
require 'erb'

module CodeTable
  class Source
    def initialize(path)
      @path = path
    end

    def load
      if @path and File.exist?(@path.to_s)
        result = YAML.load(ERB.new(IO.read(@path.to_s)).result)
      end
      result || {}
    end
  end
end
