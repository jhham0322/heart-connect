"""
마음이음 아이콘 생성 스크립트
원본 이미지를 기반으로 윈도우(ICO)와 안드로이드(PNG) 아이콘을 생성합니다.
"""

from PIL import Image
import os

# 원본 이미지 경로
source_image = r"e:\work2025\App\ConnectHeart\html 시안\마음이음아이콘.jpg"

# 안드로이드 아이콘 크기 (mipmap 폴더별)
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# 윈도우 ICO 파일에 포함할 크기들
windows_sizes = [16, 24, 32, 48, 64, 128, 256]

# assets 폴더용 웹/앱 아이콘 크기
web_app_sizes = {
    'icon-192.png': 192,
    'icon-512.png': 512,
    'apple-touch-icon.png': 180,
    'favicon.png': 32,
}

def create_high_quality_icon(img, size):
    """고품질 리사이징"""
    # LANCZOS 리샘플링으로 고품질 축소
    return img.resize((size, size), Image.LANCZOS)

def main():
    # 원본 이미지 열기
    print(f"원본 이미지 로딩: {source_image}")
    original = Image.open(source_image)
    
    # RGBA로 변환 (투명도 지원)
    if original.mode != 'RGBA':
        original = original.convert('RGBA')
    
    # 정사각형으로 크롭 (중앙 기준)
    width, height = original.size
    if width != height:
        min_dim = min(width, height)
        left = (width - min_dim) // 2
        top = (height - min_dim) // 2
        right = left + min_dim
        bottom = top + min_dim
        original = original.crop((left, top, right, bottom))
        print(f"정사각형으로 크롭: {original.size}")
    
    # 1. 안드로이드 아이콘 생성
    print("\n=== 안드로이드 아이콘 생성 ===")
    android_res_path = r"e:\work2025\App\ConnectHeart\android\app\src\main\res"
    
    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        icon = create_high_quality_icon(original, size)
        output_path = os.path.join(folder_path, "ic_launcher.png")
        icon.save(output_path, "PNG")
        print(f"  생성됨: {output_path} ({size}x{size})")
    
    # 2. 윈도우 ICO 파일 생성
    print("\n=== 윈도우 아이콘 생성 ===")
    windows_icons_path = r"e:\work2025\App\ConnectHeart\windows\runner\resources"
    
    # 여러 크기의 이미지 생성
    icon_images = []
    for size in windows_sizes:
        icon = create_high_quality_icon(original, size)
        icon_images.append(icon)
        print(f"  ICO에 포함: {size}x{size}")
    
    # ICO 파일로 저장 (첫 번째 이미지를 기반으로, 나머지를 추가)
    ico_path = os.path.join(windows_icons_path, "app_icon.ico")
    icon_images[0].save(
        ico_path,
        format='ICO',
        sizes=[(s, s) for s in windows_sizes]
    )
    print(f"  생성됨: {ico_path}")
    
    # 3. 웹/앱 assets 아이콘 생성
    print("\n=== 웹/앱 assets 아이콘 생성 ===")
    assets_path = r"e:\work2025\App\ConnectHeart\assets"
    icons_path = os.path.join(assets_path, "icons")
    os.makedirs(icons_path, exist_ok=True)
    
    for filename, size in web_app_sizes.items():
        icon = create_high_quality_icon(original, size)
        output_path = os.path.join(icons_path, filename)
        icon.save(output_path, "PNG")
        print(f"  생성됨: {output_path} ({size}x{size})")
    
    # 앱 로고 (큰 사이즈)
    logo = create_high_quality_icon(original, 1024)
    logo_path = os.path.join(icons_path, "app_logo.png")
    logo.save(logo_path, "PNG")
    print(f"  생성됨: {logo_path} (1024x1024)")
    
    # 4. WindowUI FlutterControlPanel 아이콘 생성
    print("\n=== WindowUI FlutterControlPanel 아이콘 생성 ===")
    windowui_path = r"e:\work2025\App\ConnectHeart\WindowUI\FlutterControlPanel"
    
    # PNG 아이콘 (256x256)
    windowui_icon_png = create_high_quality_icon(original, 256)
    windowui_png_path = os.path.join(windowui_path, "icon.png")
    windowui_icon_png.save(windowui_png_path, "PNG")
    print(f"  생성됨: {windowui_png_path} (256x256)")
    
    # ICO 아이콘 (멀티 해상도)
    windowui_icon_images = []
    for size in windows_sizes:
        icon = create_high_quality_icon(original, size)
        windowui_icon_images.append(icon)
    
    windowui_ico_path = os.path.join(windowui_path, "icon.ico")
    windowui_icon_images[0].save(
        windowui_ico_path,
        format='ICO',
        sizes=[(s, s) for s in windows_sizes]
    )
    print(f"  생성됨: {windowui_ico_path}")
    
    print("\n✅ 모든 아이콘 생성 완료!")
    print("\n생성된 아이콘:")
    print("  - 안드로이드: mipmap-mdpi ~ mipmap-xxxhdpi (48~192px)")
    print("  - 윈도우 Flutter: app_icon.ico (16~256px 멀티 해상도)")
    print("  - 윈도우 컨트롤러: icon.ico, icon.png")
    print("  - 웹/앱: icon-192, icon-512, favicon, apple-touch-icon, app_logo")

if __name__ == "__main__":
    main()
