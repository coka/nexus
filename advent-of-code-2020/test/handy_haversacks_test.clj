(ns handy-haversacks-test
  (:require [clojure.test :refer [deftest, is]]
            [handy-haversacks :refer :all]))

(deftest bag-color-for-a-singular-bag-is-parsed
  (is (= :bright-white (parse-bag-color "bright white bag"))))

(deftest bag-color-for-a-plural-bag-is-parsed
  (is (= :light-red (parse-bag-color "light red bags"))))

(deftest bag-contents-are-parsed
  (is (= {:bright-white 1 :muted-yellow 2}
         (parse-bag-contents "1 bright white bag, 2 muted yellow bags."))))

(deftest rule-is-parsed
  (is (= {:light-red {:bright-white 1 :muted-yellow 2}}
         (parse-rule "light red bags contain 1 bright white bag, 2 muted yellow bags."))))

(deftest empty-rule-is-parsed
  (is (= {}
         (parse-rule "faded blue bags contain no other bags."))))

(def example-input-part-1
  ["light red bags contain 1 bright white bag, 2 muted yellow bags."
   "dark orange bags contain 3 bright white bags, 4 muted yellow bags."
   "bright white bags contain 1 shiny gold bag."
   "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags."
   "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags."
   "dark olive bags contain 3 faded blue bags, 4 dotted black bags."
   "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags."
   "faded blue bags contain no other bags."
   "dotted black bags contain no other bags."])

(deftest colors-are-counted
  (is (= 4 (count-colors :shiny-gold example-input-part-1))))

(deftest regression-part-1
  (is (= 296
         (with-open [reader (clojure.java.io/reader "input/7.txt")]
           (->> reader
                line-seq
                (count-colors :shiny-gold))))))

(def example-input-part-2
  ["shiny gold bags contain 2 dark red bags."
   "dark red bags contain 2 dark orange bags."
   "dark orange bags contain 2 dark yellow bags."
   "dark yellow bags contain 2 dark green bags."
   "dark green bags contain 2 dark blue bags."
   "dark blue bags contain 2 dark violet bags."
   "dark violet bags contain no other bags."])

(deftest bags-are-counted
  (is (= 126 (count-bags :shiny-gold example-input-part-2))))

(deftest regression-part-1
  (is (= 9339
         (with-open [reader (clojure.java.io/reader "input/7.txt")]
           (->> reader
                line-seq
                (count-bags :shiny-gold))))))
