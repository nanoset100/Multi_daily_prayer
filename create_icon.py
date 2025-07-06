from PIL import Image, ImageDraw
import os

# assets 폴더가 없으면 생성
if not os.path.exists('assets'):
    os.makedirs('assets')

# 1024x1024 캔버스 생성 (베이지색 배경)
img = Image.new('RGBA', (1024, 1024), (240, 230, 210, 255))
draw = ImageDraw.Draw(img)

# 금색 비둘기 그리기
golden = (218, 165, 32, 255)

# 비둘기 몸통 (큰 타원)
draw.ellipse([200, 300, 600, 600], fill=golden)

# 날개 (위쪽)
draw.ellipse([150, 250, 450, 450], fill=golden)

# 머리 (원형)
draw.ellipse([500, 200, 700, 400], fill=golden)

# 눈 (흰색)
draw.ellipse([580, 260, 620, 300], fill=(255, 255, 255, 255))

# 부리 (삼각형)
draw.polygon([(680, 280), (720, 290), (680, 300)], fill=golden)

# 꼬리 깃털들 (3개)
for i in range(3):
    y_offset = i * 40
    draw.ellipse([50, 350 + y_offset, 250, 400 + y_offset], fill=golden)

# 날개 깃털 라인들
for i in range(4):
    y_offset = i * 30
    draw.arc([180, 280 + y_offset, 420, 420 + y_offset], 0, 180, fill=(200, 140, 20, 255), width=8)

img.save('assets/icon.png')
print('아이콘 생성 완료: assets/icon.png') 