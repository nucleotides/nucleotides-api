(ns nucleotides.api.tasks-test
  (:require [clojure.test                     :refer :all]
            [clojure.data.json                :as json]
            [helper.database                  :refer :all]
            [helper.fixture                   :refer :all]
            [nucleotides.database.connection  :as con]
            [nucleotides.api.tasks            :as task]))


(defn contains-task-entries [task]
  (dorun
    (for [key_ [:id :benchmark :task_type :image_name :image_sha256 :image_task :image_type]]
      (is (contains? task key_))))
  (is (not (contains? task :benchmark_instance_id))))

(defn contains-file-entries [task & entries]
  (let [files (set (:files task))]
    (is (not (empty? files)))
    (dorun
      (for [f files]
        (for [key_ [:url :type :sha256]]
          (is (contains? f key_)))))
    (dorun
      (for [entry entries]
        (is (contains? files entry))))))

(defn file-entry [[type_ url sha256 :as entry]]
  (into {} (map vector [:type :url :sha256] entry)))

(use-fixtures :once (fn [f]
                      (empty-database)
                      (load-fixture :metadata :input-data-source :input-data-file-set
                                    :input-data-file :image-instance :benchmarks :tasks)
                      (f)))

(deftest nucleotides.api.tasks

  (testing "#get"

    (testing "an incomplete produce task by its ID"
      (let [{:keys [status body]} (task/lookup {:connection (con/create-connection)} 1 {})]
        (is (= 200 status))
        (contains-task-entries body)
        (contains-file-entries body))))

    (testing "an incomplete evaluate task by its ID"
      (let [{:keys [status body]} (task/lookup {:connection (con/create-connection)} 2 {})]
        (is (= 200 status))
        (contains-task-entries body)
        (contains-file-entries
          body (file-entry ["reference_fasta" "s3://ref" "d421a4"]))))

  (comment (testing "#show"

    (testing "getting tasks for an incomplete benchmark"
      (let [{:keys [status body]} (task/show {:connection (con/create-connection)} {})]
        (is (= 200 status))
        (is (= 1 (count body)))
        (contains-task-entries (first body)))))))
