import os
import re

def find_conflict(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                    # Find Container blocks
                    matches = re.finditer(r'Container\s*\((.*?)\)', content, re.DOTALL)
                    for match in matches:
                        block = match.group(1)
                        # Check for color and decoration properties not inside nested builders/decorations
                        # This is tricky, but let's look for top-level color: and decoration:
                        # We count nesting of ( and {
                        lines = block.split('\n')
                        has_color = False
                        has_decoration = False
                        depth = 0
                        for line in lines:
                            # Update depth based on brackets in the line
                            depth += line.count('(') + line.count('{') - line.count(')') - line.count('}')
                            
                            # Check for property only at top level (depth <= 1 usually, depending on where we started)
                            # Actually, just check if they are top-level properties of the Container args
                            # We can use a simple regex for properties after stripping whitespace
                            stripped = line.strip()
                            if depth <= 1: # Very rough heuristic
                                if stripped.startswith('color:'):
                                    has_color = True
                                if stripped.startswith('decoration:'):
                                    has_decoration = True
                        
                        if has_color and has_decoration:
                            print(f"CONFLICT in {path}")
                            print(block)
                            print("-" * 20)

find_conflict('lib')
