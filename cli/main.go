package main

import (
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/Webictbyleo/odoid/go/odoid"
)

const version = "1.0.2"

const usage = `odoid — deterministic mixed-radix ID encoding

Usage:
  odoid encode <n> [--length 6|7|8]
  odoid decode <id>
  odoid generate [--namespace <ns>] [--length 6|7|8] [--count <n>]
  odoid version

Commands:
  encode    Encode an integer to an OdoID string
  decode    Decode an OdoID string to its originating integer
  generate  Generate one or more OdoID strings
  version   Print version

Examples:
  odoid encode 1234567
  odoid encode 1234567 --length 7
  odoid decode 0D7NM7
  odoid generate --namespace orders --length 7 --count 5
`

func main() {
	if len(os.Args) < 2 {
		fmt.Fprint(os.Stderr, usage)
		os.Exit(1)
	}

	switch os.Args[1] {
	case "encode":
		runEncode(os.Args[2:])
	case "decode":
		runDecode(os.Args[2:])
	case "generate", "gen":
		runGenerate(os.Args[2:])
	case "version", "--version", "-v":
		fmt.Println(version)
	case "help", "--help", "-h":
		fmt.Print(usage)
	default:
		fmt.Fprintf(os.Stderr, "unknown command %q\n\n%s", os.Args[1], usage)
		os.Exit(1)
	}
}

// ── encode ────────────────────────────────────────────────────────────────────

func runEncode(args []string) {
	fs := flag.NewFlagSet("encode", flag.ExitOnError)
	length := fs.Int("length", 6, "OdoID length: 6, 7, or 8")
	fs.Usage = func() {
		fmt.Fprintln(os.Stderr, "usage: odoid encode <n> [--length 6|7|8]")
		fs.PrintDefaults()
	}

	// Allow the integer positional to appear before or after flags.
	flags, positional := splitArgs(args)
	if err := fs.Parse(flags); err != nil {
		os.Exit(1)
	}
	if len(positional) != 1 {
		fs.Usage()
		os.Exit(1)
	}

	n, err := strconv.ParseUint(positional[0], 10, 64)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %q is not a valid non-negative integer\n", positional[0])
		os.Exit(1)
	}

	id, err := odoid.Encode(n, *length)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	fmt.Println(id)
}

// ── decode ────────────────────────────────────────────────────────────────────

func runDecode(args []string) {
	fs := flag.NewFlagSet("decode", flag.ExitOnError)
	fs.Usage = func() {
		fmt.Fprintln(os.Stderr, "usage: odoid decode <id>")
	}

	flags, positional := splitArgs(args)
	if err := fs.Parse(flags); err != nil {
		os.Exit(1)
	}
	if len(positional) != 1 {
		fs.Usage()
		os.Exit(1)
	}

	n, err := odoid.Decode(positional[0])
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	fmt.Println(n)
}

// ── generate ──────────────────────────────────────────────────────────────────

func runGenerate(args []string) {
	fs := flag.NewFlagSet("generate", flag.ExitOnError)
	ns := fs.String("namespace", "default", "generator namespace (informational label only)")
	length := fs.Int("length", 6, "OdoID length: 6, 7, or 8")
	count := fs.Int("count", 1, "number of IDs to generate")
	ids := fs.Bool("ids-only", false, "print only the ID strings, one per line")
	fs.Usage = func() {
		fmt.Fprintln(os.Stderr, "usage: odoid generate [--namespace <ns>] [--length 6|7|8] [--count <n>] [--ids-only]")
		fs.PrintDefaults()
	}
	if err := fs.Parse(args); err != nil {
		os.Exit(1)
	}
	if *count < 1 {
		fmt.Fprintln(os.Stderr, "error: --count must be >= 1")
		os.Exit(1)
	}

	// Validate length before entering the loop.
	if err := odoid.AssertLength(*length); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	gen, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{
		Namespace: *ns,
		Length:    *length,
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating generator: %v\n", err)
		os.Exit(1)
	}

	w := os.Stdout
	for i := 0; i < *count; i++ {
		res, err := gen.Next()
		if err != nil {
			fmt.Fprintf(os.Stderr, "error generating ID: %v\n", err)
			os.Exit(1)
		}
		if *ids {
			fmt.Fprintln(w, res.ID)
		} else {
			label := *ns
			if len(label) > 20 {
				label = label[:17] + "..."
			}
			fmt.Fprintf(w, "%-*s  n=%-14d  length=%d  ns=%s\n",
				*length, res.ID, res.N, *length, label)
		}
	}

	if !*ids && *count > 1 {
		fmt.Fprintf(w, "\n%d IDs generated  namespace=%s  length=%d\n",
			*count, *ns, *length)
	}
}

// ── helpers ───────────────────────────────────────────────────────────────────

// splitArgs separates flag arguments (starting with - or --) from positional
// arguments so that flags and positionals can appear in any order.
func splitArgs(args []string) (flags, positional []string) {
	for i := 0; i < len(args); i++ {
		a := args[i]
		if strings.HasPrefix(a, "-") {
			flags = append(flags, a)
			// If the flag is a key=value form it is self-contained; otherwise
			// consume the next token as the flag value if it doesn't start with -.
			if !strings.Contains(a, "=") && i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
				i++
				flags = append(flags, args[i])
			}
		} else {
			positional = append(positional, a)
		}
	}
	return
}

// pad right-aligns s in a field of width w using spaces.
func pad(s string, w int) string {
	if len(s) >= w {
		return s
	}
	return s + strings.Repeat(" ", w-len(s))
}
