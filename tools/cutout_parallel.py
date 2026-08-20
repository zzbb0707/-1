# GAME-004 批量抠图（多进程加速版）
# 用法: python cutout_parallel.py <输入目录> <输出目录> <workers>
import sys, os
from concurrent.futures import ProcessPoolExecutor
from rembg import remove
from PIL import Image

def cutout_one(args):
    src, dst = args
    try:
        inp = Image.open(src).convert("RGBA")
        out = remove(inp)
        a = out.getchannel("A").point(lambda v: 0 if v < 8 else v)
        out.putalpha(a)
        out.save(dst)
        return ("OK", os.path.basename(src))
    except Exception as e:
        return ("FAIL", os.path.basename(src), str(e))

def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else r"D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\approved_candidate"
    out_dir = sys.argv[2] if len(sys.argv) > 2 else r"D:\deepseek\yunxiaoxing-game004\assets\processed\cutout_v001"
    workers = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    os.makedirs(out_dir, exist_ok=True)
    files = sorted(f for f in os.listdir(src_dir)
                   if f.startswith("object_") and f.lower().endswith((".jpg", ".png")))
    jobs = []
    for name in files:
        out_name = os.path.splitext(name)[0] + "_alpha.png"
        dst = os.path.join(out_dir, out_name)
        if os.path.exists(dst):
            continue
        jobs.append((os.path.join(src_dir, name), dst))
    print(f"PENDING {len(jobs)} items, workers={workers}")
    done = fail = 0
    with ProcessPoolExecutor(max_workers=workers) as ex:
        for res in ex.map(cutout_one, jobs):
            if res[0] == "OK":
                done += 1
            else:
                fail += 1
                print(f"FAIL {res[1]}: {res[2] if len(res)>2 else ''}")
    print(f"CUTOUT_PARALLEL_DONE done={done} fail={fail}")

if __name__ == "__main__":
    main()
