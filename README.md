# Common Misconfig leads to Improper Access Control on django-mdeditor's upload path

## I. What is `django-mdeditor`?

`django-mdeditor` is a popular Django open-source project that provides an easy-to-use markdown editor for websites, supporting media uploads and live previews. This editor can be integrated either directly into templates or the Django admin panel through the `MDTextField` class.

## II. Security Issue

By default, the app does not handle uploads in an agnostic manner. It uses an `UploadView` class to process uploads, and the behavior of this view is configured in `settings.py` through `MDEDITOR_CONFIGS`. The issue lies in the fact that this view does not implement access control out of the box.

```python
class UploadView(generic.View):
    """ Upload image file """

    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super(UploadView, self).dispatch(*args, **kwargs)

    def post(self, request, *args, **kwargs):
        upload_image = request.FILES.get("editormd-image-file", None)
        media_root = settings.MEDIA_ROOT

        # image none check
        if not upload_image:
            return JsonResponse({
                'success': 0,
                'message': "未获取到要上传的图片",
                'url': ""
            })

        # image format check
        file_name_list = upload_image.name.split('.')
        file_extension = file_name_list.pop(-1)
        file_name = '.'.join(file_name_list)
        if file_extension not in MDEDITOR_CONFIGS['upload_image_formats']:
            return JsonResponse({
                'success': 0,
                'message': "上传图片格式错误，允许上传图片格式为：%s" % ','.join(
                    MDEDITOR_CONFIGS['upload_image_formats']),
                'url': ""
            })

        # image floder check
        file_path = os.path.join(media_root, MDEDITOR_CONFIGS['image_folder'])
        if not os.path.exists(file_path):
            try:
                os.makedirs(file_path)
            except Exception as err:
                return JsonResponse({
                    'success': 0,
                    'message': "上传失败：%s" % str(err),
                    'url': ""
                })

        # save image
        file_full_name = '%s_%s.%s' % (file_name,
                                       '{0:%Y%m%d%H%M%S%f}'.format(datetime.datetime.now()),
                                       file_extension)
        with open(os.path.join(file_path, file_full_name), 'wb+') as file:
            for chunk in upload_image.chunks():
                file.write(chunk)

        return JsonResponse({'success': 1,
                             'message': "上传成功！",
                             'url': os.path.join(settings.MEDIA_URL,
                                                 MDEDITOR_CONFIGS['image_folder'],
                                                 file_full_name)})
```

This can lead to scenarios where editing a markdown field might require authentication (e.g., through Django admin), but uploading files does not require it.

## III. Impact

The simplest way to exploit this vulnerability is through a file system Denial of Service (DoS) attack impacting availability.

Additionally, it can be used to increase stealth in an attack. For instance, if `https://jobs.ecorp.com` is vulnerable, an unauthenticated attacker could upload and retrieve malicious payloads hosted on that domain, helping in evading detection from DNS filtering.

## IV. Proposed Fixes

### Temporary Fix

An immediate fix would be to decorate the upload view with `login_required` to enforce authentication.

For example, instead of:
```python
urlpatterns = [
    ...
   url(r'mdeditor/', include('mdeditor.urls')),
    ...
]
```

You would use:
```python
urlpatterns = [
    ...
    path('mdeditor/uploads/', login_required(UploadView.as_view()), name='uploads'),
    ...
]
```

### Permanent Fix

A permanent solution could involve adopting [this fork](https://github.com/lenoctambule/django-mdeditor) that I made of the application and modifying `MDEDITOR_CONFIGS` accordingly. Alternatively, at the cost of breaking compatibility with apps dependent on this package, a more robust solution would be to create another fork that removes the `UploadView` entirely and use HTTP return codes instead of json responses. Essentially leaving the task of handling uploads on the back-end up to the developers such that they have full control of security.
