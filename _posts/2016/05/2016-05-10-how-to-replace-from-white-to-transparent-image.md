---
layout: post
title: "[Shell][Python][ImageMagick]하얀색을 투명으로 바꾸기"
description: ""
category: "programming"
tags: [ImageMagick, shell, python, PIL, convert]
---
{% include JB/setup %}

이미지를 전달받았을 때, 배경색이 투명으로 바꿔야할 경우가 있습니다. 여러가지 방법이 있지만, 그 중 두 가지 방법을 쓰려고 합니다.

첫번째는 [ImageMagick](http://www.imagemagick.org/)을 이용한 방법입니다.

```shell
	convert input.png -fuzz 10% -transparent white output.png
```

두번째는 Python의 Pillow 라이브러리를 이용한 방법입니다. RGBA 데이터로 얻어 픽셀을 검사하고 알파값을 교체합니다.

```python
	from PIL import Image
	import os, sys
	if __name__ == '__main__':
		img = Image.open(sys.argv[1])
		img = img.convert("RGBA")
		datas = img.getdata()

		newData = []
		for item in datas:
			if item[0] > 200 and item[1] > 200 and item[2] > 200:
				newData.append((item[0], item[1], item[2], 0))
			else:
				newData.append(item)

		img.putdata(newData)
		filename = os.path.splitext(sys.argv[1])
		img.save(filename[0] + "_output" + filename[1], "PNG")
```