import streamlit as st
import pandas as pd
from streamlit_gsheets import GSheetsConnection

st.set_page_config(layout="wide")
st.title("Money Tracer: Reading Multiple Google Sheets")
st.markdown("---")

# List of worksheets to read
# Note: Ensure these names exactly match the sheet tabs in the Google Sheet.
worksheets = ["Patrimonio", "Entrate", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

# Create a connection object.
# The connection name must match the one defined in .streamlit/secrets.toml
try:
    conn = st.connection("gsheets-2025", type=GSheetsConnection)
except Exception as e:
    st.error(f"Could not connect to Google Sheets. Please ensure 'gsheets-2025' is configured correctly in your secrets. Error: {e}")
    st.stop()

selected_sheet = st.selectbox(
    "Select a Worksheet to View:",
    options=worksheets,
    index=0,
    placeholder="Choose a sheet..."
)


if selected_sheet:
    st.subheader(f"Displaying Data for Sheet: **{selected_sheet}**")
    
    try:
        # Read the content of the current worksheet
        # Use usecols and nrows=None to read all data in the sheet
        df = conn.read(
            worksheet=selected_sheet, 
            ttl="1h", # Cache data for 1 hour
            usecols=None, 
            nrows=None 
        )

        # Drop rows where all values are NaN (often resulting from reading blank rows in sheets)
        df.dropna(how='all', inplace=True)

        if df.empty:
            st.info(f"The worksheet '{selected_sheet}' is currently empty or contains only headers.")
        else:
            # Display the DataFrame
            st.dataframe(
                df,
                hide_index=True,
                use_container_width=True
            )

            
    except Exception as e:
        # Catch specific errors during the read process (e.g., sheet not found)
        st.error(f"Failed to read worksheet '{selected_sheet}'. Error: {e}")
    
    st.markdown("---")