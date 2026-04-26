import re

def main():
    path = "lib/core/widgets/main_drawer.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # DashboardScreen
    dash_pattern = r"Navigator\.of\(context\)\.pushReplacement\(\s*PageRouteBuilder\(\s*pageBuilder:\s*\([^)]*\)\s*=>\s*const DashboardScreen\(\),\s*transitionsBuilder:\s*\([^)]*\)\s*\{\s*return FadeTransition\(\s*opacity: animation,\s*child: child,\s*\);\s*\},\s*\),\s*\);"
    content = re.sub(dash_pattern, "Navigator.of(context).popUntil((route) => route.isFirst);", content)

    # other pushReplacement calls
    content = content.replace("Navigator.of(context).pushReplacement(", "Navigator.of(context).pop(); Navigator.of(context).push(")
    
    # cleanup double pops
    content = content.replace("Navigator.of(context).pop(); // Close drawer\n                                  Navigator.of(context).pop(); Navigator.of(context).push(", "Navigator.of(context).pop(); Navigator.of(context).push(")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

if __name__ == '__main__':
    main()
