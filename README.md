# python-flask-docker
Итоговый проект курса "Машинное обучение в бизнесе"
Окулова Елена
"Early Biomarkers of Parkinson's Disease"

Стек:

ML: sklearn, pandas, numpy
API: flask
Данные: с kaggle - https://www.kaggle.com/ruslankl/early-biomarkers-of-parkinsons-disease

Задача: Предсказать вероятность нейродегенерации на основе речевых особенностей. Бинарная классификация. Для сбора данных используются 2 речевых теста.

Используемые признаки:

Age  (years)
Gender            
Entropy  of  speech  timing  (-)
Rate  of  speech  timing  (-/min)
Acceleration  of  speech  timing  (-/min2)
Duration  of  pause  intervals  (ms)
Duration  of  voiced  intervals  (ms)
Gaping  in-between  voiced  intervals  (-/min)
Duration  of  unvoiced  stops  (ms)
Decay  of  unvoiced  fricatives  (‰/min)
Relative  loudness  of  respiration  (dB)
Pause  intervals  per  respiration  (-)
Rate  of  speech  respiration  (-/min)
Latency  of  respiratory  exchange  (ms)
Entropy  of  speech  timing  (-) .1
Rate  of  speech  timing  (-/min) .1
Acceleration  of  speech  timing  (-/min2) .1
Duration  of  pause  intervals  (ms) .1
Duration  of  voiced  intervals  (ms) .1
Gaping  in-between  voiced  Intervals  (-/min)
Duration  of  unvoiced  stops  (ms) .1
Decay  of  unvoiced  fricatives  (‰/min) .1
Relative  loudness  of  respiration  (dB) .1
Pause  intervals  per  respiration  (-) .1
Rate  of  speech  respiration  (-/min) .1
Latency  of  respiratory  exchange  (ms) .1

Преобразования признаков: StandardScaler

Модель: CatBoost

### Клонируем репозиторий и создаем образ
```
$ git clone https://github.com/elenaokulova/study_projects/tree/
$ cd 
$ docker build -t 
```

### Запускаем контейнер

Здесь Вам нужно создать каталог локально и сохранить туда предобученную модель (<your_local_path_to_pretrained_models> нужно заменить на полный путь к этому каталогу)
```
$ docker run -d -p 8180:8180 -p 8181:8181 -v <your_local_path_to_pretrained_models>:/app/app/models 
```

### Переходим на localhost:8181
