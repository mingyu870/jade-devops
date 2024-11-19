from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/notify', methods=['POST'])
def notify_user():
    data = request.get_json()

    # User 서비스로부터 사용자 정보 조회
    response = requests.get(f'http://user-service:5001/users/{data["userId"]}')
    if response.status_code == 200:
        user = response.json()
        print(f'Sending notification to {user["email"]}: New post titled "{data["title"]}"')
        return jsonify({'message': 'Notification sent'}), 200
    else:
        return jsonify({'error': 'User not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True,)
