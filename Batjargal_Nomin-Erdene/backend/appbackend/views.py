from django.http import StreamingHttpResponse, Http404
import os
import re

def stream_audio(request, filename):
    file_path = os.path.join('media/audio', filename)

    if not os.path.exists(file_path):
        raise Http404("File not found")

    file_size = os.path.getsize(file_path)
    range_header = request.headers.get('Range', '').strip()
    content_type = 'audio/mpeg'

    if range_header:
        range_match = re.match(r'bytes=(\d+)-(\d*)', range_header)
        if range_match:
            start = int(range_match.group(1))
            end = int(range_match.group(2)) if range_match.group(2) else file_size - 1
            length = end - start + 1

            def stream_generator(path, start, length):
                with open(path, 'rb') as f:
                    f.seek(start)
                    remaining = length
                    chunk_size = 8192
                    while remaining > 0:
                        read_size = min(chunk_size, remaining)
                        data = f.read(read_size)
                        if not data:
                            break
                        yield data
                        remaining -= len(data)

            response = StreamingHttpResponse(
                stream_generator(file_path, start, length),
                status=206,
                content_type=content_type
            )
            response['Content-Range'] = f'bytes {start}-{end}/{file_size}'
            response['Content-Length'] = str(length)
            response['Accept-Ranges'] = 'bytes'
            return response

    # No Range header
    def full_file_generator(path):
        with open(path, 'rb') as f:
            while True:
                chunk = f.read(8192)
                if not chunk:
                    break
                yield chunk

    response = StreamingHttpResponse(
        full_file_generator(file_path),
        content_type=content_type
    )
    response['Content-Length'] = str(file_size)
    response['Accept-Ranges'] = 'bytes'
    return response
