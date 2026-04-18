import os
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from google.cloud import storage
from google.api_core.exceptions import NotFound, Forbidden
import time
import pandas as pd
import requests
import zipfile
import io
from itertools import repeat
from dotenv import load_dotenv

date = "20260406"

load_dotenv()

BUCKET_NAME = os.getenv('BUCKET_NAME')

CREDENTIALS_FILE = "gcs.json"
client = storage.Client.from_service_account_json(CREDENTIALS_FILE)


CHUNK_SIZE = 8 * 1024 * 1024

bucket = client.bucket(BUCKET_NAME)

def get_upload_list(date):

    url = "http://data.gdeltproject.org/gdeltv2/"
    file_name = "masterfilelist.txt"
    full_path = f"{url}{file_name}"

    final_dataframe = pd.DataFrame()

    dtype = {
        "file_size": "string",
        "md5_hash": "string",
        "link": "string"
    }

    chunksize = 50000

    try:
        print(f"Processing masterfile...")
        df_iter = pd.read_csv(
                full_path,
                sep=' ',
                header=None,
                names=['file_size', 'md5_hash', 'link'],
                dtype=dtype,
                iterator=True,
                chunksize=chunksize,)
    except Exception as e:
        print(f"Error: {e} in file {file_name}")
        sys.exit(f"Critical Error with masterfile '{file_name}'. Processing stopped.")


    i = 1
    for df_chunk in df_iter:
        df_chunk_filtered = df_chunk[(df_chunk["link"].str.contains("export", na=False)) & 
                                    (df_chunk["link"].str.contains(f"{date}", na=False))]
        

        final_dataframe = pd.concat(
                        [final_dataframe, df_chunk_filtered[["link"]]], axis=0, ignore_index=True
                    )
        i = i + 1

    lst = final_dataframe["link"].tolist()

    return lst

def verify_gcs_upload(blob_name):
    return storage.Blob(bucket=bucket, name=blob_name).exists(client)


def upload_to_gcs(file_path, date, max_retries=3):
    blob_name = f"{date}/{os.path.basename(file_path)[:-4]}"
    blob = bucket.blob(blob_name)
    blob.chunk_size = CHUNK_SIZE

    # download a file
    response = requests.get(file_path)
    response.raise_for_status()
    z = zipfile.ZipFile(io.BytesIO(response.content))

    for attempt in range(max_retries):
        try:
            print(f"Uploading&unzipping {file_path} to {BUCKET_NAME} (Attempt {attempt + 1})...")
            blob.upload_from_string(z.read(z.namelist()[0]))

            print(f"Uploaded: gs://{BUCKET_NAME}/{date}/{blob_name}")

            if verify_gcs_upload(blob_name):
                print(f"Verification successful for {blob_name}")
                return
            else:
                print(f"Verification failed for {blob_name}, retrying...")
        except Exception as e:
            print(f"Failed to upload {file_path} to GCS: {e}")

        time.sleep(5)

    print(f"Giving up on {file_path} after {max_retries} attempts.")


if __name__ == "__main__":

    with ThreadPoolExecutor(max_workers=4) as executor:
        executor.map(upload_to_gcs, filter(None, get_upload_list(date)), repeat(date))  # Remove None values

    print("All files processed and verified.") 