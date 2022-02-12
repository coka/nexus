(ns shuttle-search
  (:require [clojure.string :refer [split split-lines]]))

(defn earliest-bus [notes]
  (let [lines (split-lines notes)
        timestamp (Integer/parseInt (first lines))
        buses (map #(Integer/parseInt %) (filter #(not= "x" %) (split (second lines) #",")))
        minutes-until-bus (map (fn [bus] {bus (- bus (mod timestamp bus))}) buses)
        earliest-bus (first (apply min-key #(val (first %)) minutes-until-bus))
        [bus-id wait-time] earliest-bus]
    (* bus-id wait-time)))

(defn offset-map [ids]
  (reduce-kv #(if (= "x" %3) %1 (assoc %1 (Integer/parseInt %3) %2)) {} ids))

(defn offsets-for-timestamp [ids timestamp]
  (reduce (fn [acc id]
            (let [offset (- id (mod timestamp id))
                  normalized-offset (if (= offset id) 0 offset)]
              (assoc acc id normalized-offset))) {} ids))

(defn earliest-timestamp [buses]
  (let [maybe-ids (split buses #",")
        offsets (offset-map maybe-ids)
        ids (keys offsets)
        max-id (apply max ids)
        possible-timestamps (iterate (partial + max-id)
                                     (- max-id (get offsets max-id)))]
    (first (filter #(= offsets (offsets-for-timestamp ids %)) possible-timestamps))))
