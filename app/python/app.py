from flask import Flask, request
import requests

app = Flask(__name__)

@app.route('/<user>/<repo>', methods=['GET'])
def get_latest_release(user, repo):
    url = f'https://api.github.com/repos/{user}/{repo}/releases/latest'
    response = requests.get(url)
    
    if response.status_code == 200:
        release_info = response.json()
        return release_info.get('tag_name', 'No release found')
    else:
        return ('error: Repository not found'), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

