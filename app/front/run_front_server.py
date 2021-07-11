import json

from flask import Flask, render_template, redirect, url_for, request
from flask_wtf import FlaskForm
from requests.exceptions import ConnectionError
from wtforms import IntegerField, SelectField, StringField
from wtforms.validators import DataRequired

import urllib.request
import json

from app.processing import DataPreprocessing

preprocessor = DataPreprocessing()
fields = preprocessor.NUM_FEATURES

class ClientDataForm(FlaskForm):
    # description = StringField('Job Description', validators=[DataRequired()])
    # company_profile = StringField('Company Profile', validators=[DataRequired()])
    # benefits = StringField('Benefits', validators=[DataRequired()])
    pass



app = Flask(__name__)
app.config.update(
    CSRF_ENABLED=True,
    SECRET_KEY='you-will-never-guess',
)

# добавляем поля в класс формы
for i, attr in enumerate(fields):
    name = f'field{i}'
    setattr(ClientDataForm, name, StringField(attr, default=1, validators=[DataRequired()]))


def get_prediction(*args):
    body = {}
    for i, value in enumerate(args[0]):
        name = fields[i]
        body[name] = [value]


    myurl = "http://localhost:8180/predict"
    req = urllib.request.Request(myurl)
    req.add_header('Content-Type', 'application/json; charset=utf-8')
    jsondata = json.dumps(body)
    jsondataasbytes = jsondata.encode('utf-8')  # needs to be bytes
    req.add_header('Content-Length', len(jsondataasbytes))
    # print (jsondataasbytes)
    response = urllib.request.urlopen(req, jsondataasbytes)
    return json.loads(response.read())['predictions']


@app.route("/")
def index():
    return render_template('index.html')


@app.route('/predicted/<response>')
def predicted(response):
    response = json.loads(response)
    print(response)
    return render_template('predicted.html', response=response)


@app.route('/predict_form', methods=['GET', 'POST'])
def predict_form():
    form = ClientDataForm()
    data = dict()
    if request.method == 'POST':
        for i in range(len(fields)):
            name = f'field{i}'
            data[name] = request.form.get(name)

        try:
            response = str(get_prediction(data.values()))
            print(response)
        except ConnectionError:
            response = json.dumps({"error": "ConnectionError"})
        return redirect(url_for('predicted', response=response))
    return render_template('form.html', form=form)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8181, debug=True)
