from flask import Flask
import sys

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health_check():
    return "App is running", 200

def sum_numbers(num1, num2):
    return num1 + num2

if __name__ == "__main__":
    num1 = int(sys.argv[1])
    num2 = int(sys.argv[2])
    print(sum_numbers(num1, num2))
    app.run(host='0.0.0.0', port=8080)
