from flask import Flask
from flask import send_from_directory, render_template, request, jsonify
from datetime import datetime, timedelta, timezone
from werkzeug.utils import secure_filename
from flask_cors import CORS
from azure.storage.blob import BlobServiceClient, generate_blob_sas, BlobSasPermissions
import pyodbc
import re
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential

app = Flask(__name__, template_folder='web', static_folder='web')


############### START: AZURE BLOB STORAGE + SQL DATABASE INTEGRATION ###############
app.config.from_object('config.Config')
CORS(app, resources={r"/*": {"origins": [app.config['FLASK_SERVICE_EXTIP'], 
                                         app.config['AZURE_BLOB_STORAGE_ORIGIN'], 
                                         "*"]}})
# on local computer, the credential should be default to work -- login through the command line or possibly the vscode env
# when deploying, the credential needs to be managed identity
# credential = DefaultAzureCredential()
credential = ManagedIdentityCredential(client_id="ac047e2f-e290-4041-9312-2e452303bb11")
secret_client = SecretClient(vault_url=app.config['KEY_VAULT_URI'], credential=credential)
blob_connect_str = secret_client.get_secret("blob-storage-connect-string").value
blob_connect_key = secret_client.get_secret("blob-storage-connect-key").value
sql_connection_str = secret_client.get_secret("sql-database-connect-string").value

container_name = app.config['CONTAINER_NAME']
blob_service_client = BlobServiceClient.from_connection_string(conn_str=blob_connect_str)
try:
    container_client = blob_service_client.get_container_client(container=container_name) 
    container_client.get_container_properties()
except Exception as e:
    print("Creating container")
    container_client = blob_service_client.create_container(container_name)
############### END: AZURE BLOB STORAGE + SQL DATABASE INTEGRATION ###############

############### START: FLUTTER INTEGRATION ###############
FLUTTER_WEB_APP = 'web'

@app.route('/')
def render_page_web():
    """
    rendered index.html from the web--meaning it renders the flutter page
    takes the external ip and sends it to the front-end
    """
    return render_template('index.html', base_url=app.config['FLASK_SERVICE_EXTIP'])

@app.route('/<path:name>')
def return_flutter_doc(name):
    """
    accesses the files from the web folder
    """
    return send_from_directory(FLUTTER_WEB_APP, name)

############### END: FLUTTER INTEGRATION ###############


@app.route('/analyst', methods=['POST'])
def upload_file():
    """
    uploads file from the front-end to the blob storage with index tags
    information in the index tags are stored in uppercase for consistency
    """
    if 'file' not in request.files:
        return jsonify({
            "message": "no file available", 
            "status": "fail"
            }), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({
            "message": "no selected file", 
            "status": "fail"
            }), 400
    entity_name = request.form.get('entity_name')
    borrower_first_name = request.form.get('borrower_first_name')
    borrower_m_name = request.form.get('borrower_m_name')
    borrower_last_name = request.form.get('borrower_last_name')        
    doc_type = request.form.get('doc_type')
    doc_type_other = request.form.get('doc_type_other', '')
    if doc_type == 'Other' and doc_type_other:
        doc_type= doc_type_other
    timestamp = datetime.now().strftime('%Y-%m-%d_%H:%M:%S')
    filename_parts = [timestamp, doc_type, borrower_first_name]
    if borrower_m_name:
        filename_parts.append(borrower_m_name)
    filename_parts.append(borrower_last_name)
    file_extension = file.filename.rsplit('.', 1)[-1]
    filename = secure_filename("_".join(filename_parts)+'.'+file_extension)
    metadata_tags = {
        "entity_name": entity_name.upper() if entity_name else '',
        "borrower_first_name": borrower_first_name.upper(),
        "borrower_m_name": borrower_m_name.upper(),
        "borrower_last_name": borrower_last_name.upper(),
        "doc_type": doc_type.upper(),
        "timestamp": datetime.now().isoformat()
    }
    invalid_characters = r'[^a-zA-Z0-9-_.: ]' # limits characters to the alphabet, numbers, -, _, :, . 
    def has_invalid_chars(value):
        return bool(re.search(invalid_characters, value))
    for key, value in metadata_tags.items():
        if has_invalid_chars(value):
            return jsonify({
                "message": f"Invalid character in metadata tag: {key}",
                "status": "fail"
            }), 400
    try:
        blob_client = container_client.get_blob_client(filename)
        blob_client.upload_blob(file.stream, overwrite=True)
        blob_client.set_blob_tags(metadata_tags)
        file_url = blob_client.url
        return jsonify({
            "message": "File uploaded successfully",
            "status": "success",
            "file_url": file_url,
            "doc_type": doc_type,
            "entity_name": entity_name,
            "borrower_first_name": borrower_first_name,
            "borrower_m_name": borrower_m_name,
            "borrower_last_name": borrower_last_name
        }), 200
    except Exception as e: 
        return jsonify({
            "message": "Failed to upload file, Error ${e}",
            "status": "fail", 
            "error": str(e),
        }), 500

@app.route('/analyst/<path:filename>', methods=['GET'])
def uploaded_file(filename):
    """
    ^ the confirmation page after upload to the blob has been confirmed
    retrieves from the blob storage immediately after using an SAS token, meaning it doesn't have to go through the managed identity
    """
    try:
        filename = secure_filename(filename)
        blob_client = container_client.get_blob_client(blob=filename)
        if not blob_client.exists():
            return jsonify({"message": "Blob not found"}), 404
        start_time = datetime.now(timezone.utc)
        expiry_time = start_time + timedelta(hours=1)
        sas_token = generate_blob_sas(
            account_name = blob_service_client.account_name,
            container_name = container_name,
            blob_name = blob_client.blob_name,
            account_key = blob_connect_key,
            permission = BlobSasPermissions(read=True),
            expiry = expiry_time,
            start = start_time,
        )
        signed_url = f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{filename}?{sas_token}"
        blob_url = f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{filename}"
        print(signed_url)
        return jsonify({
            "file_url": signed_url,
            "blob_url": blob_url,
            "status": "success"
        })
    except Exception as e:
        print(f"Error generating SAS URL: {str(e)}")
        return jsonify({"message": f"Failed to retrieve file: {str(e)}", "status": "fail"}), 500

@app.route('/analyst/delete/<path:filename>', methods=['DELETE'])
def delete_file(filename):
    """
    allows users to delete from the blob storage after upload is confirmed
    """
    try:
        blob_client = container_client.get_blob_client(blob=filename)
        if blob_client.exists():
            blob_client.delete_blob()
            return jsonify({"message": "File deleted successfully", "status": "success"}), 200
        else:
            return jsonify({"message": "Blob not found", "status": "fail"}), 404
    except Exception as e:
        return jsonify({"message": f"Failed to delete file: {str(e)}", "status": "fail"}), 500


# consider azure ai search for a more fuzzy matching of blobs
@app.route('/steward', methods=['POST'])
def search():
    """
    user search function through the blob storage 
    Note blob storage index tags are case sensitive, so it converts the form entry to upper-case to search
    """
    data = request.get_json()
    borrower_first_name = data.get('borrower_first_name').upper()
    borrower_m_name = data.get('borrower_m_name').upper()
    borrower_last_name = data.get('borrower_last_name').upper()
    doc_type = data.get('doc_type').upper()
    entity_name = data.get('entity_name').upper()
    container_client = blob_service_client.get_container_client(container=container_name)
    query_parts = []
    if borrower_first_name:
        query_parts.append(f"\"borrower_first_name\"='{borrower_first_name}'")
    if borrower_m_name:
        query_parts.append(f"\"borrower_m_name\"='{borrower_m_name}'")
    if borrower_last_name:
        query_parts.append(f"\"borrower_last_name\"='{borrower_last_name}'")
    if doc_type and doc_type!= "OTHER":
        query_parts.append(f"\"doc_type\"='{doc_type}'")
    if entity_name:
        query_parts.append(f"\"entity_name\"='{entity_name}'")
    query = " AND ".join(query_parts)
    blob_list = container_client.find_blobs_by_tags(filter_expression=query)
    results = []
    for blob in blob_list:
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
        tags = blob_client.get_blob_tags()
        if tags:
            if doc_type == "OTHER":
                current_doc_type = tags.get('doc_type')
                if current_doc_type in ['ID', 'LOAN APPLICATION', 'FICO', 'BACKGROUND CHECK', 'APPRAISAL', 'FLOOD CERT', 'PEXP']:
                    continue
            results.append({
                'name': blob.name,
                'url': blob_client.url,
                'borrower_first_name': tags.get('borrower_first_name'),
                'borrower_m_name': tags.get('borrower_m_name'),
                'borrower_last_name': tags.get('borrower_last_name'),
                'doc_type': tags.get('doc_type'),
                'entity_name': tags.get('entity_name')
            })
    return jsonify(results)

@app.route('/send_confidence', methods=['POST'])
def send_confidence():
    """
    retrieves the confidence data from the sql table to indicate the document confidence level
    document confidence level is set to be the minimum confidence level of all the key value pairs within the document
    """
    data = request.get_json()
    document_url = data.get('URL', '')
    query = "SELECT MIN(Confidence) as confidence_lev FROM [dbo].[Lendmarq] WHERE URL LIKE ?"
    params = [f'%{document_url}%',]
    conn = pyodbc.connect(sql_connection_str)
    cursor = conn.cursor()
    cursor.execute(query, params)
    record = cursor.fetchone()
    if record and record.confidence_lev is not None:
        confidence_lev = record.confidence_lev
    else:
        confidence_lev = 0
    return jsonify({'send_confidence': confidence_lev})

@app.route('/database', methods=['POST'])
def search_database():
    """
    retrieves the sql table key value pair data according to document
    """
    data = request.get_json()
    document_url = data.get('URL', '')
    query = "SELECT * FROM [dbo].[Lendmarq] WHERE URL LIKE ?"
    params = [f'%{document_url}%',]
    conn = pyodbc.connect(sql_connection_str)
    cursor = conn.cursor()
    cursor.execute(query, params)
    records = cursor.fetchall()
    results = []
    for record in records:
        results.append({
            'ID': record.ID,
            'DocumentType': record.DocumentType,
            'URL': record.URL,
            'Time': record.Time,
            'FirstName': record.FirstName,
            'LastName': record.LastName,
            'EntityName': record.EntityName,
            'PairKey': record.PairKey,
            'PairValue': record.PairValue,
            'Confidence': record.Confidence,
            'Page': record.Page,
        })
    return jsonify(results)

@app.route('/newvalue', methods=['POST'])
def update_value():
    """
    allows the user to update the value of a key value pair within the document and updates the corresponding confidence level
    """
    data = request.get_json()
    id = data.get('ID')
    new_value = data.get('PairValue')
    if not id or new_value is None:
        return jsonify({'message': 'Invalid request data'}), 400
    try:
        conn = pyodbc.connect(sql_connection_str)
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE [dbo].[Lendmarq] SET PairValue = ?, Confidence = 1.00 WHERE ID = ?",
            (new_value, id)
        )
        conn.commit()
        return jsonify({'message': 'Changes saved successfully'}), 200
    except pyodbc.Error as e:
        return jsonify({'message': f'Error saving changes: {str(e)}'}), 500
    finally:
        conn.close()


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')