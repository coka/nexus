(ns adapter-array
  (:require [clojure.math.combinatorics :refer [selections]]))

(defn parse-line [line]
  (Integer/parseInt line))

(defn joltage-distribution [lines]
  (let [adapters (->> lines (map parse-line) set)
        add-jump (fn [distribution jump] (update distribution (dec jump) inc))]
    (loop [joltage 0 distribution [0 0 0]]
      (let [[j1 j2 j3] (range (+ joltage 1) (+ joltage 4))]
        (cond (contains? adapters j1) (recur (+ joltage 1) (add-jump distribution 1))
              (contains? adapters j2) (recur (+ joltage 2) (add-jump distribution 2))
              (contains? adapters j3) (recur (+ joltage 3) (add-jump distribution 3))
              :else (add-jump distribution 3))))))

(defn jump-combos [n]
  (->> n
       (selections (range 0 4))
       (filter #(= n (reduce + %)))
       (map #(filter pos? %))
       (reduce conj #{})
       count))

(defn adapter-arrangements [lines]
  (let [adapters
        (->> lines (map parse-line) sort)

        subsequent-one-jumps
        (loop [[next & rest] adapters joltage 0 in-a-row 0 jumps '()]
          (cond (nil? next) (conj jumps in-a-row)
                (= 1 (- next joltage)) (recur rest next (inc in-a-row) jumps)
                :else (recur rest next 0 (conj jumps in-a-row))))]

    (->> subsequent-one-jumps
         (filter #(> % 1))
         (map jump-combos)
         (reduce *))))
