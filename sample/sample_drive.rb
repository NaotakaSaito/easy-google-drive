require 'easy-google-drive'
myDrive = EasyGoogleDrive::Drive.new

myDrive.cd("~")
myDrive.ls()
myDrive.cd("$")
myDrive.ls()
myDrive.get("~/gdrive.dat","./gdrive.dat")
myDrive.send("sample_drive.rb","~/sampe_drive.rb")

