require "code_table/version"
require "key_path"
require "hashie/dash"

require "wirb"
Wirb.start

module CodeTable
  autoload :Model, "code_table/model"
  autoload :Config, "code_table/config"
  autoload :Source, "code_table/source"
  autoload :Loader, "code_table/loader"
  autoload :Builder, "code_table/builder"
end
