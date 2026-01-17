import os
import re

def find_conflict(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                    # Find Container blocks by counting parentheses
                    start_indices = [m.start() for m in re.finditer(r'Container\s*\(', content)]
                    for start in start_indices:
                        depth = 0
                        end = -1
                        for i in range(start + 9, len(content)):
                            if content[i] == '(':
                                depth += 1
                            elif content[i] == ')':
                                if depth == 0:
                                    end = i + 1
                                    break
                                depth -= 1
                        
                        if end != -1:
                            block = content[start:end]
                            # Now check for top-level color: and decoration: in this block
                            # We can strip nested parenthesis content to only look at top level
                            top_level = ""
                            inner_depth = 0
                            for char in block[block.find('(')+1:-1]:
                                if char == '(' or char == '{' or char == '[':
                                    inner_depth += 1
                                elif char == ')' or char == '}' or char == ']':
                                    inner_depth -= 1
                                elif inner_depth == 0:
                                    top_level += char
                            
                            if 'color' in top_level and 'decoration' in top_level:
                                # Double check if it's really the property name
                                if re.search(r'\bcolor\s*:', top_level) and re.search(r'\bdecoration\s*:', top_level):
                                    print(f"CONFLICT in {path}")
                                    print(block)
                                    print("-" * 20)

find_conflict('lib')
