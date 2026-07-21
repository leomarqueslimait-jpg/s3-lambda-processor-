import csv
import os
 
import streamlit as st
 
from student import Student
 
CSV_PATH = "student.csv"
FIELDNAMES = ["first_name", "last_name", "dob", "guardian_name",
              "guardian_email", "guardian_phone", "enrollment_date", "school_site"]
 
 
def save_student(student):
    file_exists = os.path.exists(CSV_PATH)
    with open(CSV_PATH, "a", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        if not file_exists:
            writer.writeheader()
        writer.writerow({
            "first_name": student.first_name,
            "last_name": student.last_name,
            "dob": student.dob,
            "guardian_name": student.guardian_name,
            "guardian_email": student.guardian_email,
            "guardian_phone": student.guardian_phone,
            "enrollment_date": student.enrollment_date,
            "school_site": student.school_site,
        })
 
 
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
        save_student(student)
        st.success(f"Saved {student.first_name} {student.last_name} to {CSV_PATH}")
    except ValueError as e:
        st.error(str(e))
 
if os.path.exists(CSV_PATH):
    st.subheader("Current records")
    with open(CSV_PATH, newline="") as file:
        rows = list(csv.reader(file))
    st.table(rows)