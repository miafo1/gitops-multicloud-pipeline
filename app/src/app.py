from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    # Gather some runtime info
    hostname = socket.gethostname()
    cloud_provider = os.getenv('CLOUD_PROVIDER', 'Unknown-Cloud')
    
    return jsonify({
        "message": f"Hello from Multi-Cloud GitOps Pipeline [v1]",
        "cloud": cloud_provider,
        "pod": hostname,
        "status": "Running"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
