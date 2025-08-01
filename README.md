## GitHub Repository Codes to PDF Converter

This script automatically finds specified source code files in your repository, combines them, and generates a single, well-formatted PDF document. It's useful for creating a comprehensive code archive or for code review purposes.

### Setup & Usage

Follow these steps to get and use the script.

**1. Get the Script**

First, clone this repository to get the `topdf.sh` file on your local machine.

```sh
git clone https://github.com/your-username/your-repository-name.git
```

*(Note: Replace the URL with the actual repository URL.)*

**2. Place the Script in Your Project**

Copy the `topdf.sh` script from the cloned directory into the **root directory of the project you want to convert to PDF**.

**3. Navigate and Execute**

Open your terminal and navigate into your project's directory.

```sh
# Example: move into your project's directory
cd /path/to/your/project
```

Make the script executable:

```sh
chmod +x topdf.sh
```

**(Optional) Configure the Script**

You can open `topdf.sh` and modify the variables at the top to fit your needs:

  * `TARGET_EXTENSIONS`: A space-separated list of file patterns to include (e.g., `"*.py" "*.js"`).
  * `OUTPUT_PDF`: The name for your final PDF file.

**Run the Script**

Execute the script from your project's root directory:

```sh
./topdf.sh
```

The script will generate the PDF in your project's directory.

-----

### Prerequisites

This script relies on external tools to function correctly. You'll need to install **Pandoc** plus at least one of the following PDF generation tools:

  * **Primary Method (Recommended):**

      * [**Pandoc**](https://pandoc.org/installing.html): For converting Markdown to other formats.
      * **A LaTeX Distribution**: such as [TeX Live](https://www.tug.org/texlive/), [MacTeX](https://www.tug.org/mactex/), or [MiKTeX](https://miktex.org/). This is required for Pandoc's `xelatex` or `pdflatex` engines.

  * **Fallback Methods:**

      * [**Google Chrome**](https://www.google.com/chrome/) / **Chromium**: Used in headless mode to convert an intermediate HTML file to PDF.
      * [**wkhtmltopdf**](https://wkhtmltopdf.org/downloads.html): An alternative command-line tool to convert HTML to PDF.

-----

### How It Works

The script automates the following process:

1.  **Finds Files**: It searches the current directory and all subdirectories for files matching the patterns in `TARGET_EXTENSIONS`.
2.  **Creates Markdown**: It compiles the contents of all found files into a single temporary Markdown file.
3.  **Generates PDF**: It intelligently tries multiple methods to convert the Markdown to PDF, starting with the highest-quality option.
4.  **Cleans Up**: It removes any temporary files.
