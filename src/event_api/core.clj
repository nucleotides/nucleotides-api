(ns event-api.core
  (:require [compojure.core         :refer [GET POST routes]]
            [ring.middleware.params :refer [wrap-params]]
            [event-api.database     :as db]))

(defn post-event
  "Process a post event request. Return 202 if
  valid otherwise return appropriate HTTP error
  code otherwise."
  [request]
  (let [required-params #{"benchmark_id"
                          "benchmark_type_code"
                          "status_code"
                          "event_type_code"}
        request-params  (set (keys (:params request)))]
    (if (superset? request-params required-params)
      {:status 202 :body (str (System/nanoTime))}
      {:status 422})))

(def api
  (wrap-params
    (routes
      (POST "/events" [] post-event))))
