#!/home/nils/scripts/calculator/env/bin/python
from textual.app import App
import sys
import numexpr as ne
from CalculatorApp import CalculatorApp

def calc_args(args):
    result = ne.evaluate("".join([str(x) for x in args]))
    return result

def main():
    if len(sys.argv) > 1:
        print(calc_args(sys.argv[1:]))
    else:
        app: App = CalculatorApp()
        app.run()


if __name__ == "__main__":
    main()
