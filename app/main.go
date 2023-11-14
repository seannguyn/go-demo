// main.go
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// Read the HTML content from the file
	html, err := ioutil.ReadFile("assets/index.html")
	if err != nil {
		http.Error(w, "Error reading HTML template", http.StatusInternalServerError)
		return
	}

	// Read the value of the APP_LOCATION environment variable
	appLocation := os.Getenv("APP_LOCATION")

	// If APP_LOCATION is set, replace a placeholder in the HTML content
	if appLocation != "" {
		htmlString := string(html)
		newHTMLString := strings.Replace(htmlString, "{{APP_LOCATION}}", appLocation, 1)

		// htmlString := string(html)
		// newHTMLString := fmt.Sprintf(htmlString, "hello")

		// // htmlString = template.HTMLEscapeString(htmlString)
		// // htmlString = fmt.Sprintf(htmlString, appLocation)
		html = []byte(newHTMLString)
	} else {
		// If APP_LOCATION is not set, remove the placeholder from the HTML content
		// html = removePlaceholder(html, "From: ")
		html = removePlaceholder(html)
	}

	w.Header().Set("Content-Type", "text/html")
	w.Write(html)
}

// removePlaceholder removes the specified placeholder from the HTML content.
func removePlaceholder(html []byte) []byte {
	htmlString := string(html)
	newHTMLString := removeSubstring(htmlString, "<p>From: <span style=\"color: #ff9999;\">{{APP_LOCATION}}</span></p>")
	return []byte(newHTMLString)
}

// removeSubstring removes the first occurrence of the specified substring from the input string.
func removeSubstring(input, substring string) string {
	index := strings.Index(input, substring)
	if index == -1 {
		return input
	}
	return input[:index] + input[index+len(substring):]
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server is running on http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
