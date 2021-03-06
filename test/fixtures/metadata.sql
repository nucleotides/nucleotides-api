INSERT INTO file_type (name, description)
VALUES
	('container_log', 'Free form text output produced by the container being benchmarked'),
	('container_runtime_metrics', 'Runtime metrics collected while running the Docker container'),
	('short_read_fastq', 'Short read sequences in FASTQ format'),
	('reference_fasta', 'Reference sequence in FASTA format'),
	('contig_fasta', 'Reads assembled into larger contiguous sequences in FASTA format'),
	('assembly_metrics', 'Quast genome assembly metrics file');

INSERT INTO source_type (name, description)
VALUES
	('metagenome', 'A mixture of multiple genomes'),
	('microbe', 'A single isolated microbe');

INSERT INTO platform_type (name, description)
VALUES
	('miseq', 'Desc');

INSERT INTO protocol_type (name, description)
VALUES
	('unamplified_regular_fragment', 'Desc');

INSERT INTO material_type (name, description)
VALUES
	('dna', 'Desc');

INSERT INTO extraction_method_type (name, description)
VALUES
	('cultured_colony_isolate', 'Desc');

INSERT INTO run_mode_type (name, description)
VALUES
	('2x150_300', 'Desc');

INSERT INTO image_type (name, description)
VALUES
	('short_read_assembler', 'desc'),
	('short_read_preprocessor', 'desc'),
	('reference_assembly_evaluation', 'desc'),
	('short_read_preprocessing_reference_evaluation', 'desc') ;

INSERT INTO metric_type (name, description)
VALUES
	('ng50', 'desc'),
	('lg50', 'desc');
