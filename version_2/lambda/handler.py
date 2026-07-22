import csv
import hashlib
import io
import os

import boto3

from student import Student

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def make_student_id(student):
    """Deterministic ID derived from every field, so re-uploading an
    unchanged row overwrites the same DynamoDB item instead of creating a
    duplicate. Changing ANY field (including a corrected typo) produces a
    new ID and therefore a new item - see the tradeoff discussed earlier."""
    raw = "|".join([
        student.first_name,
        student.last_name,
        student.dob,
        student.guardian_name,
        student.guardian_email,
        student.guardian_phone,
        student.enrollment_date,
        student.school_site,
    ])
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()

"""
lambda is associating event values with the csv file uploaded
of a single student
"""
def lambda_handler(event, context):
    results = {"success": 0, "errors": []}

    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        response = s3.get_object(Bucket=bucket, Key=key)
        csv_content = response["Body"].read().decode("utf-8")
        reader = csv.DictReader(io.StringIO(csv_content))

        for row in reader:
            try:
                student = Student(
                    row["first_name"],
                    row["last_name"],
                    row["dob"],
                    row["guardian_name"],
                    row["guardian_email"],
                    row["guardian_phone"],
                    row["enrollment_date"],
                    row["school_site"],
                )
            except ValueError as e:
                # Bad data (e.g. malformed DOB) - skip this row so one bad
                # submission doesn't crash the whole invocation. Logged here
                # for now; route to a quarantine location later.
                #
                # NOTE: the API Lambda already rejects invalid data before it
                # ever uploads to S3, using this same Student class - so
                # today, a bad row reaching this Lambda shouldn't happen.
                # Keeping this check anyway because that guarantee only holds
                # while the API Lambda is the ONLY producer writing to this
                # bucket and stays in sync with student.py. If a bulk import,
                # manual re-upload (e.g. from a future quarantine fix), or a
                # version drift ever happens, this becomes a live path again.
                # Don't remove this thinking it's dead code - it's a safety
                # net, not the primary filter.
                results["errors"].append({"key": key, "row": row, "error": str(e)})
                continue

            item = student.to_dict()
            item["student_id"] = make_student_id(student)

            try:
                table.put_item(Item=item)
                results["success"] += 1
            except Exception as e:
                results["errors"].append({"key": key, "row": row, "error": str(e)})

    print(f"Processed: {results['success']} succeeded, {len(results['errors'])} failed")
    if results["errors"]:
        print(results["errors"])

    return results
