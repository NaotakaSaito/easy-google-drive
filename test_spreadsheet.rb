require_relative './lib/easy-google-drive'
myDrive = EasyGoogleDrive::Spreadsheet.new
myDrive.help()
myDrive.open("~/gdrive_test/test_ss")
p myDrive.addNewLine("",[100,159,200])
p myDrive.get("","A:E")
#myDrive.close()
#myDrive.rm("~/gdrive_test/test_ss")


