import json
import requests

def lambda_handler(event, context):
    # Extract user and repo from the path parameters
    user = event['pathParameters']['user']
    repo = event['pathParameters']['repo']
    
    # Construct the GitHub API URL
    url = f'https://api.github.com/repos/{user}/{repo}/releases/latest'
    
    # Make the API request to GitHub
    response = requests.get(url)
    
    # Handle the response from GitHub
    if response.status_code == 200:
        release_info = response.json()
        tag_name = release_info.get('tag_name', 'No release found')
        return {
            'statusCode': 200,
            'body': json.dumps({'Latest version': tag_name })
        }
    else:
        return {
            'statusCode': response.status_code,
            'body': json.dumps({'error': 'Repository not found'})
        }
