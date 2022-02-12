(ns encoding-error
  (:require [report-repair :refer [pairs-summing-to]]))

(defn find-error [preamble-length lines]
  (let [numbers (map #(Integer/parseInt %) lines)
        preamble (into clojure.lang.PersistentQueue/EMPTY (take preamble-length numbers))
        stream (drop preamble-length numbers)]
    (loop [preamble preamble stream stream]
      (let [[target & rest] stream]
        (if (empty? (pairs-summing-to target (set preamble)))
          target
          (recur (pop (conj preamble target)) rest))))))

(defn find-encryption-weakness [preamble-length lines]
  (let [target (find-error preamble-length lines)]
    (loop [numbers (map #(Integer/parseInt %) lines)
           contiguous-range clojure.lang.PersistentQueue/EMPTY]
      (let [sum (reduce + contiguous-range)]
        (cond (= sum target) (+ (apply min contiguous-range) (apply max contiguous-range))
              (> sum target) (recur numbers (pop contiguous-range))
              (< sum target) (recur (drop 1 numbers) (conj contiguous-range (first numbers))))))))
