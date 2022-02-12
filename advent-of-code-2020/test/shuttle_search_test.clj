(ns shuttle-search-test
  (:require [shuttle-search :as subject]
            [clojure.string :refer [split-lines]]
            [clojure.test :refer [deftest is]]))

(def example-input (slurp "input/13_example.txt"))
(def input (slurp "input/13.txt"))

(deftest earliest-bus
  (is (= 295 (subject/earliest-bus example-input)))
  (is (= 6568 (subject/earliest-bus input))))

(deftest earliest-timestamp
  (is (= 1068781 (subject/earliest-timestamp (second (split-lines example-input)))))
  (is (= 3417 (subject/earliest-timestamp "17,x,13,19")))
  (is (= 754018 (subject/earliest-timestamp "67,7,59,61")))
  (is (= 779210 (subject/earliest-timestamp "67,x,7,59,61")))
  (is (= 1261476 (subject/earliest-timestamp "67,7,x,59,61")))
  (is (= 1202161486 (subject/earliest-timestamp "1789,37,47,1889")))
  #_(is (= 0 (subject/earliest-timestamp (second (split-lines input))))))
