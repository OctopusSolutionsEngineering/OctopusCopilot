zip -R OctopusCopilot.0.0.1.zip \
  '*.py' \
  '*.pyc' \
  '*.html' \
  '*.htm' \
  '*.css' \
  '*.js' \
  '*.min' \
  '*.map' \
  '*.sql' \
  '*.png' \
  '*.jpg' \
  '*.jpeg' \
  '*.gif' \
  '*.json' \
  '*.env' \
  '*.txt' \
  '*.Procfile' \
  '*.bestType' \
  '*.conf' \
  '*.encodings' \
  -x "venv/*" \
  -x "htmlcov/*" \
  -x "**/__pycache__/*" \
  -x ".vscode/*" \
  -x "tests/*"