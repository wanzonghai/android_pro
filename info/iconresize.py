#!/usr/bin/env python
#coding=utf-8

'''
sudo pip install Pillow

使用方法：同级目录放一个 icon.png     (512x512) 或者 (1024x1024)
'''

import sys
import os
import shutil

def warn(msg):
  print('\x1b[0;31;40m' + msg + '\x1b[0m')

import imp
try:
    imp.find_module('PIL')
    from PIL import Image
except ImportError:
    warn('运行\nsudo pip install Pillow\n安装 PIL 模块')
    exit (0)

#自动生成android,ios 需要的图标
#python icon.py
def generate(iPath, android_dir, ios_dir):
    if not os.path.exists(iPath):
        print('> 文件不存在：', iPath)
        exit (0)
    icon = Image.open(iPath)

    #android
    sizeFolders = [
        ('drawable',512),
        ('drawable-hdpi',72),
        ('drawable-ldpi',36),
        ('drawable-mdpi',48),
        ('drawable-xhdpi',96),
        #('drawable-xxhdpi',144),
        #('drawable-xxxhdpi',192),
    ]
    # names = ['icon','push']
    names = ['icon']

    for s in sizeFolders:
        folder,size = s
        img = icon.resize((size,size),Image.ANTIALIAS)

        oFolder = android_dir+folder
        if not os.path.exists(oFolder):
            os.makedirs(oFolder)
        for name in names:
            oPath = oFolder+'/'+name+'.png'
            img.save(oPath, icon.format)
            print(oPath)

    # ios
	ios_sizeNames = [
	    ('Icon-24@2x',48),
        ('Icon-27.5@2x',55),
        ('Icon-29@2x',58),
        ('Icon-29@3x',87),
        ('Icon-40@2x',80),
        ('Icon-44@2x',88),
        ('Icon-86@2x',172),
        ('Icon-98@2x',196),
		('Icon-57',57),
		('Icon-76',76),
        ('Icon-App-20x20@1x',20),
        ('Icon-App-20x20@2x',40),
        ('Icon-App-20x20@2x-1',40),
        ('Icon-App-20x20@3x',60),
        ('Icon-App-29x29@1x',29),
        ('Icon-App-29x29@2x',58),
        ('Icon-App-29x29@2x-1',58),
        ('Icon-App-29x29@3x',87),
        ('Icon-App-40x40@1x',40),
        ('Icon-App-40x40@2x',80),
        ('Icon-App-40x40@2x-1',80),
        ('Icon-App-40x40@3x',120),
        ('Icon-App-60x60@2x',120),
        ('Icon-App-60x60@3x',180),
        ('Icon-App-76x76@1x',76),
        ('Icon-App-76x76@2x',152),
        ('Icon-App-83.5x83.5@2x',167),
        ('ItunesArtwork@2x',1024),
	]
	
    for s in ios_sizeNames:
        iconName,size = s
        img = icon.resize((size,size),Image.ANTIALIAS)

        oFolder = ios_dir+'Assets.xcassets/AppIcon.appiconset'
        if not os.path.exists(oFolder):
            os.makedirs(oFolder)
      
        oPath = oFolder+'/'+iconName+'.png'
        img.save(oPath, icon.format)
        print(oPath)
			
    sizes = [
        29,
        40,
        48,
        50,
        57,
        58,
		60,
        72,
        76,
        80,
		87,
        #96,
        100,
        114,
        120,
        144,
        152,
		180,
    ]

    if not os.path.exists(ios_dir):
        os.makedirs(ios_dir)
    for size in sizes:
        img = icon.resize((size,size), Image.ANTIALIAS)
        oPath = ios_dir+'Icon-'+str(size)+'.png'
        img.save(oPath, icon.format)
        print(oPath)

if __name__ == '__main__':
    # if len(sys.argv)<2:
    #     path = os.path.split(os.path.realpath(__file__))[0]
    # else:
    #     path = os.path.split(sys.argv[1])[0]
    if len(sys.argv) >= 2:
        if not os.path.splitext(os.path.realpath(sys.argv[1]))[1] == ".png":
            print "please only *.png file supported!"
            exit()
        else:
            path = os.path.split(sys.argv[1])[0]
            iPath = os.path.realpath(sys.argv[1])
            android_dir = os.path.join(path, 'frameworks/runtime-src/proj.android/res/')
            ios_dir = os.path.join(path, 'frameworks/runtime-src/proj.ios_mac/ios/')
            generate(iPath, android_dir, ios_dir)
