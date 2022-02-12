(ns adapter-array-test
  (:require [adapter-array :refer [joltage-distribution adapter-arrangements]]
            [test-utilities :refer [with-input]]
            [clojure.test :refer [deftest is]]))

(deftest joltage-distribution-test
  (is (= [7 0 5] (with-input "10_example_small" joltage-distribution)))
  (is (= [22 0 10] (with-input "10_example_large" joltage-distribution)))
  (is (= [71 0 32] (with-input "10" joltage-distribution))))

(deftest adapter-arrangements-test
  (is (= 8 (with-input "10_example_small" adapter-arrangements)))
  (is (= 19208 (with-input "10_example_large" adapter-arrangements)))
  (is (= 84627647627264 (with-input "10" adapter-arrangements))))
