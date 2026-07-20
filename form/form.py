import csv

def user_input():

    first_name = input("What is your first name?: ")
    last_name = input("What is your last name?: ")
    dob = input("What is your date of birth?: ")
    grade_level = input("student's grade level: ")
    guardian_name = input("Primary guardian name: ")
    guardian_email = input("Primary guardian naemail: ")
    guardian_phone = input("Primary guardian phone number: ")
    enrollment_date = input("Enrollment date: ")
    school_site = input("School name: ")

    with open("student.csv", "a") as file:
        writer = csv.writer(file)
        writer.writerow([first_name, last_name, dob, guardian_name, guardian_email, guardian_phone, enrollment_date, school_site])

