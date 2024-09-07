-- 1 Verificando se existe duplicatas...
with duplicatas as (
	select *, 
	row_number() over(partition by [Activity Type],[Date],Title,Distance,Calories,[Avg HR],[Max HR],[Avg Run Cadence],[Max Run Cadence],[Avg Pace],[Best Pace],[Elev Gain],[Elev Loss],[Avg Stride Length],[Best Lap Time],[Number of Laps] order by [Activity Type],[Date],Title,Distance,Calories,[Avg HR],[Max HR],[Avg Run Cadence],[Max Run Cadence],[Avg Pace],[Best Pace],[Elev Gain],[Elev Loss],[Avg Stride Length],[Best Lap Time],[Number of Laps]) as row_num
	from activity_log
)
select *
from duplicatas
where row_num > 1;

select *
from activity_log;

-- 2: Padronizando os dados...

--os dados da consulta abaixo estão embaralhados...
select *
from activity_log
where [Number of Laps] like '%,%'

--Criando uma cópia, para nao bagunçar com a tabela principal...
SELECT *
INTO new_activity_log
FROM activity_log;

-- Separando o conjunto de dados defeituoso pra tratar
select *
into tratamento
from new_activity_log
where [Number of Laps] like '%,%'


select * from tratamento;

-- Jutando os dados de calorias na mesma coluna
UPDATE tratamento
SET Calories = ISNULL(Calories, '') + ISNULL("Time", '') 
where "Time" like '%"'

-- Abaixo copiando os dados de uma coluna para outra...
UPDATE tratamento
SET "Time" = [Avg HR]
where "Time" like '%"'

UPDATE tratamento
SET "Avg HR"="Max HR"
where Calories like '"%"'

UPDATE tratamento
SET "Max HR"="Avg Run Cadence"
where Calories like '"%"'

UPDATE tratamento
SET [Avg Run Cadence]=[Max Run Cadence]
where Calories like '"%"'

UPDATE tratamento
SET "Max Run Cadence"="Avg Pace"
where Calories like '"%"'


UPDATE tratamento
SET "Avg Pace"="Best Pace"
where Calories like '"%"'

select * from tratamento;

UPDATE tratamento
SET "Best Pace"="Elev Gain"
where Calories like '"%"'

UPDATE tratamento
SET "Elev Gain"="Elev Loss"
where Calories like '"%"'

UPDATE tratamento
SET "Elev Loss"="Avg Stride Length"
where Calories like '"%"'

UPDATE tratamento
SET "Avg Stride Length"="Best Lap Time"
where Calories like '"%"'

select * from tratamento

--A última coluna ta com dois valores...
-- Pegando o valor antes da virgula

UPDATE tratamento
SET "Best Lap Time"=SUBSTRING("Number of Laps", 1, CHARINDEX(',', "Number of Laps") - 1)
where Calories like '"%"'

--Pegando o valor após a virgula somente, que é o numero de voltas
UPDATE tratamento
SET "Number of Laps" = SUBSTRING("Number of Laps", CHARINDEX(',', "Number of Laps")+1, LEN("Number of Laps"))
where Calories like '"%"'


select *
from tratamento
where Calories like '"%"'


-- A última coluna também tinha 3 valores em algumas linhas
select * from tratamento where [Number of Laps] like '%,%,%'

--Juntando os dados de Elev Gain
UPDATE tratamento
SET "Elev Gain" = ISNULL("Elev Gain", '') + ISNULL("Elev Loss", '') 
where [Number of Laps] like '%,%,%'

-- Juntando os dados de Elev Loss
UPDATE tratamento
SET "Elev Loss" = ISNULL("Avg Stride Length", '') + ISNULL("Best Lap Time", '') 
where [Number of Laps] like '%,%,%'


select * from tratamento where [Number of Laps] like '%,%,%'

-- Pegando o primeiro dos 3 dados da última coluna
UPDATE tratamento
SET "Avg Stride Length" = SUBSTRING("Number of Laps", 1, CHARINDEX(',', "Number of Laps") - 1)
where [Number of Laps] like '%,%,%'

-- Pegando o segundo dos 3 dados da última coluna
UPDATE tratamento
SET "Best Lap Time" = SUBSTRING("Number of Laps", CHARINDEX(',', "Number of Laps") + 1, CHARINDEX(',', "Number of Laps", CHARINDEX(',', "Number of Laps") + 1) - CHARINDEX(',', "Number of Laps") - 1)
where [Number of Laps] like '%,%,%'

-- Pegando o último dos 3 dados da última coluna
UPDATE tratamento
SET [Number of Laps] =SUBSTRING([Number of Laps], 
                 LEN([Number of Laps]) - CHARINDEX(',', REVERSE([Number of Laps])) + 2, 
                 LEN([Number of Laps]))
where [Number of Laps] like '%,%,%'


select * from tratamento where [Number of Laps] like '%,%'

--Arrumando esse dado único.
UPDATE tratamento
SET 
    "Elev Gain" = '1000',
    "Elev Loss" = '991',
    "Avg Stride Length" = '1.28',
    "Best Lap Time" = '00:00.0',
	"Number of Laps" = '17'
WHERE [Number of Laps] LIKE '%,%';

SELECT * FROM TRATAMENTO;

--deletando os dados sujo da tabela...
delete
from new_activity_log
where [Number of Laps] like '%,%'

--Colocando os dados limpos da tabela..
INSERT INTO new_activity_log
SELECT * FROM tratamento;

-- Tirando as aspas dos números de calorias
update new_activity_log
Set Calories = REPLACE(Calories, '"', '') 
where Calories like '"%"'

select * from new_activity_log where Calories like '"%"'

select * from tratamento where "Elev Gain" like '"%"'

-- Tirando as aspas dos números de Elev Gain
update new_activity_log
Set "Elev Gain" = REPLACE("Elev Gain", '"', '') 
where "Elev Gain" like '"%"'

update new_activity_log
Set [Elev Loss] = REPLACE([Elev Loss], '"', '') 
where [Elev Loss] like '"%"'

select * from new_activity_log




