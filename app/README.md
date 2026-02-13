# App

Configure the project. Populate the following with the correct data.

```toml
# .streamlit/secrets.toml

[connections.gsheets-2025]
spreadsheet = " ... "

# From your JSON key file
type = "service_account"
project_id = " ... "
private_key_id = " ... "
private_key = " ... "
client_email = " ... "
client_id = " ... "
auth_uri = "https://accounts.google.com/o/oauth2/auth"
token_uri = "https://oauth2.googleapis.com/token"
auth_provider_x509_cert_url = "https://www.googleapis.com/oauth2/v1/certs"
client_x509_cert_url = " ... "
```

Running the project:

```shell
# Running
python -m streamlit run your_script.py

# is equivalent to:
streamlit run your_script.py
```

## Reference

- https://discuss.streamlit.io/t/google-sheet-connection-when-i-have-more-than-one-page/14923
- https://stackoverflow.com/questions/77460905/how-can-i-reference-multiple-google-sheets-worksheets-from-streamlit-secrets-to
- https://github.com/streamlit/gsheets-connection
