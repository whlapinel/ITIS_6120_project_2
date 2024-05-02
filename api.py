import MySQLdb
import sys
from getpass import getpass

print('Welcome to Patient Services. Please login.')
username = input('Username: ')
password = getpass('Password: ')

try:
  db = MySQLdb.connect(user=username, password=password, database="project_2")
  cursor = db.cursor()
except MySQLdb.Error:
  print('Error authenticating. Please try again.')
  sys.exit(0)

def make_appointment(date, patient, provider, facility, time):
  cursor = db.cursor()
  args = (date, patient, provider, facility, time)
  cursor.callproc("make_appt", args)
  result = cursor.fetchone()
  cursor.close()
  return result[0]

def record_visit(patient, provider, facility, date, time):
  cursor = db.cursor()
  args = (patient, provider, facility, date, time)
  cursor.callproc("record_visit", args)
  result = cursor.fetchone()
  cursor.close()
  return result[0]

def record_test_results(record, type, date, result):
  cursor = db.cursor()
  args = (record, type, date, result)
  cursor.callproc("record_test_results", args)
  result = cursor.fetchone()
  cursor.close()
  return result[0]

def create_patient(name, dob, address, gender, insurance, phone):
  cursor = db.cursor()
  args = (name, dob, address, gender, insurance, phone)
  cursor.callproc("create_patient", args)
  result = cursor.fetchone()
  cursor.close()
  return result[0]

def create_prescription(record, medication, dosage, instructions):
  cursor = db.cursor()
  args = (record, medication, dosage, instructions)
  cursor.callproc("create_prescription", args)
  result = cursor.fetchone()
  cursor.close()
  return result[0]

appointment = make_appointment('2012-04-04', 1, 1, 1, '10:00:00')
visit = record_visit(1, 1, 1, '2012-04-04', '10:00:00')
results = record_test_results(1, 'Vision', '2012-04-04', '20/20')
patient = create_patient('Bob Tester', '2012-04-04', '123 Test St', 'Male', 'Blue Cross', '5555555555')
prescription = create_prescription(1, 'Ibuprofen', '200', 'Take Daily')

print('Appointment: %s' % (appointment))
print('Visit: %s' % (visit))
print('Test Results: %s' % (results))
print('Patient: %s' % (patient))
print('Prescription: %s' % (prescription))
