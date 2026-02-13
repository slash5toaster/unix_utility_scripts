// Go program to create xkcd style passwords aka
// https://xkcd.com/936/

package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io"
	"math"
	"math/rand"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// ----------------------------------------------------------------------------\\
func checkError(e error) {
	if e != nil {
		panic(e)
	}
}

// ----------------------------------------------------------------------------\\
func countLinesInFile(fileName string) (int, error) {
	file, err := os.Open(fileName)

	if err != nil {
		return 0, err
	}

	buf := make([]byte, 1024)
	lines := 0

	for {
		readBytes, err := file.Read(buf)

		if err != nil {
			if readBytes == 0 && err == io.EOF {
				err = nil
			}
			return lines, err
		}

		lines += bytes.Count(buf[:readBytes], []byte{'\n'})
	}

	return lines, nil
}

// ----------------------------------------------------------------------------\\
func getSpecialChar() string {
	s := "@,#,$,%,^,&,+,_,?,~"
	spchar := strings.Split(s, ",")

	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	randomIndex := r.Intn(len(spchar))

	pick := spchar[randomIndex]

	return pick
}

// ----------------------------------------------------------------------------\\
func getRandomNumber(numPwr int) int {
	// get a random number with digits specified by numPwr
	// e.g.  numPwr = 4 gives numbers between 1000 and 9999
	var pwNum int = 1
	var maxNum int = int(math.Pow10(numPwr))

	// get a pseudorandom seed
	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	// make sure we have a number with correct digits
	for true {
		pwNum = r.Intn(maxNum)
		if pwNum >= maxNum/10 && pwNum < maxNum {
			break
		}
	}
	return pwNum
}

// ----------------------------------------------------------------------------\\
func getRandomWord() string {
	// read the file
	var dictFile string = "/usr/share/dict/words"
	var myWord, chosenWord = "nada", ""
	var maxLine, err = countLinesInFile(dictFile)
	var chosenLine int = 1 // default to first line

	// get a random number
	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	f, err := os.Open(dictFile)

	// if the file open fails, generate a hash
	if err == nil {
		// pick a line
		chosenLine = r.Intn(maxLine)

		defer f.Close()

		// scan the file until we get to our desired line.
		scanner := bufio.NewScanner(f)
		for lineNumb := 0; lineNumb <= chosenLine; lineNumb++ {
			scanner.Scan()
			if lineNumb == chosenLine {
				chosenWord = scanner.Text()
				break
			}
		}
		// remove punctuation from string
		reg := regexp.MustCompile("[^a-zA-Z0-9]+")
		myWord = reg.ReplaceAllString(chosenWord, "")
	} else {
		// if the file open fails for any reason, generate a random number as hex
		myWord = strconv.FormatInt(int64(getRandomNumber(18)), 16)
	}
	return myWord
}

// ----------------------------------------------------------------------------\\
func main() {
	var sChar string = ""
	var maxDigit int = 16
	var defaultDigit = 3

	numPtr := flag.Int("number", defaultDigit, "number of digits: max "+strconv.Itoa(maxDigit))
	specialPtr := flag.Bool("special", false, "Add a special char")

	flag.Parse()

	// catch if exponent overruns the int max (*must* be less than 18)
	if *numPtr > maxDigit {
		*numPtr = maxDigit
		fmt.Fprintln(os.Stderr, "--number set to max of "+strconv.Itoa(maxDigit))
	}

	if *numPtr <= 0 {
		*numPtr = defaultDigit
		fmt.Fprintln(os.Stderr, "--number set to default of "+strconv.Itoa(defaultDigit))
	}

	if *specialPtr {
		sChar = getSpecialChar()
	}

	// print a generated password
	fmt.Printf("%s%d%s%s\n",
		strings.ToLower(getRandomWord()),
		getRandomNumber(*numPtr),
		strings.Title(getRandomWord()),
		sChar,
	)

}

// End of file, if this is missing the file is truncated
///////////////////////////////////////////////////////////////////////////////
