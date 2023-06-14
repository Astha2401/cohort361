from flask import Flask, request, render_template

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def student_details():
    if request.method == 'POST':
        name = request.form['name']
        subject1 = int(request.form['subject1'])
        subject2 = int(request.form['subject2'])
        subject3 = int(request.form['subject3'])
        subject4 = int(request.form['subject4'])
        subject5 = int(request.form['subject5'])

        # Calculate the average marks
        average_marks = (subject1 + subject2 + subject3 + subject4 + subject5) / 5

        # Calculate the rank (assuming a simple ranking based on average marks)
        rank = calculate_rank(average_marks)  # You need to implement this function

        # Render the template with the student's details
        return render_template('student_details.html',
                               name=name,
                               subject1=subject1,
                               subject2=subject2,
                               subject3=subject3,
                               subject4=subject4,
                               subject5=subject5,
                               average_marks=average_marks,
                               rank=rank)
    else:
        return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
