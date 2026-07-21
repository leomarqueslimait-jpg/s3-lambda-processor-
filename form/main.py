import csv
from student import Student

FIELDNAMES = ["first_name", "last_name", "dob", "guardian_name",
              "guardian_email", "guardian_phone", "enrollment_date", "school_site"]

def main():
    student = Student.get()
    file_exists = False
    try:
        with open("student.csv", "r"):
            file_exists = True
    except FileNotFoundError:
        pass

    with open("student.csv", "a", newline="") as file:
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
            "school_site": student.school_site
        })

if __name__ == "__main__":
    main()
