# -*- coding: UTF-8 -*-
import os
import random
import string

#混淆path
ROOT_PATH = "F:\\BaiduNetdiskDownload\\cocos-creator-mj_hotupdate\\"
#加密密码，DES长度只能是8，AES的长度是16，尽量使用小写字母+数字
ZIP_PWD = "sg43sSttyr5S1ts7"
#加密后的文件名，任意文件名都可以，可以带后缀，如:.so,.mp3,.png,.jpg等，也可不带后缀
ZIP_ENCTYPT_FILENAME = "sgs.png"
#当前是加密原有代码资源(true)?还是打混淆垃圾文件(false)
IS_ENCTYPT_ASSETS = "true"
#用AES或DES加密
ENCTYPT_TYPE = "AES";

#批量加密垃圾文件存放地址，一般是对assets下的文件进行加密作为垃圾文件
OTHER_FILES_ENCRYPT_PATH = ROOT_PATH + "kenbuild\\jsb-link\\other\\"

#加密的文件地址
#ZIP_PATH = ROOT_PATH + "kenbuild\\jsb-link\\jsb-link.zip"
#加密后文件存放地址
#ENCRYPT_FILE_PATH = (ROOT_PATH + "kenbuild\\jsb-link\\" + ZIP_ENCTYPT_FILENAME)

ZIP_PATH = "./game-release.apk"
ENCRYPT_FILE_PATH = "./sgs.mp3"

def del_dir(srcPath):
    src_dir = os.listdir(srcPath)
    for file in src_dir:
        filePath = srcPath + file
        if os.path.exists(filePath):
            if not (os.path.isdir(filePath)):
                os.remove(filePath)
            else:
                for fileList in os.walk(filePath):
                    for name in fileList[2]:
                        os.chmod(os.path.join(fileList[0],name), stat.S_IWRITE)
                        os.remove(os.path.join(fileList[0],name))
                shutil.rmtree(filePath)
        else:
            print ("no filepath")


def all_files_path(rootDir): 
    global filepaths                      
    for root, dirs, files in os.walk(rootDir):
        for file in files:
            file_path = os.path.join(root, file)
            filepaths.append(file_path)
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            all_files_path(dir_path)

def compileJava():
    if ENCTYPT_TYPE == "AES":
        cmd = ('javac EncryptTools_AES.java')
        os.system(cmd)
        cmd = ('java EncryptTools_AES' + " " + ZIP_PWD + " " + ZIP_PATH + " " + ENCRYPT_FILE_PATH)
        os.system(cmd)
    else:
        cmd = ('javac EncryptTools.java')
        os.system(cmd)
        cmd = ('java EncryptTools' + " " + ZIP_PWD + " " + ZIP_PATH + " " + ENCRYPT_FILE_PATH)
        os.system(cmd)

def compileJavaWithParameter(password, oriPath, dirPath, content):
    if ENCTYPT_TYPE == "AES":
        cmd = ('javac EncryptTools_AES.java')
        os.system(cmd)
        cmd = ('java EncryptTools_AES' + ' ' + password + " " + oriPath + " " + dirPath + " " + content)
        os.system(cmd)
    else:
        cmd = ('javac EncryptTools.java')
        os.system(cmd)
        cmd = ('java EncryptTools' + ' ' + password + " " + oriPath + " " + dirPath + " " + content)
        os.system(cmd)

filepaths = []
def complieJavaLoop():
    if(os.path.exists(OTHER_FILES_ENCRYPT_PATH)):
        del_dir(OTHER_FILES_ENCRYPT_PATH)
    else:
        os.makedirs(OTHER_FILES_ENCRYPT_PATH)
    global filepaths
    all_files_path(ROOT_PATH + "assets")
    cryptFileCount = 0
    lenf = random.randint(12, 25)
    suffixList = ['', '.mp3', '.png', '.js', '.lua', '.jpg', '.so']
    for path in filepaths:
        cryptFileCount = cryptFileCount + 1;
        if(cryptFileCount > lenf):
            break;
        fileName = ""
        lenj = random.randint(5, 10)
        for j in range(lenj):
            fileName += random.choice(string.ascii_letters)
        pwd = ""
        lenk = 8
        if ENCTYPT_TYPE == "AES":
            lenk = 16
        for k in range(lenk):
            pwd += random.choice(string.ascii_letters)
        content = ""
        lenl = random.randint(50, 300)
        for l in range(lenl):
            content += random.choice(string.ascii_letters)
        suffix = suffixList[random.randint(0, len(suffixList)-1)]
        compileJavaWithParameter(pwd, path, (OTHER_FILES_ENCRYPT_PATH + fileName + suffix), content)

if __name__ == '__main__':
    if IS_ENCTYPT_ASSETS == "true":
        compileJava()
    else:
        complieJavaLoop()


