
class EasyGoogleDrive::Drive
	def get(src,dst)
		if dst == "" then
			puts "please enter dst file name"
		end
		tmp_list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		target_list = list_files(src,tmp_path,tmp_list)
		if target_list == [] then
			puts "cannot file file"
		else
			target_list.each do |file|
				if file.mime_type != 'application/vnd.google-apps.folder' then
					@service.get_file(file.id,{download_dest: dst})
					puts "success to get file::" + file.name + "," + file.id
					return
				end
			end
		end
	end


	def mkdir(name)
		parents = []
		parents.push(@root_path.last[:id])
		file_metadata = {
			name: name,
	  		parents: parents,
	  		mime_type: 'application/vnd.google-apps.folder',
			}
		@service.create_file(file_metadata, fields: 'id')
		puts "success to create folder:: " + name
		list(@root_path,@current_file_list)
	end

	def cd(target)
		path_split = target.split("/")
		path_split.each do |folder|
			if directory(folder,@root_path,@current_file_list) == false
				return false
			end
		end
		puts "success to change directory:: "
		pwd()
	end

	def ls(path=nil)
		tmp_list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		list = list_files(path,tmp_path,tmp_list)
		if list == false or list == [] then
			puts "file not found"
		else
# when target is folder, display inside of target
			if list.length == 1 and list[0].mime_type == "application/vnd.google-apps.folder" then
				directory(list[0].name, tmp_path, list)
			end
			list.each do |file|
				if file.mime_type == "application/vnd.google-apps.folder" then
					puts TermColor.parse("<blue>"+file.name+"</blue>")
				else
					puts TermColor.parse(file.name)
				end
			end
		end
	end

	def rmdir(name)
		list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		list_files(name,tmp_path,list)
		# filtering only folder
		list.each do |file|
			if file.mime_type != "application/vnd.google-apps.folder" then
				list.delete(file)
			end
		end
		# check inside of folder
		list.each do |folder|
			list2=[]
			tmp_path2 = []
			tmp_path2.push({name:folder.name,id:folder.id})
			list(tmp_path2,list2)
			if list2 == [] then 
				@service.delete_file(folder[:id])
				puts "success to remove folder:: "+folder[:id]
			else
				puts "cannot remove folder:: "+folder[:id]
			end
		end
	end
	def rm(fname)
		tmp_list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		list = list_files(fname,tmp_path,tmp_list)
		list.each do |file|
			if file.mime_type != "application/vnd.google-apps.folder" then
				@service.delete_file(file.id)
				puts "success to remove file:: " + file.name + ","+ file.id
			end
		end
		list(@root_path,@current_file_list)
	end

	def send(src,dst)
		# change directory
		tmp_list = []
		tmp_path = []
		tmp_path.push(@root_path.last)
		list = list_files(dst,tmp_path,tmp_list)
		if list == [] then
			target = dst.split("/").last
		elsif list.length ==1 and list[0].mime_type == "application/vnd.google-apps.folder" then
			directory(list[0].name,tmp_path,tmp_list)
			target = src.split("/").last
		else
			puts "cannot send file"
		end

		# check last path is directory or filename
		parents = []
		parents.push(tmp_path.last[:id])
		file_metadata = Google::Apis::DriveV3::File.new(
			name: target,
			mine_type: 'application/vnd.google-apps.unknown',
			parents: parents,
			)
		@service.create_file(file_metadata, upload_source: src, fields: 'id')
		msg = "success to send file:: "
		tmp_path.each do |folder|
			if folder[:name] == "root" then
				msg = msg +"~/"
			elsif folder[:name] == "shared" then 
				msg = msg + "$/"
			else
				msg = msg + folder[:name] +"/"
			end
		end
		msg += target
		puts msg
	end
	def pwd()
		path = ""
		@root_path.each do |folder|
			if folder[:name] == "root" then
				path = "~"
			elsif folder[:name] == "shared"
				path = "$"
			else
				path = path + "/" + folder[:name]
			end
		end
		puts path
	end
	def help
		puts "EasyGoogleDrive help"
		puts ""
		puts "EasyGoogleDrive::File.cd(""directory"")"
		puts "EasyGoogleDrive::File.cd(""~"")"
		puts "  move to root folder"
		puts "EasyGoogleDrive::File.cd(""$"")"
		puts "  move to shared folder"
		puts "EasyGoogleDrive::File.cd("".."")"
		puts "  move to upper folder"
		puts ""
		puts "EasyGoogleDrive::File.ls()"
		puts "  list file and folder in current folder"
		puts ""

		puts "EasyGoogleDrive::File.get(""src"",""dst"")"
		puts "   copy src file in google drive to dst in local file"
		puts "   src: source file name in gllgle drive"
		puts "   dst: destination file name in local file"

		puts ""
		puts "EasyGoogleDrive::File.send(""src"",""dst"")"
		puts "   copy src file in local drive to dst in google drive"
		puts "   src: source file name in local drive"
		puts "   dst: destination file name in google file"

		puts ""
	end
end
