require_relative '../lib/easy-google-drive'
myDrive = EasyGoogleDrive::Drive.new

myDrive.cd("~")
myDrive.ls()
myDrive.cd("$")
myDrive.ls()
myDrive.get("~/gdrive.dat","./gdrive.dat")
myDrive.cd("~")
myDrive.send("sample_drive.rb","sample_drive.rb")
myDrive.ls()
myDrive.rm("sample_drive.rb")
myDrive.ls()

