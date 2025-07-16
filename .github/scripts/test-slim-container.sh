#!/bin/bash

# Test script for revo-devcontainer-slim functionality
# Parameters: CONTAINER_NAME CONTAINER_TAG

CONTAINER_NAME="$1"
CONTAINER_TAG="$2"

if [ -z "$CONTAINER_NAME" ] || [ -z "$CONTAINER_TAG" ]; then
    echo "Usage: $0 <container_name> <container_tag>"
    exit 1
fi

echo "=========================================="
echo "Testing specific functionality for: $CONTAINER_NAME"
echo "=========================================="

echo "🪶 Testing slim container specific tools..."
FAILED_TESTS=()

echo "  → Testing Python..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" python --version > /dev/null 2>&1; then
    echo "    ✅ Python found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" python --version)"
else
    echo "    ❌ Python not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("Python")
fi

echo "  → Testing Python execution..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" python -c "print('Python working in slim container')" > /dev/null 2>&1; then
    echo "    ✅ Python execution test successful"
else
    echo "    ❌ Python execution test failed - CRITICAL ERROR"
    FAILED_TESTS+=("Python execution")
fi

echo "  → Testing pip..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" which pip > /dev/null 2>&1; then
    echo "    ✅ Pip found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" pip --version)"
else
    echo "    ❌ Pip not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("pip")
fi

echo "  → Testing Git..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" git --version > /dev/null 2>&1; then
    echo "    ✅ Git found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" git --version)"
else
    echo "    ❌ Git not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("Git")
fi

echo "  → Testing make..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" make --version > /dev/null 2>&1; then
    echo "    ✅ make found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" make --version 2>/dev/null | head -1)"
else
    echo "    ❌ make not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("make")
fi

echo "  → Testing nano..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" nano --version > /dev/null 2>&1; then
    echo "    ✅ nano found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" nano --version | head -1)"
else
    echo "    ❌ nano not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("nano")
fi

echo "  → Testing tree..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" tree --version > /dev/null 2>&1; then
    echo "    ✅ tree found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" tree --version | head -1)"
else
    echo "    ❌ tree not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("tree")
fi

echo "  → Testing uv..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uv --version > /dev/null 2>&1; then
    echo "    ✅ uv found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uv --version)"
else
    echo "    ❌ uv not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("uv")
fi

echo "  → Testing uvx..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uvx --version > /dev/null 2>&1; then
    echo "    ✅ uvx found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" uvx --version)"
else
    echo "    ❌ uvx not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("uvx")
fi

echo "  → Testing uv project workflow..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" bash -c "
    uv init test-project &&
    cd test-project &&
    uv add ruff &&
    source .venv/bin/activate &&
    ruff --version &&
    echo 'uv project workflow successful'
" > /dev/null 2>&1; then
    echo "    ✅ uv project workflow working"
else
    echo "    ❌ uv project workflow failed - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("uv project workflow")
fi

echo "  → Testing ssh..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" ssh -V > /dev/null 2>&1; then
    echo "    ✅ ssh found: $(docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" ssh -V 2>&1 | head -1)"
else
    echo "    ❌ ssh not found - REQUIRED FOR SLIM CONTAINER"
    FAILED_TESTS+=("ssh")
fi

echo "  → Testing EDITOR environment variable..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" bash -c "echo \$EDITOR | grep -q nano" > /dev/null 2>&1; then
    echo "    ✅ EDITOR environment variable set to nano"
else
    echo "    ❌ EDITOR environment variable misconfigured"
    FAILED_TESTS+=("EDITOR environment variable")
fi

echo "  → Testing workspace permissions..."
if docker run --rm "$CONTAINER_NAME:$CONTAINER_TAG" test -w /workspace > /dev/null 2>&1; then
    echo "    ✅ Container has write access to workspace"
else
    echo "    ❌ Container lacks workspace write access"
    FAILED_TESTS+=("Workspace permissions")
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
