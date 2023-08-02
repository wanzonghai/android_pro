# -*- coding: UTF-8 -*-
import shutil
import os
import random
import string
import zipfile

CUR_PATH = os.getcwd()
UP_PATH = os.path.abspath(os.path.dirname(os.getcwd()))
JAVAC_PATH = CUR_PATH + "/javac_class/"
ANDROIDJAR_PATH = CUR_PATH + "/android.jar"


#-----------------需要修改配置的部分start-----------------------

#dx.bat路径
DEXJAR_PATH = "D:/AppData/Local/Android/Sdk/build-tools/30.0.3"
#加密密码，DES长度只能是8，AES的长度是16，使用小写字母+数字
ENCRYPT_PWD = "sg43sSttyr5S1ts7"
#class.jar加密后的文件名
ENCRYPT_FILE_NAME = "sgs.png"
#插件apk的application名
PLUGIN_APPLICATION_NAME = "org.cocos2dx.lua.sgsGameApplication"
#插件apk加密后的文件名
ENCRYPT_APK_NAME = "sgs.mp3"
#代码包名，比如之前是temp_class，会自动替换成需要替换的包名并进行编译
PACKAGENAME = "sgs"
#类名及函数名，动态替换，以达到重构目的
CLASSNAME = "base"
APPLICATION_CREATE = "sgs1"
APPLICATION_ATTACHBASE = "sgs2"
ACTIVITY_ATTACHBASE = "sgs3"
ACTIVITY_CREATE = "szgame_poei_qjkejsio"

#-----------------需要修改配置的部分end-----------------------

#随机生成java文件内容
def get_java_content(packageName, fileName):
    javaContent = "package " + packageName +";"
    javaContent += "\n"
    javaContent += "public class " + fileName + " {"
    javaContent += "\n"

    #随机生成变量
    #javaContent += "private int test = 0;\n private int testB = 1;"
    spaceTypes = ["public", "private", "protected"]
    variableTypes = ["int", "String"]
    leni = random.randint(3, 10)
    for i in range(leni):
        spaceTypeI = random.randint(0, len(spaceTypes)-1)
        variableTypeI = random.randint(0, len(variableTypes)-1)
        variableStr = "    "
        variableStr += (spaceTypes[spaceTypeI] + " ")
        variableStr += (variableTypes[variableTypeI] + " ")
        variableName = ""
        lenk = random.randint(5, 10)
        for k in range(lenk):
            variableName += random.choice(string.ascii_letters)
        variableStr += (variableName + " = ")
        if variableTypes[variableTypeI] == "int":
           variableStr += str(random.randint(1, 10000))
        if variableTypes[variableTypeI] == "String":
            lenj = random.randint(5, 50)
            strContent = '"'
            for j in range(lenj):
                strContent += random.choice(string.ascii_letters)
            strContent += '"'
            variableStr += strContent
        variableStr += ";"
        variableStr += "\n"
        javaContent += variableStr
    javaContent += "\n"

    #随机生成方法
    #javaContent += "private int dqgguaol() {   return 5650;    }"
    lenMethodCount = random.randint(8, 20)
    for mc in range(lenMethodCount):
        methodReturnTypes = ["void", "int", "String", "Boolean"]
        methodReturnTypeI = random.randint(0, len(methodReturnTypes)-1)
        methodStr = "    "
        methodStr += (spaceTypes[spaceTypeI] + " ")
        methodStr += (methodReturnTypes[methodReturnTypeI] + " ")
        methodName = ""
        lenMN = random.randint(4, 10)
        for mn in range(lenMN):
            methodName += random.choice(string.ascii_letters)
        methodName = methodName.lower()
        methodStr += methodName
        methodStr += "() {"
        methodStr += "   "
        if methodReturnTypes[methodReturnTypeI] == "int":
            methodStr += "return "
            methodStr += str(random.randint(0, 9999))
        if methodReturnTypes[methodReturnTypeI] == "String":
            methodStr += "return "
            methodStrI = random.randint(5, 50)
            mstrContent = '"'
            for strI in range(methodStrI):
                mstrContent += random.choice(string.ascii_letters)
            mstrContent += '"'
            methodStr += mstrContent
        if methodReturnTypes[methodReturnTypeI] == "Boolean":
            methodStr += "return "
            boolI = random.randint(0, 1)
            if boolI == 0:
                methodStr += "true"
            else:
                methodStr += "false"
        methodStr += ";"
        methodStr += "    }"
        javaContent += methodStr
        javaContent += "\n"

    javaContent += "\n}"
    return javaContent

#随机创建文件及往文件中随机填入内容
def random_java_file():
    global create_java_files_path
    global java_packkge_name
    #随机创建15-50个文件，文件名首字每大写，文件名长度为5-10个字符
    leni = random.randint(15, 50)
    for i in range(leni):
        fileName = ""
        lenj = random.randint(5, 10)
        for j in range(lenj):
            fileName += random.choice(string.ascii_letters)
        fileName = fileName.lower().capitalize()
        rootDir = JAVAC_PATH + PACKAGENAME + "/" + fileName + ".java"
        #print(rootDir)
        f = open(rootDir,'w+')
        fileContent = get_java_content(PACKAGENAME, fileName)
        #print fileContent
        f.write(fileContent)
        f.seek(0)
        read = f.readline()
        f.close()

def deleteJavacDir(delete_path):
    if not os.path.exists(delete_path):
        return
    src_dir = os.listdir(delete_path)
    for file in src_dir:
        filePath = delete_path + file
        if os.path.exists(filePath):
            if not (os.path.isdir(filePath)):
                os.remove(filePath)
            else:
                shutil.rmtree(filePath)
        else:
            print ("no filepath")

def copyJavaFiles():
    #创建javac_class
    if not os.path.exists(JAVAC_PATH):  #创建java_class文件夹
        os.makedirs(JAVAC_PATH)
    packagepath = JAVAC_PATH + PACKAGENAME
    if not os.path.exists(packagepath):  #创建package文件夹
        os.makedirs(packagepath)  
    binPath = packagepath + "/bin"
    if not os.path.exists(binPath): #创建bin文件夹，存在编译后的文件
        os.makedirs(binPath)
    copy_files(CUR_PATH+"/temp_class", packagepath) #将模板中的java文件拷贝至这个文件夹下
    #随机生成java文件
    random_java_file()
    #编译java文件
    cmd = ('javac -encoding utf-8 -target 1.8 -bootclasspath ' + ANDROIDJAR_PATH + ' -d ' + binPath + ' ' + packagepath + '\*.java')
    os.system(cmd) 
    #将编译后的class文件压缩成一个jar包
    classjarpath = (JAVAC_PATH + "class.jar")
    outjarpath = (JAVAC_PATH + 'out.jar')
    zipDir(binPath, classjarpath)
    #将编译后的class.jar包进行dex格式化
    print "========1:",DEXJAR_PATH
    cmd = (DEXJAR_PATH + '/dx.bat --dex --output=' + outjarpath + " " + classjarpath)
    os.system(cmd) 
    print "========1"
    #对格式化后的out.jar进行加密
    cmd = ('javac ' + UP_PATH + '\\EncryptTools_AES.java')
    os.system(cmd)
    #将EncryptTools_AES.class拷贝至当前目录下，试过直接使用原始目录，会编译失败
    shutil.copy(UP_PATH+"\\EncryptTools_AES.class", CUR_PATH + "\\EncryptTools_AES.class")
    encryptjarpath = JAVAC_PATH + ENCRYPT_FILE_NAME
    #开始加密
    cmd = ('java EncryptTools_AES' + ' ' + ENCRYPT_PWD + " " + outjarpath + " " + encryptjarpath)
    print "========5"
    os.system(cmd)
    
def zipDir(dirpath,outFullName):
    zip = zipfile.ZipFile(outFullName,"w",zipfile.ZIP_DEFLATED)
    for path,dirnames,filenames in os.walk(dirpath):
        # 去掉目标跟路径，只对目标文件夹下边的文件及文件夹进行压缩
        fpath = path.replace(dirpath,'')
        for filename in filenames:
            zip.write(os.path.join(path,filename),os.path.join(fpath,filename))
    zip.close()

def replace_content(file,old_str,new_str):
    file_data = ""
    with open(file, "r") as f:
        for line in f:
            if old_str in line:
                line = line.replace(old_str,new_str)
            file_data += line
    with open(file,"w") as f:
        f.write(file_data)

def copy_files(oriPath,target):
    if not (os.path.isdir(oriPath) and os.path.isdir(target)):
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
            if(f == "PluginHelper.java"):
                f = (CLASSNAME + ".java")
            arr_path = os.path.join(a[0].replace(oriPath,target),f)
            shutil.copy(dep_path,arr_path)
            replace_content(arr_path, "temp_class", PACKAGENAME)
            if(f == (CLASSNAME + ".java")):
                replace_content(arr_path, "PluginHelper", CLASSNAME)
                replace_content(arr_path, "application_oncreate", APPLICATION_CREATE)
                replace_content(arr_path, "application_attachbasecontext", APPLICATION_ATTACHBASE)
                replace_content(arr_path, "activity_attachbasecontext", ACTIVITY_ATTACHBASE)
            if(f == "Config.java"):
                replace_content(arr_path, "temp_plugin_application_name", PLUGIN_APPLICATION_NAME)
                replace_content(arr_path, "temp_plugin_apk_name", ENCRYPT_APK_NAME)
            if(f == "Utils.java"):
                replace_content(arr_path, "temp_encrypt_password", ENCRYPT_PWD)


if __name__ == '__main__':
    deleteJavacDir(JAVAC_PATH)
    copyJavaFiles()


