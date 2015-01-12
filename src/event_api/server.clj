(ns event-api.server
  (:require [event-api.database :as db]))

(defn post-event
  "Process a post event request. Return 202 if
  valid otherwise return appropriate HTTP error
  code otherwise."
  [client domain request]
  (let [params (:params request)]
    (if (db/valid-event? params)
      {:status 202
       :body (db/create-event client domain (db/create-event-map params))}
      {:status 422})))


