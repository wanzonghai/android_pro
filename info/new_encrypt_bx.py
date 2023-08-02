import sys
import subprocess
import os
import json
import inspect  
import shutil
import traceback
import sys

from ctypes import *

def xorDir(path): 
    newpath = path.replace("\\", "/")
    dirs = os.listdir(newpath)
    for fileName in dirs:
        subPath = os.path.join(newpath,fileName)
        if os.path.isdir(subPath):
              xorDir(subPath)
        elif os.path.isfile(subPath):
            newsubPath = subPath.replace("\\", "/")
            xorFile(newsubPath)


def xorFile(path):
    if path[-4:] ==".png" or path[-4:] == ".jpg" or path[-4:] == ".lua":
        print path
        Objdll=None
        Objdll=cdll.LoadLibrary("libscp_enc_py.dll")
        if not Objdll:
            raise "libscp_enc_py.dll no find"
        dst_lua_file=path
        pStr = c_char_p()
        pStr.value = dst_lua_file
        nRst = Objdll.EncryptScriptFile(pStr)
        if nRst != 0:
            raise "EncryptScriptFile err:"+dst_lua_file


if __name__ == '__main__':
    curPath = os.path.abspath('.')
    parentPath,subName = os.path.split(curPath)
    path = os.path.join(parentPath,"encryptComponent")
    if os.path.isdir(path):
        xorDir(path)
    elif os.path.isfile(path):
        xorFile(path)
                   