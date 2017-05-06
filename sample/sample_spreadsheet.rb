require 'easy-google-drive'
mySheet = EasyGoogleDrive::Spreadsheet.new
mySheet.open("~/sample_spreadsheet")
p mySheet.addNewLine("",[100,150,200])
p mySheet.getData("","A:E")
mySheet.close()


