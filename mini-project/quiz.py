from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# MySQL database connection details
db_config = {
    'user': 'root',
    'password': 'root',
    'host': 'localhost',
    'database': 'quizwa',
    'raise_on_warnings': True
     
}

# Function to get a database connection
def get_db_connection():
    connection = mysql.connector.connect(**db_config)
    return connection

# Signup route
@app.route('/', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        # Get form data
        username = request.form['username']
        password = request.form['password']

        # Insert user data into the 'users' table
        try:
            connection = get_db_connection()
            cursor = connection.cursor()

            insert_query = "INSERT INTO users (username, password) VALUES (%s, %s)"
            cursor.execute(insert_query, (username, password))
            connection.commit()

            cursor.close()
            connection.close()

            return redirect(url_for('login'))
        except Exception as e:
            return f'Error: {str(e)}'

    return render_template('signup.html')

# Login route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # Get form data
        username = request.form['username']
        password = request.form['password']

        # Check user credentials in the 'users' table
        try:
            connection = get_db_connection()
            cursor = connection.cursor()

            select_query = "SELECT * FROM users WHERE username = %s AND password = %s"
            cursor.execute(select_query, (username, password))
            user = cursor.fetchone()

            if user:
                # Set the user session
                session['username'] = user[1]
                return redirect(url_for('categories'))
            else:
                error = 'Invalid credentials. Please try again.'
                return render_template('login.html', error=error)

            cursor.close()
            connection.close()

        except Exception as e:
            return f'Error: {str(e)}'

    return render_template('login.html')

# Categories page route
@app.route('/categories', methods=['GET', 'POST'])
def categories():
    if request.method == 'POST':
        category_id = request.form['category_id']
        return redirect(url_for('quiz', category_id=category_id))

    # Retrieve the available quiz categories from the database
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM categories')
    categories = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('categories.html', categories=categories)


# Select Category route
@app.route('/select_category', methods=['POST'])
def select_category():
    category_id = request.form.get('category_id')

    # You can perform further processing based on the selected category ID
    # For example, you can store it in session or pass it to another route

    return redirect(url_for('quiz', category_id=category_id))


# Function to fetch a question and its options from the database
def get_question(question_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    select_query = "SELECT * FROM questions WHERE id = %s"
    cursor.execute(select_query, (question_id,))
    question = cursor.fetchone()

    if question:
        question_with_options = {
            'id': question[0],
            'category_id': question[1],
            'question_text': question[2],
            'options': [
                question[3],
                question[4],
                question[5],
                question[6]
            ],
            'correct_option': question[7]
        }

    conn.close()

    return question_with_options


# Quiz page route
@app.route('/quiz/<int:category_id>', methods=['GET', 'POST'])
def quiz(category_id):
    username = session.get('username')
    if not username:
        return redirect(url_for('login'))

    if request.method == 'POST':
        # Process the form submission
        selected_options = []
        for key, value in request.form.items():
            if key.startswith('question_'):
                question_id = int(key.split('_')[1])
                option_id = int(value)
                selected_options.append({'question_id': question_id, 'option_id': option_id})

        # Store the user's selected options in session
        session['selected_options'] = selected_options
        session['category_id'] = category_id

        return redirect(url_for('result'))
    else:
        # Display the quiz form
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if the category exists in the database
        cursor.execute('SELECT * FROM categories WHERE id = %s', (category_id,))
        category = cursor.fetchone()
        if not category:
            error = 'Category not found'
            cursor.close()  # Close the cursor before closing the connection
            conn.close()
            return render_template('error.html', error=error)

        # Retrieve the quiz questions for the selected category from the database
        cursor.execute('SELECT * FROM questions WHERE category_id = %s', (category_id,))
        questions = cursor.fetchall()
        cursor.close()
        conn.close()

        # Fetch question details from the database and attach them to each question
        question_list = []
        for question in questions:
            question_details = {
                'id': question[0],
                'category_id': question[1],
                'question_text': question[2],
                'options': [
                    question[3],
                    question[4],
                    question[5],
                    question[6]
                ],
                'correct_option': question[7]
            }
            question_list.append(question_details)

        return render_template('quiz.html', questions=question_list, category_id=category_id)


# Result page route
@app.route('/result', methods=['GET', 'POST'])
def result():
    username = session.get('username')
    if not username:
        return redirect(url_for('login'))

    # Retrieve the user's selected options from session
    selected_options = session.get('selected_options')
    if not selected_options:
        return redirect(url_for('categories'))  # Redirect the user if selected options are not found

    # Retrieve the user's information (e.g., name, email) from the database
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM users WHERE username = %s', (username,))
    user = cursor.fetchone()

    # Calculate the score and percentage
    correct_answers = 0
    user_responses = []

    for selected_option in selected_options:
        question_id = selected_option['question_id']
        option_id = selected_option['option_id']

        cursor.execute('SELECT correct_option FROM questions WHERE id = %s', (question_id,))
        _ = cursor.fetchall()  # Fetch and discard any unread results

        cursor.execute('SELECT correct_option FROM questions WHERE id = %s', (question_id,))
        correct_option = cursor.fetchone()[0]

        is_correct = option_id == correct_option
        if is_correct:
            correct_answers += 1

        user_responses.append((user[0], question_id, option_id, is_correct))

    total_questions = len(selected_options)
    percentage_score = (correct_answers / total_questions) * 100

    # Store the user's performance in the user_response table
    cursor.executemany('INSERT INTO user_response (user_id, question_id, selected_option, is_correct) '
                       'VALUES (%s, %s, %s, %s)', user_responses)
    conn.commit()

    cursor.close()  # Close the cursor before closing the connection
    conn.close()  # Close the connection after executing the queries

    quiz_result = {
        'correct_answers': correct_answers,
        'total_questions': total_questions,
        'percentage_score': round(percentage_score, 2)
    }

    return render_template('result.html', user=user, quiz_result=quiz_result)





# Logout route
@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)
