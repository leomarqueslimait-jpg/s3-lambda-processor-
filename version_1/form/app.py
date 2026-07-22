import csv
import io
import os
import uuid

import boto3
import streamlit as st

from student import Student

FIELDNAMES = ["first_name", "last_name", "dob", "guardian_name",
              "guardian_email", "guardian_phone", "enrollment_date", "school_site"]

# Set this to the bucket Terraform creates. Kept as an env var so the app
# doesn't hardcode infra names that can change between environments.
BUCKET_NAME = os.environ.get("BUCKET_NAME", "REPLACE_WITH_YOUR_BUCKET_NAME")

s3_client = boto3.client("s3")


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


st.title("Student Enrollment Form")

with st.form("student_form", clear_on_submit=True):
    first_name = st.text_input("First name")
    last_name = st.text_input("Last name")
    dob = st.text_input("Date of birth (MM/DD/YYYY)")
    guardian_name = st.text_input("Guardian name")
    guardian_email = st.text_input("Guardian email")
    guardian_phone = st.text_input("Guardian phone (XXX-XXX-XXXX)")
    enrollment_date = st.text_input("Enrollment date (MM/DD/YYYY)")
    school_site = st.text_input("School site")

    submitted = st.form_submit_button("Submit")

if submitted:
    try:
        student = Student(
            first_name, last_name, dob, guardian_name,
            guardian_email, guardian_phone, enrollment_date, school_site
        )
    except ValueError as e:
        st.error(str(e))
    else:
        try:
            s3_key = upload_student_to_s3(student)
            st.success(f"Saved {student.first_name} {student.last_name}")
        except Exception as e:
            # No partial/local save - either the submission is fully in S3
            # or it doesn't exist anywhere. The guardian just has to retry.
            print(f"S3 upload failed for {student.first_name} {student.last_name}: {e}")
            st.error("Upload failed, please try again.")
