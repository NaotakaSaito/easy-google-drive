require 'google/apis/sheets_v4'

class EasyGoogleDrive::Spreadsheet < EasyGoogleDrive::Drive
	#OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
	#APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'
	#CLIENT_SECRETS_PATH = 'client_secret.json'
	#CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             #"sheets.googleapis.com-ruby-quickstart.yaml")
	#SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
	#application/vnd.google-apps.spreadsheet 	Google Sheets
	def open(file)
		tmp_list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		list = list_files(file,tmp_path,tmp_list)
		if list.length == 1 and list[0].mime_type == "application/vnd.google-apps.spreadsheet" then
			@spreadsheet = {
				file: list[0],
				opened: true,
			}
			init_sheet_api()
		elsif list.length == 1 and list[0].mime_type != "application/vnd.google-apps.spreadsheet" then
			puts "file type of "+ file + "is not spreadsheet."
			puts "the file type is " + spreadsheet_file.mime_type + "."
			@spreadsheet = {}
			return true
		elsif list.length > 1 then
			puts "find "+ list.length + "files."
			@spreadsheet = {}
			return false
		else
			puts "cannot find file. Do you create ? (Yes/No)"
			begin
				data = gets.chop
				if ["Yes","Y","yes","y","YES"].find {|n| n == data}
					continue = false
					# create new file
					name = file.split("/").last
					parents = [tmp_path.last[:id]]
					file_metadata = {
						name: name,
						parents: parents,
						mime_type: 'application/vnd.google-apps.spreadsheet',
					}
					@service.create_file(file_metadata, fields: 'id')
					#get file id
					list = list_files(name,tmp_path,tmp_list)
					@spreadsheet = {
						file: list[0],
						opened: true,
					}
					puts "success to create file:: " + name
					init_sheet_api()
				elsif ["No","N","No","n","NO"].find {|n| n == data}
					continue = false
					data = "no"
					@spreadsheet = {}
				else
					puts "cannot find file. Do you create ? (Yes/No)"
					continue = true
				end
			end while(continue)
		end
	end
	def init_sheet_api()
		service = Google::Apis::SheetsV4::SheetsService.new
		service.client_options.application_name = APPLICATION_NAME
		service.authorization = authorize
		spreadsheet_id = @spreadsheet[:file].id
		@spreadsheet[:service] = service
	end
	def addNewLine(sheet,data)
		
		request_body = Google::Apis::SheetsV4::ValueRange.new
		spreadsheet_id = @spreadsheet[:file].id
		if sheet == "" then
			range = "A:"+("A".ord + data.length).chr
		else 
			range = sheet
		end
		
		value_range_object = {
			majorDimension:"ROWS",
			values: [data],
		}
		update_res = @spreadsheet[:service].append_spreadsheet_value(spreadsheet_id, range, value_range_object, value_input_option: 'USER_ENTERED')
		return update_res
	end
	def get(sheet,range)
		if sheet == "" then
			get_range = range
		else
			get_range = sheet + "!" + range
		end
		spreadsheet_id = @spreadsheet[:file].id
		response = @spreadsheet[:service].get_spreadsheet_values(spreadsheet_id, get_range)
		return response.values
	end
	def close()
		initialize()
	end
	def help()
	end
end
