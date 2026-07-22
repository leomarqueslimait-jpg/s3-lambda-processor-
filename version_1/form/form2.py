import csv
import re
from datetime import datetime
class Student:
    def __init__(self, first_name, last_name, dob, guardian_name, guardian_email, guardian_phone, enrollment_date, school_site):
        self.first_name = first_name
        self.last_name = last_name
        self.dob = dob
        self.guardian_name = guardian_name
        self.guardian_email = guardian_email
        self.guardian_phone = guardian_phone
        self.enrollment_date = enrollment_date
        self.school_site = school_site
      

    @property
    def first_name(self):
        return self._first_name
    
    @first_name.setter
    def first_name(self, first_name):
        
        try:
            assert re.search(r"^[A-Z][a-z]+$", first_name)
        
        except:

            raise ValueError("Invalid first name")
        self._first_name = first_name
        

    @property
    def last_name(self):
        return self._last_name
    
    @last_name.setter
    def last_name(self, last_name):
        try:
            assert re.search(r"^[A-Z][a-z]+$", last_name)     
        except:
            raise ValueError("Invalid last name")
             
        self._last_name = last_name

    @property
    def dob(self):
        return self._dob
    
    @dob.setter
    def dob(self, dob):
        try:
            datetime.strptime(dob, "%m/%d/%Y")
        except:
            raise ValueError("Invalid date format. Format should be MM/DD/YYYY")
        
        self._dob = dob
        
    @property
    def guardian_name(self):
        return self._guardian_name
    
    @guardian_name.setter
    def guardian_name(self, guardian_name):
        if not guardian_name:
            raise ValueError("Invalid Name")
        
        self._guardian_name = guardian_name

    @property
    def guardian_email(self):
        return self._guardian_email
    
    @guardian_email.setter
    def guardian_email(self, guardian_email):
        try:
            assert re.search(r"^\w+@(\w+\.)?\w+\.[a-z][a-z][a-z]$", guardian_email, re.IGNORECASE)
        except:
            raise ValueError("Invalid email format")
        
        self._guardian_email = guardian_email

    @property
    def guardian_phone(self):
        return self._guardian_phone

    @guardian_phone.setter
    def guardian_phone(self, guardian_phone):
        try:
            assert re.search(r"^\d{3}-\d{3}-\d{4}$", guardian_phone)
        except:
            raise ValueError("Invalid phone format. Format should be XXX-XXX-XXXX")
        self._guardian_phone = guardian_phone

    @property
    def enrollment_date(self):
        return self._enrollment_date

    @enrollment_date.setter
    def enrollment_date(self, enrollment_date):
        try:
            datetime.strptime(enrollment_date, "%m/%d/%Y")
        except ValueError:
            raise ValueError("Invalid date format. Format should be MM/DD/YYYY")
        self._enrollment_date = enrollment_date

    @property
    def school_site(self):
        return self._school_site

    @school_site.setter
    def school_site(self, school_site):
        if not school_site:
            raise ValueError("Invalid school site")
        self._school_site = school_site

    @classmethod
    def get(cls):
        first_name = input("What is your first name?: ")
        last_name = input("What is your last name?: ")
        dob = input("What is your date of birth? (MM/DD/YYYY): ")
        guardian_name = input("What is your guardian's name?: ")
        guardian_email = input("What is your guardian's email?: ")
        guardian_phone = input("What is your guardian's phone number? (XXX-XXX-XXXX): ")
        enrollment_date = input("What is the enrollment date? (MM/DD/YYYY): ")
        school_site = input("What is the school site?: ")
        return cls(first_name, last_name, dob, guardian_name, guardian_email, guardian_phone, enrollment_date, school_site)


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
