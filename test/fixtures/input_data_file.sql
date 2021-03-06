INSERT INTO "file_instance" ("file_type_id","sha256","url")
VALUES ((SELECT file_type_id FROM file_type WHERE name = 'short_read_fastq'), '7673a', 's3://reads'),
       ((SELECT file_type_id FROM file_type WHERE name = 'short_read_fastq'), 'c1f0f', 's3://reads');
--;
INSERT INTO "input_data_file" ("input_data_file_set_id", "file_instance_id")
VALUES ((SELECT input_data_file_set_id FROM input_data_file_set WHERE name   = 'regular_fragment_1' LIMIT 1),
        (SELECT file_instance_id       FROM file_instance       WHERE sha256 = '7673a')),
       ((SELECT input_data_file_set_id FROM input_data_file_set WHERE name   = 'regular_fragment_1' LIMIT 1),
        (SELECT file_instance_id       FROM file_instance       WHERE sha256 = 'c1f0f'));
