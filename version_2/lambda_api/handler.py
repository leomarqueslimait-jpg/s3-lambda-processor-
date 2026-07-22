import csv
import io
import json
import os
import uuid

import boto3

from student import Student

FIELDNAMES = ["first_name", "last_name", "dob", "guardian_name",
              "guardian_email", "guardian_phone", "enrollment_date", "school_site"]

BUCKET_NAME = os.environ["BUCKET_NAME"]

s3_client = boto3.client("s3")

# API Gateway calls this cross-origin from wherever the static form ends up
# being hosted, so every response - success or error - needs this header.
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json",
}


def upload_student_to_s3(student):
    """Uploads a single-row CSV for this one student so each form
    submission triggers exactly one S3 event -> one Lambda invocation,
    instead of re-uploading the whole growing student.csv every time."""
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=FIELDNAMES)
    writer.writeheader()
    writer.writerow(student.to_dict())

    safe_dob = student.dob.replace("/", "-")  # avoid "/" creating pseudo-folders in S3
    key = f"submissions/{student.last_name}_{student.first_name}_{safe_dob}_{uuid.uuid4()}.csv"
    s3_client.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=buffer.getvalue(),
        ContentType="text/csv",
    )
    return key


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": CORS_HEADERS,
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    try:
        fields = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return response(400, {"error": "Malformed JSON body"})

    try:
        # Default missing fields to "" rather than None - unlike Streamlit's
        # st.text_input (which always returns a string), an arbitrary JSON
        # body can omit a key entirely, and Student's enrollment_date setter
        # only catches ValueError from strptime, not the TypeError that
        # strptime(None, ...) raises.
        student = Student(
            fields.get("first_name", ""),
            fields.get("last_name", ""),
            fields.get("dob", ""),
            fields.get("guardian_name", ""),
            fields.get("guardian_email", ""),
            fields.get("guardian_phone", ""),
            fields.get("enrollment_date", ""),
            fields.get("school_site", ""),
        )
    except ValueError as e:
        return response(400, {"error": str(e)})

    try:
        upload_student_to_s3(student)
    except Exception as e:
        # No partial/local save - either the submission is fully in S3 or it
        # doesn't exist anywhere. The guardian just has to retry.
        print(f"S3 upload failed for {student.first_name} {student.last_name}: {e}")
        return response(502, {"error": "Upload failed, please try again."})

    return response(200, {"message": f"Saved {student.first_name} {student.last_name}"})
