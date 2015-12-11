Feature: Posting and getting tasks from the API

  Scenario: Listing all tasks for an incomplete benchmark
    Given the database scenario with "a single incomplete task"
    When I get the url "/tasks/show.json"
    Then the returned HTTP status code should be "200"
    And the returned body should be a valid JSON document
    And the returned JSON should contain the entries:
      | image_name      | image_sha256 | image_task | input_url | input_md5 | task_type | image_type           |
      | bioboxes/velvet | 123abc       | default    | s3://url  | abcdef    | produce   | short_read_assembler |

  Scenario Outline: Completing an event for a task
    Given the database scenario with "a single incomplete task"
    When I post to "/events" with the data:
      """
      { "task"          : 1,
        "log_file_url"  : "s3://url",
        "success"       : <state>
        <file> }
      """
    Then the returned HTTP status code should be "201"

    Examples:
      | state | file                                          |
      | true  | , "file_url" : "s3://url", "file_md5" : "123" |
      | false |                                               |
      | false | , "file_url" : null                           |

  Scenario: Listing all tasks for a product-completed benchmark
    Given the database scenario with "a single incomplete task"
    And I successfully post to "/events" with the data:
      """
      { "task"          : 1,
        "log_file_url"  : "log_url",
        "file_url"      : "product_url",
        "file_md5"      : "123",
        "success"       : true }
      """
    And I successfully post to "/events" with the data:
      """
      { "task"          : 2,
        "log_file_url"  : "log_url",
        "file_url"      : "eval_url",
        "file_md5"      : "123",
        "success"       : true }
      """
    When I get the url "/tasks/show.json"
    Then the returned HTTP status code should be "200"
    And the returned body should be a valid JSON document
    And the returned JSON should be empty
