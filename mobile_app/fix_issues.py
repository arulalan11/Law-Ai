import re
import os

def fix_syntax(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the missing parenthesis from the previous bad replace
    content = content.replace("    ;\n  }\n}", "    );\n  }\n}")
    
    # Remove unused DashboardScreen import
    content = re.sub(r"import 'package:mobile_app/features/legal_resources/screens/dashboard_screen\.dart';\n", "", content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_syntax("lib/features/chat/screens/chat_screen.dart")
fix_syntax("lib/features/legal_resources/screens/ipc_screen.dart")
fix_syntax("lib/features/legal_resources/screens/templates_screen.dart")
fix_syntax("lib/core/widgets/main_drawer.dart")

# Also fix the unused import in api_constants.dart
api_const_path = "lib/core/constants/api_constants.dart"
with open(api_const_path, 'r', encoding='utf-8') as f:
    api_content = f.read()

api_content = re.sub(r"import 'package:flutter/foundation\.dart';\n", "", api_content)

with open(api_const_path, 'w', encoding='utf-8') as f:
    f.write(api_content)

# Fix login screen tagline
login_screen_path = "lib/features/auth/screens/login_screen.dart"
with open(login_screen_path, 'r', encoding='utf-8') as f:
    login_content = f.read()

login_content = login_content.replace(
    "'Che la giustizia sia fatta',\n                textAlign: TextAlign.center,\n                style: TextStyle(color: Colors.white70),",
    "'Let justice be done',\n                textAlign: TextAlign.center,\n                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),"
)

with open(login_screen_path, 'w', encoding='utf-8') as f:
    f.write(login_content)

print("Fixes applied.")
