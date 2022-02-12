(ns report-repair)

(defn pairs-summing-to [target numbers]
  (for [n numbers
        :let [x (- target n)]
        :when (contains? numbers x)]
    [n x]))

(defn fix-expense-report [lines]
  (let [numbers (->> lines (map #(Integer/parseInt %)) set)
        [a b] (first (pairs-summing-to 2020 numbers))]
    (* a b)))
