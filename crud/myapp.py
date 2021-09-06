import requests
import json

URL ="http://127.0.0.1:8000/studentapi/"

def get_data(id = None):
    data = {}
    if id is not None:
        data = {'id': id}
    
    json_data = json.dumps(data)

    r = requests.get(url = URL, data =json_data)
    data = r.json()
    print(data)

# get_data(2)


def post_data(id = None):
    data = {
        'name': 'shajal',
        'roll': 31,
        'city': 'magura'
    }
    
    json_data = json.dumps(data)

    r = requests.post(url = URL, data =json_data)
    data = r.json()
    print(data)

post_data()