(ns report-repair-test
  (:require [report-repair :as subject]
            [clojure.java.io]
            [clojure.string]
            [clojure.test :refer [deftest is]]))

(def example-input (clojure.string/split-lines "1721
979
366
299
675
1456
"))

(deftest fix-expense-report
  (is (= 514579 (subject/fix-expense-report example-input)))
  (is (= 800139 (with-open [reader (clojure.java.io/reader "input/1.txt")]
                  (->> reader line-seq subject/fix-expense-report)))))
