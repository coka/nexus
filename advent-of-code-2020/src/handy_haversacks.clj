(ns handy-haversacks
  (:require [clojure.set :as set]
            [clojure.string :as string]))

(defn parse-bag-color [bag]
  (-> bag
      (string/split #" bag")
      first
      (string/replace " " "-")
      keyword))

(defn parse-bag-contents [contents]
  (let [elements (string/split contents #", |\.")]
    (->> elements
         (map #(let [[_ n bag] (re-matches #"(\d) (.*)" %1)]
                 {(parse-bag-color bag) (Integer/parseInt n)}))
         (reduce merge {}))))

(defn parse-rule [line]
  (let [[container contents] (string/split line #" contain ")]
    (if (= contents "no other bags.")
      {}
      {(parse-bag-color container) (parse-bag-contents contents)})))

(defn parse-input [input]
  (reduce merge {} (map parse-rule input)))

(defn containers-of [colors rules]
  (set (filter #(not-empty (select-keys (% rules) colors))
               (keys rules))))

(defn count-colors [color input]
  (let [rules (parse-input input)]
    (count
     (loop [colors [color] total #{}]
       (let [containers (containers-of colors rules)]
         (if (empty? containers)
           total
           (recur containers (set/union total containers))))))))

(defn sum [xs]
  (reduce + xs))

(defn count-contents [contents]
  (sum (map #(sum (vals %)) contents)))

(defn fmap [f map]
  (reduce-kv (fn [m k v] (assoc m k (f v))) {} map))

(defn count-bags [color input]
  (let [rules (parse-input input)]
    (loop [colors [{color 1}]
           total 0]
      (let [nested-contents (->> colors
                                 (map #(for [[c n] %] (fmap (fn [v] (* n v)) (c rules))))
                                 flatten
                                 (filter not-empty))]
        (if (empty? nested-contents)
          total
          (recur nested-contents (+ total (count-contents nested-contents))))))))
