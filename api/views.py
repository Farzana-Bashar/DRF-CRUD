from django.shortcuts import render
import io
from rest_framework.parsers import JsonParser
from .models import Student
from .serializers import StudentSerializer
from rest_framework.renderers import JSONRenderer
from django.http import HttpResponse

def student_api(request):
    if request.method == 'GET':
        json_data = request.body
        stream = io.BytesIO(json_data)
        pythondata = JsonParser().parse(stream)
        id = pythondata.get('id', None)
        if id is not None:
            stu = Student.object.get(id = id)
            serializer = StudentSerializer(stu)
            json_data = JSONRenderer().render(serializer.data)
            return HttpResponse(json_data, content_type = 'application/json')
