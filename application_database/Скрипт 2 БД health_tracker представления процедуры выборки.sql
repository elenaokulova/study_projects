-- Для корректного просмотра всех функций можно запустить сначала весь этот скрипт.
-- Здесь представлены образцы функций, процедур, представлений и возможных запросов.

SET @var_user_id = 11;



-- Функция расчета индекса массы тела

DROP FUNCTION IF EXISTS func_body_mass_index;

DELIMITER //

CREATE FUNCTION func_body_mass_index(check_user_id INT)
RETURNS FLOAT READS SQL DATA
 BEGIN
	DECLARE user_weight FLOAT;
	DECLARE user_height FLOAT;
	DECLARE index_result FLOAT;

	SET user_weight = (
		SELECT weight FROM profiles
		WHERE user_id = check_user_id
	);
		
	SET user_height = (
		(SELECT height FROM profiles 
		WHERE user_id = check_user_id) / 100
	);
	
	SET index_result = (
		ROUND((user_weight / POW(user_height, 2)), 2)
	);
	
	RETURN index_result;
	
 END //

DELIMITER ;


SELECT func_body_mass_index(1);


-- Функция для расчета дистанции по результатам пройденных шагов

DROP FUNCTION IF EXISTS func_steps_distance;

DELIMITER //

CREATE FUNCTION func_steps_distance(steps MEDIUMINT)
RETURNS MEDIUMINT READS SQL DATA
 BEGIN
	
	DECLARE distance_result MEDIUMINT;	
	SET distance_result = steps * 0.75;	
	RETURN distance_result;
	
 END //

DELIMITER ;


SELECT func_steps_distance(10536);




-- Функция для расчета потраченных калорий по результатам пройденных шагов

DROP FUNCTION IF EXISTS func_steps_calories;

DELIMITER //

CREATE FUNCTION func_steps_calories(steps MEDIUMINT)
RETURNS MEDIUMINT READS SQL DATA
 BEGIN
	
	DECLARE calories_result MEDIUMINT;	
	SET calories_result = steps * 0.05;	
	RETURN calories_result;
	
 END //

DELIMITER ;


SELECT func_steps_calories(10536);




-- Процедура внесения нового пользователя в базу

DROP PROCEDURE IF EXISTS insert_new_user;

DELIMITER //

CREATE PROCEDURE insert_new_user(
	new_firstname VARCHAR(50), 
	new_lastname VARCHAR(50), 
	new_email  VARCHAR(120), 
	new_password_hash VARCHAR(100), 
	new_phone  BIGINT UNSIGNED,
	new_gender CHAR,
	new_birthday DATE,
	new_height TINYINT UNSIGNED,
	new_weight DECIMAL(4,1),
	new_hometown VARCHAR(100)
	)
 BEGIN
	 
	START TRANSACTION;
	
	INSERT INTO users (firstname, lastname, email, password_hash, phone) VALUES
	 (new_firstname, new_lastname, new_email, new_password_hash, new_phone);

	SELECT @last_user_id := last_insert_id();
	
	INSERT INTO profiles (user_id, gender, birthday, height, weight, hometown) VALUES
	 (@last_user_id, new_gender, new_birthday, new_height, new_weight, new_hometown);
	
	INSERT INTO total_data (user_id, total_steps, total_distance, total_calories) VALUES
	 (@last_user_id, 0, 0, 0);
	
	INSERT INTO weight_trackers (user_id, tracked_at, weight)
	 VALUES (@last_user_id,  NOW(), new_weight);
	
	COMMIT;	 	
	
 END //
 
DELIMITER ;


CALL insert_new_user('Максим', 'Поташёв', 'potashevmax@gmail.com', 'ivvmqaab7r', '9215725919', 'м', '1969-09-13', 185, 83.5, 'Москва');




-- Процедура внесения данных о текущем весе в трекер веса пользователя 

DROP PROCEDURE IF EXISTS insert_weight_data;

DELIMITER //

CREATE PROCEDURE insert_weight_data(check_user_id INT, user_weight FLOAT)
 BEGIN		 
	 
	 INSERT INTO weight_trackers (user_id, tracked_at, weight)
	 VALUES (check_user_id,  NOW(),  user_weight);	 
	 
	 UPDATE profiles 
	 SET weight = user_weight WHERE user_id = check_user_id;
	 
 END //
 
DELIMITER ;


CALL insert_weight_data(@var_user_id, 90.5);




-- Процедура внесения данных о пройденных шагах в трекер шагов пользователя

DROP PROCEDURE IF EXISTS insert_steps_data;

DELIMITER //

CREATE PROCEDURE insert_steps_data(check_user_id INT, user_steps MEDIUMINT)
 BEGIN		 
	 
	 INSERT INTO step_trackers (user_id, tracked_at, steps_number, distance, calories)
	 VALUES (check_user_id,  NOW(), user_steps, (SELECT func_steps_distance(user_steps)), (SELECT func_steps_calories(user_steps)));		 
	 
 END //
 
DELIMITER ;


CALL insert_steps_data(@var_user_id, 11255);




-- Процедура обновления таблицы total_data. 
-- Производится по запросу пользователя, когда он хочет посмотреть свои общие показатели

DROP PROCEDURE IF EXISTS update_total_data;

DELIMITER //

CREATE PROCEDURE update_total_data(check_user_id INT)
 BEGIN
	DECLARE sum_distance_steps BIGINT;
	DECLARE sum_distance_workouts BIGINT;
	DECLARE sum_calories_steps BIGINT;
	DECLARE sum_calories_workouts BIGINT;
	
	SET sum_distance_steps = (
		SELECT SUM(distance) 
		FROM step_trackers 
		WHERE user_id = check_user_id
		);
	
	SET sum_distance_workouts = (
		SELECT SUM(distance) 
		FROM workouts 
		WHERE user_id = check_user_id
		);
		
	SET sum_calories_steps = (
		SELECT SUM(calories) 
		FROM step_trackers 
		WHERE user_id = check_user_id
		);
	
	SET sum_calories_workouts = (
		SELECT SUM(calories) 
		FROM workouts 
		WHERE user_id = check_user_id
		);
	
	IF sum_distance_steps IS NULL THEN
		SET sum_distance_steps = 0;
	END IF;
	IF sum_distance_workouts IS NULL THEN
		SET sum_distance_workouts = 0;
	END IF;
	IF sum_calories_steps IS NULL THEN
		SET sum_calories_steps = 0;
	END IF;
	IF sum_calories_workouts IS NULL THEN
		SET sum_calories_workouts = 0;
	END IF;
	
	UPDATE total_data 
	 SET update_at = NOW(),
	 total_steps = (SELECT SUM(steps_number) FROM step_trackers WHERE user_id = check_user_id),
	 total_distance = sum_distance_steps + sum_distance_workouts,	 				  
	 total_calories = sum_calories_steps + sum_calories_workouts,
	 body_mass_index = (SELECT func_body_mass_index(check_user_id))	 
	 WHERE user_id = check_user_id;	 
 END //
 
DELIMITER ;

CALL update_total_data(1);
CALL update_total_data(2);
CALL update_total_data(3);
CALL update_total_data(4);
CALL update_total_data(5);
CALL update_total_data(6);
CALL update_total_data(7);
CALL update_total_data(8);
CALL update_total_data(9);
CALL update_total_data(10);
CALL update_total_data(11);





-- Представление для вывода актуальных рекомендаций по состоянию здоровья пользователя

CREATE OR REPLACE VIEW view_user_state
AS
SELECT user_id, name, recomendations 
FROM current_health_states 
JOIN health_states 
WHERE current_health_states.health_states_id = health_states.id
ORDER BY user_id;


SELECT * FROM view_user_state;




-- Представление выводит данные пользователя, у которого сегодня день рождения

CREATE OR REPLACE VIEW view_todays_birthdays
AS
SELECT id, firstname, lastname, email, phone
FROM users
JOIN
profiles
ON profiles.user_id = users.id
WHERE DATE_FORMAT(birthday, '%m %d') = DATE_FORMAT(NOW(), '%m %d');


SELECT * FROM view_todays_birthdays;



-- Запрос на просмотр веса за определенную дату (или наиболее актуальные на тот момент данные к ней) у выбранного пользователя

SELECT user_id, tracked_at, weight 
FROM weight_trackers
WHERE tracked_at <= '2019-09-30' AND user_id = 1
ORDER BY tracked_at DESC LIMIT 1;




--  Запрос на просмотр количества шагов и общую пройденную дистанцию за определенный период

SELECT user_id, SUM(steps_number) AS total_steps, SUM(distance) AS total_distance
FROM step_trackers
WHERE tracked_at 
BETWEEN '2019-01-01' AND '2019-09-30' 
AND user_id = 1;



-- Запрос на просмотр текущего веса (последние обновленные данные), индекса массы тела, состояния здоровья и советов

SELECT view_user_state.user_id, weight, body_mass_index, name, recomendations
FROM
profiles
JOIN
total_data
JOIN
view_user_state
ON profiles.user_id = total_data.user_id AND profiles.user_id = view_user_state.user_id
WHERE profiles.user_id = 1;



-- Запрос на просмотр сегодняшних показателей активности пользователя: 
-- количество шагов, пройденная дистанция, число тренировок, общее время тренировок, количество выпитой воды, общее время сна.

-- Вносим данные для проверки

INSERT INTO `workouts` (user_id, workout_types_id, total_time, distance, calories) VALUES 
(@var_user_id,'1','01:15:53',5350, 230),
(@var_user_id,'2','01:46:43',7200, 315);

INSERT INTO `water_trackers` (user_id, water_amount) VALUES 
(@var_user_id,'1.25');

INSERT INTO `sleep_trackers` (user_id, fell_asleep, woke_up, total_sleep_time) VALUES 
(@var_user_id, '01:49:13', '07:50:17', '06:01:04');


SELECT 
st.user_id, 
steps_number, 
st.distance,

(SELECT COUNT(*) 
FROM workouts 
WHERE user_id = @var_user_id 
 AND 
 DATE_FORMAT(tracked_at, '%Y %m %d') = DATE_FORMAT(NOW(), '%Y %m %d')
) AS workouts_number,

(SELECT SEC_TO_TIME(SUM(TIME_TO_SEC(total_time))) 
	FROM workouts 
	WHERE user_id = @var_user_id 
	AND 
	(DATE_FORMAT(tracked_at, '%Y %m %d') = DATE_FORMAT(NOW(), '%Y %m %d'))) AS total_workout_time,
	
water_amount, 
total_sleep_time

FROM 
step_trackers st
JOIN
workouts w 
JOIN
water_trackers wt 
JOIN
sleep_trackers st2 
ON 
st.user_id = w.user_id AND
st.user_id = wt.user_id AND
st.user_id = st2.user_id 

WHERE st.user_id = @var_user_id AND DATE_FORMAT(st.tracked_at, '%Y %m %d') = DATE_FORMAT(NOW(), '%Y %m %d')
GROUP BY user_id;

