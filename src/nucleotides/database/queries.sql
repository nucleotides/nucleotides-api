-- name: save-input-data-source<!
-- Creates a new input data source entry
INSERT INTO input_data_source (name, description, source_type_id)
SELECT :name, :description, (SELECT id FROM source_type WHERE name = :source_type)
WHERE NOT EXISTS (SELECT 1 FROM input_data_source WHERE name = :name);

-- name: save-input-data-source-file<!
-- Creates link between input_data_source and reference file_instance
WITH _existing_file AS (
  SELECT id FROM file_instance WHERE sha256 = :sha256
),
_new_file AS (
  INSERT INTO file_instance (file_type_id, sha256, url)
  SELECT (SELECT id FROM file_type WHERE name = :file_type), :sha256, :url
  WHERE NOT EXISTS (SELECT 1 FROM _existing_file)
  RETURNING id
),
_file AS (
  SELECT * FROM _existing_file
  UNION ALL
  SELECT * FROM _new_file
),
_input_data_source AS (
  SELECT * FROM input_data_source WHERE name = :source_name
)
INSERT INTO input_data_source_reference_file (input_data_source_id, file_instance_id)
SELECT (SELECT id FROM _input_data_source), (SELECT id FROM _file)
WHERE NOT EXISTS (
  SELECT 1
  FROM input_data_source_reference_file
  WHERE input_data_source_id = (SELECT id FROM _input_data_source)
  AND file_instance_id = (SELECT id FROM _file)
)

-- name: save-input-data-file-set<!
-- Creates a new input_data_file_set entry
INSERT INTO input_data_file_set (
  name,
  description,
  platform_type_id,
  product_type_id,
  protocol_type_id,
  run_mode_type_id,
  input_data_source_id)
 SELECT
  :name,
  :description,
  (SELECT id FROM platform_type WHERE name = :platform),
  (SELECT id FROM product_type WHERE name = :product),
  (SELECT id FROM protocol_type WHERE name = :protocol),
  (SELECT id FROM run_mode_type WHERE name = :run_mode),
  (SELECT id FROM input_data_source WHERE name = :input_data_source)
WHERE NOT EXISTS (SELECT id FROM input_data_file_set WHERE name = :name)

-- name: save-input-data-file<!
-- Creates link between 'input_data_file_set' and 'file_instance'
WITH _existing_file AS (
  SELECT id FROM file_instance WHERE sha256 = :sha256
),
_new_file AS (
  INSERT INTO file_instance (file_type_id, sha256, url)
  SELECT (SELECT id FROM file_type WHERE name = :file_type), :sha256, :url
  WHERE NOT EXISTS (SELECT 1 FROM _existing_file)
  RETURNING id
),
_file AS (
  SELECT * FROM _existing_file
  UNION ALL
  SELECT * FROM _new_file
),
_input_data_file_set AS (
  SELECT * FROM input_data_file_set WHERE name = :source_name
)
INSERT INTO input_data_file (input_data_file_set_id, file_instance_id)
SELECT (SELECT id FROM _input_data_file_set), (SELECT id FROM _file)
WHERE NOT EXISTS (
  SELECT 1
  FROM input_data_file
  WHERE input_data_file_set_id = (SELECT id FROM _input_data_file_set)
  AND file_instance_id = (SELECT id FROM _file)
)

-- name: save-image-instance<!
-- Creates a new Docker image instance entry
WITH _new_image_instance AS (
    INSERT INTO image_instance (name, sha256, image_type_id)
    SELECT
      :name,
      :sha256,
      (SELECT id FROM image_type WHERE name = :image_type)
    WHERE NOT EXISTS (SELECT id FROM image_instance WHERE name = :name)
    RETURNING id
),
_image_instance AS (
  SELECT id FROM image_instance WHERE name = :name
  UNION ALL
  SELECT * FROM _new_image_instance
)
INSERT INTO image_instance_task (task, image_instance_id)
SELECT :task, (SELECT id FROM _image_instance)
WHERE NOT EXISTS (
  SELECT id FROM image_instance_task
  WHERE task = :task
  AND image_instance_id = (SELECT id FROM _image_instance)
);

-- name: save-benchmark-type<!
-- Creates a new benchmark type entry
INSERT INTO benchmark_type (name, description, product_image_type_id, evaluation_image_type_id)
SELECT :name,
       :description,
	(SELECT id FROM image_type WHERE name = :product_image_type),
	(SELECT id FROM image_type WHERE name = :evaluation_image_type)
WHERE NOT EXISTS (SELECT 1 FROM benchmark_type WHERE name = :name);

-- name: save-benchmark-data<!
-- Creates a new benchmark type entry
WITH t AS (
  SELECT (SELECT id FROM input_data_file_set WHERE name = :input_data_file_set) AS f_id,
         (SELECT id FROM benchmark_type      WHERE name = :name) AS b_id
)
INSERT INTO benchmark_data (input_data_file_set_id, benchmark_type_id)
SELECT (SELECT f_id FROM t), (SELECT b_id FROM t)
WHERE NOT EXISTS (
	SELECT 1 FROM benchmark_data
	WHERE input_data_file_set_id = (SELECT f_id FROM t)
	AND benchmark_type_id        = (SELECT b_id FROM t))

-- name: populate-instance-and-task!
-- Populates benchmark instance table with combinations of data record and image task
DO $$
BEGIN
PERFORM populate_benchmark_instance();
PERFORM populate_task();
END$$
