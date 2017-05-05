require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'termcolor'

require 'fileutils'

module EasyGoogleDrive
end

require_relative 'file_base.rb'
require_relative 'file_api.rb'
require_relative 'spreadsheet.rb'

