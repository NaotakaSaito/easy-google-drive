require_relative './lib/easy-google-drive'
myDrive = EasyGoogleDrive::Drive.new
myDrive.help()

myDrive.cd("~")
myDrive.ls()
myDrive.cd("¥")
myDrive.ls()

myDrive.rmdir("~/test")
myDrive.cd("~/gdrive_test")
myDrive.ls()
myDrive.send("tags","~/gdrive_test")
myDrive.send("lib/easy-google-drive.rb","~/gdrive_test")
myDrive.rm("~/gdrive_test/tags")
myDrive.rm("~/gdrive_test/easy-google-drive.rb")

#myDrive.get("test_data2.ods","test.ods")
#myDrive.rmdir("~/gdrive_test/test")

#myDrive.cd("¥")
#myDrive.cd("~/LazuriteFly")
#myDrive.pwd()
#myDrive.ls()

#myDrive_get("test_data2.ods")
#p "test of mkdir"
#myDrive.mkdir("testtesttesttest")
#myDrive.cd("testtesttesttest")
#myDrive.rm("test_data2.ods")
#myDrive.ls("~")
#myDrive.ls()

#myDrive.ls("~/document/SLR-429")
#myDrive.ls("¥/Lauzrite920j_log")
#myDrive.ls("~/gdrive_test/test_data2.ods")
#myDrive.get("~/gdrive_test/test_data2.ods","lib/test2.ods")

'''
myDrive.cd("..")
myDrive.ls():

myDrive.cd("¥")
myDrive.ls()

myDrive.cd("Lauzrite920j_log")
myDrive.ls()

myDrive.cd("~")
myDrive.ls()


'''
