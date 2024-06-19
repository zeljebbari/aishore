from flask import Flask
from flask import send_from_directory, render_template
from flask import redirect, url_for, request, jsonify
import os 
from datetime import datetime
from werkzeug.utils import secure_filename
from flask_cors import CORS
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient



app = Flask(__name__)
CORS(app)  

app.config['upload_docs'] = 'uploads'
os.makedirs(app.config['upload_docs'], exist_ok = True)

@app.route('/')
def render_page():
    return render_template('/index.html')

############### START: FLUTTER INTEGRATION ###############
# based on: https://betterprogramming.pub/serving-flutter-web-applications-with-python-flask-c60ab5fc3fc1
FLUTTER_WEB_APP = 'templates'

@app.route('/web/')
def render_page_web():
    return render_template('index.html')

@app.route('/web/<path:name>')
def return_flutter_doc(name):
    # datalist = str(name).split('/')
    # DIR_NAME = FLUTTER_WEB_APP
    # if len(datalist) > 1:
    #     for i in range(0, len(datalist) - 1):
    #         DIR_NAME += '/' + datalist[i]
    # return send_from_directory(DIR_NAME, datalist[-1])
    return send_from_directory(FLUTTER_WEB_APP, name)

############### END: FLUTTER INTEGRATION ###############

# idk what this does honestly...  for flutter? Not needed right now though
# @app.route('/api/data')
# def get_data():
#     return {"message": "Hello from Flask!"}

# uploading documents page 
@app.route('/analyst', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        # return "no file available"
        # print("NO files part in request")
        return jsonify({
            "message": "no file available", 
            "status": "fail"
            }), 400
    file = request.files['file']
    if file.filename == '':
        # print("no selected fileeee")
        return jsonify({
            "message": "no selected file", 
            "status": "fail"
            }), 400
    if file: 
        entity_name = request.form.get('entity_name')
        # borrower_name = request.form.get('borrower_name')
        borrower_first_name = request.form.get('borrower_first_name')
        borrower_m_name = request.form.get('borrower_m_name')
        borrower_last_name = request.form.get('borrower_last_name')        
        doc_type = request.form.get('doc_type')
        doc_type_other = request.form.get('doc_type_other', '')
        if doc_type == 'Other' and doc_type_other:
            doc_type= doc_type_other
        timestamp = datetime.now().strftime('%Y-%m-%d_%H:%M:%S')
        # timestamp = datetime.now()
        filename = secure_filename(f"{timestamp}_{file.filename}")
        file.save(os.path.join(app.config['upload_docs'], filename))
        # return f"File uploaded successfully!<br>Name: {file}"
        file_url = url_for('uploaded_file', filename=filename, _external = True)
        print("file uploaded success")
        return jsonify({
            "message": "File uploaded successfully",
            "status": "success",
            "file_url": file_url,
            "doc_type": doc_type,
            "entity_name": entity_name,
            # "borrower_name": borrower_name
            "borrower_first_name": borrower_first_name,
            "borrower_m_name": borrower_m_name,
            "borrower_last_name": borrower_last_name
        }), 200
    else: 
        return jsonify({
            "message": "Failed to upload file a",
            "status": "fail"
        }), 400

# rerouting for uploaded files to either display the image or provide a download link to the pdf 
@app.route('/analyst/<path:filename>', methods=['GET'])
def uploaded_file(filename):
    return send_from_directory(app.config['upload_docs'], filename, as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True)