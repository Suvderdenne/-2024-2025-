from django.urls import path
from django.contrib import admin
from appbackend import auth, edituser, book, search, favorite, review, comment, readinghistory
from sendfile import sendfile
from django.http import HttpResponseNotFound
from django.conf import settings
from appbackend.views import stream_audio  # << энэ шугам нэмэх хэрэгтэй

def media_file(request, path):
    file_path = settings.MEDIA_ROOT + '/' + path
    try:
        return sendfile(request, file_path)
    except FileNotFoundError:
        return HttpResponseNotFound("File not found")
urlpatterns = [
     path('admin/', admin.site.urls),
    path('user/', auth.checkService),
    path('useredit/', edituser.editcheckService),
    path('book/', book.editcheckService),
    path("search/", search.searchBookService),
    path("search/options/", search.get_options),
    path('favorite/', favorite.favoriteService),
    path('review/', review.reviewService),
    path('comment/', comment.commentService),
    path('readinghistory/', readinghistory.editcheckService),

    # ✅ Range Request дэмждэг stream
    path('stream/audio/<str:filename>', stream_audio),

    # ✅ /media/audio/ файлд Range дэмжих stream
    path('media/audio/<str:filename>', stream_audio),

    # 🗂 Бусад медиа файлд fallback
    path('media/<path:path>/', media_file),
]

from django.conf.urls.static import static
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
