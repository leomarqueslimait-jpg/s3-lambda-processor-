import csv
import re
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
            assert re.search(r"[A-Z][a-z]+$", first_name)
        
        except:

            raise ValueError("Invalid first name")
        self._first_name = first_name
        

    @property
    def last_name(self):
        return self._last_name
    
    @last_name.setter
    def last_name(self, last_name):
        try:
            assert re.search(r"[A-Z][a-z]+$", last_name)     
        except:
            raise ValueError("Invalid last name")
             
        self._last_name = last_name

    @property
    def dob
        

    @classmethod
    def get(cls):
        first_name = input("What is your first name?: ")
        last_name = input("What is your last name?: ")
        return cls(first_name, last_name)


def main():
    student = Student.get()
    with open("student.csv", "a") as file:
            writer = csv.writer(file)
            writer.writerow([student.first_name, student.last_name, dob, guardian_name, guardian_email, guardian_phone, enrollment_date, school_site])


main()
