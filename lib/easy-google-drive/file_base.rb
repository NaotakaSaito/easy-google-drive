class EasyGoogleDrive::Drive
	OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
	APPLICATION_NAME = 'Google Apps Script Execution API Ruby Quickstart'
	CLIENT_SECRETS_PATH = 'client_secret.json'
	CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
			"script-ruby-quickstart.yaml")
	SCOPE = 'https://www.googleapis.com/auth/drive'
	##
	# Ensure valid credentials, either by restoring from the saved credentials
	# files or intitiating an OAuth2 authorization. If authorization is required,
	# the user's default browser will be launched to approve the request.
	#
	# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
'''
	Supported MIME Types
	You can use MIME types to filter query results or have your app listed in the Chrome Web Store list of apps that can open specific file types.
	The following table lists MIME types that are specific to G Suite and Google Drive.
	MIME Type 	Description
	application/vnd.google-apps.audio 	
	application/vnd.google-apps.document 	Google Docs
	application/vnd.google-apps.drawing 	Google Drawing
	application/vnd.google-apps.file 	Google Drive file
	application/vnd.google-apps.folder 	Google Drive folder
	application/vnd.google-apps.form 	Google Forms
	application/vnd.google-apps.fusiontable 	Google Fusion Tables
	application/vnd.google-apps.map 	Google My Maps
	application/vnd.google-apps.photo 	
	application/vnd.google-apps.presentation 	Google Slides
	application/vnd.google-apps.script 	Google Apps Scripts
	application/vnd.google-apps.sites 	Google Sites
	application/vnd.google-apps.spreadsheet 	Google Sheets
	application/vnd.google-apps.unknown 	
	application/vnd.google-apps.video 	
	application/vnd.google-apps.drive-sdk 	3rd party shortcut
'''
	def initialize
		@drive   = Google::Apis::DriveV3
		@service = @drive::DriveService.new
		@service.client_options.application_name = APPLICATION_NAME
		@service.authorization = authorize


		@current_file_list=[]
		@root_path=[]
		root(@root_path,@current_file_list)

		return
	end
	def authorize
		FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

		client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
		token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
		authorizer = Google::Auth::UserAuthorizer.new(
		client_id, SCOPE, token_store)
		user_id = 'default'
		credentials = authorizer.get_credentials(user_id)
		if credentials.nil?
			url = authorizer.get_authorization_url(
				base_url: OOB_URI)
			puts "Open the following URL in the browser and enter the " +
				"resulting code after authorization"
			puts url
			code = gets
			credentials = authorizer.get_and_store_credentials_from_code(
				user_id: user_id, code: code, base_url: OOB_URI)
		end
		credentials
	end

	def root(path,file_list)
	# file list
		page_token = nil
		ref_file = []
		begin
			response = @service.list_files(
				q: "name='gdrive.dat' and trashed = false",
				spaces: 'drive',
				fields: "nextPageToken, files(id, name, parents,kind,mimeType)",
				page_token: page_token)
			for file in response.files
				ref_file.push(file)
			end
			page_token = response.next_page_token
		end while !page_token.nil?
		if ref_file != [] then
			current_folder_id = ref_file[0].parents
		else
			puts "ref file not found"
			file_metadata = Google::Apis::DriveV3::File.new(
				name: "gdrive.dat",
				mine_type: 'application/vnd.google-apps.unknown',
				)
			@service.create_file(file_metadata, fields:'id')
			begin
				response = @service.list_files(
					q: "name='gdrive.dat'",
					spaces: 'drive',
					fields: "nextPageToken, files(id, name, parents,kind,mimeType)",
					page_token: page_token)
				for file in response.files
					ref_file.push(file)
				end
				page_token = response.next_page_token
			end while !page_token.nil?
			current_folder_id = ref_file[0].parents
		end

		path.clear
		path.push({name:"root",id:current_folder_id[0]})
		list(path,file_list)
		return
	end

	def list_files(target,path,list)
		if target == nil then
			list.clear
			@current_file_list.each do |file|
				list.push(file)
			end
			return list
		end
		target_split = target.split("/")
		if target_split == nil then
			if target == "~" or target == "$" then
				directory(target,path,list)
				return
			else
				list.clear
				@current_file_list.each do |file|
					if file.name == target then
						list.push(file)
					end
				end
			end
		else
			target_file = target_split.last
			target_split.pop()
		end
		tmp_list = []
		if target_split == [] then
			list(path,tmp_list)
		else
			target_split.each do |folder|
				if directory(folder,path,tmp_list) == false then
					return false
				end
			end
		end
		list.clear
		tmp_list.each do |file|
			if file.name == target_file or target_file == "*" then
				list.push(file)
			end
		end
		return list
	end

	def get_folderid(target,file_list)
		file_list.each do |file|
			if file.mime_type == "application/vnd.google-apps.folder" then
				if file.name == target then
					return file
				end
			end
		end
		return nil
	end

	def shared(path,list)
		path.clear
		list.clear
		page_token = nil
		begin
			response = @service.list_files(
				q: "trashed = false",
				spaces: 'drive',
				fields: "nextPageToken, files(id, name, parents,kind,mimeType)",
				page_token: page_token)
			for file in response.files
				if file.parents == nil then
					list.push(file)
				end
			end
			page_token = response.next_page_token
		end while !page_token.nil?
		path.push({name:"shared",id:nil})
		return 
	end

	def list(path,file_list)
		current_folder = path.last
		qmsg = sprintf("""'%s' in parents and trashed=false""",current_folder[:id])
		file_list.clear
		
		page_token = nil
		begin
			response = @service.list_files(
				q: qmsg,
				spaces: 'drive',
				fields: "nextPageToken, files(id, name, parents,kind,trashed, mimeType)",
				page_token: page_token)
			for file in response.files
				# Process change
				file_list.push(file)
			end
			page_token = response.next_page_token
		end while !page_token.nil?
		return
	end
	def directory(target,path,list)
		if target == ".." then
			if(path.length > 1) then
				path.pop()
				list(path,list)
			else
				puts "root folder"
				return false
			end
		elsif target == "~" then
			root(path,list)
		elsif target == "$"
			shared(path,list)
		elsif target == "."
			list(path,list)
		else
			if list == [] then
				list(path,list)
				end
			newfolder = get_folderid(target,list)
			if newfolder != nil then
				path.push({name:newfolder.name,id:newfolder.id})
				list(path,list)
			else
				puts "folder not find:: "+target
				return false
			end
		end 
		return true
	end
end

