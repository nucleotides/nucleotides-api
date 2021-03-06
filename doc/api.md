# Nucleotid.es REST API

## /benchmarks/

The benchmark is the base unit of evaluation. Each benchmark consists of the
following:

  * Multiple input files, these contain the data used to benchmark the
    software.

  * A 'produce' biobox Docker image. This is the Docker image containing the
    software to be benchmarked.

  * Multiple 'evaluate' Docker images. These are Docker images that take the
    resulting data generated by the 'produce' Docker image and generate
    evaluation metrics. These metrics are used to describe how well the
    software performed. Each 'evaluate' image is run on the same result file
    created by the 'produce' task therefore multiple different sets of metrics
    can be generated.

  * Multiple output files, these contain the data generated by the 'produce'
    and 'evaluate' Docker image.

### GET /benchmarks/show.json

Returns a list of outstanding task IDs. These can be used to fetch the data
required to start a benchmarking task from `/tasks/:id`.

#### Resource URL

/benchmarks/show.json

#### Example response

~~~
[
    389,
    391,
    397,
    # Remaining list of task IDs omitted
]

### GET /benchmarks/:id

/benchmarks/:id

#### Example response

~~~
{

    "id": "eb1e930ffcc9bd728bc13d7d7be937f1",
    "type": "illumina_isolate_reference_assembly",
    "complete": true,
    "tasks": [
        {
            "events": [
                {
                    "id": 16,
                    "created_at": "2016-10-05 07:24:08.921565",
                    "success": true,
                    "task": 1,
                    "files": [
                        {
                            "url": "s3://nucleotides-prod/uploads/61/619d12880b29cda4dd13d5ba68bc746c628d5d3f56ef93eee6212035fdeff6d6",
                            "sha256": "619d12880b29cda4dd13d5ba68bc746c628d5d3f56ef93eee6212035fdeff6d6",
                            "type": "contig_fasta"
                        }
                        # ... other produced output files omitted
                    ],
                    "metrics": {
                        "total_read_io_in_mibibytes": 0.047,
                        "total_write_io_in_mibibytes": 0.0,
                        # ... Other generated metrics omitted
                    }
                }
            ],
            "type": "produce",
            "benchmark": "eb1e930ffcc9bd728bc13d7d7be937f1",
            "inputs": [
                {
                    "sha256": "5b0600e5c014fd54a85b245c55ab64ef2372c2ba34d89f6060429d5a044376e3",
                    "url": "s3://nucleotides-prod/inputs/5b/5b0600e5c014fd54a85b245c55ab64ef2372c2ba34d89f6060429d5a044376e3",
                    "type": "short_read_fastq"
                }
            ],
            "id": 1,
            "image": {
                "name": "bioboxes/velvet",
                "version": "1.2.0",
                "sha256": "6611675a6d3755515592aa71932bd4ea4c26bccad34fae7a3ec1198ddcccddad",
                "task": "default",
                "type": "short_read_assembler"
            },
            "complete": true
        },
        {
            "events": [
                {
                    "id": 707,
                    "created_at": "2016-10-05 17:45:23.841706",
                    "success": true,
                    "task": 2,
                    "files": [
                        {
                            "url": "s3://nucleotides-prod/uploads/6c/6ce7775731827c47e521c0743c40e26048659ba8e93d3e386bb2ccf62d3a7c83",
                            "sha256": "6ce7775731827c47e521c0743c40e26048659ba8e93d3e386bb2ccf62d3a7c83",
                            "type": "assembly_metrics"
                        },
                        # ... Remaining files omitted for brevity
                    ],
                    "metrics": {
                        "ng50": 22913.0,
                        "largest_contig": 109902.0,
                        # .. Remaining metrics omitted for brevity
                    }
                }
            ],
            "type": "evaluate",
            "benchmark": "eb1e930ffcc9bd728bc13d7d7be937f1",
            "inputs": [
                # .. Files omitted for brevity
            ],
            "id": 2,
            "image": {
                "name": "bioboxes/quast",
                "version": "4.2",
                "sha256": "5af634ee3f1bc3f80a749ce768883a20f793e1791f8f404a316d7d7012423cb9",
                "task": "default",
                "type": "reference_assembly_evaluation"
            },
            "complete": true
        }
    ]
}
~~~

### GET /results/complete

Lists the status for each image benchmark and returns all benchmark metrics for
the successfully completed benchmarks. A complete benchmark is where all
'produce' and 'evaluate' tasks have been completed all on available data for a
a given image task. If all 'produce' and 'evaluate' tasks have been completed
for image task X but some tasks are still outstanding or have failed for image
task Y, then only the metrics for image task X will be returned. JSON or CSV
formatted results are available.

#### Parameters

  * **?format=<csv|json>**

    **Optional**: An optional format to return the results in, can either be
    CSV where each row corresponds to a single metric, or JSON where the
    results are nested based on the input data hierarchy.

#### Example request

GET /results/complete?format=json









### GET /events/show/:id

2eturns a single event as JSON document.


#### Parameters

  * **id**

    **Required**: The unique ID of this event. This is the time stamp of this
    event in milliseconds since 00:00:00 Coordinated Universal Time (UTC). This
    is unique for this event. (Assuming no two events are created at exactly
    the same millisecond.)

#### Example request

GET http://api.nucleotides/0.2/events/show.json?id=1234

#### Example response

    {"id"                  : "243145735212777472",
     "created_at"          : "20150113T162702.420Z",
     "benchmark_id"        : "afd0...",
     "benchmark_type_code" : "0000",
     "state_code"          : "0000",
     "event_type_code"     : "0000"}



























## /events/

### POST /events/update

Add a new event to the database.

#### Resource URL

http://api.nucleotides/0.2/events/update

#### Parameters

  * **benchmark_id**

    **Required**: The benchmark's alphanumeric identifier. Each benchmark has a
    unique identifier created from a digest of its fields.

  * **benchmark_type_code**

    **Required**: The code identifying the type of benchmark. The list of
    possible benchmarks are defined in the [nucleotides benchmark list][bench].

  * **status_code**

    **Required**: The outcome code of the event. This may have one of the
    following values:

      * **0000**: This event completed successfully.

      * **0001**: This event failed to complete due to the container failing
        with an error.

      * **0002**: This event failed to complete due to the container finishing
        without error but not producing any data.

  * **event_type_code**

    **Required**: The code for the type of event. This can have the following
    values:

      * **0000**: Started testing container reference data set.

      * **0001**: Testing container has finished.

      * **0002**: Started evaluation container with testing container generated
        data.

      * **0003**: Evaluation container has finished.

  * **log_file_s3_url**

    **Optional**: The S3 url for a file containing a log of the event.

  * **log_file_digest**

    **Optional**: The SHA256 digest of the log file.

  * **event_file_s3_url**

    **Optional**: The S3 url for a file containing data specific to this event.

  * **event_file_digest**

    **Optional**: The SHA256 digest of the event file.

  * **cgroup_file_s3_url**

    **Optional**: The S3 url for a file containing cgroup metrics for this
    event.

  * **cgroup_file_digest**

    **Optional**: The SHA256 digest of the cgroup file.

#### Example request

POST http://api.nucleotides/0.2/events/update?benchmark_id=afd0&benchmark_type_code=0000&state_code=0000&event_type_code=0000

#### Example response

HTTP/1.1 201 Created
Date: Fri, 7 Oct 2005 17:17:11 GMT
Content-Length: nnn
Content-Type: text/plain;charset="utf-8"
Location: http://api.nucleotides/0.2/events/show.json?id=243145735212777472

243145735212777472



### GET /events/show/:id

2eturns a single event as JSON document.

#### Resource URL

http://api.nucleotides/0.2/events/show.json

#### Parameters

  * **id**

    **Required**: The unique ID of this event. This is the time stamp of this
    event in milliseconds since 00:00:00 Coordinated Universal Time (UTC). This
    is unique for this event. (Assuming no two events are created at exactly
    the same millisecond.)

#### Example request

GET http://api.nucleotides/0.2/events/show.json?id=1234

#### Example response

    {"id"                  : "243145735212777472",
     "created_at"          : "20150113T162702.420Z",
     "benchmark_id"        : "afd0...",
     "benchmark_type_code" : "0000",
     "state_code"          : "0000",
     "event_type_code"     : "0000"}



### GET /events/lookup

Returns a list of up to 100 events as a JSON document.

#### Resource URL

http://api.nucleotides/0.2/events/show.json

#### Parameters

  * **benchmark_id**

    **Optional**: A comma separated list of benchmark IDs. Returns a list of
    all the events related to these benchmarks.

  * **max_id**:

    **Optional**: The event ID, inclusive, to end pagination of the events
    list. Used to fetch multiple pages of events in separate requests.

  * **benchmark_type_id**:

    **Optional**: The code identifying the type of benchmark. Selects for only
    the events for this kind of benchmark.

  * **state_code**:

    **Optional**: A comma separated list of state_codes. Limit the returned
    events to this code.

  * **event_type_code**:

    **Optional**: Limit the returned events to this type.

#### Example request

GET http://api.nucleotides/0.2/events/lookup.json?benchmark_id=a8f3&max_id=1234

[bench]: https://github.com/nucleotides/nucleotides-data/blob/master/data/benchmark_type.yml
