from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import Button, Static, Input, Header, Footer
from textual.binding import Binding
from sympy import N
from sympy.parsing.sympy_parser import parse_expr, standard_transformations, implicit_multiplication_application
import pyperclip as pc
import subprocess

class Display(Static):
    """Calculator display widget."""
    
    def update_display(self, text: str) -> None:
        self.update(text)

class CalculatorApp(App):
    """A scientific calculator TUI application."""
    
    CSS_PATH = ["css/CalculatorApp.tcss"]
    
    BINDINGS = [
        Binding("ctrl+c", "exit", "Quit", show=True),
        Binding("ctrl+l", "clear", "Clear", show=False),
        Binding("escape", "clear", "Clear"),
    ]

    def __init__(self):
        super().__init__()
        self.history = []
    
    def compose(self) -> ComposeResult:
        """Create child widgets."""
        yield Header()
        
        with Container(id="calculator"):
            with Vertical(id="display-container"):
                yield Input(placeholder="Enter expression...", id="input")
                yield Static("", id="result")
            
            with Vertical(id="buttons"):
                # Row 1: Advanced functions
                with Horizontal(classes="button-row uninportant"):
                    yield Button("SHIFT", id="shift", classes="function-btn")
                    yield Button("ALPHA", id="alpha", classes="function-btn")
                    yield Button("REPLAY", id="replay", classes="function-btn")
                    yield Button("MODE", id="mode", classes="function-btn")
                    yield Button("ON", id="on", classes="function-btn")
                
                # Row 2: Math functions 1
                with Horizontal(classes="button-row"):
                    yield Button("√", id="sqrt", classes="function-btn")
                    yield Button("x²", id="square", classes="function-btn")
                    yield Button("^", id="power", classes="function-btn")
                    yield Button("log", id="log", classes="function-btn")
                    yield Button("ln", id="ln", classes="function-btn")
                
                # Row 3: Trig functions
                with Horizontal(classes="button-row"):
                    yield Button("sin", id="sin", classes="function-btn")
                    yield Button("cos", id="cos", classes="function-btn")
                    yield Button("tan", id="tan", classes="function-btn")
                    yield Button("(", id="lparen", classes="function-btn")
                    yield Button(")", id="rparen", classes="function-btn")
                
                # Row 4: Memory/special
                with Horizontal(classes="button-row"):
                    yield Button("asin", id="asin", classes="function-btn")
                    yield Button("acos", id="acos", classes="function-btn")
                    yield Button("atan", id="atan", classes="function-btn")
                    yield Button("S<=>D", id="SD", classes="function-btn")
                    yield Button("M+", id="mplus", classes="function-btn")
                
                # Row 5: Numbers 7-9
                with Horizontal(classes="button-row"):
                    yield Button("7", id="n7", classes="number-btn")
                    yield Button("8", id="n8", classes="number-btn")
                    yield Button("9", id="n9", classes="number-btn")
                    yield Button("DEL", id="del", classes="operator-btn")
                    yield Button("AC", id="clear", classes="operator-btn")
                
                # Row 6: Numbers 4-6
                with Horizontal(classes="button-row"):
                    yield Button("4", id="n4", classes="number-btn")
                    yield Button("5", id="n5", classes="number-btn")
                    yield Button("6", id="n6", classes="number-btn")
                    yield Button("×", id="multiply", classes="number-btn")
                    yield Button("÷", id="divide2", classes="number-btn")
                
                # Row 7: Numbers 1-3
                with Horizontal(classes="button-row"):
                    yield Button("1", id="n1", classes="number-btn")
                    yield Button("2", id="n2", classes="number-btn")
                    yield Button("3", id="n3", classes="number-btn")
                    yield Button("+", id="plus", classes="number-btn")
                    yield Button("-", id="minus", classes="number-btn")
                
                # Row 8: Bottom row
                with Horizontal(classes="button-row"):
                    yield Button("0", id="n0", classes="number-btn")
                    yield Button(".", id="dot", classes="number-btn")
                    yield Button("EXP", id="exp", classes="number-btn")
                    yield Button("ANS", id="ans", classes="number-btn")
                    yield Button("=", id="equals", classes="number-btn")
        
        yield Footer()
    
    def on_mount(self) -> None:
        """Focus the input when app starts."""
        self.query_one("#input", Input).focus()
        self.app.title = "Calculator"
        self.check_screen_size()
    
    def on_resize(self) -> None:
        """Handle screen resize events."""
        self.check_screen_size()
        # self.query_one("#input", Input).value = str(self.screen.size.width)
        self.set_timer(0.1, self.check_screen_size)
    
    def check_screen_size(self) -> None:
        """Apply compact mode for smaller screens."""
        screen = self.screen
        if screen.size.width < 85 or screen.size.height < 50:
            screen.add_class("compact")
        else:
            screen.remove_class("compact")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses."""
        button_id = event.button.id
        input_widget = self.query_one("#input", Input)
        current_value = input_widget.value
        button_label = str(event.button.label.plain)
        
        if button_id == "equals":
            self.calculate()
        elif button_id == "clear":
            self.action_clear()
        elif button_id == "del":
            input_widget.value = current_value[:-1]
        elif button_id == "ans":
            if self.history:
                input_widget.value = current_value + str(self.history[-1])
        elif button_id == "pi":
            input_widget.value = current_value + "pi"
        elif button_id == "e":
            input_widget.value = current_value + "E"
        elif button_id == "exp":
            input_widget.value = current_value + "e"
        elif button_id == "power":
            input_widget.value = current_value + "**"
        elif button_id == "square":
            input_widget.value = current_value + "**2"
        elif button_id == "ln":
            input_widget.value = current_value + "log("
        elif button_id == "sqrt":
            input_widget.value = current_value + "sqrt("
        elif button_id in ["sin", "cos", "tan", "asin", "acos", "atan", "log"]:
            input_widget.value = current_value + button_id + "("
        elif button_id == "divide2":
            input_widget.value = current_value + "/"
        elif button_id == "multiply":
            input_widget.value = current_value + "*"
        elif button_id == "comma":
            input_widget.value = current_value + ","
        elif button_id.startswith("n"):
            input_widget.value = current_value + button_label
        elif button_id in ["lparen", "rparen", "divide", "plus", "minus", "dot"]:
            input_widget.value = current_value + button_label
        # Ignore non-functional buttons for now
        elif button_id in ["shift", "alpha", "replay", "mode", "on", "rcl", "eng", "mplus"]:
            pass
    
    def on_input_submitted(self, event: Input.Submitted) -> None:
        """Handle Enter key in input."""
        self.calculate()
    
    def calculate(self) -> None:
        """Evaluate the expression."""
        input_widget = self.query_one("#input", Input)
        result_widget = self.query_one("#result", Static)
        expression = input_widget.value.strip()
        
        if not expression:
            return
        
        try:
            # Replace common patterns for sympy
            expression = expression.replace("^", "**")
            expression = expression.replace("π", "pi")
            expression = expression.replace("asin", "asin")
            expression = expression.replace("acos", "acos")
            expression = expression.replace("atan", "atan")
            
            # Parse and evaluate
            transformations = standard_transformations + (implicit_multiplication_application,)
            expr = parse_expr(expression, transformations=transformations)
            result = N(expr, 15)  # 15 significant digits
            
            # Store in history
            self.history.append(float(result))
            
            # Display result
            result_str = float(result)

            result_widget.update(content=f"= {result_str}")

            # Copy to clipboard
            try:
                subprocess.Popen(['wl-copy'], stdin=subprocess.PIPE, text=True).communicate(input=str(result_str), timeout=0.1)
            except:
                pass
            # pc.copy(str(result_str))
            
        except Exception as e:
            result_widget.update(f"Error: {str(e)}")
    
    def action_clear(self) -> None:
        """Clear the input and result."""
        self.query_one("#input", Input).value = ""
        self.query_one("#result", Static).update("")
    
    def action_exit(self) -> None:
        """Quit the application."""
        self.exit()


if __name__ == "__main__":
    app = CalculatorApp()
    app.run()
