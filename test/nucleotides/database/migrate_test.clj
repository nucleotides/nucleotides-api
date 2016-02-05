(ns nucleotides.database.migrate-test
  (:require [clojure.test     :refer :all]
            [helper.fixture   :refer :all]
            [helper.database  :refer :all]

            [nucleotides.database.migrate  :as migrate]))

(use-fixtures :each (fn [f] (drop-tables) (f)))

(def tables
  [:platform-type
   :protocol-type
   :product-type
   :source-type
   :file-type
   :metric-type
   :run-mode-type

   :input-data-source
   :input-data-source-reference-file
   :input-data-file-set
   :input-data-file

   :image-type
   :image-instance
   :image-instance-task

   :benchmark-type
   :benchmark-data
   :benchmark-instance
   :task
   :task_expanded_fields])

(deftest migrate
  (testing "-main"
    (migrate/migrate (test-directory :data))
    (dorun (for [table-name tables]
             (is (not (= 0 (table-length table-name))) (str table-name))))))
