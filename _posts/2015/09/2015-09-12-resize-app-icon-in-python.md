---
layout: post
title: "[Python]파이썬을 이용하여 앱 아이콘을 리사이즈 하기"
description: ""
category: "python"
tags: [python, pip, pillow, ios, icon, image, resize, script]
---
{% include JB/setup %}

앱 개발하면서 앱 아이콘의 디자인이 바뀔 때마다 툴을 이용해서 리사이즈를 하곤 했습니다. 하지만 자주 있는 일이 아니다 보니 툴을 다시 찾아 사용하곤 했는데 상당히 귀찮았습니다. 

Python을 이용하여 앱 아이콘을 리사이즈를 하고, Contents.json 파일을 생성하여 모든 파일을 덮어씌우면 교체되도록 작업해보았습니다. 

파이썬 언어를 배우면서 만들었기 때문에 최적화나 언어를 잘못 사용할 수 있으므로 참고하시길 바랍니다.

### 사용 방법

* Python3을 기본 사용을 전제합니다.
* Pillow 라이브러리를 사용하였습니다.

pip를 통해 Pillow를 설치합니다.
	
	pip install pillow

다음 명령을 통해 실행합니다.

	python3 resize.py [이미지 파일 이름]

	python3 resize.py a.png b.png c.png

### 코드

다음은 리사이즈를 수행하는 코드입니다.

	#!/usr/bin/env python3
	# vim:set sw=4 et smarttab:

	from PIL import Image
	import os, sys, json

	iPhoneIconList = [ 
	{'size':(40,40), 'name':'Icon-40', 'scale':1, 'idiom':['ipad']}
	,{'size':(80,80), 'name':'Icon-40@2x', 'scale':2, 'idiom':['iphone', 'ipad']}
	,{'size':(120,120), 'name':'Icon-40@3x', 'scale':3, 'idiom':['iphone']}
	,{'size':(120,120), 'name':'Icon-60@2x', 'scale':2, 'idiom':['iphone']}
	,{'size':(180,180), 'name':'Icon-60@3x', 'scale':3, 'idiom':['iphone']}
	,{'size':(76,76), 'name':'Icon-76', 'scale':1, 'idiom':['ipad']}
	,{'size':(152,152), 'name':'Icon-76@2x', 'scale':2, 'idiom':['ipad']}
	,{'size':(72,72), 'name':'Icon-72', 'scale':1, 'idiom':['ipad']}
	,{'size':(144,144), 'name':'Icon-72@2x', 'scale':2, 'idiom':['ipad']}
	,{'size':(50,50), 'name':'Icon-Small-50', 'scale':1, 'idiom':['ipad']}
	,{'size':(100,100), 'name':'Icon-Small-50@2x', 'scale':2, 'idiom':['ipad']}
	,{'size':(29,29), 'name':'Icon-Small', 'scale':1, 'idiom':['iphone', 'ipad']}
	,{'size':(58,58), 'name':'Icon-Small@2x', 'scale':2, 'idiom':['iphone', 'ipad']}
	,{'size':(57,57), 'name':'Icon', 'scale':1, 'idiom':['iphone']}
	,{'size':(114,114), 'name':'Icon@2x', 'scale':2, 'idiom':['iphone']}
	# {'size':(512,512), 'name':'iTunesArtwork', 'scale':1},
	# {'size':(1024,1024), 'name':'iTunesArtwork@2x', 'scale':2}
	]

	watchIconList = [
	{'size':(48,48), 'name':'Icon-24@2x', 'scale':2, 'idiom':['watch'], 'role':'notificationCenter', 'subtype':'38mm'}
	,{'size':(55,55), 'name':'Icon-27.5@2x', 'scale':2, 'idiom':['watch'], 'role':'notificationCenter', 'subtype':'42mm'}
	,{'size':(58,58), 'name':'Icon-29@2x', 'scale':2, 'idiom':['watch'], 'role':'companionSettings'}
	,{'size':(87,87), 'name':'Icon-29@3x', 'scale':3, 'idiom':['watch'], 'role':'companionSettings'}
	,{'size':(80,80), 'name':'Icon-40@2x', 'scale':2, 'idiom':['watch'], 'role':'appLauncher', 'subtype':'38mm'}
	,{'size':(88,88), 'name':'Icon-44@2x', 'scale':2, 'idiom':['watch'], 'role':'longLook', 'subtype':'42mm'}
	,{'size':(172,172), 'name':'Icon-86@2x', 'scale':2, 'idiom':['watch'], 'role':'quickLook', 'subtype':'38mm'}
	,{'size':(196,196), 'name':'Icon-98@2x', 'scale':2, 'idiom':['watch'], 'role':'quickLook', 'subtype':'42mm'}
	]

	def saveImage(newImage, size, newPath):
		newImage.thumbnail(size, Image.ANTIALIAS)
		newImage.save(newPath, 'PNG')

	def saveContentsJson(jsonData, newPath):
		with open(newPath, 'w') as outfile:
		    json.dump(jsonData, outfile)

	def makeIphoneIconContentJson(contentsJson, item):
		if not "images" in contentsJson:
			contentsJson["images"] = []
		if not "info" in contentsJson:
			contentsJson["info"] = {"version":1, "author":"xcode"}
		width = str(int(item['size'][0]/item['scale']))
		imageData = {}
		imageData["size"] = width + 'x' + width
		imageData["filename"] = item['name'] + ".png"
		imageData["scale"] = str(item['scale']) + 'x'
		for idiom in item["idiom"]:
			imageData["idiom"] = idiom
			contentsJson["images"].append(imageData.copy())
		return contentsJson

	def makeAppleWatchIconContentJson(contentsJson, item):
		if not "images" in contentsJson:
			contentsJson["images"] = []
		if not "info" in contentsJson:
			contentsJson["info"] = {"version":1, "author":"xcode"}

		imageData = {}
		size = item['size'][0] / item['scale']
		if size % int(size) == 0:
			imageData["size"] = str(int(size)) + 'x' + str(int(size))
		else:
			imageData["size"] = str(size) + 'x' + str(size)
		imageData["filename"] = item['name'] + ".png"
		imageData["scale"] = str(item['scale']) + 'x'
		imageData["role"] = item["role"]
		if "subtype" in item:
			imageData["subtype"] = item["subtype"]
		for idiom in item["idiom"]:
			imageData["idiom"] = idiom
			contentsJson["images"].append(imageData.copy())
		return contentsJson

	def resizeImageiPhone(dir, im, contentsJson):
		for item in iPhoneIconList:
			#import ipdb;ipdb.set_trace()
			saveImage(im.copy(), item['size'], os.path.join(dir, item['name'] + ".png"))
			makeIphoneIconContentJson(contentsJson, item)
		# saveContentsJson(contentsJson, os.path.join(dir, 'Contents.json'))

	def resizeImageAppleWatch(dir, im, contentsJson):
		for item in watchIconList:
			saveImage(im.copy(), item['size'], os.path.join(dir, item['name'] + ".png"))
			makeAppleWatchIconContentJson(contentsJson, item)
		# saveContentsJson(contentsJson, os.path.join(dir, 'Contents.json'))

	def makefolder(fName):
		filename = os.path.splitext(fName)
		scriptDir = os.path.dirname(__file__)
		newDir = os.path.join(scriptDir, filename[0])
		iphoneDir = os.path.join(newDir, 'iphone')
		watchDir = os.path.join(newDir, 'watch')
		if not os.path.exists(newDir):
			os.makedirs(newDir)
		if not os.path.exists(iphoneDir):
			os.makedirs(iphoneDir)
		if not os.path.exists(watchDir):
			os.makedirs(watchDir)
		return (iphoneDir, watchDir)

	def main(argv):
		for fileName in argv:
			try:
				contentsJson = {}
				im = Image.open(fileName)
				dir = makefolder(fileName)
				resizeImageiPhone(dir[0], im, contentsJson)
				resizeImageAppleWatch(dir[1], im, contentsJson)
				saveContentsJson(contentsJson, os.path.join(dir[0], 'Contents.json'))
			except IOError:
				print ("This file is not exist")

	if __name__ == '__main__':
		if len (sys.argv) == 1:
			print ("You don`t input filename")
			sys.exit()
		main(sys.argv[1:])