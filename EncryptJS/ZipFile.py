# -*- coding: UTF-8 -*-
import os, stat
import shutil
import random
import string
import zipfile

KENBUILD_PATH = os.path.abspath(os.path.dirname(os.getcwd()))

def zipDir(dirpath,outFullName):
    zip = zipfile.ZipFile(outFullName,"w",zipfile.ZIP_DEFLATED)
    for path,dirnames,filenames in os.walk(dirpath):
        # 去掉目标跟路径，只对目标文件夹下边的文件及文件夹进行压缩
        fpath = path.replace(dirpath,'')
        for filename in filenames:
            zip.write(os.path.join(path,filename),os.path.join(fpath,filename))
    zip.close()

def copy_dir(oriPath,target):
    # oriPath 源目录
    # target 目标目录
    #print "begin copy!!!"
    #print "oriPath:" + oriPath
    #print "target:" + target
    if not os.path.isdir(target):
        os.makedirs(target)
    if not (os.path.isdir(oriPath) and os.path.isdir(target)):
        # 如果传进来的不是目录
        print("path is not dir")
        return

    for a in os.walk(oriPath):
        #递归创建目录
        for d in a[1]:
            dir_path = os.path.join(a[0].replace(oriPath,target),d)
            if not os.path.isdir(dir_path):
                os.makedirs(dir_path)
        #递归拷贝文件
        for f in a[2]:
            dep_path = os.path.join(a[0],f)
            arr_path = os.path.join(a[0].replace(oriPath,target),f)
            shutil.copy(dep_path,arr_path)

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
            print "no filepath"

def createZipDir():
    #先删除之前的assets
    jsbPath = KENBUILD_PATH + "\\jsb-link\\"
    if(os.path.exists(jsbPath + 'assets.zip')):
       os.remove(jsbPath + 'assets.zip')
    if(os.path.exists(jsbPath + 'assets')):
        del_dir(jsbPath + 'assets\\')
    else:
        os.makedirs(jsbPath + 'assets')
    copy_dir(jsbPath + 'res',jsbPath + 'assets\\res')
    copy_dir(jsbPath + 'src',jsbPath + 'assets\\src')
    copy_dir(jsbPath + 'script',jsbPath + 'assets\\script')
    shutil.copy(jsbPath + 'main.js',jsbPath + 'assets')
    shutil.copy(jsbPath + 'project.json',jsbPath + 'assets')

def compileJavaWithParameter(password, oriPath, dirPath, isWriteContent):
    cmd = ('javac EncryptTools.java')
    os.system(cmd)
    cmd = ('java EncryptTools' + ' ' + password + " " + oriPath + " " + dirPath + " " + isWriteContent)
    os.system(cmd)

def cryptAssets():
    jsbPath = KENBUILD_PATH + "\\jsb-link\\"
    if(os.path.exists(jsbPath + 'crypt')):
        del_dir(jsbPath + 'crypt\\')
    else:
        os.makedirs(jsbPath + 'crypt')
    pwd = ""
    lenk = 8
    for k in range(lenk):
        pwd += random.choice(string.ascii_letters)
    fileName = ""
    lenj = random.randint(4, 10)
    for j in range(lenj):
        fileName += random.choice(string.ascii_letters)
    file = open(jsbPath + "crypt\\" + pwd + ".pwd", 'w')
    file.close()
    compileJavaWithParameter(pwd, jsbPath + "assets.zip", jsbPath + "crypt\\" + fileName, "false")

def get_all_files_path(rootDir): 
    global filepaths                      
    for root, dirs, files in os.walk(rootDir):
        for file in files:
            file_path = os.path.join(root, file)
            filepaths.append(file_path)
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            get_all_files_path(dir_path)

filepaths = []
def cryptAssetsOthers():
    jsbPath = KENBUILD_PATH + "\\jsb-link\\"
    if(os.path.exists(jsbPath + 'crypt\\others')):
        del_dir(jsbPath + 'crypt\\others')
    else:
        os.makedirs(jsbPath + 'crypt\\others')
    global filepaths
    get_all_files_path(os.path.abspath(os.path.dirname(KENBUILD_PATH)) + "\\assets")
    suffixList = ['', '.mp3', '.png', '.js', '.lua', '.jpg', '.so']
    cryptFileCount = 0
    lenf = random.randint(8, 25)
    for path in filepaths:
        cryptFileCount = cryptFileCount + 1;
        if(cryptFileCount > lenf):
            break;
        fileName = ""
        lenj = random.randint(3, 15)
        for j in range(lenj):
            fileName += random.choice(string.ascii_letters)
        pwd = ""
        lenk = 8
        for k in range(lenk):
            pwd += random.choice(string.ascii_letters)
        suffix = suffixList[random.randint(0, len(suffixList)-1)]
        content = ""
        lenk = random.randint(50, 300)
        for k in range(lenk):
            content += random.choice(string.ascii_letters)
        compileJavaWithParameter(pwd, path, jsbPath + 'crypt\\others\\' + fileName + suffix, content)

if __name__ == '__main__':
    #先将需要压缩的文件拷贝到同一个assets
    createZipDir()
    #将js端的代码和资源打成一个压缩包
    zipDir(KENBUILD_PATH + "\\jsb-link\\assets", KENBUILD_PATH + "\\jsb-link\\assets.zip")
    #对压缩包进行加密
    cryptAssets()
    #对assets下的文件进行加密，可打包到assets下，达到混淆目的
    cryptAssetsOthers()