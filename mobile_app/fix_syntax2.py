def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Let's fix it by replacing the extra parenthesis
    # The ending right now is:
    #       ),
    #     );
    #   }
    # }
    
    content = content.replace("      ),\n    );\n  }\n}", "    );\n  }\n}")
    
    # Also if it was slightly different spacing:
    content = content.replace("      )\n    );\n  }\n}", "    );\n  }\n}")
    content = content.replace("      ),\n    );\n  }\n}\n", "    );\n  }\n}\n")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_file("lib/features/chat/screens/chat_screen.dart")
fix_file("lib/features/legal_resources/screens/ipc_screen.dart")
fix_file("lib/features/legal_resources/screens/templates_screen.dart")
