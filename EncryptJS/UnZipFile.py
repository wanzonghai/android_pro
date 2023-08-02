# -*- coding: UTF-8 -*-
import os, stat
import shutil
import random
import string
import zipfile

ROOT_PATH = os.getcwd()

def unzip():
    global zip_file
    zip_file = zipfile.ZipFile(ROOT_PATH + "\\RoyalRummy-3525-2.1.9.apk", 'r')
    yourpath = ROOT_PATH + "\\royalapk"
    try:
        zip_file.extractall(path=yourpath)
    except Exception as e:
        Logger(sys.exc_info()[2]).error(e)
    finally:
        zip_file.close

if __name__ == '__main__':
    unzip()