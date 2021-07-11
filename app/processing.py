from sklearn.preprocessing import StandardScaler


class DataPreprocessing:
    """Подготовка исходных данных"""

    def __init__(self):
        """Параметры класса"""

        self.x_copy = None
        self.scaler = StandardScaler()
        self.NUM_FEATURES = [
            ' Age  (years) ',
            'Gender',
            ' Entropy  of  speech  timing  (-) ',
            ' Rate  of  speech  timing  (-/min) ',
            ' Acceleration  of  speech  timing  (-/min2) ',
            ' Duration  of  pause  intervals  (ms) ',
            ' Duration  of  voiced  intervals  (ms) ',
            ' Gaping  in-between  voiced  intervals  (-/min) ',
            ' Duration  of  unvoiced  stops  (ms) ',
            ' Decay  of  unvoiced  fricatives  (‰/min) ',
            ' Relative  loudness  of  respiration  (dB) ',
            ' Pause  intervals  per  respiration  (-) ',
            ' Rate  of  speech  respiration  (-/min) ',
            ' Latency  of  respiratory  exchange  (ms) ',
            ' Entropy  of  speech  timing  (-) .1',
            ' Rate  of  speech  timing  (-/min) .1',
            ' Acceleration  of  speech  timing  (-/min2) .1',
            ' Duration  of  pause  intervals  (ms) .1',
            ' Duration  of  voiced  intervals  (ms) .1',
            ' Gaping  in-between  voiced  Intervals  (-/min) ',
            ' Duration  of  unvoiced  stops  (ms) .1',
            ' Decay  of  unvoiced  fricatives  (‰/min) .1',
            ' Relative  loudness  of  respiration  (dB) .1',
            ' Pause  intervals  per  respiration  (-) .1',
            ' Rate  of  speech  respiration  (-/min) .1',
            ' Latency  of  respiratory  exchange  (ms) .1',
        ]

    def transform(self, X):
        """Трансформация данных"""

        X = X.copy()

        X.loc[(X['Gender'] == 'M'), 'Gender'] = 1
        X.loc[(X['Gender'] == 'F'), 'Gender'] = 0
        X['Gender'] = X['Gender'].astype('int')

        for i in self.NUM_FEATURES:
            if i != ' Age  (years) ' and i != 'Gender':
                X[i] = self.scaler.fit_transform(X[[i]])

        return X

if __name__=='__main__':
    pass
