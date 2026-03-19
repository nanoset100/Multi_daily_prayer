import struct
import zlib
import os

def create_simple_png():
    """간단한 1024x1024 PNG 파일을 생성합니다."""
    
    width = 1024
    height = 1024
    
    # 베이지색 배경 (#F0E6D2)
    bg_r, bg_g, bg_b = 240, 230, 210
    
    # 금색 (#DAA520)  
    gold_r, gold_g, gold_b = 218, 165, 32
    
    # 이미지 데이터 생성 (RGBA)
    img_data = []
    
    for y in range(height):
        row = []
        for x in range(width):
            # 간단한 원형 패턴으로 금색 비둘기 형태 생성
            center_x, center_y = 512, 512
            distance = ((x - center_x) ** 2 + (y - center_y) ** 2) ** 0.5
            
            if distance < 300:  # 중앙 원형 영역
                # 금색
                row.extend([gold_r, gold_g, gold_b, 255])
            else:
                # 베이지색 배경
                row.extend([bg_r, bg_g, bg_b, 255])
        
        img_data.append(bytes([0] + row))  # PNG 필터 바이트 추가
    
    # PNG 데이터 압축
    raw_data = b''.join(img_data)
    compressed_data = zlib.compress(raw_data)
    
    # PNG 헤더 생성
    def make_chunk(chunk_type, data):
        length = struct.pack('>I', len(data))
        crc = zlib.crc32(chunk_type + data) & 0xffffffff
        return length + chunk_type + data + struct.pack('>I', crc)
    
    # PNG 시그니처
    png_signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR 청크
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr_chunk = make_chunk(b'IHDR', ihdr_data)
    
    # IDAT 청크
    idat_chunk = make_chunk(b'IDAT', compressed_data)
    
    # IEND 청크
    iend_chunk = make_chunk(b'IEND', b'')
    
    # PNG 파일 생성
    png_data = png_signature + ihdr_chunk + idat_chunk + iend_chunk
    
    # 파일로 저장
    with open('assets/icon.png', 'wb') as f:
        f.write(png_data)
    
    print('SUCCESS: 간단한 금색 원형 PNG 아이콘 생성 완료 - assets/icon.png')

if __name__ == '__main__':
    create_simple_png() 