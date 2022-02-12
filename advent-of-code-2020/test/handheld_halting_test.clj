(ns handheld-halting-test
  (:require [clojure.test :refer [deftest
                                  is]]
            [handheld-halting :refer [input->code
                                      run-boot-code
                                      terminates?
                                      repair-boot-code]]))

(def example-input "nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
")
(def real-input (slurp "input/8.txt"))

(def example-code (input->code example-input))
(def real-code (input->code real-input))

(deftest run-boot-code-test
  (is (= 5 (run-boot-code example-code)))
  (is (= 1384 (run-boot-code real-code))))

(deftest terminates?-test
  (is (= false (terminates? example-code)))
  (is (= false (terminates? real-code)))
  (is (= true (terminates? (repair-boot-code example-code))))
  (is (= true (terminates? (repair-boot-code real-code)))))

(deftest repaired-boot-code
  (is (= 8 (run-boot-code (repair-boot-code example-code))))
  (is (= 761 (run-boot-code (repair-boot-code real-code)))))
