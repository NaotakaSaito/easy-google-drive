require 'easy-google-drive'
myDrive = EasyGoogleDrive::Drive.new

myDrive.cd("~")
myDrive.ls()
myDrive.cd("$")
myDrive.ls()
myDrive.cd("~")
myDrive.send("sample_drive.rb","~/sample_drive.rb")
myDrive.get("~/gdrive.dat","./gdrive.dat")
myDrive.ls()
myDrive.rm("sample_drive.rb")
myDrive.ls()
