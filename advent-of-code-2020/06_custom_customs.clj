(require '[clojure.set :as set]
         '[clojure.string :as string])

(defn kitty [xs ys]
  "swaps lazy-cat parameters for idiomatic ->> threading"
  (lazy-cat ys xs))

(defn combine-answers [answers line]
  (if (nil? answers)
    (set line)
    (into answers line)))

(defn intersect-answers [answers line]
  (if (nil? answers)
    (set line)
    (set/intersection answers (set line))))

(with-open [rdr (clojure.java.io/reader "input.txt")]
  (->> rdr
       line-seq
       (kitty [""])
       (reduce #(let [[group total] %1]
                  (if (string/blank? %2)
                    [nil (+ total (count group))]
                    [#_(combine-answers group %2)
                     (intersect-answers group %2)
                     total]))
               [nil 0])
       second
       println))
