(ns nucleotides.database.load
  (:require
    [clojure.set              :as st]
    [clojure.java.jdbc        :as sql]
    [com.rpl.specter          :refer :all]
    [yesql.core               :refer [defqueries]]
    [nucleotides.database.connection :as con]))

(defqueries "nucleotides/database/queries.sql")

(defn unfold-data-replicates [entries]
  (let [select-fields (partial select
                               [ALL (collect-one :name)
                                    (keypath :entries)
                                ALL (collect-one :reference)
                                    (collect-one :reads)
                                    (collect-one :entry_id)
                                    (keypath :replicates)])]
    (mapcat
      (fn [[name reference reads entry-id replicates]]
        (let [entry-data {:reference_url (:url    reference)
                          :reference_md5 (:md5sum reference)
                          :name          name
                          :reads         reads
                          :entry_id      entry-id}]
          (map-indexed
            (fn [idx rep]
              (-> (st/rename-keys rep {:md5sum :input_md5 :url :input_url})
                  (assoc :replicate (inc idx))
                  (merge entry-data)))
            replicates)))
      (select-fields entries))))


(defn- load-entries
  "Creates a function that transforms and saves data with a given
  DB connection"
  ([transform save]
   (fn [connection data]
     (->> (transform data)
          (map #(save % {:connection connection}))
          (dorun))))
  ([save]
   (load-entries identity save)))


(def image-types
  "Select the image types and load into the database"
  (let [transform (fn [entry] (-> entry
                                  (select-keys [:image_type, :description])
                                  (st/rename-keys {:image_type :name})))]
    (load-entries (partial map transform) save-image-type<!)))

(def image-instances
  "Select the image instances and load into the database"
  (let [transform (partial select [ALL (collect-one :image_type) (keypath :image_instances)
                                   ALL (collect-one :sha256) (keypath :name)])
        zip       (partial map (partial zipmap [:image_type :sha256 :name]))]
    (load-entries (fn [entries] (zip (transform entries))) save-image-instance<!)))

(def image-tasks
  "Select the image tasks and load into the database"
  (let [transform (partial select [ALL (keypath :image_instances)
                                   ALL (collect-one :name) (collect-one :sha256) (keypath :tasks)
                                   ALL])
        zip       (partial map (partial zipmap [:name :sha256 :task]))]
    (load-entries (fn [entries] (zip (transform entries))) save-image-task<!)))

(def data-sets
  "Load data sets into the database"
  (let [transform #(select-keys % [:name, :description])]
  (load-entries (partial map transform) save-data-set<!)))

(def data-records
  "Load data records into the database"
  (load-entries unfold-data-replicates save-data-record<!))

(def metric-types
  "Load metric types into the database"
  (load-entries save-metric-type<!))

(def benchmark-types
  "Load benchmark types into the database"
  (let [f (fn [acc entry]
            (let [benchmark (dissoc entry :data_sets)]
              (->> (:data_sets entry)
                   (map (partial assoc benchmark :data_set_name))
                   (concat acc))))
        transform (partial reduce f [])]
    (load-entries transform save-benchmark-type<!)))

(defn rebuild-benchmark-task [connection]
  (let [args [{} {:connection connection}]]
    (apply populate-benchmark-instance! args)
    (apply populate-task! args)))

(def loaders
  [[data-sets        :data]
   [data-records     :data]
   [image-types      :image]
   [image-instances  :image]
   [image-tasks      :image]
   [benchmark-types  :benchmark_type]
   [metric-types     :metric_type]])

(defn load-data
  "Load and update benchmark data in the database"
  [connection data]
  (let [load_ (fn [[f k]] (f connection (k data)))]
    (do
      (dorun (map load_ loaders))
      (rebuild-benchmark-task connection))))