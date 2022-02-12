(ns docking-data-test
  (:require [docking-data :as subject]
            [test-utilities :refer [with-input]]
            [clojure.test :refer [deftest is]]))

(deftest decode
  (is (= 165 (with-input "14_example_part_one" subject/decode)))
  (is (= 5902420735773 (with-input "14" subject/decode))))

(deftest decode-v2
  (is (= 208 (with-input "14_example_part_two" subject/decode-v2)))
  (is (= 3801988250775 (with-input "14" subject/decode-v2))))
