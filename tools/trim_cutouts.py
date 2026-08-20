# GAME-004 抠图自动裁边：去掉透明边缘，让对象占满画布
# 用法: python trim_cutouts.py <目录>
import sys, os
from PIL import Image

def trim(path):
    img = Image.open(path).convert("RGBA")
    bbox = img.getchannel("A").getbbox()
    if not bbox:
        return False
    # 加8px内边距避免贴边
    pad = 8
    w, h = img.size
    x0 = max(0, bbox[0] - pad); y0 = max(0, bbox[1] - pad)
    x1 = min(w, bbox[2] + pad); y1 = min(h, bbox[3] + pad)
    img = img.crop((x0, y0, x1, y1))
    img.save(path)
    return True

def main():
    d = sys.argv[1] if len(sys.argv) > 1 else r"D:\deepseek\yunxiaoxing-game004\assets\processed\cutout_v001"
    done = 0
    for name in sorted(os.listdir(d)):
        if name.endswith("_alpha.png"):
            p = os.path.join(d, name)
            if trim(p):
                done += 1
    print(f"TRIM_DONE trimmed={done}")

if __name__ == "__main__":
    main()
