(ns docking-data
  (:require [clojure.string :as string]
            [clojure.math.combinatorics :as combinatorics]))

(def wilcard-bit \X)

(defn parse-overrides [v]
  (reduce-kv #(if (= wilcard-bit %3) %1 (assoc %1 %2 %3)) {} (vec v)))

(defn parse-mem [address-specifier value]
  (let [address (string/replace address-specifier #"\D" "")]
    {(Long/parseLong address) (Long/parseLong value)}))

(defn parse-instruction [line]
  (let [[kind _ value] (string/split line #" ")]
    (if (= kind "mask") value (parse-mem kind value))))

(defn int->binary-with-padding [n]
  (string/replace (format "%36s" (Long/toBinaryString n)) " " "0"))

(defn parse-binary-string [s]
  (Long/parseLong s 2))

(defn sum-memory [[_ memory]]
  (->> memory vals (apply +)))

;;;; Part One

(defn override-bits [bits overrides]
  (reduce #(let [[position bit] %2] (assoc %1 position bit)) bits overrides))

(defn apply-overrides [overrides value]
  (let [value-bits (vec (int->binary-with-padding value))
        mangled-bits (override-bits value-bits overrides)]
    (parse-binary-string (reduce str mangled-bits))))

(defn process [[mask memory] instruction]
  (if (string? instruction)
    [instruction memory]
    (let [[address value] (first instruction)
          overrides (parse-overrides mask)]
      [mask (conj memory {address (apply-overrides overrides value)})])))

(defn decode [init-sequence]
  (->> init-sequence
       (map parse-instruction)
       (reduce process [nil {}])
       sum-memory))

;;;; Part Two

(defn memdecode [masked-address]
  (let [floating-bits (vec (keep-indexed #(when (= wilcard-bit %2) %1) masked-address))
        selections (map vec (combinatorics/selections [\0 \1] (count floating-bits)))
        targets (for [s selections]
                  (reduce-kv #(assoc %1 %3 (get s %2)) (vec masked-address) floating-bits))]
    (map #(parse-binary-string (apply str %)) targets)))

(defn mask-address [address mask]
  (let [pairs (map vec (partition 2 (interleave (int->binary-with-padding address) mask)))
        decoder (fn [masked-address [original overlay]]
                  (conj masked-address (if (= overlay \0) original overlay)))]
    (apply str (reduce decoder [] pairs))))

(defn process-v2 [[mask memory] instruction]
  (if (string? instruction)
    [instruction memory]
    (let [[address value] (first instruction)
          adresses (memdecode (mask-address address mask))]
      [mask (reduce into memory (map (fn [a] {a value}) adresses))])))

(defn decode-v2 [init-sequence]
  (->> init-sequence
       (map parse-instruction)
       (reduce process-v2 [nil {}])
       sum-memory))
