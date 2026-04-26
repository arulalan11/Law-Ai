import re

def remove_popscope(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match PopScope block
    pattern = r"return PopScope\(\s*canPop:\s*false,\s*onPopInvokedWithResult:\s*\([^)]*\)\s*async\s*\{\s*if\s*\(didPop\)\s*return;\s*Navigator\.of\(context\)\.pushReplacement\(\s*MaterialPageRoute\(builder:\s*\(_\)\s*=>\s*const\s*DashboardScreen\(\)\),\s*\);\s*\},\s*child:\s*Scaffold\("
    
    if re.search(pattern, content):
        content = re.sub(pattern, "return Scaffold(", content)
        # remove the last ); that matched the PopScope
        content = content.rsplit(");", 1)[0] + ";" + content.rsplit(");", 1)[1]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Removed PopScope from {filepath}")
    else:
        print(f"PopScope pattern not found in {filepath}")

remove_popscope("lib/features/legal_resources/screens/templates_screen.dart")
remove_popscope("lib/features/legal_resources/screens/ipc_screen.dart")
remove_popscope("lib/features/chat/screens/chat_screen.dart")
