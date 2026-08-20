# GAME-004 批量抠图：把 approved_candidate 的对象图抠成透明PNG
# 用法: python cutout_objects.py <输入目录> <输出目录>
import sys, os
from rembg import remove
from PIL import Image

def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else r"D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\approved_candidate"
    out_dir = sys.argv[2] if len(sys.argv) > 2 else r"D:\deepseek\yunxiaoxing-game004\assets\processed\cutout_v001"
    os.makedirs(out_dir, exist_ok=True)
    # 只处理 object_ 开头的 jpg/png
    files = sorted(f for f in os.listdir(src_dir)
                   if f.startswith("object_") and f.lower().endswith((".jpg", ".png")))
    done, fail = 0, 0
    for name in files:
        src = os.path.join(src_dir, name)
        out_name = os.path.splitext(name)[0] + "_alpha.png"
        dst = os.path.join(out_dir, out_name)
        if os.path.exists(dst):
            done += 1
            continue
        try:
            inp = Image.open(src).convert("RGBA")
            out = remove(inp)
            # 去掉边缘半透明噪点：alpha < 8 归零
            alpha = out.getchannel("A")
            import PIL.ImageOps
            alpha = alpha.point(lambda a: 0 if a < 8 else a)
            out.putalpha(alpha)
            out.save(dst)
            done += 1
            print(f"OK {name} -> {out_name}")
        except Exception as e:
            fail += 1
            print(f"FAIL {name}: {e}")
    print(f"CUTOUT_DONE done={done} fail={fail} total_files={len(files)}")

if __name__ == "__main__":
    main()
