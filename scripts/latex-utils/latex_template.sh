#!/usr/bin/env bash
#
# latex-template - A utility for creating LaTeX projects from templates
#

set -e

# Configuration
TEMPLATES_DIR="$HOME/.dotfiles/Latex_template"
DEFAULT_PROJECT_NAME="$(basename "$(pwd)")-latex"

# Colors for terminal output
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Help information
show_help() {
    echo -e "${BLUE}LaTeX Template Utility${RESET}"
    echo "Creates a new LaTeX project from a template."
    echo
    echo "Usage:"
    echo "  latex-template [options]"
    echo
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -n, --name NAME      Specify project name (default: current-dir-latex)"
    echo "  -t, --template NAME  Specify template to use"
    echo "  -l, --list           List available templates"
    echo
}

# List available templates
list_templates() {
    echo -e "${BLUE}Available Templates:${RESET}"
    
    # Get the list of directories in the templates directory
    templates=()
    for template in "$TEMPLATES_DIR"/*; do
        if [ -d "$template" ]; then
            template_name=$(basename "$template")
            templates+=("$template_name")
        fi
    done
    
    # Display the templates
    if [ ${#templates[@]} -eq 0 ]; then
        echo "No templates found in $TEMPLATES_DIR"
        exit 1
    fi
    
    for i in "${!templates[@]}"; do
        echo "  $((i+1)). ${templates[$i]}"
    done
    
    return 0
}

# Select a template
select_template() {
    templates=()
    for template in "$TEMPLATES_DIR"/*; do
        if [ -d "$template" ]; then
            template_name=$(basename "$template")
            templates+=("$template_name")
        fi
    done
    
    if [ ${#templates[@]} -eq 0 ]; then
        echo "No templates found in $TEMPLATES_DIR"
        exit 1
    fi
    
    echo -e "${BLUE}Select a template:${RESET}"
    for i in "${!templates[@]}"; do
        echo "  $((i+1)). ${templates[$i]}"
    done
    
    echo
    read -p "Enter template number [1-${#templates[@]}]: " choice
    
    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#templates[@]} ]; then
        echo -e "${YELLOW}Invalid selection. Please choose a number between 1 and ${#templates[@]}.${RESET}"
        exit 1
    fi
    
    selected_template=${templates[$((choice-1))]}
    echo -e "${GREEN}Selected template: $selected_template${RESET}"
    
    return 0
}

# Create the project
create_project() {
    local template_name=$1
    local project_name=$2
    
    # Check if project directory already exists
    if [ -e "$project_name" ]; then
        echo -e "${YELLOW}Error: '$project_name' already exists.${RESET}"
        exit 1
    fi
    
    # Create project directory
    mkdir -p "$project_name"
    
    # Copy template files
    cp -r "$TEMPLATES_DIR/$template_name/"* "$project_name/"
    
    echo -e "${GREEN}Project '$project_name' created successfully using the '$template_name' template.${RESET}"
    echo -e "You can find it at: ${BLUE}$(pwd)/$project_name${RESET}"
    
    return 0
}

# Parse command line arguments
PROJECT_NAME="$DEFAULT_PROJECT_NAME"
TEMPLATE_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -t|--template)
            TEMPLATE_NAME="$2"
            shift 2
            ;;
        -l|--list)
            list_templates
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1${RESET}"
            show_help
            exit 1
            ;;
    esac
done

# If template wasn't specified via command line, let user select one
if [ -z "$TEMPLATE_NAME" ]; then
    select_template
    TEMPLATE_NAME="$selected_template"
fi

# If we got here by command line arguments, verify the template exists
if [ ! -d "$TEMPLATES_DIR/$TEMPLATE_NAME" ]; then
    echo -e "${YELLOW}Error: Template '$TEMPLATE_NAME' not found.${RESET}"
    echo "Available templates:"
    list_templates
    exit 1
fi

# Confirm or ask for project name if not set via command line
if [ "$PROJECT_NAME" = "$DEFAULT_PROJECT_NAME" ]; then
    read -p "Enter project name [$PROJECT_NAME]: " input
    if [ ! -z "$input" ]; then
        PROJECT_NAME="$input"
    fi
fi

# Create the project
create_project "$TEMPLATE_NAME" "$PROJECT_NAME"

# Check for LaTeX installation
if ! command -v pdflatex &> /dev/null; then
    echo -e "\033[0;33mWarning: pdflatex not found. Your LaTeX projects may not compile correctly.\033[0m"
    echo -e "Consider installing the full LaTeX distribution with: sudo apt-get install texlive-full"
    echo -e "For a minimal installation: sudo apt-get install texlive-latex-base texlive-latex-extra texlive-fonts-recommended"
    echo -e "The full installation is recommended for complete functionality."
    echo
fi

exit 0
