extends SceneTree

func _init() -> void:
    var cutout := "res://assets/processed/cutout_v001/object_bluesquare_v001_alpha.png"
    var original := "res://assets/candidates/banana/approved_candidate/object_bluesquare_v001.jpg"
    print("CUTOUT_EXISTS=", ResourceLoader.exists(cutout))
    print("ORIGINAL_EXISTS=", ResourceLoader.exists(original))
    if ResourceLoader.exists(cutout):
        var t := load(cutout) as Texture2D
        if t:
            print("CUTOUT_LOADED size=", t.get_width(), "x", t.get_height())
            var img := t.get_image()
            if img:
                # 检查角落像素是否透明
                var corner := img.get_pixel(4, 4)
                print("CORNER_ALPHA=", corner.a)
    quit(0)
