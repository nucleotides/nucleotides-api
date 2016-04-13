(ns nucleotides.database.load
  (:require
    [com.rpl.specter          :refer :all]
    [yesql.core               :refer [defqueries]]
    [camel-snake-kebab.core          :as ksk]
    [nucleotides.database.connection :as con]))

(defqueries "nucleotides/database/queries.sql")

(defn select-file-entries [k entries]
  (->> entries
       (mapcat (partial select [(collect-one :name) (keypath k) ALL]))
       (remove empty?)
       (map #(assoc (last %) :source_name (first %)))))

(defn unfold-by-key [collection-key singleton-key entry]
  (map
    #(-> entry (dissoc collection-key) (assoc singleton-key %))
    (collection-key entry)))

(defn- load-entries
  "Takes a save and optional transform function, returns a new function that
  applies 'transform' and then maps the 'save' over the data."
  ([f save]
   (fn [data]
     (->> (f data)
          (map #(save % {:connection (con/create-connection)}))
          (dorun))))
  ([save]
   (load-entries identity save)))

(def biological-sources
  "Loads input data sources into the database"
  (let [f (fn [[k v]]
            (assoc (:source v) :name (ksk/->snake_case_string k)))]
   (load-entries (partial map f) save-biological-source<!)))

(def biological-source-files
  "Loads references into file_instance table and links to input_data_source"
  (let [f (fn [[k v]]
            (->> (get-in v [:source :references])
                 (flatten)
                 (remove empty?)
                 (map #(assoc % :source_name (ksk/->snake_case_string k)))))]
   (load-entries (partial mapcat f) save-biological-source-file<!)))

(def input-data-file-set
  "Load entries into the 'input_data_file_set' table"
  (let [f (fn [[k v]]
            (->>
              (:data v)
              (map #(assoc % :source_name (ksk/->snake_case_string k)))
              (map #(dissoc % :files))))]
  (load-entries (partial mapcat f) save-input-data-file-set<!)))

(def input-data-files
  "Loads entries into 'file_instance' and links to 'input_data_file_set'"
  (let [f (fn [[k v]]
            (->> (:data v)
                 (select [ALL (collect-one :name) (keypath :files) ALL])
                 (map #(assoc (last %) :file_set_name (first %)))
                 (map #(assoc % :source_name (ksk/->snake_case_string k)))))]
   (load-entries (partial mapcat f) save-input-data-file<!)))

(def image-instances
  "Select the image instances and load into the database"
  (let [f (fn [entry]
            (map #(-> entry (dissoc :tasks) (assoc :task %)) (:tasks entry)))]
    (load-entries (partial mapcat f) save-image-instance<!)))

(def benchmark-types
  "Load entries into the 'input_data_file_set' table"
  (load-entries save-benchmark-type<!))

(def benchmark-data
  "Load benchmark types into the database"
  (let [f #(map (comp
                  (partial zipmap [:benchmark_name :source_name :file_set_name])
                  flatten)
                (select [(collect-one :name) (keypath :data_sets) ALL] %))]
    (load-entries (partial mapcat f) save-benchmark-data<!)))

(def loaders
  [[image-instances          [:inputs :image]]
   [biological-sources       [:data]]
   [biological-source-files  [:data]]
   [input-data-file-set      [:data]]
   [input-data-files         [:data]]
   [benchmark-types          [:inputs :benchmark]]
   [benchmark-data           [:inputs :benchmark]]])

(defn load-all-input-data
  "Load and update benchmark data in the database"
  [data]
  (dorun
    (for [[f ks] loaders]
      (f (get-in data ks)))))
