from flask import Flask, redirect, url_for, request, render_template, send_from_directory
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
        # entity_first = request.form['entity_f_name']
        # entity_last = request.form['entity_l_name']
        borrower = request.form['borrower_name']
        # borrower_first = request.form['borrower_f_name']
        # borrower_last = request.form['borrower_l_name']        
        doc_type = request.form['doc_type']
        other_doc_type = request.form['other_doc_type']
        if doc_type == 'Other' and other_doc_type:
            doc_type= other_doc_type
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        # timestamp = datetime.now()
        # filename = f"{timestamp}_{file.filename}"
        filename = file.filename
        file.save(os.path.join(app.config['upload_docs'], filename))
        # return f"File uploaded successfully!<br>Name: {file}"
        file_url = url_for('uploaded_file', filename=filename)
        return (render_template('uploaded2.html', 
                                entity_name= entity, 
                                borrower_name = borrower, 
                                # filename = f"{borrower_last}_{borrower_first}-{doc_type}"
                                # entity_f_name = entity_first, 
                                # entity_l_name = entity_last,
                                # borrower_f_name = borrower_first,
                                # borrower_l_name = borrower_last,
                                doc_type_name = doc_type, 
                                timestamp_n = timestamp,
                                file_url = file_url
                                )
                )

@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['upload_docs'],
                               filename, as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True)
