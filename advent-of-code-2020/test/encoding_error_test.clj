(ns encoding-error-test
  (:require [encoding-error :as subject]
            [clojure.java.io]
            [clojure.string]
            [clojure.test :refer [deftest is]]))

(def example-input (clojure.string/split-lines "35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
"))

(deftest find-error
  (is (= 127 (subject/find-error 5 example-input)))
  (is (= 15690279 (with-open [reader (clojure.java.io/reader "input/9.txt")]
                    (->> reader line-seq (subject/find-error 25))))))

(deftest find-encryption-weakness
  (is (= 62 (subject/find-encryption-weakness 5 example-input)))
  (is (= 2174232 (with-open [reader (clojure.java.io/reader "input/9.txt")]
                   (->> reader line-seq (subject/find-encryption-weakness 25))))))
