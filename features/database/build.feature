Feature: Migrating and loading input data for the database

  Scenario: Migrating and loading database with artificial inputs
    Given an empty database without any tables
    And I copy the directory "../../data/testing" to "data"
    When in bash I run:
      """
      docker run \
        --env="PGUSER=${PGUSER}" \
        --env="PGDATABASE=${PGDATABASE}" \
        --env="PGPASSWORD=${PGPASSWORD}" \
        --env="PGHOST=${PGHOST}" \
        --env="PGPORT=${PGPORT}" \
        --volume=$(realpath data):/data:ro \
        --net=host \
        nucleotides-api \
        migrate
      """
    Then the stderr excluding logging info should not contain anything
    And the exit status should be 0
    And the following tables should not be empty:
      | name                   |
      | platform_type          |
      | protocol_type          |
      | extraction_method_type |
      | material_type          |
      | run_mode_type          |
      | file_type              |
      | metric_type            |
      | source_type            |
      | image_type             |
    And the table "biological_source" should include the entries:
      | name                   | source_type_id              |
      | source_1               | $source_type?name='microbe' |
      | bad_camel_case_source2 | $source_type?name='microbe' |
      | empty_file_set         | $source_type?name='microbe' |
      | no_input_files         | $source_type?name='microbe' |
    And the table "biological_source_reference_file" should include the entries:
      | biological_source_id                             | file_instance_id                           |
      | $biological_source?name='source_1'               | $file_instance?sha256='reference_1_digest' |
      | $biological_source?name='bad_camel_case_source2' | $file_instance?sha256='reference_2_digest' |
      | $biological_source?name='empty_file_set'         | $file_instance?sha256='reference_3_digest' |
      | $biological_source?name='no_input_files'         | $file_instance?sha256='reference_4_digest' |
    And the table "input_data_file_set" should contain "3" rows
    And the table "input_data_file_set" should include the entries:
      | name                  | biological_source_id                             |
      | data_set_1_data_1     | $biological_source?name='source_1'               |
      | data_set_2_data_1     | $biological_source?name='bad_camel_case_source2' |
      | no_input_files_data_1 | $biological_source?name='no_input_files'         |
    And the table "input_data_file" should contain "3" rows
    And the table "input_data_file" should include the entries:
      | file_instance_id                                                                         |
      | $file_instance?sha256='data_set_1_data_1_digest_1' |
      | $file_instance?sha256='data_set_1_data_1_digest_2' |
      | $file_instance?sha256='data_set_2_data_1_digest_1' |
    And the table "image_instance" should contain "4" rows
    And the table "image_instance" should include the entries:
      | name    | image_type_id             |
      | tiger   | $image_type?name='feline' |
      | grizzly | $image_type?name='ursine' |
      | collie  | $image_type?name='canine' |
      | polar   | $image_type?name='ursine' |
    And the table "image_version" should contain "5" rows
    And the table "image_version" should include the entries:
       | name | sha256           | image_instance_id              |
       | siberian | image_1_digest_1 | $image_instance?name='tiger'   |
       | bengal | image_1_digest_2 | $image_instance?name='tiger'   |
       | yosemite   | image_2_digest   | $image_instance?name='grizzly' |
       | shaggy   | image_3_digest   | $image_instance?name='collie'  |
       | arctic   | image_4_digest   | $image_instance?name='polar'   |
    And the table "image_task" should contain "6" rows
    And the table "image_task" should include the entries:
      | name         | image_version_id                         |
      | eat_cow      | $image_version?sha256='image_1_digest_1' |
      | eat_pig      | $image_version?sha256='image_1_digest_2' |
      | scare_hikers | $image_version?sha256='image_2_digest'   |
      | chase_sheep  | $image_version?sha256='image_3_digest'   |
      | sleep        | $image_version?sha256='image_3_digest'   |
      | eat_penguin  | $image_version?sha256='image_4_digest'   |
    And the table "benchmark_type" should contain "5" rows
    And the table "benchmark_type" should include the entries:
      | name           | product_image_type_id                 | evaluation_image_type_id              |
      | benchmark_1    | $image_type?name='feline'             | $image_type?name='canine'             |
      | benchmark_2    | $image_type?name='ursine'             | $image_type?name='canine'             |
      | no_data_sets   | $image_type?name='ursine'             | $image_type?name='canine'             |
      | no_images      | $image_type?name='non_existing_image' | $image_type?name='non_existing_image' |
      | no_input_files | $image_type?name='ursine'             | $image_type?name='canine'             |
    And the table "benchmark_data" should contain "4" rows
    And the table "benchmark_data" should include the entries:
      | benchmark_type_id                     | input_data_file_set_id                            |
      | $benchmark_type?name='benchmark_1'    | $input_data_file_set?name='data_set_1_data_1'     |
      | $benchmark_type?name='benchmark_2'    | $input_data_file_set?name='data_set_2_data_1'     |
      | $benchmark_type?name='no_images'      | $input_data_file_set?name='data_set_1_data_1'     |
      | $benchmark_type?name='no_input_files' | $input_data_file_set?name='no_input_files_data_1' |
    And the table "benchmark_instance" should contain "6" rows
    And the table "benchmark_instance" should include the entries:
      | benchmark_type_id                  | file_instance_id                                   | product_image_task_id           |
      | $benchmark_type?name='benchmark_1' | $file_instance?sha256='data_set_1_data_1_digest_1' | $image_task?name='eat_cow'      |
      | $benchmark_type?name='benchmark_1' | $file_instance?sha256='data_set_1_data_1_digest_1' | $image_task?name='eat_pig'      |
      | $benchmark_type?name='benchmark_1' | $file_instance?sha256='data_set_1_data_1_digest_2' | $image_task?name='eat_cow'      |
      | $benchmark_type?name='benchmark_1' | $file_instance?sha256='data_set_1_data_1_digest_2' | $image_task?name='eat_pig'      |
      | $benchmark_type?name='benchmark_2' | $file_instance?sha256='data_set_2_data_1_digest_1' | $image_task?name='scare_hikers' |
      | $benchmark_type?name='benchmark_2' | $file_instance?sha256='data_set_2_data_1_digest_1' | $image_task?name='eat_penguin'  |
    And the table "task" should contain "18" rows
    And the table "task" should include the entries:
      | task_type | benchmark_instance_id                                                                                                    |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/siberian/eat_cow source_1/data_set_1_data_1/data_set_1_data_1_digest_1' |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/siberian/eat_cow source_1/data_set_1_data_1/data_set_1_data_1_digest_1' |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_1'   |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_1'   |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_1'   |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_1'   |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/siberian/eat_cow source_1/data_set_1_data_1/data_set_1_data_1_digest_2' |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/siberian/eat_cow source_1/data_set_1_data_1/data_set_1_data_1_digest_2' |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_2'   |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_2'   |
      | produce   | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_2'   |
      | evaluate  | $benchmark_instance_name?name='benchmark_1 tiger/bengal/eat_pig source_1/data_set_1_data_1/data_set_1_data_1_digest_2'   |
    And the table "task" should include the entries:
      | task_type | image_task_id                   | benchmark_instance_id                                                                                                                         |
      | produce   | $image_task?name='scare_hikers' | $benchmark_instance_name?name='benchmark_2 grizzly/yosemite/scare_hikers bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1' |
      | evaluate  | $image_task?name='chase_sheep'  | $benchmark_instance_name?name='benchmark_2 grizzly/yosemite/scare_hikers bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1' |
      | evaluate  | $image_task?name='sleep'        | $benchmark_instance_name?name='benchmark_2 grizzly/yosemite/scare_hikers bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1' |
      | produce   | $image_task?name='eat_penguin'  | $benchmark_instance_name?name='benchmark_2 polar/arctic/eat_penguin bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1'      |
      | evaluate  | $image_task?name='chase_sheep'  | $benchmark_instance_name?name='benchmark_2 polar/arctic/eat_penguin bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1'      |
      | evaluate  | $image_task?name='sleep'        | $benchmark_instance_name?name='benchmark_2 polar/arctic/eat_penguin bad_camel_case_source2/data_set_2_data_1/data_set_2_data_1_digest_1'      |


  Scenario: Migrating and loading the database twice using real data and the RDS_* ENV variables
    Given an empty database without any tables
    And I copy the directory "../../tmp/prod_nucleotides_data" to "data"
    And in bash I successfully run:
      """
      docker run \
        --env="RDS_PORT=${PGPORT}" \
        --env="RDS_USERNAME=${PGUSER}" \
        --env="RDS_PASSWORD=${PGPASSWORD}" \
        --env="RDS_HOSTNAME=${PGHOST}" \
        --env="RDS_DB_NAME=${PGDATABASE}" \
        --volume=$(realpath data):/data:ro \
        --net=host \
        nucleotides-api \
        migrate
      """
    And in bash I run:
      """
      docker run \
        --env="RDS_PORT=${PGPORT}" \
        --env="RDS_USERNAME=${PGUSER}" \
        --env="RDS_PASSWORD=${PGPASSWORD}" \
        --env="RDS_HOSTNAME=${PGHOST}" \
        --env="RDS_DB_NAME=${PGDATABASE}" \
        --volume=$(realpath data):/data:ro \
        --net=host \
        nucleotides-api \
        migrate
      """
    Then the stderr excluding logging info should not contain anything
    And the exit status should be 0
