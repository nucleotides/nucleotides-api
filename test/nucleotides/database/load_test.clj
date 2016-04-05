(ns nucleotides.database.load-test
  (:require [clojure.test     :refer :all]
            [helper.database  :refer :all]
            [helper.fixture   :refer :all]

            [nucleotides.database.files      :as files]
            [nucleotides.database.migrate    :as mg]
            [nucleotides.database.load       :as ld]
            [nucleotides.database.connection :as con]))

(def input-data
  (:inputs (files/load-data-files "tmp/input_data")))

(defn test-data-loader [{:keys [loader tables fixtures]}]

    (testing "loading with into an empty database"
      (do (empty-database)
          (apply load-fixture fixtures)
          (loader)
          (dorun
            (for [t tables]
              (is (not (empty? (table-entries t))))))))

    (testing "reloading the same data"
      (do (empty-database)
          (apply load-fixture fixtures)
          (loader)
          (loader)
          (dorun
            (for [t tables]
              (is (not (empty? (table-entries t)))))))))


(deftest load-biological-sources
  (test-data-loader
    {:fixtures [:metadata]
     :loader   #(ld/biological-sources (:biological-source input-data))
     :tables   [:biological-source]}))

(deftest load-biological-source-reference-files
  (test-data-loader
    {:fixtures [:metadata :biological-source]
     :loader   #(ld/biological-source-files (:biological-source input-data))
     :tables   [:biological-source-reference-file]}))

(deftest load-input-data-set
  (test-data-loader
    {:fixtures [:metadata :biological-source]
     :loader   #(ld/input-data-file-set (:file input-data))
     :tables   [:input-data-file-set]}))

(deftest load-input-data-file
  (test-data-loader
    {:fixtures [:metadata :biological-source :input-data-file-set]
     :loader   #(ld/input-data-files (:file input-data))
     :tables   [:input-data-file]}))

(deftest load-image-instances
  (test-data-loader
    {:fixtures [:metadata]
     :loader   #(ld/image-instances % (:image-instance input-data))
     :tables   [:image-instance :image-instance-task]}))

(deftest load-benchmarks
  (test-data-loader
    {:fixtures [:metadata :biological-source :input-data-file-set]
     :loader   #(ld/benchmarks % (:benchmark-type input-data))
     :tables   [:benchmark-type :benchmark-data]}))

(deftest load-benchmark-instances
  (test-data-loader
    {:fixtures [:metadata :biological-source :input-data-file-set :input-data-file :assembly-image-instance :benchmarks]
     :loader   ld/rebuild-benchmark-task
     :tables   [:benchmark-instance :task]}))
