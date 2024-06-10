from flask import Flask, redirect, url_for, request, render_template
import os
from datetime import datetime
app = Flask(__name__)

app.config['upload_docs'] = 'uploads'
os.makedirs(app.config['upload_docs'], exist_ok = True)

@app.route('/')
def index():
    return render_template('upload.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "no file available"
    file = request.files['file']
    if file: 
        entity = request.form['entity_name']
        borrower = request.form['borrower_name']
        doc_type = request.form['doc_type']
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        # timestamp = datetime.now()
        # filename = f"{timestamp}_{file.filename}"
        filename = file.filename
        file.save(os.path.join(app.config['upload_docs'], filename))
        # return f"File uploaded successfully!<br>Name: {file}"
        return (render_template('uploaded.html', 
                                entity_name= entity, 
                                borrower_name = borrower, 
                                doc_type_name = doc_type, 
                                timestamp_n = timestamp
                                )
                )


if __name__ == '__main__':
    app.run(debug=True)
