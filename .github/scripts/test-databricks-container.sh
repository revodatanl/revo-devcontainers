#!/bin/bash

# Test script for revo-devcontainer-databricks functionality
# Parameters: CONTAINER_NAME CONTAINER_TAG PYTHON_VERSION

CONTAINER_NAME="$1"
CONTAINER_TAG="$2"
PYTHON_VERSION="$3"

if [ -z "$CONTAINER_NAME" ] || [ -z "$CONTAINER_TAG" ] || [ -z "$PYTHON_VERSION" ]; then
    echo "Usage: $0 <container_name> <container_tag> <python_version>"
    exit 1
fi

echo "=========================================="
echo "Testing specific functionality for: $CONTAINER_NAME"
echo "=========================================="

echo "🐍 Testing Databricks runtime specific tools..."
FAILED_TESTS=()

echo "  → Testing uv..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uv --version > /dev/null 2>&1; then
    echo "    ✅ uv found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uv --version)"
else
    echo "    ❌ uv not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("uv")
fi

echo "  → Testing uvx command..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uvx --version > /dev/null 2>&1; then
    echo "    ✅ uvx found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uvx --version)"
else
    echo "    ❌ uvx not found - REQUIRED FOR UV FUNCTIONALITY"
    FAILED_TESTS+=("uvx")
fi

echo "  → Testing uv project workflow with Python version specification..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" bash -c '
    echo "$PYTHON_VERSION" > .python-version &&
    uv init test-project &&
    cd test-project &&
    uv add ruff &&
    source .venv/bin/activate &&
    echo "Testing package availability..." &&
    uv pip list | grep -E "ruff" &&
    python -c "import ruff; print(\"ruff available\")" &&
    echo "uv workflow successful"
' > /dev/null 2>&1; then
    echo "    ✅ uv project workflow working"
else
    echo "    ❌ uv project workflow failed - CRITICAL ERROR"
    FAILED_TESTS+=("uv project workflow")
fi

echo "  → Testing Python availability through uv..."
PYTHON_VERSION_OUTPUT=$(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" bash -c "
    echo '$PYTHON_VERSION' > .python-version &&
    uv init test-project &&
    cd test-project &&
    uv sync &&
    source .venv/bin/activate &&
    python --version
" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "    ✅ Python test successful with version: $PYTHON_VERSION_OUTPUT"
else
    echo "    ❌ Python not accessible through uv - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("Python via uv")
fi

echo "  → Testing jq..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" jq --version > /dev/null 2>&1; then
    echo "    ✅ jq found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" jq --version)"
else
    echo "    ❌ jq not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("jq")
fi

echo "  → Testing jq JSON processing..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" sh -c 'echo "{\"test\": \"value\"}" | jq .test' > /dev/null 2>&1; then
    echo "    ✅ jq JSON processing test successful"
else
    echo "    ❌ jq JSON processing test failed - CRITICAL ERROR"
    FAILED_TESTS+=("jq JSON processing")
fi

echo "  → Testing Databricks CLI..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" databricks --version > /dev/null 2>&1; then
    echo "    ✅ Databricks CLI found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" databricks --version)"
else
    echo "    ❌ Databricks CLI not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("Databricks CLI")
fi

echo "  → Testing Git..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" git --version > /dev/null 2>&1; then
    echo "    ✅ Git found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" git --version)"
else
    echo "    ❌ Git not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("Git")
fi

echo "  → Testing make..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" make --version > /dev/null 2>&1; then
    echo "    ✅ make found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" make --version 2>/dev/null | head -1)"
else
    echo "    ❌ make not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("make")
fi

echo "  → Testing tree..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" tree --version > /dev/null 2>&1; then
    echo "    ✅ tree found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" tree --version | head -1)"
else
    echo "    ❌ tree not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("tree")
fi

echo "  → Testing nano..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" nano --version > /dev/null 2>&1; then
    echo "    ✅ nano found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" nano --version | head -1)"
else
    echo "    ❌ nano not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("nano")
fi

echo "  → Testing curl..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" curl --version > /dev/null 2>&1; then
    echo "    ✅ curl found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" curl --version | head -1)"
else
    echo "    ❌ curl not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("curl")
fi

echo "  → Testing wget..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" wget --version > /dev/null 2>&1; then
    echo "    ✅ wget found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" wget --version | head -1)"
else
    echo "    ❌ wget not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("wget")
fi

echo "  → Testing ssh..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" ssh -V > /dev/null 2>&1; then
    echo "    ✅ ssh found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" ssh -V 2>&1 | head -1)"
else
    echo "    ❌ ssh not found - REQUIRED FOR DATABRICKS RUNTIME"
    FAILED_TESTS+=("ssh")
fi

echo "  → Testing zsh shell environment..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "echo 'zsh working'" > /dev/null 2>&1; then
    echo "    ✅ Zsh shell working"
else
    echo "    ❌ Zsh shell failed - CRITICAL ERROR"
    FAILED_TESTS+=("Zsh shell")
fi

echo "  → Testing zsh history configuration..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "source ~/.zshrc && echo \$HISTFILE | grep -q zsh_history" > /dev/null 2>&1; then
    echo "    ✅ Zsh history configured correctly"
else
    echo "    ❌ Zsh history misconfigured - CONFIGURATION ERROR"
    FAILED_TESTS+=("Zsh history")
fi

echo "  → Testing fzf functionality..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "source ~/.zshrc && which fzf" > /dev/null 2>&1; then
    echo "    ✅ fzf found and accessible"
else
    echo "    ❌ fzf not found - REQUIRED FOR TERMINAL FUNCTIONALITY"
    FAILED_TESTS+=("fzf")
fi

echo "  → Testing fzf key bindings..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "source ~/.zshrc && test -f ~/.local/share/fzf/key-bindings.zsh" > /dev/null 2>&1; then
    echo "    ✅ fzf key bindings installed"
else
    echo "    ❌ fzf key bindings missing - CONFIGURATION ERROR"
    FAILED_TESTS+=("fzf key bindings")
fi

echo "  → Testing MCfly installation..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "source ~/.zshrc && which mcfly" > /dev/null 2>&1; then
    echo "    ✅ MCfly found and accessible"
else
    echo "    ❌ MCfly not found - REQUIRED FOR TERMINAL FUNCTIONALITY"
    FAILED_TESTS+=("MCfly")
fi

echo "  → Testing procps (ps command)..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" ps --version > /dev/null 2>&1; then
    echo "    ✅ ps (procps) found"
else
    echo "    ❌ ps (procps) not found - REQUIRED FOR SYSTEM MONITORING"
    FAILED_TESTS+=("procps")
fi

echo "  → Testing environment variables..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "echo \$EDITOR | grep -q nano" > /dev/null 2>&1; then
    echo "    ✅ EDITOR environment variable set to nano"
else
    echo "    ❌ EDITOR environment variable misconfigured - CONFIGURATION ERROR"
    FAILED_TESTS+=("EDITOR environment variable")
fi

echo "  → Testing SHELL environment variable..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "echo \$SHELL | grep -q zsh" > /dev/null 2>&1; then
    echo "    ✅ SHELL environment variable set to zsh"
else
    echo "    ❌ SHELL environment variable misconfigured - CONFIGURATION ERROR"
    FAILED_TESTS+=("SHELL environment variable")
fi

echo "  → Testing command history persistence..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" test -f /commandhistory/.zsh_history > /dev/null 2>&1; then
    echo "    ✅ Command history file exists"
else
    echo "    ❌ Command history file missing - CONFIGURATION ERROR"
    FAILED_TESTS+=("Command history")
fi

echo "  → Testing workspace permissions..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" test -w /workspace > /dev/null 2>&1; then
    echo "    ✅ Container has write access to workspace"
else
    echo "    ❌ Container lacks workspace write access - PERMISSION ERROR"
    FAILED_TESTS+=("Workspace permissions")
fi

echo "  → Testing zsh plugins (autosuggestions)..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" /bin/zsh -c "source ~/.zshrc && echo \$ZSH_CUSTOM | grep -q zsh" > /dev/null 2>&1; then
    echo "    ✅ Zsh plugins configured"
else
    echo "    ❌ Zsh plugins not properly configured - CONFIGURATION ERROR"
    FAILED_TESTS+=("Zsh plugins")
fi

echo "  → Testing fonts-powerline..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" dpkg -l fonts-powerline > /dev/null 2>&1; then
    echo "    ✅ Powerline fonts installed"
else
    echo "    ❌ Powerline fonts not installed - DISPLAY ERROR"
    FAILED_TESTS+=("Powerline fonts")
fi

# Report summary of failed tests
echo ""
echo "=========================================="
echo "📋 Test Summary for $CONTAINER_NAME"
echo "=========================================="
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo "✅ All tests passed successfully!"
else
    echo "❌ ${#FAILED_TESTS[@]} test(s) failed:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
    echo ""
    echo "🚨 Container testing failed - please review the errors above"
    exit 1
fi

echo "=========================================="