(require '[clojure.string :as string])

(def version
  (-> "VERSION" slurp string/trim))

(defproject nucleotides-api version

  :description "REST API for nucleotid.es bioinformatics benchmarking"

  :dependencies [[camel-snake-kebab          "0.3.2"]
                 [clj-time                   "0.9.0"]
                 [circleci/clj-yaml          "0.5.4"]
                 [com.rpl/specter            "0.8.0"]
                 [com.taoensso/timbre        "4.1.4"]
                 [compojure                  "1.3.1"]
                 [migratus                   "0.8.7"]
                 [org.clojure/clojure        "1.7.0"]
                 [org.clojure/data.json      "0.2.5"]
                 [org.clojure/java.jdbc      "0.4.2"]
                 [org.clojure/core.match     "0.3.0-alpha4"]
                 [postgresql/postgresql      "9.3-1102.jdbc41"]
                 [ring-logger-timbre         "0.7.4"]
                 [ring/ring-jetty-adapter    "1.3.1"]
                 [ring/ring-json             "0.4.0"]
                 [yesql                      "0.5.1"]]

  :plugins      [[lein-ring                          "0.9.0"]
                 [com.jakemccrary/lein-test-refresh  "0.11.0"]]

  :local-repo  "vendor/maven"

  :profiles {
    :dev        {:dependencies [[ring-mock "0.1.5"]]}
    :uberjar    {:aot :all}})
