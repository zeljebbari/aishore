from flask import Flask, redirect, url_for, request, render_template
import os
import datetime
app = Flask(__name__)

app.config['upload_docs'] = 'uploads'
os.makedirs(app.config['upload_docs'], exist_ok = True)

@app.route('/')
def index():
    return render_template('upload.html')


@app.route('/success/<name>')
def success(name):
    return 'welcome %s' % name


@app.route('/login', methods=['POST', 'GET'])
def login():
    if request.method == 'POST':
        user = request.form['nm']
        return redirect(url_for('success', name=user))
    else:
        user = request.args.get('nm')
        return redirect(url_for('success', name=user))


if __name__ == '__main__':
    app.run(debug=True)
