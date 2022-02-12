import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Predicate;
import java.util.regex.Pattern;
import java.util.stream.StreamSupport;


class PassportProcessing {
    public static void main(String[] args) throws Exception {
        var filename = args[0];
        var inputProcessor = new InputProcessor(filename);

        var passports = inputProcessor.process((map) -> new Passport(map));
        System.out.println(count(passports, Passport::isValid));

        var securePassports = inputProcessor.process((map) -> new SecurePassport(map));
        System.out.println(count(securePassports, SecurePassport::isValid));
    }

    private static <T> long count(Iterable<T> xs, Predicate<T> p) {
        return StreamSupport.stream(xs.spliterator(), false).filter(p).count();
    }
}


interface StringMapToType<T> {
    public T transform(Map<String, String> map);
}


class InputProcessor {
    private String filename;

    public InputProcessor(String filename) {
        this.filename = filename;
    }

    public <T> Iterable<T> process(StringMapToType<T> stringMapToType) throws Exception {
        var result = new ArrayList<T>();
        var fileReader = new FileReader(filename);
        var bufferedReader = new BufferedReader(fileReader);
        var completeLine = new StringBuilder();
        String currentLine;
        while ((currentLine = bufferedReader.readLine()) != null) {
            if (currentLine.isEmpty()) {
                result.add(stringMapToType.transform(lineToMap(completeLine.toString())));
                completeLine.setLength(0);
            } else {
                if (completeLine.length() == 0) {
                    completeLine.append(currentLine);
                } else {
                    completeLine.append(" ").append(currentLine);
                }
            }
        }
        result.add(stringMapToType.transform(lineToMap(completeLine.toString())));
        bufferedReader.close();
        return result;
    }

    private Map<String, String> lineToMap(String line) {
        var map = new HashMap<String, String>();
        var fields = line.split(" ");
        for (var f : fields) {
            var pair = f.split(":");
            map.put(pair[0], pair[1]);
        }
        return map;
    }
}


class Passport {
    protected String birthYear;
    protected String issueYear;
    protected String expirationYear;
    protected String height;
    protected String hairColor;
    protected String eyeColor;
    protected String passportId;

    public Passport(Map<String, String> map) {
        birthYear = map.get("byr");
        issueYear = map.get("iyr");
        expirationYear = map.get("eyr");
        height = map.get("hgt");
        hairColor = map.get("hcl");
        eyeColor = map.get("ecl");
        passportId = map.get("pid");
    }

    public boolean isValid() {
        return birthYear != null && issueYear != null && expirationYear != null && height != null
                && hairColor != null && eyeColor != null && passportId != null;
    }
}


class SecurePassport extends Passport {
    private static final Pattern YEAR_PATTERN = Pattern.compile("\\d{4}");
    private static final Pattern HEIGHT_PATTERN = Pattern.compile("(\\d+)(cm|in)");
    private static final Pattern HAIR_COLOR_PATTERN = Pattern.compile("#[0-9|a-f]{6}");
    private static final Pattern EYE_COLOR_PATTERN = Pattern.compile("amb|blu|brn|gry|grn|hzl|oth");
    private static final Pattern PASSPORT_ID_PATTERN = Pattern.compile("^\\d{9}$"); // !!!

    public SecurePassport(Map<String, String> map) {
        super(map);
    }

    public boolean isValid() {
        return super.isValid()

                && new Year(birthYear).isBetween(1920, 2002)
                && new Year(issueYear).isBetween(2010, 2020)
                && new Year(expirationYear).isBetween(2020, 2030)

                && isHeightValid()

                && HAIR_COLOR_PATTERN.matcher(hairColor).matches()
                && EYE_COLOR_PATTERN.matcher(eyeColor).matches()
                && PASSPORT_ID_PATTERN.matcher(passportId).matches();
    }

    private class Year {
        private Integer year;

        public Year(String year) {
            var matcher = YEAR_PATTERN.matcher(year);
            if (matcher.matches()) {
                this.year = Integer.parseInt(matcher.group(0));
            }
        }

        public boolean isBetween(int min, int max) {
            return year != null && year >= min && year <= max;
        }
    }

    private boolean isHeightValid() {
        var matcher = HEIGHT_PATTERN.matcher(height);
        if (!matcher.matches()) {
            return false;
        }

        var height = Integer.parseInt(matcher.group(1));
        if (matcher.group(2).equals("cm")) {
            return height >= 150 && height <= 193;
        } else {
            return height >= 59 && height <= 76;
        }
    }
}
