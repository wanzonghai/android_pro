# -*- coding: UTF-8 -*-
import os, stat
import shutil
import random
import string

ORI_PATH = os.getcwd()
TARGET_PATH = os.path.abspath(os.path.dirname(os.getcwd()))
ANDROID_PATH = '\\frameworks\\runtime-src\\proj.android_brazil\\'

#adjust sdk(打开 'true' 关闭 'false')
ADJUST_SWITCH = 'true'

#appsflyer(af) sdk(打开 'true' 关闭 'false')
AF_SWITCH = 'false'

#firebase sdk(打开 'true' 关闭 'false') 打开firebase时，需要拷贝一个icon到res/drawable/ic_launcher.png(144*144)
FIREBASE_SWITCH = 'true'

def del_dir(path):
    print 'del_dir_path:' + path
    #删除文件夹或文件
    shutil.rmtree(path,True)
    
def copy_dir(oriPath,target):
    # oriPath 源目录
    # target 目标目录
    #print "begin copy!!!"
    #print "oriPath:" + oriPath
    #print "target:" + target
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
     
          
three_switch = "{"
def three_sdk_switch_update(name, switch):
    global three_switch
    if three_switch == "{":
        print ('')
    else:
        three_switch += ", "
    three_switch += '"'
    three_switch += name
    three_switch += '"'
    three_switch += ":"
    three_switch += switch
    
def three_sdk_switch_update_file():
    global three_switch
    three_switch += "}"
        
    targetPath = TARGET_PATH + '\\clientBrazil\\base\\threeSdkSwitch.json'
    print "targetPath" + targetPath
    file = open(targetPath, 'w')
    file.truncate(0)
    
    print ('three_switch:') + three_switch
    file.write(three_switch)
    file.close()
        
def three_sdk_copy_files(name, switch):
    three_sdk_switch_update(name, switch)
    three_sdk_copy_contents(name, switch)
    srcPath = TARGET_PATH + ANDROID_PATH + 'app\\src\\'
    srcPath1 = srcPath + 'truco\\three\\'
    if switch == 'true':
        oriPath = ORI_PATH + '\\ThreeSDKFiles\\' + name
        copy_dir(oriPath, srcPath)
    else:
        delPath = srcPath1 + name
        del_dir(delPath)
        if name == 'firebasesdk':
            #firebase重置google-services.json文件
            jsonPath = TARGET_PATH + ANDROID_PATH + 'app\\google-services.json'
            file = open(jsonPath, 'w')
            file.truncate(0)
            
            file.write('{}')
            file.close()
            
        
def three_sdk_reset_gradle():
    targetBuildFilePath = TARGET_PATH + ANDROID_PATH + 'app\\build.gradle'
    targetProjectFilePath = TARGET_PATH + ANDROID_PATH + "build.gradle"
    #重置app/build.gradle文件
    file = open(targetBuildFilePath, 'r')
    content = file.read()
    file.close()
    #print('content:' + content)
        
    fileContent = content.split('//split_line_start')
    file = open(targetBuildFilePath, 'w')
    file.truncate(0)
    #print('fileContent:' + fileContent[0])
    file.write(fileContent[0])
    file.write('//split_line_start')
    file.close()
        
    #重置proj.android-studio/build.gradle文件
    file = open(targetProjectFilePath, 'r')
    content = file.read()
    file.close()
        
    fileContent = content.split('//split_line_start')
    file = open(targetProjectFilePath, 'w')
    file.truncate(0)
    #print('fileContent:' + fileContent[0])
        
    file.write(fileContent[0])
    file.write('//split_line_start')
    file.close()
        
def three_sdk_copy_contents(name, switch):
    buildFilePath = ORI_PATH + '\\ThreeSDKFiles\\' + name + '.gradle'
    targetBuildFilePath = TARGET_PATH + ANDROID_PATH + 'app\\build.gradle'
    projectFilePath = ORI_PATH + '\\ThreeSDKFiles\\project_' + name + '.gradle'
    targetProjectFilePath = TARGET_PATH + ANDROID_PATH + "build.gradle"
    if switch == 'true':
        if os.path.exists(buildFilePath):
            print ('three_sdk_copy_contents buildFilePath:') + buildFilePath
            
            #拷贝app/build.gradle
            file = open(buildFilePath, 'r')
            content = file.read()
            file.close()
        
            #写入
            file = open(targetBuildFilePath, 'a')
            file.write(content)
            file.close()
        if os.path.exists(projectFilePath):
            print ('three_sdk_copy_contents projectFilePath:') + projectFilePath
            
            #拷贝proj.android-studio/build.gradle
            file = open(projectFilePath,'r')
            content = file.read()
            file.close()
        
            #写入
            file = open(targetProjectFilePath, 'a')
            file.write(content)
            file.close()

def three_sdk_action():
    #第三方sdk打包相关
    three_sdk_reset_gradle()
    three_sdk_copy_files('adjustsdk', ADJUST_SWITCH)
    three_sdk_copy_files('afsdk', AF_SWITCH)
    three_sdk_copy_files('firebasesdk', FIREBASE_SWITCH)
    three_sdk_switch_update_file()

# #随机往AndroidManifest中添加组件
# def updateXmlContent():
#     read_xmlPath = ORI_PATH + "\\AndroidManifest.xml"
#     tree = read_xml(read_xmlPath)
#     #找到父节点
#     nodes = find_nodes(tree, "application")
#     ET.register_namespace('android','http://schemas.android.com/apk/res/android')
#     createXmlNodes(nodes, "Activity")
#     createXmlNodes(nodes, "Receiver")
#     createXmlNodes(nodes, "Service")

#     write_xmlPath = TARGET_PATH + ANDROID_PATH + "app\\AndroidManifest.xml"
#     write_xml(tree, write_xmlPath)


if __name__ == '__main__':
    #第三方SDK打包
    three_sdk_action()
