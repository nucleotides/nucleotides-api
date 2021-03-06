(require '[clojure.string :as string])

(def version
  (-> "VERSION" slurp string/trim))

(defproject nucleotides-api version

  :description "REST API for nucleotid.es bioinformatics benchmarking"

  :dependencies [[circleci/clj-yaml          "0.5.5"]
                 [clj-time                   "0.11.0"]
                 [clojure.jdbc/clojure.jdbc-c3p0 "0.3.2"]
                 [com.rpl/specter            "0.9.2"]
                 [com.taoensso/timbre        "4.2.1"]
                 [liberator                  "0.13"]
                 [compojure                  "1.4.0"]
                 [medley                     "0.8.3"]
                 [migratus                   "0.8.9"]
                 [org.clojure/clojure        "1.7.0"]
                 [org.clojure/core.match     "0.3.0-alpha4"]
                 [org.clojure/data.json      "0.2.6"]
                 [org.clojure/data.csv       "0.1.3"]
                 [org.clojure/java.jdbc      "0.4.2"]
                 [postgresql/postgresql      "9.3-1102.jdbc41"]
                 [ring-logger-timbre         "0.7.5"]
                 [ring/ring-jetty-adapter    "1.3.1"]
                 [ring/ring-json             "0.4.0"]
                 [yesql                      "0.5.2"]]

  :plugins      [[lein-ring                          "0.9.0"]
                 [com.jakemccrary/lein-test-refresh  "0.11.0"]]

  :local-repo  "vendor/maven"

  :profiles {
    :dev        {:dependencies [[ring-mock "0.1.5"]]}
    :uberjar    {:aot :all}})
