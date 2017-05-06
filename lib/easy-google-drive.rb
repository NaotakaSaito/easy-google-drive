require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'termcolor'

require 'fileutils'

module EasyGoogleDrive
end

require_relative 'easy-google-drive/version.rb'
require_relative 'easy-google-drive/file_base.rb'
require_relative 'easy-google-drive/file_api.rb'
require_relative 'easy-google-drive/spreadsheet.rb'

