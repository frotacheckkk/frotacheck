import imageio
from PIL import Image
from pathlib import Path

video_path = Path(r"C:\Users\Andressa\Downloads\WhatsApp Video 2026-06-17 at 09.50.19.mp4")
output_path = Path(r"C:\frotacheck\video_frame_000.png")

print('video_exists', video_path.exists())
print('video_size', video_path.stat().st_size if video_path.exists() else None)

try:
    reader = imageio.get_reader(str(video_path), format='ffmpeg')
    meta = reader.get_meta_data()
    print('meta', meta)
    print('width,height', meta.get('size'))
    print('duration', meta.get('duration'))
    print('fps', meta.get('fps'))
    print('nframes', len(reader))
    frame = reader.get_data(0)
    Image.fromarray(frame).save(output_path)
    print('saved_frame', output_path)
    reader.close()
except Exception as e:
    import traceback
    traceback.print_exc()
