from django.shortcuts import render
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import StreamingHttpResponse
from wsgiref.util import FileWrapper

import os
import ffmpeg
import mimetypes

def convert(f):
    pos = f.rfind('.')
    new_name = f[:pos] + '-gray.mp4'
    ffmpeg.input(f).output(new_name, vf='format=gray', pix_fmt='yuv420p').run()
    return new_name

def simple_upload(request):
    if request.method == 'POST' and request.FILES['myfile']:
        myfile = request.FILES['myfile']
        fs = FileSystemStorage()
        filename = fs.save(myfile.name, myfile)
        filename = convert(filename)
        #uploaded_file_url = fs.url(filename)
        uploaded_file_url = filename
        return render(request, 'upload.html', {
            'uploaded_file_url': uploaded_file_url
        })
    return render(request, 'upload.html')

def get_file(request, file_path):
    chunk_size = 8192
    response = StreamingHttpResponse(FileWrapper(open(file_path, 'rb'), chunk_size),
            content_type=mimetypes.guess_type(file_path)[0])
    response['Content-Length'] = os.path.getsize(file_path)
    response['Content-Disposition'] = "attachment; filename=%s" % file_path
    return response
