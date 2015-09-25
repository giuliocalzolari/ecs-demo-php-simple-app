from flask import Flask, render_template
# from redis import Redis
import os

app = Flask(__name__)
# redis = Redis(host='redis', port=6379)
# server_name = os.getenv('SRV_NAME')
# server_health_key = '{0}_health'.format(server_name)


@app.route('/health/check')
def health_check():
    return 'healthy', 200
    # health = redis.get(server_health_key)
    # if health == 'on':
    #     return 'healthy', 200
    # else:
    #     return 'not healthy', 500

@app.route('/')
def index():
    # redis.incr('hits')
    # return render_template('index.html', hits=redis.get('hits'))
    return render_template('index.html')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
